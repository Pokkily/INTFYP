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
        private string currentUserId;

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            // Get language ID from query parameter
            currentLanguageId = Request.QueryString["languageId"];
            currentUserId = GetCurrentUserId();

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

        private string GetCurrentUserId()
        {
            // Check if user is logged in
            if (Session["UserId"] != null)
                return Session["UserId"].ToString();

            // Check if we have a demo user
            if (Session["DemoUserId"] != null)
                return Session["DemoUserId"].ToString();

            // Generate a demo user ID if none exists
            string demoUserId = "DEMO_" + DateTime.Now.Ticks.ToString();
            Session["DemoUserId"] = demoUserId;

            System.Diagnostics.Debug.WriteLine($"🆔 Generated demo user ID: {demoUserId}");
            return demoUserId;
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

                    // Load user progress overview
                    await LoadUserProgressOverview();
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

        private async System.Threading.Tasks.Task LoadUserProgressOverview()
        {
            try
            {
                DocumentReference userProgressRef = db.Collection("users")
                    .Document(currentUserId)
                    .Collection("progress")
                    .Document(currentLanguageId);

                DocumentSnapshot progressSnap = await userProgressRef.GetSnapshotAsync();

                if (progressSnap.Exists)
                {
                    var data = progressSnap.ToDictionary();

                    // Display user progress (add these labels to your UI if needed)
                    int completedLessons = data.ContainsKey("completedLessons") ? Convert.ToInt32(data["completedLessons"]) : 0;
                    double averageScore = data.ContainsKey("averageScore") ? Convert.ToDouble(data["averageScore"]) : 0;
                    int currentStreak = data.ContainsKey("currentStreak") ? Convert.ToInt32(data["currentStreak"]) : 0;

                    System.Diagnostics.Debug.WriteLine($"👤 User Progress: {completedLessons} lessons completed, {averageScore:F1}% average, {currentStreak} day streak");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading user progress: {ex.Message}");
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

                        // Get user's progress for this lesson
                        var lessonProgress = await GetUserLessonProgress(currentUserId, currentLanguageId, topicName, lessonName);

                        lessons.Add(new
                        {
                            Id = lessonDoc.Id,
                            Name = lessonData.ContainsKey("name") ? lessonData["name"].ToString() : lessonName,
                            Description = lessonData.ContainsKey("description") ? lessonData["description"].ToString() : "",
                            QuestionCount = questionCount,
                            CreatedAt = lessonData.ContainsKey("createdAt") ? lessonData["createdAt"] : "",
                            TopicName = topicName,

                            // User progress data
                            IsCompleted = lessonProgress.IsCompleted,
                            BestScore = lessonProgress.BestScore,
                            TotalAttempts = lessonProgress.TotalAttempts,
                            Status = lessonProgress.Status,
                            ProgressBadge = GetProgressBadge(lessonProgress.Status, lessonProgress.BestScore)
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

        private async System.Threading.Tasks.Task<dynamic> GetUserLessonProgress(string userId, string languageId, string topicName, string lessonId)
        {
            try
            {
                DocumentReference progressRef = db.Collection("users")
                    .Document(userId)
                    .Collection("progress")
                    .Document(languageId)
                    .Collection("topics")
                    .Document(topicName)
                    .Collection("lessons")
                    .Document(lessonId);

                DocumentSnapshot progressSnap = await progressRef.GetSnapshotAsync();

                if (progressSnap.Exists)
                {
                    var data = progressSnap.ToDictionary();
                    return new
                    {
                        IsCompleted = data.ContainsKey("isCompleted") && Convert.ToBoolean(data["isCompleted"]),
                        BestScore = data.ContainsKey("bestScore") ? Convert.ToInt32(data["bestScore"]) : 0,
                        TotalAttempts = data.ContainsKey("totalAttempts") ? Convert.ToInt32(data["totalAttempts"]) : 0,
                        Status = data.ContainsKey("status") ? data["status"].ToString() : "NOT_STARTED"
                    };
                }
                else
                {
                    return new
                    {
                        IsCompleted = false,
                        BestScore = 0,
                        TotalAttempts = 0,
                        Status = "NOT_STARTED"
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting lesson progress: {ex.Message}");
                return new
                {
                    IsCompleted = false,
                    BestScore = 0,
                    TotalAttempts = 0,
                    Status = "NOT_STARTED"
                };
            }
        }

        private string GetProgressBadge(string status, int bestScore)
        {
            switch (status)
            {
                case "COMPLETED":
                    if (bestScore >= 90) return "🌟 Mastered";
                    if (bestScore >= 80) return "✅ Completed";
                    return "✅ Passed";
                case "IN_PROGRESS":
                    return "🔄 In Progress";
                case "NOT_STARTED":
                default:
                    return "⭕ Not Started";
            }
        }

        private async System.Threading.Tasks.Task<(int LessonCount, int QuestionCount)> GetLanguageStatistics(string languageId)
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

                return (lessonCount, questionCount);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting language statistics: " + ex.Message);
                return (0, 0);
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