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
    public partial class Learning : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        // Data Models (same as teacher side)
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
        }

        [FirestoreData]
        public class StudentEnrollment
        {
            [FirestoreProperty]
            public string Id { get; set; }

            [FirestoreProperty]
            public string LanguageId { get; set; }

            [FirestoreProperty]
            public string StudentId { get; set; }

            [FirestoreProperty]
            public string StudentName { get; set; }

            [FirestoreProperty]
            public string StudentEmail { get; set; }

            [FirestoreProperty]
            public DateTime EnrollmentDate { get; set; }

            [FirestoreProperty]
            public string Status { get; set; }
        }

        // Store enrolled language IDs for quick checking
        private HashSet<string> enrolledLanguageIds = new HashSet<string>();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    InitializeFirestore();
                    await LoadLanguagesAsync();
                }
                catch (Exception ex)
                {
                    ShowAlert($"Error loading page: {ex.Message}", "error");
                    // Show empty state if there's an error
                    pnlNoLanguages.Visible = true;
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
                            // If Firebase fails, just log and continue with empty data
                            System.Diagnostics.Debug.WriteLine($"Firebase init error: {ex.Message}");
                            throw; // Let the caller handle this
                        }
                    }
                }
            }
        }

        private async Task LoadLanguagesAsync()
        {
            try
            {
                // First get student's enrolled languages for quick checking
                await LoadStudentEnrollments();

                // Then get all available languages
                var languages = await GetAllAvailableLanguages();

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
            }
            catch (Exception ex)
            {
                ShowAlert($"Error loading language courses: {ex.Message}", "error");
                pnlNoLanguages.Visible = true;
            }
        }

        private async Task LoadStudentEnrollments()
        {
            try
            {
                string studentId = GetCurrentStudentId();
                enrolledLanguageIds.Clear();

                Query query = db.Collection("enrollments")
                               .WhereEqualTo("StudentId", studentId)
                               .WhereEqualTo("Status", "Active");

                // Add timeout to prevent hanging
                var timeoutTask = Task.Delay(5000); // 5 second timeout
                var queryTask = query.GetSnapshotAsync();

                var completedTask = await Task.WhenAny(queryTask, timeoutTask);

                if (completedTask == timeoutTask)
                {
                    System.Diagnostics.Debug.WriteLine("Enrollment query timed out");
                    return;
                }

                QuerySnapshot snapshot = await queryTask;

                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    var enrollment = doc.ConvertTo<StudentEnrollment>();
                    enrolledLanguageIds.Add(enrollment.LanguageId);
                }
            }
            catch (Exception ex)
            {
                // Continue with empty enrollment list if error
                System.Diagnostics.Debug.WriteLine($"Error loading enrollments: {ex.Message}");
                enrolledLanguageIds.Clear();
            }
        }

        private async Task<List<Language>> GetAllAvailableLanguages()
        {
            var languages = new List<Language>();

            try
            {
                // Get all active languages with timeout
                CollectionReference languagesRef = db.Collection("languages");
                Query query = languagesRef.WhereEqualTo("IsActive", true);

                // Add timeout to prevent hanging
                var timeoutTask = Task.Delay(10000); // 10 second timeout
                var queryTask = query.GetSnapshotAsync();

                var completedTask = await Task.WhenAny(queryTask, timeoutTask);

                if (completedTask == timeoutTask)
                {
                    throw new TimeoutException("Database query timed out - please check your internet connection");
                }

                QuerySnapshot snapshot = await queryTask;

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    if (document.Exists)
                    {
                        var language = document.ConvertTo<Language>();

                        // Get student count quickly with timeout
                        language.StudentCount = await GetStudentCountForLanguage(language.Id);

                        languages.Add(language);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting languages: {ex.Message}");
                throw; // Let caller handle the error
            }

            return languages;
        }

        private async Task<int> GetStudentCountForLanguage(string languageId)
        {
            try
            {
                Query query = db.Collection("enrollments")
                               .WhereEqualTo("LanguageId", languageId)
                               .WhereEqualTo("Status", "Active");

                // Add timeout for count query
                var timeoutTask = Task.Delay(3000); // 3 second timeout
                var queryTask = query.GetSnapshotAsync();

                var completedTask = await Task.WhenAny(queryTask, timeoutTask);

                if (completedTask == timeoutTask)
                {
                    return 0; // Return 0 if timeout
                }

                QuerySnapshot snapshot = await queryTask;
                return snapshot.Documents.Count;
            }
            catch
            {
                return 0; // Return 0 if error
            }
        }

        protected async void rptLanguages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "JoinLanguage")
            {
                string languageId = e.CommandArgument.ToString();
                await JoinLanguageCourse(languageId);
            }
        }

        private async Task JoinLanguageCourse(string languageId)
        {
            try
            {
                string studentId = GetCurrentStudentId();
                string studentName = GetCurrentStudentName();
                string studentEmail = GetCurrentStudentEmail();

                // Quick check using our cached enrolled IDs
                if (enrolledLanguageIds.Contains(languageId))
                {
                    ShowAlert("You are already enrolled in this language course!", "error");
                    return;
                }

                // Get language name for success message
                string languageName = await GetLanguageName(languageId);

                // Create enrollment record
                var enrollment = new StudentEnrollment
                {
                    Id = Guid.NewGuid().ToString(),
                    LanguageId = languageId,
                    StudentId = studentId,
                    StudentName = studentName,
                    StudentEmail = studentEmail,
                    EnrollmentDate = DateTime.UtcNow,
                    Status = "Active"
                };

                // Add enrollment to Firebase with timeout
                DocumentReference docRef = db.Collection("enrollments").Document(enrollment.Id);

                var timeoutTask = Task.Delay(8000); // 8 second timeout
                var setTask = docRef.SetAsync(enrollment);

                var completedTask = await Task.WhenAny(setTask, timeoutTask);

                if (completedTask == timeoutTask)
                {
                    throw new TimeoutException("Enrollment request timed out");
                }

                await setTask;

                // Update cached enrollment
                enrolledLanguageIds.Add(languageId);

                // Update the language's student count (don't wait for this)
                _ = Task.Run(() => UpdateLanguageStudentCount(languageId));

                ShowAlert($"🎉 Successfully joined {languageName} course!", "success");

                // Refresh the page to show updated enrollment status
                await LoadLanguagesAsync();
            }
            catch (Exception ex)
            {
                ShowAlert($"Error joining course: {ex.Message}", "error");
            }
        }

        private async Task<string> GetLanguageName(string languageId)
        {
            try
            {
                DocumentReference languageRef = db.Collection("languages").Document(languageId);

                var timeoutTask = Task.Delay(3000);
                var getTask = languageRef.GetSnapshotAsync();

                var completedTask = await Task.WhenAny(getTask, timeoutTask);

                if (completedTask == timeoutTask)
                {
                    return "this language";
                }

                DocumentSnapshot snapshot = await getTask;

                if (snapshot.Exists)
                {
                    return snapshot.GetValue<string>("Name");
                }
            }
            catch
            {
                // Ignore error
            }

            return "this language";
        }

        private async Task UpdateLanguageStudentCount(string languageId)
        {
            try
            {
                int count = await GetStudentCountForLanguage(languageId);
                DocumentReference languageRef = db.Collection("languages").Document(languageId);

                await languageRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "StudentCount", count }
                });
            }
            catch
            {
                // Ignore errors for count updates
            }
        }

        // Helper method to check if student is enrolled (for UI binding)
        protected bool IsStudentEnrolled(string languageId)
        {
            // Use cached enrollment data instead of async call
            return enrolledLanguageIds.Contains(languageId);
        }

        // Student session management (simplified)
        private string GetCurrentStudentId()
        {
            if (Session["StudentId"] != null)
                return Session["StudentId"].ToString();

            // Generate a simple student ID
            string studentId = "STUDENT_" + Session.SessionID;
            Session["StudentId"] = studentId;
            return studentId;
        }

        private string GetCurrentStudentName()
        {
            if (Session["StudentName"] != null)
                return Session["StudentName"].ToString();

            string demoName = "Language Learner";
            Session["StudentName"] = demoName;
            return demoName;
        }

        private string GetCurrentStudentEmail()
        {
            if (Session["StudentEmail"] != null)
                return Session["StudentEmail"].ToString();

            string demoEmail = "learner@example.com";
            Session["StudentEmail"] = demoEmail;
            return demoEmail;
        }

        private void ShowAlert(string message, string type)
        {
            pnlAlert.Visible = true;
            lblMessage.Text = message;

            string cssClass = type == "success" ? "alert-success-glass" : "alert-danger-glass";
            alertDiv.Attributes["class"] = $"alert-glass {cssClass}";
        }
    }
}