using Google.Cloud.Firestore;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Collections.Generic;
using System.Configuration;
using SendGrid;
using SendGrid.Helpers.Mail;
using System.Security.Cryptography;
using System.Text;

namespace YourProjectNamespace
{
    public partial class Login : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        // SendGrid configuration with fallback to environment variables
        private static readonly string SendGridApiKey = GetConfigValue("SendGridApiKey");
        private static readonly string SendGridFromEmail = GetConfigValue("SendGridFromEmail");
        private static readonly string SendGridFromName = GetConfigValue("SendGridFromName");

        // Helper method to get configuration values with environment variable fallback
        private static string GetConfigValue(string key)
        {
            // First try to get from web.config/appSettings.config
            string value = ConfigurationManager.AppSettings[key];

            // If not found or empty, try environment variable
            if (string.IsNullOrEmpty(value))
            {
                value = Environment.GetEnvironmentVariable(key);
            }

            return value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                InitializeFirestore();

                if (!IsPostBack)
                {
                    // Show login form by default
                    loginPanel.Visible = true;
                    forgotPasswordPanel.Visible = false;
                    resetPasswordPanel.Visible = false;
                    successPanel.Visible = false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Page_Load error: {ex.Message}");
                ShowError("System initialization error. Please try again later.");
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

                            System.Diagnostics.Debug.WriteLine("Firestore initialized successfully");
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

        protected async void btnLogin_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            try
            {
                var input = txtUsernameOrEmail.Text.Trim().ToLower();
                var password = txtPassword.Text;

                if (string.IsNullOrWhiteSpace(input) || string.IsNullOrWhiteSpace(password))
                {
                    ShowError("Please enter both username/email and password.");
                    return;
                }

                QuerySnapshot querySnapshot;
                if (input.Contains("@"))
                {
                    querySnapshot = await db.Collection("users")
                        .WhereEqualTo("email", input)
                        .Limit(1)
                        .GetSnapshotAsync();
                }
                else
                {
                    querySnapshot = await db.Collection("users")
                        .WhereEqualTo("username_lower", input)
                        .Limit(1)
                        .GetSnapshotAsync();
                }

                if (querySnapshot.Count == 0)
                {
                    ShowError("User not found.");
                    return;
                }

                var userDoc = querySnapshot.Documents[0];
                var userData = userDoc.ToDictionary();

                string storedPassword = userData["password"]?.ToString();
                if (storedPassword != password)
                {
                    ShowError("Incorrect password.");
                    return;
                }

                // Update lastLogin
                await db.Collection("users").Document(userDoc.Id).UpdateAsync("lastLogin", Timestamp.GetCurrentTimestamp());

                // Save session info
                Session["userId"] = userDoc.Id;
                Session["username"] = userData["username"];
                Session["email"] = userData["email"];
                Session["position"] = userData["position"];

                string position = userData["position"]?.ToString()?.ToLower();
                string redirectPage = position == "administrator" ? "admin.aspx" : "class.aspx";

                ShowSuccess("Login successful! Redirecting...");
                ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                    $"setTimeout(function(){{ window.location='{redirectPage}'; }}, 2000);", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Login error: {ex}");
                ShowError("An error occurred while trying to log in. Please try again.");
            }
        }

        protected void btnShowForgotPassword_Click(object sender, EventArgs e)
        {
            loginPanel.Visible = false;
            forgotPasswordPanel.Visible = true;
            resetPasswordPanel.Visible = false;
            successPanel.Visible = false;
            lblMessage.Visible = false;
        }

        protected void btnBackToLogin_Click(object sender, EventArgs e)
        {
            loginPanel.Visible = true;
            forgotPasswordPanel.Visible = false;
            resetPasswordPanel.Visible = false;
            successPanel.Visible = false;
            lblMessage.Visible = false;
            ClearForgotPasswordFields();
        }

        protected async void btnSendResetCode_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            try
            {
                var email = txtForgotEmail.Text.Trim().ToLower();

                if (string.IsNullOrWhiteSpace(email))
                {
                    ShowError("Please enter your email address.");
                    return;
                }

                // Validate email format
                try
                {
                    var addr = new System.Net.Mail.MailAddress(email);
                    if (addr.Address != email)
                    {
                        ShowError("Please enter a valid email address.");
                        return;
                    }
                }
                catch
                {
                    ShowError("Please enter a valid email address.");
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"Checking if email exists: {email}");

                // Check if email exists in database
                var emailQuery = await db.Collection("users")
                    .WhereEqualTo("email", email)
                    .Limit(1)
                    .GetSnapshotAsync();

                if (emailQuery.Count == 0)
                {
                    ShowError("No account found with this email address.");
                    return;
                }

                var userDoc = emailQuery.Documents[0];
                var userData = userDoc.ToDictionary();
                var firstName = userData["firstName"]?.ToString() ?? "User";

                // Generate reset code
                var resetCode = new Random().Next(100000, 999999).ToString();
                var resetCodeExpiry = DateTime.UtcNow.AddMinutes(15); // 15 minutes expiry

                System.Diagnostics.Debug.WriteLine($"Generated reset code: {resetCode}");

                // Store reset code in Firestore
                var resetData = new Dictionary<string, object>
                {
                    {"Email", email},
                    {"ResetCode", resetCode},
                    {"Expiry", Timestamp.FromDateTime(resetCodeExpiry)},
                    {"Attempts", 0},
                    {"Used", false}
                };

                await db.Collection("password_resets").Document(email).SetAsync(resetData);
                System.Diagnostics.Debug.WriteLine("Reset code stored in Firestore");

                // Send reset code email
                await SendResetCodeEmail(email, resetCode, firstName);

                // Store email in session for next step
                Session["ResetEmail"] = email;

                // Show reset password form
                forgotPasswordPanel.Visible = false;
                resetPasswordPanel.Visible = true;
                lblResetEmail.Text = $"We've sent a 6-digit reset code to <strong>{email}</strong>";

                System.Diagnostics.Debug.WriteLine("Reset code sent successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Send reset code error: {ex.Message}");
                ShowError($"Failed to send reset code: {ex.Message}");
            }
        }

