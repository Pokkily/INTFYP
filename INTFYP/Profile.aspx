<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="YourProjectNamespace.Profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Profile
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Profile Page Design */
        
        .profile-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        }

        .profile-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
            padding: 40px;
            color: white;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 15px 35px rgba(103, 126, 234, 0.3);
        }

        .profile-header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: headerFloat 20s ease-in-out infinite;
        }

        @keyframes headerFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-10px, -10px) rotate(1deg); }
            50% { transform: translate(10px, -5px) rotate(-1deg); }
            75% { transform: translate(-5px, 5px) rotate(0.5deg); }
        }

        .profile-header-content {
            position: relative;
            z-index: 1;
            display: flex;
            align-items: center;
            gap: 30px;
        }

        .profile-image-container {
            position: relative;
        }

        .profile-image {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .profile-image:hover {
            transform: scale(1.05);
            border-color: rgba(255, 255, 255, 0.6);
        }

        .image-upload-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
            cursor: pointer;
            color: white;
            font-size: 24px;
        }

        .profile-image-container:hover .image-upload-overlay {
            opacity: 1;
        }

        .profile-info {
            flex: 1;
        }

        .profile-name {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 10px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }

        .profile-username {
            font-size: 18px;
            opacity: 0.9;
            margin-bottom: 5px;
        }

        .profile-position {
            font-size: 16px;
            opacity: 0.8;
            margin-bottom: 20px;
        }

        .profile-stats {
            display: flex;
            gap: 30px;
        }

        .stat-item {
            text-align: center;
        }

        .stat-number {
            font-size: 24px;
            font-weight: 700;
            display: block;
        }

        .stat-label {
            font-size: 14px;
            opacity: 0.8;
        }

        .edit-profile-btn {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
            padding: 12px 25px;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .edit-profile-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            border-color: rgba(255, 255, 255, 0.5);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 255, 255, 0.2);
        }

        .profile-tabs {
            display: flex;
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.05);
        }

        .tab-button {
            flex: 1;
            padding: 20px 15px;
            border: none;
            background: white;
            color: #6c757d;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .tab-button.active {
            color: #667eea;
            background: linear-gradient(135deg, rgba(103, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
        }

        .tab-button.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(135deg, #667eea, #764ba2);
        }

        .tab-button:hover:not(.active) {
            background: #f8f9fa;
            color: #495057;
        }

        .tab-icon {
            font-size: 20px;
        }

        .tab-content {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.05);
        }

        .tab-panel {
            padding: 40px;
            display: none;
            animation: fadeIn 0.5s ease-out;
        }

        .tab-panel.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .section-header {
            font-size: 24px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .section-icon {
            font-size: 28px;
            color: #667eea;
        }

        .form-section {
            margin-bottom: 40px;
        }

        .form-section-title {
            font-size: 18px;
            font-weight: 600;
            color: #495057;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid rgba(103, 126, 234, 0.1);
        }

        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            flex: 1;
        }

        .form-label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
            display: block;
        }

        .form-control {
            width: 100%;
            padding: 15px;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s ease;
            background: #f8f9fa;
            box-sizing: border-box;
        }

        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: white;
            outline: none;
        }

        .form-control:disabled {
            background: #f1f3f4;
            color: #6c757d;
        }

        .btn {
            padding: 12px 25px;
            border-radius: 25px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 6px 20px rgba(103, 126, 234, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(103, 126, 234, 0.4);
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
            box-shadow: 0 4px 15px rgba(108, 117, 125, 0.3);
        }

        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
        }

        .btn-danger {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
            box-shadow: 0 6px 20px rgba(231, 76, 60, 0.3);
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(231, 76, 60, 0.4);
        }

        .class-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-top: 20px;
        }

        .class-card {
            background: linear-gradient(135deg, #f8f9ff 0%, #e8ecff 100%);
            border-radius: 15px;
            padding: 25px;
            border: 1px solid rgba(103, 126, 234, 0.1);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .class-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(135deg, #667eea, #764ba2);
        }

        .class-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(103, 126, 234, 0.2);
            border-color: rgba(103, 126, 234, 0.3);
        }

        .class-name {
            font-size: 18px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .class-teacher {
            color: #667eea;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .class-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 14px;
            color: #6c757d;
        }

        .post-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 25px;
            margin-top: 20px;
        }

        .post-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            border: 1px solid #e9ecef;
            transition: all 0.3s ease;
            position: relative;
        }

        .post-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border-color: rgba(103, 126, 234, 0.3);
        }

        .post-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }

        .post-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 16px;
        }

        .post-meta {
            flex: 1;
        }

        .post-author {
            font-weight: 600;
            color: #2c3e50;
        }

        .post-time {
            font-size: 13px;
            color: #6c757d;
        }

        .post-content {
            color: #495057;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .post-actions {
            display: flex;
            gap: 20px;
            font-size: 14px;
            color: #6c757d;
        }

        .post-action {
            display: flex;
            align-items: center;
            gap: 5px;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .post-action:hover {
            color: #667eea;
        }

        .post-action.liked {
            color: #e74c3c;
        }

        .post-action.saved {
            color: #f39c12;
        }

        .empty-state {
            text-align: center;
            padding: 60px 30px;
            color: #6c757d;
        }

        .empty-state-icon {
            font-size: 72px;
            margin-bottom: 20px;
            opacity: 0.6;
        }

        .empty-state-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .empty-state-text {
            font-size: 16px;
            opacity: 0.8;
        }

        .activity-filter {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
        }

        .filter-btn {
            padding: 10px 20px;
            border: 2px solid #e9ecef;
            background: white;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
        }

        .filter-btn.active {
            border-color: #667eea;
            background: #667eea;
            color: white;
        }

        .filter-btn:hover:not(.active) {
            border-color: #667eea;
            color: #667eea;
        }

        /* Loading states */
        .loading {
            opacity: 0.6;
            pointer-events: none;
            position: relative;
        }

        .loading::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            transform: translate(-50%, -50%);
        }

        @keyframes spin {
            0% { transform: translate(-50%, -50%) rotate(0deg); }
            100% { transform: translate(-50%, -50%) rotate(360deg); }
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .profile-container {
                padding: 15px;
            }

            .profile-header {
                padding: 25px;
            }

            .profile-header-content {
                flex-direction: column;
                text-align: center;
                gap: 20px;
            }

            .profile-image {
                width: 100px;
                height: 100px;
            }

            .profile-name {
                font-size: 24px;
            }

            .profile-stats {
                justify-content: center;
                gap: 20px;
            }

            .profile-tabs {
                flex-direction: column;
            }

            .tab-button {
                padding: 15px;
            }

            .tab-panel {
                padding: 25px;
            }

            .form-row {
                flex-direction: column;
                gap: 15px;
            }

            .class-grid,
            .post-grid {
                grid-template-columns: 1fr;
            }

            .activity-filter {
                flex-wrap: wrap;
                gap: 10px;
            }
        }

        /* Accessibility improvements */
        .btn:focus,
        .tab-button:focus,
        .form-control:focus,
        .filter-btn:focus {
            outline: 3px solid rgba(103, 126, 234, 0.5);
            outline-offset: 2px;
        }

        /* Alert styles for notifications */
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 10px;
            position: relative;
        }

        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }

        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }

        .alert-warning {
            color: #856404;
            background-color: #fff3cd;
            border-color: #ffeaa7;
        }

        .alert-info {
            color: #0c5460;
            background-color: #d1ecf1;
            border-color: #bee5eb;
        }

        .btn-close {
            position: absolute;
            top: 8px;
            right: 15px;
            background: none;
            border: none;
            font-size: 18px;
            cursor: pointer;
        }
    </style>

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="profile-container">
                <!-- Profile Header -->
                <div class="profile-header">
                    <div class="profile-header-content">
                        <div class="profile-image-container">
                            <asp:Image ID="imgProfile" runat="server" CssClass="profile-image" 
                                ImageUrl="Images/dprofile.jpg" AlternateText="Profile Picture" />
                            <div class="image-upload-overlay" onclick="document.getElementById('<%= fileProfilePicture.ClientID %>').click();">
                                📷
                            </div>
                            <asp:FileUpload ID="fileProfilePicture" runat="server" 
                                style="display: none;" 
                                accept="image/*" 
                                onchange="previewProfileImage(this);" />
                        </div>
                        
                        <div class="profile-info">
                            <h1 class="profile-name">
                                <asp:Literal ID="ltProfileName" runat="server" Text="Loading..." />
                            </h1>
                            <div class="profile-username">
                                @<asp:Literal ID="ltUsername" runat="server" Text="username" />
                            </div>
                            <div class="profile-position">
                                <asp:Literal ID="ltPosition" runat="server" Text="Student" />
                            </div>
                            
                            <div class="profile-stats">
                                <div class="stat-item">
                                    <span class="stat-number">
                                        <asp:Literal ID="ltClassesCount" runat="server" Text="0" />
                                    </span>
                                    <span class="stat-label">Classes</span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-number">
                                        <asp:Literal ID="ltPostsCount" runat="server" Text="0" />
                                    </span>
                                    <span class="stat-label">Posts</span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-number">
                                        <asp:Literal ID="ltLikesCount" runat="server" Text="0" />
                                    </span>
                                    <span class="stat-label">Likes</span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-number">
                                        <asp:Literal ID="ltSavedCount" runat="server" Text="0" />
                                    </span>
                                    <span class="stat-label">Saved</span>
                                </div>
                            </div>
                        </div>

                        <div>
                            <asp:Button ID="btnUploadPhoto" runat="server" Text="📷 Update Photo" 
                                CssClass="edit-profile-btn" OnClick="btnUploadPhoto_Click" 
                                Style="display: none;" />
                        </div>
                    </div>
                </div>

                <!-- Navigation Tabs -->
                <div class="profile-tabs">
                    <button type="button" class="tab-button active" onclick="showTab('overview')">
                        <span class="tab-icon">👤</span>
                        <span>Overview</span>
                    </button>
                    <button type="button" class="tab-button" onclick="showTab('classes')">
                        <span class="tab-icon">📚</span>
                        <span>My Classes</span>
                    </button>
                    <button type="button" class="tab-button" onclick="showTab('activity')">
                        <span class="tab-icon">📱</span>
                        <span>Activity</span>
                    </button>
                </div>

                <!-- Tab Content -->
                <div class="tab-content">
                    <!-- Overview Tab -->
                    <div id="overview" class="tab-panel active">
                        <div class="section-header">
                            <span class="section-icon">👤</span>
                            Personal Information
                        </div>

                        <div class="form-section">
                            <h3 class="form-section-title">Basic Information</h3>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">First Name</label>
                                    <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Last Name</label>
                                    <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" />
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">Email</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" ReadOnly="true" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Username</label>
                                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" ReadOnly="true" />
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">Phone Number</label>
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Gender</label>
                                    <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="Male" Value="Male" />
                                        <asp:ListItem Text="Female" Value="Female" />
                                        <asp:ListItem Text="Other" Value="Other" />
                                        <asp:ListItem Text="Prefer not to say" Value="Undisclosed" />
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">Position</label>
                                    <asp:TextBox ID="txtPosition" runat="server" CssClass="form-control" ReadOnly="true" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Birthdate</label>
                                    <asp:TextBox ID="txtBirthdate" runat="server" CssClass="form-control" TextMode="Date" />
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Address</label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" 
                                    TextMode="MultiLine" Rows="3" />
                            </div>

                            <div style="margin-top: 30px;">
                                <asp:Button ID="btnUpdateProfile" runat="server" Text="💾 Save Changes" 
                                    CssClass="btn btn-primary" OnClick="btnUpdateProfile_Click" />
                                <button type="button" class="btn btn-secondary" onclick="resetForm()">
                                    🔄 Reset
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Classes Tab -->
                    <div id="classes" class="tab-panel">
                        <div class="section-header">
                            <span class="section-icon">📚</span>
                            My Enrolled Classes
                        </div>

                        <asp:Panel ID="pnlClassesLoading" runat="server" CssClass="loading" style="height: 200px;"></asp:Panel>
                        
                        <asp:Panel ID="pnlClasses" runat="server">
                            <div class="class-grid">
                                <asp:Repeater ID="rptClasses" runat="server">
                                    <ItemTemplate>
                                        <div class="class-card">
                                            <div class="class-name"><%# Eval("className") %></div>
                                            <div class="class-teacher">👨‍🏫 <%# Eval("teacherName") %></div>
                                            <div class="class-meta">
                                                <span>📅 <%# Eval("schedule") %></span>
                                                <span>👥 <%# Eval("studentCount") %> students</span>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <asp:Panel ID="pnlNoClasses" runat="server" Visible="false">
                                <div class="empty-state">
                                    <div class="empty-state-icon">📚</div>
                                    <h3 class="empty-state-title">No Classes Yet</h3>
                                    <p class="empty-state-text">You haven't enrolled in any classes yet. Start exploring!</p>
                                    <a href="Class.aspx" class="btn btn-primary" style="margin-top: 20px;">
                                        🔍 Browse Classes
                                    </a>
                                </div>
                            </asp:Panel>
                        </asp:Panel>
                    </div>

                    <!-- Activity Tab -->
                    <div id="activity" class="tab-panel">
                        <div class="section-header">
                            <span class="section-icon">📱</span>
                            Study Hub Activity
                        </div>

                        <!-- Activity Filter -->
                        <div class="activity-filter">
                            <button type="button" class="filter-btn active" onclick="filterActivity('all')">All Activity</button>
                            <button type="button" class="filter-btn" onclick="filterActivity('liked')">❤️ Liked Posts</button>
                            <button type="button" class="filter-btn" onclick="filterActivity('saved')">⭐ Saved Posts</button>
                            <button type="button" class="filter-btn" onclick="filterActivity('shared')">📤 Shared Posts</button>
                        </div>

                        <!-- Activity Content -->
                        <asp:Panel ID="pnlActivity" runat="server">
                            <div class="activity-grid">
                                <!-- Liked Posts -->
                                <asp:Repeater ID="rptLikedPosts" runat="server">
                                    <ItemTemplate>
                                        <div class="post-card activity-item liked-post" data-activity-type="liked">
                                            <div class="post-header">
                                                <div class="post-author">
                                                    <div class="post-avatar">
                                                        <%# Eval("authorName").ToString().Substring(0, 1).ToUpper() %>
                                                    </div>
                                                    <div class="post-meta">
                                                        <div class="post-author-name"><%# Eval("authorName") %></div>
                                                        <div class="post-time"><%# Eval("timestamp") %></div>
                                                        <div class="post-group">in <%# Eval("groupName") %></div>
                                                    </div>
                                                </div>
                                                <div class="activity-badge liked">
                                                    <span class="badge-icon">❤️</span>
                                                    <span class="badge-text">Liked</span>
                                                </div>
                                            </div>
                                            <div class="post-content">
                                                <div class="post-text"><%# Eval("content") %></div>
                                            </div>
                                            <div class="post-stats">
                                                <div class="stat-item">
                                                    <span class="stat-icon">❤️</span>
                                                    <span class="stat-count"><%# Eval("likeCount") %></span>
                                                </div>
                                                <div class="stat-item">
                                                    <span class="stat-icon">💬</span>
                                                    <span class="stat-count"><%# Eval("commentCount") %></span>
                                                </div>
                                                <div class="stat-item">
                                                    <span class="stat-icon">📤</span>
                                                    <span class="stat-count"><%# Eval("shareCount") %></span>
                                                </div>
                                            </div>
                                            <div class="post-actions">
                                                <a href="StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>&postId=<%# Eval("postId") %>" class="action-btn view-post">
                                                    <span class="action-icon">👁️</span>
                                                    View Post
                                                </a>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <!-- Saved Posts -->
                                <asp:Repeater ID="rptSavedPosts" runat="server">
                                    <ItemTemplate>
                                        <div class="post-card activity-item saved-post" data-activity-type="saved">
                                            <div class="post-header">
                                                <div class="post-author">
                                                    <div class="post-avatar">
                                                        <%# Eval("authorName").ToString().Substring(0, 1).ToUpper() %>
                                                    </div>
                                                    <div class="post-meta">
                                                        <div class="post-author-name"><%# Eval("authorName") %></div>
                                                        <div class="post-time"><%# Eval("timestamp") %></div>
                                                        <div class="post-group">in <%# Eval("groupName") %></div>
                                                    </div>
                                                </div>
                                                <div class="activity-badge saved">
                                                    <span class="badge-icon">⭐</span>
                                                    <span class="badge-text">Saved</span>
                                                </div>
                                            </div>
                                            <div class="post-content">
                                                <div class="post-text"><%# Eval("content") %></div>
                                            </div>
                                            <div class="post-stats">
                                                <div class="stat-item">
                                                    <span class="stat-icon">❤️</span>
                                                    <span class="stat-count"><%# Eval("likeCount") %></span>
                                                </div>
                                                <div class="stat-item">
                                                    <span class="stat-icon">💬</span>
                                                    <span class="stat-count"><%# Eval("commentCount") %></span>
                                                </div>
                                                <div class="stat-item">
                                                    <span class="stat-icon">📤</span>
                                                    <span class="stat-count"><%# Eval("shareCount") %></span>
                                                </div>
                                            </div>
                                            <div class="post-actions">
                                                <a href="StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>&postId=<%# Eval("postId") %>" class="action-btn view-post">
                                                    <span class="action-icon">👁️</span>
                                                    View Post
                                                </a>
                                                <asp:LinkButton ID="btnUnsave" runat="server" 
                                                    CommandArgument='<%# Eval("postId") + "|" + Eval("groupId") %>'
                                                    OnClick="btnUnsavePost_Click" 
                                                    CssClass="action-btn unsave-btn"
                                                    OnClientClick="return confirm('Remove this post from your saved items?');">
                                                    <span class="action-icon">🗑️</span>
                                                    Unsave
                                                </asp:LinkButton>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <!-- Shared Posts -->
                                <asp:Repeater ID="rptSharedPosts" runat="server">
                                    <ItemTemplate>
                                        <div class="post-card activity-item shared-post" data-activity-type="shared">
                                            <div class="post-header">
                                                <div class="post-author">
                                                    <div class="post-avatar">
                                                        <%# Eval("authorName").ToString().Substring(0, 1).ToUpper() %>
                                                    </div>
                                                    <div class="post-meta">
                                                        <div class="post-author-name"><%# Eval("authorName") %></div>
                                                        <div class="post-time"><%# Eval("timestamp") %></div>
                                                        <div class="post-group">in <%# Eval("groupName") %></div>
                                                    </div>
                                                </div>
                                                <div class="activity-badge shared">
                                                    <span class="badge-icon">📤</span>
                                                    <span class="badge-text">Shared</span>
                                                </div>
                                            </div>
                                            <div class="post-content">
                                                <div class="post-text"><%# Eval("content") %></div>
                                            </div>
                                            <div class="post-stats">
                                                <div class="stat-item">
                                                    <span class="stat-icon">❤️</span>
                                                    <span class="stat-count"><%# Eval("likeCount") %></span>
                                                </div>
                                                <div class="stat-item">
                                                    <span class="stat-icon">💬</span>
                                                    <span class="stat-count"><%# Eval("commentCount") %></span>
                                                </div>
                                                <div class="stat-item">
                                                    <span class="stat-icon">📤</span>
                                                    <span class="stat-count"><%# Eval("shareCount") %></span>
                                                </div>
                                            </div>
                                            <div class="post-actions">
                                                <a href="StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>&postId=<%# Eval("postId") %>" class="action-btn view-post">
                                                    <span class="action-icon">👁️</span>
                                                    View Post
                                                </a>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <!-- No Activity -->
                            <asp:Panel ID="pnlNoActivity" runat="server" Visible="false">
                                <div class="empty-state">
                                    <div class="empty-state-icon">📱</div>
                                    <h3 class="empty-state-title">No Activity Yet</h3>
                                    <p class="empty-state-text">Start engaging with StudyHub posts to see your activity here!</p>
                                    <a href="StudyHub.aspx" class="btn btn-primary" style="margin-top: 20px;">
                                        🚀 Explore StudyHub
                                    </a>
                                </div>
                            </asp:Panel>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnUploadPhoto" />
        </Triggers>
    </asp:UpdatePanel>

    <script>
        // Tab switching functionality
        function showTab(tabName) {
            try {
                // Hide all tab panels
                document.querySelectorAll('.tab-panel').forEach(panel => {
                    panel.classList.remove('active');
                });

                // Remove active class from all tab buttons
                document.querySelectorAll('.tab-button').forEach(button => {
                    button.classList.remove('active');
                });

                // Show selected tab panel
                const targetPanel = document.getElementById(tabName);
                if (targetPanel) {
                    targetPanel.classList.add('active');
                }

                // Add active class to clicked button
                event.target.closest('.tab-button').classList.add('active');

                // Load tab content if needed
                if (tabName === 'classes') {
                    loadClasses();
                } else if (tabName === 'activity') {
                    loadActivity();
                }

                // Prevent any form submission
                event.preventDefault();
                return false;
            } catch (error) {
                console.error('Error switching tabs:', error);
            }
        }

        // Profile image preview
        function previewProfileImage(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    document.querySelector('.profile-image').src = e.target.result;
                    document.getElementById('<%= btnUploadPhoto.ClientID %>').style.display = 'inline-block';
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function filterActivity(type) {
            try {
                // Update filter buttons
                document.querySelectorAll('.filter-btn').forEach(btn => {
                    btn.classList.remove('active');
                });
                event.target.classList.add('active');

                // Show/hide activity items with animation
                document.querySelectorAll('.activity-item').forEach(item => {
                    const itemType = item.getAttribute('data-activity-type');

                    if (type === 'all') {
                        item.classList.remove('hidden');
                        item.style.display = 'block';
                    } else {
                        if (itemType === type) {
                            item.classList.remove('hidden');
                            item.style.display = 'block';
                        } else {
                            item.classList.add('hidden');
                            setTimeout(() => {
                                if (item.classList.contains('hidden')) {
                                    item.style.display = 'none';
                                }
                            }, 300);
                        }
                    }
                });

                event.preventDefault();
                return false;
            } catch (error) {
                console.error('Error filtering activity:', error);
            }
        }

        // Form reset functionality
        function resetForm() {
            if (confirm('Are you sure you want to reset all changes?')) {
                // This will be handled by server-side code
                __doPostBack('<%= btnUpdateProfile.UniqueID %>', 'reset');
            }
            return false;
        }

        // Load classes (placeholder for async loading)
        function loadClasses() {
            const panel = document.getElementById('pnlClassesLoading');
            if (panel) {
                panel.style.display = 'block';
                // Simulate loading delay
                setTimeout(() => {
                    panel.style.display = 'none';
                }, 1000);
            }
        }

        // Load activity (placeholder for async loading)
        function loadActivity() {
            // Activity loading logic can be implemented here
            console.log('Loading user activity...');
        }

        // Notification functions
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.className = `alert alert-${type} alert-dismissible fade show`;
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 300px;';
            notification.innerHTML = `
                ${message}
                <button type="button" class="btn-close" onclick="this.parentElement.remove()">×</button>
            `;
            document.body.appendChild(notification);

            setTimeout(() => {
                if (notification.parentNode) {
                    notification.remove();
                }
            }, 5000);
        }

        // Initialize page
        document.addEventListener('DOMContentLoaded', function () {
            // Add smooth scrolling to tab switching
            document.querySelectorAll('.tab-button').forEach(button => {
                button.addEventListener('click', function (e) {
                    e.preventDefault();
                    document.querySelector('.tab-content').scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                });
            });

            console.log('Profile page initialized');
        });

        // Keyboard navigation support
        document.addEventListener('keydown', function (e) {
            if (e.ctrlKey || e.metaKey) {
                switch (e.key) {
                    case '1':
                        e.preventDefault();
                        showTab('overview');
                        break;
                    case '2':
                        e.preventDefault();
                        showTab('classes');
                        break;
                    case '3':
                        e.preventDefault();
                        showTab('activity');
                        break;
                }
            }
        });
    </script>
</asp:Content>