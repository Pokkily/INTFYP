using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class Language : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();
        private string currentUserEmail;
        private string currentUserName;
        private string currentUserId;

        protected async void Page_Load(object sender, EventArgs e)
        {
            currentUserEmail = Session["email"]?.ToString();
            currentUserName = Session["username"]?.ToString() ?? "Anonymous";
            currentUserId = Session["userId"]?.ToString();

            if (string.IsNullOrEmpty(currentUserEmail) || string.IsNullOrEmpty(currentUserId))
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            InitializeFirestore();
            if (!IsPostBack)
            {
                await LoadLanguages();
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
                            ShowErrorMessage("Error initializing database: " + ex.Message);
                        }
                    }
                }
            }
        }

        private async System.Threading.Tasks.Task LoadLanguages(string searchTerm = "")
        {
            try
            {
                Query languagesQuery = db.Collection("languages").OrderBy("Name");
                QuerySnapshot snapshot = await languagesQuery.GetSnapshotAsync();

                var languages = new List<object>();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var data = document.ToDictionary();

                    string languageName = data.ContainsKey("Name") ? data["Name"].ToString() : "";
                    string languageCode = data.ContainsKey("Code") ? data["Code"].ToString() : "";
                    string languageFlag = data.ContainsKey("Flag") ? data["Flag"].ToString() : "🌍";
                    string languageDescription = data.ContainsKey("Description") ? data["Description"].ToString() : "";

                    if (!string.IsNullOrEmpty(searchTerm) &&
                        !languageName.ToLower().Contains(searchTerm.ToLower()) &&
                        !languageCode.ToLower().Contains(searchTerm.ToLower()))
                    {
                        continue;
                    }

                    var stats = await GetLanguageStatistics(document.Id);

                    languages.Add(new
                    {
                        Id = document.Id,
                        Name = languageName,
                        Code = languageCode,
                        Flag = languageFlag,
                        Description = languageDescription,
                        CreatedDate = data.ContainsKey("CreatedAt") ? data["CreatedAt"] :
                                    data.ContainsKey("CreatedDate") ? data["CreatedDate"] :
                                    Timestamp.GetCurrentTimestamp(),
                        LessonCount = stats.LessonCount,
                        QuestionCount = stats.QuestionCount,
                        StudentCount = stats.StudentCount
                    });
                }

                if (languages.Count > 0)
                {
                    rptLanguages.DataSource = languages;
                    rptLanguages.DataBind();
                    pnlNoLanguages.Visible = false;
                }
                else
                {
                    rptLanguages.DataSource = null;
                    rptLanguages.DataBind();
                    pnlNoLanguages.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading languages: " + ex.Message);
                ShowErrorMessage("Error loading languages. Please try again.");
            }
        }

        private async System.Threading.Tasks.Task<(int LessonCount, int QuestionCount, int StudentCount)> GetLanguageStatistics(string languageId)
        {
            try
            {
                int lessonCount = 0;
                int questionCount = 0;
                int studentCount = 0;

                Query lessonsQuery = db.Collection("lessons").WhereEqualTo("LanguageId", languageId);
                QuerySnapshot lessonsSnapshot = await lessonsQuery.GetSnapshotAsync();
                lessonCount = lessonsSnapshot.Documents.Count;

                foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                {
                    Query questionsQuery = db.Collection("questions").WhereEqualTo("LessonId", lessonDoc.Id);
                    QuerySnapshot questionsSnapshot = await questionsQuery.GetSnapshotAsync();
                    questionCount += questionsSnapshot.Documents.Count;
                }

                Query studentsQuery = db.Collection("userLanguages").WhereEqualTo("LanguageId", languageId);
                QuerySnapshot studentsSnapshot = await studentsQuery.GetSnapshotAsync();
                studentCount = studentsSnapshot.Documents.Count;

                return (lessonCount, questionCount, studentCount);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting language statistics: " + ex.Message);
                return (0, 0, 0);
            }
        }

        protected async void txtLanguageSearch_TextChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(currentUserId))
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            string searchTerm = txtLanguageSearch.Text.Trim();
            await LoadLanguages(searchTerm);
        }

        protected async void rptLanguages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (string.IsNullOrEmpty(currentUserId))
            {
                ShowErrorMessage("Please log in to select a language.");
                return;
            }

            if (e.CommandName == "SelectLanguage")
            {
                string languageId = e.CommandArgument.ToString();

                try
                {
                    await EnrollUserInLanguage(currentUserId, languageId);

                    Response.Redirect($"DisplayQuestion.aspx?languageId={languageId}", false);
                    Context.ApplicationInstance.CompleteRequest();
                }
                catch (Exception ex)
                {
                    ShowErrorMessage("Error selecting language: " + ex.Message);
                }
            }
        }

        protected void btnStudentReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(currentUserId))
            {
                ShowErrorMessage("Please log in to view reports.");
                return;
            }

            Response.Redirect("StudentReports.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowErrorMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                $"alert('{message.Replace("'", "\\'")}');", true);
        }

        private void ShowSuccessMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                $"alert('{message.Replace("'", "\\'")}');", true);
        }

        public async System.Threading.Tasks.Task<object> GetLanguageById(string languageId)
        {
            try
            {
                DocumentSnapshot languageDoc = await db.Collection("languages").Document(languageId).GetSnapshotAsync();

                if (languageDoc.Exists)
                {
                    var data = languageDoc.ToDictionary();
                    var stats = await GetLanguageStatistics(languageId);

                    return new
                    {
                        Id = languageDoc.Id,
                        Name = data.ContainsKey("Name") ? data["Name"].ToString() : "",
                        Code = data.ContainsKey("Code") ? data["Code"].ToString() : "",
                        Flag = data.ContainsKey("Flag") ? data["Flag"].ToString() : "🌍",
                        Description = data.ContainsKey("Description") ? data["Description"].ToString() : "",
                        CreatedDate = data.ContainsKey("CreatedAt") ? data["CreatedAt"] :
                                    data.ContainsKey("CreatedDate") ? data["CreatedDate"] :
                                    Timestamp.GetCurrentTimestamp(),
                        LessonCount = stats.LessonCount,
                        QuestionCount = stats.QuestionCount,
                        StudentCount = stats.StudentCount
                    };
                }

                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting language by ID: " + ex.Message);
                return null;
            }
        }

        public async System.Threading.Tasks.Task EnrollUserInLanguage(string userId, string languageId)
        {
            try
            {
                Query checkQuery = db.Collection("userLanguages")
                    .WhereEqualTo("UserId", userId)
                    .WhereEqualTo("LanguageId", languageId);
                QuerySnapshot checkSnapshot = await checkQuery.GetSnapshotAsync();

                if (checkSnapshot.Documents.Count == 0)
                {
                    await db.Collection("userLanguages").AddAsync(new
                    {
                        UserId = userId,
                        LanguageId = languageId,
                        EnrolledDate = Timestamp.GetCurrentTimestamp(),
                        Progress = 0,
                        CompletedLessons = new List<string>(),
                        LastAccessed = Timestamp.GetCurrentTimestamp()
                    });

                    System.Diagnostics.Debug.WriteLine($"User {userId} enrolled in language {languageId}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error enrolling user: " + ex.Message);
                throw;
            }
        }

        public async System.Threading.Tasks.Task<bool> IsUserEnrolledInLanguage(string userId, string languageId)
        {
            try
            {
                Query checkQuery = db.Collection("userLanguages")
                    .WhereEqualTo("UserId", userId)
                    .WhereEqualTo("LanguageId", languageId);
                QuerySnapshot checkSnapshot = await checkQuery.GetSnapshotAsync();

                return checkSnapshot.Documents.Count > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error checking user enrollment: " + ex.Message);
                return false;
            }
        }

        public async System.Threading.Tasks.Task<List<object>> GetUserLanguages(string userId)
        {
            try
            {
                Query userLanguagesQuery = db.Collection("userLanguages")
                    .WhereEqualTo("UserId", userId)
                    .OrderByDescending("EnrolledDate");
                QuerySnapshot userLanguagesSnapshot = await userLanguagesQuery.GetSnapshotAsync();

                var userLanguages = new List<object>();

                foreach (DocumentSnapshot userLangDoc in userLanguagesSnapshot.Documents)
                {
                    var userLangData = userLangDoc.ToDictionary();
                    string languageId = userLangData["LanguageId"].ToString();

                    var languageDetails = await GetLanguageById(languageId);
                    if (languageDetails != null)
                    {
                        userLanguages.Add(languageDetails);
                    }
                }

                return userLanguages;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting user languages: " + ex.Message);
                return new List<object>();
            }
        }

        public async System.Threading.Tasks.Task<List<object>> GetPopularLanguages(int topCount = 6)
        {
            try
            {
                Query languagesQuery = db.Collection("languages").OrderBy("Name");
                QuerySnapshot snapshot = await languagesQuery.GetSnapshotAsync();

                var languagesWithStats = new List<dynamic>();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var data = document.ToDictionary();
                    var stats = await GetLanguageStatistics(document.Id);

                    languagesWithStats.Add(new
                    {
                        Id = document.Id,
                        Name = data.ContainsKey("Name") ? data["Name"].ToString() : "",
                        Code = data.ContainsKey("Code") ? data["Code"].ToString() : "",
                        Flag = data.ContainsKey("Flag") ? data["Flag"].ToString() : "🌍",
                        Description = data.ContainsKey("Description") ? data["Description"].ToString() : "",
                        StudentCount = stats.StudentCount,
                        LessonCount = stats.LessonCount,
                        QuestionCount = stats.QuestionCount
                    });
                }

                var sortedLanguages = languagesWithStats
                    .OrderByDescending(l => l.StudentCount)
                    .Take(topCount)
                    .ToList();

                return sortedLanguages.Cast<object>().ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting popular languages: " + ex.Message);
                return new List<object>();
            }
        }
    }
}