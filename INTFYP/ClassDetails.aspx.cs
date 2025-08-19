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

        protected async void Page_Load(object sender, EventArgs e)
        {
            try
            {
                InitializeFirestore();

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
                    ["postId"] = postId
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

        // AJAX Web Method for adding comments
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

                System.Diagnostics.Debug.WriteLine($"User info: email={currentUserEmail}, name={currentUserName}");

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
                    ["postId"] = postId
                };

                await commentRef.SetAsync(commentData);
                System.Diagnostics.Debug.WriteLine("Comment added to Firestore successfully");

                // Return success with comment data for immediate UI update
                var result = new
                {
                    success = true,
                    comment = new
                    {
                        content = commentText.Trim(),
                        authorName = currentUserName,
                        authorInitials = GetInitialsFromName(currentUserName),
                        createdAt = DateTime.Now
                    }
                };

                System.Diagnostics.Debug.WriteLine($"Returning result: success=true, authorName={currentUserName}");
                return result;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AJAX AddComment error: {ex.Message}\nStack trace: {ex.StackTrace}");
                return new { success = false, error = $"Failed to post comment: {ex.Message}" };
            }
        }

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

        // Get current username
        private string GetCurrentUsername()
        {
            try
            {
                if (Session != null && Session["username"] != null)
                {
                    return Session["username"].ToString();
                }
                else if (Session != null && Session["firstName"] != null && Session["lastName"] != null)
                {
                    return $"{Session["firstName"]} {Session["lastName"]}";
                }
                else if (Session != null && Session["email"] != null)
                {
                    return Session["email"].ToString();
                }
                return string.Empty;
            }
            catch
            {
                return string.Empty;
            }
        }

        // Get current user position
        private string GetCurrentUserPosition()
        {
            try
            {
                if (Session != null && Session["position"] != null)
                {
                    return Session["position"].ToString();
                }
                return "Student"; // Default to Student
            }
            catch
            {
                return "Student";
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

                            var post = new PostEntry
                            {
                                Id = document.Id,
                                Title = GetStringValue(postData, "title", "No Title"),
                                Type = GetStringValue(postData, "postType", "Post"),
                                Content = GetStringValue(postData, "content", ""),
                                CreatedByName = await GetUserDisplayNameAsync(GetStringValue(postData, "createdBy", "")),
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

                foreach (DocumentSnapshot commentDoc in commentsSnapshot.Documents)
                {
                    if (commentDoc.Exists)
                    {
                        try
                        {
                            Dictionary<string, object> commentData = commentDoc.ToDictionary();

                            var comment = new CommentEntry
                            {
                                Id = commentDoc.Id,
                                Content = GetStringValue(commentData, "content", ""),
                                AuthorEmail = GetStringValue(commentData, "authorEmail", ""),
                                AuthorName = GetStringValue(commentData, "authorName", "Anonymous"),
                                CreatedAtFormatted = FormatTimestamp(commentData, "createdAt")
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

        // Helper methods for user information
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

    public class PostEntry
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Type { get; set; }
        public string Content { get; set; }
        public string CreatedByName { get; set; }
        public string CreatedAtFormatted { get; set; }
        public List<string> FileUrls { get; set; } = new List<string>();
        public List<CommentEntry> Comments { get; set; } = new List<CommentEntry>();
        public int CommentsCount { get; set; } = 0;
    }

    public class CommentEntry
    {
        public string Id { get; set; }
        public string Content { get; set; }
        public string AuthorEmail { get; set; }
        public string AuthorName { get; set; }
        public string CreatedAtFormatted { get; set; }
    }
}