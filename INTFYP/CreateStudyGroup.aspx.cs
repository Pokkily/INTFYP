using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using System.Web.Configuration;
using System.Web.UI;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using System.Linq;

namespace YourProjectNamespace
{
    public partial class CreateStudyGroup : System.Web.UI.Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        protected string currentUsername;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["username"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            currentUserId = Session["userId"].ToString();
            currentUsername = Session["username"].ToString();
            db = FirestoreDb.Create("intorannetto");

            if (!IsPostBack)
            {
                InitializePage();
            }
        }

        private void InitializePage()
        {
            // Set default values
            txtCapacity.Text = "10";
            chkPublic.Checked = true;
            chkAllowInvites.Checked = true;
            chkResourceSharing.Checked = true;

            // Clear any previous messages
            pnlMessage.Visible = false;
        }

        protected async void btnCreate_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields
                if (!ValidateForm())
                    return;

                // Prepare group data
                string groupName = txtGroupName.Text.Trim();
                string subject = ddlSubject.SelectedValue;
                int capacity = int.Parse(txtCapacity.Text.Trim());
                string description = txtDescription.Text.Trim();
                string imageUrl = "";

                // Upload image if provided
                if (fileGroupImage.HasFile)
                {
                    imageUrl = await UploadImageToCloudinary();
                    if (string.IsNullOrEmpty(imageUrl))
                    {
                        ShowMessage("Image upload failed. Please try again.", "danger");
                        return;
                    }
                }

                // Parse tags
                List<string> tags = ParseTags(hfTags.Value);

                // Parse study methods
                List<string> studyMethods = GetStudyMethods();

                // Create group document
                DocumentReference docRef = db.Collection("studyHubs").Document();
                string groupId = docRef.Id;

                Dictionary<string, object> groupData = new Dictionary<string, object>
                {
                    { "groupName", groupName },
                    { "subject", subject },
                    { "capacity", capacity },
                    { "description", description },
                    { "hosterId", currentUserId },
                    { "hosterName", currentUsername },
                    { "members", new List<string> { currentUserId } },
                    { "groupImage", !string.IsNullOrEmpty(imageUrl) ? imageUrl : GetDefaultGroupImage(subject) },
                    { "tags", tags },
                    { "studyMethods", studyMethods },
                    { "createdAt", Timestamp.GetCurrentTimestamp() },
                    { "lastActivity", Timestamp.GetCurrentTimestamp() },
                    
                    // Privacy and settings
                    { "isPublic", chkPublic.Checked },
                    { "requireApproval", chkRequireApproval.Checked },
                    { "allowInvites", chkAllowInvites.Checked },
                    
                    // Meeting information
                    { "meetingFrequency", ddlMeetingFrequency.SelectedValue },
                    { "meetingTime", txtMeetingTime.Text.Trim() },
                    
                    // Statistics
                    { "totalPosts", 0 },
                    { "totalComments", 0 },
                    { "activeMembers", 1 },
                    
                    // Status
                    { "isActive", true },
                    { "isArchived", false }
                };

                await docRef.SetAsync(groupData);

                // Create initial group settings subcollection
                await CreateGroupSettings(groupId);

                // Create welcome post
                await CreateWelcomePost(groupId);

                // Log group creation activity
                await LogGroupActivity(groupId, "group_created", $"Study group '{groupName}' was created");

                // Create notification for user
                await CreateUserNotification("group_created", $"Your study group '{groupName}' has been created successfully!");

                // Clear localStorage draft
                string clearDraftScript = "localStorage.removeItem('studyGroupDraft');";
                ScriptManager.RegisterStartupScript(this, GetType(), "clearDraft", clearDraftScript, true);

                ShowMessage("Study group created successfully! You will be redirected to your new group.", "success");

