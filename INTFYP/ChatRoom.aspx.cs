using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Configuration;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;

namespace YourProjectNamespace
{
    public partial class ChatRoom : System.Web.UI.Page
    {
        private FirestoreDb db;
        private string currentUserEmail;
        private string currentUserName;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if request was too large for file uploads
            if (Request.ContentLength > (4 * 1024 * 1024))
            {
                ShowMessage("File size exceeds 4 MB limit. Please select a smaller file.", "text-danger");
                return;
            }

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
                LoadPrivateChatsAsync();
                UpdateRoomCounts();

                string roomId = Request.QueryString["room"];
                string activeTab = Request.QueryString["tab"];
                string action = Request.QueryString["action"];

                if (!string.IsNullOrEmpty(roomId))
                {
                    hfCurrentRoomId.Value = roomId;
                    LoadCurrentRoomAsync();
                }

                if (!string.IsNullOrEmpty(activeTab))
                {
                    hfActiveTab.Value = activeTab;
                }
                else
                {
                    hfActiveTab.Value = "my-rooms";
                }

                if (!string.IsNullOrEmpty(action))
                {
                    HandleRedirectMessages(action);
                }
            }
            else
            {
                HandlePostBackEvents();

                if (!string.IsNullOrEmpty(hfCurrentRoomId.Value))
                {
                    LoadCurrentRoomAsync();
                }
            }
        }

        private void HandleRedirectMessages(string action)
        {
            switch (action)
            {
                case "room-created":
                    ShowMessage("Room created successfully!", "text-success");
                    break;
                case "chat-started":
                    ShowSearchMessage("Private chat started successfully!", "text-success");
                    break;
                case "message-sent":
                    // No message needed for message sent
                    break;
                case "file-sent":
                    // No message needed for file sent
                    break;
                case "room-left":
                    ShowMessage("You left the chat successfully", "text-success");
                    break;
                case "user-invited":
                    ShowInviteMessage("User invited successfully!", "text-success");
                    break;
                case "user-removed":
                    ShowInviteMessage("Member removed successfully", "text-success");
                    break;
                case "room-deleted":
                    ShowMessage("Group was deleted", "text-success");
                    break;
                case "message-deleted":
                    // No message needed for message deletion
                    break;
            }
        }

        private void HandlePostBackEvents()
        {
            string eventTarget = Request["__EVENTTARGET"];
            string eventArgument = Request["__EVENTARGUMENT"];

            switch (eventTarget)
            {
                case "LoadRoom":
                    if (!string.IsNullOrEmpty(eventArgument))
                    {
                        hfCurrentRoomId.Value = eventArgument;
                        LoadCurrentRoomAsync();
                    }
                    break;

                case "LoadPrivateChats":
                    LoadPrivateChatsAsync();
                    hfActiveTab.Value = "private-chat";
                    break;

                case "LoadMembers":
                    LoadMembersAsync();
                    ClientScript.RegisterStartupScript(this.GetType(), "showMembers",
                        "setTimeout(() => showMembersList(), 100);", true);
                    break;

                // NEW: Handle message deletion
                case "DeleteMessage":
                    if (!string.IsNullOrEmpty(eventArgument))
                    {
                        DeleteMessageAsync(eventArgument);
                    }
                    break;

                default:
                    break;
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

        // NEW: Delete message method
        private async void DeleteMessageAsync(string messageId)
        {
            string roomId = hfCurrentRoomId.Value;
            if (string.IsNullOrEmpty(roomId) || string.IsNullOrEmpty(messageId))
            {
                return;
            }

            try
            {
                var messageRef = db.Collection("chatRooms").Document(roomId)
                    .Collection("messages").Document(messageId);

                var messageSnapshot = await messageRef.GetSnapshotAsync();
                if (!messageSnapshot.Exists)
                {
                    return;
                }

                var messageData = messageSnapshot.ToDictionary();
                string senderId = GetSafeValue(messageData, "senderId", "");

                // Verify that the current user is the sender of the message
                if (senderId != currentUserEmail)
                {
                    ShowMessage("You can only delete your own messages", "text-danger");
                    return;
                }

                // Soft delete - mark as deleted instead of actually removing
                await messageRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "isDeleted", true },
                    { "deletedAt", FieldValue.ServerTimestamp },
                    { "deletedBy", currentUserEmail }
                });

                // Update room last activity
                await db.Collection("chatRooms").Document(roomId)
                    .UpdateAsync("lastActivity", FieldValue.ServerTimestamp);

                // Redirect to reload messages and prevent duplicate postback
                Response.Redirect($"ChatRoom.aspx?room={roomId}&tab={hfActiveTab.Value}&action=message-deleted");
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting message: " + ex.Message, "text-danger");
            }
        }

        // File upload to Cloudinary method (similar to AddBook)
        private async System.Threading.Tasks.Task<FileUploadResult> UploadFileToCloudinary(FileUpload fileUpload)
        {
            var account = new Account(
                ConfigurationManager.AppSettings["CloudinaryCloudName"],
                ConfigurationManager.AppSettings["CloudinaryApiKey"],
                ConfigurationManager.AppSettings["CloudinaryApiSecret"]
            );
            var cloudinary = new Cloudinary(account);

            using (var stream = fileUpload.PostedFile.InputStream)
            {
                string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
                bool isImage = fileExtension == ".png" || fileExtension == ".jpg" ||
                              fileExtension == ".jpeg" || fileExtension == ".gif";

                if (isImage)
                {
                    // Upload as image
                    var uploadParams = new ImageUploadParams
                    {
                        File = new FileDescription(fileUpload.FileName, stream),
                        Folder = "chat_images",
                        Transformation = new Transformation().Width(800).Height(600).Crop("limit").Quality("auto")
                    };
                    var uploadResult = await cloudinary.UploadAsync(uploadParams);

                    if (uploadResult.Error != null)
                    {
                        throw new Exception($"Cloudinary upload error: {uploadResult.Error.Message}");
                    }

                    return new FileUploadResult
                    {
                        Url = uploadResult.SecureUrl?.ToString() ?? "",
                        FileName = fileUpload.FileName,
                        FileType = "image",
                        FileSize = fileUpload.PostedFile.ContentLength
                    };
                }
                else
                {
                    // Upload as raw file (PDF)
                    var uploadParams = new RawUploadParams
                    {
                        File = new FileDescription(fileUpload.FileName, stream),
                        Folder = "chat_files"
                    };
                    var uploadResult = await cloudinary.UploadAsync(uploadParams);

                    if (uploadResult.Error != null)
                    {
                        throw new Exception($"Cloudinary upload error: {uploadResult.Error.Message}");
                    }

                    return new FileUploadResult
                    {
                        Url = uploadResult.SecureUrl?.ToString() ?? "",
                        FileName = fileUpload.FileName,
                        FileType = "pdf",
                        FileSize = fileUpload.PostedFile.ContentLength
                    };
                }
            }
        }

        // Validate uploaded file
        private bool ValidateUploadedFile(FileUpload fileUpload)
        {
            if (!fileUpload.HasFile)
            {
                return true; // No file is OK, just send text message
            }

            // Check file extension
            string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
            string[] allowedExtensions = { ".pdf", ".png", ".jpg", ".jpeg", ".gif" };

            if (!allowedExtensions.Contains(fileExtension))
            {
                ShowMessage("Only PDF and image files (PNG, JPG, JPEG, GIF) are allowed.", "text-danger");
                return false;
            }

            // Check file size (4 MB limit)
            const int maxFileSize = 4 * 1024 * 1024; // 4 MB in bytes
            if (fileUpload.PostedFile.ContentLength > maxFileSize)
            {
                ShowMessage("File size exceeds 4 MB limit. Please select a smaller file.", "text-danger");
                return false;
            }

            // Check MIME type for additional security
            string[] allowedMimeTypes = { "application/pdf", "image/png", "image/jpeg", "image/gif", "image/jpg" };
            if (!allowedMimeTypes.Contains(fileUpload.PostedFile.ContentType))
            {
                ShowMessage("Invalid file type. Please select a valid file.", "text-danger");
                return false;
            }

            return true;
        }

        // Send message with file support
        protected async void btnSend_Click(object sender, EventArgs e)
        {
            string message = txtMessage.Text.Trim();
            string roomId = hfCurrentRoomId.Value;

            if (string.IsNullOrEmpty(roomId))
            {
                return;
            }

            // Must have either text message or file
            if (string.IsNullOrEmpty(message) && !fileUpload.HasFile)
            {
                return;
            }

            // Validate uploaded file if present
            if (!ValidateUploadedFile(fileUpload))
            {
                return;
            }

            try
            {
                var roomRef = db.Collection("chatRooms").Document(roomId);

                // Prepare message data
                var messageData = new Dictionary<string, object>
                {
                    { "senderId", currentUserEmail },
                    { "senderName", currentUserName },
                    { "content", message },
                    { "type", "text" },
                    { "timestamp", FieldValue.ServerTimestamp },
                    { "edited", false },
                    { "isDeleted", false } // NEW: Add isDeleted field for new messages
                };

                // Handle file upload if present
                if (fileUpload.HasFile)
                {
                    var fileResult = await UploadFileToCloudinary(fileUpload);

                    messageData["fileUrl"] = fileResult.Url;
                    messageData["fileName"] = fileResult.FileName;
                    messageData["fileType"] = fileResult.FileType;
                    messageData["fileSize"] = fileResult.FileSize;
                    messageData["type"] = "file"; // Change type to file if file is attached
                }

                // Add message to Firestore
                await roomRef.Collection("messages").AddAsync(messageData);

                // Update room last activity
                await roomRef.UpdateAsync("lastActivity", FieldValue.ServerTimestamp);

                // Update user's last seen
                await roomRef.Collection("members").Document(currentUserEmail)
                    .UpdateAsync("lastSeen", FieldValue.ServerTimestamp);

                // Redirect to prevent form resubmission
                string action = fileUpload.HasFile ? "file-sent" : "message-sent";
                Response.Redirect($"ChatRoom.aspx?room={roomId}&tab={hfActiveTab.Value}&action={action}");
            }
            catch (Exception ex)
            {
                ShowMessage("Error sending message: " + ex.Message, "text-danger");
            }
        }

        // Helper method to render file content in messages
        protected string GetFileContent(string fileUrl, string fileName, string fileType)
        {
            if (string.IsNullOrEmpty(fileUrl)) return "";

            if (fileType == "image")
            {
                return $@"
                    <div class='message-file'>
                        <img src='{fileUrl}' alt='{fileName}' class='file-image' onclick='window.open(""{fileUrl}"", ""_blank"")' title='Click to view full size' />
                    </div>";
            }
            else if (fileType == "pdf")
            {
                return $@"
                    <div class='message-file'>
                        <div class='file-preview'>
                            <div class='file-icon pdf'>
                                <i class='fas fa-file-pdf'></i>
                            </div>
                            <div class='file-info'>
                                <div class='file-name'>{fileName}</div>
                                <div class='file-size'>{FormatFileSize(0)}</div>
                            </div>
                        </div>
                        <a href='{fileUrl}' target='_blank' style='color: inherit; text-decoration: none; font-size: 12px; margin-top: 8px; display: block;'>
                            <i class='fas fa-external-link-alt'></i> Open PDF
                        </a>
                    </div>";
            }

            return "";
        }

        // Format file size helper
        private string FormatFileSize(long bytes)
        {
            if (bytes == 0) return "0 Bytes";
            string[] sizes = { "Bytes", "KB", "MB", "GB" };
            int i = (int)Math.Floor(Math.Log(bytes) / Math.Log(1024));
            return Math.Round(bytes / Math.Pow(1024, i), 2) + " " + sizes[i];
        }

        private async void LoadMyRoomsAsync()
        {
            try
            {
                var rooms = new List<ChatRoomInfo>();

                var allRoomsQuery = db.Collection("chatRooms")
                    .WhereEqualTo("status", "active")
                    .WhereEqualTo("type", "group")
                    .Limit(100);

                var allRoomsSnapshot = await allRoomsQuery.GetSnapshotAsync();

                foreach (var roomDoc in allRoomsSnapshot.Documents)
                {
                    try
                    {
                        var memberDoc = await roomDoc.Reference.Collection("members")
                            .Document(currentUserEmail).GetSnapshotAsync();

                        if (memberDoc.Exists)
                        {
                            var memberData = memberDoc.ToDictionary();
                            string status = GetSafeValue(memberData, "status", "");

                            if (status == "active")
                            {
                                var roomData = roomDoc.ToDictionary();

                                var membersSnapshot = await roomDoc.Reference.Collection("members")
                                    .WhereEqualTo("status", "active")
                                    .GetSnapshotAsync();

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
                                    IsPublic = false
                                });
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error processing room {roomDoc.Id}: {ex.Message}");
                        continue;
                    }
                }

                rptMyRooms.DataSource = rooms.OrderByDescending(r => r.LastActivity).ToList();
                rptMyRooms.DataBind();

                lblMyRoomCount.Text = rooms.Count.ToString();
                pnlNoMyRooms.Visible = rooms.Count == 0;
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading your rooms: " + ex.Message, "text-danger");
                lblMyRoomCount.Text = "0";
                pnlNoMyRooms.Visible = true;
            }
        }

        private async void LoadPrivateChatsAsync()
        {
            try
            {
                var privateChats = new List<ChatRoomInfo>();

                var allPrivateChatsQuery = db.Collection("chatRooms")
                    .WhereEqualTo("status", "active")
                    .WhereEqualTo("type", "private")
                    .Limit(100);

                var allPrivateChatsSnapshot = await allPrivateChatsQuery.GetSnapshotAsync();

                foreach (var roomDoc in allPrivateChatsSnapshot.Documents)
                {
                    try
                    {
                        var memberDoc = await roomDoc.Reference.Collection("members")
                            .Document(currentUserEmail).GetSnapshotAsync();

                        if (memberDoc.Exists)
                        {
                            var memberData = memberDoc.ToDictionary();
                            string status = GetSafeValue(memberData, "status", "");

                            if (status == "active")
                            {
                                var roomData = roomDoc.ToDictionary();
                                var allMembers = await roomDoc.Reference.Collection("members")
                                    .WhereEqualTo("status", "active")
                                    .GetSnapshotAsync();

                                string chatName = "Private Chat";
                                string otherParticipantEmail = "";

                                foreach (var member in allMembers.Documents)
                                {
                                    var memberInfo = member.ToDictionary();
                                    string memberEmail = GetSafeValue(memberInfo, "email", "");

                                    if (memberEmail != currentUserEmail && !string.IsNullOrEmpty(memberEmail))
                                    {
                                        string participantName = GetSafeValue(memberInfo, "name", "");
                                        if (string.IsNullOrEmpty(participantName))
                                        {
                                            participantName = memberEmail.Contains("@") ?
                                                memberEmail.Split('@')[0] : memberEmail;
                                        }

                                        chatName = participantName;
                                        otherParticipantEmail = memberEmail;
                                        break;
                                    }
                                }

                                if (!string.IsNullOrEmpty(otherParticipantEmail))
                                {
                                    string lastActivity = "No recent activity";
                                    if (roomData.ContainsKey("lastActivity"))
                                    {
                                        var timestamp = ((Timestamp)roomData["lastActivity"]).ToDateTime();
                                        lastActivity = FormatRelativeTime(timestamp);
                                    }

                                    privateChats.Add(new ChatRoomInfo
                                    {
                                        Id = roomDoc.Id,
                                        Name = chatName,
                                        Description = $"Private chat with {chatName}",
                                        MemberCount = allMembers.Count,
                                        LastActivity = lastActivity,
                                        CreatedBy = otherParticipantEmail,
                                        IsPublic = false
                                    });
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error processing private chat {roomDoc.Id}: {ex.Message}");
                        continue;
                    }
                }

                var sortedChats = privateChats.OrderByDescending(r => r.LastActivity).ToList();
                rptPrivateChats.DataSource = sortedChats;
                rptPrivateChats.DataBind();

                lblPrivateChatCount.Text = sortedChats.Count.ToString();
                pnlNoPrivateChats.Visible = sortedChats.Count == 0;
            }
            catch (Exception ex)
            {
                ShowSearchMessage("Error loading private chats: " + ex.Message, "text-danger");
                lblPrivateChatCount.Text = "0";
                pnlNoPrivateChats.Visible = true;
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

            hfActiveTab.Value = "private-chat";

            try
            {
                var userResults = new List<UserSearchResult>();

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
                await StartPrivateChatAsync(targetUserEmail);
            }
        }

        private async Task StartPrivateChatAsync(string targetUserEmail)
        {
            try
            {
                var existingChatsQuery = db.Collection("chatRooms")
                    .WhereEqualTo("type", "private")
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

                    if (memberEmails.Count == 2 &&
                        memberEmails.Contains(currentUserEmail) &&
                        memberEmails.Contains(targetUserEmail))
                    {
                        Response.Redirect($"ChatRoom.aspx?room={chatDoc.Id}&tab=private-chat&action=chat-started");
                        return;
                    }
                }

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

                var chatRef = db.Collection("chatRooms").Document();
                var chatData = new Dictionary<string, object>
                {
                    { "name", $"Private Chat" },
                    { "type", "private" },
                    { "createdBy", currentUserEmail },
                    { "createdAt", FieldValue.ServerTimestamp },
                    { "lastActivity", FieldValue.ServerTimestamp },
                    { "status", "active" }
                };

                await chatRef.SetAsync(chatData);

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

                Response.Redirect($"ChatRoom.aspx?room={chatRef.Id}&tab=private-chat&action=chat-started");
            }
            catch (Exception ex)
            {
                ShowSearchMessage("Error starting chat: " + ex.Message, "text-danger");
            }
        }

        protected async void btnCreateRoom_Click(object sender, EventArgs e)
        {
            string roomName = txtRoomName.Text.Trim();

            if (string.IsNullOrEmpty(roomName))
            {
                ShowMessage("Please enter a room name", "text-danger");
                hfActiveTab.Value = "create-room";
                return;
            }

            try
            {
                var roomRef = db.Collection("chatRooms").Document();
                var roomData = new Dictionary<string, object>
                {
                    { "name", roomName },
                    { "type", "group" },
                    { "createdBy", currentUserEmail },
                    { "createdAt", FieldValue.ServerTimestamp },
                    { "lastActivity", FieldValue.ServerTimestamp },
                    { "status", "active" }
                };

                await roomRef.SetAsync(roomData);

                await roomRef.Collection("members").Document(currentUserEmail).SetAsync(new
                {
                    email = currentUserEmail,
                    name = currentUserName,
                    role = "admin",
                    joinedAt = FieldValue.ServerTimestamp,
                    status = "active",
                    lastSeen = FieldValue.ServerTimestamp
                });

                Response.Redirect($"ChatRoom.aspx?room={roomRef.Id}&tab=my-rooms&action=room-created");
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating room: " + ex.Message, "text-danger");
                hfActiveTab.Value = "create-room";
            }
        }

        protected async void btnInviteUser_Click(object sender, EventArgs e)
        {
            string inviteEmail = txtInviteEmail.Text.Trim().ToLower();
            string roomId = hfCurrentRoomId.Value;

            if (string.IsNullOrEmpty(inviteEmail))
            {
                ShowInviteMessage("Please enter an email address", "text-danger");
                return;
            }

            if (string.IsNullOrEmpty(roomId))
            {
                ShowInviteMessage("No room selected", "text-danger");
                return;
            }

            if (inviteEmail == currentUserEmail.ToLower())
            {
                ShowInviteMessage("You are already in this room", "text-warning");
                return;
            }

            try
            {
                var roomRef = db.Collection("chatRooms").Document(roomId);
                var roomSnapshot = await roomRef.GetSnapshotAsync();

                if (!roomSnapshot.Exists)
                {
                    ShowInviteMessage("Room not found", "text-danger");
                    return;
                }

                var userSnapshot = await db.Collection("users")
                    .WhereEqualTo("email", inviteEmail)
                    .GetSnapshotAsync();

                if (userSnapshot.Count == 0)
                {
                    ShowInviteMessage("User not found", "text-danger");
                    return;
                }

                var existingMember = await roomRef.Collection("members")
                    .Document(inviteEmail).GetSnapshotAsync();

                if (existingMember.Exists)
                {
                    var memberData = existingMember.ToDictionary();
                    if (GetSafeValue(memberData, "status", "") == "active")
                    {
                        ShowInviteMessage("User is already a member", "text-warning");
                        return;
                    }
                }

                var userData = userSnapshot.Documents[0].ToDictionary();
                string firstName = GetSafeValue(userData, "firstName", "");
                string lastName = GetSafeValue(userData, "lastName", "");
                string fullName = $"{firstName} {lastName}".Trim();

                if (string.IsNullOrEmpty(fullName))
                {
                    fullName = inviteEmail.Split('@')[0];
                }

                await roomRef.Collection("members").Document(inviteEmail).SetAsync(new
                {
                    email = inviteEmail,
                    name = fullName,
                    role = "member",
                    joinedAt = FieldValue.ServerTimestamp,
                    status = "active",
                    lastSeen = FieldValue.ServerTimestamp
                });

                await roomRef.UpdateAsync("lastActivity", FieldValue.ServerTimestamp);

                txtInviteEmail.Text = "";

                Response.Redirect($"ChatRoom.aspx?room={roomId}&tab={hfActiveTab.Value}&action=user-invited");
            }
            catch (Exception ex)
            {
                ShowInviteMessage("Error inviting user: " + ex.Message, "text-danger");
            }
        }

        private async void LoadMembersAsync()
        {
            string roomId = hfCurrentRoomId.Value;
            if (string.IsNullOrEmpty(roomId)) return;

            try
            {
                var roomRef = db.Collection("chatRooms").Document(roomId);
                var roomSnapshot = await roomRef.GetSnapshotAsync();

                if (!roomSnapshot.Exists) return;

                var roomData = roomSnapshot.ToDictionary();
                string createdBy = GetSafeValue(roomData, "createdBy", "");
                bool isOwner = (createdBy == currentUserEmail);

                var membersSnapshot = await roomRef.Collection("members")
                    .WhereEqualTo("status", "active")
                    .GetSnapshotAsync();

                var members = new List<RoomMember>();

                foreach (var memberDoc in membersSnapshot.Documents)
                {
                    var memberData = memberDoc.ToDictionary();
                    string memberEmail = GetSafeValue(memberData, "email", "");
                    string memberRole = GetSafeValue(memberData, "role", "member");

                    bool canRemove = isOwner && memberEmail != currentUserEmail;

                    members.Add(new RoomMember
                    {
                        Email = memberEmail,
                        Name = GetSafeValue(memberData, "name", memberEmail.Split('@')[0]),
                        Role = memberRole,
                        CanRemove = canRemove
                    });
                }

                rptMembers.DataSource = members.OrderBy(m => m.Role == "admin" ? 0 : 1).ThenBy(m => m.Name);
                rptMembers.DataBind();
            }
            catch (Exception ex)
            {
                ShowInviteMessage("Error loading members: " + ex.Message, "text-danger");
            }
        }

        protected async void rptMembers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "KickMember")
            {
                string targetEmail = e.CommandArgument.ToString();
                string roomId = hfCurrentRoomId.Value;

                if (string.IsNullOrEmpty(roomId) || targetEmail == currentUserEmail)
                {
                    return;
                }

                try
                {
                    var roomRef = db.Collection("chatRooms").Document(roomId);

                    await roomRef.Collection("members").Document(targetEmail)
                        .UpdateAsync("status", "removed");

                    await roomRef.UpdateAsync("lastActivity", FieldValue.ServerTimestamp);

                    Response.Redirect($"ChatRoom.aspx?room={roomId}&tab={hfActiveTab.Value}&action=user-removed");
                }
                catch (Exception ex)
                {
                    ShowInviteMessage("Error removing member: " + ex.Message, "text-danger");
                }
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
                string roomType = GetSafeValue(roomData, "type", "group");
                string createdBy = GetSafeValue(roomData, "createdBy", "");
                bool isOwner = (createdBy == currentUserEmail);

                await roomRef.Collection("members").Document(currentUserEmail)
                    .UpdateAsync("status", "left");

                if (isOwner && roomType == "group")
                {
                    await roomRef.UpdateAsync("status", "deleted");

                    var membersSnapshot = await roomRef.Collection("members")
                        .WhereEqualTo("status", "active")
                        .GetSnapshotAsync();

                    foreach (var memberDoc in membersSnapshot.Documents)
                    {
                        await memberDoc.Reference.UpdateAsync("status", "left");
                    }

                    Response.Redirect("ChatRoom.aspx?tab=my-rooms&action=room-deleted");
                }
                else
                {
                    await roomRef.UpdateAsync("lastActivity", FieldValue.ServerTimestamp);
                    Response.Redirect("ChatRoom.aspx?tab=my-rooms&action=room-left");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error leaving room: " + ex.Message, "text-danger");
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
                string createdBy = GetSafeValue(roomData, "createdBy", "");
                bool isOwner = (createdBy == currentUserEmail);

                hfCurrentRoomType.Value = roomType;
                hfIsOwner.Value = isOwner.ToString().ToLower();

                var membersSnapshot = await roomRef.Collection("members")
                    .WhereEqualTo("status", "active")
                    .GetSnapshotAsync();

                string roomName;
                if (roomType == "private")
                {
                    roomName = "Private Chat";
                    foreach (var member in membersSnapshot.Documents)
                    {
                        var memberInfo = member.ToDictionary();
                        string memberEmail = GetSafeValue(memberInfo, "email", "");
                        if (memberEmail != currentUserEmail)
                        {
                            string participantName = GetSafeValue(memberInfo, "name", "");
                            if (string.IsNullOrEmpty(participantName))
                            {
                                participantName = memberEmail.Contains("@") ?
                                    memberEmail.Split('@')[0] : memberEmail;
                            }
                            roomName = participantName;
                            break;
                        }
                    }

                    pnlManageButton.Visible = false;
                    btnLeaveRoom.Visible = false;
                }
                else
                {
                    roomName = GetSafeValue(roomData, "name", "Unnamed Room");
                    pnlManageButton.Visible = isOwner;
                    btnLeaveRoom.Visible = true;
                }

                lblCurrentRoom.Text = roomName;
                lblMemberCount.Text = roomType == "private" ? "Private Chat" : $"{membersSnapshot.Count} members";

                pnlNoRoom.Visible = false;
                pnlChatInterface.Visible = true;

                await LoadMessagesAsync(roomId);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading room: " + ex.Message, "text-danger");
            }
        }

        // UPDATED: Load messages with deletion support
        private async Task LoadMessagesAsync(string roomId)
        {
            try
            {
                var messagesQuery = db.Collection("chatRooms").Document(roomId)
                    .Collection("messages")
                    .OrderBy("timestamp")
                    .Limit(100);

                var messagesSnapshot = await messagesQuery.GetSnapshotAsync();
                var messages = new List<ChatMessage>();

                foreach (var doc in messagesSnapshot.Documents)
                {
                    var data = doc.ToDictionary();

                    string messageType = GetSafeValue(data, "type", "text");
                    if (messageType == "system") continue;

                    DateTime timestamp = DateTime.Now;
                    if (data.ContainsKey("timestamp") && data["timestamp"] != null)
                    {
                        timestamp = ((Timestamp)data["timestamp"]).ToDateTime();
                    }

                    // NEW: Check if message is deleted
                    bool isDeleted = false;
                    if (data.ContainsKey("isDeleted"))
                    {
                        bool.TryParse(data["isDeleted"].ToString(), out isDeleted);
                    }

                    messages.Add(new ChatMessage
                    {
                        Id = doc.Id,
                        SenderId = GetSafeValue(data, "senderId", ""),
                        SenderName = GetSafeValue(data, "senderName", "Anonymous"),
                        Content = GetSafeValue(data, "content", ""),
                        Type = messageType,
                        Timestamp = timestamp,
                        FormattedTime = FormatMessageTime(timestamp),
                        FileUrl = GetSafeValue(data, "fileUrl", ""),
                        FileName = GetSafeValue(data, "fileName", ""),
                        FileType = GetSafeValue(data, "fileType", ""),
                        IsDeleted = isDeleted // NEW: Add deleted status
                    });
                }

                rptMessages.DataSource = messages;
                rptMessages.DataBind();

                ClientScript.RegisterStartupScript(this.GetType(), "scrollToBottom",
                    "setTimeout(() => scrollToBottom(true), 200);", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading messages: " + ex.Message, "text-danger");
            }
        }

        private void UpdateRoomCounts()
        {
            try
            {
                if (rptMyRooms.Items != null)
                {
                    lblMyRoomCount.Text = rptMyRooms.Items.Count.ToString();
                }

                if (rptPrivateChats.Items != null)
                {
                    lblPrivateChatCount.Text = rptPrivateChats.Items.Count.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating room counts: {ex.Message}");
            }
        }

        // HELPER METHODS
        protected string GetMessageClass(string senderId, string messageType)
        {
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

        // NEW: Helper method to get current user email for template access
        protected string GetCurrentUserEmail()
        {
            return currentUserEmail ?? "";
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

        // UPDATED: ChatMessage class with deletion support
        public class ChatMessage
        {
            public string Id { get; set; }
            public string SenderId { get; set; }
            public string SenderName { get; set; }
            public string Content { get; set; }
            public string Type { get; set; }
            public DateTime Timestamp { get; set; }
            public string FormattedTime { get; set; }
            public string FileUrl { get; set; }
            public string FileName { get; set; }
            public string FileType { get; set; }
            public bool IsDeleted { get; set; } // NEW: Deletion status
        }

        public class UserSearchResult
        {
            public string Email { get; set; }
            public string Name { get; set; }
        }

        public class RoomMember
        {
            public string Email { get; set; }
            public string Name { get; set; }
            public string Role { get; set; }
            public bool CanRemove { get; set; }
        }

        public class FileUploadResult
        {
            public string Url { get; set; }
            public string FileName { get; set; }
            public string FileType { get; set; }
            public long FileSize { get; set; }
        }
    }
}