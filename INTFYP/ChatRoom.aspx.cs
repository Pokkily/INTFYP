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
            else if (Request["__EVENTTARGET"] == "LoadAvailableRooms")
            {
                LoadAvailableRoomsAsync();
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

                // Alternative approach: Get all rooms and check membership individually
                // This avoids collection group queries entirely
                var allRoomsQuery = db.Collection("chatRooms")
                    .WhereEqualTo("status", "active")
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
                                IsPublic = GetSafeBoolValue(roomData, "settings.isPrivate", true) == false
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

        private async void LoadAvailableRoomsAsync()
        {
            try
            {
                var availableRooms = new List<ChatRoomInfo>();

                // Get all active public rooms - use the direct isPublic field for better querying
                var publicRoomsQuery = db.Collection("chatRooms")
                    .WhereEqualTo("status", "active")
                    .WhereEqualTo("isPublic", true)
                    .Limit(100);
                var publicSnapshot = await publicRoomsQuery.GetSnapshotAsync();

                foreach (var roomDoc in publicSnapshot.Documents)
                {
                    var roomData = roomDoc.ToDictionary();

                    // Double-check if room is public (fallback to settings if needed)
                    bool isPublic = GetSafeBoolValue(roomData, "isPublic", false);
                    if (!isPublic)
                    {
                        // Fallback to check settings.isPrivate
                        bool isPrivate = GetSafeBoolValue(roomData, "settings.isPrivate", true);
                        if (isPrivate) continue; // Skip private rooms
                    }

                    // Check if user is already a member
                    var memberDoc = await roomDoc.Reference.Collection("members")
                        .Document(currentUserEmail).GetSnapshotAsync();

                    bool isAlreadyMember = false;
                    if (memberDoc.Exists)
                    {
                        var memberData = memberDoc.ToDictionary();
                        string status = GetSafeValue(memberData, "status", "");
                        isAlreadyMember = (status == "active");
                    }

                    if (isAlreadyMember) continue; // Skip rooms user is already in

                    // Get member count
                    var membersSnapshot = await roomDoc.Reference.Collection("members")
                        .WhereEqualTo("status", "active")
                        .GetSnapshotAsync();

                    availableRooms.Add(new ChatRoomInfo
                    {
                        Id = roomDoc.Id,
                        Name = GetSafeValue(roomData, "name", "Unnamed Room"),
                        Description = GetSafeValue(roomData, "description", "No description"),
                        MemberCount = membersSnapshot.Count,
                        CreatedBy = GetCreatorName(GetSafeValue(roomData, "createdBy", "")),
                        IsPublic = true
                    });
                }

                rptAvailableRooms.DataSource = availableRooms.OrderByDescending(r => r.MemberCount).ToList();
                rptAvailableRooms.DataBind();

                lblAvailableRoomCount.Text = availableRooms.Count.ToString();

                // Show/hide empty state
                pnlNoAvailableRooms.Visible = availableRooms.Count == 0;
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading available rooms: " + ex.Message, "text-danger");
            }
        }

        protected async void btnCreateRoom_Click(object sender, EventArgs e)
        {
            string roomName = txtRoomName.Text.Trim();
            string description = txtDescription.Text.Trim();
            bool isPublic = chkPublicRoom.Checked;

            if (string.IsNullOrEmpty(roomName))
            {
                ShowMessage("Please enter a room name", "text-danger");
                return;
            }

            try
            {
                // Create new room
                var roomRef = db.Collection("chatRooms").Document();
                var roomData = new Dictionary<string, object>
                {
                    { "name", roomName },
                    { "description", description },
                    { "type", "group" },
                    { "createdBy", currentUserEmail },
                    { "createdAt", FieldValue.ServerTimestamp },
                    { "lastActivity", FieldValue.ServerTimestamp },
                    { "status", "active" },
                    { "isPublic", isPublic }, // Add direct isPublic field for easier querying
                    { "settings", new Dictionary<string, object>
                        {
                            { "isPrivate", !isPublic },
                            { "allowInvites", true },
                            { "maxMembers", 100 }
                        }
                    }
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
                chkPublicRoom.Checked = false;
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

        protected async void rptAvailableRooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "JoinRoom")
            {
                string roomId = e.CommandArgument.ToString();
                await JoinRoomAsync(roomId);
            }
        }

        private async Task JoinRoomAsync(string roomId)
        {
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
                string roomName = GetSafeValue(roomData, "name", "Unknown Room");

                // Check if already a member
                var memberDoc = await roomRef.Collection("members").Document(currentUserEmail).GetSnapshotAsync();
                if (memberDoc.Exists && GetSafeValue(memberDoc.ToDictionary(), "status", "") == "active")
                {
                    ShowMessage("You are already a member of this room", "text-warning");
                    return;
                }

                // Add user as member
                await roomRef.Collection("members").Document(currentUserEmail).SetAsync(new
                {
                    email = currentUserEmail,
                    name = currentUserName,
                    role = "member",
                    joinedAt = FieldValue.ServerTimestamp,
                    status = "active",
                    lastSeen = FieldValue.ServerTimestamp
                });

                // Add system message
                await roomRef.Collection("messages").AddAsync(new
                {
                    senderId = "system",
                    senderName = "System",
                    content = $"{currentUserName} joined the room",
                    type = "system",
                    timestamp = FieldValue.ServerTimestamp
                });

                // Update room last activity
                await roomRef.UpdateAsync("lastActivity", FieldValue.ServerTimestamp);

                ShowMessage($"Successfully joined '{roomName}'!", "text-success");

                // Refresh both lists
                LoadMyRoomsAsync();
                LoadAvailableRoomsAsync();
                UpdateRoomCounts();

                // Auto-select the joined room
                hfCurrentRoomId.Value = roomId;
                LoadCurrentRoomAsync();
            }
            catch (Exception ex)
            {
                ShowMessage("Error joining room: " + ex.Message, "text-danger");
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
                    content = $"{currentUserName} left the room",
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
                pnlInviteSection.Visible = false;

                LoadMyRoomsAsync();
                LoadAvailableRoomsAsync();
                UpdateRoomCounts();
            }
            catch (Exception ex)
            {
                ShowMessage("Error leaving room: " + ex.Message, "text-danger");
            }
        }

        protected async void btnInvite_Click(object sender, EventArgs e)
        {
            string email = txtInviteEmail.Text.Trim().ToLower();
            string roomId = hfCurrentRoomId.Value;

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(roomId))
            {
                ShowInviteMessage("Please enter an email address", "text-danger");
                return;
            }

            try
            {
                // Check if user exists
                var userSnapshot = await db.Collection("users").WhereEqualTo("email", email).GetSnapshotAsync();
                if (userSnapshot.Count == 0)
                {
                    ShowInviteMessage("User not found", "text-danger");
                    return;
                }

                var userDoc = userSnapshot.Documents[0];
                string userName = userDoc.GetValue<string>("firstName") + " " + userDoc.GetValue<string>("lastName");

                // Check if already a member
                var roomRef = db.Collection("chatRooms").Document(roomId);
                var memberDoc = await roomRef.Collection("members").Document(email).GetSnapshotAsync();

                if (memberDoc.Exists && GetSafeValue(memberDoc.ToDictionary(), "status", "") == "active")
                {
                    ShowInviteMessage("User is already a member", "text-warning");
                    return;
                }

                // Add as member
                await roomRef.Collection("members").Document(email).SetAsync(new
                {
                    email = email,
                    name = userName,
                    role = "member",
                    joinedAt = FieldValue.ServerTimestamp,
                    status = "active",
                    lastSeen = FieldValue.ServerTimestamp
                });

                // Add system message
                await roomRef.Collection("messages").AddAsync(new
                {
                    senderId = "system",
                    senderName = "System",
                    content = $"{userName} was invited to join the room",
                    type = "system",
                    timestamp = FieldValue.ServerTimestamp
                });

                // Update last activity
                await roomRef.UpdateAsync("lastActivity", FieldValue.ServerTimestamp);

                txtInviteEmail.Text = "";
                ShowInviteMessage($"{userName} invited successfully!", "text-success");
                LoadCurrentRoomAsync(); // Refresh member count
            }
            catch (Exception ex)
            {
                ShowInviteMessage("Error inviting user: " + ex.Message, "text-danger");
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
                pnlInviteSection.Visible = false;
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

                // Get member count
                var membersSnapshot = await roomRef.Collection("members")
                    .WhereEqualTo("status", "active")
                    .GetSnapshotAsync();

                // Update UI
                lblCurrentRoom.Text = GetSafeValue(roomData, "name", "Unnamed Room");
                lblMemberCount.Text = $"{membersSnapshot.Count} members";

                pnlNoRoom.Visible = false;
                pnlChatInterface.Visible = true;
                pnlInviteSection.Visible = true;

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

        private bool GetSafeBoolValue(Dictionary<string, object> dict, string key, bool defaultValue)
        {
            try
            {
                if (key.Contains(".")) // Handle nested keys like "settings.isPrivate"
                {
                    var keys = key.Split('.');
                    object current = dict;

                    foreach (var k in keys)
                    {
                        if (current is Dictionary<string, object> currentDict && currentDict.ContainsKey(k))
                        {
                            current = currentDict[k];
                        }
                        else
                        {
                            return defaultValue;
                        }
                    }

                    return current is bool ? (bool)current : defaultValue;
                }

                if (dict.ContainsKey(key) && dict[key] is bool)
                {
                    return (bool)dict[key];
                }
            }
            catch (Exception)
            {
                // Return default on any error
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

        private void ShowInviteMessage(string message, string cssClass)
        {
            lblInviteStatus.Text = message;
            lblInviteStatus.CssClass = $"status-message show {cssClass}";
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
    }
}