        protected async void btnResetPassword_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            try
            {
                var email = Session["ResetEmail"]?.ToString();
                if (string.IsNullOrEmpty(email))
                {
                    ShowError("Session expired. Please start again.");
                    btnBackToLogin_Click(sender, e);
                    return;
                }

                var resetCode = txtResetCode.Text.Trim();
                var newPassword = txtNewPassword.Text;
                var confirmPassword = txtConfirmNewPassword.Text;

                // Validate inputs
                if (string.IsNullOrWhiteSpace(resetCode) || resetCode.Length != 6)
                {
                    ShowError("Please enter a valid 6-digit reset code.");
                    return;
                }

                if (string.IsNullOrWhiteSpace(newPassword))
                {
                    ShowError("Please enter a new password.");
                    return;
                }

                // Validate password strength
                if (newPassword.Length < 8 ||
                    !newPassword.Any(char.IsUpper) ||
                    !newPassword.Any(char.IsLower) ||
                    !newPassword.Any(char.IsDigit) ||
                    !newPassword.Any(ch => !char.IsLetterOrDigit(ch)))
                {
                    ShowError("Password must be at least 8 characters and contain uppercase, lowercase, number, and special character.");
                    return;
                }

                if (newPassword != confirmPassword)
                {
                    ShowError("Passwords do not match.");
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"Verifying reset code for email: {email}");

                // Get reset code record from Firestore
                var resetDoc = await db.Collection("password_resets").Document(email).GetSnapshotAsync();

                if (!resetDoc.Exists)
                {
                    ShowError("Reset code expired or invalid. Please request a new one.");
                    btnBackToLogin_Click(sender, e);
                    return;
                }

                var storedResetCode = resetDoc.GetValue<string>("ResetCode");
                var expiry = resetDoc.GetValue<Timestamp>("Expiry").ToDateTime();
                var attempts = resetDoc.GetValue<int>("Attempts");
                var used = resetDoc.GetValue<bool>("Used");

                // Check if already used
                if (used)
                {
                    ShowError("This reset code has already been used. Please request a new one.");
                    await db.Collection("password_resets").Document(email).DeleteAsync();
                    btnBackToLogin_Click(sender, e);
                    return;
                }

                // Check if expired
                if (DateTime.UtcNow > expiry)
                {
                    ShowError("Reset code has expired. Please request a new one.");
                    await db.Collection("password_resets").Document(email).DeleteAsync();
                    btnBackToLogin_Click(sender, e);
                    return;
                }

                // Check attempts
                if (attempts >= 3)
                {
                    ShowError("Too many incorrect attempts. Please request a new reset code.");
                    await db.Collection("password_resets").Document(email).DeleteAsync();
                    btnBackToLogin_Click(sender, e);
                    return;
                }

                // Verify reset code
                if (resetCode != storedResetCode)
                {
                    // Increment attempt count
                    var updateData = new Dictionary<string, object> { { "Attempts", attempts + 1 } };
                    await db.Collection("password_resets").Document(email).UpdateAsync(updateData);
                    ShowError("Invalid reset code. Please try again.");
                    return;
                }

                System.Diagnostics.Debug.WriteLine("Reset code verified, updating password");

                // Find user and update password
                var userQuery = await db.Collection("users")
                    .WhereEqualTo("email", email)
                    .Limit(1)
                    .GetSnapshotAsync();

                if (userQuery.Count > 0)
                {
                    var userDoc = userQuery.Documents[0];

                    // Update password (in production, hash the password)
                    var passwordUpdateData = new Dictionary<string, object>
                    {
                        {"password", newPassword}, // In production, hash this
                        {"lastUpdated", Timestamp.GetCurrentTimestamp()}
                    };

                    await db.Collection("users").Document(userDoc.Id).UpdateAsync(passwordUpdateData);

                    // Mark reset code as used
                    await db.Collection("password_resets").Document(email).UpdateAsync("Used", true);

                    System.Diagnostics.Debug.WriteLine("Password updated successfully");

                    // Show success
                    resetPasswordPanel.Visible = false;
                    successPanel.Visible = true;

                    // Clean up session
                    Session.Remove("ResetEmail");
                }
                else
                {
                    ShowError("User account not found.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Reset password error: {ex.Message}");
                ShowError($"Failed to reset password: {ex.Message}");
            }
        }

