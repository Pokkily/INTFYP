using System;
using System.Configuration;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;
using System.Threading.Tasks;
using System.IO;

namespace INTFYP
{
    public partial class ScholarshipApp : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
            if (!IsPostBack)
            {
                await LoadApplications();
            }
        }

        private string GetCurrentUserId()
        {
            // Option 1: Get from Session (if you're storing user ID in session)
            if (Session["UserId"] != null)
            {
                return Session["UserId"].ToString();
            }

            // Option 2: Get from User Identity (if using ASP.NET authentication)
            if (User.Identity.IsAuthenticated)
            {
                return User.Identity.Name; // or User.Identity.GetUserId() if using Identity framework
            }

            // Option 3: Get from query string or form (for testing purposes)
            if (!string.IsNullOrEmpty(Request.QueryString["userId"]))
            {
                return Request.QueryString["userId"];
            }

            // Fallback: Generate a temporary session-based ID
            if (Session["TempUserId"] == null)
            {
                Session["TempUserId"] = Guid.NewGuid().ToString();
            }
            return Session["TempUserId"].ToString();
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

        protected async void btnSubmitApplication_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields
                if (!ValidateForm())
                {
                    return;
                }

                // Initialize URLs for document uploads
                string transcriptUrl = "";
                string recommendationUrl = "";
                string financialUrl = "";
                string additionalUrl = "";

                // Upload files to Cloudinary
                if (fileTranscript.HasFile)
                {
                    if (!IsValidFile(fileTranscript))
                    {
                        ShowError("Transcript must be a PDF or image file (JPG, JPEG, PNG, GIF).");
                        return;
                    }
                    transcriptUrl = await UploadFileToCloudinary(fileTranscript, "transcripts");
                }

                if (fileRecommendation.HasFile)
                {
                    if (!IsValidFile(fileRecommendation))
                    {
                        ShowError("Recommendation letter must be a PDF or image file (JPG, JPEG, PNG, GIF).");
                        return;
                    }
                    recommendationUrl = await UploadFileToCloudinary(fileRecommendation, "recommendations");
                }

                if (fileFinancial.HasFile)
                {
                    if (!IsValidFile(fileFinancial))
                    {
                        ShowError("Financial documents must be a PDF or image file (JPG, JPEG, PNG, GIF).");
                        return;
                    }
                    financialUrl = await UploadFileToCloudinary(fileFinancial, "financial");
                }

                if (fileAdditional.HasFile)
                {
                    if (!IsValidFile(fileAdditional))
                    {
                        ShowError("Additional documents must be a PDF or image file (JPG, JPEG, PNG, GIF).");
                        return;
                    }
                    additionalUrl = await UploadFileToCloudinary(fileAdditional, "additional");
                }

                // Parse dates
                DateTime? dateOfBirth = null;
                if (!string.IsNullOrEmpty(txtDateOfBirth.Text))
                {
                    if (DateTime.TryParse(txtDateOfBirth.Text, out DateTime dob))
                        dateOfBirth = dob;
                }

                DateTime? graduationDate = null;
                if (!string.IsNullOrEmpty(txtGraduationDate.Text))
                {
                    if (DateTime.TryParse(txtGraduationDate.Text, out DateTime grad))
                        graduationDate = grad;
                }

                // Create scholarship application object
                var applicationData = new Dictionary<string, object>
                {
                    // User Information
                    { "UserId", GetCurrentUserId() },
                    
                    // Personal Information
                    { "FullName", txtFullName.Text.Trim() },
                    { "Email", txtEmail.Text.Trim() },
                    { "Phone", txtPhone.Text.Trim() },

                    // Academic Information
                    { "Institution", txtInstitution.Text.Trim() },
                    { "FieldOfStudy", txtFieldOfStudy.Text.Trim() },
                    { "AcademicLevel", ddlAcademicLevel.SelectedValue },
                    { "CurrentResult", txtCurrentResult.Text.Trim() },

                    // Document URLs
                    { "TranscriptUrl", transcriptUrl },
                    { "RecommendationUrl", recommendationUrl },
                    { "FinancialUrl", financialUrl },
                    { "AdditionalUrl", additionalUrl },

                    // System Fields
                    { "Status", "Pending" },
                    { "CreatedAt", Timestamp.GetCurrentTimestamp() },
                    { "UpdatedAt", Timestamp.GetCurrentTimestamp() }
                };

                // Add optional date fields if they have values
                if (dateOfBirth.HasValue)
                {
                    applicationData["DateOfBirth"] = Timestamp.FromDateTime(dateOfBirth.Value.ToUniversalTime());
                }

                if (graduationDate.HasValue)
                {
                    applicationData["GraduationDate"] = Timestamp.FromDateTime(graduationDate.Value.ToUniversalTime());
                }

                // Save to Firestore
                DocumentReference addedDocRef = await db.Collection("scholarship_applications").AddAsync(applicationData);

                ShowSuccess($"✅ Scholarship application submitted successfully! (ID: {addedDocRef.Id})");

                // Clear form
                ClearForm();

                // Reload applications
                await LoadApplications();
            }
            catch (Exception ex)
            {
                ShowError("❌ Error submitting application: " + ex.Message);
            }
        }

        private bool ValidateForm()
        {
            // Check required dropdown selections
            if (string.IsNullOrEmpty(ddlAcademicLevel.SelectedValue))
            {
                ShowError("❌ Please select your academic level.");
                return false;
            }

            // Validate email format
            if (!IsValidEmail(txtEmail.Text.Trim()))
            {
                ShowError("❌ Please enter a valid email address.");
                return false;
            }

            return true;
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private bool IsValidFile(FileUpload fileUpload)
        {
            if (!fileUpload.HasFile) return false;

            string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
            string[] allowedExtensions = { ".pdf", ".jpg", ".jpeg", ".png", ".gif" };

            foreach (string ext in allowedExtensions)
            {
                if (fileExtension == ext)
                {
                    return true;
                }
            }
            return false;
        }

        private async Task<string> UploadFileToCloudinary(FileUpload fileUpload, string folder)
        {
            var account = new Account(
                ConfigurationManager.AppSettings["CloudinaryCloudName"],
                ConfigurationManager.AppSettings["CloudinaryApiKey"],
                ConfigurationManager.AppSettings["CloudinaryApiSecret"]
            );
            var cloudinary = new Cloudinary(account);

            using (var stream = fileUpload.PostedFile.InputStream)
            {
                string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();

                // Check if it's an image or PDF
                if (fileExtension == ".pdf")
                {
                    // Upload as raw file for PDF
                    var uploadParams = new RawUploadParams
                    {
                        File = new FileDescription(fileUpload.FileName, stream),
                        Folder = $"scholarship_applications/{folder}"
                    };
                    var uploadResult = await cloudinary.UploadAsync(uploadParams);
                    return uploadResult.SecureUrl?.ToString() ?? "";
                }
                else
                {
                    // Upload as image for image files
                    var uploadParams = new ImageUploadParams
                    {
                        File = new FileDescription(fileUpload.FileName, stream),
                        Folder = $"scholarship_applications/{folder}"
                    };
                    var uploadResult = await cloudinary.UploadAsync(uploadParams);
                    return uploadResult.SecureUrl?.ToString() ?? "";
                }
            }
        }

        private async Task LoadApplications()
        {
            try
            {
                string currentUserId = GetCurrentUserId();

                // Use simple query without OrderByDescending
                Query applicationsQuery = db.Collection("scholarship_applications")
                    .WhereEqualTo("UserId", currentUserId)
                    .Limit(50);

                QuerySnapshot snapshot = await applicationsQuery.GetSnapshotAsync();

                var applications = new List<dynamic>();
                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var data = document.ToDictionary();

                    // Convert Timestamp to DateTime for display
                    DateTime createdAt = DateTime.Now;
                    if (data.ContainsKey("CreatedAt") && data["CreatedAt"] is Timestamp timestamp)
                    {
                        createdAt = timestamp.ToDateTime();
                    }

                    applications.Add(new
                    {
                        Id = document.Id,
                        FullName = data.ContainsKey("FullName") ? data["FullName"].ToString() : "",
                        Email = data.ContainsKey("Email") ? data["Email"].ToString() : "",
                        Institution = data.ContainsKey("Institution") ? data["Institution"].ToString() : "",
                        FieldOfStudy = data.ContainsKey("FieldOfStudy") ? data["FieldOfStudy"].ToString() : "",
                        CurrentResult = data.ContainsKey("CurrentResult") ? data["CurrentResult"].ToString() : "",
                        Status = data.ContainsKey("Status") ? data["Status"].ToString() : "Pending",
                        CreatedAt = createdAt,

                        // NEW: Include document URLs for display
                        TranscriptUrl = data.ContainsKey("TranscriptUrl") ? data["TranscriptUrl"].ToString() : "",
                        RecommendationUrl = data.ContainsKey("RecommendationUrl") ? data["RecommendationUrl"].ToString() : "",
                        FinancialUrl = data.ContainsKey("FinancialUrl") ? data["FinancialUrl"].ToString() : "",
                        AdditionalUrl = data.ContainsKey("AdditionalUrl") ? data["AdditionalUrl"].ToString() : ""
                    });
                }

                // Sort manually instead of using LINQ OrderByDescending
                applications.Sort((x, y) => DateTime.Compare(y.CreatedAt, x.CreatedAt));

                rptApplications.DataSource = applications;
                rptApplications.DataBind();

                pnlNoApplications.Visible = applications.Count == 0;

                // REMOVED: No longer showing the count message
                // if (applications.Count > 0)
                // {
                //     lblApplicationStatus.ForeColor = System.Drawing.Color.Green;
                //     lblApplicationStatus.Text = $"Showing {applications.Count} application(s) for current user.";
                // }
            }
            catch (Exception ex)
            {
                // Only show error messages, not count messages
                Response.Write($"<script>console.error('Error loading applications: {ex.Message}');</script>");
            }
        }

        private void ShowSuccess(string message)
        {
            lblStatus.Text = message;
            lblStatus.ForeColor = System.Drawing.Color.Green;
            pnlStatus.Visible = true;
            pnlStatus.CssClass = "status-message";
        }

        private void ShowError(string message)
        {
            lblStatus.Text = message;
            lblStatus.ForeColor = System.Drawing.Color.Red;
            pnlStatus.Visible = true;
            pnlStatus.CssClass = "status-message error";
        }

        private void ClearForm()
        {
            // Personal Information
            txtFullName.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtDateOfBirth.Text = "";

            // Academic Information
            txtInstitution.Text = "";
            txtFieldOfStudy.Text = "";
            ddlAcademicLevel.SelectedIndex = 0;
            txtCurrentResult.Text = "";
            txtGraduationDate.Text = "";

            // File uploads can't be cleared programmatically for security reasons
            // They will be cleared automatically after postback
        }

        // Optional: Method to update application status (for admin use)
        public async Task UpdateApplicationStatus(string applicationId, string newStatus)
        {
            try
            {
                DocumentReference appRef = db.Collection("scholarship_applications").Document(applicationId);
                var updates = new Dictionary<string, object>
                {
                    { "Status", newStatus },
                    { "UpdatedAt", Timestamp.GetCurrentTimestamp() }
                };

                await appRef.UpdateAsync(updates);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating application status: {ex.Message}");
            }
        }

        // Optional: Method to get application by ID
        public async Task<Dictionary<string, object>> GetApplicationById(string applicationId)
        {
            try
            {
                DocumentReference appRef = db.Collection("scholarship_applications").Document(applicationId);
                DocumentSnapshot snapshot = await appRef.GetSnapshotAsync();

                if (snapshot.Exists)
                {
                    return snapshot.ToDictionary();
                }
                return null;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving application: {ex.Message}");
            }
        }

        // Optional: Method to delete application
        public async Task DeleteApplication(string applicationId)
        {
            try
            {
                DocumentReference appRef = db.Collection("scholarship_applications").Document(applicationId);
                await appRef.DeleteAsync();
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting application: {ex.Message}");
            }
        }

        // Optional: Method to get applications by status - Updated to remove OrderByDescending
        public async Task<List<Dictionary<string, object>>> GetApplicationsByStatus(string status)
        {
            try
            {
                Query statusQuery = db.Collection("scholarship_applications")
                    .WhereEqualTo("Status", status);

                QuerySnapshot snapshot = await statusQuery.GetSnapshotAsync();

                var applications = new List<Dictionary<string, object>>();
                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var data = document.ToDictionary();
                    data["Id"] = document.Id;
                    applications.Add(data);
                }

                // Sort manually by CreatedAt timestamp in descending order
                applications.Sort((x, y) =>
                {
                    DateTime dateX = DateTime.MinValue;
                    DateTime dateY = DateTime.MinValue;

                    if (x.ContainsKey("CreatedAt") && x["CreatedAt"] is Timestamp tsX)
                        dateX = tsX.ToDateTime();
                    if (y.ContainsKey("CreatedAt") && y["CreatedAt"] is Timestamp tsY)
                        dateY = tsY.ToDateTime();

                    return DateTime.Compare(dateY, dateX); // Descending order (newest first)
                });

                return applications;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving applications by status: {ex.Message}");
            }
        }

        // Optional: Method to search applications by name or email - Updated to remove OrderByDescending
        public async Task<List<Dictionary<string, object>>> SearchApplications(string searchTerm)
        {
            try
            {
                var allApplications = new List<Dictionary<string, object>>();

                // Simple query without OrderByDescending
                Query nameQuery = db.Collection("scholarship_applications");

                QuerySnapshot snapshot = await nameQuery.GetSnapshotAsync();

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var data = document.ToDictionary();
                    string fullName = data.ContainsKey("FullName") ? data["FullName"].ToString() : "";
                    string email = data.ContainsKey("Email") ? data["Email"].ToString() : "";

                    if (fullName.IndexOf(searchTerm, StringComparison.OrdinalIgnoreCase) >= 0 ||
                        email.IndexOf(searchTerm, StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        data["Id"] = document.Id;
                        allApplications.Add(data);
                    }
                }

                // Sort manually by CreatedAt timestamp
                allApplications.Sort((x, y) =>
                {
                    DateTime dateX = DateTime.MinValue;
                    DateTime dateY = DateTime.MinValue;

                    if (x.ContainsKey("CreatedAt") && x["CreatedAt"] is Timestamp tsX)
                        dateX = tsX.ToDateTime();
                    if (y.ContainsKey("CreatedAt") && y["CreatedAt"] is Timestamp tsY)
                        dateY = tsY.ToDateTime();

                    return DateTime.Compare(dateY, dateX); // Descending order
                });

                return allApplications;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error searching applications: {ex.Message}");
            }
        }
    }
}