using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;
using System.Web;

namespace INTFYP
{
    public partial class AddLanguageCard : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        // Data Models
        [FirestoreData]
        public class Language
        {
            [FirestoreProperty]
            public string Id { get; set; }

            [FirestoreProperty]
            public string Name { get; set; }

            [FirestoreProperty]
            public string Code { get; set; }

            [FirestoreProperty]
            public string Description { get; set; }

            [FirestoreProperty]
            public string Flag { get; set; }

            [FirestoreProperty]
            public string Difficulty { get; set; }

            [FirestoreProperty]
            public DateTime CreatedDate { get; set; }

            [FirestoreProperty]
            public int StudentCount { get; set; }

            [FirestoreProperty]
            public bool IsActive { get; set; }

            // Calculated property for UI
            public int LessonCount { get; set; }
        }

        [FirestoreData]
        public class Lesson
        {
            [FirestoreProperty]
            public string Id { get; set; }

            [FirestoreProperty]
            public string LanguageId { get; set; }

            [FirestoreProperty]
            public string Title { get; set; }

            [FirestoreProperty]
            public string Description { get; set; }

            [FirestoreProperty]
            public string Difficulty { get; set; } // Beginner, Intermediate, Advanced

            [FirestoreProperty]
            public int Order { get; set; }

            [FirestoreProperty]
            public DateTime CreatedDate { get; set; }

            [FirestoreProperty]
            public bool IsActive { get; set; }

            [FirestoreProperty]
            public List<string> Topics { get; set; }

            // Calculated property for UI
            public int QuestionCount { get; set; }
        }

        [FirestoreData]
        public class Question
        {
            [FirestoreProperty]
            public string Id { get; set; }

            [FirestoreProperty]
            public string LessonId { get; set; }

            [FirestoreProperty]
            public string LanguageId { get; set; }

            [FirestoreProperty]
            public string QuestionText { get; set; }

            [FirestoreProperty]
            public string Type { get; set; } // MultipleChoice, TrueFalse, FillInBlank, etc.

            [FirestoreProperty]
            public List<AnswerOption> Options { get; set; }

            [FirestoreProperty]
            public string Explanation { get; set; }

            [FirestoreProperty]
            public int Points { get; set; }

            [FirestoreProperty]
            public string Difficulty { get; set; }

            [FirestoreProperty]
            public int Order { get; set; }

            [FirestoreProperty]
            public DateTime CreatedDate { get; set; }

            [FirestoreProperty]
            public bool IsActive { get; set; }
        }

        [FirestoreData]
        public class AnswerOption
        {
            [FirestoreProperty]
            public string Text { get; set; }

            [FirestoreProperty]
            public bool IsCorrect { get; set; }

            [FirestoreProperty]
            public string Explanation { get; set; }
        }

