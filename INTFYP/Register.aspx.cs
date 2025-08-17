using Google.Cloud.Firestore;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Collections.Generic;
using System.IO;
using System.Configuration;
using SendGrid;
using SendGrid.Helpers.Mail;

namespace YourProjectNamespace
{
    public partial class Register : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        // SendGrid configuration with fallback to environment variables
        private static readonly string SendGridApiKey = GetConfigValue("SendGridApiKey");
        private static readonly string SendGridFromEmail = GetConfigValue("SendGridFromEmail");
        private static readonly string SendGridFromName = GetConfigValue("SendGridFromName");
        private static readonly string AdminEmail = GetConfigValue("AdminEmail"); // Admin notification email

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
                    // Show registration form by default
                    registrationStep1.Visible = true;
                    registrationStep2.Visible = false;
                    registrationComplete.Visible = false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Page_Load error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                ShowErrorMessage("System initialization error. Please try again later.");
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
                            // Try multiple paths for service account key
                            string path = Server.MapPath("~/serviceAccountKey.json");

                            // Alternative: try environment variable for service account path
                            if (!System.IO.File.Exists(path))
                            {
                                string envPath = Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS");
                                if (!string.IsNullOrEmpty(envPath) && System.IO.File.Exists(envPath))
                                {
                                    path = envPath;
                                }
                                else
                                {
                                    throw new FileNotFoundException($"Service account key not found at: {path}. Please ensure serviceAccountKey.json exists or set GOOGLE_APPLICATION_CREDENTIALS environment variable.");
                                }
                            }

                            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                            db = FirestoreDb.Create("intorannetto");

