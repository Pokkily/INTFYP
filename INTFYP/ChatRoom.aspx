<%@ Page Title="Chat Room" Language="C#" MasterPageFile="~/Site.master" 
    AutoEventWireup="true" CodeBehind="ChatRoom.aspx.cs" 
    Inherits="YourProjectNamespace.ChatRoom" Async="true" %>

<asp:Content ID="ChatContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .chat-container {
            display: flex;
            height: calc(100vh - 120px);
            max-width: 1400px;
            margin: 0 auto;
            gap: 20px;
            padding: 20px;
        }

        .sidebar {
            width: 380px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .sidebar-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }

        .sidebar-header h3 {
            margin: 0 0 10px 0;
            font-weight: 600;
        }

        .sidebar-tabs {
            display: flex;
            background: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
        }

        .tab-btn {
            flex: 1;
            padding: 12px 16px;
            background: none;
            border: none;
            cursor: pointer;
            font-weight: 500;
            font-size: 14px;
            color: #6c757d;
            transition: all 0.3s ease;
        }

        .tab-btn.active {
            background: white;
            color: #667eea;
            border-bottom: 2px solid #667eea;
        }

        .tab-btn:hover {
            background: #e9ecef;
            color: #495057;
        }

        .tab-content {
            display: none;
            flex: 1;
            flex-direction: column;
            overflow: hidden;
        }

        .tab-content.active {
            display: flex;
        }

        .create-room-section {
            padding: 20px;
            border-bottom: 1px solid #e9ecef;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-label {
            font-weight: 500;
            color: #495057;
            font-size: 14px;
            margin-bottom: 5px;
            display: block;
        }

        .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ced4da;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.2s ease;
            box-sizing: border-box;
        }

        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        .btn-success {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
        }

        .btn-small {
            padding: 6px 12px;
            font-size: 12px;
        }

        .btn-mini {
            padding: 4px 8px;
            font-size: 11px;
        }

        .btn-icon {
            padding: 8px 12px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .rooms-list {
            flex: 1;
            overflow-y: auto;
            padding: 0;
        }

        .room-item {
            padding: 15px 20px;
            border-bottom: 1px solid #f1f3f4;
            cursor: pointer;
            transition: background-color 0.2s ease;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .room-item:hover {
            background-color: #f8f9fa;
        }

        .room-item.active {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            border-left: 4px solid #667eea;
        }

        .room-info {
            flex: 1;
        }

        .room-info h4 {
            margin: 0 0 5px 0;
            font-size: 16px;
            font-weight: 600;
            color: #212529;
        }

        .room-info p {
            margin: 0;
            font-size: 12px;
            color: #6c757d;
        }

        .room-actions {
            display: flex;
            gap: 5px;
            align-items: center;
        }

        .room-status {
            font-size: 11px;
            padding: 2px 6px;
            border-radius: 10px;
            font-weight: 500;
        }

        .room-status.joined {
            background: #d4edda;
            color: #155724;
        }

        .room-status.direct {
            background: #cce5ff;
            color: #004085;
        }

        .search-section {
            padding: 15px 20px;
            border-bottom: 1px solid #e9ecef;
            background: #f8f9fa;
        }

        .search-box {
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 10px 12px 10px 35px;
            border: 1px solid #ced4da;
            border-radius: 25px;
            font-size: 13px;
            box-sizing: border-box;
        }

        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
        }

        .main-chat {
            flex: 1;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .chat-title {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        .chat-members {
            font-size: 14px;
            opacity: 0.9;
        }

        .room-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .leave-btn {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .leave-btn:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        .messages-container {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #f8f9fa;
        }

        .message {
            margin-bottom: 15px;
            display: flex;
            gap: 10px;
        }

        .message.own {
            flex-direction: row-reverse;
        }

        .message-avatar {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 14px;
            flex-shrink: 0;
        }

        .message.own .message-avatar {
            background: linear-gradient(135deg, #28a745, #20c997);
        }

        .message-content {
            max-width: 70%;
            background: white;
            padding: 12px 16px;
            border-radius: 18px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .message.own .message-content {
            background: #667eea;
            color: white;
        }

        .message.system .message-content {
            background: #e9ecef;
            color: #495057;
            font-style: italic;
            text-align: center;
            border-radius: 15px;
            padding: 8px 12px;
        }

        .message-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 4px;
        }

        .message-sender {
            font-weight: 600;
            font-size: 12px;
        }

        .message-time {
            font-size: 11px;
            opacity: 0.7;
        }

        .message-text {
            font-size: 14px;
            line-height: 1.4;
            word-wrap: break-word;
        }

        .message-input-area {
            padding: 20px;
            background: white;
            border-top: 1px solid #e9ecef;
        }

        .input-group {
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }

        .message-input {
            flex: 1;
            padding: 12px 16px;
            border: 1px solid #ced4da;
            border-radius: 25px;
            font-size: 14px;
            resize: none;
            min-height: 20px;
            max-height: 100px;
        }

        .message-input:focus {
            outline: none;
            border-color: #667eea;
        }

        .send-btn {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .send-btn:hover {
            transform: scale(1.1);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        .empty-state {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            color: #6c757d;
            text-align: center;
        }

        .empty-state h3 {
            font-size: 24px;
            margin-bottom: 10px;
        }

        .status-message {
            padding: 8px 12px;
            margin: 8px 0;
            border-radius: 6px;
            font-size: 13px;
            display: none;
        }

        .status-message.show {
            display: block;
        }

        .text-success { 
            background: #d4edda; 
            color: #155724; 
            border: 1px solid #c3e6cb; 
        }

        .text-danger { 
            background: #f8d7da; 
            color: #721c24; 
            border: 1px solid #f5c6cb; 
        }

        .text-warning { 
            background: #fff3cd; 
            color: #856404; 
            border: 1px solid #ffeaa7; 
        }

        .start-chat-section {
            padding: 20px;
            border-bottom: 1px solid #e9ecef;
        }

        .user-search-result {
            padding: 12px 15px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .user-avatar {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 12px;
        }

        @media (max-width: 768px) {
            .chat-container {
                flex-direction: column;
                height: auto;
            }
            
            .sidebar {
                width: 100%;
                height: 400px;
            }
            
            .main-chat {
                height: 500px;
            }
        }

        .no-room-selected {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        }

        .room-count {
            background: #667eea;
            color: white;
            border-radius: 10px;
            padding: 2px 6px;
            font-size: 11px;
            font-weight: 600;
        }
    </style>

    <div class="chat-container">
        <!-- Enhanced Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <h3>Chat Rooms</h3>
                <p>Create rooms and chat with others</p>
                <div style="margin-top: 10px;">
                    <span class="room-count">My Rooms: <asp:Label ID="lblMyRoomCount" runat="server" Text="0" /></span>
                    <span class="room-count" style="margin-left: 8px; background: #28a745;">Direct Chats: <asp:Label ID="lblDirectChatCount" runat="server" Text="0" /></span>
                </div>
            </div>

            <!-- Sidebar Tabs -->
            <div class="sidebar-tabs">
                <button type="button" class="tab-btn active" onclick="switchTab('my-rooms')">My Rooms</button>
                <button type="button" class="tab-btn" onclick="switchTab('direct-chat')">Direct Chat</button>
                <button type="button" class="tab-btn" onclick="switchTab('create-room')">Create</button>
            </div>

            <!-- My Rooms Tab -->
            <div class="tab-content active" id="my-rooms-tab">
                <!-- Search My Rooms -->
                <div class="search-section">
                    <div class="search-box">
                        <asp:TextBox ID="txtSearchMyRooms" runat="server" CssClass="search-input" 
                                   placeholder="Search my rooms..." onkeyup="filterRooms('my')" />
                        <span class="search-icon">🔍</span>
                    </div>
                </div>

                <!-- My Rooms List -->
                <div class="rooms-list" id="myRoomsList">
                    <asp:Repeater ID="rptMyRooms" runat="server">
                        <ItemTemplate>
                            <div class="room-item" onclick="selectRoom('<%# Eval("Id") %>', '<%# Eval("Name") %>', 'my')">
                                <div class="room-info">
                                    <h4><%# Eval("Name") %></h4>
                                    <p><%# Eval("MemberCount") %> members • <%# Eval("LastActivity") %></p>
                                </div>
                                <div class="room-actions">
                                    <span class="room-status joined">Group</span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoMyRooms" runat="server" style="padding: 40px 20px; text-align: center; color: #6c757d;">
                        <h4>No Rooms Yet</h4>
                        <p>Create a room or start direct chats to get started!</p>
                    </asp:Panel>
                </div>
            </div>

            <!-- Direct Chat Tab -->
            <div class="tab-content" id="direct-chat-tab">
                <!-- Start New Chat Section -->
                <div class="start-chat-section">
                    <h4 style="margin: 0 0 15px 0; color: #495057; font-size: 16px;">Start New Chat</h4>
                    
                    <div class="form-group">
                        <label class="form-label">Search by Email</label>
                        <div style="display: flex; gap: 8px;">
                            <asp:TextBox ID="txtUserSearch" runat="server" CssClass="form-control" 
                                       placeholder="Enter email address" style="flex: 1;" />
                            <asp:Button ID="btnSearchUser" runat="server" Text="Search" 
                                      CssClass="btn btn-primary btn-small" OnClick="btnSearchUser_Click" />
                        </div>
                    </div>

                    <!-- User Search Results -->
                    <asp:Panel ID="pnlUserSearchResults" runat="server" Visible="false">
                        <asp:Repeater ID="rptUserSearchResults" runat="server" OnItemCommand="rptUserSearchResults_ItemCommand">
                            <ItemTemplate>
                                <div class="user-search-result">
                                    <div class="user-info">
                                        <div class="user-avatar">
                                            <%# GetInitials(Eval("Name").ToString()) %>
                                        </div>
                                        <div>
                                            <div style="font-weight: 500;"><%# Eval("Name") %></div>
                                            <div style="font-size: 12px; color: #6c757d;"><%# Eval("Email") %></div>
                                        </div>
                                    </div>
                                    <asp:Button runat="server" Text="Chat" CommandName="StartChat" 
                                              CommandArgument='<%# Eval("Email") %>' 
                                              CssClass="btn btn-success btn-mini" />
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </asp:Panel>
                    
                    <asp:Label ID="lblSearchStatus" runat="server" CssClass="status-message" />
                </div>

                <!-- Direct Chats List -->
                <div class="rooms-list" id="directChatsList">
                    <asp:Repeater ID="rptDirectChats" runat="server">
                        <ItemTemplate>
                            <div class="room-item" onclick="selectRoom('<%# Eval("Id") %>', '<%# Eval("Name") %>', 'direct')">
                                <div class="room-info">
                                    <h4><%# Eval("Name") %></h4>
                                    <p><%# Eval("LastActivity") %></p>
                                </div>
                                <div class="room-actions">
                                    <span class="room-status direct">Direct</span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoDirectChats" runat="server" style="padding: 40px 20px; text-align: center; color: #6c757d;">
                        <h4>No Direct Chats</h4>
                        <p>Search for users and start chatting!</p>
                    </asp:Panel>
                </div>
            </div>

            <!-- Create Room Tab -->
            <div class="tab-content" id="create-room-tab">
                <div class="create-room-section">
                    <h4 style="margin: 0 0 15px 0; color: #495057; font-size: 16px;">Create New Room</h4>
                    
                    <div class="form-group">
                        <label class="form-label">Room Name</label>
                        <asp:TextBox ID="txtRoomName" runat="server" CssClass="form-control" placeholder="Enter room name" />
                    </div>

                    <div class="form-group">
                        <label class="form-label">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" 
                                   TextMode="MultiLine" Rows="2" placeholder="Brief description" />
                    </div>

                    <asp:Button ID="btnCreateRoom" runat="server" Text="Create Room" 
                              CssClass="btn btn-primary" OnClick="btnCreateRoom_Click" style="width: 100%;" />
                    
                    <asp:Label ID="lblCreateStatus" runat="server" CssClass="status-message" />
                </div>
            </div>
        </div>

        <!-- Main Chat Area -->
        <div class="main-chat">
            <!-- No Room Selected State -->
            <asp:Panel ID="pnlNoRoom" runat="server" CssClass="empty-state no-room-selected" Visible="true">
                <h3>Welcome to Chat Rooms</h3>
                <p>Select a room from the sidebar to start chatting, or create/start new chats</p>
                <div style="margin-top: 20px; color: #495057;">
                    <p><strong>Getting Started:</strong></p>
                    <p>• Start direct chats with other users by searching their email</p>
                    <p>• Create group rooms and invite others</p>
                    <p>• Switch between multiple conversations</p>
                </div>
            </asp:Panel>

            <!-- Chat Interface -->
            <asp:Panel ID="pnlChatInterface" runat="server" Visible="false">
                <!-- Chat Header -->
                <div class="chat-header">
                    <div>
                        <h2 class="chat-title">
                            <asp:Label ID="lblCurrentRoom" runat="server" />
                        </h2>
                        <div class="chat-members">
                            <asp:Label ID="lblMemberCount" runat="server" />
                        </div>
                    </div>
                    <div class="room-controls">
                        <asp:Button ID="btnLeaveRoom" runat="server" Text="Leave Chat" 
                                  CssClass="leave-btn" OnClick="btnLeaveRoom_Click" 
                                  OnClientClick="return confirm('Are you sure you want to leave this chat?');" />
                    </div>
                </div>

                <!-- Messages Container -->
                <div class="messages-container" id="messagesContainer">
                    <asp:Repeater ID="rptMessages" runat="server">
                        <ItemTemplate>
                            <div class="message <%# GetMessageClass(Eval("SenderId").ToString(), Eval("Type").ToString()) %>">
                                <div class="message-avatar">
                                    <%# GetInitials(Eval("SenderName").ToString()) %>
                                </div>
                                <div class="message-content">
                                    <div class="message-header">
                                        <span class="message-sender"><%# Eval("SenderName") %></span>
                                        <span class="message-time"><%# Eval("FormattedTime") %></span>
                                    </div>
                                    <div class="message-text"><%# Eval("Content") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- Message Input -->
                <div class="message-input-area">
                    <div class="input-group">
                        <asp:TextBox ID="txtMessage" runat="server" CssClass="message-input" 
                                   placeholder="Type your message..." TextMode="MultiLine" Rows="1" />
                        <asp:Button ID="btnSend" runat="server" CssClass="send-btn" Text="➤" OnClick="btnSend_Click" />
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <!-- Hidden fields -->
    <asp:HiddenField ID="hfCurrentRoomId" runat="server" />

    <script type="text/javascript">
        function switchTab(tabName, event) {
            // Prevent any default behavior
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }

            // Remove active class from all tabs and content
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

            // Add active class to clicked tab and corresponding content
            const clickedBtn = document.querySelector(`[onclick*="${tabName}"]`);
            if (clickedBtn) clickedBtn.classList.add('active');
            
            const targetTab = document.getElementById(tabName + '-tab');
            if (targetTab) targetTab.classList.add('active');

            // Load direct chats when direct chat tab is opened
            if (tabName === 'direct-chat') {
                setTimeout(() => {
                    __doPostBack('LoadDirectChats', '');
                }, 100);
            }
            
            return false;
        }

        function selectRoom(roomId, roomName, source) {
            document.getElementById('<%= hfCurrentRoomId.ClientID %>').value = roomId;
            
            // Update active room styling in the current tab
            const currentList = source === 'my' ? '#myRoomsList' : '#directChatsList';
            document.querySelectorAll(`${currentList} .room-item`).forEach(item => item.classList.remove('active'));
            event.currentTarget.classList.add('active');
            
            // Trigger postback to load room
            __doPostBack('LoadRoom', roomId);
        }

        function filterRooms(type) {
            const searchInput = document.getElementById('<%= txtSearchMyRooms.ClientID %>');
            const roomsList = '#myRoomsList';

            const filter = searchInput.value.toLowerCase();
            const rooms = document.querySelectorAll(`${roomsList} .room-item`);

            rooms.forEach(room => {
                const roomName = room.querySelector('h4').textContent.toLowerCase();
                const roomDesc = room.querySelector('p').textContent.toLowerCase();

                if (roomName.includes(filter) || roomDesc.includes(filter)) {
                    room.style.display = 'flex';
                } else {
                    room.style.display = 'none';
                }
            });
        }

        function scrollToBottom() {
            const container = document.getElementById('messagesContainer');
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        }

        // Handle Enter key in message input
        document.addEventListener('DOMContentLoaded', function () {
            // Prevent tab buttons from submitting form
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    return false;
                });
            });

            const messageInput = document.getElementById('<%= txtMessage.ClientID %>');
            if (messageInput) {
                messageInput.addEventListener('keydown', function (e) {
                    if (e.key === 'Enter' && !e.shiftKey) {
                        e.preventDefault();
                        document.getElementById('<%= btnSend.ClientID %>').click();
                    }
                });
            }

            // Auto-scroll to bottom
            setTimeout(scrollToBottom, 100);
        });

        // Clear status messages after 3 seconds
        setTimeout(function () {
            const statusMessages = document.querySelectorAll('.status-message.show');
            statusMessages.forEach(msg => {
                if (msg.textContent.trim()) {
                    msg.style.opacity = '0';
                    setTimeout(() => {
                        msg.textContent = '';
                        msg.classList.remove('show');
                    }, 500);
                }
            });
        }, 3000);
    </script>
</asp:Content>