using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class ChatRoom : System.Web.UI.Page
    {
        private FirestoreDb db;
        private string currentUserEmail;
        private string currentUserName;

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            currentUserEmail = Session["email"]?.ToString();
            currentUserName = Session["username"]?.ToString() ?? "Anonymous";

            if (string.IsNullOrEmpty(currentUserEmail))
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadMyRoomsAsync();
                UpdateRoomCounts();
            }

            // Handle different postback events
            if (Request["__EVENTTARGET"] == "LoadRoom")
            {
                string roomId = Request["__EVENTARGUMENT"];
                if (!string.IsNullOrEmpty(roomId))
                {
                    hfCurrentRoomId.Value = roomId;
                    LoadCurrentRoomAsync();
                }
            }
            else if (Request["__EVENTTARGET"] == "LoadDirectChats")
            {
                LoadDirectChatsAsync();
            }
            else if (!string.IsNullOrEmpty(hfCurrentRoomId.Value))
            {
                LoadCurrentRoomAsync();
            }
        }

        private void InitializeFirestore()
        {
            try
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto");
            }
            catch (Exception ex)
            {
                ShowMessage("Error initializing database: " + ex.Message, "text-danger");
            }
        }

        private async void LoadMyRoomsAsync()
        {
            try
            {
                var rooms = new List<ChatRoomInfo>();

                // Get all rooms and check membership individually
                var allRoomsQuery = db.Collection("chatRooms")
                    .WhereEqualTo("status", "active")
                    .WhereEqualTo("type", "group") // Only get group rooms, not direct chats
                    .Limit(100);

                var allRoomsSnapshot = await allRoomsQuery.GetSnapshotAsync();

                foreach (var roomDoc in allRoomsSnapshot.Documents)
                {
                    // Check if current user is a member of this room
                    var memberDoc = await roomDoc.Reference.Collection("members")
                        .Document(currentUserEmail).GetSnapshotAsync();

                    if (memberDoc.Exists)
                    {
                        var memberData = memberDoc.ToDictionary();
                        string status = GetSafeValue(memberData, "status", "");

                        // Only include active memberships
                        if (status == "active")
                        {
                            var roomData = roomDoc.ToDictionary();

                            // Get member count
                            var membersSnapshot = await roomDoc.Reference.Collection("members")
                                .WhereEqualTo("status", "active")
                                .GetSnapshotAsync();

                            // Get last activity
                            string lastActivity = "No recent activity";
                            if (roomData.ContainsKey("lastActivity"))
                            {
                                var timestamp = ((Timestamp)roomData["lastActivity"]).ToDateTime();
                                lastActivity = FormatRelativeTime(timestamp);
                            }

                            rooms.Add(new ChatRoomInfo
                            {
                                Id = roomDoc.Id,
                                Name = GetSafeValue(roomData, "name", "Unnamed Room"),
                                Description = GetSafeValue(roomData, "description", ""),
                                MemberCount = membersSnapshot.Count,
                                LastActivity = lastActivity,
                                CreatedBy = GetCreatorName(GetSafeValue(roomData, "createdBy", "")),
                                IsPublic = false // All rooms are private now
                            });
                        }
                    }
                }

                rptMyRooms.DataSource = rooms.OrderByDescending(r => r.LastActivity).ToList();
                rptMyRooms.DataBind();

                lblMyRoomCount.Text = rooms.Count.ToString();

                // Show/hide empty state
                pnlNoMyRooms.Visible = rooms.Count == 0;
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading your rooms: " + ex.Message, "text-danger");
            }
        }

        private async void LoadDirectChatsAsync()
        {
            try
            {
                var directChats = new List<ChatRoomInfo>();

                // Get all direct chat rooms where current user is a member
                var directChatsQuery = db.Collection("chatRooms")
                    .WhereEqualTo("status", "active")
                    .WhereEqualTo("type", "direct")
                    .Limit(100);

                var directChatsSnapshot = await directChatsQuery.GetSnapshotAsync();

                foreach (var roomDoc in directChatsSnapshot.Documents)
                {
                    // Check if current user is a member of this direct chat
                    var memberDoc = await roomDoc.Reference.Collection("members")
                        .Document(currentUserEmail).GetSnapshotAsync();

                    if (memberDoc.Exists)
                    {
                        var memberData = memberDoc.ToDictionary();
                        string status = GetSafeValue(memberData, "status", "");

                        if (status == "active")
                        {
                            var roomData = roomDoc.ToDictionary();

                            // Get the other participant's name for display
                            var allMembers = await roomDoc.Reference.Collection("members")
                                .WhereEqualTo("status", "active")
                                .GetSnapshotAsync();

                            string chatName = "Direct Chat";
                            foreach (var member in allMembers.Documents)
                            {
                                var memberInfo = member.ToDictionary();
                                string memberEmail = GetSafeValue(memberInfo, "email", "");
                                if (memberEmail != currentUserEmail)
                                {
                                    chatName = GetSafeValue(memberInfo, "name", memberEmail);
                                    break;
                                }
                            }

                            // Get last activity
                            string lastActivity = "No recent activity";
                            if (roomData.ContainsKey("lastActivity"))
                            {
                                var timestamp = ((Timestamp)roomData["lastActivity"]).ToDateTime();
                                lastActivity = FormatRelativeTime(timestamp);
                            }

                            directChats.Add(new ChatRoomInfo
                            {
                                Id = roomDoc.Id,
                                Name = chatName,
                                Description = "",
                                MemberCount = 2,
                                LastActivity = lastActivity,
                                CreatedBy = "",
                                IsPublic = false
                            });
                        }
                    }
                }

                rptDirectChats.DataSource = directChats.OrderByDescending(r => r.LastActivity).ToList();
                rptDirectChats.DataBind();

                lblDirectChatCount.Text = directChats.Count.ToString();

                // Show/hide empty state
                pnlNoDirectChats.Visible = directChats.Count == 0;
            }
            catch (Exception ex)
            {
                ShowSearchMessage("Error loading direct chats: " + ex.Message, "text-danger");
            }
        }

        protected async void btnSearchUser_Click(object sender, EventArgs e)
        {
            string searchEmail = txtUserSearch.Text.Trim().ToLower();

            if (string.IsNullOrEmpty(searchEmail))
            {
                ShowSearchMessage("Please enter an email address", "text-danger");
                return;
            }

            if (searchEmail == currentUserEmail.ToLower())
            {
                ShowSearchMessage("You cannot start a chat with yourself", "text-warning");
                return;
            }

            try
            {
                var userResults = new List<UserSearchResult>();

                // Search for user by email
                var userSnapshot = await db.Collection("users")
                    .WhereEqualTo("email", searchEmail)
                    .GetSnapshotAsync();

                if (userSnapshot.Count > 0)
                {
                    var userDoc = userSnapshot.Documents[0];
                    var userData = userDoc.ToDictionary();

                    string firstName = GetSafeValue(userData, "firstName", "");
                    string lastName = GetSafeValue(userData, "lastName", "");
                    string fullName = $"{firstName} {lastName}".Trim();

                    if (string.IsNullOrEmpty(fullName))
                    {
                        fullName = searchEmail.Split('@')[0];
                    }

                    userResults.Add(new UserSearchResult
                    {
                        Email = searchEmail,
                        Name = fullName
                    });

                    rptUserSearchResults.DataSource = userResults;
                    rptUserSearchResults.DataBind();
                    pnlUserSearchResults.Visible = true;

                    ShowSearchMessage("User found!", "text-success");
                }
                else
                {
                    pnlUserSearchResults.Visible = false;
                    ShowSearchMessage("User not found", "text-danger");
                }
            }
            catch (Exception ex)
            {
                pnlUserSearchResults.Visible = false;
                ShowSearchMessage("Error searching for user: " + ex.Message, "text-danger");
            }
        }

        protected async void rptUserSearchResults_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "StartChat")
            {
                string targetUserEmail = e.CommandArgument.ToString();
                await StartDirectChatAsync(targetUserEmail);
            }
        }

        private async Task StartDirectChatAsync(string targetUserEmail)
        {
            try
            {
                // Check if direct chat already exists between these users
                var existingChatsQuery = db.Collection("chatRooms")
                    .WhereEqualTo("type", "direct")
                    .WhereEqualTo("status", "active");

                var existingChatsSnapshot = await existingChatsQuery.GetSnapshotAsync();

                foreach (var chatDoc in existingChatsSnapshot.Documents)
                {
                    var membersSnapshot = await chatDoc.Reference.Collection("members")
                        .WhereEqualTo("status", "active")
                        .GetSnapshotAsync();

                    var memberEmails = new List<string>();
                    foreach (var member in membersSnapshot.Documents)
                    {
                        var memberData = member.ToDictionary();
                        memberEmails.Add(GetSafeValue(memberData, "email", ""));
                    }

                    // Check if this chat has exactly these two users
                    if (memberEmails.Count == 2 &&
                        memberEmails.Contains(currentUserEmail) &&
                        memberEmails.Contains(targetUserEmail))
                    {
                        // Direct chat already exists, just select it
                        hfCurrentRoomId.Value = chatDoc.Id;
                        LoadCurrentRoomAsync();
                        ShowSearchMessage("Opened existing chat", "text-success");
                        return;
                    }
                }

                // Get target user info
                var userSnapshot = await db.Collection("users")
                    .WhereEqualTo("email", targetUserEmail)
                    .GetSnapshotAsync();

                if (userSnapshot.Count == 0)
                {
                    ShowSearchMessage("User not found", "text-danger");
                    return;
                }

                var targetUser = userSnapshot.Documents[0].ToDictionary();
                string targetUserName = GetSafeValue(targetUser, "firstName", "") + " " + GetSafeValue(targetUser, "lastName", "");
                if (string.IsNullOrEmpty(targetUserName.Trim()))
                {
                    targetUserName = targetUserEmail.Split('@')[0];
                }

                // Create new direct chat
                var chatRef = db.Collection("chatRooms").Document();
                var chatData = new Dictionary<string, object>
                {
                    { "name", $"Direct Chat" },
                    { "type", "direct" },
                    { "createdBy", currentUserEmail },
                    { "createdAt", FieldValue.ServerTimestamp },
                    { "lastActivity", FieldValue.ServerTimestamp },
                    { "status", "active" }
                };

                await chatRef.SetAsync(chatData);

                // Add both users as members
                await chatRef.Collection("members").Document(currentUserEmail).SetAsync(new
                {
                    email = currentUserEmail,
                    name = currentUserName,
                    role = "member",
                    joinedAt = FieldValue.ServerTimestamp,
                    status = "active",
                    lastSeen = FieldValue.ServerTimestamp
                });

                await chatRef.Collection("members").Document(targetUserEmail).SetAsync(new
                {
                    email = targetUserEmail,
                    name = targetUserName,
                    role = "member",
                    joinedAt = FieldValue.ServerTimestamp,
                    status = "active",
                    lastSeen = FieldValue.ServerTimestamp
                });

                // Add welcome message
                await chatRef.Collection("messages").AddAsync(new
                {
                    senderId = "system",
                    senderName = "System",
                    content = $"{currentUserName} started a chat with {targetUserName}",
                    type = "system",
                    timestamp = FieldValue.ServerTimestamp
                });

                // Clear search and select new chat
                txtUserSearch.Text = "";
                pnlUserSearchResults.Visible = false;
                hfCurrentRoomId.Value = chatRef.Id;
                LoadCurrentRoomAsync();
                LoadDirectChatsAsync();

                ShowSearchMessage($"Started chat with {targetUserName}!", "text-success");

                // Switch to direct chat tab
                ClientScript.RegisterStartupScript(this.GetType(), "switchToDirectChat",
                    "setTimeout(() => switchTab('direct-chat'), 500);", true);
            }
            catch (Exception ex)
            {
                ShowSearchMessage("Error starting chat: " + ex.Message, "text-danger");
            }
        }

        protected async void btnCreateRoom_Click(object sender, EventArgs e)
        {
            string roomName = txtRoomName.Text.Trim();
            string description = txtDescription.Text.Trim();

            if (string.IsNullOrEmpty(roomName))
            {
                ShowMessage("Please enter a room name", "text-danger");
                return;
            }

            try
            {
                // Create new group room (always private now)
                var roomRef = db.Collection("chatRooms").Document();
                var roomData = new Dictionary<string, object>
                {
                    { "name", roomName },
                    { "description", description },
                    { "type", "group" },
                    { "createdBy", currentUserEmail },
                    { "createdAt", FieldValue.ServerTimestamp },
                    { "lastActivity", FieldValue.ServerTimestamp },
                    { "status", "active" }
                };

                await roomRef.SetAsync(roomData);

                // Add creator as admin member
                await roomRef.Collection("members").Document(currentUserEmail).SetAsync(new
                {
                    email = currentUserEmail,
                    name = currentUserName,
                    role = "admin",
                    joinedAt = FieldValue.ServerTimestamp,
                    status = "active",
                    lastSeen = FieldValue.ServerTimestamp
                });

                // Add welcome message
                await roomRef.Collection("messages").AddAsync(new
                {
                    senderId = "system",
                    senderName = "System",
                    content = $"Welcome to {roomName}! This room was created by {currentUserName}.",
                    type = "system",
                    timestamp = FieldValue.ServerTimestamp
                });

                // Clear form and refresh
                txtRoomName.Text = "";
                txtDescription.Text = "";
                ShowMessage($"Room '{roomName}' created successfully!", "text-success");

                LoadMyRoomsAsync();
                UpdateRoomCounts();

                // Auto-select the new room
                hfCurrentRoomId.Value = roomRef.Id;
                LoadCurrentRoomAsync();

                // Switch to My Rooms tab
                ClientScript.RegisterStartupScript(this.GetType(), "switchToMyRooms",
                    "setTimeout(() => switchTab('my-rooms'), 500);", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating room: " + ex.Message, "text-danger");
            }
        }

        protected async void btnLeaveRoom_Click(object sender, EventArgs e)
        {
            string roomId = hfCurrentRoomId.Value;
            if (string.IsNullOrEmpty(roomId)) return;

            try
            {
                var roomRef = db.Collection("chatRooms").Document(roomId);
                var roomSnapshot = await roomRef.GetSnapshotAsync();

                if (!roomSnapshot.Exists) return;

                var roomData = roomSnapshot.ToDictionary();
                string roomName = GetSafeValue(roomData, "name", "Unknown Room");

                // Update member status to left
                await roomRef.Collection("members").Document(currentUserEmail)
                    .UpdateAsync("status", "left");

                // Add system message
                await roomRef.Collection("messages").AddAsync(new
                {
                    senderId = "system",
                    senderName = "System",
                    content = $"{currentUserName} left the chat",
                    type = "system",
                    timestamp = FieldValue.ServerTimestamp
                });

                // Update room last activity
                await roomRef.UpdateAsync("lastActivity", FieldValue.ServerTimestamp);

                ShowMessage($"You left '{roomName}'", "text-success");

                // Clear current room and refresh
                hfCurrentRoomId.Value = "";
                pnlNoRoom.Visible = true;
                pnlChatInterface.Visible = false;

                LoadMyRoomsAsync();
                LoadDirectChatsAsync();
                UpdateRoomCounts();
            }
            catch (Exception ex)
            {
                ShowMessage("Error leaving room: " + ex.Message, "text-danger");
            }
        }

        protected async void btnSend_Click(object sender, EventArgs e)
        {
            string message = txtMessage.Text.Trim();
            string roomId = hfCurrentRoomId.Value;

            if (string.IsNullOrEmpty(message) || string.IsNullOrEmpty(roomId))
            {
                return;
            }

            try
            {
                var roomRef = db.Collection("chatRooms").Document(roomId);

                // Add message
                await roomRef.Collection("messages").AddAsync(new
                {
                    senderId = currentUserEmail,
                    senderName = currentUserName,
                    content = message,
                    type = "text",
                    timestamp = FieldValue.ServerTimestamp,
                    edited = false
                });

                // Update room last activity
                await roomRef.UpdateAsync("lastActivity", FieldValue.ServerTimestamp);

                // Update user's last seen
                await roomRef.Collection("members").Document(currentUserEmail)
                    .UpdateAsync("lastSeen", FieldValue.ServerTimestamp);

                txtMessage.Text = "";
                LoadCurrentRoomAsync(); // Refresh messages
            }
            catch (Exception ex)
            {
                ShowMessage("Error sending message: " + ex.Message, "text-danger");
            }
        }

        private async void LoadCurrentRoomAsync()
        {
            string roomId = hfCurrentRoomId.Value;
            if (string.IsNullOrEmpty(roomId))
            {
                pnlNoRoom.Visible = true;
                pnlChatInterface.Visible = false;
                return;
            }

            try
            {
                var roomRef = db.Collection("chatRooms").Document(roomId);
                var roomSnapshot = await roomRef.GetSnapshotAsync();

                if (!roomSnapshot.Exists)
                {
                    ShowMessage("Room not found", "text-danger");
                    return;
                }

                var roomData = roomSnapshot.ToDictionary();
                string roomType = GetSafeValue(roomData, "type", "group");

                // Get member count and room name
                var membersSnapshot = await roomRef.Collection("members")
                    .WhereEqualTo("status", "active")
                    .GetSnapshotAsync();

                string roomName;
                if (roomType == "direct")
                {
                    // For direct chats, show the other participant's name
                    roomName = "Direct Chat";
                    foreach (var member in membersSnapshot.Documents)
                    {
                        var memberInfo = member.ToDictionary();
                        string memberEmail = GetSafeValue(memberInfo, "email", "");
                        if (memberEmail != currentUserEmail)
                        {
                            roomName = GetSafeValue(memberInfo, "name", memberEmail);
                            break;
                        }
                    }
                }
                else
                {
                    roomName = GetSafeValue(roomData, "name", "Unnamed Room");
                }

                // Update UI
                lblCurrentRoom.Text = roomName;
                lblMemberCount.Text = roomType == "direct" ? "Direct Chat" : $"{membersSnapshot.Count} members";

                pnlNoRoom.Visible = false;
                pnlChatInterface.Visible = true;

                // Load messages
                await LoadMessagesAsync(roomId);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading room: " + ex.Message, "text-danger");
            }
        }

        private async Task LoadMessagesAsync(string roomId)
        {
            try
            {
                var messagesQuery = db.Collection("chatRooms").Document(roomId)
                    .Collection("messages")
                    .OrderBy("timestamp")
                    .Limit(50);

                var messagesSnapshot = await messagesQuery.GetSnapshotAsync();
                var messages = new List<ChatMessage>();

                foreach (var doc in messagesSnapshot.Documents)
                {
                    var data = doc.ToDictionary();

                    DateTime timestamp = DateTime.Now;
                    if (data.ContainsKey("timestamp") && data["timestamp"] != null)
                    {
                        timestamp = ((Timestamp)data["timestamp"]).ToDateTime();
                    }

                    messages.Add(new ChatMessage
                    {
                        Id = doc.Id,
                        SenderId = GetSafeValue(data, "senderId", ""),
                        SenderName = GetSafeValue(data, "senderName", "Anonymous"),
                        Content = GetSafeValue(data, "content", ""),
                        Type = GetSafeValue(data, "type", "text"),
                        Timestamp = timestamp,
                        FormattedTime = FormatMessageTime(timestamp)
                    });
                }

                rptMessages.DataSource = messages;
                rptMessages.DataBind();

                // Add JavaScript to scroll to bottom
                ClientScript.RegisterStartupScript(this.GetType(), "scrollToBottom", "setTimeout(scrollToBottom, 100);", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading messages: " + ex.Message, "text-danger");
            }
        }

        private async void UpdateRoomCounts()
        {
            try
            {
                // Update counts without full refresh
                ClientScript.RegisterStartupScript(this.GetType(), "updateCounts",
                    $"document.getElementById('{lblMyRoomCount.ClientID}').textContent = '{rptMyRooms.Items.Count}';", true);
            }
            catch (Exception ex)
            {
                // Ignore count update errors
            }
        }

        // HELPER METHODS
        protected string GetMessageClass(string senderId, string messageType)
        {
            if (messageType == "system") return "system";
            return senderId == currentUserEmail ? "own" : "";
        }

        protected string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "U";
            var parts = name.Split(' ');
            return parts.Length > 1 ?
                (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper() :
                parts[0][0].ToString().ToUpper();
        }

        private string GetSafeValue(Dictionary<string, object> dict, string key, string defaultValue)
        {
            if (dict.ContainsKey(key) && dict[key] != null)
            {
                return dict[key].ToString();
            }
            return defaultValue;
        }

        private string GetCreatorName(string creatorEmail)
        {
            if (string.IsNullOrEmpty(creatorEmail)) return "Unknown";

            // Extract name part from email for display
            string[] parts = creatorEmail.Split('@');
            if (parts.Length > 0)
            {
                return parts[0].Replace(".", " ").Replace("_", " ");
            }

            return "Unknown";
        }

        private string FormatRelativeTime(DateTime timestamp)
        {
            var timeSpan = DateTime.UtcNow - timestamp;

            if (timeSpan.Days > 0)
                return $"{timeSpan.Days}d ago";
            else if (timeSpan.Hours > 0)
                return $"{timeSpan.Hours}h ago";
            else if (timeSpan.Minutes > 0)
                return $"{timeSpan.Minutes}m ago";
            else
                return "Just now";
        }

        private string FormatMessageTime(DateTime timestamp)
        {
            return timestamp.ToString("HH:mm");
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblCreateStatus.Text = message;
            lblCreateStatus.CssClass = $"status-message show {cssClass}";
        }

        private void ShowSearchMessage(string message, string cssClass)
        {
            lblSearchStatus.Text = message;
            lblSearchStatus.CssClass = $"status-message show {cssClass}";
        }

        // DATA CLASSES
        public class ChatRoomInfo
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public int MemberCount { get; set; }
            public string LastActivity { get; set; }
            public string CreatedBy { get; set; }
            public bool IsPublic { get; set; }
        }

        public class ChatMessage
        {
            public string Id { get; set; }
            public string SenderId { get; set; }
            public string SenderName { get; set; }
            public string Content { get; set; }
            public string Type { get; set; }
            public DateTime Timestamp { get; set; }
            public string FormattedTime { get; set; }
        }

        public class UserSearchResult
        {
            public string Email { get; set; }
            public string Name { get; set; }
        }
    }
}