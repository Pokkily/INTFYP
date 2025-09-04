using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;

namespace YourProjectNamespace
{
    public partial class Feedback : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private Dictionary<string, bool> commentBoxStates = new Dictionary<string, bool>();
        private string currentUserEmail;
        private string currentUserName;
        private string currentUserId;

        protected async void Page_Load(object sender, EventArgs e)
        {
            // Check authentication first
            currentUserEmail = Session["email"]?.ToString();
            currentUserName = Session["username"]?.ToString() ?? "Anonymous";
            currentUserId = Session["userId"]?.ToString();

            if (string.IsNullOrEmpty(currentUserEmail) || string.IsNullOrEmpty(currentUserId))
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                InitializeFirestore();

                // Set username for feedback form from session
                txtFeedbackUsername.Text = currentUserName;

                await LoadAllFeedbacks();
            }
        }

        private void InitializeFirestore()
        {
            try
            {
                if (db == null)
                {
                    string path = Server.MapPath("~/serviceAccountKey.json");
                    Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                    db = FirestoreDb.Create("intorannetto");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error initializing database: " + ex.Message, "text-danger");
            }
        }

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            // Clear any previous messages
            lblMessage.Visible = false;
            lblMessage.Text = "";

            // Double-check authentication
            if (string.IsNullOrEmpty(currentUserId))
            {
                ShowMessage("Please login to submit feedback.", "alert alert-danger");
                return;
            }

            // Server-side validation (backup to client-side)
            if (!Page.IsValid)
            {
                lblMessage.Text = "Please correct the validation errors above.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            // Additional server-side validation
            List<string> validationErrors = new List<string>();

            // Validate Username
            if (string.IsNullOrWhiteSpace(txtFeedbackUsername.Text))
            {
                validationErrors.Add("Username is required.");
            }

            // Validate Description
            if (string.IsNullOrWhiteSpace(txtDescription.Text))
            {
                validationErrors.Add("Description is required.");
            }
            else if (txtDescription.Text.Trim().Length > 1000)
            {
                validationErrors.Add("Description cannot exceed 1000 characters.");
            }

            // Validate File Upload
            if (!fileUpload.HasFile)
            {
                validationErrors.Add("Please select a file to upload.");
            }
            else
            {
                // Validate file size (10MB limit)
                if (fileUpload.PostedFile.ContentLength > 10 * 1024 * 1024)
                {
                    validationErrors.Add("File size must be less than 10MB.");
                }

                // Validate file type
                string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".mp4", ".avi" };

                if (!allowedExtensions.Contains(fileExtension))
                {
                    validationErrors.Add("Invalid file type. Please upload JPG, PNG, GIF, MP4, or AVI files only.");
                }

                // Validate content type for additional security
                string[] allowedContentTypes = {
                    "image/jpeg", "image/jpg", "image/png", "image/gif",
                    "video/mp4", "video/avi", "video/x-msvideo"
                };

                if (!allowedContentTypes.Contains(fileUpload.PostedFile.ContentType.ToLower()))
                {
                    validationErrors.Add("Invalid file content type.");
                }

                // Additional security: Check for potentially malicious files
                if (IsDisallowedFileType(fileUpload.FileName))
                {
                    validationErrors.Add("File type not allowed for security reasons.");
                }
            }

            // If there are validation errors, display them
            if (validationErrors.Count > 0)
            {
                lblMessage.Text = "<strong>Please correct the following errors:</strong><br/>" +
                                 string.Join("<br/>", validationErrors.Select(e => "• " + e));
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            try
            {
                // Upload file (now guaranteed to exist due to validation)
                string mediaUrl = await UploadFileIfAny();

                if (string.IsNullOrEmpty(mediaUrl))
                {
                    ShowMessage("Error uploading file. Please try again.", "alert alert-danger");
                    return;
                }

                // Create feedback object
                var feedback = new
                {
                    userId = currentUserId,
                    username = currentUserName,
                    email = currentUserEmail,
                    description = txtDescription.Text.Trim(),
                    mediaUrl = mediaUrl,
                    likes = new string[] { },
                    comments = new List<object>(),
                    createdAt = Timestamp.GetCurrentTimestamp()
                };

                // Save to database
                await db.Collection("feedbacks").AddAsync(feedback);

                // Success message
                ShowMessage("Feedback submitted successfully!", "alert alert-success");

                // Clear form
                txtDescription.Text = "";
                // Don't clear username as it's readonly

                // Close modal after success (using client script)
                ScriptManager.RegisterStartupScript(this, GetType(), "CloseModal",
                    "setTimeout(function(){ $('#feedbackModal').modal('hide'); }, 1500);", true);

                // Refresh the feedback list
                await LoadAllFeedbacks();
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred while submitting feedback: " + ex.Message, "alert alert-danger");
            }
        }

        private bool IsDisallowedFileType(string fileName)
        {
            // List of disallowed extensions for security
            string[] disallowedExtensions = {
                ".exe", ".bat", ".cmd", ".com", ".pif", ".scr", ".vbs", ".js",
                ".jar", ".asp", ".aspx", ".php", ".jsp", ".cfm", ".pl", ".py",
                ".rb", ".sh", ".ps1", ".msi", ".dll", ".zip", ".rar", ".7z"
            };

            string extension = Path.GetExtension(fileName).ToLower();
            return disallowedExtensions.Contains(extension);
        }

        private async Task<string> UploadFileIfAny()
        {
            if (!fileUpload.HasFile) return null;

            try
            {
                var account = new Account(
                    System.Configuration.ConfigurationManager.AppSettings["CloudinaryCloudName"],
                    System.Configuration.ConfigurationManager.AppSettings["CloudinaryApiKey"],
                    System.Configuration.ConfigurationManager.AppSettings["CloudinaryApiSecret"]
                );

                var cloudinary = new Cloudinary(account);

                using (var stream = fileUpload.PostedFile.InputStream)
                {
                    string ext = Path.GetExtension(fileUpload.FileName).ToLower();

                    // Upload images
                    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif")
                    {
                        var uploadParams = new ImageUploadParams
                        {
                            File = new FileDescription(fileUpload.FileName, stream),
                            Folder = "feedback_images",
                            Transformation = new Transformation()
                                .Quality("auto")
                                .FetchFormat("auto")
                        };
                        var uploadResult = cloudinary.Upload(uploadParams);

                        if (uploadResult.StatusCode == System.Net.HttpStatusCode.OK)
                        {
                            return uploadResult.SecureUrl?.ToString();
                        }
                    }
                    // Upload videos
                    else if (ext == ".mp4" || ext == ".mov" || ext == ".avi" || ext == ".webm")
                    {
                        var uploadParams = new VideoUploadParams
                        {
                            File = new FileDescription(fileUpload.FileName, stream),
                            Folder = "feedback_videos"
                        };
                        var uploadResult = cloudinary.Upload(uploadParams);

                        if (uploadResult.StatusCode == System.Net.HttpStatusCode.OK)
                        {
                            return uploadResult.SecureUrl?.ToString();
                        }
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                ShowMessage("Error uploading file: " + ex.Message, "alert alert-danger");
                return null;
            }
        }

        private async Task LoadAllFeedbacks()
        {
            try
            {
                var feedbacks = new List<dynamic>();

                QuerySnapshot snapshot = await db.Collection("feedbacks").OrderByDescending("createdAt").GetSnapshotAsync();

                foreach (var doc in snapshot.Documents)
                {
                    var data = doc.ToDictionary();
                    var likesList = data.ContainsKey("likes") ? (data["likes"] as IEnumerable<object>)?.ToList() : new List<object>();

                    // Load comments for this feedback post
                    var commentsSnapshot = await db.Collection("feedbacks").Document(doc.Id).Collection("comments").OrderBy("createdAt").GetSnapshotAsync();

                    var comments = commentsSnapshot.Documents.Select(c =>
                    {
                        var cData = c.ToDictionary();
                        return new
                        {
                            username = cData.GetValueOrDefault("username", "Anonymous").ToString(),
                            text = cData.GetValueOrDefault("text", "").ToString(),
                            createdAt = cData.ContainsKey("createdAt") ? ((Timestamp)cData["createdAt"]).ToDateTime() : DateTime.Now
                        };
                    }).ToList();

                    feedbacks.Add(new
                    {
                        PostId = doc.Id,
                        Username = data["username"]?.ToString(),
                        Description = data["description"]?.ToString(),
                        MediaUrl = data.ContainsKey("mediaUrl") ? data["mediaUrl"]?.ToString() : null,
                        Likes = likesList?.Count ?? 0,
                        CreatedAt = data.ContainsKey("createdAt")
                            ? ((Timestamp)data["createdAt"]).ToDateTime()
                            : DateTime.Now,
                        Comments = comments,
                        IsLiked = !string.IsNullOrEmpty(currentUserId) && likesList != null && likesList.Contains(currentUserId)
                    });
                }

                rptFeedback.DataSource = feedbacks;
                rptFeedback.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading feedbacks: " + ex.Message, "alert alert-danger");
            }
        }

        protected void rptFeedback_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var feedback = (dynamic)e.Item.DataItem;

                // Handle the modal comments repeater
                var rptCommentsDetail = (Repeater)e.Item.FindControl("rptCommentsDetail");
                var noCommentsDetailDiv = (HtmlGenericControl)e.Item.FindControl("noCommentsDetailDiv");

                if (rptCommentsDetail != null)
                {
                    rptCommentsDetail.DataSource = feedback.Comments;
                    rptCommentsDetail.DataBind();

                    if (feedback.Comments.Count == 0)
                    {
                        if (noCommentsDetailDiv != null) noCommentsDetailDiv.Style["display"] = "block";
                        rptCommentsDetail.Visible = false;
                    }
                    else
                    {
                        if (noCommentsDetailDiv != null) noCommentsDetailDiv.Style["display"] = "none";
                        rptCommentsDetail.Visible = true;
                    }
                }

                // Also handle regular comments repeater if it exists
                var rptComments = (Repeater)e.Item.FindControl("rptComments");
                var noCommentsDiv = (HtmlGenericControl)e.Item.FindControl("noCommentsDiv");

                if (rptComments != null)
                {
                    rptComments.DataSource = feedback.Comments;
                    rptComments.DataBind();

                    if (feedback.Comments.Count == 0)
                    {
                        if (noCommentsDiv != null) noCommentsDiv.Style["display"] = "block";
                        rptComments.Visible = false;
                    }
                    else
                    {
                        if (noCommentsDiv != null) noCommentsDiv.Style["display"] = "none";
                        rptComments.Visible = true;
                    }
                }
            }
        }

        protected async void rptFeedback_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Check authentication before processing any command
            if (string.IsNullOrEmpty(currentUserId))
            {
                ShowMessage("Please login to interact with feedback posts.", "alert alert-warning");
                return;
            }

            if (e.CommandName == "Like")
            {
                string postId = e.CommandArgument.ToString();

                try
                {
                    DocumentReference postRef = db.Collection("feedbacks").Document(postId);
                    DocumentSnapshot postSnap = await postRef.GetSnapshotAsync();

                    if (postSnap.Exists)
                    {
                        var data = postSnap.ToDictionary();
                        var likes = data.ContainsKey("likes") ? (data["likes"] as IEnumerable<object>)?.ToList() : new List<object>();

                        if (likes == null)
                            likes = new List<object>();

                        if (likes.Contains(currentUserId))
                        {
                            // Unlike
                            likes.Remove(currentUserId);
                        }
                        else
                        {
                            // Like
                            likes.Add(currentUserId);
                        }

                        Dictionary<string, object> updates = new Dictionary<string, object>
                        {
                            { "likes", likes }
                        };

                        await postRef.UpdateAsync(updates);
                        await LoadAllFeedbacks();
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("Error updating like: " + ex.Message, "alert alert-danger");
                }
            }
            else if (e.CommandName == "SubmitComment")
            {
                string postId = e.CommandArgument.ToString();

                // Try to find the modal comment controls first
                var txtCommentInputDetail = (TextBox)e.Item.FindControl("txtCommentInputDetail");
                var lblCommentErrorDetail = (Label)e.Item.FindControl("lblCommentErrorDetail");

                // If modal controls not found, try regular controls (fallback)
                var txtCommentInput = txtCommentInputDetail ?? (TextBox)e.Item.FindControl("txtCommentInput");
                var lblCommentError = lblCommentErrorDetail ?? (Label)e.Item.FindControl("lblCommentError");

                string commentText = txtCommentInput?.Text.Trim();

                // Validate comment text
                if (string.IsNullOrWhiteSpace(commentText))
                {
                    if (lblCommentError != null)
                    {
                        lblCommentError.Text = "Comment cannot be empty";
                        lblCommentError.Visible = true;
                    }
                    return;
                }

                // Additional comment validation
                if (commentText.Length > 500)
                {
                    if (lblCommentError != null)
                    {
                        lblCommentError.Text = "Comment cannot exceed 500 characters";
                        lblCommentError.Visible = true;
                    }
                    return;
                }

                // Check for inappropriate content (basic filter)
                if (ContainsInappropriateContent(commentText))
                {
                    if (lblCommentError != null)
                    {
                        lblCommentError.Text = "Comment contains inappropriate content";
                        lblCommentError.Visible = true;
                    }
                    return;
                }

                var commentData = new Dictionary<string, object>
                {
                    { "userId", currentUserId },
                    { "username", currentUserName },
                    { "text", commentText },
                    { "createdAt", Timestamp.GetCurrentTimestamp() }
                };

                try
                {
                    await db.Collection("feedbacks").Document(postId).Collection("comments").AddAsync(commentData);

                    // Clear the comment input
                    if (txtCommentInput != null) txtCommentInput.Text = "";

                    // Hide any previous error
                    if (lblCommentError != null) lblCommentError.Visible = false;

                    await LoadAllFeedbacks();

                    // Add JavaScript to keep the modal open after postback
                    string script = $@"
                        <script type='text/javascript'>
                            $(document).ready(function() {{
                                setTimeout(function() {{
                                    openCardDetail('{postId}');
                                }}, 500);
                            }});
                        </script>";
                    ClientScript.RegisterStartupScript(this.GetType(), "ReopenModal", script);
                }
                catch (Exception ex)
                {
                    if (lblCommentError != null)
                    {
                        lblCommentError.Text = "Error submitting comment: " + ex.Message;
                        lblCommentError.Visible = true;
                    }
                }
            }
        }

        private bool ContainsInappropriateContent(string text)
        {
            // Basic content filter - you can expand this as needed
            string[] inappropriateWords = {
                "spam", "scam", "fake", "hate", "abuse" 
                // Add more words as needed
            };

            string lowerText = text.ToLower();
            return inappropriateWords.Any(word => lowerText.Contains(word));
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = cssClass;
            lblMessage.Visible = true;
        }

        // Add page methods for better error handling
        protected override void OnError(EventArgs e)
        {
            Exception ex = Server.GetLastError();
            ShowMessage("An unexpected error occurred: " + ex.Message, "alert alert-danger");
            Server.ClearError();
            base.OnError(e);
        }

        protected override void OnPreRender(EventArgs e)
        {
            // Ensure validation scripts are registered
            if (Page.IsPostBack)
            {
                // Re-register validation scripts if needed
                ClientScript.RegisterStartupScript(this.GetType(), "ValidationScripts", @"
                    <script type='text/javascript'>
                        // Ensure validation functions are available after postback
                        if (typeof validateFeedbackForm === 'undefined') {
                            window.location.reload();
                        }
                    </script>");
            }
            base.OnPreRender(e);
        }
    }

    public static class FirestoreExtensions
    {
        public static object GetValueOrDefault(this IDictionary<string, object> dict, string key, object defaultValue)
        {
            return dict.ContainsKey(key) ? dict[key] : defaultValue;
        }
    }
}