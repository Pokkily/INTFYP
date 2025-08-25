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
using System.Collections;

namespace YourProjectNamespace
{
    public partial class Profile : System.Web.UI.Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        protected string currentUsername;
        private Dictionary<string, object> userData = new Dictionary<string, object>();

        protected async void Page_Load(object sender, EventArgs e)
        {
            // Enhanced session validation
            if (Session["userId"] == null || Session["username"] == null ||
                string.IsNullOrEmpty(Session["userId"].ToString()) ||
                string.IsNullOrEmpty(Session["username"].ToString()))
            {
                Response.Redirect("Login.aspx");
                return;
            }

            try
            {
                // Initialize Firestore
                db = FirestoreDb.Create("intorannetto");
                if (db == null)
                {
                    throw new InvalidOperationException("Failed to initialize Firestore database");
                }

                currentUserId = Session["userId"].ToString();
                currentUsername = Session["username"].ToString();

                if (!IsPostBack)
                {
                    // Show loading initially
                    pnlClassesLoading.Visible = true;

                    await LoadUserProfile();
                    await LoadUserStats();
                    await LoadUserClasses();
                    await LoadUserActivity();

                    // Hide loading after everything is loaded
                    pnlClassesLoading.Visible = false;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading profile: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Profile load error: {ex}");

                // Hide loading on error
                pnlClassesLoading.Visible = false;
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

                // Check if userData is null (this should not happen if document exists, but let's be safe)
                if (userData == null)
                {
                    userData = new Dictionary<string, object>();
                    ShowMessage("Error loading user data.", "danger");
                    return;
                }

                // Safely get values with null checks
                string firstName = GetSafeValue(userData, "firstName");
                string lastName = GetSafeValue(userData, "lastName");
                string username = GetSafeValue(userData, "username");
                string position = GetSafeValue(userData, "position", "Student");

                ltProfileName.Text = $"{firstName} {lastName}";
                ltUsername.Text = username;
                ltPosition.Text = position;

                // Load profile image if exists
                string profileImageUrl = GetSafeValue(userData, "profileImageUrl");
                if (!string.IsNullOrEmpty(profileImageUrl))
                {
                    imgProfile.ImageUrl = profileImageUrl;
                }

                // Populate form fields
                txtFirstName.Text = firstName;
                txtLastName.Text = lastName;
                txtEmail.Text = GetSafeValue(userData, "email");
                txtUsername.Text = username;
                txtPhone.Text = GetSafeValue(userData, "phone");
                txtPosition.Text = position;
                txtAddress.Text = GetSafeValue(userData, "address");

                // Set gender dropdown
                string gender = GetSafeValue(userData, "gender");
                if (!string.IsNullOrEmpty(gender) && ddlGender.Items.FindByValue(gender) != null)
                {
                    ddlGender.SelectedValue = gender;
                }

                // Set birthdate
                string birthdate = GetSafeValue(userData, "birthdate");
                if (!string.IsNullOrEmpty(birthdate))
                {
                    txtBirthdate.Text = birthdate;
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
                string userEmail = Session["email"]?.ToString()?.ToLower();
                string userPosition = Session["position"]?.ToString()?.ToLower();

                int classesCount = 0;

                if (!string.IsNullOrEmpty(userEmail))
                {
                    if (userPosition == "teacher")
                    {
                        // For teachers: count classes they created
                        var teacherClassesSnapshot = await db.Collection("classrooms")
                            .WhereEqualTo("createdBy", userEmail)
                            .WhereEqualTo("isArchived", false) // Only active classes
                            .GetSnapshotAsync();
                        classesCount = teacherClassesSnapshot?.Count ?? 0;
                    }
                    else
                    {
                        // For students: count accepted invitations
                        var invitedSnapshot = await db.CollectionGroup("invitedStudents")
                            .WhereEqualTo("email", userEmail)
                            .WhereEqualTo("status", "accepted")
                            .GetSnapshotAsync();

                        if (invitedSnapshot != null)
                        {
                            // Count only non-archived classes
                            foreach (var inviteDoc in invitedSnapshot.Documents)
                            {
                                try
                                {
                                    var classroomRef = inviteDoc.Reference.Parent.Parent;
                                    var classroomDoc = await classroomRef.GetSnapshotAsync();

                                    if (classroomDoc.Exists)
                                    {
                                        var classroomData = classroomDoc.ToDictionary();
                                        if (classroomData != null)
                                        {
                                            // Only count if not archived
                                            bool isArchived = classroomData.ContainsKey("isArchived") &&
                                                            Convert.ToBoolean(classroomData["isArchived"]);
                                            if (!isArchived)
                                            {
                                                classesCount++;
                                            }
                                        }
                                    }
                                }
                                catch (Exception ex)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Error checking class archive status: {ex.Message}");
                                }
                            }
                        }
                    }
                }

                ltClassesCount.Text = classesCount.ToString();
                System.Diagnostics.Debug.WriteLine($"Classes count updated: {classesCount}");

                // Get posts count (posts created by user)
                var allGroupsSnapshot = await db.Collection("studyHubs").GetSnapshotAsync();
                int postsCount = 0;

                if (allGroupsSnapshot != null)
                {
                    foreach (var groupDoc in allGroupsSnapshot.Documents)
                    {
                        try
                        {
                            var postsSnapshot = await groupDoc.Reference.Collection("posts")
                                .WhereEqualTo("postedBy", currentUserId).GetSnapshotAsync();
                            if (postsSnapshot != null)
                            {
                                postsCount += postsSnapshot.Count;
                            }
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error getting posts for group {groupDoc.Id}: {ex.Message}");
                        }
                    }
                }
                ltPostsCount.Text = postsCount.ToString();

                // Get total likes received
                int totalLikes = 0;
                if (allGroupsSnapshot != null)
                {
                    foreach (var groupDoc in allGroupsSnapshot.Documents)
                    {
                        try
                        {
                            var userPostsSnapshot = await groupDoc.Reference.Collection("posts")
                                .WhereEqualTo("postedBy", currentUserId).GetSnapshotAsync();

                            if (userPostsSnapshot != null)
                            {
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
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error getting likes for group {groupDoc.Id}: {ex.Message}");
                        }
                    }
                }
                ltLikesCount.Text = totalLikes.ToString();

                // Get saved posts count by counting posts where user is in saves array
                int savedCount = 0;
                if (allGroupsSnapshot != null)
                {
                    foreach (var groupDoc in allGroupsSnapshot.Documents)
                    {
                        try
                        {
                            var savedPostsSnapshot = await groupDoc.Reference.Collection("posts")
                                .WhereArrayContains("saves", currentUserId).GetSnapshotAsync();
                            if (savedPostsSnapshot != null)
                            {
                                savedCount += savedPostsSnapshot.Count;
                            }
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error getting saved posts for group {groupDoc.Id}: {ex.Message}");
                        }
                    }
                }
                ltSavedCount.Text = savedCount.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserStats error: {ex}");
                // Set default values
                ltClassesCount.Text = "0";
                ltPostsCount.Text = "0";
                ltLikesCount.Text = "0";
                ltSavedCount.Text = "0";
            }
        }

        private async Task LoadUserClasses()
        {
            try
            {
                var classes = new List<dynamic>();
                string userEmail = Session["email"]?.ToString()?.ToLower();
                string userPosition = Session["position"]?.ToString()?.ToLower();

                if (string.IsNullOrEmpty(userEmail))
                {
                    System.Diagnostics.Debug.WriteLine("User email is empty in LoadUserClasses");
                    pnlNoClasses.Visible = true;
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"Loading classes for user: {userEmail}, position: {userPosition}");

                if (userPosition == "teacher")
                {
                    System.Diagnostics.Debug.WriteLine("Loading classes created by teacher...");

                    // For teachers: get classes they created
                    var teacherClassesSnapshot = await db.Collection("classrooms")
                        .WhereEqualTo("createdBy", userEmail)
                        .WhereEqualTo("isArchived", false) // Only get active classes
                        .GetSnapshotAsync();

                    System.Diagnostics.Debug.WriteLine($"Found {teacherClassesSnapshot?.Count ?? 0} classes created by teacher");

                    if (teacherClassesSnapshot != null)
                    {
                        foreach (var classDoc in teacherClassesSnapshot.Documents)
                        {
                            try
                            {
                                var classData = classDoc.ToDictionary();
                                if (classData == null) continue;

                                // Get student count for this class
                                var invitedStudentsSnapshot = await classDoc.Reference.Collection("invitedStudents")
                                    .WhereEqualTo("status", "accepted")
                                    .GetSnapshotAsync();

                                string createdAtDate = "Unknown";
                                if (classData.ContainsKey("createdAt") && classData["createdAt"] != null)
                                {
                                    try
                                    {
                                        if (classData["createdAt"] is Timestamp timestamp)
                                        {
                                            createdAtDate = timestamp.ToDateTime().ToString("MMM dd, yyyy");
                                        }
                                    }
                                    catch
                                    {
                                        createdAtDate = "Unknown";
                                    }
                                }

                                classes.Add(new
                                {
                                    classId = classDoc.Id,
                                    className = GetSafeValue(classData, "name", "Unknown Class"),
                                    teacherName = "You", // Since this is a class created by the user
                                    schedule = GetSafeValue(classData, "schedule", "Not specified"),
                                    studentCount = invitedStudentsSnapshot?.Count ?? 0,
                                    enrolledAt = createdAtDate
                                });

                                System.Diagnostics.Debug.WriteLine($"Added teacher class: {GetSafeValue(classData, "name")}");
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error processing teacher class {classDoc.Id}: {ex.Message}");
                            }
                        }
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("Loading classes for student...");

                    // For students: get classes they're invited to and accepted
                    var invitedSnapshot = await db.CollectionGroup("invitedStudents")
                        .WhereEqualTo("email", userEmail)
                        .WhereEqualTo("status", "accepted") // Only get accepted invitations
                        .GetSnapshotAsync();

                    System.Diagnostics.Debug.WriteLine($"Found {invitedSnapshot?.Count ?? 0} accepted invitations for student");

                    if (invitedSnapshot != null)
                    {
                        foreach (var inviteDoc in invitedSnapshot.Documents)
                        {
                            try
                            {
                                var inviteData = inviteDoc.ToDictionary();
                                if (inviteData == null) continue;

                                // Get the parent classroom document
                                var classroomRef = inviteDoc.Reference.Parent.Parent;
                                var classroomDoc = await classroomRef.GetSnapshotAsync();

                                if (!classroomDoc.Exists) continue;

                                var classroomData = classroomDoc.ToDictionary();
                                if (classroomData == null) continue;

                                // Skip archived classes
                                if (classroomData.ContainsKey("isArchived") && Convert.ToBoolean(classroomData["isArchived"]))
                                {
                                    continue;
                                }

                                // Get teacher name
                                string creatorEmail = GetSafeValue(classroomData, "createdBy");
                                string teacherName = await GetUserFullName(creatorEmail);

                                // Get student count for this class
                                var studentsSnapshot = await classroomRef.Collection("invitedStudents")
                                    .WhereEqualTo("status", "accepted")
                                    .GetSnapshotAsync();

                                string joinedAtDate = "Unknown";
                                if (inviteData.ContainsKey("acceptedAt") && inviteData["acceptedAt"] != null)
                                {
                                    try
                                    {
                                        if (inviteData["acceptedAt"] is Timestamp timestamp)
                                        {
                                            joinedAtDate = timestamp.ToDateTime().ToString("MMM dd, yyyy");
                                        }
                                    }
                                    catch
                                    {
                                        joinedAtDate = "Unknown";
                                    }
                                }
                                else if (inviteData.ContainsKey("invitedAt") && inviteData["invitedAt"] != null)
                                {
                                    try
                                    {
                                        if (inviteData["invitedAt"] is Timestamp timestamp)
                                        {
                                            joinedAtDate = timestamp.ToDateTime().ToString("MMM dd, yyyy");
                                        }
                                    }
                                    catch
                                    {
                                        joinedAtDate = "Unknown";
                                    }
                                }

                                classes.Add(new
                                {
                                    classId = classroomRef.Id,
                                    className = GetSafeValue(classroomData, "name", "Unknown Class"),
                                    teacherName = teacherName,
                                    schedule = GetSafeValue(classroomData, "schedule", "Not specified"),
                                    studentCount = studentsSnapshot?.Count ?? 0,
                                    enrolledAt = joinedAtDate
                                });

                                System.Diagnostics.Debug.WriteLine($"Added student class: {GetSafeValue(classroomData, "name")}");
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error processing student invitation {inviteDoc.Id}: {ex.Message}");
                            }
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"Total classes found: {classes.Count}");

                rptClasses.DataSource = classes;
                rptClasses.DataBind();

                pnlNoClasses.Visible = classes.Count == 0;

                if (classes.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("No classes found for user");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserClasses error: {ex}");
                pnlNoClasses.Visible = true;
            }
        }

        // Helper method to get user's full name from email
        private async Task<string> GetUserFullName(string email)
        {
            try
            {
                if (string.IsNullOrEmpty(email)) return "Unknown Teacher";

                var userSnapshot = await db.Collection("users")
                    .WhereEqualTo("email_lower", email.ToLower())
                    .GetSnapshotAsync();

                if (userSnapshot != null && userSnapshot.Count > 0)
                {
                    var userDoc = userSnapshot.Documents[0];
                    var userData = userDoc.ToDictionary();
                    if (userData != null)
                    {
                        string firstName = GetSafeValue(userData, "firstName", "");
                        string lastName = GetSafeValue(userData, "lastName", "");

                        if (!string.IsNullOrEmpty(firstName) || !string.IsNullOrEmpty(lastName))
                        {
                            return $"{firstName} {lastName}".Trim();
                        }
                    }
                }
                return email;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in GetUserFullName: {ex.Message}");
                return email;
            }
        }

        // Simplified single method to load all user activity from post documents
        private async Task LoadUserActivity()
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

                            // Get all posts in this group and check engagement arrays
                            var postsSnapshot = await groupDoc.Reference.Collection("posts")
                                .OrderByDescending("timestamp")
                                .GetSnapshotAsync();

                            if (postsSnapshot != null)
                            {
                                foreach (var postDoc in postsSnapshot.Documents)
                                {
                                    var postData = postDoc.ToDictionary();
                                    if (postData == null) continue;

                                    // Check if current user has any engagement with this post
                                    bool isLiked = IsUserInArray(postData, "likes", currentUserId);
                                    bool isSaved = IsUserInArray(postData, "saves", currentUserId);
                                    bool isShared = IsUserInArray(postData, "shares", currentUserId);

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
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error loading posts for group {groupDoc.Id}: {ex.Message}");
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

                System.Diagnostics.Debug.WriteLine($"Activity loaded - Liked: {likedPosts.Count}, Saved: {savedPosts.Count}, Shared: {sharedPosts.Count}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserActivity error: {ex}");
                pnlNoActivity.Visible = true;
            }
        }

        // Helper method to check if user ID is in an array field
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
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error checking user in array {arrayFieldName}: {ex.Message}");
                return false;
            }
        }

        // Helper method to get count of items in an array field
        private int GetArrayCount(Dictionary<string, object> postData, string arrayFieldName)
        {
            try
            {
                if (!postData.ContainsKey(arrayFieldName) || postData[arrayFieldName] == null)
                    return 0;

                var array = postData[arrayFieldName] as List<object>;
                return array?.Count ?? 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting array count for {arrayFieldName}: {ex.Message}");
                return 0;
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
                    if (settings != null)
                    {
                        chkEmailNotifications.Checked = Convert.ToBoolean(GetSafeValue(settings, "emailNotifications", "true"));
                        chkStudyHubNotifications.Checked = Convert.ToBoolean(GetSafeValue(settings, "studyHubNotifications", "true"));
                        chkClassNotifications.Checked = Convert.ToBoolean(GetSafeValue(settings, "classNotifications", "true"));
                    }
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
                    if (privacy != null)
                    {
                        chkPublicProfile.Checked = Convert.ToBoolean(GetSafeValue(privacy, "publicProfile", "true"));
                        chkShowActivity.Checked = Convert.ToBoolean(GetSafeValue(privacy, "showActivity", "true"));
                    }
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
                // Set default values on error
                chkEmailNotifications.Checked = true;
                chkStudyHubNotifications.Checked = true;
                chkClassNotifications.Checked = true;
                chkPublicProfile.Checked = true;
                chkShowActivity.Checked = true;
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
                if (userData == null)
                {
                    ShowMessage("Error accessing user data.", "danger");
                    return;
                }

                string storedPassword = GetSafeValue(userData, "password");

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

        // Handle unsaving posts by updating the post's saves array
        protected async void btnUnsavePost_Click(object sender, EventArgs e)
        {
            try
            {
                var button = sender as LinkButton;
                if (button == null) return;

                string commandArg = button.CommandArgument;
                var args = commandArg.Split('|');

                if (args.Length != 2) return;

                string postId = args[0];
                string groupId = args[1];

                await UnsavePost(postId, groupId);
                await LoadUserActivity(); // Refresh the activity display

                ShowMessage("Post removed from saved items.", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error removing post from saved items: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Unsave post error: {ex}");
            }
        }

        // Simplified unsave method that directly modifies the post's saves array
        private async Task UnsavePost(string postId, string groupId)
        {
            try
            {
                var postRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document(postId);

                var postSnap = await postRef.GetSnapshotAsync();
                if (!postSnap.Exists) return;

                var postData = postSnap.ToDictionary();
                if (postData == null) return;

                // Get current saves array
                var saves = new List<string>();
                if (postData.ContainsKey("saves") && postData["saves"] != null)
                {
                    var savesObj = postData["saves"] as List<object>;
                    if (savesObj != null)
                    {
                        saves = savesObj.Cast<string>().ToList();
                    }
                }

                // Remove current user from saves array if present
                if (saves.Contains(currentUserId))
                {
                    saves.Remove(currentUserId);
                    await postRef.UpdateAsync("saves", saves);
                    System.Diagnostics.Debug.WriteLine($"User {currentUserId} removed from saves of post {postId}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error unsaving post: {ex}");
                throw;
            }
        }

        // Helper method for dictionary access
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

        // Method to check if we have activity data
        protected bool HasActivityData()
        {
            try
            {
                int likedCount = 0;
                int savedCount = 0;
                int sharedCount = 0;

                if (rptLikedPosts.DataSource is IList likedData)
                    likedCount = likedData.Count;

                if (rptSavedPosts.DataSource is IList savedData)
                    savedCount = savedData.Count;

                if (rptSharedPosts.DataSource is IList sharedData)
                    sharedCount = sharedData.Count;

                return likedCount > 0 || savedCount > 0 || sharedCount > 0;
            }
            catch
            {
                return false;
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            // Set visibility of no activity panel based on data
            pnlNoActivity.Visible = !HasActivityData();

            // Add any additional client-side scripts needed
            string script = @"
                console.log('Profile page loaded successfully');
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "profilePageReady", script, true);
        }
    }
}