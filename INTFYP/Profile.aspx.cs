using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

namespace YourProjectNamespace
{
    public partial class Profile : System.Web.UI.Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        protected string currentUsername;
        private Dictionary<string, object> userData;

        protected async void Page_Load(object sender, EventArgs e)
        {
            // Check authentication
            if (Session["userId"] == null || Session["username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            try
            {
                // Initialize Firestore
                db = FirestoreDb.Create("intorannetto");
                currentUserId = Session["userId"].ToString();
                currentUsername = Session["username"].ToString();

                if (!IsPostBack)
                {
                    await LoadUserProfile();
                    await LoadUserStats();
                    await LoadUserClasses();
                    await LoadUserActivity();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading profile: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Profile load error: {ex}");
            }
        }

        private async Task LoadUserProfile()
        {
            try
            {
                // Get user data from Firestore
                var userRef = db.Collection("users").Document(currentUserId);
                var userSnap = await userRef.GetSnapshotAsync();

                if (!userSnap.Exists)
                {
                    ShowMessage("User profile not found.", "danger");
                    return;
                }

                userData = userSnap.ToDictionary();

                // Populate profile header
                string firstName = userData.GetValueOrDefault("firstName", "").ToString();
                string lastName = userData.GetValueOrDefault("lastName", "").ToString();
                string username = userData.GetValueOrDefault("username", "").ToString();
                string position = userData.GetValueOrDefault("position", "Student").ToString();

                ltProfileName.Text = $"{firstName} {lastName}";
                ltUsername.Text = username;
                ltPosition.Text = position;

                // Load profile image if exists
                if (userData.ContainsKey("profileImageUrl") && !string.IsNullOrEmpty(userData["profileImageUrl"].ToString()))
                {
                    imgProfile.ImageUrl = userData["profileImageUrl"].ToString();
                }

                // Populate form fields
                txtFirstName.Text = firstName;
                txtLastName.Text = lastName;
                txtEmail.Text = userData.GetValueOrDefault("email", "").ToString();
                txtUsername.Text = username;
                txtPhone.Text = userData.GetValueOrDefault("phone", "").ToString();
                txtPosition.Text = position;
                txtAddress.Text = userData.GetValueOrDefault("address", "").ToString();

                // Set gender dropdown
                string gender = userData.GetValueOrDefault("gender", "").ToString();
                if (ddlGender.Items.FindByValue(gender) != null)
                {
                    ddlGender.SelectedValue = gender;
                }

                // Set birthdate
                if (userData.ContainsKey("birthdate") && !string.IsNullOrEmpty(userData["birthdate"].ToString()))
                {
                    txtBirthdate.Text = userData["birthdate"].ToString();
                }

                // Load notification settings
                await LoadNotificationSettings();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading user profile: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"LoadUserProfile error: {ex}");
            }
        }

        private async Task LoadUserStats()
        {
            try
            {
                // Get classes count
                var classesSnapshot = await db.Collection("users").Document(currentUserId)
                    .Collection("enrolledClasses").GetSnapshotAsync();
                ltClassesCount.Text = classesSnapshot.Count.ToString();

                // Get posts count (posts created by user)
                var allGroupsSnapshot = await db.Collection("studyHubs").GetSnapshotAsync();
                int postsCount = 0;

                foreach (var groupDoc in allGroupsSnapshot.Documents)
                {
                    var postsSnapshot = await groupDoc.Reference.Collection("posts")
                        .WhereEqualTo("postedBy", currentUserId).GetSnapshotAsync();
                    postsCount += postsSnapshot.Count;
                }
                ltPostsCount.Text = postsCount.ToString();

                // Get total likes received
                int totalLikes = 0;
                foreach (var groupDoc in allGroupsSnapshot.Documents)
                {
                    var userPostsSnapshot = await groupDoc.Reference.Collection("posts")
                        .WhereEqualTo("postedBy", currentUserId).GetSnapshotAsync();

                    foreach (var postDoc in userPostsSnapshot.Documents)
                    {
                        var postData = postDoc.ToDictionary();
                        if (postData.ContainsKey("likes"))
                        {
                            var likes = (List<object>)postData["likes"];
                            totalLikes += likes.Count;
                        }
                    }
                }
                ltLikesCount.Text = totalLikes.ToString();

                // Get saved posts count
                var savedPostsSnapshot = await db.Collection("users").Document(currentUserId)
                    .Collection("savedPosts").GetSnapshotAsync();
                ltSavedCount.Text = savedPostsSnapshot.Count.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserStats error: {ex}");
                // Don't show error to user, just log it
            }
        }

        private async Task LoadUserClasses()
        {
            try
            {
                var classes = new List<dynamic>();
                var enrolledClassesSnapshot = await db.Collection("users").Document(currentUserId)
                    .Collection("enrolledClasses").GetSnapshotAsync();

                foreach (var enrollmentDoc in enrolledClassesSnapshot.Documents)
                {
                    var enrollment = enrollmentDoc.ToDictionary();
                    string classId = enrollment.GetValueOrDefault("classId", "").ToString();

                    if (!string.IsNullOrEmpty(classId))
                    {
                        var classDoc = await db.Collection("classes").Document(classId).GetSnapshotAsync();
                        if (classDoc.Exists)
                        {
                            var classData = classDoc.ToDictionary();

                            // Get student count for this class
                            var studentsSnapshot = await db.Collection("classes").Document(classId)
                                .Collection("students").GetSnapshotAsync();

                            classes.Add(new
                            {
                                classId,
                                className = classData.GetValueOrDefault("className", "Unknown Class").ToString(),
                                teacherName = classData.GetValueOrDefault("teacherName", "Unknown Teacher").ToString(),
                                schedule = classData.GetValueOrDefault("schedule", "Not specified").ToString(),
                                studentCount = studentsSnapshot.Count,
                                enrolledAt = enrollment.ContainsKey("enrolledAt") ?
                                    ((Timestamp)enrollment["enrolledAt"]).ToDateTime().ToString("MMM dd, yyyy") : "Unknown"
                            });
                        }
                    }
                }

                rptClasses.DataSource = classes;
                rptClasses.DataBind();

                pnlNoClasses.Visible = classes.Count == 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserClasses error: {ex}");
                pnlNoClasses.Visible = true;
            }
        }

        private async Task LoadUserActivity()
        {
            try
            {
                await LoadLikedPosts();
                await LoadSavedPosts();
                await LoadSharedPosts();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserActivity error: {ex}");
                pnlNoActivity.Visible = true;
            }
        }

        private async Task LoadLikedPosts()
        {
            try
            {
                var likedPosts = new List<dynamic>();
                var allGroupsSnapshot = await db.Collection("studyHubs").GetSnapshotAsync();

                foreach (var groupDoc in allGroupsSnapshot.Documents)
                {
                    var postsSnapshot = await groupDoc.Reference.Collection("posts")
                        .WhereArrayContains("likes", currentUserId)
                        .OrderByDescending("timestamp")
                        .Limit(10)
                        .GetSnapshotAsync();

                    foreach (var postDoc in postsSnapshot.Documents)
                    {
                        var postData = postDoc.ToDictionary();

                        // Get comment count
                        var commentsSnapshot = await postDoc.Reference.Collection("comments").GetSnapshotAsync();

                        likedPosts.Add(new
                        {
                            postId = postDoc.Id,
                            content = TruncateText(postData.GetValueOrDefault("content", "").ToString(), 150),
                            authorName = postData.GetValueOrDefault("postedByName", "Unknown").ToString(),
                            timestamp = postData.ContainsKey("timestamp") ?
                                ((Timestamp)postData["timestamp"]).ToDateTime().ToString("MMM dd, yyyy") : "",
                            likeCount = postData.ContainsKey("likes") ? ((List<object>)postData["likes"]).Count : 0,
                            commentCount = commentsSnapshot.Count,
                            shareCount = postData.ContainsKey("shares") ? ((List<object>)postData["shares"]).Count : 0
                        });
                    }
                }

                // Sort by timestamp and take top 20
                likedPosts = likedPosts.OrderByDescending(p => p.timestamp).Take(20).ToList();

                rptLikedPosts.DataSource = likedPosts;
                rptLikedPosts.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadLikedPosts error: {ex}");
            }
        }

        private async Task LoadSavedPosts()
        {
            try
            {
                var savedPosts = new List<dynamic>();
                var savedPostsSnapshot = await db.Collection("users").Document(currentUserId)
                    .Collection("savedPosts").OrderByDescending("savedAt").Limit(20).GetSnapshotAsync();

                foreach (var savedDoc in savedPostsSnapshot.Documents)
                {
                    var savedData = savedDoc.ToDictionary();
                    string postId = savedData.GetValueOrDefault("postId", "").ToString();
                    string groupId = savedData.GetValueOrDefault("groupId", "").ToString();

                    if (!string.IsNullOrEmpty(postId) && !string.IsNullOrEmpty(groupId))
                    {
                        var postDoc = await db.Collection("studyHubs").Document(groupId)
                            .Collection("posts").Document(postId).GetSnapshotAsync();

                        if (postDoc.Exists)
                        {
                            var postData = postDoc.ToDictionary();

                            // Get comment count
                            var commentsSnapshot = await postDoc.Reference.Collection("comments").GetSnapshotAsync();

                            savedPosts.Add(new
                            {
                                postId,
                                content = TruncateText(postData.GetValueOrDefault("content", "").ToString(), 150),
                                authorName = postData.GetValueOrDefault("postedByName", "Unknown").ToString(),
                                timestamp = postData.ContainsKey("timestamp") ?
                                    ((Timestamp)postData["timestamp"]).ToDateTime().ToString("MMM dd, yyyy") : "",
                                likeCount = postData.ContainsKey("likes") ? ((List<object>)postData["likes"]).Count : 0,
                                commentCount = commentsSnapshot.Count,
                                shareCount = postData.ContainsKey("shares") ? ((List<object>)postData["shares"]).Count : 0
                            });
                        }
                    }
                }

                rptSavedPosts.DataSource = savedPosts;
                rptSavedPosts.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadSavedPosts error: {ex}");
            }
        }

        private async Task LoadSharedPosts()
        {
            try
            {
                var sharedPosts = new List<dynamic>();
                var timelineSnapshot = await db.Collection("users").Document(currentUserId)
                    .Collection("timeline").WhereEqualTo("type", "share")
                    .OrderByDescending("sharedAt").Limit(20).GetSnapshotAsync();

                foreach (var timelineDoc in timelineSnapshot.Documents)
                {
                    var timelineData = timelineDoc.ToDictionary();
                    string originalPostId = timelineData.GetValueOrDefault("originalPostId", "").ToString();
                    string originalGroupId = timelineData.GetValueOrDefault("originalGroupId", "").ToString();

                    if (!string.IsNullOrEmpty(originalPostId) && !string.IsNullOrEmpty(originalGroupId))
                    {
                        var postDoc = await db.Collection("studyHubs").Document(originalGroupId)
                            .Collection("posts").Document(originalPostId).GetSnapshotAsync();

                        if (postDoc.Exists)
                        {
                            var postData = postDoc.ToDictionary();

                            // Get comment count
                            var commentsSnapshot = await postDoc.Reference.Collection("comments").GetSnapshotAsync();

                            sharedPosts.Add(new
                            {
                                postId = originalPostId,
                                content = TruncateText(postData.GetValueOrDefault("content", "").ToString(), 150),
                                authorName = postData.GetValueOrDefault("postedByName", "Unknown").ToString(),
                                timestamp = timelineData.ContainsKey("sharedAt") ?
                                    ((Timestamp)timelineData["sharedAt"]).ToDateTime().ToString("MMM dd, yyyy") : "",
                                likeCount = postData.ContainsKey("likes") ? ((List<object>)postData["likes"]).Count : 0,
                                commentCount = commentsSnapshot.Count,
                                shareCount = postData.ContainsKey("shares") ? ((List<object>)postData["shares"]).Count : 0
                            });
                        }
                    }
                }

                rptSharedPosts.DataSource = sharedPosts;
                rptSharedPosts.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadSharedPosts error: {ex}");
            }
        }

        private async Task LoadNotificationSettings()
        {
            try
            {
                var settingsRef = db.Collection("users").Document(currentUserId).Collection("settings").Document("notifications");
                var settingsSnap = await settingsRef.GetSnapshotAsync();

                if (settingsSnap.Exists)
                {
                    var settings = settingsSnap.ToDictionary();
                    chkEmailNotifications.Checked = Convert.ToBoolean(settings.GetValueOrDefault("emailNotifications", true));
                    chkStudyHubNotifications.Checked = Convert.ToBoolean(settings.GetValueOrDefault("studyHubNotifications", true));
                    chkClassNotifications.Checked = Convert.ToBoolean(settings.GetValueOrDefault("classNotifications", true));
                }
                else
                {
                    // Default settings
                    chkEmailNotifications.Checked = true;
                    chkStudyHubNotifications.Checked = true;
                    chkClassNotifications.Checked = true;
                }

                // Load privacy settings
                var privacyRef = db.Collection("users").Document(currentUserId).Collection("settings").Document("privacy");
                var privacySnap = await privacyRef.GetSnapshotAsync();

                if (privacySnap.Exists)
                {
                    var privacy = privacySnap.ToDictionary();
                    chkPublicProfile.Checked = Convert.ToBoolean(privacy.GetValueOrDefault("publicProfile", true));
                    chkShowActivity.Checked = Convert.ToBoolean(privacy.GetValueOrDefault("showActivity", true));
                }
                else
                {
                    // Default privacy settings
                    chkPublicProfile.Checked = true;
                    chkShowActivity.Checked = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadNotificationSettings error: {ex}");
            }
        }

        protected async void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            try
            {
                // Check if this is a reset request
                string eventArgument = Request["__EVENTARGUMENT"];
                if (eventArgument == "reset")
                {
                    await LoadUserProfile();
                    ShowMessage("Form has been reset to original values.", "info");
                    return;
                }

                // Validate required fields
                if (string.IsNullOrWhiteSpace(txtFirstName.Text) || string.IsNullOrWhiteSpace(txtLastName.Text))
                {
                    ShowMessage("First name and last name are required.", "warning");
                    return;
                }

                // Validate phone number if provided
                string phone = txtPhone.Text.Trim();
                if (!string.IsNullOrEmpty(phone) && (phone.Length < 6 || !phone.All(char.IsDigit)))
                {
                    ShowMessage("Please enter a valid phone number (digits only, at least 6 characters).", "warning");
                    return;
                }

                // Update user profile
                var updateData = new Dictionary<string, object>
                {
                    { "firstName", txtFirstName.Text.Trim() },
                    { "lastName", txtLastName.Text.Trim() },
                    { "phone", phone },
                    { "gender", ddlGender.SelectedValue },
                    { "birthdate", txtBirthdate.Text.Trim() },
                    { "address", txtAddress.Text.Trim() },
                    { "lastUpdated", Timestamp.GetCurrentTimestamp() }
                };

                var userRef = db.Collection("users").Document(currentUserId);
                await userRef.UpdateAsync(updateData);

                // Update profile header display
                ltProfileName.Text = $"{txtFirstName.Text.Trim()} {txtLastName.Text.Trim()}";

                ShowMessage("Profile updated successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating profile: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Profile update error: {ex}");
            }
        }

        protected async void btnUploadPhoto_Click(object sender, EventArgs e)
        {
            try
            {
                if (!fileProfilePicture.HasFile)
                {
                    ShowMessage("Please select an image file.", "warning");
                    return;
                }

                var file = fileProfilePicture.PostedFile;

                // Validate file type
                if (!file.ContentType.StartsWith("image/"))
                {
                    ShowMessage("Please select a valid image file.", "warning");
                    return;
                }

                // Validate file size (max 5MB)
                if (file.ContentLength > 5 * 1024 * 1024)
                {
                    ShowMessage("Image file size should not exceed 5MB.", "warning");
                    return;
                }

                // Upload to Cloudinary
                string imageUrl = await UploadImageToCloudinary(file);

                if (!string.IsNullOrEmpty(imageUrl))
                {
                    // Update user profile image URL in Firestore
                    var userRef = db.Collection("users").Document(currentUserId);
                    await userRef.UpdateAsync("profileImageUrl", imageUrl);

                    // Update UI
                    imgProfile.ImageUrl = imageUrl;

                    ShowMessage("Profile picture updated successfully!", "success");
                }
                else
                {
                    ShowMessage("Failed to upload image. Please try again.", "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error uploading profile picture: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Profile picture upload error: {ex}");
            }
        }

        private async Task<string> UploadImageToCloudinary(System.Web.HttpPostedFile file)
        {
            try
            {
                string cloudName = ConfigurationManager.AppSettings["CloudinaryCloudName"];
                string apiKey = ConfigurationManager.AppSettings["CloudinaryApiKey"];
                string apiSecret = ConfigurationManager.AppSettings["CloudinaryApiSecret"];

                if (string.IsNullOrEmpty(cloudName) || string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(apiSecret))
                {
                    System.Diagnostics.Debug.WriteLine("Cloudinary configuration is missing");
                    return "";
                }

                var account = new Account(cloudName, apiKey, apiSecret);
                var cloudinary = new Cloudinary(account);

                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(file.FileName, file.InputStream),
                    Folder = "profile_pictures",
                    PublicId = $"profile_{currentUserId}_{DateTime.Now.Ticks}",
                    Transformation = new Transformation().Width(200).Height(200).Crop("fill").Quality("auto").FetchFormat("auto"),
                    Overwrite = true
                };

                var uploadResult = await cloudinary.UploadAsync(uploadParams);

                if (uploadResult.StatusCode == System.Net.HttpStatusCode.OK)
                {
                    return uploadResult.SecureUrl.ToString();
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"Cloudinary upload failed: {uploadResult.Error?.Message}");
                    return "";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Cloudinary upload error: {ex}");
                return "";
            }
        }

        protected async void btnChangePassword_Click(object sender, EventArgs e)
        {
            try
            {
                string currentPassword = txtCurrentPassword.Text.Trim();
                string newPassword = txtNewPassword.Text.Trim();
                string confirmPassword = txtConfirmPassword.Text.Trim();

                // Validate inputs
                if (string.IsNullOrEmpty(currentPassword) || string.IsNullOrEmpty(newPassword) || string.IsNullOrEmpty(confirmPassword))
                {
                    ShowMessage("All password fields are required.", "warning");
                    return;
                }

                if (newPassword != confirmPassword)
                {
                    ShowMessage("New passwords do not match.", "warning");
                    return;
                }

                // Validate new password strength
                if (newPassword.Length < 8 ||
                    !newPassword.Any(char.IsUpper) ||
                    !newPassword.Any(char.IsLower) ||
                    !newPassword.Any(char.IsDigit) ||
                    !newPassword.Any(ch => !char.IsLetterOrDigit(ch)))
                {
                    ShowMessage("New password must be at least 8 characters and contain uppercase, lowercase, number, and special character.", "warning");
                    return;
                }

                // Get current user data
                var userRef = db.Collection("users").Document(currentUserId);
                var userSnap = await userRef.GetSnapshotAsync();

                if (!userSnap.Exists)
                {
                    ShowMessage("User not found.", "danger");
                    return;
                }

                var userData = userSnap.ToDictionary();
                string storedPassword = userData.GetValueOrDefault("password", "").ToString();

                // Verify current password (In production, use proper password hashing)
                if (currentPassword != storedPassword)
                {
                    ShowMessage("Current password is incorrect.", "warning");
                    return;
                }

                // Update password (In production, hash the password before storing)
                await userRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "password", newPassword },
                    { "passwordLastChanged", Timestamp.GetCurrentTimestamp() }
                });

                // Clear password fields
                txtCurrentPassword.Text = "";
                txtNewPassword.Text = "";
                txtConfirmPassword.Text = "";

                ShowMessage("Password changed successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error changing password: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Password change error: {ex}");
            }
        }

        protected async void btnSaveNotifications_Click(object sender, EventArgs e)
        {
            try
            {
                var settingsRef = db.Collection("users").Document(currentUserId)
                    .Collection("settings").Document("notifications");

                var notificationSettings = new Dictionary<string, object>
                {
                    { "emailNotifications", chkEmailNotifications.Checked },
                    { "studyHubNotifications", chkStudyHubNotifications.Checked },
                    { "classNotifications", chkClassNotifications.Checked },
                    { "lastUpdated", Timestamp.GetCurrentTimestamp() }
                };

                await settingsRef.SetAsync(notificationSettings);

                ShowMessage("Notification preferences saved successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving notification preferences: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Save notifications error: {ex}");
            }
        }

        protected async void btnSavePrivacy_Click(object sender, EventArgs e)
        {
            try
            {
                var privacyRef = db.Collection("users").Document(currentUserId)
                    .Collection("settings").Document("privacy");

                var privacySettings = new Dictionary<string, object>
                {
                    { "publicProfile", chkPublicProfile.Checked },
                    { "showActivity", chkShowActivity.Checked },
                    { "lastUpdated", Timestamp.GetCurrentTimestamp() }
                };

                await privacyRef.SetAsync(privacySettings);

                ShowMessage("Privacy settings saved successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving privacy settings: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Save privacy error: {ex}");
            }
        }

        protected async void btnDeactivateAccount_Click(object sender, EventArgs e)
        {
            try
            {
                var userRef = db.Collection("users").Document(currentUserId);

                // Mark account as deactivated instead of deleting
                await userRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "isActive", false },
                    { "deactivatedAt", Timestamp.GetCurrentTimestamp() },
                    { "deactivatedBy", currentUserId },
                    { "status", "deactivated" }
                });

                // Log the deactivation
                var activityRef = db.Collection("users").Document(currentUserId)
                    .Collection("activities").Document();

                await activityRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", "account_deactivated" },
                    { "description", "Account deactivated by user" },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "userId", currentUserId }
                });

                // Clear session and redirect
                Session.Clear();
                Session.Abandon();

                ShowMessage("Account deactivated successfully. You will be redirected to the login page.", "info");

                // Redirect after a short delay
                string script = @"
                    setTimeout(function() {
                        window.location.href = 'Login.aspx?deactivated=true';
                    }, 3000);
                ";
                ScriptManager.RegisterStartupScript(this, GetType(), "redirectAfterDeactivation", script, true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error deactivating account: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Account deactivation error: {ex}");
            }
        }

        private string TruncateText(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text) || text.Length <= maxLength)
                return text;

            return text.Substring(0, maxLength) + "...";
        }

        private void ShowMessage(string message, string type)
        {
            string script = $@"
                showNotification('{message.Replace("'", "\\'")}', '{type}');
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "showMessage", script, true);
        }

        // Helper method for checking if activity has data
        protected bool HasActivityData()
        {
            return rptLikedPosts.Items.Count > 0 || rptSavedPosts.Items.Count > 0 || rptSharedPosts.Items.Count > 0;
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            // Set visibility of no activity panel based on data
            pnlNoActivity.Visible = !HasActivityData();

            // Add any additional client-side scripts needed
            string script = @"
                // Additional client-side functionality can be added here
                console.log('Profile page loaded successfully');
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "profilePageReady", script, true);
        }
    }
}