        // Page state enum
        public enum PageState
        {
            Languages,
            Lessons,
            Questions
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore();
                LoadLanguages();
            }
            else
            {
                // Handle postback events
                string eventTarget = Request["__EVENTTARGET"];
                string eventArgument = Request["__EVENTARGUMENT"];

                if (eventTarget == hdnSelectedLanguageId.UniqueID && eventArgument == "SelectLanguage")
                {
                    LoadLessonsForLanguage(hdnSelectedLanguageId.Value);
                }
                else if (eventTarget == hdnSelectedLessonId.UniqueID && eventArgument == "SelectLesson")
                {
                    LoadQuestionsForLesson(hdnSelectedLessonId.Value);
                }
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
                        try
                        {
                            string path = Server.MapPath("~/serviceAccountKey.json");
                            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                            db = FirestoreDb.Create("intorannetto");
                        }
                        catch (Exception ex)
                        {
                            ShowAlert($"Firebase initialization error: {ex.Message}", "error");
                        }
                    }
                }
            }
        }

        private async void LoadLanguages()
        {
            try
            {
                await LoadLanguagesAsync();
            }
            catch (Exception ex)
            {
                ShowAlert($"Error loading languages: {ex.Message}", "error");
            }
        }

        private async Task LoadLanguagesAsync()
        {
            try
            {
                var languages = await GetAllLanguagesWithLessonCount();

                if (languages.Any())
                {
                    rptLanguages.DataSource = languages.OrderBy(l => l.Name);
                    rptLanguages.DataBind();
                    pnlNoLanguages.Visible = false;
                }
                else
                {
                    rptLanguages.DataSource = null;
                    rptLanguages.DataBind();
                    pnlNoLanguages.Visible = true;
                }

                // Show languages panel
                ShowPanel(PageState.Languages);
            }
            catch (Exception ex)
            {
                ShowAlert($"Error loading languages: {ex.Message}", "error");
            }
        }

        private async Task<List<Language>> GetAllLanguagesWithLessonCount()
        {
            var languages = new List<Language>();

            try
            {
                // Get all active languages
                CollectionReference languagesRef = db.Collection("languages");
                Query query = languagesRef.WhereEqualTo("IsActive", true);
                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    if (document.Exists)
                    {
                        var language = document.ConvertTo<Language>();

                        // Get lesson count for this language
                        language.LessonCount = await GetLessonCountForLanguage(language.Id);

                        languages.Add(language);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving languages: {ex.Message}");
            }

            return languages;
        }

        private async Task<int> GetLessonCountForLanguage(string languageId)
        {
            try
            {
                Query query = db.Collection("lessons")
                               .WhereEqualTo("LanguageId", languageId)
                               .WhereEqualTo("IsActive", true);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Count;
            }
            catch
            {
                return 0;
            }
        }

        private async void LoadLessonsForLanguage(string languageId)
        {
            try
            {
                await LoadLessonsAsync(languageId);
            }
            catch (Exception ex)
            {
                ShowAlert($"Error loading lessons: {ex.Message}", "error");
            }
        }

        private async Task LoadLessonsAsync(string languageId)
        {
            try
            {
                // Get language name for display
                var language = await GetLanguageById(languageId);
                if (language != null)
                {
                    lblSelectedLanguage.Text = $"{language.Flag} {language.Name}";
                }

                var lessons = await GetLessonsForLanguage(languageId);

                if (lessons.Any())
                {
                    rptLessons.DataSource = lessons.OrderBy(l => l.Order).ThenBy(l => l.Title);
                    rptLessons.DataBind();
                    pnlNoLessons.Visible = false;
                }
                else
                {
                    rptLessons.DataSource = null;
                    rptLessons.DataBind();
                    pnlNoLessons.Visible = true;
                }

                // Show lessons panel
                ShowPanel(PageState.Lessons);
            }
            catch (Exception ex)
            {
                ShowAlert($"Error loading lessons: {ex.Message}", "error");
            }
        }

        private async Task<Language> GetLanguageById(string languageId)
        {
            try
            {
                DocumentReference languageRef = db.Collection("languages").Document(languageId);
                DocumentSnapshot languageDoc = await languageRef.GetSnapshotAsync();

                if (languageDoc.Exists)
                {
                    return languageDoc.ConvertTo<Language>();
                }
            }
            catch
            {
                // Return null on error
            }

            return null;
        }

        private async Task<List<Lesson>> GetLessonsForLanguage(string languageId)
        {
            var lessons = new List<Lesson>();

            try
            {
                Query query = db.Collection("lessons")
                               .WhereEqualTo("LanguageId", languageId)
                               .WhereEqualTo("IsActive", true);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    if (document.Exists)
                    {
                        var lesson = document.ConvertTo<Lesson>();

                        // Get question count for this lesson
                        lesson.QuestionCount = await GetQuestionCountForLesson(lesson.Id);

                        lessons.Add(lesson);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving lessons: {ex.Message}");
            }

            return lessons;
        }

        private async Task<int> GetQuestionCountForLesson(string lessonId)
        {
            try
            {
                Query query = db.Collection("questions")
                               .WhereEqualTo("LessonId", lessonId)
                               .WhereEqualTo("IsActive", true);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Count;
            }
            catch
            {
                return 0;
            }
        }

        private async void LoadQuestionsForLesson(string lessonId)
        {
            try
            {
                await LoadQuestionsAsync(lessonId);
            }
            catch (Exception ex)
            {
                ShowAlert($"Error loading questions: {ex.Message}", "error");
            }
        }

        private async Task LoadQuestionsAsync(string lessonId)
        {
            try
            {
                // Get lesson info for display
                var lesson = await GetLessonById(lessonId);
                if (lesson != null)
                {
                    lblSelectedLesson.Text = $"📚 {lesson.Title}";
                }

                var questions = await GetQuestionsForLesson(lessonId);

                if (questions.Any())
                {
                    rptQuestions.DataSource = questions.OrderBy(q => q.Order).ThenBy(q => q.CreatedDate);
                    rptQuestions.DataBind();
                    pnlNoQuestions.Visible = false;
                    lblQuestionCount.Text = $"{questions.Count} Questions";
                }
                else
                {
                    rptQuestions.DataSource = null;
                    rptQuestions.DataBind();
                    pnlNoQuestions.Visible = true;
                    lblQuestionCount.Text = "0 Questions";
                }

                // Show questions panel
                ShowPanel(PageState.Questions);
            }
            catch (Exception ex)
            {
                ShowAlert($"Error loading questions: {ex.Message}", "error");
            }
        }

        private async Task<Lesson> GetLessonById(string lessonId)
        {
            try
            {
                DocumentReference lessonRef = db.Collection("lessons").Document(lessonId);
                DocumentSnapshot lessonDoc = await lessonRef.GetSnapshotAsync();

                if (lessonDoc.Exists)
                {
                    return lessonDoc.ConvertTo<Lesson>();
                }
            }
            catch
            {
                // Return null on error
            }

            return null;
        }

        private async Task<List<Question>> GetQuestionsForLesson(string lessonId)
        {
            var questions = new List<Question>();

            try
            {
                Query query = db.Collection("questions")
                               .WhereEqualTo("LessonId", lessonId)
                               .WhereEqualTo("IsActive", true);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    if (document.Exists)
                    {
                        var question = document.ConvertTo<Question>();

                        // Ensure Options list is initialized
                        if (question.Options == null)
                        {
                            question.Options = new List<AnswerOption>();
                        }

                        questions.Add(question);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving questions: {ex.Message}");
            }

            return questions;
        }

        private void ShowPanel(PageState state)
        {
            // Hide all panels
            pnlLanguages.Visible = false;
            pnlLessons.Visible = false;
            pnlQuestions.Visible = false;
            pnlBackButton.Visible = false;

            // Show appropriate panel
            switch (state)
            {
                case PageState.Languages:
                    pnlLanguages.Visible = true;
                    break;
                case PageState.Lessons:
                    pnlLessons.Visible = true;
                    pnlBackButton.Visible = true;
                    btnBack.Text = "<i class=\"fas fa-arrow-left me-2\"></i>Back to Languages";
                    break;
                case PageState.Questions:
                    pnlQuestions.Visible = true;
                    pnlBackButton.Visible = true;
                    btnBack.Text = "<i class=\"fas fa-arrow-left me-2\"></i>Back to Lessons";
                    break;
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            if (pnlQuestions.Visible)
            {
                // From questions back to lessons
                LoadLessonsForLanguage(hdnSelectedLanguageId.Value);
            }
            else if (pnlLessons.Visible)
            {
                // From lessons back to languages
                LoadLanguages();
            }
        }

        protected void rptLanguages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Handle any additional language-related commands if needed
        }

        protected void rptLessons_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Handle any additional lesson-related commands if needed
        }

        private void ShowAlert(string message, string type)
        {
            pnlAlert.Visible = true;
            lblMessage.Text = message;

            string cssClass = type == "success" ? "alert-success-glass" : "alert-danger-glass";
            alertDiv.Attributes["class"] = $"alert-glass {cssClass}";
        }

        // Additional utility methods for future enhancements

        public async Task<bool> CreateSampleData()
        {
            try
            {
                // Create sample language if none exists
                var languages = await GetAllLanguagesWithLessonCount();
                if (!languages.Any())
                {
                    await CreateSampleLanguageData();
                }
                return true;
            }
            catch
            {
                return false;
            }
        }

        private async Task CreateSampleLanguageData()
        {
            try
            {
                // Sample language
                var sampleLanguage = new Language
                {
                    Id = Guid.NewGuid().ToString(),
                    Name = "Spanish",
                    Code = "ES",
                    Description = "Learn Spanish from beginner to advanced level",
                    Flag = "🇪🇸",
                    Difficulty = "Beginner",
                    CreatedDate = DateTime.UtcNow,
                    StudentCount = 0,
                    IsActive = true
                };

                DocumentReference languageRef = db.Collection("languages").Document(sampleLanguage.Id);
                await languageRef.SetAsync(sampleLanguage);

                // Sample lesson
                var sampleLesson = new Lesson
                {
                    Id = Guid.NewGuid().ToString(),
                    LanguageId = sampleLanguage.Id,
                    Title = "Basic Greetings",
                    Description = "Learn how to greet people in Spanish",
                    Difficulty = "Beginner",
                    Order = 1,
                    CreatedDate = DateTime.UtcNow,
                    IsActive = true,
                    Topics = new List<string> { "Greetings", "Basic Conversation" }
                };

                DocumentReference lessonRef = db.Collection("lessons").Document(sampleLesson.Id);
                await lessonRef.SetAsync(sampleLesson);

                // Sample question
                var sampleQuestion = new Question
                {
                    Id = Guid.NewGuid().ToString(),
                    LessonId = sampleLesson.Id,
                    LanguageId = sampleLanguage.Id,
                    QuestionText = "How do you say 'Hello' in Spanish?",
                    Type = "Multiple Choice",
                    Options = new List<AnswerOption>
                    {
                        new AnswerOption { Text = "Hola", IsCorrect = true, Explanation = "Correct! 'Hola' means hello in Spanish." },
                        new AnswerOption { Text = "Adiós", IsCorrect = false, Explanation = "'Adiós' means goodbye." },
                        new AnswerOption { Text = "Gracias", IsCorrect = false, Explanation = "'Gracias' means thank you." },
                        new AnswerOption { Text = "Por favor", IsCorrect = false, Explanation = "'Por favor' means please." }
                    },
                    Explanation = "'Hola' is the most common way to say hello in Spanish.",
                    Points = 10,
                    Difficulty = "Beginner",
                    Order = 1,
                    CreatedDate = DateTime.UtcNow,
                    IsActive = true
                };

                DocumentReference questionRef = db.Collection("questions").Document(sampleQuestion.Id);
                await questionRef.SetAsync(sampleQuestion);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error creating sample data: {ex.Message}");
            }
        }

        public async Task<Dictionary<string, object>> GetLessonProgress(string studentId, string lessonId)
        {
            var progress = new Dictionary<string, object>();

            try
            {
                // This would track student progress through lessons
                // Implementation depends on your progress tracking system
                Query progressQuery = db.Collection("student_progress")
                                       .WhereEqualTo("StudentId", studentId)
                                       .WhereEqualTo("LessonId", lessonId);

                QuerySnapshot snapshot = await progressQuery.GetSnapshotAsync();

                if (snapshot.Documents.Count > 0)
                {
                    var doc = snapshot.Documents.First();
                    progress = doc.ToDictionary();
                }
                else
                {
                    // Initialize default progress
                    progress["Completed"] = false;
                    progress["Score"] = 0;
                    progress["TimeSpent"] = 0;
                    progress["LastAttempt"] = DateTime.UtcNow;
                }
            }
            catch
            {
                // Return default progress on error
                progress["Completed"] = false;
                progress["Score"] = 0;
            }

            return progress;
        }
    }
}