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

                    // Debug feedback data first
                    await DebugFeedbackData();

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
                System.Diagnostics.Debug.WriteLine($"Profile load error: {ex}");

                // Hide loading on error
                pnlClassesLoading.Visible = false;
            }
        }

        private async Task DebugFeedbackData()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"=== DEBUGGING FEEDBACK DATA ===");
                System.Diagnostics.Debug.WriteLine($"Current User ID: '{currentUserId}'");

                // First, let's see ALL feedback documents
                var allFeedbackSnapshot = await db.Collection("feedbacks").GetSnapshotAsync();
                System.Diagnostics.Debug.WriteLine($"Total feedback documents in database: {allFeedbackSnapshot?.Count ?? 0}");

                if (allFeedbackSnapshot != null && allFeedbackSnapshot.Count > 0)
                {
                    System.Diagnostics.Debug.WriteLine("\n=== ALL FEEDBACK DOCUMENTS ===");
                    foreach (var doc in allFeedbackSnapshot.Documents)
                    {
                        var data = doc.ToDictionary();
                        if (data != null)
                        {
                            string userId = GetSafeValue(data, "userId");
                            string description = GetSafeValue(data, "description");

                            System.Diagnostics.Debug.WriteLine($"Doc ID: {doc.Id}");
                            System.Diagnostics.Debug.WriteLine($"  UserId: '{userId}'");
                            System.Diagnostics.Debug.WriteLine($"  Description: '{description?.Substring(0, Math.Min(50, description?.Length ?? 0))}...'");
                            System.Diagnostics.Debug.WriteLine($"  Matches current user: {userId == currentUserId}");
                            System.Diagnostics.Debug.WriteLine("  ---");
                        }
                    }
                }

                // Now try the specific query
                System.Diagnostics.Debug.WriteLine($"\n=== QUERYING FOR USER: {currentUserId} ===");
                var userFeedbackSnapshot = await db.Collection("feedbacks")
                    .WhereEqualTo("userId", currentUserId)
                    .GetSnapshotAsync();

                System.Diagnostics.Debug.WriteLine($"User-specific query returned: {userFeedbackSnapshot?.Count ?? 0} documents");

                if (userFeedbackSnapshot != null && userFeedbackSnapshot.Count > 0)
                {
                    foreach (var doc in userFeedbackSnapshot.Documents)
                    {
                        var data = doc.ToDictionary();
                        if (data != null)
                        {
                            System.Diagnostics.Debug.WriteLine($"Found user feedback: {doc.Id}");
                            System.Diagnostics.Debug.WriteLine($"  Description: '{GetSafeValue(data, "description")}'");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Debug error: {ex.Message}");
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
                System.Diagnostics.Debug.WriteLine($"LoadUserProfile error: {ex}");
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

                // Get classes count (existing logic)
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
                                catch (Exception ex)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Error processing classroom for stats: {ex.Message}");
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
                                catch (Exception ex)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Error checking class archive status for stats: {ex.Message}");
                                }
                            }
                        }
                    }
                }

                // Get feedback count
                var feedbackSnapshot = await db.Collection("feedbacks")
                    .WhereEqualTo("userId", currentUserId)
                    .GetSnapshotAsync();
                feedbackCount = feedbackSnapshot?.Count ?? 0;

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
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error processing book for stats: {ex.Message}");
                        }
                    }
                }

                // Get posts count (existing logic)
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
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error getting saved posts for group {groupDoc.Id}: {ex.Message}");
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

                System.Diagnostics.Debug.WriteLine($"📊 Final stats - Classes: {classesCount}, Posts: {postsCount}, Feedback: {feedbackCount}, Recommended: {recommendedBooksCount}, Favorites: {favoriteBooksCount}, Likes: {totalLikes}, Saved: {savedCount}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserStats error: {ex}");
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

        private async Task LoadUserFeedback()
        {
            try
            {
                var feedbacks = new List<dynamic>();

                System.Diagnostics.Debug.WriteLine($"=== LOADING FEEDBACK FOR USER: {currentUserId} ===");

                // Get user's feedback posts
                var feedbackSnapshot = await db.Collection("feedbacks")
                    .WhereEqualTo("userId", currentUserId)
                    .OrderByDescending("createdAt")
                    .GetSnapshotAsync();

                System.Diagnostics.Debug.WriteLine($"Feedback query returned {feedbackSnapshot?.Count ?? 0} documents");

                if (feedbackSnapshot != null && feedbackSnapshot.Count > 0)
                {
                    foreach (var feedbackDoc in feedbackSnapshot.Documents)
                    {
                        try
                        {
                            var feedbackData = feedbackDoc.ToDictionary();
                            if (feedbackData == null)
                            {
                                System.Diagnostics.Debug.WriteLine($"Feedback document {feedbackDoc.Id} has null data");
                                continue;
                            }

                            System.Diagnostics.Debug.WriteLine($"Processing feedback {feedbackDoc.Id}:");
                            System.Diagnostics.Debug.WriteLine($"  - Description: {GetSafeValue(feedbackData, "description")}");
                            System.Diagnostics.Debug.WriteLine($"  - UserId: {GetSafeValue(feedbackData, "userId")}");

                            // Get likes count
                            var likes = 0;
                            if (feedbackData.ContainsKey("likes") && feedbackData["likes"] != null)
                            {
                                try
                                {
                                    var likesArray = feedbackData["likes"] as List<object>;
                                    likes = likesArray?.Count ?? 0;
                                }
                                catch (Exception ex)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Error parsing likes: {ex.Message}");
                                }
                            }

                            // Get comments count
                            var commentsSnapshot = await feedbackDoc.Reference.Collection("comments").GetSnapshotAsync();
                            int commentCount = commentsSnapshot?.Count ?? 0;

                            // Format created date
                            string createdAt = "Unknown date";
                            if (feedbackData.ContainsKey("createdAt") && feedbackData["createdAt"] != null)
                            {
                                try
                                {
                                    if (feedbackData["createdAt"] is Timestamp timestamp)
                                    {
                                        createdAt = timestamp.ToDateTime().ToString("MMM dd, yyyy 'at' h:mm tt");
                                    }
                                    else if (feedbackData["createdAt"] is DateTime dateTime)
                                    {
                                        createdAt = dateTime.ToString("MMM dd, yyyy 'at' h:mm tt");
                                    }
                                    else
                                    {
                                        System.Diagnostics.Debug.WriteLine($"CreatedAt is of type: {feedbackData["createdAt"].GetType()}");
                                    }
                                }
                                catch (Exception ex)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Error parsing createdAt: {ex.Message}");
                                }
                            }

                            var feedbackItem = new
                            {
                                feedbackId = feedbackDoc.Id,
                                description = TruncateText(GetSafeValue(feedbackData, "description"), 150),
                                createdAt = createdAt,
                                likeCount = likes,
                                commentCount = commentCount,
                                mediaUrl = GetSafeValue(feedbackData, "mediaUrl")
                            };

                            feedbacks.Add(feedbackItem);
                            System.Diagnostics.Debug.WriteLine($"  ✅ Added feedback item: {feedbackItem.description.Substring(0, Math.Min(50, feedbackItem.description.Length))}...");
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"❌ Error processing feedback {feedbackDoc.Id}: {ex.Message}");
                        }
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("❌ No feedback documents found or snapshot is null");
                }

                System.Diagnostics.Debug.WriteLine($"Final feedback count: {feedbacks.Count}");

                // Force visibility before binding
                pnlMyFeedback.Visible = true;
                rptMyFeedback.Visible = true;

                // Bind data
                rptMyFeedback.DataSource = feedbacks;
                rptMyFeedback.DataBind();

                // Set panel visibility
                pnlNoFeedback.Visible = feedbacks.Count == 0;

                System.Diagnostics.Debug.WriteLine($"Repeater items count after binding: {rptMyFeedback.Items.Count}");
                System.Diagnostics.Debug.WriteLine($"pnlNoFeedback.Visible: {pnlNoFeedback.Visible}");

                if (feedbacks.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("❌ NO FEEDBACK WILL BE DISPLAYED");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"✅ {feedbacks.Count} FEEDBACK ITEMS SHOULD BE DISPLAYED");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ CRITICAL ERROR in LoadUserFeedback: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}");
                pnlNoFeedback.Visible = true;
                pnlMyFeedback.Visible = true;
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
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error processing book {bookDoc.Id}: {ex.Message}");
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

                System.Diagnostics.Debug.WriteLine($"Loaded {recommendedBooks.Count} recommended books and {favoriteBooks.Count} favorite books for user");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserBooks error: {ex}");
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

                // Get session data without any modifications first
                string sessionEmail = Session["email"]?.ToString();
                string sessionPosition = Session["position"]?.ToString();
                string sessionUserId = Session["userId"]?.ToString();
                string sessionUsername = Session["username"]?.ToString();

                System.Diagnostics.Debug.WriteLine($"=== COMPLETE DEBUG SESSION INFO ===");
                System.Diagnostics.Debug.WriteLine($"Session UserId: '{sessionUserId}'");
                System.Diagnostics.Debug.WriteLine($"Session Email: '{sessionEmail}'");
                System.Diagnostics.Debug.WriteLine($"Session Username: '{sessionUsername}'");
                System.Diagnostics.Debug.WriteLine($"Session Position: '{sessionPosition}'");
                System.Diagnostics.Debug.WriteLine($"Current UserId Field: '{currentUserId}'");
                System.Diagnostics.Debug.WriteLine($"==========================================");

                // Check if session data exists
                if (string.IsNullOrEmpty(sessionEmail) || string.IsNullOrEmpty(sessionPosition))
                {
                    System.Diagnostics.Debug.WriteLine("❌ SESSION DATA MISSING - redirecting to login");
                    Response.Redirect("Login.aspx");
                    return;
                }

                string userPosition = sessionPosition.ToLower();

                if (userPosition == "teacher")
                {
                    System.Diagnostics.Debug.WriteLine($"🧑‍🏫 TEACHER MODE - Looking for classes created by: '{sessionEmail}'");

                    // First, let's see ALL classrooms in the database
                    System.Diagnostics.Debug.WriteLine("=== DEBUGGING: ALL CLASSROOMS IN DATABASE ===");
                    var allClassroomsSnapshot = await db.Collection("classrooms").GetSnapshotAsync();
                    System.Diagnostics.Debug.WriteLine($"Total classrooms found: {allClassroomsSnapshot?.Count ?? 0}");

                    if (allClassroomsSnapshot != null && allClassroomsSnapshot.Count > 0)
                    {
                        int classIndex = 1;
                        foreach (var classroom in allClassroomsSnapshot.Documents)
                        {
                            try
                            {
                                var classroomData = classroom.ToDictionary();
                                if (classroomData != null)
                                {
                                    string createdBy = GetSafeValue(classroomData, "createdBy");
                                    string name = GetSafeValue(classroomData, "name");
                                    bool isArchived = classroomData.ContainsKey("isArchived") ? Convert.ToBoolean(classroomData["isArchived"]) : false;

                                    System.Diagnostics.Debug.WriteLine($"Classroom #{classIndex}:");
                                    System.Diagnostics.Debug.WriteLine($"  - ID: {classroom.Id}");
                                    System.Diagnostics.Debug.WriteLine($"  - Name: '{name}'");
                                    System.Diagnostics.Debug.WriteLine($"  - CreatedBy: '{createdBy}'");
                                    System.Diagnostics.Debug.WriteLine($"  - IsArchived: {isArchived}");
                                    System.Diagnostics.Debug.WriteLine($"  - Email Match (Exact): {createdBy == sessionEmail}");
                                    System.Diagnostics.Debug.WriteLine($"  - Email Match (Case Insensitive): {string.Equals(createdBy, sessionEmail, StringComparison.OrdinalIgnoreCase)}");
                                    System.Diagnostics.Debug.WriteLine($"  - Should Include: {createdBy == sessionEmail && !isArchived}");
                                    System.Diagnostics.Debug.WriteLine("  ---");

                                    classIndex++;
                                }
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error reading classroom {classroom.Id}: {ex.Message}");
                            }
                        }
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("❌ NO CLASSROOMS FOUND IN DATABASE");
                    }

                    // Use manual filtering instead of compound query to avoid Firestore limitations
                    System.Diagnostics.Debug.WriteLine("=== USING MANUAL FILTERING (more reliable) ===");

                    List<DocumentSnapshot> matchingClassrooms = new List<DocumentSnapshot>();

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
                                    bool isArchived = classroomData.ContainsKey("isArchived") ? Convert.ToBoolean(classroomData["isArchived"]) : false;

                                    // Manual filtering
                                    if (createdBy == sessionEmail && !isArchived)
                                    {
                                        matchingClassrooms.Add(classroom);
                                        System.Diagnostics.Debug.WriteLine($"✅ Manual match found: {GetSafeValue(classroomData, "name")} (ID: {classroom.Id})");
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"Error filtering classroom {classroom.Id}: {ex.Message}");
                            }
                        }
                    }

                    System.Diagnostics.Debug.WriteLine($"📚 Manual filtering found {matchingClassrooms.Count} matching classes");

                    // Process the manually filtered results
                    if (matchingClassrooms.Count > 0)
                    {
                        System.Diagnostics.Debug.WriteLine($"📚 Processing {matchingClassrooms.Count} teacher classes...");

                        foreach (var classDoc in matchingClassrooms)
                        {
                            try
                            {
                                var classData = classDoc.ToDictionary();
                                if (classData == null) continue;

                                System.Diagnostics.Debug.WriteLine($"Processing class: {classDoc.Id} - {GetSafeValue(classData, "name")}");

                                // Get student count
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
                                    catch (Exception ex)
                                    {
                                        System.Diagnostics.Debug.WriteLine($"Error parsing createdAt: {ex.Message}");
                                    }
                                }

                                var classItem = new
                                {
                                    classId = classDoc.Id,
                                    className = GetSafeValue(classData, "name", "Unknown Class"),
                                    teacherName = "You",
                                    schedule = GetSafeValue(classData, "schedule", "Not specified"),
                                    studentCount = invitedStudentsSnapshot?.Count ?? 0,
                                    enrolledAt = createdAtDate
                                };

                                classes.Add(classItem);
                                System.Diagnostics.Debug.WriteLine($"✅ Added class: {classItem.className}");
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"❌ Error processing class {classDoc.Id}: {ex.Message}");
                            }
                        }
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("❌ No matching classrooms found with manual filtering");
                    }
                }
                else
                {
                    // Student logic with debugging
                    System.Diagnostics.Debug.WriteLine($"👨‍🎓 STUDENT MODE - Looking for invitations for: '{sessionEmail}'");

                    var invitedSnapshot = await db.CollectionGroup("invitedStudents")
                        .WhereEqualTo("email", sessionEmail)
                        .WhereEqualTo("status", "accepted")
                        .GetSnapshotAsync();

                    System.Diagnostics.Debug.WriteLine($"Student invitations found: {invitedSnapshot?.Count ?? 0}");

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

                                System.Diagnostics.Debug.WriteLine($"✅ Added student class: {GetSafeValue(classroomData, "name")}");
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine($"❌ Error processing student invitation {inviteDoc.Id}: {ex.Message}");
                            }
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"=== FINAL RESULTS ===");
                System.Diagnostics.Debug.WriteLine($"Total classes to display: {classes.Count}");

                // Bind data
                rptClasses.DataSource = classes;
                rptClasses.DataBind();

                pnlNoClasses.Visible = classes.Count == 0;

                if (classes.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("❌ NO CLASSES WILL BE DISPLAYED");
                    ShowMessage("No classes found. Check debug output for details.", "info");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"✅ {classes.Count} CLASSES WILL BE DISPLAYED");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ CRITICAL ERROR in LoadUserClasses: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}");
                ShowMessage($"Error loading classes: {ex.Message}", "danger");
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

        // Handle feedback deletion
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
                System.Diagnostics.Debug.WriteLine($"Delete feedback error: {ex}");
            }
        }

        // Updated btnUpdateProfile_Click method with comprehensive validation
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

                // Validate email uniqueness (if email field becomes editable in the future)
                string email = txtEmail.Text.Trim().ToLower();
                if (!string.IsNullOrEmpty(email))
                {
                    // Basic email format validation
                    if (!IsValidEmail(email))
                    {
                        ShowMessage("Please enter a valid email address.", "warning");
                        return;
                    }

                    // Check email uniqueness
                    bool isEmailValid = await ValidateFieldUniqueness("email_lower", email);
                    if (!isEmailValid)
                    {
                        ShowMessage("This email address is already registered by another user.", "danger");
                        return;
                    }
                }

                // Validate username uniqueness (if username field becomes editable in the future)
                string username = txtUsername.Text.Trim();
                if (!string.IsNullOrEmpty(username))
                {
                    // Basic username format validation
                    if (username.Length < 3 || username.Length > 20)
                    {
                        ShowMessage("Username must be between 3 and 20 characters long.", "warning");
                        return;
                    }

                    if (!System.Text.RegularExpressions.Regex.IsMatch(username, @"^[a-zA-Z0-9_]+$"))
                    {
                        ShowMessage("Username can only contain letters, numbers, and underscores.", "warning");
                        return;
                    }

                    // Check username uniqueness
                    bool isUsernameValid = await ValidateFieldUniqueness("username", username);
                    if (!isUsernameValid)
                    {
                        ShowMessage("This username is already taken. Please choose a different username.", "danger");
                        return;
                    }
                }

                // Validate birthdate if provided
                if (!string.IsNullOrEmpty(txtBirthdate.Text))
                {
                    if (DateTime.TryParse(txtBirthdate.Text, out DateTime birthDate))
                    {
                        if (birthDate > DateTime.Now)
                        {
                            ShowMessage("Birthdate cannot be in the future.", "warning");
                            return;
                        }

                        if (birthDate < DateTime.Now.AddYears(-120))
                        {
                            ShowMessage("Please enter a valid birthdate.", "warning");
                            return;
                        }
                    }
                    else
                    {
                        ShowMessage("Please enter a valid birthdate.", "warning");
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

                // Add email and username to update if they were modified and are not read-only
                if (!txtEmail.ReadOnly && !string.IsNullOrEmpty(email))
                {
                    updateData["email"] = txtEmail.Text.Trim();
                    updateData["email_lower"] = email;
                }

                if (!txtUsername.ReadOnly && !string.IsNullOrEmpty(username))
                {
                    updateData["username"] = username;
                }

                var userRef = db.Collection("users").Document(currentUserId);
                await userRef.UpdateAsync(updateData);

                // Update profile header display
                ltProfileName.Text = $"{txtFirstName.Text.Trim()} {txtLastName.Text.Trim()}";

                // Update username display if it was changed
                if (!txtUsername.ReadOnly)
                {
                    ltUsername.Text = username;
                }

                ShowMessage("Profile updated successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating profile: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Profile update error: {ex}");
            }
        }

        private async Task<bool> ValidateFieldUniqueness(string fieldName, string fieldValue)
        {
            try
            {
                if (string.IsNullOrEmpty(fieldValue))
                    return true; // Empty values are allowed (not checking uniqueness for empty values)

                // Get the current user's data to compare
                var currentUserRef = db.Collection("users").Document(currentUserId);
                var currentUserSnap = await currentUserRef.GetSnapshotAsync();

                if (currentUserSnap.Exists)
                {
                    var currentUserData = currentUserSnap.ToDictionary();
                    string currentValue = GetSafeValue(currentUserData, fieldName);

                    // If the value hasn't changed, it's valid
                    if (string.Equals(currentValue, fieldValue, StringComparison.OrdinalIgnoreCase))
                    {
                        return true;
                    }
                }

                // Check if any other user has this field value
                var query = db.Collection("users").WhereEqualTo(fieldName, fieldValue);
                var snapshot = await query.GetSnapshotAsync();

                if (snapshot != null && snapshot.Count > 0)
                {
                    // Check if any of the found documents is not the current user
                    foreach (var doc in snapshot.Documents)
                    {
                        if (doc.Id != currentUserId)
                        {
                            return false; // Found another user with the same field value
                        }
                    }
                }

                return true; // No other user has this field value
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error validating field uniqueness for {fieldName}: {ex}");
                return false; // Return false on error to be safe
            }
        }

        // Helper method to validate email format
        private bool IsValidEmail(string email)
        {
            try
            {
                var emailRegex = new System.Text.RegularExpressions.Regex(
                    @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    System.Text.RegularExpressions.RegexOptions.IgnoreCase);

                return emailRegex.IsMatch(email);
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