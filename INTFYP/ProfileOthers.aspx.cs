using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class ProfileOthers : System.Web.UI.Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        protected string currentUsername;
        protected string targetUserId;
        protected bool isProfilePrivate = false;

        protected async void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in
            if (Session["userId"] == null || Session["username"] == null ||
                string.IsNullOrEmpty(Session["userId"].ToString()) ||
                string.IsNullOrEmpty(Session["username"].ToString()))
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Get target user ID from query string
            targetUserId = Request.QueryString["userId"];
            if (string.IsNullOrEmpty(targetUserId))
            {
                Response.Redirect("StudyHub.aspx");
                return;
            }

            // Initialize Firestore and user info
            db = FirestoreDb.Create("intorannetto");
            currentUserId = Session["userId"].ToString();
            currentUsername = Session["username"].ToString();

            // Redirect to own profile if trying to view own profile
            if (targetUserId == currentUserId)
            {
                Response.Redirect("Profile.aspx");
                return;
            }

            if (!IsPostBack)
            {
                await LoadTargetUserProfile();
            }
        }

        private async Task LoadTargetUserProfile()
        {
            try
            {
                // Show loading initially
                pnlActivityLoading.Visible = true;

                // Get target user data from Firestore
                var userRef = db.Collection("users").Document(targetUserId);
                var userSnap = await userRef.GetSnapshotAsync();

                if (!userSnap.Exists)
                {
                    ShowMessage("User not found.", "warning");
                    Response.Redirect("StudyHub.aspx");
                    return;
                }

                var userData = userSnap.ToDictionary();
                if (userData == null)
                {
                    ShowMessage("Error loading user data.", "danger");
                    return;
                }

                // Get user information
                string firstName = GetSafeValue(userData, "firstName", "Unknown");
                string lastName = GetSafeValue(userData, "lastName", "User");
                string username = GetSafeValue(userData, "username", "unknown");
                string position = GetSafeValue(userData, "position", "Student");

                // Check privacy setting
                isProfilePrivate = userData.ContainsKey("profilePrivate") ?
                    Convert.ToBoolean(userData["profilePrivate"]) : false;

                // Update profile header
                ltProfileName.Text = $"{firstName} {lastName}";
                ltUsername.Text = username;
                ltPosition.Text = position;
                ltUserFirstName.Text = firstName;

                // Load profile image if exists
                string profileImageUrl = GetSafeValue(userData, "profileImageUrl");
                if (!string.IsNullOrEmpty(profileImageUrl))
                {
                    imgProfile.ImageUrl = profileImageUrl;
                }
                else
                {
                    // Set default profile image or initials
                    imgProfile.ImageUrl = "Images/dprofile.jpg";
                }

                // Hide loading
                pnlActivityLoading.Visible = false;

                if (isProfilePrivate)
                {
                    // Show privacy blocked section
                    pnlPrivacyBlocked.Visible = true;
                    pnlPublicActivity.Visible = false;
                    pnlPublicStats.Visible = false;
                }
                else
                {
                    // Show public activity
                    pnlPrivacyBlocked.Visible = false;
                    pnlPublicActivity.Visible = true;
                    pnlPublicStats.Visible = true;

                    // Load public stats and activity
                    await LoadPublicStats();
                    await LoadPublicActivity();
                }
            }
            catch (Exception ex)
            {
                pnlActivityLoading.Visible = false;
                ShowMessage("Error loading profile: " + ex.Message, "danger");
            }
        }

        private async Task LoadPublicStats()
        {
            try
            {
                int postsCount = 0;
                int totalLikes = 0;
                int totalActivity = 0;

                // Get all study hub groups
                var allGroupsSnapshot = await db.Collection("studyHubs").GetSnapshotAsync();

                if (allGroupsSnapshot != null)
                {
                    foreach (var groupDoc in allGroupsSnapshot.Documents)
                    {
                        try
                        {
                            // Get posts count for this user
                            var userPostsSnapshot = await groupDoc.Reference.Collection("posts")
                                .WhereEqualTo("postedBy", targetUserId).GetSnapshotAsync();

                            if (userPostsSnapshot != null)
                            {
                                postsCount += userPostsSnapshot.Count;

                                // Count likes received on user's posts
                                foreach (var postDoc in userPostsSnapshot.Documents)
                                {
                                    var postData = postDoc.ToDictionary();
                                    if (postData != null && postData.ContainsKey("likes") && postData["likes"] != null)
                                    {
                                        try
                                        {
                                            var likes = postData["likes"] as List<object>;
                                            if (likes != null)
                                            {
                                                totalLikes += likes.Count;
                                            }
                                        }
                                        catch
                                        {
                                            // Skip if likes format is unexpected
                                        }
                                    }
                                }
                            }

                            // Count user's engagement activities (likes, saves, shares)
                            var allPostsSnapshot = await groupDoc.Reference.Collection("posts").GetSnapshotAsync();
                            if (allPostsSnapshot != null)
                            {
                                foreach (var postDoc in allPostsSnapshot.Documents)
                                {
                                    var postData = postDoc.ToDictionary();
                                    if (postData != null)
                                    {
                                        // Check if user liked this post
                                        if (IsUserInArray(postData, "likes", targetUserId))
                                        {
                                            totalActivity++;
                                        }
                                        // Check if user saved this post
                                        if (IsUserInArray(postData, "saves", targetUserId))
                                        {
                                            totalActivity++;
                                        }
                                        // Check if user shared this post
                                        if (IsUserInArray(postData, "shares", targetUserId))
                                        {
                                            totalActivity++;
                                        }
                                    }
                                }
                            }
                        }
                        catch
                        {
                            // Skip if error getting data for this group
                        }
                    }
                }

                // Update UI
                ltPostsCount.Text = postsCount.ToString();
                ltLikesCount.Text = totalLikes.ToString();
                ltActivityCount.Text = totalActivity.ToString();
            }
            catch
            {
                // Set default values on error
                ltPostsCount.Text = "0";
                ltLikesCount.Text = "0";
                ltActivityCount.Text = "0";
            }
        }

        private async Task LoadPublicActivity()
        {
            try
            {
                var likedPosts = new List<dynamic>();
                var savedPosts = new List<dynamic>();
                var sharedPosts = new List<dynamic>();

                // Get all study hub groups
                var allGroupsSnapshot = await db.Collection("studyHubs").GetSnapshotAsync();

                if (allGroupsSnapshot != null)
                {
                    foreach (var groupDoc in allGroupsSnapshot.Documents)
                    {
                        try
                        {
                            var groupData = groupDoc.ToDictionary();
                            string groupName = GetSafeValue(groupData, "groupName", "Unknown Group");

                            // Get all posts in this group and check target user's engagement
                            var postsSnapshot = await groupDoc.Reference.Collection("posts")
                                .OrderByDescending("timestamp")
                                .GetSnapshotAsync();

                            if (postsSnapshot != null)
                            {
                                foreach (var postDoc in postsSnapshot.Documents)
                                {
                                    var postData = postDoc.ToDictionary();
                                    if (postData == null) continue;

                                    // Check if target user has any engagement with this post
                                    bool isLiked = IsUserInArray(postData, "likes", targetUserId);
                                    bool isSaved = IsUserInArray(postData, "saves", targetUserId);
                                    bool isShared = IsUserInArray(postData, "shares", targetUserId);

                                    // Skip if user has no engagement with this post
                                    if (!isLiked && !isSaved && !isShared) continue;

                                    // Get comment count
                                    var commentsSnapshot = await postDoc.Reference.Collection("comments").GetSnapshotAsync();

                                    // Get engagement counts directly from the arrays
                                    int likeCount = GetArrayCount(postData, "likes");
                                    int shareCount = GetArrayCount(postData, "shares");

                                    // Format timestamp
                                    string timestamp = "";
                                    DateTime postDateTime = DateTime.MinValue;
                                    if (postData.ContainsKey("timestamp") && postData["timestamp"] != null)
                                    {
                                        try
                                        {
                                            if (postData["timestamp"] is Timestamp ts)
                                            {
                                                postDateTime = ts.ToDateTime();
                                                timestamp = postDateTime.ToString("MMM dd, yyyy 'at' h:mm tt");
                                            }
                                        }
                                        catch { timestamp = "Unknown date"; }
                                    }

                                    var postItem = new
                                    {
                                        postId = postDoc.Id,
                                        groupId = groupDoc.Id,
                                        groupName = groupName,
                                        content = TruncateText(GetSafeValue(postData, "content"), 150),
                                        authorName = GetSafeValue(postData, "postedByName", "Unknown"),
                                        timestamp = timestamp,
                                        sortTimestamp = postDateTime,
                                        likeCount = likeCount,
                                        commentCount = commentsSnapshot?.Count ?? 0,
                                        shareCount = shareCount,
                                        isLiked = isLiked,
                                        isSaved = isSaved,
                                        isShared = isShared
                                    };

                                    // Add to appropriate lists based on user engagement
                                    if (isLiked)
                                    {
                                        likedPosts.Add(postItem);
                                    }
                                    if (isSaved)
                                    {
                                        savedPosts.Add(postItem);
                                    }
                                    if (isShared)
                                    {
                                        sharedPosts.Add(postItem);
                                    }
                                }
                            }
                        }
                        catch
                        {
                            // Skip if error loading posts for group
                        }
                    }
                }

                // Sort all lists by timestamp (most recent first) and limit
                likedPosts = likedPosts.OrderByDescending(p => ((DateTime)p.sortTimestamp)).Take(50).ToList();
                savedPosts = savedPosts.OrderByDescending(p => ((DateTime)p.sortTimestamp)).Take(50).ToList();
                sharedPosts = sharedPosts.OrderByDescending(p => ((DateTime)p.sortTimestamp)).Take(50).ToList();

                // Bind to repeaters
                rptLikedPosts.DataSource = likedPosts;
                rptLikedPosts.DataBind();

                rptSavedPosts.DataSource = savedPosts;
                rptSavedPosts.DataBind();

                rptSharedPosts.DataSource = sharedPosts;
                rptSharedPosts.DataBind();

                // Check if we have any activity data
                bool hasActivity = likedPosts.Count > 0 || savedPosts.Count > 0 || sharedPosts.Count > 0;
                pnlNoActivity.Visible = !hasActivity;
                pnlActivityContent.Visible = true;
            }
            catch
            {
                pnlNoActivity.Visible = true;
                pnlActivityContent.Visible = true;
            }
        }

        private bool IsUserInArray(Dictionary<string, object> postData, string arrayFieldName, string userId)
        {
            try
            {
                if (!postData.ContainsKey(arrayFieldName) || postData[arrayFieldName] == null)
                    return false;

                var array = postData[arrayFieldName] as List<object>;
                if (array == null) return false;

                return array.Cast<string>().Contains(userId);
            }
            catch
            {
                return false;
            }
        }

        private int GetArrayCount(Dictionary<string, object> postData, string arrayFieldName)
        {
            try
            {
                if (!postData.ContainsKey(arrayFieldName) || postData[arrayFieldName] == null)
                    return 0;

                var array = postData[arrayFieldName] as List<object>;
                return array?.Count ?? 0;
            }
            catch
            {
                return 0;
            }
        }

        private string GetSafeValue(Dictionary<string, object> dictionary, string key, string defaultValue = "")
        {
            if (dictionary == null || !dictionary.ContainsKey(key) || dictionary[key] == null)
            {
                return defaultValue;
            }
            return dictionary[key].ToString();
        }

        private string TruncateText(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text) || text.Length <= maxLength)
                return text ?? "";

            return text.Substring(0, maxLength) + "...";
        }

        private void ShowMessage(string message, string type)
        {
            string script = $@"
                showNotification('{message.Replace("'", "\\'")}', '{type}');
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "showMessage", script, true);
        }
    }
}