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
    public partial class StudyHubGroup : System.Web.UI.Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        protected string currentUsername;
        protected string groupId;

        private static HashSet<string> editingPostIds = new HashSet<string>();
        private static HashSet<string> editingCommentKeys = new HashSet<string>();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            db = FirestoreDb.Create("intorannetto");
            currentUserId = Session["userId"].ToString();
            currentUsername = Session["username"].ToString();
            groupId = Request.QueryString["groupId"];

            if (string.IsNullOrEmpty(groupId))
            {
                Response.Redirect("StudyHubGroup.aspx");
                return;
            }

            if (!IsPostBack)
                await LoadGroup();
        }
        
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            // Add scroll position maintenance script
            string scrollScript = @"
                // Store scroll position before postback
                function storeScrollPosition() {
                    sessionStorage.setItem('scrollPosition', window.pageYOffset || document.documentElement.scrollTop);
                }

                // Restore scroll position after postback
                function restoreScrollPosition() {
                    var scrollPos = sessionStorage.getItem('scrollPosition');
                    if (scrollPos) {
                        window.scrollTo(0, parseInt(scrollPos));
                        sessionStorage.removeItem('scrollPosition');
                    }
                }

                // Store position before any postback
                Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(storeScrollPosition);
                
                // Restore position after partial postback
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(restoreScrollPosition);

                // Also restore on initial page load
                window.addEventListener('load', restoreScrollPosition);
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "scrollMaintenance", scrollScript, true);
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
                var members = group.ContainsKey("members") ? (List<object>)group["members"] : new List<object>();
                var membersList = members.Cast<string>().ToList();

                // Check if user is a member
                if (!membersList.Contains(currentUserId))
                {
                    ShowMessage("You are not a member of this group.", "warning");
                    Response.Redirect("StudyHub.aspx");
                    return;
                }

                // Get group statistics
                int memberCount = membersList.Count;
                int postCount = await GetPostCount();
                string lastActivity = await GetLastActivity();

                ltGroupDetails.Text = $@"
                    <h1 class='group-title'>{group["groupName"]}</h1>
                    <div class='group-meta'>🧑‍🏫 Hosted by {group["hosterName"]}</div>
                    <div class='group-description'>{group.GetValueOrDefault("description", "")}</div>
                    <div class='group-stats'>
                        <div class='stat-item'>
                            <span class='stat-icon'>👥</span>
                            <span>{memberCount} members</span>
                        </div>
                        <div class='stat-item'>
                            <span class='stat-icon'>📝</span>
                            <span>{postCount} posts</span>
                        </div>
                        <div class='stat-item'>
                            <span class='stat-icon'>⏰</span>
                            <span>{lastActivity}</span>
                        </div>
                    </div>";

                await LoadPosts();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading group details: " + ex.Message, "danger");
            }
        }

        private async Task<int> GetPostCount()
        {
            try
            {
                var postsSnapshot = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").GetSnapshotAsync();
                return postsSnapshot.Count;
            }
            catch
            {
                return 0;
            }
        }

        private async Task<string> GetLastActivity()
        {
            try
            {
                var lastPostSnapshot = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").OrderByDescending("timestamp").Limit(1).GetSnapshotAsync();

                if (lastPostSnapshot.Count > 0)
                {
                    var lastPost = lastPostSnapshot.Documents[0].ToDictionary();
                    if (lastPost.ContainsKey("timestamp"))
                    {
                        var timestamp = (Timestamp)lastPost["timestamp"];
                        var timeAgo = DateTime.Now - timestamp.ToDateTime();

                        if (timeAgo.TotalDays > 1)
                            return $"{(int)timeAgo.TotalDays} days ago";
                        else if (timeAgo.TotalHours > 1)
                            return $"{(int)timeAgo.TotalHours} hours ago";
                        else
                            return "Recently";
                    }
                }

                return "No recent activity";
            }
            catch
            {
                return "Unknown";
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
                    var comments = await LoadCommentsForPost(postId);

                    // Get engagement data
                    var likes = p.ContainsKey("likes") ? (List<object>)p["likes"] : new List<object>();
                    var saves = p.ContainsKey("saves") ? (List<object>)p["saves"] : new List<object>();
                    var shares = p.ContainsKey("shares") ? (List<object>)p["shares"] : new List<object>();

                    var likesList = likes.Cast<string>().ToList();
                    var savesList = saves.Cast<string>().ToList();
                    var sharesList = shares.Cast<string>().ToList();

                    // Load attachments
                    var attachments = await LoadAttachmentsForPost(postId);

                    posts.Add(new
                    {
                        postId,
                        content = p.GetValueOrDefault("content", "").ToString(),
                        timestamp = p.ContainsKey("timestamp") ?
                            ((Timestamp)p["timestamp"]).ToDateTime().ToString("MMM dd, yyyy 'at' h:mm tt") : "",
                        creatorUsername = p.GetValueOrDefault("postedByName", "Unknown").ToString(),
                        isOwner = p.GetValueOrDefault("postedBy", "").ToString() == currentUserId,
                        IsEditingPost = editingPostIds.Contains(postId),
                        comments,
                        commentCount = comments.Count,
                        likeCount = likesList.Count,
                        shareCount = sharesList.Count,
                        isLiked = likesList.Contains(currentUserId),
                        isSaved = savesList.Contains(currentUserId),
                        attachments
                    });
                }

                rptPosts.DataSource = posts;
                rptPosts.DataBind();

                pnlNoPosts.Visible = posts.Count == 0;
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading posts: " + ex.Message, "danger");
            }
        }

        private async Task<List<dynamic>> LoadCommentsForPost(string postId)
        {
            var comments = new List<dynamic>();
            try
            {
                var commentSnaps = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document(postId)
                    .Collection("comments").OrderBy("timestamp").GetSnapshotAsync();

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
                            ((Timestamp)c["timestamp"]).ToDateTime().ToString("MMM dd 'at' h:mm tt") : "",
                        isOwner = c.GetValueOrDefault("commenterId", "").ToString() == currentUserId,
                        IsEditingComment = editingCommentKeys.Contains(commentKey),
                        likes = c.ContainsKey("likes") ? ((List<object>)c["likes"]).Count : 0
                    });
                }
            }
            catch (Exception ex)
            {
                // Log error but don't fail
            }

            return comments;
        }

        private async Task<List<dynamic>> LoadAttachmentsForPost(string postId)
        {
            var attachments = new List<dynamic>();
            try
            {
                var attachmentSnaps = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document(postId)
                    .Collection("attachments").GetSnapshotAsync();

                foreach (var aDoc in attachmentSnaps.Documents)
                {
                    var a = aDoc.ToDictionary();
                    attachments.Add(new
                    {
                        fileName = a.GetValueOrDefault("fileName", "").ToString(),
                        fileUrl = a.GetValueOrDefault("fileUrl", "").ToString(),
                        fileType = a.GetValueOrDefault("fileType", "").ToString(),
                        fileSize = a.GetValueOrDefault("fileSize", 0)
                    });
                }
            }
            catch (Exception ex)
            {
                // Log error but don't fail
                System.Diagnostics.Debug.WriteLine($"Error loading attachments: {ex.Message}");
            }

            return attachments;
        }

        protected async void btnPost_Click(object sender, EventArgs e)
        {
            try
            {
                string content = txtPostContent.Text.Trim();
                bool hasFiles = fileUpload.HasFiles && fileUpload.PostedFiles.Count > 0;

                // Allow posts with either content OR files (or both)
                if (string.IsNullOrEmpty(content) && !hasFiles)
                {
                    ShowMessage("Please enter some content or attach a file for your post.", "warning");
                    return;
                }

                // Create the post first
                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document();
                string postId = postRef.Id;

                var postData = new Dictionary<string, object>
                {
                    { "content", content ?? "" },
                    { "postedBy", currentUserId },
                    { "postedByName", chkAnonymous.Checked ? "Anonymous" : currentUsername },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "likes", new List<string>() },
                    { "saves", new List<string>() },
                    { "shares", new List<string>() },
                    { "reports", new List<string>() },
                    { "isAnonymous", chkAnonymous.Checked },
                    { "hasAttachments", hasFiles }
                };

                await postRef.SetAsync(postData);

                // Handle file attachments AFTER creating the post
                if (hasFiles)
                {
                    bool uploadSuccess = await HandleFileUploads(postId);
                    if (!uploadSuccess)
                    {
                        // If file upload fails, you might want to delete the post or show a warning
                        ShowMessage("Post created but some files failed to upload. Please try again.", "warning");
                    }
                }

                // Create activity log
                await LogGroupActivity("post_created", $"New post created by {(chkAnonymous.Checked ? "Anonymous" : currentUsername)}");

                // Clear form
                txtPostContent.Text = "";
                chkAnonymous.Checked = false;

                // Clear file upload and file preview
                fileUpload.Attributes.Clear();

                // Add script to clear file preview on client side
                ScriptManager.RegisterStartupScript(this, GetType(), "clearFiles", "clearFilesAfterPost();", true);

                // Reload posts
                await LoadPosts();

                ShowMessage("Post created successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating post: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Post creation error: {ex}");
            }
        }

        private async Task<bool> HandleFileUploads(string postId)
        {
            bool allUploadsSuccessful = true;

            try
            {
                // Verify Cloudinary configuration exists
                string cloudName = ConfigurationManager.AppSettings["CloudinaryCloudName"];
                string apiKey = ConfigurationManager.AppSettings["CloudinaryApiKey"];
                string apiSecret = ConfigurationManager.AppSettings["CloudinaryApiSecret"];

                if (string.IsNullOrEmpty(cloudName) || string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(apiSecret))
                {
                    ShowMessage("Cloudinary configuration is missing. Please contact administrator.", "danger");
                    return false;
                }

                var account = new Account(cloudName, apiKey, apiSecret);
                var cloudinary = new Cloudinary(account);

                foreach (var file in fileUpload.PostedFiles)
                {
                    if (file != null && file.ContentLength > 0)
                    {
                        try
                        {
                            // Check file size (limit to 10MB)
                            if (file.ContentLength > 10 * 1024 * 1024)
                            {
                                ShowMessage($"File {file.FileName} is too large. Maximum size is 10MB.", "warning");
                                allUploadsSuccessful = false;
                                continue;
                            }

                            string uploadResult = "";
                            string fileType = file.ContentType;

                            // Reset stream position to beginning
                            file.InputStream.Position = 0;

                            if (fileType.StartsWith("image/"))
                            {
                                // Upload image
                                var uploadParams = new ImageUploadParams
                                {
                                    File = new FileDescription(file.FileName, file.InputStream),
                                    Folder = "studyhub_posts",
                                    Transformation = new Transformation().Quality("auto").FetchFormat("auto"),
                                    PublicId = $"post_{postId}_{DateTime.Now.Ticks}_{Path.GetFileNameWithoutExtension(file.FileName)}"
                                };

                                var result = await cloudinary.UploadAsync(uploadParams);

                                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                                {
                                    uploadResult = result.SecureUrl.ToString();
                                }
                                else
                                {
                                    System.Diagnostics.Debug.WriteLine($"Cloudinary upload failed: {result.Error?.Message}");
                                    allUploadsSuccessful = false;
                                    continue;
                                }
                            }
                            else
                            {
                                // Upload other files (documents)
                                var uploadParams = new RawUploadParams
                                {
                                    File = new FileDescription(file.FileName, file.InputStream),
                                    Folder = "studyhub_documents",
                                    PublicId = $"doc_{postId}_{DateTime.Now.Ticks}_{Path.GetFileNameWithoutExtension(file.FileName)}"
                                };

                                var result = await cloudinary.UploadAsync(uploadParams);

                                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                                {
                                    uploadResult = result.SecureUrl.ToString();
                                }
                                else
                                {
                                    System.Diagnostics.Debug.WriteLine($"Cloudinary upload failed: {result.Error?.Message}");
                                    allUploadsSuccessful = false;
                                    continue;
                                }
                            }

                            // Save attachment info to Firestore
                            if (!string.IsNullOrEmpty(uploadResult))
                            {
                                var attachmentRef = db.Collection("studyHubs").Document(groupId)
                                    .Collection("posts").Document(postId)
                                    .Collection("attachments").Document();

                                var attachmentData = new Dictionary<string, object>
                                {
                                    { "fileName", file.FileName },
                                    { "fileUrl", uploadResult },
                                    { "fileType", fileType },
                                    { "fileSize", file.ContentLength },
                                    { "uploadedBy", currentUserId },
                                    { "uploadedAt", Timestamp.GetCurrentTimestamp() }
                                };

                                await attachmentRef.SetAsync(attachmentData);

                                System.Diagnostics.Debug.WriteLine($"Successfully uploaded and saved: {file.FileName}");
                            }
                            else
                            {
                                allUploadsSuccessful = false;
                                ShowMessage($"Failed to upload {file.FileName}", "warning");
                            }
                        }
                        catch (Exception fileEx)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error uploading file {file.FileName}: {fileEx}");
                            ShowMessage($"Error uploading {file.FileName}: {fileEx.Message}", "warning");
                            allUploadsSuccessful = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"General file upload error: {ex}");
                ShowMessage("Error uploading files: " + ex.Message, "danger");
                allUploadsSuccessful = false;
            }

            return allUploadsSuccessful;
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
                            await postRef.UpdateAsync(new Dictionary<string, object>
                            {
                                { "content", newContent },
                                { "lastModified", Timestamp.GetCurrentTimestamp() },
                                { "modifiedBy", currentUserId }
                            });
                            editingPostIds.Remove(postId);

                            await LogGroupActivity("post_edited", $"Post edited by {currentUsername}");
                        }
                        break;

                    case "DeletePost":
                        await DeletePost(postRef, postId);
                        break;

                    case "ToggleLike":
                        await HandleToggleLike(postRef);
                        break;

                    case "ToggleSave":
                        await HandleToggleSave(postRef);
                        break;

                    case "InternalShare":
                        await HandleInternalShare(postRef, postId);
                        break;

                    case "ReportPost":
                        await HandleReportPost(postId);
                        break;

                    case "AddComment":
                        await HandleAddComment(e, postId);
                        break;
                }

                await LoadPosts();
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred: " + ex.Message, "danger");
            }
        }

        private async Task DeletePost(DocumentReference postRef, string postId)
        {
            try
            {
                // Verify ownership
                var postSnap = await postRef.GetSnapshotAsync();
                if (postSnap.Exists)
                {
                    var postData = postSnap.ToDictionary();
                    if (postData.GetValueOrDefault("postedBy", "").ToString() == currentUserId)
                    {
                        // Delete all subcollections first
                        await DeleteSubcollection(postRef.Collection("comments"));
                        await DeleteSubcollection(postRef.Collection("attachments"));

                        // Delete the post
                        await postRef.DeleteAsync();

                        await LogGroupActivity("post_deleted", $"Post deleted by {currentUsername}");
                        ShowMessage("Post deleted successfully.", "success");
                    }
                    else
                    {
                        ShowMessage("You can only delete your own posts.", "warning");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting post: " + ex.Message, "danger");
            }
        }

        private async Task DeleteSubcollection(CollectionReference collectionRef)
        {
            try
            {
                var snapshot = await collectionRef.GetSnapshotAsync();
                foreach (var doc in snapshot.Documents)
                {
                    await doc.Reference.DeleteAsync();
                }
            }
            catch
            {
                // Log error but don't fail the main operation
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

            bool wasLiked = likes.Contains(currentUserId);

            if (wasLiked)
            {
                likes.Remove(currentUserId);
            }
            else
            {
                likes.Add(currentUserId);

                // Create notification for post owner
                string postOwnerId = postData.GetValueOrDefault("postedBy", "").ToString();
                if (postOwnerId != currentUserId)
                {
                    await CreateNotification(postOwnerId, "like", $"{currentUsername} liked your post");
                }
            }

            await postRef.UpdateAsync("likes", likes);

            // Log activity
            await LogGroupActivity("post_liked", $"{currentUsername} {(wasLiked ? "unliked" : "liked")} a post");
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
                ShowMessage("Post removed from saved items.", "info");
            }
            else
            {
                saves.Add(currentUserId);
                ShowMessage("Post saved successfully!", "success");

                // Save to user's saved posts collection
                await SaveToUserCollection(postRef.Id);
            }

            await postRef.UpdateAsync("saves", saves);
        }

        private async Task SaveToUserCollection(string postId)
        {
            try
            {
                var userSaveRef = db.Collection("users").Document(currentUserId)
                    .Collection("savedPosts").Document(postId);

                await userSaveRef.SetAsync(new Dictionary<string, object>
                {
                    { "postId", postId },
                    { "groupId", groupId },
                    { "savedAt", Timestamp.GetCurrentTimestamp() }
                });
            }
            catch
            {
                // Log error but don't fail
            }
        }

        private async Task HandleInternalShare(DocumentReference postRef, string postId)
        {
            var postSnap = await postRef.GetSnapshotAsync();
            if (!postSnap.Exists) return;

            var postData = postSnap.ToDictionary();
            var shares = postData.ContainsKey("shares") ?
                ((List<object>)postData["shares"]).Cast<string>().ToList() :
                new List<string>();

            if (!shares.Contains(currentUserId))
            {
                shares.Add(currentUserId);
                await postRef.UpdateAsync("shares", shares);

                // Create a share activity
                await CreateShareActivity(postId, postData);

                ShowMessage("Post shared to your timeline!", "success");
            }
            else
            {
                ShowMessage("You have already shared this post.", "info");
            }
        }

        private async Task CreateShareActivity(string postId, Dictionary<string, object> postData)
        {
            try
            {
                var shareRef = db.Collection("users").Document(currentUserId)
                    .Collection("timeline").Document();

                await shareRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", "share" },
                    { "originalPostId", postId },
                    { "originalGroupId", groupId },
                    { "originalContent", postData.GetValueOrDefault("content", "") },
                    { "originalAuthor", postData.GetValueOrDefault("postedByName", "") },
                    { "sharedBy", currentUserId },
                    { "sharedByName", currentUsername },
                    { "sharedAt", Timestamp.GetCurrentTimestamp() }
                });

                await LogGroupActivity("post_shared", $"{currentUsername} shared a post");
            }
            catch
            {
                // Log error but don't fail
            }
        }

        private async Task HandleReportPost(string postId)
        {
            try
            {
                var reportRef = db.Collection("reports").Document();
                await reportRef.SetAsync(new Dictionary<string, object>
                {
                    { "reporterId", currentUserId },
                    { "reporterName", currentUsername },
                    { "postId", postId },
                    { "groupId", groupId },
                    { "type", "post" },
                    { "reason", "inappropriate_content" },
                    { "status", "pending" },
                    { "timestamp", Timestamp.GetCurrentTimestamp() }
                });

                ShowMessage("Post reported successfully. Thank you for helping keep our community safe.", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error submitting report: " + ex.Message, "danger");
            }
        }

        private async Task HandleAddComment(RepeaterCommandEventArgs e, string postId)
        {
            var txtNewComment = (TextBox)e.Item.FindControl("txtNewComment");
            var chkAnonymousComment = (CheckBox)e.Item.FindControl("chkAnonymousComment");

            string commentText = txtNewComment.Text.Trim();

            if (!string.IsNullOrEmpty(commentText))
            {
                var commentRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document(postId)
                    .Collection("comments").Document();

                await commentRef.SetAsync(new Dictionary<string, object>
                {
                    { "commenterId", currentUserId },
                    { "commenterName", chkAnonymousComment.Checked ? "Anonymous" : currentUsername },
                    { "text", commentText },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "likes", new List<string>() },
                    { "isAnonymous", chkAnonymousComment.Checked }
                });

                // Create notification for post owner
                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document(postId);
                var postSnap = await postRef.GetSnapshotAsync();
                if (postSnap.Exists)
                {
                    var postData = postSnap.ToDictionary();
                    string postOwnerId = postData.GetValueOrDefault("postedBy", "").ToString();

                    if (postOwnerId != currentUserId)
                    {
                        await CreateNotification(postOwnerId, "comment",
                            $"{(chkAnonymousComment.Checked ? "Someone" : currentUsername)} commented on your post");
                    }
                }

                txtNewComment.Text = "";
                chkAnonymousComment.Checked = false;

                await LogGroupActivity("comment_created", $"New comment by {(chkAnonymousComment.Checked ? "Anonymous" : currentUsername)}");
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

                switch (e.CommandName)
                {
                    case "EditComment":
                        editingCommentKeys.Add(key);
                        break;

                    case "CancelComment":
                        editingCommentKeys.Remove(key);
                        break;

                    case "SaveComment":
                        var txtEditComment = (TextBox)e.Item.FindControl("txtEditComment");
                        string updatedText = txtEditComment.Text.Trim();

                        if (!string.IsNullOrEmpty(updatedText))
                        {
                            await commentRef.UpdateAsync(new Dictionary<string, object>
                            {
                                { "text", updatedText },
                                { "lastModified", Timestamp.GetCurrentTimestamp() },
                                { "modifiedBy", currentUserId }
                            });
                            editingCommentKeys.Remove(key);

                            await LogGroupActivity("comment_edited", $"Comment edited by {currentUsername}");
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
                                await LogGroupActivity("comment_deleted", $"Comment deleted by {currentUsername}");
                                ShowMessage("Comment deleted successfully.", "success");
                            }
                            else
                            {
                                ShowMessage("You can only delete your own comments.", "warning");
                            }
                        }
                        break;
                }

                await LoadPosts();
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred: " + ex.Message, "danger");
            }
        }

        private async Task CreateNotification(string userId, string type, string message)
        {
            try
            {
                var notificationRef = db.Collection("users").Document(userId)
                    .Collection("notifications").Document();

                await notificationRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", type },
                    { "message", message },
                    { "fromUserId", currentUserId },
                    { "fromUsername", currentUsername },
                    { "groupId", groupId },
                    { "isRead", false },
                    { "timestamp", Timestamp.GetCurrentTimestamp() }
                });
            }
            catch
            {
                // Log error but don't fail the main operation
            }
        }

        private async Task LogGroupActivity(string activityType, string description)
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
            catch
            {
                // Log error but don't fail the main operation
            }
        }

        private void ShowMessage(string message, string type)
        {
            string alertClass = type == "success" ? "alert-success" :
                               type == "warning" ? "alert-warning" :
                               type == "info" ? "alert-info" :
                               "alert-danger";

            string script = $@"
                showNotification('{message.Replace("'", "\\'")}', '{type}');
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "showMessage", script, true);
        }
    }
}