        protected async void btnResendResetCode_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            try
            {
                var email = Session["ResetEmail"]?.ToString();
                if (string.IsNullOrEmpty(email))
                {
                    ShowError("Session expired. Please start again.");
                    btnBackToLogin_Click(sender, e);
                    return;
                }

                // Generate new reset code
                var resetCode = new Random().Next(100000, 999999).ToString();
                var resetCodeExpiry = DateTime.UtcNow.AddMinutes(15);

                System.Diagnostics.Debug.WriteLine($"Generated new reset code: {resetCode} for email: {email}");

                // Update reset code in Firestore
                var resetData = new Dictionary<string, object>
                {
                    {"ResetCode", resetCode},
                    {"Expiry", Timestamp.FromDateTime(resetCodeExpiry)},
                    {"Attempts", 0},
                    {"Used", false}
                };

                await db.Collection("password_resets").Document(email).SetAsync(resetData);

                // Get user's first name for email
                var userQuery = await db.Collection("users")
                    .WhereEqualTo("email", email)
                    .Limit(1)
                    .GetSnapshotAsync();

                var firstName = "User";
                if (userQuery.Count > 0)
                {
                    var userData = userQuery.Documents[0].ToDictionary();
                    firstName = userData["firstName"]?.ToString() ?? "User";
                }

                // Send new reset code email
                await SendResetCodeEmail(email, resetCode, firstName);

                ShowSuccess($"A new reset code has been sent to {email}");
                System.Diagnostics.Debug.WriteLine("Reset code resent successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Resend reset code error: {ex.Message}");
                ShowError($"Failed to resend reset code: {ex.Message}");
            }
        }

        protected void btnLoginFromSuccess_Click(object sender, EventArgs e)
        {
            loginPanel.Visible = true;
            forgotPasswordPanel.Visible = false;
            resetPasswordPanel.Visible = false;
            successPanel.Visible = false;
            lblMessage.Visible = false;
            ClearForgotPasswordFields();
        }

        private async Task SendResetCodeEmail(string toEmail, string resetCode, string firstName)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"Sending reset code email to: {toEmail}");

                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName);
                var to = new EmailAddress(toEmail, firstName);
                var subject = "Password Reset Code";

                var plainTextContent = $@"
