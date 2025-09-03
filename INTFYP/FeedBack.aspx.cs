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
            // Double-check authentication
            if (string.IsNullOrEmpty(currentUserId))
            {
                ShowMessage("Please login to submit feedback.", "text-danger");
                return;
            }

            lblMessage.Visible = true;

            string description = txtDescription.Text.Trim();
            if (string.IsNullOrWhiteSpace(description))
            {
                ShowMessage("Please enter feedback description.", "text-danger");
                return;
            }

            try
            {
                string mediaUrl = await UploadFileIfAny();

                var feedback = new
                {
                    userId = currentUserId,
                    username = currentUserName,
                    email = currentUserEmail,
                    description,
                    mediaUrl,
                    likes = new string[] { },
                    comments = new List<object>(),
                    createdAt = Timestamp.GetCurrentTimestamp()
                };

                await db.Collection("feedbacks").AddAsync(feedback);

                ShowMessage("Feedback submitted successfully!", "text-success");
                txtDescription.Text = "";

                await LoadAllFeedbacks();
            }
            catch (Exception ex)
            {
                ShowMessage("Error submitting feedback: " + ex.Message, "text-danger");
            }
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

                    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif")
                    {
                        var uploadParams = new ImageUploadParams
                        {
                            File = new FileDescription(fileUpload.FileName, stream),
                            Folder = "feedback_images"
                        };
                        var uploadResult = cloudinary.Upload(uploadParams);
                        return uploadResult.SecureUrl?.ToString();
                    }
                    else if (ext == ".mp4" || ext == ".mov" || ext == ".avi" || ext == ".webm")
                    {
                        var uploadParams = new VideoUploadParams
                        {
                            File = new FileDescription(fileUpload.FileName, stream),
                            Folder = "feedback_videos"
                        };
                        var uploadResult = cloudinary.Upload(uploadParams);
                        return uploadResult.SecureUrl?.ToString();
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                ShowMessage("Error uploading file: " + ex.Message, "text-danger");
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
                ShowMessage("Error loading feedbacks: " + ex.Message, "text-danger");
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
                ShowMessage("Please login to interact with feedback posts.", "text-warning");
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
                    ShowMessage("Error updating like: " + ex.Message, "text-danger");
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

                if (string.IsNullOrWhiteSpace(commentText))
                {
                    if (lblCommentError != null)
                    {
                        lblCommentError.Text = "Comment cannot be empty";
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

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = cssClass;
            lblMessage.Visible = true;
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