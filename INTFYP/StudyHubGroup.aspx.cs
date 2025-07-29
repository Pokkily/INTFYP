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

namespace YourProjectNamespace
{
    public partial class StudyHubGroup : System.Web.UI.Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        protected string groupId;

        private static HashSet<string> editingPostIds = new HashSet<string>();
        private static HashSet<string> editingCommentKeys = new HashSet<string>();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            db = FirestoreDb.Create("intorannetto");
            currentUserId = Session["userId"].ToString();
            groupId = Request.QueryString["groupId"];

            if (string.IsNullOrEmpty(groupId))
            {
                Response.Redirect("StudyHub.aspx");
                return;
            }

            if (!IsPostBack)
                await LoadGroup();
        }

        private async Task LoadGroup()
        {
            try
            {
                DocumentSnapshot groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                if (!groupSnap.Exists)
                {
                    Response.Redirect("StudyHub.aspx");
                    return;
                }

                var group = groupSnap.ToDictionary();
                ltGroupDetails.Text = $@"
                    <div class='card mb-4'>
                        <div class='card-body'>
                            <h2 class='card-title'>{group["groupName"]}</h2>
                            <p class='card-text'>{group["description"]}</p>
                            <small class='text-muted'>Host: {group["hosterName"]}</small>
                        </div>
                    </div>";

                await LoadPosts();
            }
            catch (Exception ex)
            {
                // Log error
                ltGroupDetails.Text = "<div class='alert alert-danger'>Error loading group details.</div>";
            }
        }

        private async Task LoadPosts()
        {
            try
            {
                var posts = new List<dynamic>();
                var postsRef = db.Collection("studyHubs").Document(groupId).Collection("posts");
                var postSnaps = await postsRef.OrderByDescending("timestamp").GetSnapshotAsync();

                foreach (var postDoc in postSnaps.Documents)
                {
                    var p = postDoc.ToDictionary();
                    string postId = postDoc.Id;

                    // Load comments
                    var comments = new List<dynamic>();
                    var commentSnaps = await postsRef.Document(postId).Collection("comments")
                        .OrderBy("timestamp").GetSnapshotAsync();

                    foreach (var cDoc in commentSnaps.Documents)
                    {
                        var c = cDoc.ToDictionary();
                        string commentId = cDoc.Id;
                        string commentKey = postId + "|" + commentId;

                        comments.Add(new
                        {
                            postId,
                            commentId,
                            username = c.GetValueOrDefault("commenterName", "Unknown").ToString(),
                            content = c.GetValueOrDefault("text", "").ToString(),
                            timestamp = c.ContainsKey("timestamp") ?
                                ((Timestamp)c["timestamp"]).ToDateTime().ToString("MMM dd, yyyy 'at' h:mm tt") : "",
                            isOwner = c.GetValueOrDefault("commenterId", "").ToString() == currentUserId,
                            IsEditingComment = editingCommentKeys.Contains(commentKey)
                        });
                    }

                    // Get likes and saves
                    var likes = p.ContainsKey("likes") ? (List<object>)p["likes"] : new List<object>();
                    var saves = p.ContainsKey("saves") ? (List<object>)p["saves"] : new List<object>();

                    // Convert to string list for easier checking
                    var likesList = likes.Cast<string>().ToList();
                    var savesList = saves.Cast<string>().ToList();

                    posts.Add(new
                    {
                        postId,
                        content = p.GetValueOrDefault("content", "").ToString(),
                        imageUrl = p.ContainsKey("imageUrl") ? p["imageUrl"].ToString() : "",
                        timestamp = p.ContainsKey("timestamp") ?
                            ((Timestamp)p["timestamp"]).ToDateTime().ToString("MMM dd, yyyy 'at' h:mm tt") : "",
                        creatorUsername = p.GetValueOrDefault("postedByName", "Unknown").ToString(),
                        isOwner = p.GetValueOrDefault("postedBy", "").ToString() == currentUserId,
                        IsEditingPost = editingPostIds.Contains(postId),
                        comments,
                        likeCount = likesList.Count,
                        isLiked = likesList.Contains(currentUserId),
                        isSaved = savesList.Contains(currentUserId)
                    });
                }

                rptPosts.DataSource = posts;
                rptPosts.DataBind();
            }
            catch (Exception ex)
            {
                // Log error
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "alert('Error loading posts.');", true);
            }
        }

        protected async void btnPost_Click(object sender, EventArgs e)
        {
            try
            {
                string content = txtPostContent.Text.Trim();

                if (string.IsNullOrEmpty(content))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "validation",
                        "alert('Please enter some content for your post.');", true);
                    return;
                }

                string imageUrl = UploadImageToCloudinary();

                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document();

                var postData = new Dictionary<string, object>
                {
                    { "content", content },
                    { "postedBy", currentUserId },
                    { "postedByName", Session["username"]?.ToString() ?? "Unknown" },
                    { "imageUrl", imageUrl },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "likes", new List<string>() },
                    { "saves", new List<string>() }
                };

                await postRef.SetAsync(postData);

                txtPostContent.Text = "";
                await LoadPosts();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "alert('Error creating post. Please try again.');", true);
            }
        }

        private string UploadImageToCloudinary()
        {
            try
            {
                if (!fileUpload.HasFile) return "";

                var account = new Account(
                    ConfigurationManager.AppSettings["CloudinaryCloudName"],
                    ConfigurationManager.AppSettings["CloudinaryApiKey"],
                    ConfigurationManager.AppSettings["CloudinaryApiSecret"]
                );

                var cloudinary = new Cloudinary(account);

                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(fileUpload.FileName, fileUpload.PostedFile.InputStream),
                    Folder = "studyhub_posts"
                };

                var uploadResult = cloudinary.Upload(uploadParams);

                if (uploadResult.StatusCode == System.Net.HttpStatusCode.OK)
                    return uploadResult.SecureUrl.ToString();
                else
                    return "";
            }
            catch (Exception ex)
            {
                // Log error
                return "";
            }
        }

        protected async void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                string postId = e.CommandArgument.ToString();
                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document(postId);

                switch (e.CommandName)
                {
                    case "EditPost":
                        editingPostIds.Add(postId);
                        break;

                    case "CancelPost":
                        editingPostIds.Remove(postId);
                        break;

                    case "SavePost":
                        var txtEditPost = (TextBox)e.Item.FindControl("txtEditPost");
                        string newContent = txtEditPost.Text.Trim();

                        if (!string.IsNullOrEmpty(newContent))
                        {
                            await postRef.UpdateAsync("content", newContent);
                            editingPostIds.Remove(postId);
                        }
                        break;

                    case "DeletePost":
                        // Verify ownership
                        var postSnap = await postRef.GetSnapshotAsync();
                        if (postSnap.Exists)
                        {
                            var postData = postSnap.ToDictionary();
                            if (postData.GetValueOrDefault("postedBy", "").ToString() == currentUserId)
                            {
                                await postRef.DeleteAsync();
                            }
                        }
                        break;

                    case "ToggleLike":
                        await HandleToggleLike(postRef);
                        break;

                    case "ToggleSave":
                        await HandleToggleSave(postRef);
                        break;

                    case "ReportPost":
                        await HandleReportPost(postId);
                        break;

                    case "AddComment":
                        var txtNewComment = (TextBox)e.Item.FindControl("txtNewComment");
                        string commentTxt = txtNewComment.Text.Trim();

                        if (!string.IsNullOrEmpty(commentTxt))
                        {
                            var cref = postRef.Collection("comments").Document();
                            await cref.SetAsync(new Dictionary<string, object>
                            {
                                { "commenterId", currentUserId },
                                { "commenterName", Session["username"]?.ToString() ?? "Unknown" },
                                { "text", commentTxt },
                                { "timestamp", Timestamp.GetCurrentTimestamp() }
                            });
                            txtNewComment.Text = "";
                        }
                        break;
                }

                await LoadPosts();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "alert('An error occurred. Please try again.');", true);
            }
        }

        private async Task HandleToggleLike(DocumentReference postRef)
        {
            var postSnap = await postRef.GetSnapshotAsync();
            if (!postSnap.Exists) return;

            var postData = postSnap.ToDictionary();
            var likes = postData.ContainsKey("likes") ?
                ((List<object>)postData["likes"]).Cast<string>().ToList() :
                new List<string>();

            if (likes.Contains(currentUserId))
            {
                likes.Remove(currentUserId);
            }
            else
            {
                likes.Add(currentUserId);
            }

            await postRef.UpdateAsync("likes", likes);
        }

        private async Task HandleToggleSave(DocumentReference postRef)
        {
            var postSnap = await postRef.GetSnapshotAsync();
            if (!postSnap.Exists) return;

            var postData = postSnap.ToDictionary();
            var saves = postData.ContainsKey("saves") ?
                ((List<object>)postData["saves"]).Cast<string>().ToList() :
                new List<string>();

            if (saves.Contains(currentUserId))
            {
                saves.Remove(currentUserId);
            }
            else
            {
                saves.Add(currentUserId);
            }

            await postRef.UpdateAsync("saves", saves);
        }

        private async Task HandleReportPost(string postId)
        {
            try
            {
                // Add to reports collection
                var reportRef = db.Collection("reports").Document();
                await reportRef.SetAsync(new Dictionary<string, object>
                {
                    { "reporterId", currentUserId },
                    { "reporterName", Session["username"]?.ToString() ?? "Unknown" },
                    { "postId", postId },
                    { "groupId", groupId },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "type", "post" },
                    { "status", "pending" }
                });

                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "alert('Post reported successfully. Thank you for helping keep our community safe.');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "alert('Error submitting report. Please try again.');", true);
            }
        }

        protected async void rptComments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                var args = e.CommandArgument.ToString().Split('|');
                string postId = args[0];
                string commentId = args[1];
                string key = postId + "|" + commentId;

                var commentRef = db.Collection("studyHubs").Document(groupId)
                                    .Collection("posts").Document(postId)
                                    .Collection("comments").Document(commentId);

                var container = (RepeaterItem)e.Item;

                switch (e.CommandName)
                {
                    case "EditComment":
                        editingCommentKeys.Add(key);
                        break;

                    case "CancelComment":
                        editingCommentKeys.Remove(key);
                        break;

                    case "SaveComment":
                        var txtEditComment = (TextBox)container.FindControl("txtEditComment");
                        string updatedText = txtEditComment.Text.Trim();

                        if (!string.IsNullOrEmpty(updatedText))
                        {
                            await commentRef.UpdateAsync("text", updatedText);
                            editingCommentKeys.Remove(key);
                        }
                        break;

                    case "DeleteComment":
                        // Verify ownership
                        var commentSnap = await commentRef.GetSnapshotAsync();
                        if (commentSnap.Exists)
                        {
                            var commentData = commentSnap.ToDictionary();
                            if (commentData.GetValueOrDefault("commenterId", "").ToString() == currentUserId)
                            {
                                await commentRef.DeleteAsync();
                            }
                        }
                        break;
                }

                await LoadPosts();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "alert('An error occurred. Please try again.');", true);
            }
        }
    }
}