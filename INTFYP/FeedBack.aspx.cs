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

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore();
                string userId = Session["userId"] as string;

                if (string.IsNullOrEmpty(userId))
                {
                    // Redirect to login page or show message
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                // Set username for feedback form from session
                txtFeedbackUsername.Text = Session["username"]?.ToString() ?? "";

                await LoadAllFeedbacks();
            }
        }

        private void InitializeFirestore()
        {
            if (db == null)
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto");
            }
        }

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = true;

            string userId = Session["userId"]?.ToString();
            if (string.IsNullOrEmpty(userId))
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Please login to submit feedback.";
                return;
            }

            string description = txtDescription.Text.Trim();
            if (string.IsNullOrWhiteSpace(description))
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Please enter feedback description.";
                return;
            }

            string mediaUrl = await UploadFileIfAny();

            var feedback = new
            {
                userId,
                username = Session["username"]?.ToString(),
                email = Session["email"]?.ToString(),
                description,
                mediaUrl,
                likes = new string[] { },
                comments = new List<object>(),
                createdAt = Timestamp.GetCurrentTimestamp()
            };

            await db.Collection("feedbacks").AddAsync(feedback);

            lblMessage.CssClass = "text-success";
            lblMessage.Text = "Feedback submitted successfully!";
            txtDescription.Text = "";

            await LoadAllFeedbacks();
        }

        private async Task<string> UploadFileIfAny()
        {
            if (!fileUpload.HasFile) return null;

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

        private async Task LoadAllFeedbacks()
        {
            var feedbacks = new List<dynamic>();
            string currentUserId = Session["userId"]?.ToString(); // Get current user ID

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

        protected void rptFeedback_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var feedback = (dynamic)e.Item.DataItem;
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
            if (e.CommandName == "Like")
            {
                string postId = e.CommandArgument.ToString();
                string userId = Session["userId"]?.ToString();

                if (string.IsNullOrEmpty(userId)) return;

                DocumentReference postRef = db.Collection("feedbacks").Document(postId);
                DocumentSnapshot postSnap = await postRef.GetSnapshotAsync();

                if (postSnap.Exists)
                {
                    var data = postSnap.ToDictionary();
                    var likes = data.ContainsKey("likes") ? (data["likes"] as IEnumerable<object>)?.ToList() : new List<object>();

                    if (likes == null)
                        likes = new List<object>();

                    if (likes.Contains(userId))
                    {
                        // Unlike
                        likes.Remove(userId);
                    }
                    else
                    {
                        // Like
                        likes.Add(userId);
                    }

                    Dictionary<string, object> updates = new Dictionary<string, object>
                    {
                        { "likes", likes }
                    };

                    await postRef.UpdateAsync(updates);
                    await LoadAllFeedbacks();
                }
            }
            else if (e.CommandName == "SubmitComment")
            {
                string postId = e.CommandArgument.ToString();
                string userId = Session["userId"]?.ToString();
                string username = Session["username"]?.ToString() ?? "Anonymous";

                var txtCommentInput = (TextBox)e.Item.FindControl("txtCommentInput");
                string commentText = txtCommentInput?.Text.Trim();

                if (string.IsNullOrEmpty(userId))
                {
                    var lblCommentError = (Label)e.Item.FindControl("lblCommentError");
                    if (lblCommentError != null)
                    {
                        lblCommentError.Text = "Please login to comment";
                        lblCommentError.Visible = true;
                    }
                    return;
                }

                if (string.IsNullOrWhiteSpace(commentText))
                {
                    var lblCommentError = (Label)e.Item.FindControl("lblCommentError");
                    if (lblCommentError != null)
                    {
                        lblCommentError.Text = "Comment cannot be empty";
                        lblCommentError.Visible = true;
                    }
                    return;
                }

                var commentData = new Dictionary<string, object>
                {
                    { "userId", userId },
                    { "username", username },
                    { "text", commentText },
                    { "createdAt", Timestamp.GetCurrentTimestamp() }
                };

                try
                {
                    await db.Collection("feedbacks").Document(postId).Collection("comments").AddAsync(commentData);

                    // Clear the comment input
                    if (txtCommentInput != null) txtCommentInput.Text = "";

                    // Hide any previous error
                    var lblCommentError = (Label)e.Item.FindControl("lblCommentError");
                    if (lblCommentError != null) lblCommentError.Visible = false;

                    await LoadAllFeedbacks();
                }
                catch (Exception ex)
                {
                    var lblCommentError = (Label)e.Item.FindControl("lblCommentError");
                    if (lblCommentError != null)
                    {
                        lblCommentError.Text = "Error submitting comment: " + ex.Message;
                        lblCommentError.Visible = true;
                    }
                }
            }
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