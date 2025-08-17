using System;
using System.Configuration;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class DisplayQuestion : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();
        private string currentLanguageId;

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            // Get language ID from query parameter
            currentLanguageId = Request.QueryString["languageId"];

            if (string.IsNullOrEmpty(currentLanguageId))
            {
                Response.Redirect("Language.aspx");
                return;
            }

            if (!IsPostBack)
            {
                await LoadLanguageInfo();
                await LoadTopicsAndLessons();
            }
        }

        private void InitializeFirestore()
        {
            if (db == null)
            {
                lock (dbLock)
                {
                    if (db == null)
                    {
                        string path = Server.MapPath("~/serviceAccountKey.json");
                        Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                        db = FirestoreDb.Create("intorannetto");
                    }
                }
            }
        }

        private async System.Threading.Tasks.Task LoadLanguageInfo()
        {
            try
            {
                DocumentSnapshot languageDoc = await db.Collection("languages").Document(currentLanguageId).GetSnapshotAsync();

                if (languageDoc.Exists)
                {
                    var data = languageDoc.ToDictionary();
                    string languageName = data.ContainsKey("Name") ? data["Name"].ToString() : "Language";

                    lblLanguageName.Text = languageName + " Learning Path";
                    lblLanguageTitle.Text = languageName;
                    lblLanguageFlag.Text = data.ContainsKey("Flag") ? data["Flag"].ToString() : "🌍";
                    lblLanguageDescription.Text = data.ContainsKey("Description") ? data["Description"].ToString() : "";

                    // Load statistics
                    var stats = await GetLanguageStatistics(currentLanguageId);
                    lblTotalQuestions.Text = stats.QuestionCount.ToString();
                    lblTotalLessons.Text = stats.LessonCount.ToString();
                }
                else
                {
                    Response.Redirect("Language.aspx");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading language info: " + ex.Message);
                ShowErrorMessage("Error loading language information.");
            }
        }

        private async System.Threading.Tasks.Task LoadTopicsAndLessons()
        {
            try
            {
                // Get all topics for this language
                CollectionReference topicsRef = db.Collection("languages").Document(currentLanguageId).Collection("topics");
                QuerySnapshot topicsSnapshot = await topicsRef.GetSnapshotAsync();

                var topicsWithLessons = new List<object>();

                foreach (DocumentSnapshot topicDoc in topicsSnapshot.Documents)
                {
                    string topicName = topicDoc.Id;
                    var topicData = topicDoc.ToDictionary();

                    // Get lessons for this topic
                    CollectionReference lessonsRef = topicDoc.Reference.Collection("lessons");
                    QuerySnapshot lessonsSnapshot = await lessonsRef.OrderBy("createdAt").GetSnapshotAsync();

                    var lessons = new List<object>();
                    int totalQuestionsInTopic = 0;

                    foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                    {
                        string lessonName = lessonDoc.Id;
                        var lessonData = lessonDoc.ToDictionary();

                        // Get question count for this lesson
                        CollectionReference questionsRef = lessonDoc.Reference.Collection("questions");
                        QuerySnapshot questionsSnapshot = await questionsRef.GetSnapshotAsync();
                        int questionCount = questionsSnapshot.Documents.Count;
                        totalQuestionsInTopic += questionCount;

                        lessons.Add(new
                        {
                            Id = lessonDoc.Id,
                            Name = lessonData.ContainsKey("name") ? lessonData["name"].ToString() : lessonName,
                            Description = lessonData.ContainsKey("description") ? lessonData["description"].ToString() : "",
                            QuestionCount = questionCount,
                            CreatedAt = lessonData.ContainsKey("createdAt") ? lessonData["createdAt"] : "",
                            TopicName = topicName
                        });
                    }

                    topicsWithLessons.Add(new
                    {
                        TopicName = topicName,
                        TopicDisplayName = topicData.ContainsKey("name") ? topicData["name"].ToString() : topicName,
                        LessonCount = lessons.Count,
                        QuestionCount = totalQuestionsInTopic,
                        Lessons = lessons,
                        CollapseId = "topic_" + topicName.Replace(" ", "_").Replace("#", "").Replace(".", "")
                    });
                }

                if (topicsWithLessons.Count > 0)
                {
                    rptTopics.DataSource = topicsWithLessons;
                    rptTopics.DataBind();
                    pnlNoQuestions.Visible = false;

                    // Update quick stats in sidebar
                    int totalTopics = topicsWithLessons.Count;
                    int totalLessons = 0;
                    foreach (var topic in topicsWithLessons)
                    {
                        totalLessons += ((dynamic)topic).LessonCount;
                    }

                    // Update sidebar labels directly
                    lblQuickTopics.Text = totalTopics.ToString();
                    lblQuickLessons.Text = totalLessons.ToString();
                }
                else
                {
                    rptTopics.DataSource = null;
                    rptTopics.DataBind();
                    pnlNoQuestions.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading topics and lessons: " + ex.Message);
                ShowErrorMessage("Error loading content. Please try again.");
            }
        }

        private async System.Threading.Tasks.Task<(int LessonCount, int QuestionCount, int StudentCount)> GetLanguageStatistics(string languageId)
        {
            try
            {
                int lessonCount = 0;
                int questionCount = 0;

                // Get all topics
                CollectionReference topicsRef = db.Collection("languages").Document(languageId).Collection("topics");
                QuerySnapshot topicsSnapshot = await topicsRef.GetSnapshotAsync();

                foreach (DocumentSnapshot topicDoc in topicsSnapshot.Documents)
                {
                    // Get lessons in this topic
                    CollectionReference lessonsRef = topicDoc.Reference.Collection("lessons");
                    QuerySnapshot lessonsSnapshot = await lessonsRef.GetSnapshotAsync();
                    lessonCount += lessonsSnapshot.Documents.Count;

                    // Get questions in each lesson
                    foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                    {
                        CollectionReference questionsRef = lessonDoc.Reference.Collection("questions");
                        QuerySnapshot questionsSnapshot = await questionsRef.GetSnapshotAsync();
                        questionCount += questionsSnapshot.Documents.Count;
                    }
                }

                // Get student enrollment count
                Query studentsQuery = db.Collection("enrollments").WhereEqualTo("LanguageId", languageId).WhereEqualTo("Status", "Active");
                QuerySnapshot studentsSnapshot = await studentsQuery.GetSnapshotAsync();
                int studentCount = studentsSnapshot.Documents.Count;

                return (lessonCount, questionCount, studentCount);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting language statistics: " + ex.Message);
                return (0, 0, 0);
            }
        }

        protected void btnBackToLanguages_Click(object sender, EventArgs e)
        {
            Response.Redirect("Language.aspx");
        }

        protected void rptTopics_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // Find the nested repeater for lessons
                Repeater rptLessons = (Repeater)e.Item.FindControl("rptLessons");
                if (rptLessons != null)
                {
                    var dataItem = e.Item.DataItem as dynamic;
                    if (dataItem != null && dataItem.Lessons != null)
                    {
                        rptLessons.DataSource = dataItem.Lessons;
                        rptLessons.DataBind();
                    }
                }
            }
        }

        protected void rptLessons_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Parse the command argument which contains "lessonId|topicName"
            string[] args = e.CommandArgument.ToString().Split('|');
            if (args.Length != 2) return;

            string lessonId = args[0];
            string topicName = args[1];

            try
            {
                if (e.CommandName == "StartLesson")
                {
                    // Redirect to the lesson/quiz page for this specific lesson
                    string redirectUrl = $"TakeQuiz.aspx?languageId={currentLanguageId}&topicName={Server.UrlEncode(topicName)}&lessonId={Server.UrlEncode(lessonId)}";
                    Response.Redirect(redirectUrl, false);
                    Context.ApplicationInstance.CompleteRequest();
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error: " + ex.Message);
            }
        }

        private async System.Threading.Tasks.Task DeleteLesson(string topicName, string lessonId)
        {
            try
            {
                DocumentReference lessonRef = db.Collection("languages")
                    .Document(currentLanguageId)
                    .Collection("topics")
                    .Document(topicName)
                    .Collection("lessons")
                    .Document(lessonId);

                // First, delete all questions in this lesson
                CollectionReference questionsRef = lessonRef.Collection("questions");
                QuerySnapshot questionsSnapshot = await questionsRef.GetSnapshotAsync();

                // Delete all questions
                foreach (DocumentSnapshot questionDoc in questionsSnapshot.Documents)
                {
                    await questionDoc.Reference.DeleteAsync();
                }

                // Then delete the lesson itself
                await lessonRef.DeleteAsync();

                ShowSuccessMessage("Lesson and all its questions deleted successfully!");

                // Reload topics and lessons
                await LoadTopicsAndLessons();
                await LoadLanguageInfo(); // Refresh statistics
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error deleting lesson: " + ex.Message);
                ShowErrorMessage("Error deleting lesson. Please try again.");
            }
        }

        // Method to get all questions in a lesson
        public async System.Threading.Tasks.Task<List<object>> GetQuestionsInLesson(string topicName, string lessonId)
        {
            try
            {
                CollectionReference questionsRef = db.Collection("languages")
                    .Document(currentLanguageId)
                    .Collection("topics")
                    .Document(topicName)
                    .Collection("lessons")
                    .Document(lessonId)
                    .Collection("questions");

                QuerySnapshot questionsSnapshot = await questionsRef.OrderBy("order").GetSnapshotAsync();

                var questions = new List<object>();

                foreach (DocumentSnapshot questionDoc in questionsSnapshot.Documents)
                {
                    var questionData = questionDoc.ToDictionary();

                    // Parse options
                    var options = new List<string>();
                    if (questionData.ContainsKey("options") && questionData["options"] is object[] optionArray)
                    {
                        foreach (var option in optionArray)
                        {
                            options.Add(option.ToString());
                        }
                    }

                    questions.Add(new
                    {
                        Id = questionDoc.Id,
                        Text = questionData.ContainsKey("text") ? questionData["text"].ToString() : "",
                        Type = questionData.ContainsKey("questionType") ? questionData["questionType"].ToString() : "text",
                        Order = questionData.ContainsKey("order") ? Convert.ToInt32(questionData["order"]) : 1,
                        ImagePath = questionData.ContainsKey("imagePath") ? questionData["imagePath"].ToString() : "",
                        AudioPath = questionData.ContainsKey("audioPath") ? questionData["audioPath"].ToString() : "",
                        Options = options,
                        Answer = questionData.ContainsKey("answer") ? questionData["answer"].ToString() : ""
                    });
                }

                return questions;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting questions in lesson: " + ex.Message);
                return new List<object>();
            }
        }

        // Method to get lesson details
        public async System.Threading.Tasks.Task<object> GetLessonDetails(string topicName, string lessonId)
        {
            try
            {
                DocumentSnapshot lessonDoc = await db.Collection("languages")
                    .Document(currentLanguageId)
                    .Collection("topics")
                    .Document(topicName)
                    .Collection("lessons")
                    .Document(lessonId)
                    .GetSnapshotAsync();

                if (lessonDoc.Exists)
                {
                    var lessonData = lessonDoc.ToDictionary();

                    // Get question count
                    CollectionReference questionsRef = lessonDoc.Reference.Collection("questions");
                    QuerySnapshot questionsSnapshot = await questionsRef.GetSnapshotAsync();

                    return new
                    {
                        Id = lessonDoc.Id,
                        Name = lessonData.ContainsKey("name") ? lessonData["name"].ToString() : lessonId,
                        Description = lessonData.ContainsKey("description") ? lessonData["description"].ToString() : "",
                        QuestionCount = questionsSnapshot.Documents.Count,
                        CreatedAt = lessonData.ContainsKey("createdAt") ? lessonData["createdAt"] : "",
                        TopicName = topicName
                    };
                }

                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting lesson details: " + ex.Message);
                return null;
            }
        }

        private void ShowErrorMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                $"alert('{message}');", true);
        }

        private void ShowSuccessMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                $"alert('{message}');", true);
        }
    }
}