                            System.Diagnostics.Debug.WriteLine("Firestore initialized successfully");
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Firestore initialization failed: {ex.Message}");
                            System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                            throw;
                        }
                    }
                }
            }
        }

        protected async void btnRegister_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            try
            {
                System.Diagnostics.Debug.WriteLine("Registration process started");

                // Validate API keys are configured
                if (string.IsNullOrEmpty(SendGridApiKey))
                {
                    ShowErrorMessage("Email service is not configured. Please contact administrator.");
                    return;
                }

                // Get form values
                var firstName = txtFirstName.Text.Trim();
                var lastName = txtLastName.Text.Trim();
                var username = txtUsername.Text.Trim();
                var email = txtEmail.Text.Trim().ToLower();
                var password = txtPassword.Text;
                var confirmPassword = txtConfirmPassword.Text;
                var phone = txtPhone.Text.Trim();
                var gender = ddlGender.SelectedValue;
                var position = ddlPosition.SelectedValue;
                var birthdate = txtBirthdate.Text;
                var address = txtAddress.Text.Trim();

                System.Diagnostics.Debug.WriteLine($"Form data collected. Email: {email}, Username: {username}");

                // Validate required fields
                if (string.IsNullOrWhiteSpace(firstName) ||
                    string.IsNullOrWhiteSpace(lastName) ||
                    string.IsNullOrWhiteSpace(username) ||
                    string.IsNullOrWhiteSpace(email) ||
                    string.IsNullOrWhiteSpace(password) ||
                    string.IsNullOrWhiteSpace(confirmPassword) ||
                    string.IsNullOrWhiteSpace(gender) ||
                    string.IsNullOrWhiteSpace(position))
                {
                    ShowErrorMessage("Please fill in all required fields.");
                    return;
                }

                // Validate username format
                if (username.Length < 3)
                {
                    ShowErrorMessage("Username must be at least 3 characters.");
                    return;
                }

                if (!System.Text.RegularExpressions.Regex.IsMatch(username, @"^[a-zA-Z0-9_]+$"))
                {
                    ShowErrorMessage("Username can only contain letters, numbers, and underscores.");
                    return;
                }

                // Validate email format
                try
                {
                    var addr = new System.Net.Mail.MailAddress(email);
                    if (addr.Address != email)
                    {
                        ShowErrorMessage("Please enter a valid email address.");
                        return;
                    }
                }
                catch
                {
                    ShowErrorMessage("Please enter a valid email address.");
                    return;
                }

                // Validate password
                if (password.Length < 8 ||
                    !password.Any(char.IsUpper) ||
                    !password.Any(char.IsLower) ||
                    !password.Any(char.IsDigit) ||
                    !password.Any(ch => !char.IsLetterOrDigit(ch)))
                {
                    ShowErrorMessage("Password must be at least 8 characters and contain uppercase, lowercase, number, and special character.");
                    return;
                }

                if (password != confirmPassword)
                {
                    ShowErrorMessage("Passwords do not match.");
                    return;
                }

                // Validate phone if provided
                if (!string.IsNullOrWhiteSpace(phone) && (phone.Length < 6 || !phone.All(char.IsDigit)))
                {
                    ShowErrorMessage("Please enter a valid phone number (digits only, at least 6 characters).");
                    return;
                }

                System.Diagnostics.Debug.WriteLine("Validation passed, checking for existing users");

                // Check for existing username
                var usernameQuery = await db.Collection("users")
                    .WhereEqualTo("username_lower", username.ToLower())
                    .Limit(1)
                    .GetSnapshotAsync();

                if (usernameQuery.Count > 0)
                {
                    ShowErrorMessage("Username is already taken. Please choose another one.");
                    return;
                }

                // Check for existing email
                var emailQuery = await db.Collection("users")
                    .WhereEqualTo("email", email)
                    .Limit(1)
                    .GetSnapshotAsync();

                if (emailQuery.Count > 0)
                {
                    ShowErrorMessage("Email is already registered. Please use another email or login.");
                    return;
                }

                // Check for existing phone if provided
                if (!string.IsNullOrWhiteSpace(phone))
                {
                    var phoneQuery = await db.Collection("users")
                        .WhereEqualTo("phone", phone)
                        .Limit(1)
                        .GetSnapshotAsync();

                    if (phoneQuery.Count > 0)
                    {
                        ShowErrorMessage("Phone number is already registered.");
                        return;
                    }
                }

                System.Diagnostics.Debug.WriteLine("No existing users found, generating OTP");

                // Generate OTP
                var otp = new Random().Next(100000, 999999).ToString();
                var otpExpiry = DateTime.UtcNow.AddMinutes(10);

                System.Diagnostics.Debug.WriteLine($"Generated OTP: {otp}");

                // Store registration data in session using a proper class
                var registrationData = new RegistrationData
                {
                    FirstName = firstName,
                    LastName = lastName,
                    Username = username,
                    UsernameLower = username.ToLower(),
                    Email = email,
                    Password = password, // Note: In production, hash this before storing
                    Phone = string.IsNullOrWhiteSpace(phone) ? null : phone,
                    Gender = gender,
                    Position = position,
                    Birthdate = string.IsNullOrWhiteSpace(birthdate) ? null : birthdate,
                    Address = string.IsNullOrWhiteSpace(address) ? null : address
                };

                Session["RegistrationData"] = registrationData;
                System.Diagnostics.Debug.WriteLine("Registration data stored in session");

                // Store OTP in Firestore
                var otpData = new Dictionary<string, object>
                {
                    {"Email", email},
                    {"OTP", otp},
                    {"Expiry", Timestamp.FromDateTime(otpExpiry)},
                    {"Attempts", 0}
                };

                await db.Collection("otps").Document(email).SetAsync(otpData);
                System.Diagnostics.Debug.WriteLine("OTP stored in Firestore");

                // Send OTP email via SendGrid
                await SendOtpEmailViaSendGrid(email, otp, firstName);
                System.Diagnostics.Debug.WriteLine("OTP email sent via SendGrid");

                // Move to OTP verification step
                registrationStep1.Visible = false;
                registrationStep2.Visible = true;
                registrationComplete.Visible = false;
                lblOtpEmail.Text = $"We've sent a 6-digit OTP to <strong>{email}</strong>. Please check your inbox.";

                System.Diagnostics.Debug.WriteLine("Registration process completed successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Registration error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                ShowErrorMessage($"An error occurred during registration: {ex.Message}");
            }
        }

        protected async void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            try
            {
                System.Diagnostics.Debug.WriteLine("OTP verification started");

                var registrationData = Session["RegistrationData"] as RegistrationData;
                if (registrationData == null)
                {
                    ShowErrorMessage("Session expired. Please start registration again.");
                    Response.Redirect("Register.aspx");
                    return;
                }

                var email = registrationData.Email;
                var userOtp = txtOtp.Text.Trim();

                System.Diagnostics.Debug.WriteLine($"Verifying OTP for email: {email}, OTP: {userOtp}");

                if (string.IsNullOrWhiteSpace(userOtp) || userOtp.Length != 6)
                {
                    ShowErrorMessage("Please enter a valid 6-digit OTP.");
                    return;
                }

                // Get OTP record from Firestore
                var otpDoc = await db.Collection("otps").Document(email).GetSnapshotAsync();

                if (!otpDoc.Exists)
                {
                    ShowErrorMessage("OTP expired or invalid. Please request a new one.");
                    registrationStep1.Visible = true;
                    registrationStep2.Visible = false;
                    registrationComplete.Visible = false;
                    return;
                }

                var storedOtp = otpDoc.GetValue<string>("OTP");
                var expiry = otpDoc.GetValue<Timestamp>("Expiry").ToDateTime();
                var attempts = otpDoc.GetValue<int>("Attempts");

                System.Diagnostics.Debug.WriteLine($"Stored OTP: {storedOtp}, User OTP: {userOtp}, Expiry: {expiry}, Attempts: {attempts}");

                // Check if OTP is expired
                if (DateTime.UtcNow > expiry)
                {
                    ShowErrorMessage("OTP has expired. Please request a new one.");
                    await db.Collection("otps").Document(email).DeleteAsync();
                    registrationStep1.Visible = true;
                    registrationStep2.Visible = false;
                    registrationComplete.Visible = false;
                    return;
                }

                // Check if too many attempts
                if (attempts >= 3)
                {
                    ShowErrorMessage("Too many incorrect attempts. Please request a new OTP.");
                    await db.Collection("otps").Document(email).DeleteAsync();
                    registrationStep1.Visible = true;
                    registrationStep2.Visible = false;
                    registrationComplete.Visible = false;
                    return;
                }

                // Verify OTP
                if (userOtp != storedOtp)
                {
                    // Increment attempt count
                    var updateData = new Dictionary<string, object> { { "Attempts", attempts + 1 } };
                    await db.Collection("otps").Document(email).UpdateAsync(updateData);
                    ShowErrorMessage("Invalid OTP. Please try again.");
                    return;
                }

                System.Diagnostics.Debug.WriteLine("OTP verified successfully, completing registration");

                // OTP verified - proceed with registration (now with pending status)
                await CompleteRegistrationWithApproval(registrationData);

                // Delete OTP record
                await db.Collection("otps").Document(email).DeleteAsync();

                // Clear session
                Session.Remove("RegistrationData");

                // Show completion step
                registrationStep1.Visible = false;
                registrationStep2.Visible = false;
                registrationComplete.Visible = true;

                System.Diagnostics.Debug.WriteLine("Registration completed successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"OTP verification error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                ShowErrorMessage($"An error occurred during OTP verification: {ex.Message}");
            }
        }

        protected async void btnResendOtp_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            try
            {
                System.Diagnostics.Debug.WriteLine("Resending OTP");

                var registrationData = Session["RegistrationData"] as RegistrationData;
                if (registrationData == null)
                {
                    ShowErrorMessage("Session expired. Please start registration again.");
                    Response.Redirect("Register.aspx");
                    return;
                }

                var email = registrationData.Email;

                // Generate new OTP
                var otp = new Random().Next(100000, 999999).ToString();
                var otpExpiry = DateTime.UtcNow.AddMinutes(10);

                System.Diagnostics.Debug.WriteLine($"Generated new OTP: {otp} for email: {email}");

                // Update OTP in Firestore
                var otpData = new Dictionary<string, object>
                {
                    {"OTP", otp},
                    {"Expiry", Timestamp.FromDateTime(otpExpiry)},
                    {"Attempts", 0}
                };

                await db.Collection("otps").Document(email).SetAsync(otpData);

                // Send new OTP to user's email via SendGrid
                await SendOtpEmailViaSendGrid(email, otp, registrationData.FirstName);

                ShowSuccessMessage($"A new OTP has been sent to {email}");
                System.Diagnostics.Debug.WriteLine("OTP resent successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Resend OTP error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                ShowErrorMessage($"Failed to resend OTP: {ex.Message}");
            }
        }

        protected void btnBackToRegister_Click(object sender, EventArgs e)
        {
            registrationStep1.Visible = true;
            registrationStep2.Visible = false;
            registrationComplete.Visible = false;
        }

        private async Task CompleteRegistrationWithApproval(RegistrationData registrationData)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("Completing registration for user: " + registrationData.Email);

                // Hash password (in production, use proper hashing like BCrypt)
                var hashedPassword = registrationData.Password; // Replace with actual hashing

                // Create user data with pending status
                var uid = Guid.NewGuid().ToString();
                var userData = new Dictionary<string, object>
                {
                    {"uid", uid},
                    {"firstName", registrationData.FirstName},
                    {"lastName", registrationData.LastName},
                    {"username", registrationData.Username},
                    {"username_lower", registrationData.UsernameLower},
                    {"email", registrationData.Email},
                    {"password", hashedPassword},
                    {"phone", registrationData.Phone},
                    {"gender", registrationData.Gender},
                    {"position", registrationData.Position},
                    {"birthdate", registrationData.Birthdate},
                    {"address", registrationData.Address},
                    {"createdAt", Timestamp.GetCurrentTimestamp()},
                    {"lastUpdated", Timestamp.GetCurrentTimestamp()},
                    {"isActive", false}, // User is not active until approved
                    {"lastLogin", null},
                    {"isEmailVerified", true},
                    {"status", "pending"}, // Pending admin approval
                    {"submittedForApproval", Timestamp.GetCurrentTimestamp()}
                };

                // Save to Firestore
                var docRef = db.Collection("users").Document(uid);
                await docRef.SetAsync(userData);

                System.Diagnostics.Debug.WriteLine("User data saved to Firestore with UID: " + uid);

                // Send notification to user about pending approval
                await SendPendingApprovalNotification(registrationData);

                // Send notification to admin about new registration
                await SendAdminNotification(registrationData);

                System.Diagnostics.Debug.WriteLine("Notifications sent successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error completing registration: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                throw;
            }
        }

        private async Task SendPendingApprovalNotification(RegistrationData userData)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"Sending pending approval notification to: {userData.Email}");

                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName);
                var to = new EmailAddress(userData.Email, $"{userData.FirstName} {userData.LastName}");
                var subject = "Registration Submitted - Pending Approval";

                var plainTextContent = $@"
