using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using SendGrid;
using SendGrid.Helpers.Mail;
using System.Threading;

namespace YourProjectNamespace
{
    public partial class AdminScholarship : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        // SendGrid configuration
        private static readonly string SendGridApiKey = GetConfigValue("SendGridApiKey");
        private static readonly string SendGridFromEmail = GetConfigValue("SendGridFromEmail");
        private static readonly string SendGridFromName = GetConfigValue("SendGridFromName");

        private static string GetConfigValue(string key)
        {
            string value = ConfigurationManager.AppSettings[key];
            if (string.IsNullOrEmpty(value))
            {
                value = Environment.GetEnvironmentVariable(key);
            }
            return value;
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // Check if user is admin (implement your admin authentication logic here)
                if (!IsAdminAuthenticated())
                {
                    Response.Redirect("Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                InitializeFirestore();

                if (!IsPostBack)
                {
                    await LoadApplications();
                    await LoadStatistics();
                }
            }
            catch (ThreadAbortException)
            {
                return;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Page_Load error: {ex.Message}");
                ShowErrorMessage("System error. Please try again later.");
            }
        }

        private bool IsAdminAuthenticated()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== Admin Authentication Check ===");

                foreach (string key in Session.Keys)
                {
                    System.Diagnostics.Debug.WriteLine($"Session[{key}] = {Session[key]}");
                }

                string userRole = Session["UserRole"]?.ToString() ?? Session["position"]?.ToString();
                bool isLoggedIn = false;

                if (Session["IsLoggedIn"] != null)
                {
                    isLoggedIn = (bool)Session["IsLoggedIn"];
                }
                else if (Session["isLoggedIn"] != null)
                {
                    isLoggedIn = (bool)Session["isLoggedIn"];
                }

                bool isAdmin = !string.IsNullOrEmpty(userRole) &&
                               userRole.Equals("Administrator", StringComparison.OrdinalIgnoreCase);

                return isLoggedIn && isAdmin;

                // For testing purposes, uncomment this line to bypass authentication
                // return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"IsAdminAuthenticated error: {ex.Message}");
                return false;
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
                            if (!System.IO.File.Exists(path))
                            {
                                string envPath = Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS");
                                if (!string.IsNullOrEmpty(envPath) && System.IO.File.Exists(envPath))
                                {
                                    path = envPath;
                                }
                                else
                                {
                                    throw new System.IO.FileNotFoundException($"Service account key not found at: {path}");
                                }
                            }

                            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                            db = FirestoreDb.Create("intorannetto");
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Firestore initialization failed: {ex.Message}");
                            throw;
                        }
                    }
                }
            }
        }

        private async Task LoadApplications()
        {
            try
            {
                var query = db.Collection("scholarship_applications");

                // Apply filters
                var searchTerm = txtSearch.Text.Trim().ToLower();
                var statusFilter = ddlStatusFilter.SelectedValue;
                var levelFilter = ddlLevelFilter.SelectedValue;

                var snapshot = await query.GetSnapshotAsync();
                var applications = new List<ScholarshipApplicationData>();

                foreach (var document in snapshot.Documents)
                {
                    var applicationData = ConvertToApplicationData(document);

                    // Apply search filter
                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        var searchableText = $"{applicationData.FullName} {applicationData.Email} {applicationData.Institution} {applicationData.FieldOfStudy}".ToLower();
                        if (!searchableText.Contains(searchTerm))
                            continue;
                    }

                    // Apply status filter
                    if (!string.IsNullOrEmpty(statusFilter) && applicationData.Status != statusFilter)
                        continue;

                    // Apply level filter
                    if (!string.IsNullOrEmpty(levelFilter) && applicationData.AcademicLevel != levelFilter)
                        continue;

                    applications.Add(applicationData);
                }

                // Sort by CreatedAt descending (newest first)
                applications = applications.OrderByDescending(a => a.CreatedAt).ToList();

                if (applications.Count > 0)
                {
                    rptApplications.DataSource = applications;
                    rptApplications.DataBind();
                    pnlNoApplications.Visible = false;
                }
                else
                {
                    rptApplications.DataSource = null;
                    rptApplications.DataBind();
                    pnlNoApplications.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadApplications error: {ex.Message}");
                ShowErrorMessage("Failed to load applications. Please try again.");
            }
        }

        private async Task LoadStatistics()
        {
            try
            {
                var snapshot = await db.Collection("scholarship_applications").GetSnapshotAsync();

                int pending = 0, approved = 0, rejected = 0, total = snapshot.Count;

                foreach (var document in snapshot.Documents)
                {
                    var status = document.ContainsField("Status") ? document.GetValue<string>("Status") : "Pending";
                    switch (status)
                    {
                        case "Pending":
                            pending++;
                            break;
                        case "Approved":
                            approved++;
                            break;
                        case "Rejected":
                            rejected++;
                            break;
                    }
                }

                lblPendingCount.Text = pending.ToString();
                lblApprovedCount.Text = approved.ToString();
                lblRejectedCount.Text = rejected.ToString();
                lblTotalCount.Text = total.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadStatistics error: {ex.Message}");
            }
        }

        private ScholarshipApplicationData ConvertToApplicationData(DocumentSnapshot document)
        {
            var data = document.ToDictionary();

            return new ScholarshipApplicationData
            {
                Id = document.Id,
                UserId = GetStringValue(data, "UserId"),
                FullName = GetStringValue(data, "FullName"),
                Email = GetStringValue(data, "Email"),
                Phone = GetStringValue(data, "Phone"),
                Institution = GetStringValue(data, "Institution"),
                FieldOfStudy = GetStringValue(data, "FieldOfStudy"),
                AcademicLevel = GetStringValue(data, "AcademicLevel"),
                CurrentResult = GetStringValue(data, "CurrentResult"),
                Status = GetStringValue(data, "Status", "Pending"),
                RejectionReason = GetStringValue(data, "RejectionReason"),
                TranscriptUrl = GetStringValue(data, "TranscriptUrl"),
                RecommendationUrl = GetStringValue(data, "RecommendationUrl"),
                FinancialUrl = GetStringValue(data, "FinancialUrl"),
                AdditionalUrl = GetStringValue(data, "AdditionalUrl"),
                CreatedAt = GetDateTimeValue(data, "CreatedAt"),
                UpdatedAt = GetDateTimeValue(data, "UpdatedAt"),
                DateOfBirth = GetNullableDateTimeValue(data, "DateOfBirth"),
                GraduationDate = GetNullableDateTimeValue(data, "GraduationDate")
            };
        }

        private string GetStringValue(Dictionary<string, object> data, string key, string defaultValue = "")
        {
            return data.ContainsKey(key) && data[key] != null ? data[key].ToString() : defaultValue;
        }

        private DateTime GetDateTimeValue(Dictionary<string, object> data, string key)
        {
            if (data.ContainsKey(key) && data[key] is Timestamp timestamp)
            {
                return timestamp.ToDateTime();
            }
            return DateTime.Now;
        }

        private DateTime? GetNullableDateTimeValue(Dictionary<string, object> data, string key)
        {
            if (data.ContainsKey(key) && data[key] is Timestamp timestamp)
            {
                return timestamp.ToDateTime();
            }
            return null;
        }

        public string GetStatusClass(string status)
        {
            switch (status?.ToLower())
            {
                case "approved":
                    return "approved";
                case "rejected":
                    return "rejected";
                case "pending":
                default:
                    return "pending";
            }
        }

        protected async void rptApplications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Approve")
                {
                    var applicationId = e.CommandArgument.ToString();
                    await ApproveApplication(applicationId);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ItemCommand error: {ex.Message}");
                ShowErrorMessage("Action failed. Please try again.");
            }
        }

        private async Task ApproveApplication(string applicationId)
        {
            try
            {
                // Get application data
                var applicationDoc = await db.Collection("scholarship_applications").Document(applicationId).GetSnapshotAsync();
                if (!applicationDoc.Exists)
                {
                    ShowErrorMessage("Application not found.");
                    return;
                }

                var applicationData = ConvertToApplicationData(applicationDoc);

                // Update application status
                var updates = new Dictionary<string, object>
                {
                    {"Status", "Approved"},
                    {"ApprovedAt", Timestamp.GetCurrentTimestamp()},
                    {"UpdatedAt", Timestamp.GetCurrentTimestamp()}
                };

                // Remove rejection reason if it exists
                if (applicationDoc.ContainsField("RejectionReason"))
                {
                    updates.Add("RejectionReason", FieldValue.Delete);
                }

                await db.Collection("scholarship_applications").Document(applicationId).UpdateAsync(updates);

                // Send approval email
                await SendApprovalEmail(applicationData);

                ShowSuccessMessage($"Scholarship application for {applicationData.FullName} has been approved successfully!");

                await LoadApplications();
                await LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ApproveApplication error: {ex.Message}");
                ShowErrorMessage($"Failed to approve application: {ex.Message}");
            }
        }

        protected async void btnConfirmReject_Click(object sender, EventArgs e)
        {
            try
            {
                var applicationId = hiddenApplicationIdToReject.Value;
                var rejectionReason = "";

                // Build rejection reason from dropdown and text
                if (!string.IsNullOrEmpty(ddlRejectionReason.SelectedValue))
                {
                    rejectionReason = ddlRejectionReason.SelectedValue;
                    if (!string.IsNullOrEmpty(txtRejectionReason.Text.Trim()))
                    {
                        rejectionReason += ": " + txtRejectionReason.Text.Trim();
                    }
                }
                else if (!string.IsNullOrEmpty(txtRejectionReason.Text.Trim()))
                {
                    rejectionReason = txtRejectionReason.Text.Trim();
                }

                if (string.IsNullOrEmpty(rejectionReason))
                {
                    ShowErrorMessage("Please provide a reason for rejection.");
                    return;
                }

                await RejectApplication(applicationId, rejectionReason);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Reject application error: {ex.Message}");
                ShowErrorMessage("Rejection failed. Please try again.");
            }
        }

        private async Task RejectApplication(string applicationId, string rejectionReason)
        {
            try
            {
                // Get application data
                var applicationDoc = await db.Collection("scholarship_applications").Document(applicationId).GetSnapshotAsync();
                if (!applicationDoc.Exists)
                {
                    ShowErrorMessage("Application not found.");
                    return;
                }

                var applicationData = ConvertToApplicationData(applicationDoc);

                // Update application status
                var updates = new Dictionary<string, object>
                {
                    {"Status", "Rejected"},
                    {"RejectionReason", rejectionReason},
                    {"RejectedAt", Timestamp.GetCurrentTimestamp()},
                    {"UpdatedAt", Timestamp.GetCurrentTimestamp()}
                };

                await db.Collection("scholarship_applications").Document(applicationId).UpdateAsync(updates);

                // Send rejection email
                await SendRejectionEmail(applicationData, rejectionReason);

                ShowSuccessMessage($"Scholarship application for {applicationData.FullName} has been rejected.");

                await LoadApplications();
                await LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RejectApplication error: {ex.Message}");
                ShowErrorMessage($"Failed to reject application: {ex.Message}");
            }
        }

        private async Task SendApprovalEmail(ScholarshipApplicationData applicationData)
        {
            try
            {
                if (string.IsNullOrEmpty(SendGridApiKey) || string.IsNullOrEmpty(SendGridFromEmail))
                {
                    System.Diagnostics.Debug.WriteLine("SendGrid configuration missing");
                    return;
                }

                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName ?? "Scholarship Admin");
                var to = new EmailAddress(applicationData.Email, applicationData.FullName);
                var subject = "🎉 Scholarship Application Approved!";

                var plainTextContent = $@"
Dear {applicationData.FullName},

Congratulations! We are delighted to inform you that your scholarship application has been approved.

Application Details:
- Institution: {applicationData.Institution}
- Field of Study: {applicationData.FieldOfStudy}
- Academic Level: {applicationData.AcademicLevel}

You will receive further instructions regarding the scholarship disbursement process within the next few business days.

If you have any questions, please don't hesitate to contact us.

Best regards,
The Scholarship Committee
                ";

                var htmlContent = CreateApprovalEmailTemplate(applicationData);
                var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
                var response = await client.SendEmailAsync(msg);

                if (!response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Body.ReadAsStringAsync();
                    throw new Exception($"SendGrid API error: {response.StatusCode} - {responseBody}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending approval email: {ex.Message}");
            }
        }

        private async Task SendRejectionEmail(ScholarshipApplicationData applicationData, string rejectionReason)
        {
            try
            {
                if (string.IsNullOrEmpty(SendGridApiKey) || string.IsNullOrEmpty(SendGridFromEmail))
                {
                    System.Diagnostics.Debug.WriteLine("SendGrid configuration missing");
                    return;
                }

                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName ?? "Scholarship Admin");
                var to = new EmailAddress(applicationData.Email, applicationData.FullName);
                var subject = "Scholarship Application Status Update";

                var plainTextContent = $@"
Dear {applicationData.FullName},

Thank you for your interest in our scholarship program. After careful review, we regret to inform you that your scholarship application has not been approved at this time.

Reason for rejection:
{rejectionReason}

We encourage you to address the concerns mentioned above and consider reapplying in future scholarship cycles.

If you have any questions or need clarification, please contact our support team.

Best regards,
The Scholarship Committee
                ";

                var htmlContent = CreateRejectionEmailTemplate(applicationData, rejectionReason);
                var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
                var response = await client.SendEmailAsync(msg);

                if (!response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Body.ReadAsStringAsync();
                    throw new Exception($"SendGrid API error: {response.StatusCode} - {responseBody}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending rejection email: {ex.Message}");
            }
        }

        private string CreateApprovalEmailTemplate(ScholarshipApplicationData applicationData)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Scholarship Application Approved</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .success-section {{ text-align: center; margin: 30px 0; }}
        .success-icon {{ font-size: 64px; color: #27ae60; margin-bottom: 20px; }}
        .application-info {{ 
            background-color: #f8f9fc; 
            border-left: 4px solid #27ae60; 
            padding: 20px; 
            margin: 25px 0; 
            border-radius: 0 8px 8px 0;
        }}
        .footer {{ 
            background-color: #f8f9fc; 
            padding: 20px; 
            text-align: center; 
            border-top: 1px solid #e3e6f0;
            font-size: 14px;
            color: #666;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🎓 Congratulations!</h1>
        </div>
        
        <div class='content'>
            <div class='success-section'>
                <div class='success-icon'>✅</div>
                <h2>Your Scholarship Application Has Been Approved!</h2>
                <p style='font-size: 18px; color: #666;'>Dear {applicationData.FullName},</p>
            </div>
            
            <p>We are delighted to inform you that your scholarship application has been approved by our review committee.</p>
            
            <div class='application-info'>
                <h3>🎯 Application Details:</h3>
                <p><strong>Institution:</strong> {applicationData.Institution}</p>
                <p><strong>Field of Study:</strong> {applicationData.FieldOfStudy}</p>
                <p><strong>Academic Level:</strong> {applicationData.AcademicLevel}</p>
                <p><strong>Current Result:</strong> {applicationData.CurrentResult}</p>
            </div>
            
            <p>You will receive further instructions regarding the scholarship disbursement process and next steps within the next few business days.</p>
            
            <p>Congratulations once again on this achievement!</p>
            
            <p>Best regards,<br><strong>The Scholarship Committee</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>© 2024 Scholarship Program. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string CreateRejectionEmailTemplate(ScholarshipApplicationData applicationData, string rejectionReason)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Scholarship Application Status</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .reason-box {{ 
            background-color: #f8d7da; 
            border: 1px solid #f5c6cb; 
            border-radius: 8px; 
            padding: 20px; 
            margin: 25px 0;
        }}
        .reason-box h3 {{ margin-top: 0; color: #721c24; }}
        .reason-text {{ 
            background-color: white; 
            padding: 15px; 
            border-radius: 6px; 
            border-left: 4px solid #e74c3c;
            font-style: italic;
        }}
        .footer {{ 
            background-color: #f8f9fc; 
            padding: 20px; 
            text-align: center; 
            border-top: 1px solid #e3e6f0;
            font-size: 14px;
            color: #666;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>📋 Application Status Update</h1>
        </div>
        
        <div class='content'>
            <h2>Dear {applicationData.FullName},</h2>
            
            <p>Thank you for your interest in our scholarship program. After careful review by our committee, we regret to inform you that your scholarship application has not been approved at this time.</p>
            
            <div class='reason-box'>
                <h3>📋 Reason for Decision:</h3>
                <div class='reason-text'>
                    {rejectionReason}
                </div>
            </div>
            
            <p>We encourage you to address the concerns mentioned above and consider reapplying in future scholarship cycles. Our team is available to provide guidance if you need clarification on the feedback.</p>
            
            <p>Thank you for your understanding and continued interest in our scholarship program.</p>
            
            <p>Best regards,<br><strong>The Scholarship Committee</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>For support inquiries, please contact our support team directly.</p>
            <p>© 2024 Scholarship Program. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        protected async void txtSearch_TextChanged(object sender, EventArgs e)
        {
            await LoadApplications();
        }

        protected async void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadApplications();
        }

        protected async void ddlLevelFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadApplications();
        }

        protected async void btnRefresh_Click(object sender, EventArgs e)
        {
            await LoadApplications();
            await LoadStatistics();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear session and redirect to login
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        private void ShowErrorMessage(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-danger";
            lblMessage.Visible = true;
        }

        private void ShowSuccessMessage(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;
        }
    }

    // Scholarship Application data model
    [Serializable]
    public class ScholarshipApplicationData
    {
        public string Id { get; set; }
        public string UserId { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Institution { get; set; }
        public string FieldOfStudy { get; set; }
        public string AcademicLevel { get; set; }
        public string CurrentResult { get; set; }
        public string Status { get; set; }
        public string RejectionReason { get; set; }
        public string TranscriptUrl { get; set; }
        public string RecommendationUrl { get; set; }
        public string FinancialUrl { get; set; }
        public string AdditionalUrl { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public DateTime? GraduationDate { get; set; }
    }
}