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
    public partial class Admin : System.Web.UI.Page
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
                    // Use false parameter to prevent ThreadAbortException
                    Response.Redirect("Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest(); // Complete the request cleanly
                    return;
                }

                InitializeFirestore();

                if (!IsPostBack)
                {
                    await LoadUsers();
                    await LoadStatistics();
                }
            }
            catch (ThreadAbortException)
            {
                // ThreadAbortException is normal for Response.Redirect
                // Don't log or show error message for this
                // Don't re-throw - just let it complete
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

                // Debug: Log all session variables
                foreach (string key in Session.Keys)
                {
                    System.Diagnostics.Debug.WriteLine($"Session[{key}] = {Session[key]}");
                }

                // Check multiple possible session variable names for flexibility
                string userRole = Session["UserRole"]?.ToString() ?? Session["position"]?.ToString();
                bool isLoggedIn = false;

                // Check both possible login status variables
                if (Session["IsLoggedIn"] != null)
                {
                    isLoggedIn = (bool)Session["IsLoggedIn"];
                }
                else if (Session["isLoggedIn"] != null)
                {
                    isLoggedIn = (bool)Session["isLoggedIn"];
                }

                System.Diagnostics.Debug.WriteLine($"UserRole/Position: '{userRole}'");
                System.Diagnostics.Debug.WriteLine($"IsLoggedIn: {isLoggedIn}");

                // Check if user has admin role (case-insensitive)
                bool isAdmin = !string.IsNullOrEmpty(userRole) &&
                               userRole.Equals("Administrator", StringComparison.OrdinalIgnoreCase);

                System.Diagnostics.Debug.WriteLine($"IsAdmin: {isAdmin}");
                System.Diagnostics.Debug.WriteLine($"Final Authentication Result: {isLoggedIn && isAdmin}");

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

        private async Task LoadUsers()
        {
            try
            {
                var query = db.Collection("users").OrderByDescending("createdAt");

                // Apply filters
                var searchTerm = txtSearch.Text.Trim().ToLower();
                var statusFilter = ddlStatusFilter.SelectedValue;
                var positionFilter = ddlPositionFilter.SelectedValue;

                var snapshot = await query.GetSnapshotAsync();
                var users = new List<UserData>();

                foreach (var document in snapshot.Documents)
                {
                    var userData = ConvertToUserData(document);

                    // Apply search filter
                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        var searchableText = $"{userData.FirstName} {userData.LastName} {userData.Email} {userData.Username}".ToLower();
                        if (!searchableText.Contains(searchTerm))
                            continue;
                    }

                    // Apply status filter
                    if (!string.IsNullOrEmpty(statusFilter) && userData.Status != statusFilter)
                        continue;

                    // Apply position filter
                    if (!string.IsNullOrEmpty(positionFilter) && userData.Position != positionFilter)
                        continue;

                    users.Add(userData);
                }

                if (users.Count > 0)
                {
                    rptUsers.DataSource = users;
                    rptUsers.DataBind();
                    pnlNoUsers.Visible = false;
                }
                else
                {
                    rptUsers.DataSource = null;
                    rptUsers.DataBind();
                    pnlNoUsers.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUsers error: {ex.Message}");
                ShowErrorMessage("Failed to load users. Please try again.");
            }
        }

        private async Task LoadStatistics()
        {
            try
            {
                var snapshot = await db.Collection("users").GetSnapshotAsync();

                int pending = 0, approved = 0, rejected = 0, total = snapshot.Count;

                foreach (var document in snapshot.Documents)
                {
                    var status = document.ContainsField("status") ? document.GetValue<string>("status") : "pending";
                    switch (status)
                    {
                        case "pending":
                            pending++;
                            break;
                        case "approved":
                            approved++;
                            break;
                        case "rejected":
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

        private UserData ConvertToUserData(DocumentSnapshot document)
        {
            return new UserData
            {
                Uid = document.Id,
                FirstName = document.GetValue<string>("firstName"),
                LastName = document.GetValue<string>("lastName"),
                Username = document.GetValue<string>("username"),
                Email = document.GetValue<string>("email"),
                Phone = document.ContainsField("phone") ? document.GetValue<string>("phone") : null,
                Gender = document.GetValue<string>("gender"),
                Position = document.GetValue<string>("position"),
                Birthdate = document.ContainsField("birthdate") ? document.GetValue<string>("birthdate") : null,
                Address = document.ContainsField("address") ? document.GetValue<string>("address") : null,
                Status = document.ContainsField("status") ? document.GetValue<string>("status") : "pending",
                RejectionReason = document.ContainsField("rejectionReason") ? document.GetValue<string>("rejectionReason") : null,
                CreatedAt = document.GetValue<Timestamp>("createdAt").ToDateTime(),
                LastUpdated = document.GetValue<Timestamp>("lastUpdated").ToDateTime()
            };
        }

        public string GetStatusClass(string status)
        {
            switch (status?.ToLower())
            {
                case "approved":
                    return "approved";
                case "rejected":
                    return "rejected";
                default:
                    return "";
            }
        }

        protected async void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Approve")
                {
                    var userId = e.CommandArgument.ToString();
                    await ApproveUser(userId);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ItemCommand error: {ex.Message}");
                ShowErrorMessage("Action failed. Please try again.");
            }
        }

        private async Task ApproveUser(string userId)
        {
            try
            {
                // Get user data
                var userDoc = await db.Collection("users").Document(userId).GetSnapshotAsync();
                if (!userDoc.Exists)
                {
                    ShowErrorMessage("User not found.");
                    return;
                }

                var userData = ConvertToUserData(userDoc);

                // Update user status
                var updates = new Dictionary<string, object>
                {
                    {"status", "approved"},
                    {"isActive", true}, // Activate the user account
                    {"approvedAt", Timestamp.GetCurrentTimestamp()},
                    {"lastUpdated", Timestamp.GetCurrentTimestamp()}
                };

                // Remove rejection reason if it exists
                if (userDoc.ContainsField("rejectionReason"))
                {
                    updates.Add("rejectionReason", FieldValue.Delete);
                }

                await db.Collection("users").Document(userId).UpdateAsync(updates);

                // Send approval email
                await SendApprovalEmail(userData);

                ShowSuccessMessage($"User {userData.FirstName} {userData.LastName} has been approved successfully!");

                await LoadUsers();
                await LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ApproveUser error: {ex.Message}");
                ShowErrorMessage($"Failed to approve user: {ex.Message}");
            }
        }

        protected async void btnConfirmReject_Click(object sender, EventArgs e)
        {
            try
            {
                var userId = hiddenUserIdToReject.Value;
                var rejectionReason = txtRejectionReason.Text.Trim();

                if (string.IsNullOrEmpty(rejectionReason))
                {
                    ShowErrorMessage("Please provide a reason for rejection.");
                    return;
                }

                await RejectUser(userId, rejectionReason);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Reject user error: {ex.Message}");
                ShowErrorMessage("Rejection failed. Please try again.");
            }
        }

        private async Task RejectUser(string userId, string rejectionReason)
        {
            try
            {
                // Get user data
                var userDoc = await db.Collection("users").Document(userId).GetSnapshotAsync();
                if (!userDoc.Exists)
                {
                    ShowErrorMessage("User not found.");
                    return;
                }

                var userData = ConvertToUserData(userDoc);

                // Update user status
                var updates = new Dictionary<string, object>
                {
                    {"status", "rejected"},
                    {"rejectionReason", rejectionReason},
                    {"isActive", false}, // Ensure account remains inactive
                    {"rejectedAt", Timestamp.GetCurrentTimestamp()},
                    {"lastUpdated", Timestamp.GetCurrentTimestamp()}
                };

                await db.Collection("users").Document(userId).UpdateAsync(updates);

                // Send rejection email
                await SendRejectionEmail(userData, rejectionReason);

                ShowSuccessMessage($"User {userData.FirstName} {userData.LastName} has been rejected.");

                await LoadUsers();
                await LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RejectUser error: {ex.Message}");
                ShowErrorMessage($"Failed to reject user: {ex.Message}");
            }
        }

        private async Task SendApprovalEmail(UserData userData)
        {
            try
            {
                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName);
                var to = new EmailAddress(userData.Email, $"{userData.FirstName} {userData.LastName}");
                var subject = "🎉 Registration Approved - Welcome!";

                var plainTextContent = $@"
Hello {userData.FirstName}!

Great news! Your registration has been approved by our administrators.

You can now log in to your account using your email and password.

Login Details:
- Email: {userData.Email}
- Username: {userData.Username}

Welcome to our platform! We're excited to have you as part of our community.

If you have any questions, please don't hesitate to contact our support team.

Best regards,
The Admin Team
                ";

                var htmlContent = CreateApprovalEmailTemplate(userData);

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
                throw;
            }
        }

        private async Task SendRejectionEmail(UserData userData, string rejectionReason)
        {
            try
            {
                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName);
                var to = new EmailAddress(userData.Email, $"{userData.FirstName} {userData.LastName}");
                var subject = "Registration Status Update";

                var plainTextContent = $@"
Hello {userData.FirstName}!

Thank you for your interest in joining our platform. After careful review, we regret to inform you that your registration application has not been approved at this time.

Reason for rejection:
{rejectionReason}

If you believe this decision was made in error or if you have addressed the concerns mentioned above, you are welcome to submit a new registration application.

For any questions or clarification, please contact our support team.

Thank you for your understanding.

Best regards,
The Admin Team
                ";

                var htmlContent = CreateRejectionEmailTemplate(userData, rejectionReason);

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
                throw;
            }
        }

        private string CreateApprovalEmailTemplate(UserData userData)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Registration Approved</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background: linear-gradient(135deg, #1cc88a 0%, #17a673 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .welcome-section {{ text-align: center; margin: 30px 0; }}
        .success-icon {{ font-size: 64px; color: #1cc88a; margin-bottom: 20px; }}
        .login-info {{ 
            background-color: #f8f9fc; 
            border-left: 4px solid #1cc88a; 
            padding: 20px; 
            margin: 25px 0; 
            border-radius: 0 8px 8px 0;
        }}
        .login-info h3 {{ margin-top: 0; color: #1cc88a; }}
        .credentials {{ 
            background-color: #e3f2fd; 
            border-radius: 8px; 
            padding: 15px; 
            margin: 15px 0;
            font-family: 'Courier New', monospace;
        }}
        .cta-button {{ 
            display: inline-block; 
            background-color: #1cc88a; 
            color: white; 
            padding: 15px 30px; 
            text-decoration: none; 
            border-radius: 8px; 
            font-weight: bold;
            margin: 20px 0;
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
            <h1>🎉 Welcome Aboard!</h1>
        </div>
        
        <div class='content'>
            <div class='welcome-section'>
                <div class='success-icon'>✅</div>
                <h2>Congratulations, {userData.FirstName}!</h2>
                <p style='font-size: 18px; color: #666;'>Your registration has been approved by our administrators.</p>
            </div>
            
            <p>We're excited to welcome you to our platform! You can now access all the features and services available to registered users.</p>
            
            <div class='login-info'>
                <h3>🔐 Your Login Information:</h3>
                <div class='credentials'>
                    <strong>Email:</strong> {userData.Email}<br>
                    <strong>Username:</strong> {userData.Username}
                </div>
                <p><strong>Note:</strong> Use the password you created during registration.</p>
            </div>
            
            <div style='text-align: center;'>
                <a href='#' class='cta-button'>Login to Your Account</a>
            </div>
            
            <div style='background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 15px; margin: 20px 0;'>
                <strong>🚀 What's Next?</strong>
                <ul style='margin: 10px 0; padding-left: 20px;'>
                    <li>Complete your profile information</li>
                    <li>Explore the platform features</li>
                    <li>Connect with other users</li>
                    <li>Access exclusive content and resources</li>
                </ul>
            </div>
            
            <p>If you have any questions or need assistance getting started, our support team is here to help.</p>
            
            <p>Welcome to the community!</p>
            
            <p>Best regards,<br><strong>The Admin Team</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>© 2024 Your Company Name. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string CreateRejectionEmailTemplate(UserData userData, string rejectionReason)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Registration Status Update</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background: linear-gradient(135deg, #e74a3b 0%, #c73321 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .status-section {{ text-align: center; margin: 30px 0; }}
        .status-icon {{ font-size: 64px; color: #e74a3b; margin-bottom: 20px; }}
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
            border-left: 4px solid #e74a3b;
            font-style: italic;
        }}
        .next-steps {{ 
            background-color: #d1ecf1; 
            border: 1px solid #bee5eb; 
            border-radius: 8px; 
            padding: 20px; 
            margin: 25px 0;
        }}
        .next-steps h3 {{ margin-top: 0; color: #0c5460; }}
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
            <h1>📝 Registration Status Update</h1>
        </div>
        
        <div class='content'>
            <div class='status-section'>
                <div class='status-icon'>⚠️</div>
                <h2>Hello {userData.FirstName},</h2>
                <p style='font-size: 18px; color: #666;'>Thank you for your interest in joining our platform.</p>
            </div>
            
            <p>After careful review by our administrative team, we regret to inform you that your registration application has not been approved at this time.</p>
            
            <div class='reason-box'>
                <h3>📋 Reason for Rejection:</h3>
                <div class='reason-text'>
                    {rejectionReason}
                </div>
            </div>
            
            <div class='next-steps'>
                <h3>🔄 What You Can Do Next:</h3>
                <ul style='margin: 10px 0; padding-left: 20px;'>
                    <li><strong>Review the feedback:</strong> Consider the reason provided above</li>
                    <li><strong>Make necessary changes:</strong> Address the concerns mentioned</li>
                    <li><strong>Reapply:</strong> You're welcome to submit a new registration application</li>
                    <li><strong>Contact support:</strong> Reach out if you need clarification</li>
                </ul>
            </div>
            
            <p>If you believe this decision was made in error or if you have questions about the feedback provided, please don't hesitate to contact our support team. We're here to help and provide guidance.</p>
            
            <p>We appreciate your understanding and interest in our platform.</p>
            
            <p>Best regards,<br><strong>The Admin Team</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>For support inquiries, please contact our support team directly.</p>
            <p>© 2024 Your Company Name. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        protected async void txtSearch_TextChanged(object sender, EventArgs e)
        {
            await LoadUsers();
        }

        protected async void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadUsers();
        }

        protected async void ddlPositionFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadUsers();
        }

        protected async void btnRefresh_Click(object sender, EventArgs e)
        {
            await LoadUsers();
            await LoadStatistics();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Implement logout logic
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

    // User data model
    [Serializable]
    public class UserData
    {
        public string Uid { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Gender { get; set; }
        public string Position { get; set; }
        public string Birthdate { get; set; }
        public string Address { get; set; }
        public string Status { get; set; }
        public string RejectionReason { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime LastUpdated { get; set; }
    }
}