Hello {userData.FirstName}!

Thank you for registering with us. Your registration has been successfully submitted and is currently pending administrative approval.

Registration Details:
- Name: {userData.FirstName} {userData.LastName}
- Email: {userData.Email}
- Username: {userData.Username}
- Position: {userData.Position}

What happens next?
1. Our administrators will review your registration details
2. You will receive an email notification once your account is approved or if additional information is needed
3. After approval, you can log in using your email and password

Please note: You will not be able to log in until your account has been approved by an administrator.

If you have any questions, please contact our support team.

Thank you for your patience!

Best regards,
The Registration Team
                ";

                var htmlContent = CreatePendingApprovalEmailTemplate(userData);

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
                System.Diagnostics.Debug.WriteLine($"Error sending pending approval notification: {ex.Message}");
                throw;
            }
        }

        private async Task SendAdminNotification(RegistrationData userData)
        {
            try
            {
                if (string.IsNullOrEmpty(AdminEmail))
                {
                    System.Diagnostics.Debug.WriteLine("Admin email not configured, skipping admin notification");
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"Sending admin notification to: {AdminEmail}");

                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName);
                var to = new EmailAddress(AdminEmail, "Administrator");
                var subject = "🔔 New User Registration Pending Approval";

                var plainTextContent = $@"
A new user has registered and is pending your approval.

User Details:
- Name: {userData.FirstName} {userData.LastName}
- Email: {userData.Email}
- Username: {userData.Username}
- Position: {userData.Position}
- Gender: {userData.Gender}
- Phone: {userData.Phone ?? "Not provided"}
- Birthdate: {userData.Birthdate ?? "Not provided"}
- Address: {userData.Address ?? "Not provided"}
- Registration Date: {DateTime.Now:MMM dd, yyyy HH:mm}

Please log in to the admin dashboard to review and approve/reject this registration.

Admin Dashboard: [Your Admin Dashboard URL]

Best regards,
System Administrator
                ";

                var htmlContent = CreateAdminNotificationEmailTemplate(userData);

                var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
                var response = await client.SendEmailAsync(msg);

                if (!response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Body.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"Failed to send admin notification: {response.StatusCode} - {responseBody}");
                    // Don't throw exception for admin notification failure - it's not critical for user flow
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending admin notification: {ex.Message}");
                // Don't throw exception for admin notification failure
            }
        }

        private async Task SendOtpEmailViaSendGrid(string toEmail, string otp, string firstName)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"Sending OTP email via SendGrid to: {toEmail}");

                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName);
                var to = new EmailAddress(toEmail, $"{firstName}");
                var subject = "Your OTP for Registration";

                // Create email content
                var plainTextContent = $@"
