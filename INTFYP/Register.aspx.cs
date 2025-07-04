using Google.Cloud.Firestore;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Services;
using System.Web.UI;

namespace YourProjectNamespace
{
    public partial class Register : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
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
                            System.Diagnostics.Debug.WriteLine($"Service account path: {path}");
                            System.Diagnostics.Debug.WriteLine($"File exists: {System.IO.File.Exists(path)}");

                            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                            db = FirestoreDb.Create("intorannetto");
                            System.Diagnostics.Debug.WriteLine("Firestore initialized successfully");
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Firestore initialization failed: {ex}");
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

                // Check for existing username
                var usernameQuery = await db.Collection("users")
        .WhereEqualTo("username_lower", username.ToLower()) // Store lowercase version for searching
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

                // Hash password (in production, use proper hashing like BCrypt)
                var hashedPassword = password; // Replace with actual hashing

                // Create user data
                var userData = new
                {
                    uid = Guid.NewGuid().ToString(),
                    firstName,
                    lastName,
                    username,
                    username_lower = username.ToLower(),
                    email,
                    password = hashedPassword,
                    phone = string.IsNullOrWhiteSpace(phone) ? null : phone,
                    gender,
                    position,
                    birthdate = string.IsNullOrWhiteSpace(birthdate) ? null : birthdate,
                    address = string.IsNullOrWhiteSpace(address) ? null : address,
                    createdAt = Timestamp.GetCurrentTimestamp(),
                    lastUpdated = Timestamp.GetCurrentTimestamp(),
                    isActive = true,
                    lastLogin = (Timestamp?)null
                };

                // Save to Firestore
                var docRef = db.Collection("users").Document(userData.uid);
                await docRef.SetAsync(userData);

                // Show success message and redirect
                ShowSuccessMessage("Registration successful! Redirecting to login page...");
                ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                    "setTimeout(function(){ window.location.href = 'Login.aspx'; }, 2000);", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Registration error: {ex}");
                ShowErrorMessage("An error occurred during registration. Please try again later.");
            }
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
}