                // Redirect to the new group after a short delay
                string redirectScript = $"setTimeout(function() {{ window.location.href = 'StudyHubGroup.aspx?groupId={groupId}'; }}, 2000);";
                ScriptManager.RegisterStartupScript(this, GetType(), "redirect", redirectScript, true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating study group: " + ex.Message, "danger");
                LogError("CreateStudyGroup_btnCreate", ex);
            }
        }

        private bool ValidateForm()
        {
            List<string> errors = new List<string>();

            // Validate group name
            if (string.IsNullOrWhiteSpace(txtGroupName.Text))
                errors.Add("Group name is required.");
            else if (txtGroupName.Text.Trim().Length < 3)
                errors.Add("Group name must be at least 3 characters long.");
            else if (txtGroupName.Text.Trim().Length > 100)
                errors.Add("Group name must be less than 100 characters.");

            // Validate subject
            if (string.IsNullOrEmpty(ddlSubject.SelectedValue))
                errors.Add("Please select a subject.");

            // Validate capacity
            if (string.IsNullOrWhiteSpace(txtCapacity.Text))
                errors.Add("Group capacity is required.");
            else
            {
                if (!int.TryParse(txtCapacity.Text, out int capacity))
                    errors.Add("Group capacity must be a valid number.");
                else if (capacity < 2)
                    errors.Add("Group capacity must be at least 2 members.");
                else if (capacity > 100)
                    errors.Add("Group capacity cannot exceed 100 members.");
            }

            // Validate description
            if (string.IsNullOrWhiteSpace(txtDescription.Text))
                errors.Add("Group description is required.");
            else if (txtDescription.Text.Trim().Length < 10)
                errors.Add("Group description must be at least 10 characters long.");
            else if (txtDescription.Text.Trim().Length > 500)
                errors.Add("Group description must be less than 500 characters.");

            // Validate file upload if present
            if (fileGroupImage.HasFile)
            {
                string fileExtension = Path.GetExtension(fileGroupImage.FileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

                if (!allowedExtensions.Contains(fileExtension))
                    errors.Add("Only JPG, JPEG, PNG, and GIF image files are allowed.");

                if (fileGroupImage.PostedFile.ContentLength > 5 * 1024 * 1024) // 5MB
                    errors.Add("Image file size must be less than 5MB.");
            }

            // Validate tags
            if (!string.IsNullOrEmpty(hfTags.Value))
            {
                var tags = ParseTags(hfTags.Value);
                if (tags.Count > 10)
                    errors.Add("Maximum 10 tags are allowed.");

                foreach (var tag in tags)
                {
                    if (tag.Length > 20)
                        errors.Add("Each tag must be less than 20 characters.");
                }
            }

            if (errors.Any())
            {
                ShowMessage(string.Join("<br/>", errors), "danger");
                return false;
            }

            return true;
        }

        private async Task<string> UploadImageToCloudinary()
        {
            try
            {
                var account = new Account(
                    WebConfigurationManager.AppSettings["CloudinaryCloudName"],
                    WebConfigurationManager.AppSettings["CloudinaryApiKey"],
                    WebConfigurationManager.AppSettings["CloudinaryApiSecret"]
                );
                var cloudinary = new Cloudinary(account);

                using (Stream fileStream = fileGroupImage.PostedFile.InputStream)
                {
                    var uploadParams = new ImageUploadParams()
                    {
                        File = new FileDescription(fileGroupImage.FileName, fileStream),
                        Folder = "studyhub_groups",
                        Transformation = new Transformation()
                            .Width(800)
                            .Height(600)
                            .Crop("fill")
                            .Quality("auto")
                            .FetchFormat("auto"),
                        PublicId = $"group_{currentUserId}_{DateTime.Now.Ticks}"
                    };

                    var uploadResult = await cloudinary.UploadAsync(uploadParams);

                    if (uploadResult.StatusCode == System.Net.HttpStatusCode.OK)
                        return uploadResult.SecureUrl.ToString();
                    else
                        return "";
                }
            }
            catch (Exception ex)
            {
                LogError("UploadImageToCloudinary", ex);
                return "";
            }
        }

        private string GetDefaultGroupImage(string subject)
        {
            // Return default images based on subject
            var defaultImages = new Dictionary<string, string>
    {
        { "Mathematics", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/math.jpg" },
        { "Science", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/science.jpg" },
        { "Programming", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/programming.jpg" },
        { "Languages", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/languages.jpg" },
        { "History", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/history.jpg" },
        { "Business", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/business.jpg" },
        { "Arts", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/arts.jpg" },
        { "Medicine", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/medicine.jpg" },
        { "Engineering", "https://res.cloudinary.com/your-cloud/image/upload/v1/defaults/engineering.jpg" }
    };

            // .NET Framework compatible way to get value or default
            string result;
            return defaultImages.TryGetValue(subject, out result) ? result : "Images/default-group.jpg";
        }

        private List<string> ParseTags(string tagsString)
        {
            if (string.IsNullOrEmpty(tagsString))
                return new List<string>();

            return tagsString.Split(',')
                .Where(tag => !string.IsNullOrWhiteSpace(tag))
                .Select(tag => tag.Trim().ToLower())
                .Distinct()
                .Take(10)
                .ToList();
        }

        private List<string> GetStudyMethods()
        {
            var methods = new List<string>();

            if (chkOnlineStudy.Checked) methods.Add("online_sessions");
            if (chkInPersonStudy.Checked) methods.Add("in_person_meetings");
            if (chkResourceSharing.Checked) methods.Add("resource_sharing");
            if (chkPeerTutoring.Checked) methods.Add("peer_tutoring");

            return methods;
        }

        private async Task CreateGroupSettings(string groupId)
        {
            try
            {
                var settingsRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("settings").Document("general");

                var settingsData = new Dictionary<string, object>
                {
                    { "allowAnonymousPosts", false },
                    { "allowAnonymousComments", false },
                    { "moderationEnabled", false },
                    { "autoApproveJoinRequests", !chkRequireApproval.Checked },
                    { "allowFileUploads", true },
                    { "maxFileSize", 10 }, // MB
                    { "allowedFileTypes", new List<string> { "jpg", "jpeg", "png", "gif", "pdf", "doc", "docx" } },
                    { "enableNotifications", true },
                    { "enableEmailNotifications", false },
                    { "createdAt", Timestamp.GetCurrentTimestamp() }
                };

                await settingsRef.SetAsync(settingsData);
            }
            catch (Exception ex)
            {
                LogError("CreateGroupSettings", ex);
            }
        }

        private async Task CreateWelcomePost(string groupId)
        {
            try
            {
                var postRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document();

                var welcomeMessage = $@"🎉 Welcome to {txtGroupName.Text.Trim()}!

Hi everyone! I'm excited to start this study group focused on {ddlSubject.SelectedItem.Text}. 

📚 What we'll be doing:
{txtDescription.Text.Trim()}

🤝 Let's introduce ourselves and share:
• What you're hoping to learn or achieve
• Your current level of experience
• How you prefer to study
• Any specific topics you'd like to focus on

Feel free to ask questions, share resources, and help each other succeed! 

Happy studying! 🚀";

                var postData = new Dictionary<string, object>
                {
                    { "content", welcomeMessage },
                    { "postedBy", currentUserId },
                    { "postedByName", currentUsername },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "likes", new List<string>() },
                    { "saves", new List<string>() },
                    { "shares", new List<string>() },
                    { "reports", new List<string>() },
                    { "isWelcomePost", true },
                    { "isPinned", true }
                };

                await postRef.SetAsync(postData);
            }
            catch (Exception ex)
            {
                LogError("CreateWelcomePost", ex);
            }
        }

        private async Task LogGroupActivity(string groupId, string activityType, string description)
        {
            try
            {
                var activityRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("activities").Document();

                await activityRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", activityType },
                    { "description", description },
                    { "userId", currentUserId },
                    { "username", currentUsername },
                    { "timestamp", Timestamp.GetCurrentTimestamp() }
                });
            }
            catch (Exception ex)
            {
                LogError("LogGroupActivity", ex);
            }
        }

        private async Task CreateUserNotification(string type, string message)
        {
            try
            {
                var notificationRef = db.Collection("users").Document(currentUserId)
                    .Collection("notifications").Document();

                await notificationRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", type },
                    { "message", message },
                    { "isRead", false },
                    { "timestamp", Timestamp.GetCurrentTimestamp() }
                });
            }
            catch (Exception ex)
            {
                LogError("CreateUserNotification", ex);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("StudyHub.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowMessage(string message, string type)
        {
            string alertClass = type == "success" ? "alert-success" :
                               type == "warning" ? "alert-warning" :
                               "alert-danger";

            string icon = type == "success" ? "✅" :
                         type == "warning" ? "⚠️" :
                         "❌";

            ltMessage.Text = $@"
                <div class='alert {alertClass}'>
                    <span>{icon}</span>
                    {message}
                </div>";

            pnlMessage.Visible = true;

            // Auto-hide success messages
            if (type == "success")
            {
                string script = @"
                    setTimeout(function() {
                        var messagePanel = document.getElementById('" + pnlMessage.ClientID + @"');
                        if (messagePanel) {
                            messagePanel.style.transition = 'opacity 0.5s ease';
                            messagePanel.style.opacity = '0';
                            setTimeout(function() {
                                messagePanel.style.display = 'none';
                            }, 500);
                        }
                    }, 3000);
                ";
                ScriptManager.RegisterStartupScript(this, GetType(), "hideMessage", script, true);
            }
        }

        private void LogError(string method, Exception ex)
        {
            try
            {
                // Log to Firestore errors collection
                var errorRef = db.Collection("errors").Document();

                var errorData = new Dictionary<string, object>
                {
                    { "method", method },
                    { "message", ex.Message },
                    { "stackTrace", ex.StackTrace },
                    { "userId", currentUserId },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "page", "CreateStudyGroup" }
                };

                _ = errorRef.SetAsync(errorData); // Fire and forget
            }
            catch
            {
                // If logging fails, don't throw another exception
            }
        }

        // Helper method to check if user has reached group creation limit
        private async Task<bool> CheckGroupCreationLimit()
        {
            try
            {
                // Check if user has created too many groups in the last 24 hours
                var yesterday = Timestamp.FromDateTime(DateTime.UtcNow.AddDays(-1));

                var recentGroupsQuery = db.Collection("studyHubs")
                    .WhereEqualTo("hosterId", currentUserId)
                    .WhereGreaterThan("createdAt", yesterday);

                var recentGroupsSnapshot = await recentGroupsQuery.GetSnapshotAsync();

                // Allow up to 3 groups per day
                return recentGroupsSnapshot.Count < 3;
            }
            catch
            {
                return true; // Allow if check fails
            }
        }

        // Helper method to check for inappropriate content
        private bool CheckContentPolicy(string text)
        {
            // Basic content filtering - in production, use a proper content moderation service
            var bannedWords = new List<string> { /* add banned words */ };
            var lowerText = text.ToLower();

            return !bannedWords.Any(word => lowerText.Contains(word));
        }

        // Override Page_PreRender to add additional client-side functionality
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            // Add client-side validation scripts
            string validationScript = @"
                // Additional client-side validation can be added here
                window.addEventListener('beforeunload', function(e) {
                    // Warn user about unsaved changes
                    var hasContent = document.getElementById('" + txtGroupName.ClientID + @"').value.trim() ||
                                   document.getElementById('" + txtDescription.ClientID + @"').value.trim();
                    
                    if (hasContent && !window.formSubmitted) {
                        e.preventDefault();
                        e.returnValue = '';
                    }
                });
                
                // Mark form as submitted when create button is clicked
                document.getElementById('" + btnCreate.ClientID + @"').addEventListener('click', function() {
                    window.formSubmitted = true;
                });
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "validation", validationScript, true);
        }
    }
}