Hello {firstName}!

Thank you for registering with us. To complete your registration, please verify your email address using the OTP below:

Your One-Time Password (OTP) is: {otp}

Important:
- This OTP is valid for 10 minutes only
- Do not share this code with anyone
- If you didn't request this, please ignore this email

If you have any questions, please contact our support team.

Best regards,
The Registration Team
                ";

                var htmlContent = CreateOtpEmailTemplate(firstName, otp);

                var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);

                // Send email
                var response = await client.SendEmailAsync(msg);

                if (response.IsSuccessStatusCode)
                {
                    System.Diagnostics.Debug.WriteLine("OTP email sent successfully via SendGrid");
                }
                else
                {
                    var responseBody = await response.Body.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"SendGrid API error: {response.StatusCode}");
                    System.Diagnostics.Debug.WriteLine($"Response body: {responseBody}");
                    throw new Exception($"SendGrid API error: {response.StatusCode} - {responseBody}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending OTP email via SendGrid: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                throw new Exception($"Failed to send OTP email: {ex.Message}");
            }
        }

        private string CreatePendingApprovalEmailTemplate(RegistrationData userData)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Registration Pending Approval</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background: linear-gradient(135deg, #f6c23e 0%, #e4a900 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .status-section {{ text-align: center; margin: 30px 0; }}
        .status-icon {{ font-size: 64px; color: #f6c23e; margin-bottom: 20px; }}
        .info-box {{ 
            background-color: #fff3cd; 
            border: 1px solid #ffeaa7; 
            border-radius: 8px; 
            padding: 20px; 
            margin: 25px 0;
        }}
        .info-box h3 {{ margin-top: 0; color: #856404; }}
        .user-details {{ 
            background-color: #f8f9fc; 
            border-radius: 8px; 
            padding: 20px; 
            margin: 20px 0;
        }}
        .detail-row {{ 
            display: flex; 
            justify-content: space-between; 
            padding: 8px 0; 
            border-bottom: 1px solid #e3e6f0;
        }}
        .detail-row:last-child {{ border-bottom: none; }}
        .detail-label {{ font-weight: bold; color: #5a5c69; }}
        .detail-value {{ color: #3a3b45; }}
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
            <h1>⏳ Registration Submitted</h1>
        </div>
        
        <div class='content'>
            <div class='status-section'>
                <div class='status-icon'>📝</div>
                <h2>Hello {userData.FirstName}!</h2>
                <p style='font-size: 18px; color: #666;'>Your registration has been successfully submitted.</p>
            </div>
            
            <p>Thank you for registering with us! Your registration details have been submitted and are currently pending administrative approval.</p>
            
            <div class='user-details'>
                <h3 style='margin-top: 0; color: #5a5c69;'>📋 Your Registration Details:</h3>
                <div class='detail-row'>
                    <span class='detail-label'>Name:</span>
                    <span class='detail-value'>{userData.FirstName} {userData.LastName}</span>
                </div>
                <div class='detail-row'>
                    <span class='detail-label'>Email:</span>
                    <span class='detail-value'>{userData.Email}</span>
                </div>
                <div class='detail-row'>
                    <span class='detail-label'>Username:</span>
                    <span class='detail-value'>{userData.Username}</span>
                </div>
                <div class='detail-row'>
                    <span class='detail-label'>Position:</span>
                    <span class='detail-value'>{userData.Position}</span>
                </div>
            </div>
            
            <div class='next-steps'>
                <h3>🔄 What Happens Next?</h3>
                <ol style='margin: 10px 0; padding-left: 20px;'>
                    <li><strong>Review Process:</strong> Our administrators will review your registration details</li>
                    <li><strong>Email Notification:</strong> You'll receive an email once your account is approved or if we need additional information</li>
                    <li><strong>Account Access:</strong> After approval, you can log in using your email and password</li>
                </ol>
            </div>
            
            <div class='info-box'>
                <h3>⚠️ Important Note:</h3>
                <p style='margin: 0;'><strong>You will not be able to log in until your account has been approved by an administrator.</strong> Please wait for the approval email before attempting to access your account.</p>
            </div>
            
            <p>We appreciate your patience during the review process. If you have any questions, please don't hesitate to contact our support team.</p>
            
            <p>Thank you for choosing our platform!</p>
            
            <p>Best regards,<br><strong>The Registration Team</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>© 2024 Your Company Name. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string CreateAdminNotificationEmailTemplate(RegistrationData userData)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>New User Registration - Admin Approval Required</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background: linear-gradient(135deg, #4e73df 0%, #3a5bc7 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .alert-section {{ text-align: center; margin: 30px 0; }}
        .alert-icon {{ font-size: 64px; color: #4e73df; margin-bottom: 20px; }}
        .user-card {{ 
            background-color: #f8f9fc; 
            border: 2px solid #4e73df; 
            border-radius: 12px; 
            padding: 25px; 
            margin: 25px 0;
        }}
        .user-card h3 {{ margin-top: 0; color: #4e73df; }}
        .detail-grid {{ 
            display: grid; 
            grid-template-columns: 1fr 1fr; 
            gap: 15px; 
            margin: 20px 0;
        }}
        .detail-item {{ 
            background-color: white; 
            padding: 15px; 
            border-radius: 8px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .detail-label {{ font-weight: bold; color: #5a5c69; font-size: 14px; }}
        .detail-value {{ color: #3a3b45; margin-top: 5px; }}
        .cta-section {{ 
            background: linear-gradient(135deg, #1cc88a 0%, #17a673 100%); 
            color: white; 
            border-radius: 12px; 
            padding: 25px; 
            text-align: center; 
            margin: 30px 0;
        }}
        .cta-button {{ 
            display: inline-block; 
            background-color: white; 
            color: #1cc88a; 
            padding: 15px 30px; 
            text-decoration: none; 
            border-radius: 8px; 
            font-weight: bold;
            margin: 15px 0;
        }}
        .footer {{ 
            background-color: #f8f9fc; 
            padding: 20px; 
            text-align: center; 
            border-top: 1px solid #e3e6f0;
            font-size: 14px;
            color: #666;
        }}
        @media (max-width: 600px) {{
            .detail-grid {{ grid-template-columns: 1fr; }}
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🔔 New Registration Alert</h1>
        </div>
        
        <div class='content'>
            <div class='alert-section'>
                <div class='alert-icon'>👤</div>
                <h2>Action Required</h2>
                <p style='font-size: 18px; color: #666;'>A new user has registered and requires approval.</p>
            </div>
            
            <div class='user-card'>
                <h3>📝 User Registration Details</h3>
                <div class='detail-grid'>
                    <div class='detail-item'>
                        <div class='detail-label'>Full Name</div>
                        <div class='detail-value'>{userData.FirstName} {userData.LastName}</div>
                    </div>
                    <div class='detail-item'>
                        <div class='detail-label'>Email Address</div>
                        <div class='detail-value'>{userData.Email}</div>
                    </div>
                    <div class='detail-item'>
                        <div class='detail-label'>Username</div>
                        <div class='detail-value'>{userData.Username}</div>
                    </div>
                    <div class='detail-item'>
                        <div class='detail-label'>Position</div>
                        <div class='detail-value'>{userData.Position}</div>
                    </div>
                    <div class='detail-item'>
                        <div class='detail-label'>Gender</div>
                        <div class='detail-value'>{userData.Gender}</div>
                    </div>
                    <div class='detail-item'>
                        <div class='detail-label'>Phone</div>
                        <div class='detail-value'>{userData.Phone ?? "Not provided"}</div>
                    </div>
                    {(!string.IsNullOrEmpty(userData.Birthdate) ? $@"
                    <div class='detail-item'>
                        <div class='detail-label'>Birthdate</div>
                        <div class='detail-value'>{userData.Birthdate}</div>
                    </div>" : "")}
                    {(!string.IsNullOrEmpty(userData.Address) ? $@"
                    <div class='detail-item'>
                        <div class='detail-label'>Address</div>
                        <div class='detail-value'>{userData.Address}</div>
                    </div>" : "")}
                    <div class='detail-item'>
                        <div class='detail-label'>Registration Time</div>
                        <div class='detail-value'>{DateTime.Now:MMM dd, yyyy HH:mm}</div>
                    </div>
                </div>
            </div>
            
            <div class='cta-section'>
                <h3 style='margin-top: 0;'>⚡ Ready to Review?</h3>
                <p>Please log in to the admin dashboard to approve or reject this registration.</p>
                <a href='#' class='cta-button'>Open Admin Dashboard</a>
            </div>
            
            <div style='background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 20px; margin: 20px 0;'>
                <h4 style='margin-top: 0; color: #856404;'>📊 Quick Stats:</h4>
                <p style='margin: 0; color: #856404;'>The user has completed email verification and is awaiting your approval to access the platform.</p>
            </div>
            
            <p>Best regards,<br><strong>System Administrator</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated notification from the registration system.</p>
            <p>© 2024 Your Company Name. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string CreateOtpEmailTemplate(string firstName, string otp)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Your OTP for Registration</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background-color: #4e73df; color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .otp-section {{ text-align: center; margin: 30px 0; }}
        .otp-box {{ 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 12px; 
            padding: 25px; 
            display: inline-block;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }}
        .otp-label {{ color: white; font-size: 16px; margin-bottom: 10px; }}
        .otp-code {{ 
            font-size: 36px; 
            font-weight: bold; 
            color: white; 
            letter-spacing: 8px; 
            font-family: 'Courier New', monospace;
        }}
        .instructions {{ 
            background-color: #f8f9fc; 
            border-left: 4px solid #4e73df; 
            padding: 20px; 
            margin: 25px 0; 
            border-radius: 0 8px 8px 0;
        }}
        .instructions h3 {{ margin-top: 0; color: #4e73df; }}
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
            <h1>🔐 Email Verification</h1>
        </div>
        
        <div class='content'>
            <h2>Hello {firstName}!</h2>
            <p>Thank you for registering with us. To complete your registration and secure your account, please verify your email address using the One-Time Password below.</p>
            
            <div class='otp-section'>
                <div class='otp-box'>
                    <div class='otp-label'>Your verification code is:</div>
                    <div class='otp-code'>{otp}</div>
                </div>
            </div>
            
            <div class='instructions'>
                <h3>📋 Important Instructions:</h3>
                <ul>
                    <li><strong>Valid for 10 minutes only</strong> - Use this code promptly</li>
                    <li><strong>Keep it confidential</strong> - Never share this code with anyone</li>
                    <li><strong>One-time use</strong> - This code can only be used once</li>
                    <li><strong>Didn't request this?</strong> You can safely ignore this email</li>
                </ul>
            </div>
            
            <div class='security-notice'>
                <strong>🛡️ Security Tip:</strong> We will never ask for your OTP via phone, SMS, or email. Only enter this code on our official website.
            </div>
            
            <p>If you need assistance or have any questions, please don't hesitate to contact our support team.</p>
            
            <p>Best regards,<br><strong>The Registration Team</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>© 2024 Your Company Name. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
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

    // Helper class for registration data
    [Serializable]
    public class RegistrationData
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string UsernameLower { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string Phone { get; set; }
        public string Gender { get; set; }
        public string Position { get; set; }
        public string Birthdate { get; set; }
        public string Address { get; set; }
    }
}