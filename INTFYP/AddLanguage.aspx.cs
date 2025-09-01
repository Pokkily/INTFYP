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

        // Data Model
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
            public bool IsActive { get; set; }
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

        private async void LoadLanguages()
        {
            await LoadLanguagesAsync();
        }

        private async Task LoadLanguagesAsync()
        {
            try
            {
                var languages = await GetAllLanguages();

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

        private async Task<List<Language>> GetAllLanguages()
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
                    // Validate the input
                    if (string.IsNullOrWhiteSpace(txtEditName.Text))
                    {
                        ShowAlert("Please enter a language name.", "error");
                        return;
                    }

                    if (string.IsNullOrWhiteSpace(txtEditCode.Text))
                    {
                        ShowAlert("Please enter a language code.", "error");
                        return;
                    }

                    // Check if the new language code already exists (excluding current language)
                    string newCode = txtEditCode.Text.Trim().ToUpper();
                    if (await LanguageCodeExistsExcluding(newCode, languageId))
                    {
                        ShowAlert($"A language with code '{newCode}' already exists!", "error");
                        return;
                    }

                    // Update language in Firestore
                    DocumentReference languageRef = db.Collection("languages").Document(languageId);

                    await languageRef.UpdateAsync(new Dictionary<string, object>
                    {
                        { "Name", txtEditName.Text.Trim() },
                        { "Code", newCode },
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

        private async Task<bool> LanguageCodeExistsExcluding(string code, string excludeLanguageId)
        {
            try
            {
                Query query = db.Collection("languages")
                               .WhereEqualTo("Code", code)
                               .WhereEqualTo("IsActive", true);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                // Check if any document exists with this code that's not the current language
                return snapshot.Documents.Any(doc => doc.Id != excludeLanguageId);
            }
            catch
            {
                return false;
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

        private void ShowAlert(string message, string type)
        {
            pnlAlert.Visible = true;
            lblMessage.Text = message;

            string cssClass = type == "success" ? "alert-message" : "alert-message alert-danger";
            alertDiv.Attributes["class"] = cssClass;
        }



        public async Task<List<Language>> GetLanguagesByDifficulty(string difficulty)
        {
            try
            {
                var languages = new List<Language>();

                Query query = db.Collection("languages")
                               .WhereEqualTo("Difficulty", difficulty)
                               .WhereEqualTo("IsActive", true);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    if (document.Exists)
                    {
                        languages.Add(document.ConvertTo<Language>());
                    }
                }

                return languages.OrderBy(l => l.Name).ToList();
            }
            catch
            {
                return new List<Language>();
            }
        }

        public async Task<Language> GetLanguageById(string languageId)
        {
            try
            {
                DocumentReference languageRef = db.Collection("languages").Document(languageId);
                DocumentSnapshot languageDoc = await languageRef.GetSnapshotAsync();

                if (languageDoc.Exists)
                {
                    return languageDoc.ConvertTo<Language>();
                }

                return null;
            }
            catch
            {
                return null;
            }
        }

        public async Task<Language> GetLanguageByCode(string languageCode)
        {
            try
            {
                Query query = db.Collection("languages")
                               .WhereEqualTo("Code", languageCode.ToUpper())
                               .WhereEqualTo("IsActive", true)
                               .Limit(1);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                if (snapshot.Documents.Count > 0)
                {
                    return snapshot.Documents[0].ConvertTo<Language>();
                }

                return null;
            }
            catch
            {
                return null;
            }
        }

        public async Task<bool> UpdateLanguageDifficulty(string languageId, string difficulty)
        {
            try
            {
                DocumentReference languageRef = db.Collection("languages").Document(languageId);
                await languageRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "Difficulty", difficulty }
                });
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<int> GetTotalLanguageCount()
        {
            try
            {
                Query query = db.Collection("languages").WhereEqualTo("IsActive", true);
                QuerySnapshot snapshot = await query.GetSnapshotAsync();
                return snapshot.Documents.Count;
            }
            catch
            {
                return 0;
            }
        }

        public async Task<Dictionary<string, int>> GetLanguageStatistics()
        {
            try
            {
                var stats = new Dictionary<string, int>();

                // Get total active languages
                Query activeQuery = db.Collection("languages").WhereEqualTo("IsActive", true);
                QuerySnapshot activeSnapshot = await activeQuery.GetSnapshotAsync();
                stats["ActiveLanguages"] = activeSnapshot.Documents.Count;

                // Get total inactive languages
                Query inactiveQuery = db.Collection("languages").WhereEqualTo("IsActive", false);
                QuerySnapshot inactiveSnapshot = await inactiveQuery.GetSnapshotAsync();
                stats["InactiveLanguages"] = inactiveSnapshot.Documents.Count;

                // Get languages by difficulty
                var difficulties = new[] { "Beginner", "Intermediate", "Advanced", "Expert" };
                foreach (var difficulty in difficulties)
                {
                    Query difficultyQuery = db.Collection("languages")
                                             .WhereEqualTo("Difficulty", difficulty)
                                             .WhereEqualTo("IsActive", true);
                    QuerySnapshot difficultySnapshot = await difficultyQuery.GetSnapshotAsync();
                    stats[$"{difficulty}Languages"] = difficultySnapshot.Documents.Count;
                }

                return stats;
            }
            catch
            {
                return new Dictionary<string, int>();
            }
        }
    }
}