using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class Learning : System.Web.UI.Page
    {
        private static FirestoreDb db;

        // Use same session approach as Library
        public string CurrentUserId => Session["userId"]?.ToString();

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitFirestore();

            if (!IsPostBack)
            {
                await LoadLanguages();
            }
        }

        private void InitFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadLanguages()
        {
            try
            {
                // Generate userId if not exists (like Library)
                if (string.IsNullOrEmpty(CurrentUserId))
                {
                    Session["userId"] = "user_" + Guid.NewGuid().ToString("N").Substring(0, 8);
                }

                System.Diagnostics.Debug.WriteLine("Session userId: " + Session["userId"]);

                QuerySnapshot snapshot = await db.Collection("languages").GetSnapshotAsync();
                List<LanguageClass> languageList = new List<LanguageClass>();

                foreach (var doc in snapshot.Documents)
                {
                    var language = doc.ConvertTo<LanguageClass>();
                    language.DocumentId = doc.Id;

                    // Check if current user is enrolled by looking at enrollments collection
                    language.IsEnrolled = await CheckUserEnrollment(doc.Id);

                    languageList.Add(language);
                }

                // Show languages ordered by name
                languageList = languageList.OrderBy(l => l.Name).ToList();

                if (languageList.Count == 0)
                {
                    pnlNoLanguages.Visible = true;
                    rptLanguages.DataSource = null;
                }
                else
                {
                    pnlNoLanguages.Visible = false;
                    rptLanguages.DataSource = languageList;
                }

                rptLanguages.DataBind();
            }
            catch (Exception ex)
            {
                ShowAlert($"Error loading languages: {ex.Message}", "error");
                pnlNoLanguages.Visible = true;
            }
        }

        // Check if current user is enrolled in a specific language
        private async Task<bool> CheckUserEnrollment(string languageId)
        {
            try
            {
                if (string.IsNullOrEmpty(CurrentUserId)) return false;

                // Query the enrollments subcollection under the specific language
                Query query = db.Collection("languages")
                    .Document(languageId)
                    .Collection("enrollments")
                    .WhereEqualTo("UserId", CurrentUserId)
                    .WhereEqualTo("Status", "Active");

                QuerySnapshot snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Count > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error checking enrollment: {ex.Message}");
                return false;
            }
        }

        // Search functionality like Library
        protected async void txtLanguageSearch_TextChanged(object sender, EventArgs e)
        {
            string keyword = ((TextBox)sender).Text.ToLower().Trim();

            try
            {
                QuerySnapshot snapshot = await db.Collection("languages").GetSnapshotAsync();
                List<LanguageClass> results = new List<LanguageClass>();

                if (string.IsNullOrEmpty(keyword))
                {
                    // If search is empty, load all languages
                    await LoadLanguages();
                    return;
                }

                foreach (var doc in snapshot.Documents)
                {
                    var language = doc.ConvertTo<LanguageClass>();
                    language.DocumentId = doc.Id;

                    // Check enrollment status
                    language.IsEnrolled = await CheckUserEnrollment(doc.Id);

                    // Search across name, code, and description
                    bool matchesSearch =
                        (language.Name?.ToLower().Contains(keyword) ?? false) ||
                        (language.Code?.ToLower().Contains(keyword) ?? false) ||
                        (language.Description?.ToLower().Contains(keyword) ?? false);

                    if (matchesSearch)
                    {
                        results.Add(language);
                    }
                }

                // Order by name
                results = results.OrderBy(l => l.Name).ToList();

                if (results.Count == 0)
                {
                    pnlNoLanguages.Visible = true;
                    rptLanguages.DataSource = null;
                }
                else
                {
                    pnlNoLanguages.Visible = false;
                    rptLanguages.DataSource = results;
                }

                rptLanguages.DataBind();
            }
            catch (Exception ex)
            {
                ShowAlert($"Error searching languages: {ex.Message}", "error");
            }
        }

        protected async void rptLanguages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("Session userId: " + Session["userId"]);

            if (string.IsNullOrEmpty(CurrentUserId)) return;

            string languageId = e.CommandArgument.ToString();

            try
            {
                if (e.CommandName == "JoinClass")
                {
                    await JoinLanguageClass(languageId);
                }
                else if (e.CommandName == "QuitClass")
                {
                    await QuitLanguageClass(languageId);
                }
                else if (e.CommandName == "StartLearning")
                {
                    await StartLearning(languageId);
                }

                // Reload languages to show updated state
                await LoadLanguages();
            }
            catch (Exception ex)
            {
                ShowAlert($"Error: {ex.Message}", "error");
                System.Diagnostics.Debug.WriteLine($"Error in ItemCommand: {ex}");
            }
        }

        private async Task JoinLanguageClass(string languageId)
        {
            try
            {
                // Check if already enrolled
                bool isEnrolled = await CheckUserEnrollment(languageId);
                if (isEnrolled)
                {
                    ShowAlert("You are already enrolled in this class!", "error");
                    return;
                }

                // Get language name for message
                string languageName = await GetLanguageName(languageId);

                // Create enrollment record in the language's enrollments subcollection
                var enrollment = new Enrollment
                {
                    UserId = CurrentUserId,
                    JoinedDate = Timestamp.GetCurrentTimestamp(),
                    Status = "Active"
                };

                // Add to enrollments subcollection under the specific language
                await db.Collection("languages")
                    .Document(languageId)
                    .Collection("enrollments")
                    .AddAsync(enrollment);

                ShowAlert($"Successfully joined {languageName} class! 🎉", "success");
            }
            catch (Exception ex)
            {
                ShowAlert($"Error joining class: {ex.Message}", "error");
                System.Diagnostics.Debug.WriteLine($"Error joining class: {ex}");
            }
        }

        private async Task QuitLanguageClass(string languageId)
        {
            try
            {
                // Find active enrollment in the language's enrollments subcollection
                Query query = db.Collection("languages")
                    .Document(languageId)
                    .Collection("enrollments")
                    .WhereEqualTo("UserId", CurrentUserId)
                    .WhereEqualTo("Status", "Active");

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                if (snapshot.Documents.Count == 0)
                {
                    ShowAlert("You are not enrolled in this class.", "error");
                    return;
                }

                // Get language name for message
                string languageName = await GetLanguageName(languageId);

                // Update enrollment status to quit
                DocumentSnapshot enrollmentDoc = snapshot.Documents.First();
                await enrollmentDoc.Reference.UpdateAsync(new Dictionary<string, object>
                {
                    { "Status", "Quit" },
                    { "QuitDate", Timestamp.GetCurrentTimestamp() }
                });

                ShowAlert($"You have quit the {languageName} class. You can rejoin anytime!", "success");
            }
            catch (Exception ex)
            {
                ShowAlert($"Error quitting class: {ex.Message}", "error");
                System.Diagnostics.Debug.WriteLine($"Error quitting class: {ex}");
            }
        }

        private async Task StartLearning(string languageId)
        {
            try
            {
                // Check if user is enrolled
                bool isEnrolled = await CheckUserEnrollment(languageId);
                if (!isEnrolled)
                {
                    ShowAlert("Please join the class first before starting to learn!", "error");
                    return;
                }

                // Get language name for message
                string languageName = await GetLanguageName(languageId);

                // Update last access date
                await UpdateLastAccessDate(languageId);

                ShowAlert($"Starting {languageName} learning session! 📚", "success");

                // TODO: Redirect to learning page
                // Response.Redirect($"~/LearningSession.aspx?languageId={languageId}");
            }
            catch (Exception ex)
            {
                ShowAlert($"Error starting learning session: {ex.Message}", "error");
            }
        }

        private async Task UpdateLastAccessDate(string languageId)
        {
            try
            {
                // Find active enrollment in the language's enrollments subcollection
                Query query = db.Collection("languages")
                    .Document(languageId)
                    .Collection("enrollments")
                    .WhereEqualTo("UserId", CurrentUserId)
                    .WhereEqualTo("Status", "Active");

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                if (snapshot.Documents.Count > 0)
                {
                    DocumentSnapshot enrollmentDoc = snapshot.Documents.First();
                    await enrollmentDoc.Reference.UpdateAsync(new Dictionary<string, object>
                    {
                        { "LastAccessDate", Timestamp.GetCurrentTimestamp() }
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating last access date: {ex.Message}");
            }
        }

        private async Task<string> GetLanguageName(string languageId)
        {
            try
            {
                DocumentReference languageRef = db.Collection("languages").Document(languageId);
                DocumentSnapshot snapshot = await languageRef.GetSnapshotAsync();

                if (snapshot.Exists && snapshot.ContainsField("Name"))
                {
                    return snapshot.GetValue<string>("Name");
                }
                return "this language";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting language name: {ex.Message}");
                return "this language";
            }
        }

        protected void rptLanguages_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var language = (LanguageClass)e.Item.DataItem;

                // Find the panels
                Panel pnlJoinButton = (Panel)e.Item.FindControl("pnlJoinButton");
                Panel pnlEnrolledActions = (Panel)e.Item.FindControl("pnlEnrolledActions");

                // Show appropriate panel based on enrollment status
                if (language.IsEnrolled)
                {
                    pnlJoinButton.Visible = false;
                    pnlEnrolledActions.Visible = true;
                }
                else
                {
                    pnlJoinButton.Visible = true;
                    pnlEnrolledActions.Visible = false;
                }

                System.Diagnostics.Debug.WriteLine($"Language {language.Name}: IsEnrolled = {language.IsEnrolled}");
            }
        }

        private void ShowAlert(string message, string type)
        {
            lblMessage.Text = message;
            pnlAlert.Visible = true;

            if (type == "success")
            {
                alertDiv.Attributes["class"] = "alert-glass alert-success-glass";
            }
            else
            {
                alertDiv.Attributes["class"] = "alert-glass alert-danger-glass";
            }
        }

        [FirestoreData]
        public class LanguageClass
        {
            [FirestoreProperty] public string Name { get; set; }
            [FirestoreProperty] public string Code { get; set; }
            [FirestoreProperty] public string Description { get; set; }
            [FirestoreProperty] public string Flag { get; set; }
            [FirestoreProperty] public string Difficulty { get; set; }
            [FirestoreProperty] public Timestamp CreatedDate { get; set; }
            [FirestoreProperty] public bool IsActive { get; set; }

            public string DocumentId { get; set; }
            public bool IsEnrolled { get; set; }
        }

        [FirestoreData]
        public class Enrollment
        {
            [FirestoreProperty] public string UserId { get; set; }
            [FirestoreProperty] public Timestamp JoinedDate { get; set; }
            [FirestoreProperty] public Timestamp LastAccessDate { get; set; }
            [FirestoreProperty] public Timestamp QuitDate { get; set; }
            [FirestoreProperty] public string Status { get; set; }
        }
    }
}