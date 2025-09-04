using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace YourProjectNamespace
{
    public partial class ClassDetails : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private const string ProjectId = "intorannetto";
        private static readonly object dbLock = new object();

        // Enhanced with current user info for profile navigation
        protected string currentUserId;
        protected string currentUsername;

        // Add this static HashSet to track editing comments
        private static HashSet<string> editingCommentKeys = new HashSet<string>();

        // Cache for profile images to avoid multiple Firestore calls - same as StudyHubGroup
        private static Dictionary<string, (string imageUrl, string initials, DateTime cachedAt)> profileCache =
            new Dictionary<string, (string, string, DateTime)>();
        private static readonly TimeSpan CacheExpiry = TimeSpan.FromMinutes(30);

        protected async void Page_Load(object sender, EventArgs e)
        {
            try
            {
                InitializeFirestore();

                // Initialize current user info for profile navigation
                if (Session["userId"] == null || Session["username"] == null)
                {
                    Response.Redirect("Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                currentUserId = Session["userId"].ToString();
                currentUsername = Session["username"].ToString();

                if (!IsPostBack)
                {
                    // Check authentication
                    if (!IsCurrentUserAuthenticated())
                    {
                        ShowAuthenticationError();
                        return;
                    }

                    string classId = Request.QueryString["classId"];
                    if (!string.IsNullOrEmpty(classId))
                    {
                        await LoadClassroomDetailsAsync(classId);
                        await LoadPostsAsync(classId);
                    }
                    else
                    {
                        ShowError("Classroom ID not specified.");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Page_Load error: {ex.Message}");
                ShowError($"Error initializing: {ex.Message}");
            }
        }

        // Add profile navigation script on PreRender - same as StudyHubGroup
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            // Add profile navigation and scroll position maintenance script
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
                if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(storeScrollPosition);
                    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(restoreScrollPosition);
                }
                
                // Also restore on initial page load
                window.addEventListener('load', restoreScrollPosition);

                // Profile navigation function
                function navigateToProfile(userId) {
                    if (userId && userId !== '" + currentUserId + @"') {
                        window.location.href = 'ProfileOthers.aspx?userId=' + userId;
                    } else if (userId === '" + currentUserId + @"') {
                        window.location.href = 'Profile.aspx';
                    }
                }
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "scrollMaintenance", scrollScript, true);
        }

        // Enhanced profile image loading method - same as StudyHubGroup
        private async Task<(string imageUrl, string initials, string userId)> LoadUserProfileImageSync(string userEmail, string username)
        {
            if (string.IsNullOrEmpty(userEmail))
                return ("", GenerateUserInitials("", "", username), "");

            try
            {
                // Try to get userId first from email
                var userQuery = db.Collection("users").WhereEqualTo("email", userEmail.ToLower()).Limit(1);
                var userSnapshot = await userQuery.GetSnapshotAsync();

                if (userSnapshot.Count == 0)
                {
                    // Try with original case
                    userQuery = db.Collection("users").WhereEqualTo("email", userEmail).Limit(1);
                    userSnapshot = await userQuery.GetSnapshotAsync();
                }

                if (userSnapshot.Count == 0)
                {
                    return ("", GenerateUserInitials("", "", username), "");
                }

                var userDoc = userSnapshot.Documents[0];
                string userId = userDoc.Id;

                // Check cache first
                if (profileCache.ContainsKey(userId))
                {
                    var cached = profileCache[userId];
                    if (DateTime.Now - cached.cachedAt < CacheExpiry)
                    {
                        return (cached.imageUrl, cached.initials, userId);
                    }
                    else
                    {
                        profileCache.Remove(userId);
                    }
                }

                // Load from Firestore
                if (userDoc.Exists)
                {
                    var userData = userDoc.ToDictionary();
                    string profileImageUrl = GetSafeValue(userData, "profileImageUrl");
                    string firstName = GetSafeValue(userData, "firstName");
                    string lastName = GetSafeValue(userData, "lastName");
                    string initials = GenerateUserInitials(firstName, lastName, username);

                    // Cache the result
                    profileCache[userId] = (profileImageUrl, initials, DateTime.Now);

                    return (profileImageUrl, initials, userId);
                }

                return ("", GenerateUserInitials("", "", username), "");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading profile for {userEmail}: {ex.Message}");
                return ("", GenerateUserInitials("", "", username), "");
            }
        }

        // Helper method to get current user profile info - same as StudyHubGroup
        private async Task<(string imageUrl, string initials, string userId)> LoadCurrentUserProfileInfo()
        {
            try
            {
                string currentUserEmail = GetCurrentUserEmail();
                if (string.IsNullOrEmpty(currentUserEmail))
                {
                    return ("", GetUserInitials(), currentUserId);
                }

                return await LoadUserProfileImageSync(currentUserEmail, currentUsername);
            }
            catch
            {
                return ("", GetUserInitials(), currentUserId);
            }
        }

        // Generate user initials method - same as StudyHubGroup
        private string GenerateUserInitials(string firstName, string lastName, string username)
        {
            if (!string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
            {
                return (firstName.Substring(0, 1) + lastName.Substring(0, 1)).ToUpper();
            }
            else if (!string.IsNullOrEmpty(username))
            {
                return username.Length >= 2 ? username.Substring(0, 2).ToUpper() : username.Substring(0, 1).ToUpper();
            }
            return "?";
        }

        // Get safe value method - same as StudyHubGroup
        private string GetSafeValue(Dictionary<string, object> dictionary, string key, string defaultValue = "")
        {
            if (dictionary == null || !dictionary.ContainsKey(key) || dictionary[key] == null)
            {
                return defaultValue;
            }
            return dictionary[key].ToString();
        }

        // Add the rptComments_ItemCommand event handler (kept for fallback)
        protected async void rptComments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                var args = e.CommandArgument.ToString().Split('|');
                string postId = args[0];
                string commentId = args[1];
                string commentKey = postId + "|" + commentId;
                string classId = Request.QueryString["classId"];

                var commentRef = db.Collection("classrooms")
                    .Document(classId)
                    .Collection("posts")
                    .Document(postId)
                    .Collection("comments")
                    .Document(commentId);

                switch (e.CommandName)
                {
                    case "EditComment":
                        editingCommentKeys.Add(commentKey);
                        break;

                    case "CancelEdit":
                        editingCommentKeys.Remove(commentKey);
                        break;

                    case "SaveComment":
                        await HandleSaveComment(e, commentRef, commentKey);
                        break;

                    case "DeleteComment":
                        await HandleDeleteComment(commentRef, commentId);
                        break;
                }

                // Reload posts to reflect changes
                await LoadPostsAsync(classId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"rptComments_ItemCommand error: {ex.Message}");
                ShowClientMessage("An error occurred while processing your request.", "error");
            }
        }

        private async Task HandleSaveComment(RepeaterCommandEventArgs e, DocumentReference commentRef, string commentKey)
        {
            try
            {
                var txtEditComment = (TextBox)e.Item.FindControl("txtEditComment");
                string updatedContent = txtEditComment?.Text?.Trim();

                if (string.IsNullOrWhiteSpace(updatedContent))
                {
                    ShowClientMessage("Comment content cannot be empty.", "error");
                    return;
                }

                // Verify comment exists and user owns it
                var commentSnap = await commentRef.GetSnapshotAsync();
                if (!commentSnap.Exists)
                {
                    ShowClientMessage("Comment not found.", "error");
                    return;
                }

                var commentData = commentSnap.ToDictionary();
                string commentAuthorEmail = GetStringValue(commentData, "authorEmail", "");
                string currentUserEmail = GetCurrentUserEmail();

                if (commentAuthorEmail != currentUserEmail)
                {
                    ShowClientMessage("You can only edit your own comments.", "error");
                    return;
                }

                // Update the comment
                var updateData = new Dictionary<string, object>
                {
                    { "content", updatedContent },
                    { "lastModified", Timestamp.GetCurrentTimestamp() },
                    { "modifiedBy", currentUserEmail },
                    { "isEdited", true }
                };

                await commentRef.UpdateAsync(updateData);

                // Remove from editing set
                editingCommentKeys.Remove(commentKey);

                ShowClientMessage("Comment updated successfully!", "success");
                System.Diagnostics.Debug.WriteLine($"Comment {commentRef.Id} updated successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error saving comment: {ex.Message}");
                ShowClientMessage("Error saving comment: " + ex.Message, "error");
            }
        }

        private async Task HandleDeleteComment(DocumentReference commentRef, string commentId)
        {
            try
            {
                // Verify comment exists and user owns it
                var commentSnap = await commentRef.GetSnapshotAsync();
                if (!commentSnap.Exists)
                {
                    ShowClientMessage("Comment not found.", "error");
                    return;
                }

                var commentData = commentSnap.ToDictionary();
                string commentAuthorEmail = GetStringValue(commentData, "authorEmail", "");
                string currentUserEmail = GetCurrentUserEmail();

                if (commentAuthorEmail != currentUserEmail)
                {
                    ShowClientMessage("You can only delete your own comments.", "error");
                    return;
                }

                // Delete the comment
                await commentRef.DeleteAsync();
                ShowClientMessage("Comment deleted successfully!", "success");
                System.Diagnostics.Debug.WriteLine($"Comment {commentId} deleted successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting comment: {ex.Message}");
                ShowClientMessage("Error deleting comment: " + ex.Message, "error");
            }
        }

        // NEW: AJAX Web Method for updating comments
        [WebMethod]
        public static async Task<object> UpdateComment(string classId, string postId, string commentId, string newContent)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"UpdateComment WebMethod called: classId={classId}, postId={postId}, commentId={commentId}");

                // Get current user info from session
                HttpContext context = HttpContext.Current;
                if (context?.Session == null)
                {
                    return new { success = false, error = "Session expired. Please log in again." };
                }

                string currentUserEmail = context.Session["email"]?.ToString();
                if (string.IsNullOrEmpty(currentUserEmail))
                {
                    return new { success = false, error = "Authentication required." };
                }

                if (string.IsNullOrWhiteSpace(newContent) || string.IsNullOrEmpty(classId) ||
                    string.IsNullOrEmpty(postId) || string.IsNullOrEmpty(commentId))
                {
                    return new { success = false, error = "Invalid input data." };
                }

                // Initialize Firestore if needed
                if (db == null)
                {
                    InitializeFirestoreStatic();
                }

                DocumentReference commentRef = db.Collection("classrooms")
                    .Document(classId)
                    .Collection("posts")
                    .Document(postId)
                    .Collection("comments")
                    .Document(commentId);

                // Verify comment exists and user owns it
                var commentSnap = await commentRef.GetSnapshotAsync();
                if (!commentSnap.Exists)
                {
                    return new { success = false, error = "Comment not found." };
                }

                var commentData = commentSnap.ToDictionary();
                string commentAuthorEmail = GetStringValueStatic(commentData, "authorEmail", "");

                if (commentAuthorEmail != currentUserEmail)
                {
                    return new { success = false, error = "You can only edit your own comments." };
                }

                // Update the comment
                var updateData = new Dictionary<string, object>
                {
                    { "content", newContent.Trim() },
                    { "lastModified", Timestamp.GetCurrentTimestamp() },
                    { "modifiedBy", currentUserEmail },
                    { "isEdited", true }
                };

                await commentRef.UpdateAsync(updateData);

                System.Diagnostics.Debug.WriteLine("Comment updated successfully via AJAX");
                return new { success = true, message = "Comment updated successfully!" };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AJAX UpdateComment error: {ex.Message}");
                return new { success = false, error = $"Failed to update comment: {ex.Message}" };
            }
        }

        // NEW: AJAX Web Method for deleting comments
        [WebMethod]
        public static async Task<object> DeleteComment(string classId, string postId, string commentId)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"DeleteComment WebMethod called: classId={classId}, postId={postId}, commentId={commentId}");

                // Get current user info from session
                HttpContext context = HttpContext.Current;
                if (context?.Session == null)
                {
                    return new { success = false, error = "Session expired. Please log in again." };
                }

                string currentUserEmail = context.Session["email"]?.ToString();
                if (string.IsNullOrEmpty(currentUserEmail))
                {
                    return new { success = false, error = "Authentication required." };
                }

                if (string.IsNullOrEmpty(classId) || string.IsNullOrEmpty(postId) || string.IsNullOrEmpty(commentId))
                {
                    return new { success = false, error = "Invalid input data." };
                }

                // Initialize Firestore if needed
                if (db == null)
                {
                    InitializeFirestoreStatic();
                }

                DocumentReference commentRef = db.Collection("classrooms")
                    .Document(classId)
                    .Collection("posts")
                    .Document(postId)
                    .Collection("comments")
                    .Document(commentId);

                // Verify comment exists and user owns it
                var commentSnap = await commentRef.GetSnapshotAsync();
                if (!commentSnap.Exists)
                {
                    return new { success = false, error = "Comment not found." };
                }

                var commentData = commentSnap.ToDictionary();
                string commentAuthorEmail = GetStringValueStatic(commentData, "authorEmail", "");

                if (commentAuthorEmail != currentUserEmail)
                {
                    return new { success = false, error = "You can only delete your own comments." };
                }

                // Delete the comment
                await commentRef.DeleteAsync();

                System.Diagnostics.Debug.WriteLine("Comment deleted successfully via AJAX");
                return new { success = true, message = "Comment deleted successfully!" };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AJAX DeleteComment error: {ex.Message}");
                return new { success = false, error = $"Failed to delete comment: {ex.Message}" };
            }
        }

        // Fallback comment submission handler for postback
        protected async void SubmitComment_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                string postId = btn.CommandArgument;
                string classId = Request.QueryString["classId"];

                if (string.IsNullOrEmpty(classId) || string.IsNullOrEmpty(postId))
                {
                    ShowError("Invalid post or classroom ID.");
                    return;
                }

                // Find the comment textarea in the same repeater item
                RepeaterItem item = (RepeaterItem)btn.NamingContainer;
                TextBox txtComment = (TextBox)item.FindControl("txtComment");

                if (txtComment == null || string.IsNullOrWhiteSpace(txtComment.Text))
                {
                    return; // No comment to submit
                }

                string commentText = txtComment.Text.Trim();
                string currentUserEmail = GetCurrentUserEmail();
                string currentUserName = GetCurrentUserName();

                if (string.IsNullOrEmpty(currentUserEmail))
                {
                    ShowAuthenticationError();
                    return;
                }

                await AddCommentAsync(classId, postId, commentText, currentUserEmail, currentUserName);

                // Clear the comment box and reload the page to show the new comment
                txtComment.Text = "";
                await LoadPostsAsync(classId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Comment submission error: {ex.Message}");
                ShowError($"Error posting comment: {ex.Message}");
            }
        }

        private async Task AddCommentAsync(string classId, string postId, string commentText, string authorEmail, string authorName)
        {
            try
            {
                DocumentReference commentRef = db.Collection("classrooms")
                    .Document(classId)
                    .Collection("posts")
                    .Document(postId)
                    .Collection("comments")
                    .Document();

                var commentData = new Dictionary<string, object>
                {
                    ["content"] = commentText,
                    ["authorEmail"] = authorEmail,
                    ["authorName"] = authorName,
                    ["createdAt"] = Timestamp.GetCurrentTimestamp(),
                    ["postId"] = postId,
                    ["isEdited"] = false,
                    ["lastModified"] = null,
                    ["modifiedBy"] = ""
                };

                await commentRef.SetAsync(commentData);
                System.Diagnostics.Debug.WriteLine($"Comment added successfully for post {postId}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error adding comment: {ex.Message}");
                throw;
            }
        }

        // AJAX Web Method for adding comments - Enhanced with profile image support
        [WebMethod]
        public static async Task<object> AddComment(string classId, string postId, string commentText)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"AddComment WebMethod called with: classId={classId}, postId={postId}, commentText={commentText}");

                // Get current user info from session
                HttpContext context = HttpContext.Current;
                if (context?.Session == null)
                {
                    System.Diagnostics.Debug.WriteLine("Session is null");
                    return new { success = false, error = "Session expired. Please log in again." };
                }

                string currentUserEmail = context.Session["email"]?.ToString();
                string currentUserName = GetSessionUserName(context.Session);
                string currentUserId = context.Session["userId"]?.ToString();

                System.Diagnostics.Debug.WriteLine($"User info: email={currentUserEmail}, name={currentUserName}, id={currentUserId}");

                if (string.IsNullOrEmpty(currentUserEmail))
                {
                    System.Diagnostics.Debug.WriteLine("No user email found in session");
                    return new { success = false, error = "Authentication required." };
                }

                if (string.IsNullOrWhiteSpace(commentText) || string.IsNullOrEmpty(classId) || string.IsNullOrEmpty(postId))
                {
                    System.Diagnostics.Debug.WriteLine("Invalid input data");
                    return new { success = false, error = "Invalid input data." };
                }

                // Initialize Firestore if needed
                if (db == null)
                {
                    System.Diagnostics.Debug.WriteLine("Initializing Firestore");
                    InitializeFirestoreStatic();
                }

                // Load current user profile info for the response
                string profileImageUrl = "";
                string initials = GetInitialsFromName(currentUserName);
                bool hasProfileImage = false;

                try
                {
                    if (!string.IsNullOrEmpty(currentUserId))
                    {
                        var userRef = db.Collection("users").Document(currentUserId);
                        var userSnap = await userRef.GetSnapshotAsync();

                        if (userSnap.Exists)
                        {
                            var userData = userSnap.ToDictionary();
                            profileImageUrl = GetStringValueStatic(userData, "profileImageUrl", "");
                            hasProfileImage = !string.IsNullOrEmpty(profileImageUrl);

                            // Generate better initials if we have user data
                            string firstName = GetStringValueStatic(userData, "firstName", "");
                            string lastName = GetStringValueStatic(userData, "lastName", "");
                            if (!string.IsNullOrEmpty(firstName) || !string.IsNullOrEmpty(lastName))
                            {
                                initials = GenerateInitialsStatic(firstName, lastName, currentUserName);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error loading user profile info: {ex.Message}");
                    // Continue with default values
                }

                // Add comment to Firestore
                DocumentReference commentRef = db.Collection("classrooms")
                    .Document(classId)
                    .Collection("posts")
                    .Document(postId)
                    .Collection("comments")
                    .Document();

                var commentData = new Dictionary<string, object>
                {
                    ["content"] = commentText.Trim(),
                    ["authorEmail"] = currentUserEmail,
                    ["authorName"] = currentUserName,
                    ["createdAt"] = Timestamp.GetCurrentTimestamp(),
                    ["postId"] = postId,
                    ["isEdited"] = false,
                    ["lastModified"] = null,
                    ["modifiedBy"] = ""
                };

                await commentRef.SetAsync(commentData);
                System.Diagnostics.Debug.WriteLine("Comment added to Firestore successfully");

                // Return success with enhanced comment data for immediate UI update
                var result = new
                {
                    success = true,
                    comment = new
                    {
                        content = commentText.Trim(),
                        authorName = currentUserName,
                        authorInitials = initials,
                        authorUserId = currentUserId,
                        authorProfileImage = profileImageUrl,
                        hasProfileImage = hasProfileImage,
                        createdAt = DateTime.Now,
                        postId = postId
                    }
                };

                System.Diagnostics.Debug.WriteLine($"Returning result: success=true, authorName={currentUserName}, hasProfileImage={hasProfileImage}");
                return result;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AJAX AddComment error: {ex.Message}\nStack trace: {ex.StackTrace}");
                return new { success = false, error = $"Failed to post comment: {ex.Message}" };
            }
        }

        // Static helper methods for WebMethods
        private static void InitializeFirestoreStatic()
        {
            if (db == null)
            {
                lock (dbLock)
                {
                    if (db == null)
                    {
                        try
                        {
                            string path = HttpContext.Current.Server.MapPath("~/serviceAccountKey.json");

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
                            db = FirestoreDb.Create(ProjectId);
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Static Firestore initialization failed: {ex.Message}");
                            throw;
                        }
                    }
                }
            }
        }

        private static string GetSessionUserName(HttpSessionState session)
        {
            try
            {
                if (session["username"] != null)
                {
                    return session["username"].ToString();
                }
                else if (session["firstName"] != null && session["lastName"] != null)
                {
                    return $"{session["firstName"]} {session["lastName"]}";
                }
                else if (session["email"] != null)
                {
                    return session["email"].ToString();
                }
                return "Anonymous User";
            }
            catch
            {
                return "Anonymous User";
            }
        }

        private static string GetInitialsFromName(string name)
        {
            try
            {
                if (string.IsNullOrEmpty(name)) return "U";

                string[] nameParts = name.Split(' ');
                if (nameParts.Length >= 2)
                {
                    return $"{nameParts[0][0]}{nameParts[1][0]}".ToUpper();
                }
                else if (nameParts.Length == 1 && nameParts[0].Length > 0)
                {
                    return nameParts[0].Substring(0, Math.Min(2, nameParts[0].Length)).ToUpper();
                }
                return "U";
            }
            catch
            {
                return "U";
            }
        }

        // Static version of GenerateUserInitials for WebMethods
        private static string GenerateInitialsStatic(string firstName, string lastName, string username)
        {
            if (!string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
            {
                return (firstName.Substring(0, 1) + lastName.Substring(0, 1)).ToUpper();
            }
            else if (!string.IsNullOrEmpty(username))
            {
                return username.Length >= 2 ? username.Substring(0, 2).ToUpper() : username.Substring(0, 1).ToUpper();
            }
            return "?";
        }

        // Static version of GetStringValue for use in WebMethods
        private static string GetStringValueStatic(Dictionary<string, object> data, string key, string defaultValue = "")
        {
            if (data.ContainsKey(key) && data[key] != null)
            {
                return data[key].ToString();
            }
            return defaultValue;
        }

        // Direct authentication check method
        private bool IsCurrentUserAuthenticated()
        {
            try
            {
                if (Session == null)
                {
                    return false;
                }

                // Check if user has valid session data
                string email = Session["email"]?.ToString();
                string username = Session["username"]?.ToString();

                // Consider authenticated if either email or username exists
                return !string.IsNullOrEmpty(email) || !string.IsNullOrEmpty(username);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Authentication check error: {ex.Message}");
                return false;
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
                            db = FirestoreDb.Create(ProjectId);

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

        private void ShowAuthenticationError()
        {
            string script = @"
                <script type='text/javascript'>
                    document.addEventListener('DOMContentLoaded', function() {
                        const authAlert = document.getElementById('authAlert');
                        const authMessage = document.getElementById('authMessage');
                        
                        if (authAlert && authMessage) {
                            authMessage.textContent = 'Please log in to access this classroom.';
                            authAlert.classList.add('show');
                        }
                    });
                </script>";

            ClientScript.RegisterStartupScript(this.GetType(), "AuthError", script, false);
        }

        private async Task LoadClassroomDetailsAsync(string classId)
        {
            try
            {
                DocumentReference classRef = db.Collection("classrooms").Document(classId);
                DocumentSnapshot classSnap = await classRef.GetSnapshotAsync();

                if (classSnap.Exists)
                {
                    var classData = classSnap.ToDictionary();
                    string className = classData.ContainsKey("name") ? classData["name"].ToString() : "Classroom";
                    string venue = classData.ContainsKey("venue") ? classData["venue"].ToString() : "";

                    // Update page title
                    classTitle.InnerText = $"📚 {className}";
                    if (!string.IsNullOrEmpty(venue))
                    {
                        classTitle.InnerText += $" • {venue}";
                    }

                    System.Diagnostics.Debug.WriteLine($"Loaded classroom: {className}");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("Classroom not found");
                    ShowError("Classroom not found.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading classroom: {ex.Message}");
                ShowError("Error loading classroom details.");
            }
        }

        // Enhanced LoadPostsAsync with profile image support
        private async Task LoadPostsAsync(string classId)
        {
            try
            {
                CollectionReference postsRef = db.Collection("classrooms")
                    .Document(classId)
                    .Collection("posts");

                QuerySnapshot postsSnapshot = await postsRef.OrderByDescending("postedAt").GetSnapshotAsync();

                List<PostEntry> posts = new List<PostEntry>();

                foreach (DocumentSnapshot document in postsSnapshot.Documents)
                {
                    if (document.Exists)
                    {
                        try
                        {
                            Dictionary<string, object> postData = document.ToDictionary();
                            string creatorEmail = GetStringValue(postData, "createdBy", "");

                            // Load profile info for post creator
                            var creatorProfile = await LoadUserProfileImageSync(creatorEmail, GetStringValue(postData, "createdByName", "Unknown"));

                            var post = new PostEntry
                            {
                                Id = document.Id,
                                Title = GetStringValue(postData, "title", "No Title"),
                                Type = GetStringValue(postData, "postType", "Post"),
                                Content = GetStringValue(postData, "content", ""),
                                CreatedByName = await GetUserDisplayNameAsync(creatorEmail),
                                CreatedByUserId = creatorProfile.userId,
                                CreatedByProfileImage = creatorProfile.imageUrl,
                                CreatedByInitials = creatorProfile.initials,
                                HasCreatorProfileImage = !string.IsNullOrEmpty(creatorProfile.imageUrl),
                                CreatedAtFormatted = FormatTimestamp(postData, "postedAt"),
                                FileUrls = GetFileUrls(postData),
                                Comments = await LoadCommentsAsync(classId, document.Id)
                            };

                            post.CommentsCount = post.Comments.Count;
                            posts.Add(post);
                            System.Diagnostics.Debug.WriteLine($"Loaded post: {post.Title} by {post.CreatedByName} with {post.CommentsCount} comments");
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error processing post {document.Id}: {ex.Message}");
                            continue; // Skip this post and continue with others
                        }
                    }
                }

                if (posts.Count > 0)
                {
                    rptPosts.DataSource = posts;
                    rptPosts.DataBind();
                    pnlNoPosts.Visible = false;
                    System.Diagnostics.Debug.WriteLine($"Loaded {posts.Count} posts successfully");
                }
                else
                {
                    ShowInfo("No posts found for this classroom.");
                }
            }
            catch (Exception ex)
            {
                ShowError($"Error loading posts: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Post loading error: {ex}");
            }
        }

        // Enhanced LoadCommentsAsync with profile image support
        private async Task<List<CommentEntry>> LoadCommentsAsync(string classId, string postId)
        {
            var comments = new List<CommentEntry>();

            try
            {
                CollectionReference commentsRef = db.Collection("classrooms")
                    .Document(classId)
                    .Collection("posts")
                    .Document(postId)
                    .Collection("comments");

                QuerySnapshot commentsSnapshot = await commentsRef.OrderBy("createdAt").GetSnapshotAsync();

                string currentUserEmail = GetCurrentUserEmail();

                foreach (DocumentSnapshot commentDoc in commentsSnapshot.Documents)
                {
                    if (commentDoc.Exists)
                    {
                        try
                        {
                            Dictionary<string, object> commentData = commentDoc.ToDictionary();
                            string commentKey = postId + "|" + commentDoc.Id;
                            string authorEmail = GetStringValue(commentData, "authorEmail", "");

                            // Load profile info for comment author
                            var authorProfile = await LoadUserProfileImageSync(authorEmail, GetStringValue(commentData, "authorName", "Anonymous"));

                            var comment = new CommentEntry
                            {
                                Id = commentDoc.Id,
                                PostId = postId,
                                Content = GetStringValue(commentData, "content", ""),
                                AuthorEmail = authorEmail,
                                AuthorName = GetStringValue(commentData, "authorName", "Anonymous"),
                                AuthorUserId = authorProfile.userId,
                                AuthorProfileImage = authorProfile.imageUrl,
                                HasAuthorProfileImage = !string.IsNullOrEmpty(authorProfile.imageUrl),
                                CreatedAtFormatted = FormatTimestamp(commentData, "createdAt"),
                                IsOwner = authorEmail == currentUserEmail,
                                IsEditingComment = editingCommentKeys.Contains(commentKey),
                                IsEdited = commentData.ContainsKey("isEdited") && (bool)commentData["isEdited"]
                            };

                            comments.Add(comment);
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error processing comment {commentDoc.Id}: {ex.Message}");
                            continue;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading comments for post {postId}: {ex.Message}");
            }

            return comments;
        }

        private string GetStringValue(Dictionary<string, object> data, string key, string defaultValue = "")
        {
            if (data.ContainsKey(key) && data[key] != null)
            {
                return data[key].ToString();
            }
            return defaultValue;
        }

        private string FormatTimestamp(Dictionary<string, object> data, string key)
        {
            try
            {
                if (data.ContainsKey(key) && data[key] is Timestamp timestamp)
                {
                    DateTime dateTime = timestamp.ToDateTime().ToLocalTime();
                    TimeSpan timeDiff = DateTime.Now - dateTime;

                    if (timeDiff.TotalMinutes < 1)
                        return "Just now";
                    else if (timeDiff.TotalMinutes < 60)
                        return $"{(int)timeDiff.TotalMinutes}m ago";
                    else if (timeDiff.TotalHours < 24)
                        return $"{(int)timeDiff.TotalHours}h ago";
                    else if (timeDiff.TotalDays < 7)
                        return $"{(int)timeDiff.TotalDays}d ago";
                    else
                        return dateTime.ToString("MMM dd, yyyy");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error formatting timestamp: {ex.Message}");
            }
            return "Unknown date";
        }

        private List<string> GetFileUrls(Dictionary<string, object> postData)
        {
            var fileUrls = new List<string>();

            try
            {
                // Check multiple possible field names for files
                string[] possibleFields = { "fileUrls", "fileUtils", "files", "attachments" };

                foreach (string field in possibleFields)
                {
                    if (postData.ContainsKey(field) && postData[field] is List<object> urlsList)
                    {
                        foreach (var url in urlsList)
                        {
                            if (url != null && !string.IsNullOrEmpty(url.ToString()))
                            {
                                fileUrls.Add(url.ToString());
                            }
                        }
                        break; // Found valid field, no need to check others
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting file URLs: {ex.Message}");
            }

            return fileUrls;
        }

        private async Task<string> GetUserDisplayNameAsync(string email)
        {
            if (string.IsNullOrEmpty(email)) return "Unknown User";

            try
            {
                // Try multiple query approaches
                QuerySnapshot userSnap = await db.Collection("users")
                    .WhereEqualTo("email", email.ToLower())
                    .Limit(1)
                    .GetSnapshotAsync();

                if (userSnap.Count == 0)
                {
                    // Try with original case
                    userSnap = await db.Collection("users")
                        .WhereEqualTo("email", email)
                        .Limit(1)
                        .GetSnapshotAsync();
                }

                if (userSnap.Count == 0)
                {
                    // Try with email_lower field
                    userSnap = await db.Collection("users")
                        .WhereEqualTo("email_lower", email.ToLower())
                        .Limit(1)
                        .GetSnapshotAsync();
                }

                if (userSnap.Count > 0 && userSnap.Documents[0].Exists)
                {
                    DocumentSnapshot userDoc = userSnap.Documents[0];
                    var userData = userDoc.ToDictionary();

                    string firstName = GetStringValue(userData, "firstName", "");
                    string lastName = GetStringValue(userData, "lastName", "");

                    if (!string.IsNullOrEmpty(firstName) || !string.IsNullOrEmpty(lastName))
                    {
                        return $"{firstName} {lastName}".Trim();
                    }
                }

                return email; // Fallback to email if name found
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting user display name: {ex.Message}");
                return email;
            }
        }

        // Helper method for file name extraction
        protected string GetFileName(string url)
        {
            try
            {
                if (string.IsNullOrEmpty(url)) return "File";

                Uri uri = new Uri(url);
                string fileName = System.IO.Path.GetFileName(uri.LocalPath);

                if (string.IsNullOrEmpty(fileName))
                {
                    fileName = url.Split('/').Last();
                }

                // Decode URL-encoded characters
                fileName = Uri.UnescapeDataString(fileName);

                return fileName;
            }
            catch
            {
                return "File";
            }
        }

        // Helper method to get initials for avatars
        protected string GetInitials(string name)
        {
            return GenerateUserInitials("", "", name);
        }

        // Enhanced helper methods for current user information with profile image support
        protected string GetCurrentUserName()
        {
            try
            {
                if (Session["username"] != null)
                {
                    return Session["username"].ToString();
                }
                else if (Session["firstName"] != null && Session["lastName"] != null)
                {
                    return $"{Session["firstName"]} {Session["lastName"]}";
                }
                return "Anonymous User";
            }
            catch
            {
                return "Anonymous User";
            }
        }

        protected string GetUserInitials()
        {
            try
            {
                string userName = GetCurrentUserName();
                if (userName == "Anonymous User") return "AU";

                string[] nameParts = userName.Split(' ');
                if (nameParts.Length >= 2)
                {
                    return $"{nameParts[0][0]}{nameParts[1][0]}".ToUpper();
                }
                else if (nameParts.Length == 1 && nameParts[0].Length > 0)
                {
                    return nameParts[0].Substring(0, Math.Min(2, nameParts[0].Length)).ToUpper();
                }
                return "U";
            }
            catch
            {
                return "U";
            }
        }

        // NEW: Methods for current user profile image support
        protected string GetCurrentUserId()
        {
            try
            {
                return currentUserId ?? "";
            }
            catch
            {
                return "";
            }
        }

        protected string GetCurrentUserProfileImage()
        {
            try
            {
                // This would be loaded async in a real scenario, but for the template we'll return empty
                // In a production environment, you'd want to cache this or load it once per page load
                return ""; // Will be loaded by JavaScript or in Page_Load if needed
            }
            catch
            {
                return "";
            }
        }

        protected bool HasCurrentUserProfileImage()
        {
            try
            {
                return false; // Will be determined by JavaScript or in Page_Load if needed
            }
            catch
            {
                return false;
            }
        }

        private string GetCurrentUserEmail()
        {
            try
            {
                return Session["email"]?.ToString() ?? "";
            }
            catch
            {
                return "";
            }
        }

        // Client-side message display method
        private void ShowClientMessage(string message, string type)
        {
            string alertClass = type == "success" ? "success" :
                               type == "warning" ? "warning" :
                               type == "info" ? "info" :
                               "error";

            string script = $@"
                document.addEventListener('DOMContentLoaded', function() {{
                    showToast('{message.Replace("'", "\\'")}', '{alertClass}');
                }});
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "showClientMessage", script, true);
        }

        private void ShowError(string message)
        {
            pnlNoPosts.Visible = true;
            pnlNoPosts.CssClass = "no-posts";
            pnlNoPosts.Controls.Clear();
            pnlNoPosts.Controls.Add(new LiteralControl($@"
                <div class='no-posts-icon'>❌</div>
                <h3>Error</h3>
                <p>{message}</p>
            "));
        }

        private void ShowInfo(string message)
        {
            pnlNoPosts.Visible = true;
            pnlNoPosts.CssClass = "no-posts";
            pnlNoPosts.Controls.Clear();
            pnlNoPosts.Controls.Add(new LiteralControl($@"
                <div class='no-posts-icon'>📮</div>
                <h3>No Posts Yet</h3>
                <p>{message}</p>
            "));
        }
    }

    // Enhanced PostEntry class with profile image support
    public class PostEntry
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Type { get; set; }
        public string Content { get; set; }
        public string CreatedByName { get; set; }
        public string CreatedByUserId { get; set; } = "";
        public string CreatedByProfileImage { get; set; } = "";
        public string CreatedByInitials { get; set; } = "";
        public bool HasCreatorProfileImage { get; set; } = false;
        public string CreatedAtFormatted { get; set; }
        public List<string> FileUrls { get; set; } = new List<string>();
        public List<CommentEntry> Comments { get; set; } = new List<CommentEntry>();
        public int CommentsCount { get; set; } = 0;
    }

    // Enhanced CommentEntry class with profile image support
    public class CommentEntry
    {
        public string Id { get; set; }
        public string PostId { get; set; }
        public string Content { get; set; }
        public string AuthorEmail { get; set; }
        public string AuthorName { get; set; }
        public string AuthorUserId { get; set; } = "";
        public string AuthorProfileImage { get; set; } = "";
        public bool HasAuthorProfileImage { get; set; } = false;
        public string CreatedAtFormatted { get; set; }
        public bool IsOwner { get; set; } = false;
        public bool IsEditingComment { get; set; } = false;
        public bool IsEdited { get; set; } = false;
    }
}