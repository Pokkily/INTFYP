<%@ Page Title="User Profile" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="ProfileOthers.aspx.cs" Inherits="YourProjectNamespace.ProfileOthers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    User Profile
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Profile Others Page Design */
        
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
            gap: 25px;
            flex-wrap: wrap;
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

        .back-button {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
            padding: 12px 25px;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .back-button:hover {
            background: rgba(255, 255, 255, 0.3);
            border-color: rgba(255, 255, 255, 0.5);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 255, 255, 0.2);
            text-decoration: none;
            color: white;
        }

        /* Privacy Blocked Section */
        .privacy-blocked {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            padding: 60px 40px;
            text-align: center;
            border: 1px solid rgba(0,0,0,0.05);
            margin-top: 30px;
        }

        .privacy-blocked-icon {
            font-size: 72px;
            margin-bottom: 20px;
            color: #6c757d;
            opacity: 0.6;
        }

        .privacy-blocked-title {
            font-size: 28px;
            font-weight: 700;
            color: #495057;
            margin-bottom: 15px;
        }

        .privacy-blocked-text {
            font-size: 16px;
            color: #6c757d;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .privacy-explanation {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            margin-top: 20px;
            text-align: left;
        }

        .privacy-explanation-title {
            font-weight: 600;
            color: #495057;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .privacy-explanation-text {
            color: #6c757d;
            font-size: 14px;
            line-height: 1.5;
        }

        /* Activity Tab Styles */
        .activity-tab {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.05);
            margin-top: 30px;
        }

        .activity-header {
            background: linear-gradient(135deg, #f8f9ff 0%, #e8ecff 100%);
            padding: 25px;
            border-bottom: 1px solid rgba(0,0,0,0.05);
        }

        .activity-title {
            font-size: 24px;
            font-weight: 700;
            color: #2c3e50;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .activity-icon {
            font-size: 28px;
            color: #667eea;
        }

        .activity-content {
            padding: 30px;
        }

        .activity-filter {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }

        .filter-btn {
            padding: 10px 20px;
            border: 2px solid #e9ecef;
            background: white;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
            font-size: 14px;
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

        .activity-grid {
            display: grid;
            gap: 20px;
        }

        .post-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            border: 1px solid rgba(0,0,0,0.05);
            overflow: hidden;
            transition: all 0.3s ease;
            animation: fadeIn 0.5s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .post-card:hover {
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            transform: translateY(-2px);
        }

        .post-header {
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .post-author {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .post-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 16px;
        }

        .post-meta {
            flex: 1;
        }

        .post-author-name {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 4px;
        }

        .post-time {
            font-size: 12px;
            color: #6c757d;
        }

        .post-group {
            font-size: 12px;
            color: #667eea;
        }

        .activity-badge {
            padding: 6px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .activity-badge.liked {
            background: rgba(231, 76, 60, 0.1);
            color: #e74c3c;
        }

        .activity-badge.saved {
            background: rgba(243, 156, 18, 0.1);
            color: #f39c12;
        }

        .activity-badge.shared {
            background: rgba(52, 152, 219, 0.1);
            color: #3498db;
        }

        .post-content {
            padding: 0 20px;
        }

        .post-text {
            color: #495057;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .post-stats {
            display: flex;
            gap: 20px;
            padding: 15px 20px;
            border-top: 1px solid #f1f3f4;
            font-size: 14px;
        }

        .stat-item {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #6c757d;
        }

        .post-actions {
            padding: 15px 20px;
            border-top: 1px solid #f1f3f4;
        }

        .action-btn {
            padding: 8px 16px;
            border-radius: 20px;
            border: none;
            background: #f8f9fa;
            color: #495057;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .action-btn:hover {
            background: #e9ecef;
            color: #667eea;
            text-decoration: none;
        }

        .empty-activity {
            text-align: center;
            padding: 60px 30px;
            color: #6c757d;
        }

        .empty-activity-icon {
            font-size: 72px;
            margin-bottom: 20px;
            opacity: 0.6;
        }

        .empty-activity-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .empty-activity-text {
            font-size: 16px;
            opacity: 0.8;
        }

        /* Loading states */
        .loading {
            opacity: 0.6;
            pointer-events: none;
            position: relative;
            min-height: 200px;
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

            .privacy-blocked {
                padding: 40px 25px;
            }

            .privacy-blocked-icon {
                font-size: 56px;
            }

            .privacy-blocked-title {
                font-size: 24px;
            }

            .activity-content {
                padding: 20px;
            }

            .activity-filter {
                flex-wrap: wrap;
                gap: 10px;
            }
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

                            <asp:Panel ID="pnlPublicStats" runat="server">
                                <div class="profile-stats">
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
                                            <asp:Literal ID="ltActivityCount" runat="server" Text="0" />
                                        </span>
                                        <span class="stat-label">Activities</span>
                                    </div>
                                </div>
                            </asp:Panel>
                        </div>

                        <div>
                            <a href="javascript:history.back()" class="back-button">
                                ← Back
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Privacy Blocked Section -->
                <asp:Panel ID="pnlPrivacyBlocked" runat="server" Visible="false">
                    <div class="privacy-blocked">
                        <div class="privacy-blocked-icon">🔒</div>
                        <h2 class="privacy-blocked-title">This Profile is Private</h2>
                        <p class="privacy-blocked-text">
                            This user has set their profile to private. You cannot view their profile information or activity.
                        </p>
                        
                        <div class="privacy-explanation">
                            <div class="privacy-explanation-title">
                                <span>ℹ️</span>
                                Privacy Notice
                            </div>
                            <div class="privacy-explanation-text">
                                Users can choose to make their profiles private to protect their personal information and activity. 
                                This helps maintain privacy while still participating in study groups and classes.
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <!-- Activity Tab (for Public Profiles) -->
                <asp:Panel ID="pnlPublicActivity" runat="server" Visible="false">
                    <div class="activity-tab">
                        <div class="activity-header">
                            <h2 class="activity-title">
                                <span class="activity-icon">📱</span>
                                <asp:Literal ID="ltUserFirstName" runat="server" Text="User" />'s Study Hub Activity
                            </h2>
                        </div>
                        
                        <div class="activity-content">
                            <!-- Activity Filter -->
                            <div class="activity-filter">
                                <button type="button" class="filter-btn active" onclick="filterActivity('all')">All Activity</button>
                                <button type="button" class="filter-btn" onclick="filterActivity('liked')">❤️ Liked Posts</button>
                                <button type="button" class="filter-btn" onclick="filterActivity('saved')">⭐ Saved Posts</button>
                                <button type="button" class="filter-btn" onclick="filterActivity('shared')">📤 Shared Posts</button>
                            </div>

                            <!-- Loading Panel -->
                            <asp:Panel ID="pnlActivityLoading" runat="server" CssClass="loading"></asp:Panel>

                            <!-- Activity Content -->
                            <asp:Panel ID="pnlActivityContent" runat="server">
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
                                                    <a href="StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>&postId=<%# Eval("postId") %>" class="action-btn">
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
                                                    <a href="StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>&postId=<%# Eval("postId") %>" class="action-btn">
                                                        <span class="action-icon">👁️</span>
                                                        View Post
                                                    </a>
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
                                                    <a href="StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>&postId=<%# Eval("postId") %>" class="action-btn">
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
                                    <div class="empty-activity">
                                        <div class="empty-activity-icon">📱</div>
                                        <h3 class="empty-activity-title">No Activity Yet</h3>
                                        <p class="empty-activity-text">This user hasn't engaged with any StudyHub posts yet.</p>
                                    </div>
                                </asp:Panel>
                            </asp:Panel>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script>
        function filterActivity(type) {
            try {
                // Update filter buttons
                document.querySelectorAll('.filter-btn').forEach(btn => {
                    btn.classList.remove('active');
                });
                if (event && event.target) {
                    event.target.classList.add('active');
                }

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

                if (event) {
                    event.preventDefault();
                    return false;
                }
            } catch (error) {
                console.error('Error filtering activity:', error);
            }
        }

        // Enhanced notification function
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.className = `alert alert-${type} alert-dismissible fade show`;
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 400px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);';

            let icon = '';
            switch (type) {
                case 'success': icon = '✅'; break;
                case 'danger': icon = '❌'; break;
                case 'warning': icon = '⚠️'; break;
                case 'info': icon = 'ℹ️'; break;
                default: icon = '📢'; break;
            }

            notification.innerHTML = `
                <strong>${icon}</strong> ${message}
                <button type="button" class="btn-close" onclick="this.parentElement.remove()">×</button>
            `;
            document.body.appendChild(notification);

            setTimeout(() => {
                if (notification && notification.parentElement) {
                    notification.classList.remove('show');
                    setTimeout(() => {
                        if (notification.parentElement) {
                            notification.remove();
                        }
                    }, 150);
                }
            }, 5000);
        }

        // Initialize page
        document.addEventListener('DOMContentLoaded', function () {
            // Add any initialization code here
        });
    </script>
</asp:Content>