Hello {firstName}!

You requested to reset your password. Use the code below to reset your password:

Your Password Reset Code: {resetCode}

Important:
- This code is valid for 15 minutes only
- Do not share this code with anyone
- If you didn't request this, please ignore this email

Best regards,
The Support Team
                ";

                var htmlContent = CreateResetEmailTemplate(firstName, resetCode);

                var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);

                var response = await client.SendEmailAsync(msg);

                if (response.IsSuccessStatusCode)
                {
                    System.Diagnostics.Debug.WriteLine("Reset code email sent successfully");
                }
                else
                {
                    var responseBody = await response.Body.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"SendGrid API error: {response.StatusCode}");
                    throw new Exception($"SendGrid API error: {response.StatusCode}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending reset code email: {ex.Message}");
                throw new Exception($"Failed to send reset code email: {ex.Message}");
            }
        }

        private string CreateResetEmailTemplate(string firstName, string resetCode)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Password Reset Code</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background-color: #dc3545; color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .code-section {{ text-align: center; margin: 30px 0; }}
        .code-box {{ 
            background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            border-radius: 12px; 
            padding: 25px; 
            display: inline-block;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }}
        .code-label {{ color: white; font-size: 16px; margin-bottom: 10px; }}
        .reset-code {{ 
            font-size: 36px; 
            font-weight: bold; 
            color: white; 
            letter-spacing: 8px; 
            font-family: 'Courier New', monospace;
        }}
        .instructions {{ 
            background-color: #f8f9fc; 
            border-left: 4px solid #dc3545; 
            padding: 20px; 
            margin: 25px 0; 
            border-radius: 0 8px 8px 0;
        }}
        .instructions h3 {{ margin-top: 0; color: #dc3545; }}
        .instructions ul {{ margin: 10px 0; padding-left: 20px; }}
        .instructions li {{ margin-bottom: 8px; }}
        .footer {{ 
            background-color: #f8f9fc; 
            padding: 20px; 
            text-align: center; 
            border-top: 1px solid #e3e6f0;
            font-size: 14px;
            color: #666;
        }}
        .security-notice {{
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            text-align: center;
        }}
        .security-notice strong {{ color: #856404; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🔒 Password Reset</h1>
        </div>
        
        <div class='content'>
            <h2>Hello {firstName}!</h2>
            <p>You requested to reset your password. To proceed with resetting your password, please use the verification code below.</p>
            
            <div class='code-section'>
                <div class='code-box'>
                    <div class='code-label'>Your password reset code is:</div>
                    <div class='reset-code'>{resetCode}</div>
                </div>
            </div>
            
            <div class='instructions'>
                <h3>📋 Important Instructions:</h3>
                <ul>
                    <li><strong>Valid for 15 minutes only</strong> - Use this code promptly</li>
                    <li><strong>Keep it confidential</strong> - Never share this code with anyone</li>
                    <li><strong>One-time use</strong> - This code can only be used once</li>
                    <li><strong>Didn't request this?</strong> You can safely ignore this email</li>
                </ul>
            </div>
            
            <div class='security-notice'>
                <strong>🛡️ Security Tip:</strong> We will never ask for your reset code via phone or SMS. Only enter this code on our official website.
            </div>
            
            <p>If you need assistance or have any questions, please contact our support team.</p>
            
            <p>Best regards,<br><strong>The Support Team</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>© 2024 Your Company Name. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private void ClearForgotPasswordFields()
        {
            txtForgotEmail.Text = "";
            txtResetCode.Text = "";
            txtNewPassword.Text = "";
            txtConfirmNewPassword.Text = "";
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-danger";
            lblMessage.Visible = true;
        }

        private void ShowSuccess(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;
        }
    }
}
