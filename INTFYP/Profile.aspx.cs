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
                    await LoadUserFeedback();
                    await LoadUserBooks();

                    // Hide loading after everything is loaded
                    pnlClassesLoading.Visible = false;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading profile: " + ex.Message, "danger");
                // Hide loading on error
                pnlClassesLoading.Visible = false;
            }
        }

        private async Task LoadUserFeedback()
        {
            try
            {
                var feedbacks = new List<dynamic>();

                // Get user's feedback posts
                var feedbackSnapshot = await db.Collection("feedbacks")
                    .WhereEqualTo("userId", currentUserId)
                    .GetSnapshotAsync();

                if (feedbackSnapshot != null && feedbackSnapshot.Count > 0)
                {
                    foreach (var feedbackDoc in feedbackSnapshot.Documents)
                    {
                        try
                        {
                            var feedbackData = feedbackDoc.ToDictionary();
                            if (feedbackData == null) continue;

                            // Safely extract description
                            string description = "";
                            if (feedbackData.ContainsKey("description") && feedbackData["description"] != null)
                            {
                                description = feedbackData["description"].ToString().Trim();
                            }
                            else if (feedbackData.ContainsKey("content") && feedbackData["content"] != null)
                            {
                                description = feedbackData["content"].ToString().Trim();
                            }
                            else if (feedbackData.ContainsKey("text") && feedbackData["text"] != null)
                            {
                                description = feedbackData["text"].ToString().Trim();
                            }

                            if (string.IsNullOrWhiteSpace(description)) continue;

                            // Verify userId match
                            string docUserId = GetSafeValue(feedbackData, "userId");
                            if (docUserId != currentUserId) continue;

                            // Get likes count
                            var likes = 0;
                            try
                            {
                                if (feedbackData.ContainsKey("likes") && feedbackData["likes"] != null)
                                {
                                    var likesArray = feedbackData["likes"] as List<object>;
                                    likes = likesArray?.Count ?? 0;
                                }
                            }
                            catch
                            {
                                likes = 0;
                            }

                            // Get comments count
                            int commentCount = 0;
                            try
                            {
                                var commentsSnapshot = await feedbackDoc.Reference.Collection("comments").GetSnapshotAsync();
                                commentCount = commentsSnapshot?.Count ?? 0;
                            }
                            catch
                            {
                                commentCount = 0;
                            }

                            // Format created date
                            string createdAt = "Unknown date";
                            try
                            {
                                if (feedbackData.ContainsKey("createdAt") && feedbackData["createdAt"] != null)
                                {
                                    if (feedbackData["createdAt"] is Timestamp timestamp)
                                    {
                                        createdAt = timestamp.ToDateTime().ToString("MMM dd, yyyy 'at' h:mm tt");
                                    }
                                    else if (feedbackData["createdAt"] is DateTime dateTime)
                                    {
                                        createdAt = dateTime.ToString("MMM dd, yyyy 'at' h:mm tt");
                                    }
                                    else if (DateTime.TryParse(feedbackData["createdAt"].ToString(), out DateTime parsedDate))
                                    {
                                        createdAt = parsedDate.ToString("MMM dd, yyyy 'at' h:mm tt");
                                    }
                                }
                                else if (feedbackData.ContainsKey("timestamp") && feedbackData["timestamp"] != null)
                                {
                                    if (feedbackData["timestamp"] is Timestamp timestamp2)
                                    {
                                        createdAt = timestamp2.ToDateTime().ToString("MMM dd, yyyy 'at' h:mm tt");
                                    }
                                }
                            }
                            catch
                            {
                                createdAt = "Recent";
                            }

                            var feedbackItem = new
                            {
                                feedbackId = feedbackDoc.Id,
                                description = TruncateText(description, 150),
                                fullDescription = description,
                                createdAt = createdAt,
                                likeCount = likes,
                                commentCount = commentCount,
                                mediaUrl = GetSafeValue(feedbackData, "mediaUrl"),
                                hasMedia = !string.IsNullOrEmpty(GetSafeValue(feedbackData, "mediaUrl"))
                            };

                            feedbacks.Add(feedbackItem);
                        }
                        catch
                        {
                            // Skip this feedback item if there's an error
                            continue;
                        }
                    }
                }

                // Sort by creation date if possible
                try
                {
                    feedbacks = feedbacks.OrderByDescending(f => f.createdAt).ToList();
                }
                catch
                {
                    // Keep original order if sorting fails
                }

                // Bind data
                rptMyFeedback.DataSource = feedbacks;
                rptMyFeedback.DataBind();

                // Set empty panel visibility
                pnlNoFeedback.Visible = feedbacks.Count == 0;
            }
            catch (Exception ex)
            {
                pnlNoFeedback.Visible = true;
                ShowMessage($"Error loading feedback: {ex.Message}", "danger");
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
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading user profile: " + ex.Message, "danger");
            }
        }

        private async Task LoadUserStats()
        {
            try
            {
                string userEmail = Session["email"]?.ToString();
                string userPosition = Session["position"]?.ToString()?.ToLower();

                int classesCount = 0;
                int feedbackCount = 0;
                int recommendedBooksCount = 0;
                int favoriteBooksCount = 0;

                // Get classes count
                if (!string.IsNullOrEmpty(userEmail))
                {
                    if (userPosition == "teacher")
                    {
                        var allClassroomsSnapshot = await db.Collection("classrooms").GetSnapshotAsync();

                        if (allClassroomsSnapshot != null)
                        {
                            foreach (var classroom in allClassroomsSnapshot.Documents)
                            {
                                try
                                {
                                    var classroomData = classroom.ToDictionary();
                                    if (classroomData != null)
                                    {
                                        string createdBy = GetSafeValue(classroomData, "createdBy");
                                        bool isArchived = classroomData.ContainsKey("isArchived") ?
                                            Convert.ToBoolean(classroomData["isArchived"]) : false;

                                        if (createdBy == userEmail && !isArchived)
                                        {
                                            classesCount++;
                                        }
                                    }
                                }
                                catch
                                {
                                    // Skip if error processing classroom
                                }
                            }
                        }
                    }
                    else
                    {
                        var invitedSnapshot = await db.CollectionGroup("invitedStudents")
                            .WhereEqualTo("email", userEmail)
                            .WhereEqualTo("status", "accepted")
                            .GetSnapshotAsync();

                        if (invitedSnapshot != null)
                        {
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
                                            bool isArchived = classroomData.ContainsKey("isArchived") &&
                                                            Convert.ToBoolean(classroomData["isArchived"]);
                                            if (!isArchived)
                                            {
                                                classesCount++;
                                            }
                                        }
                                    }
                                }
                                catch
                                {
                                    // Skip if error checking class archive status
                                }
                            }
                        }
                    }
                }

                // Get feedback count
                try
                {
                    var feedbackSnapshot = await db.Collection("feedbacks")
                        .WhereEqualTo("userId", currentUserId)
                        .GetSnapshotAsync();
                    feedbackCount = feedbackSnapshot?.Count ?? 0;
                }
                catch
                {
                    feedbackCount = 0;
                }

                // Get book interactions count
                var booksSnapshot = await db.Collection("books").GetSnapshotAsync();
                if (booksSnapshot != null)
                {
                    foreach (var bookDoc in booksSnapshot.Documents)
                    {
                        try
                        {
                            var bookData = bookDoc.ToDictionary();
                            if (bookData != null)
                            {
                                // Check if user recommended this book
                                var recommendedBy = bookData.ContainsKey("RecommendedBy") && bookData["RecommendedBy"] != null
                                    ? ((List<object>)bookData["RecommendedBy"]).Cast<string>().ToList()
                                    : new List<string>();

                                if (recommendedBy.Contains(currentUserId))
                                {
                                    recommendedBooksCount++;
                                }

                                // Check if user favorited this book
                                var favoritedBy = bookData.ContainsKey("FavoritedBy") && bookData["FavoritedBy"] != null
                                    ? ((List<object>)bookData["FavoritedBy"]).Cast<string>().ToList()
                                    : new List<string>();

                                if (favoritedBy.Contains(currentUserId))
                                {
                                    favoriteBooksCount++;
                                }
                            }
                        }
                        catch
                        {
                            // Skip if error processing book
                        }
                    }
                }

                // Get posts count
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
                        catch
                        {
                            // Skip if error getting posts for group
                        }
                    }
                }

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
                        catch
                        {
                            // Skip if error getting likes for group
                        }
                    }
                }

                // Get saved posts count
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
                        catch
                        {
                            // Skip if error getting saved posts for group
                        }
                    }
                }

                // Update all stats in UI
                ltClassesCount.Text = classesCount.ToString();
                ltPostsCount.Text = postsCount.ToString();
                ltFeedbackCount.Text = feedbackCount.ToString();
                ltRecommendedBooksCount.Text = recommendedBooksCount.ToString();
                ltFavoriteBooksCount.Text = favoriteBooksCount.ToString();
                ltLikesCount.Text = totalLikes.ToString();
                ltSavedCount.Text = savedCount.ToString();
            }
            catch
            {
                // Set default values
                ltClassesCount.Text = "0";
                ltPostsCount.Text = "0";
                ltFeedbackCount.Text = "0";
                ltRecommendedBooksCount.Text = "0";
                ltFavoriteBooksCount.Text = "0";
                ltLikesCount.Text = "0";
                ltSavedCount.Text = "0";
            }
        }

        private async Task LoadUserBooks()
        {
            try
            {
                var recommendedBooks = new List<dynamic>();
                var favoriteBooks = new List<dynamic>();

                // Get all books and filter by user interactions
                var booksSnapshot = await db.Collection("books").GetSnapshotAsync();

                if (booksSnapshot != null)
                {
                    foreach (var bookDoc in booksSnapshot.Documents)
                    {
                        try
                        {
                            var bookData = bookDoc.ToDictionary();
                            if (bookData == null) continue;

                            // Check if user has any interaction with this book
                            var recommendedBy = bookData.ContainsKey("RecommendedBy") && bookData["RecommendedBy"] != null
                                ? ((List<object>)bookData["RecommendedBy"]).Cast<string>().ToList()
                                : new List<string>();

                            var favoritedBy = bookData.ContainsKey("FavoritedBy") && bookData["FavoritedBy"] != null
                                ? ((List<object>)bookData["FavoritedBy"]).Cast<string>().ToList()
                                : new List<string>();

                            bool isRecommended = recommendedBy.Contains(currentUserId);
                            bool isFavorited = favoritedBy.Contains(currentUserId);

                            // Create book item with PDF URL
                            var bookItem = new
                            {
                                bookId = bookDoc.Id,
                                title = GetSafeValue(bookData, "Title", "Unknown Title"),
                                author = GetSafeValue(bookData, "Author", "Unknown Author"),
                                pdfUrl = GetSafeValue(bookData, "PdfUrl", "") // Include PDF URL for preview
                            };

                            // Add to appropriate lists based on user interaction
                            if (isRecommended)
                            {
                                recommendedBooks.Add(bookItem);
                            }
                            if (isFavorited)
                            {
                                favoriteBooks.Add(bookItem);
                            }
                        }
                        catch
                        {
                            // Skip if error processing book
                        }
                    }
                }

                // Sort both lists by title
                recommendedBooks = recommendedBooks.OrderBy(b => b.title).ToList();
                favoriteBooks = favoriteBooks.OrderBy(b => b.title).ToList();

                // Bind data to separate repeaters
                rptRecommendedBooks.DataSource = recommendedBooks;
                rptRecommendedBooks.DataBind();

                rptFavoriteBooks.DataSource = favoriteBooks;
                rptFavoriteBooks.DataBind();

                // Update navigation counts
                ltRecommendedCount.Text = recommendedBooks.Count.ToString();
                ltFavoriteCount.Text = favoriteBooks.Count.ToString();

                // Handle empty states for each section
                pnlNoRecommendedBooks.Visible = recommendedBooks.Count == 0;
                pnlNoFavoriteBooks.Visible = favoriteBooks.Count == 0;
                pnlNoBooks.Visible = recommendedBooks.Count == 0 && favoriteBooks.Count == 0;
            }
            catch
            {
                pnlNoRecommendedBooks.Visible = true;
                pnlNoFavoriteBooks.Visible = true;
                pnlNoBooks.Visible = true;

                // Set default counts
                ltRecommendedCount.Text = "0";
                ltFavoriteCount.Text = "0";
            }
        }

        private async Task LoadUserClasses()
        {
            try
            {
                var classes = new List<dynamic>();

                string sessionEmail = Session["email"]?.ToString();
                string sessionPosition = Session["position"]?.ToString();

                if (string.IsNullOrEmpty(sessionEmail) || string.IsNullOrEmpty(sessionPosition))
                {
                    Response.Redirect("Login.aspx");
                    return;
                }

                string userPosition = sessionPosition.ToLower();

                if (userPosition == "teacher")
                {
                    var allClassroomsSnapshot = await db.Collection("classrooms").GetSnapshotAsync();

                    if (allClassroomsSnapshot != null && allClassroomsSnapshot.Count > 0)
                    {
                        foreach (var classroom in allClassroomsSnapshot.Documents)
                        {
                            try
                            {
                                var classroomData = classroom.ToDictionary();
                                if (classroomData != null)
                                {
                                    string createdBy = GetSafeValue(classroomData, "createdBy");
                                    bool isArchived = classroomData.ContainsKey("isArchived") ? Convert.ToBoolean(classroomData["isArchived"]) : false;

                                    if (createdBy == sessionEmail && !isArchived)
                                    {
                                        // Get student count
                                        var invitedStudentsSnapshot = await classroom.Reference.Collection("invitedStudents")
                                            .WhereEqualTo("status", "accepted")
                                            .GetSnapshotAsync();

                                        string createdAtDate = "Unknown";
                                        if (classroomData.ContainsKey("createdAt") && classroomData["createdAt"] != null)
                                        {
                                            try
                                            {
                                                if (classroomData["createdAt"] is Timestamp timestamp)
                                                {
                                                    createdAtDate = timestamp.ToDateTime().ToString("MMM dd, yyyy");
                                                }
                                            }
                                            catch
                                            {
                                                // Use default date if parsing fails
                                            }
                                        }

                                        var classItem = new
                                        {
                                            classId = classroom.Id,
                                            className = GetSafeValue(classroomData, "name", "Unknown Class"),
                                            teacherName = "You",
                                            schedule = GetSafeValue(classroomData, "schedule", "Not specified"),
                                            studentCount = invitedStudentsSnapshot?.Count ?? 0,
                                            enrolledAt = createdAtDate
                                        };

                                        classes.Add(classItem);
                                    }
                                }
                            }
                            catch
                            {
                                // Skip if error processing class
                            }
                        }
                    }
                }
                else
                {
                    // Student logic
                    var invitedSnapshot = await db.CollectionGroup("invitedStudents")
                        .WhereEqualTo("email", sessionEmail)
                        .WhereEqualTo("status", "accepted")
                        .GetSnapshotAsync();

                    if (invitedSnapshot != null && invitedSnapshot.Count > 0)
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

                                // Get student count
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
                                    catch { }
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
                                    catch { }
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
                            }
                            catch
                            {
                                // Skip if error processing student invitation
                            }
                        }
                    }
                }

                // Bind data
                rptClasses.DataSource = classes;
                rptClasses.DataBind();

                pnlNoClasses.Visible = classes.Count == 0;
            }
            catch (Exception ex)
            {
                ShowMessage($"Error loading classes: {ex.Message}", "danger");
                pnlNoClasses.Visible = true;
            }
        }

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
            catch
            {
                return email;
            }
        }

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
            }
            catch
            {
                pnlNoActivity.Visible = true;
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

        protected async void rptMyFeedback_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "DeleteFeedback")
                {
                    string feedbackId = e.CommandArgument.ToString();

                    // Delete the feedback document
                    await db.Collection("feedbacks").Document(feedbackId).DeleteAsync();

                    ShowMessage("Feedback deleted successfully!", "success");

                    // Reload the user's feedback and stats
                    await LoadUserFeedback();
                    await LoadUserStats();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting feedback: " + ex.Message, "danger");
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

                // Validate and check phone number uniqueness
                string phone = txtPhone.Text.Trim();
                if (!string.IsNullOrEmpty(phone))
                {
                    // Basic phone format validation
                    if (phone.Length < 6 || !phone.All(char.IsDigit))
                    {
                        ShowMessage("Please enter a valid phone number (digits only, at least 6 characters).", "warning");
                        return;
                    }

                    // Check if phone number is already taken by another user
                    bool isPhoneValid = await ValidateFieldUniqueness("phone", phone);
                    if (!isPhoneValid)
                    {
                        ShowMessage("This phone number is already registered by another user. Please use a different phone number.", "danger");
                        return;
                    }
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
            }
        }

        private async Task<bool> ValidateFieldUniqueness(string fieldName, string fieldValue)
        {
            try
            {
                if (string.IsNullOrEmpty(fieldValue))
                    return true;

                var currentUserRef = db.Collection("users").Document(currentUserId);
                var currentUserSnap = await currentUserRef.GetSnapshotAsync();

                if (currentUserSnap.Exists)
                {
                    var currentUserData = currentUserSnap.ToDictionary();
                    string currentValue = GetSafeValue(currentUserData, fieldName);

                    if (string.Equals(currentValue, fieldValue, StringComparison.OrdinalIgnoreCase))
                    {
                        return true;
                    }
                }

                var query = db.Collection("users").WhereEqualTo(fieldName, fieldValue);
                var snapshot = await query.GetSnapshotAsync();

                if (snapshot != null && snapshot.Count > 0)
                {
                    foreach (var doc in snapshot.Documents)
                    {
                        if (doc.Id != currentUserId)
                        {
                            return false;
                        }
                    }
                }

                return true;
            }
            catch
            {
                return false;
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

                if (!file.ContentType.StartsWith("image/"))
                {
                    ShowMessage("Please select a valid image file.", "warning");
                    return;
                }

                if (file.ContentLength > 5 * 1024 * 1024)
                {
                    ShowMessage("Image file size should not exceed 5MB.", "warning");
                    return;
                }

                string imageUrl = await UploadImageToCloudinary(file);

                if (!string.IsNullOrEmpty(imageUrl))
                {
                    var userRef = db.Collection("users").Document(currentUserId);
                    await userRef.UpdateAsync("profileImageUrl", imageUrl);

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
                    return "";
                }
            }
            catch
            {
                return "";
            }
        }

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
                await LoadUserActivity();

                ShowMessage("Post removed from saved items.", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error removing post from saved items: " + ex.Message, "danger");
            }
        }

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

                var saves = new List<string>();
                if (postData.ContainsKey("saves") && postData["saves"] != null)
                {
                    var savesObj = postData["saves"] as List<object>;
                    if (savesObj != null)
                    {
                        saves = savesObj.Cast<string>().ToList();
                    }
                }

                if (saves.Contains(currentUserId))
                {
                    saves.Remove(currentUserId);
                    await postRef.UpdateAsync("saves", saves);
                }
            }
            catch
            {
                throw;
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
            pnlNoActivity.Visible = !HasActivityData();
        }
    }
}