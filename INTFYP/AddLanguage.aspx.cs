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
    public partial class AddLanguage : System.Web.UI.Page
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
            public string Status { get; set; } // Active, Completed, Dropped
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore();
                LoadLanguages();
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

        protected async void btnAddLanguage_Click(object sender, EventArgs e)
        {
            try
            {
                if (!ValidateLanguageInput())
                    return;

                var language = new Language
                {
                    Id = Guid.NewGuid().ToString(),
                    Name = txtLanguageName.Text.Trim(),
                    Code = txtLanguageCode.Text.Trim().ToUpper(),
                    Description = txtDescription.Text.Trim(),
                    Flag = txtFlag.Text.Trim(),
                    Difficulty = "Beginner", // Default value
                    CreatedDate = DateTime.UtcNow,
                    StudentCount = 0,
                    IsActive = true
                };

                // Check if language already exists
                if (await LanguageExists(language.Code))
                {
                    ShowAlert($"A language with code '{language.Code}' already exists!", "error");
                    return;
                }

                // Add to Firestore
                DocumentReference docRef = db.Collection("languages").Document(language.Id);
                await docRef.SetAsync(language);

                ShowAlert($"Language '{language.Name}' added successfully!", "success");
                ClearForm();
                await LoadLanguagesAsync();
            }
            catch (Exception ex)
            {
                ShowAlert($"Error adding language: {ex.Message}", "error");
            }
        }

        private bool ValidateLanguageInput()
        {
            if (string.IsNullOrWhiteSpace(txtLanguageName.Text))
            {
                ShowAlert("Please enter a language name.", "error");
                return false;
            }

            if (string.IsNullOrWhiteSpace(txtLanguageCode.Text))
            {
                ShowAlert("Please enter a language code.", "error");
                return false;
            }

            if (txtLanguageCode.Text.Trim().Length > 5)
            {
                ShowAlert("Language code should be 5 characters or less.", "error");
                return false;
            }

            if (string.IsNullOrWhiteSpace(txtFlag.Text))
            {
                ShowAlert("Please enter a flag emoji.", "error");
                return false;
            }

            return true;
        }

        private async Task<bool> LanguageExists(string code)
        {
            try
            {
                Query query = db.Collection("languages").WhereEqualTo("Code", code).WhereEqualTo("IsActive", true);
                QuerySnapshot snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Count > 0;
            }
            catch
            {
                return false;
            }
        }

        private void ClearForm()
        {
            txtLanguageName.Text = "";
            txtLanguageCode.Text = "";
            txtDescription.Text = "";
            txtFlag.Text = "";
        }

        protected async void btnRefreshLanguages_Click(object sender, EventArgs e)
        {
            await LoadLanguagesAsync();
        }

        private async void LoadLanguages()
        {
            await LoadLanguagesAsync();
        }

        private async Task LoadLanguagesAsync()
        {
            try
            {
                var languages = await GetAllLanguagesWithStudentCount();

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
                ShowAlert($"Error loading languages: {ex.Message}", "error");
            }
        }

        private async Task<List<Language>> GetAllLanguagesWithStudentCount()
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

                        // Get real-time student count for this language
                        language.StudentCount = await GetStudentCountForLanguage(language.Id);

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

        private async Task<int> GetStudentCountForLanguage(string languageId)
        {
            try
            {
                Query query = db.Collection("enrollments")
                               .WhereEqualTo("LanguageId", languageId)
                               .WhereEqualTo("Status", "Active");

                QuerySnapshot snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Count;
            }
            catch
            {
                return 0;
            }
        }

        protected async void rptLanguages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string languageId = e.CommandArgument.ToString();

            try
            {
                switch (e.CommandName)
                {
                    case "UpdateLanguage":
                        await UpdateLanguage(e, languageId);
                        break;

                    case "DeleteLanguage":
                        await DeleteLanguage(languageId);
                        break;

                    case "ViewStudents":
                        await ViewEnrolledStudents(languageId);
                        break;

                    case "JoinLanguage":
                        await EnrollStudentInLanguage(languageId);
                        break;
                }
            }
            catch (Exception ex)
            {
                ShowAlert($"Error processing command: {ex.Message}", "error");
            }
        }

        private async Task UpdateLanguage(RepeaterCommandEventArgs e, string languageId)
        {
            try
            {
                // Find the controls in the repeater item
                RepeaterItem item = (RepeaterItem)e.Item;
                TextBox txtEditName = (TextBox)item.FindControl("txtEditLanguageName");
                TextBox txtEditCode = (TextBox)item.FindControl("txtEditLanguageCode");
                TextBox txtEditFlag = (TextBox)item.FindControl("txtEditFlag");
                TextBox txtEditDesc = (TextBox)item.FindControl("txtEditDescription");

                if (txtEditName != null && txtEditCode != null)
                {
                    // Update language in Firestore
                    DocumentReference languageRef = db.Collection("languages").Document(languageId);

                    await languageRef.UpdateAsync(new Dictionary<string, object>
                    {
                        { "Name", txtEditName.Text.Trim() },
                        { "Code", txtEditCode.Text.Trim().ToUpper() },
                        { "Flag", txtEditFlag?.Text.Trim() ?? "" },
                        { "Description", txtEditDesc?.Text.Trim() ?? "" }
                    });

                    ShowAlert("Language course updated successfully!", "success");
                    await LoadLanguagesAsync();
                }
            }
            catch (Exception ex)
            {
                ShowAlert($"Error updating language: {ex.Message}", "error");
            }
        }

        private async Task DeleteLanguage(string languageId)
        {
            try
            {
                // First, get the language name for the success message
                DocumentReference languageRef = db.Collection("languages").Document(languageId);
                DocumentSnapshot languageDoc = await languageRef.GetSnapshotAsync();
                string languageName = languageDoc.Exists ? languageDoc.GetValue<string>("Name") : "Unknown";

                // Update all enrollments to inactive (soft delete)
                Query enrollmentQuery = db.Collection("enrollments")
                                         .WhereEqualTo("LanguageId", languageId);

                QuerySnapshot enrollmentSnapshot = await enrollmentQuery.GetSnapshotAsync();

                foreach (DocumentSnapshot doc in enrollmentSnapshot.Documents)
                {
                    await doc.Reference.UpdateAsync(new Dictionary<string, object>
                    {
                        { "Status", "Inactive" }
                    });
                }

                // Soft delete the language (mark as inactive instead of hard delete)
                await languageRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "IsActive", false }
                });

                ShowAlert($"Language course '{languageName}' deleted successfully!", "success");
                await LoadLanguagesAsync();
            }
            catch (Exception ex)
            {
                ShowAlert($"Error deleting language: {ex.Message}", "error");
            }
        }

        private async Task ViewEnrolledStudents(string languageId)
        {
            try
            {
                var enrollments = await GetEnrollmentsForLanguage(languageId);

                if (enrollments.Any())
                {
                    string studentList = string.Join(", ", enrollments.Select(e => e.StudentName));
                    ShowAlert($"Enrolled Students ({enrollments.Count}): {studentList}", "success");
                }
                else
                {
                    ShowAlert("No students currently enrolled in this course.", "error");
                }
            }
            catch (Exception ex)
            {
                ShowAlert($"Error retrieving student list: {ex.Message}", "error");
            }
        }

        private async Task EnrollStudentInLanguage(string languageId)
        {
            try
            {
                string studentId = GetCurrentStudentId();
                string studentName = GetCurrentStudentName();
                string studentEmail = GetCurrentStudentEmail();

                // Check if student is already enrolled
                if (await IsStudentEnrolled(studentId, languageId))
                {
                    ShowAlert("Student is already enrolled in this language course!", "error");
                    return;
                }

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

                // Add enrollment to Firestore
                DocumentReference docRef = db.Collection("enrollments").Document(enrollment.Id);
                await docRef.SetAsync(enrollment);

                // Update language student count
                await UpdateLanguageStudentCount(languageId);

                ShowAlert($"Student '{studentName}' successfully enrolled!", "success");
                await LoadLanguagesAsync(); // Refresh to show updated count
            }
            catch (Exception ex)
            {
                ShowAlert($"Error enrolling student: {ex.Message}", "error");
            }
        }

        private async Task<bool> IsStudentEnrolled(string studentId, string languageId)
        {
            try
            {
                Query query = db.Collection("enrollments")
                               .WhereEqualTo("StudentId", studentId)
                               .WhereEqualTo("LanguageId", languageId)
                               .WhereEqualTo("Status", "Active");

                QuerySnapshot snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Count > 0;
            }
            catch
            {
                return false;
            }
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
            catch (Exception ex)
            {
                // Log error but don't fail the main operation
                System.Diagnostics.Debug.WriteLine($"Error updating student count: {ex.Message}");
            }
        }

        public async Task<List<StudentEnrollment>> GetEnrollmentsForLanguage(string languageId)
        {
            var enrollments = new List<StudentEnrollment>();

            try
            {
                Query query = db.Collection("enrollments")
                               .WhereEqualTo("LanguageId", languageId)
                               .WhereEqualTo("Status", "Active");

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    if (document.Exists)
                    {
                        enrollments.Add(document.ConvertTo<StudentEnrollment>());
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting enrollments: {ex.Message}");
            }

            return enrollments;
        }

        // Teacher Management Methods

        public async Task<bool> UnenrollStudent(string studentId, string languageId)
        {
            try
            {
                Query query = db.Collection("enrollments")
                               .WhereEqualTo("StudentId", studentId)
                               .WhereEqualTo("LanguageId", languageId)
                               .WhereEqualTo("Status", "Active");

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    await document.Reference.UpdateAsync(new Dictionary<string, object>
                    {
                        { "Status", "Dropped" }
                    });
                }

                await UpdateLanguageStudentCount(languageId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<Dictionary<string, object>> GetLanguageStatistics(string languageId)
        {
            try
            {
                var stats = new Dictionary<string, object>();

                // Get total enrollments (all time)
                Query totalQuery = db.Collection("enrollments")
                                    .WhereEqualTo("LanguageId", languageId);
                QuerySnapshot totalSnapshot = await totalQuery.GetSnapshotAsync();
                stats["TotalEnrollments"] = totalSnapshot.Documents.Count;

                // Get active enrollments
                Query activeQuery = db.Collection("enrollments")
                                     .WhereEqualTo("LanguageId", languageId)
                                     .WhereEqualTo("Status", "Active");
                QuerySnapshot activeSnapshot = await activeQuery.GetSnapshotAsync();
                stats["ActiveEnrollments"] = activeSnapshot.Documents.Count;

                // Get completed enrollments
                Query completedQuery = db.Collection("enrollments")
                                        .WhereEqualTo("LanguageId", languageId)
                                        .WhereEqualTo("Status", "Completed");
                QuerySnapshot completedSnapshot = await completedQuery.GetSnapshotAsync();
                stats["CompletedEnrollments"] = completedSnapshot.Documents.Count;

                // Calculate completion rate
                int total = totalSnapshot.Documents.Count;
                int completed = completedSnapshot.Documents.Count;
                stats["CompletionRate"] = total > 0 ? (double)completed / total * 100 : 0;

                return stats;
            }
            catch
            {
                return new Dictionary<string, object>();
            }
        }

        // Helper methods for student information
        private string GetCurrentStudentId()
        {
            if (Session["StudentId"] != null)
                return Session["StudentId"].ToString();

            // Generate a demo student ID if none exists
            string demoStudentId = "DEMO_" + DateTime.Now.Ticks.ToString();
            Session["StudentId"] = demoStudentId;
            return demoStudentId;
        }

        private string GetCurrentStudentName()
        {
            if (Session["StudentName"] != null)
                return Session["StudentName"].ToString();

            // Demo student name
            string demoName = "Demo Student";
            Session["StudentName"] = demoName;
            return demoName;
        }

        private string GetCurrentStudentEmail()
        {
            if (Session["StudentEmail"] != null)
                return Session["StudentEmail"].ToString();

            // Demo email
            string demoEmail = "demo.student@example.com";
            Session["StudentEmail"] = demoEmail;
            return demoEmail;
        }

        private void ShowAlert(string message, string type)
        {
            pnlAlert.Visible = true;
            lblMessage.Text = message;

            string cssClass = type == "success" ? "alert alert-success" : "alert alert-danger";
            alertDiv.Attributes["class"] = cssClass;
        }

        // Additional Teacher Methods

        public async Task<bool> ActivateLanguage(string languageId)
        {
            try
            {
                DocumentReference languageRef = db.Collection("languages").Document(languageId);
                await languageRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "IsActive", true }
                });
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<bool> DeactivateLanguage(string languageId)
        {
            try
            {
                DocumentReference languageRef = db.Collection("languages").Document(languageId);
                await languageRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "IsActive", false }
                });
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<List<Language>> GetPopularLanguages(int limit = 5)
        {
            try
            {
                var languages = await GetAllLanguagesWithStudentCount();
                return languages.OrderByDescending(l => l.StudentCount).Take(limit).ToList();
            }
            catch
            {
                return new List<Language>();
            }
        }

        public async Task<Dictionary<string, int>> GetLanguageEnrollmentTrends(string languageId, int days = 30)
        {
            var trends = new Dictionary<string, int>();

            try
            {
                DateTime startDate = DateTime.UtcNow.AddDays(-days);

                Query query = db.Collection("enrollments")
                               .WhereEqualTo("LanguageId", languageId)
                               .WhereGreaterThan("EnrollmentDate", startDate);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    var enrollment = doc.ConvertTo<StudentEnrollment>();
                    string dateKey = enrollment.EnrollmentDate.ToString("yyyy-MM-dd");

                    if (trends.ContainsKey(dateKey))
                        trends[dateKey]++;
                    else
                        trends[dateKey] = 1;
                }
            }
            catch
            {
                // Return empty trends on error
            }

            return trends;
        }
    }
}