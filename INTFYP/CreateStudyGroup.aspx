<%@ Page Title="Study Hub Group" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="StudyHubGroup.aspx.cs" Inherits="YourProjectNamespace.StudyHubGroup" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Study Group
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Study Group Page Design */
        
        .study-group-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        }

        .group-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
            padding: 30px;
            color: white;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 15px 35px rgba(103, 126, 234, 0.3);
        }

        .group-header::before {
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

        .group-header-content {
            position: relative;
            z-index: 1;
        }

        .group-title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 10px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }

        .group-meta {
            font-size: 16px;
            opacity: 0.9;
            margin-bottom: 15px;
        }

        .group-description {
            font-size: 18px;
            line-height: 1.6;
            opacity: 0.95;
        }

        .group-stats {
            display: flex;
            gap: 30px;
            margin-top: 20px;
        }

        .stat-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 16px;
        }

        .stat-icon {
            font-size: 20px;
        }

        .post-creation-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.05);
            transition: all 0.3s ease;
        }

        .post-creation-card:hover {
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
            transform: translateY(-2px);
        }

        .post-creation-header {
            background: linear-gradient(135deg, #f8f9ff 0%, #e8ecff 100%);
            padding: 25px;
            border-bottom: 1px solid rgba(0,0,0,0.05);
        }

        .post-creation-title {
            font-size: 20px;
            font-weight: 600;
            color: #2c3e50;
            margin: 0;
        }

        .post-creation-body {
            padding: 25px;
        }

        .form-control {
            border-radius: 12px;
            border: 2px solid #e9ecef;
            padding: 15px;
            font-size: 16px;
            transition: all 0.3s ease;
            background: #f8f9fa;
        }

        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: white;
        }

        .file-upload-area {
    border: 2px solid #dee2e6;
    border-radius: 12px;
    padding: 30px;
    text-align: center;
    background: #f8f9fa;
    transition: all 0.3s ease;
    cursor: pointer;
}

.file-upload-area:hover {
    border-color: #667eea;
    background: rgba(103, 126, 234, 0.05);
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(103, 126, 234, 0.15);
}

.file-upload-icon {
    font-size: 48px;
    color: #6c757d;
    margin-bottom: 15px;
}

.file-upload-text {
    color: #6c757d;
    font-size: 16px;
}

        .btn-post {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 15px 35px;
            border-radius: 25px;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 8px 20px rgba(103, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
        }

        .btn-post::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .btn-post:hover::before {
            width: 300px;
            height: 300px;
        }

        .btn-post:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(103, 126, 234, 0.4);
        }

        .post-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            animation: postSlideIn 0.6s ease-out;
        }

        @keyframes postSlideIn {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .post-card:hover {
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        }

        .post-header {
            padding: 25px 25px 15px 25px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .post-author {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .author-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 18px;
        }

        .author-info {
            display: flex;
            flex-direction: column;
        }

        .author-name {
            font-weight: 600;
            color: #2c3e50;
            font-size: 16px;
        }

        .post-timestamp {
            font-size: 14px;
            color: #6c757d;
        }

        .post-actions-menu {
            position: relative;
        }

        .post-menu-btn {
            background: none;
            border: none;
            color: #6c757d;
            font-size: 20px;
            cursor: pointer;
            padding: 8px;
            border-radius: 50%;
            transition: all 0.3s ease;
        }

        .post-menu-btn:hover {
            background: #f8f9fa;
            color: #495057;
        }

        .post-dropdown {
            position: absolute;
            right: 0;
            top: 100%;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            padding: 10px 0;
            min-width: 150px;
            z-index: 1000;
            border: 1px solid rgba(0,0,0,0.1);
        }

        .dropdown-item {
            display: block;
            width: 100%;
            padding: 12px 20px;
            border: none;
            background: none;
            text-align: left;
            color: #495057;
            text-decoration: none;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .dropdown-item:hover {
            background: #f8f9fa;
            color: #667eea;
        }

        .dropdown-item.danger:hover {
            background: #ffeaea;
            color: #dc3545;
        }

        .post-content {
            padding: 0 25px 20px 25px;
        }

        .post-text {
            font-size: 16px;
            line-height: 1.6;
            color: #2c3e50;
            margin-bottom: 20px;
        }

        .post-image {
            width: 100%;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .post-attachments {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 20px;
        }

        .attachment-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            background: #f8f9fa;
            border-radius: 10px;
            text-decoration: none;
            color: #495057;
            transition: all 0.3s ease;
            border: 1px solid #e9ecef;
        }

        .attachment-item:hover {
            background: #e9ecef;
            color: #667eea;
            text-decoration: none;
        }

        .attachment-icon {
            font-size: 20px;
        }

        .post-reactions {
            border-top: 1px solid #f1f3f4;
            padding: 20px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .reaction-buttons {
            display: flex;
            gap: 25px;
        }

        .reaction-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            background: none;
            border: none;
            color: #6c757d;
            font-size: 14px;
            cursor: pointer;
            padding: 8px 12px;
            border-radius: 20px;
            transition: all 0.3s ease;
            font-weight: 500;
            position: relative;
        }

        .reaction-btn:hover {
            background: #f8f9fa;
            color: #495057;
            transform: translateY(-1px);
        }

        .reaction-btn.liked {
            color: #e74c3c;
            background: rgba(231, 76, 60, 0.1);
        }

        .reaction-btn.saved {
            color: #f39c12;
            background: rgba(243, 156, 18, 0.1);
        }

        .reaction-btn.shared {
            color: #3498db;
        }

        .reaction-icon {
            font-size: 18px;
        }

        .share-dropdown {
            position: relative;
        }

        .share-menu {
            position: absolute;
            bottom: 100%;
            left: 0;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            padding: 15px;
            min-width: 200px;
            z-index: 1000;
            border: 1px solid rgba(0,0,0,0.1);
            margin-bottom: 10px;
        }

        .share-option {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px;
            border-radius: 8px;
            text-decoration: none;
            color: #495057;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .share-option:hover {
            background: #f8f9fa;
            color: #667eea;
            text-decoration: none;
        }

        .comments-section {
            border-top: 1px solid #f1f3f4;
            padding: 25px;
            background: #fafbfc;
        }

        .comments-header {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 20px;
        }

        .comment-item {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            border: 1px solid #e9ecef;
            transition: all 0.3s ease;
        }

        .comment-item:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .comment-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .comment-author {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .comment-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4ecdc4, #44a08d);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 14px;
        }

        .comment-text {
            color: #2c3e50;
            line-height: 1.5;
            font-size: 15px;
        }

        .comment-actions {
            display: flex;
            gap: 15px;
            margin-top: 15px;
        }

        .comment-action-btn {
            background: none;
            border: none;
            color: #6c757d;
            font-size: 13px;
            cursor: pointer;
            padding: 6px 12px;
            border-radius: 15px;
            transition: all 0.3s ease;
        }

        .comment-action-btn:hover {
            background: #f8f9fa;
            color: #495057;
        }

        .new-comment-form {
            background: white;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid #e9ecef;
            margin-top: 20px;
        }

        .comment-input {
            width: 100%;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            padding: 15px;
            font-size: 15px;
            resize: vertical;
            min-height: 80px;
            background: #f8f9fa;
            transition: all 0.3s ease;
        }

        .comment-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: white;
            outline: none;
        }

        .comment-submit-btn {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 15px;
        }

        .comment-submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(78, 205, 196, 0.3);
        }

        .edit-mode {
            border: 2px solid #667eea !important;
            background: rgba(103, 126, 234, 0.05) !important;
        }

        .edit-controls {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }

        .btn-save {
            background: #28a745;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
        }

        /* Loading states */
        .loading {
            opacity: 0.6;
            pointer-events: none;
        }

        .spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Enhanced interaction feedback */
        .reaction-btn.processing {
            opacity: 0.7;
            transform: scale(0.95);
        }

        .notification-badge {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            max-width: 300px;
            animation: slideInRight 0.3s ease-out;
        }

        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .study-group-container {
                padding: 15px;
            }

            .group-header {
                padding: 20px;
            }

            .group-title {
                font-size: 24px;
            }

            .group-stats {
                flex-direction: column;
                gap: 15px;
            }

            .post-creation-header,
            .post-creation-body {
                padding: 20px;
            }

            .post-header {
                padding: 20px 20px 15px 20px;
            }

            .post-content {
                padding: 0 20px 15px 20px;
            }

            .post-reactions {
                padding: 15px 20px;
            }

            .reaction-buttons {
                gap: 15px;
            }

            .comments-section {
                padding: 20px;
            }
        }

        /* Accessibility improvements */
        .reaction-btn:focus,
        .comment-action-btn:focus,
        .btn-post:focus,
        .comment-submit-btn:focus {
            outline: 3px solid rgba(103, 126, 234, 0.5);
            outline-offset: 2px;
        }

        /* Dark mode support (optional) */
        @media (prefers-color-scheme: dark) {
            .post-card,
            .post-creation-card,
            .comment-item,
            .new-comment-form {
                background: #1a1a1a;
                border-color: #333;
                color: #fff;
            }

            .form-control,
            .comment-input {
                background: #2a2a2a;
                border-color: #444;
                color: #fff;
            }
        }
    </style>

    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="false">
        <ContentTemplate>
            <div class="study-group-container">
                <!-- Enhanced Group Header -->
                <div class="group-header">
                    <div class="group-header-content">
                        <asp:Literal ID="ltGroupDetails" runat="server" />
                    </div>
                </div>

                <!-- Enhanced Create Post Section -->
                <div class="post-creation-card">
                    <div class="post-creation-header">
                        <h5 class="post-creation-title">📝 Share Something with the Group</h5>
                    </div>
                    <div class="post-creation-body">
                        <asp:TextBox ID="txtPostContent" runat="server" TextMode="MultiLine" CssClass="form-control mb-3" 
                            placeholder="What's on your mind? Share your thoughts, questions, or study materials..."></asp:TextBox>
                        
                        <div class="file-upload-area mb-3" onclick="document.getElementById('<%= fileUpload.ClientID %>').click();">
    <div class="file-upload-icon">📎</div>
    <div class="file-upload-text">
        <strong>Click to attach files</strong><br>
        <small>Support: Images (JPG, PNG, GIF), Documents (PDF, DOC) - Max 10MB each</small>
    </div>
    <asp:FileUpload ID="fileUpload" runat="server" AllowMultiple="true" 
        accept=".jpg,.jpeg,.png,.gif,.pdf,.doc,.docx" style="display: none;" />
</div>

                        <div class="d-flex justify-content-between align-items-center">
                            <div class="form-check">
                                <asp:CheckBox ID="chkAnonymous" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="<%= chkAnonymous.ClientID %>">
                                    Post anonymously
                                </label>
                            </div>
                            <asp:Button ID="btnPost" runat="server" CssClass="btn-post" Text="📤 Share Post" OnClick="btnPost_Click" />
                        </div>
                    </div>
                </div>

                <!-- Enhanced Posts List -->
                <asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand">
                    <ItemTemplate>
                        <div class="post-card" data-post-id='<%# Eval("postId") %>'>
                            <!-- Post Header -->
                            <div class="post-header">
                                <div class="post-author">
                                    <div class="author-avatar">
                                        <%# Eval("creatorUsername").ToString().Substring(0, 1).ToUpper() %>
                                    </div>
                                    <div class="author-info">
                                        <div class="author-name"><%# Eval("creatorUsername") %></div>
                                        <div class="post-timestamp"><%# Eval("timestamp") %></div>
                                    </div>
                                </div>
                                
                                <div class="post-actions-menu" runat="server" visible='<%# (bool)Eval("isOwner") %>'>
                                    <button class="post-menu-btn" type="button" onclick="toggleDropdown(this)">⋯</button>
                                    <div class="post-dropdown" style="display: none;">
                                        <asp:LinkButton ID="btnEditPost" runat="server" 
                                            CommandName="EditPost" 
                                            CommandArgument='<%# Eval("postId") %>' 
                                            CssClass="dropdown-item"
                                            OnClientClick="storeScrollPosition();">
                                            ✏️ Edit Post
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDeletePost" runat="server" 
                                            CommandName="DeletePost" 
                                            CommandArgument='<%# Eval("postId") %>' 
                                            CssClass="dropdown-item danger"
                                            OnClientClick="storeScrollPosition(); return confirm('Are you sure you want to delete this post?')">
                                            🗑️ Delete Post
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>

                            <!-- Post Content -->
                            <div class="post-content">
                                <!-- View Mode -->
                                <asp:Panel ID="pnlPostView" runat="server" Visible='<%# !(bool)Eval("IsEditingPost") %>'>
                                    <div class="post-text"><%# Eval("content") %></div>
                                    
                                    <!-- Post Attachments -->
                                    <asp:Repeater ID="rptAttachments" runat="server" DataSource='<%# Eval("attachments") %>'>
                                        <HeaderTemplate>
                                            <div class="post-attachments">
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <%# Eval("fileType").ToString().StartsWith("image") ? 
                                                "<img src='" + Eval("fileUrl") + "' class='post-image' alt='Post Image' />" :
                                                "<a href='" + Eval("fileUrl") + "' class='attachment-item' target='_blank'>" +
                                                "<span class='attachment-icon'>📄</span>" +
                                                "<span>" + Eval("fileName") + "</span></a>" %>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            </div>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </asp:Panel>

                                <!-- Edit Mode -->
                                <asp:Panel ID="pnlPostEdit" runat="server" Visible='<%# (bool)Eval("IsEditingPost") %>'>
                                    <div class="edit-mode">
                                        <asp:TextBox ID="txtEditPost" runat="server" CssClass="form-control" 
                                            Text='<%# Eval("content") %>' TextMode="MultiLine" Rows="4"></asp:TextBox>
                                        <div class="edit-controls">
                                            <asp:Button ID="btnSavePost" runat="server" CommandName="SavePost" 
                                                CommandArgument='<%# Eval("postId") %>' Text="💾 Save" CssClass="btn-save"
                                                OnClientClick="storeScrollPosition();" />
                                            <asp:Button ID="btnCancelPost" runat="server" CommandName="CancelPost" 
                                                CommandArgument='<%# Eval("postId") %>' Text="❌ Cancel" CssClass="btn-cancel"
                                                OnClientClick="storeScrollPosition();" />
                                        </div>
                                    </div>
                                </asp:Panel>
                            </div>

                            <!-- Enhanced Post Reactions -->
                            <div class="post-reactions">
                                <div class="reaction-buttons">
                                    <asp:LinkButton ID="btnLike" runat="server" 
                                        CommandName="ToggleLike" 
                                        CommandArgument='<%# Eval("postId") %>' 
                                        CssClass='<%# "reaction-btn " + ((bool)Eval("isLiked") ? "liked" : "") %>'
                                        OnClientClick="storeScrollPosition(); handleLikeClick(this); return true;">
                                        <span class="reaction-icon"><%# (bool)Eval("isLiked") ? "❤️" : "🤍" %></span>
                                        <span><%# Eval("likeCount") %> Likes</span>
                                    </asp:LinkButton>

                                    <div class="share-dropdown">
                                        <button class="reaction-btn" type="button" onclick="toggleShareMenu(this)">
                                            <span class="reaction-icon">📤</span>
                                            <span>Share</span>
                                        </button>
                                        <div class="share-menu" style="display: none;">
                                            <div class="share-option" onclick="shareToClipboard('<%# Eval("postId") %>')">
                                                <span>🔗</span> Copy Link
                                            </div>
                                            <div class="share-option" onclick="shareViaEmail('<%# Eval("postId") %>')">
                                                <span>📧</span> Share via Email
                                            </div>
                                            <asp:LinkButton ID="btnInternalShare" runat="server" 
                                                CommandName="InternalShare" 
                                                CommandArgument='<%# Eval("postId") %>' 
                                                CssClass="share-option"
                                                OnClientClick="storeScrollPosition();">
                                                <span>🔄</span> Share to Timeline
                                            </asp:LinkButton>
                                        </div>
                                    </div>

                                    <asp:LinkButton ID="btnSave" runat="server" 
                                        CommandName="ToggleSave" 
                                        CommandArgument='<%# Eval("postId") %>' 
                                        CssClass='<%# "reaction-btn " + ((bool)Eval("isSaved") ? "saved" : "") %>'
                                        OnClientClick="storeScrollPosition();">
                                        <span class="reaction-icon"><%# (bool)Eval("isSaved") ? "⭐" : "☆" %></span>
                                        <span><%# (bool)Eval("isSaved") ? "Saved" : "Save" %></span>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnReport" runat="server" 
                                        CommandName="ReportPost" 
                                        CommandArgument='<%# Eval("postId") %>' 
                                        CssClass="reaction-btn"
                                        Visible='<%# !(bool)Eval("isOwner") %>'
                                        OnClientClick="storeScrollPosition(); return confirm('Report this post as inappropriate?')">
                                        <span class="reaction-icon">🚩</span>
                                        <span>Report</span>
                                    </asp:LinkButton>
                                </div>
                                
                                <div class="post-stats">
                                    <small class="text-muted">
                                        <%# Eval("commentCount") %> comments • <%# Eval("shareCount") %> shares
                                    </small>
                                </div>
                            </div>

                            <!-- Enhanced Comments Section -->
                            <div class="comments-section">
                                <div class="comments-header">
                                    💬 Comments (<%# ((List<dynamic>)Eval("comments")).Count %>)
                                </div>
                                
                                <!-- Comments List -->
                                <asp:Repeater ID="rptComments" runat="server" DataSource='<%# Eval("comments") %>' OnItemCommand="rptComments_ItemCommand">
                                    <ItemTemplate>
                                        <div class="comment-item">
                                            <div class="comment-header">
                                                <div class="comment-author">
                                                    <div class="comment-avatar">
                                                        <%# Eval("username").ToString().Substring(0, 1).ToUpper() %>
                                                    </div>
                                                    <div>
                                                        <strong><%# Eval("username") %></strong>
                                                        <div class="post-timestamp"><%# Eval("timestamp") %></div>
                                                    </div>
                                                </div>
                                                <div runat="server" visible='<%# (bool)Eval("isOwner") %>'>
                                                    <asp:LinkButton ID="btnEditComment" runat="server" 
                                                        CommandName="EditComment" 
                                                        CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                        CssClass="comment-action-btn"
                                                        OnClientClick="storeScrollPosition();">
                                                        ✏️
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="btnDeleteComment" runat="server" 
                                                        CommandName="DeleteComment" 
                                                        CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                        CssClass="comment-action-btn"
                                                        OnClientClick="storeScrollPosition(); return confirm('Delete this comment?')">
                                                        🗑️
                                                    </asp:LinkButton>
                                                </div>
                                            </div>

                                            <!-- Comment Content / Edit -->
                                            <asp:Panel ID="pnlCommentView" runat="server" Visible='<%# !(bool)Eval("IsEditingComment") %>'>
                                                <div class="comment-text"><%# Eval("content") %></div>
                                                <div class="comment-actions">
                                                    <button class="comment-action-btn" onclick="toggleCommentLike(this, '<%# Eval("commentId") %>')">
                                                        <span>👍</span> Like
                                                    </button>
                                                    <button class="comment-action-btn" onclick="replyToComment('<%# Eval("commentId") %>')">
                                                        <span>💬</span> Reply
                                                    </button>
                                                </div>
                                            </asp:Panel>

                                            <asp:Panel ID="pnlCommentEdit" runat="server" Visible='<%# (bool)Eval("IsEditingComment") %>'>
                                                <div class="edit-mode">
                                                    <asp:TextBox ID="txtEditComment" runat="server" CssClass="comment-input" 
                                                        Text='<%# Eval("content") %>' TextMode="MultiLine"></asp:TextBox>
                                                    <div class="edit-controls">
                                                        <asp:Button ID="btnSaveComment" runat="server" CommandName="SaveComment" 
                                                            CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                            Text="💾 Save" CssClass="btn-save"
                                                            OnClientClick="storeScrollPosition();" />
                                                        <asp:Button ID="btnCancelComment" runat="server" CommandName="CancelComment" 
                                                            CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                            Text="❌ Cancel" CssClass="btn-cancel"
                                                            OnClientClick="storeScrollPosition();" />
                                                    </div>
                                                </div>
                                            </asp:Panel>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <!-- New Comment Form -->
                                <div class="new-comment-form">
                                    <asp:TextBox ID="txtNewComment" runat="server" CssClass="comment-input" 
                                        placeholder="Write a thoughtful comment..." TextMode="MultiLine"></asp:TextBox>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="form-check">
                                            <asp:CheckBox ID="chkAnonymousComment" runat="server" CssClass="form-check-input" />
                                            <label class="form-check-label">Comment anonymously</label>
                                        </div>
                                        <asp:Button ID="btnComment" runat="server" CommandName="AddComment" 
                                            CommandArgument='<%# Eval("postId") %>' Text="💬 Post Comment" 
                                            CssClass="comment-submit-btn"
                                            OnClientClick="storeScrollPosition();" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <!-- No Posts Message -->
                <asp:Panel ID="pnlNoPosts" runat="server" Visible="false">
                    <div class="post-card" style="text-align: center; padding: 60px 30px;">
                        <div style="font-size: 72px; margin-bottom: 20px; opacity: 0.6;">📝</div>
                        <h3 style="color: #6c757d; margin-bottom: 15px;">No posts yet</h3>
                        <p style="color: #adb5bd; font-size: 16px;">Be the first to share something with the group!</p>
                    </div>
                </asp:Panel>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnPost" />
            <asp:AsyncPostBackTrigger ControlID="rptPosts" />
        </Triggers>
    </asp:UpdatePanel>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const fileInput = document.querySelector('input[type="file"]');
            const uploadArea = document.querySelector('.file-upload-area');
            const uploadText = uploadArea.querySelector('.file-upload-text');

            if (!fileInput || !uploadArea) return;

            // Handle file selection
            fileInput.addEventListener('change', handleFileSelection);

            function handleFileSelection() {
                const files = fileInput.files;

                if (files.length > 0) {
                    updateUploadAreaText(files);
                    createFilePreview(files);
                    validateFiles(files);
                } else {
                    resetUploadArea();
                }
            }

            function updateUploadAreaText(files) {
                const totalSize = Array.from(files).reduce((total, file) => total + file.size, 0);
                const totalSizeMB = (totalSize / (1024 * 1024)).toFixed(2);

                uploadText.innerHTML = `
                <strong>${files.length} file(s) selected</strong><br>
                <small>Total size: ${totalSizeMB} MB</small><br>
                <small>Review your files below before posting</small>
            `;
            }

            function createFilePreview(files) {
                // Remove existing preview
                const existingPreview = document.querySelector('.files-preview-container');
                if (existingPreview) {
                    existingPreview.remove();
                }

                // Create preview container
                const previewContainer = document.createElement('div');
                previewContainer.className = 'files-preview-container';
                previewContainer.style.cssText = `
                margin-top: 20px;
                padding: 20px;
                background: white;
                border-radius: 12px;
                border: 1px solid #e9ecef;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            `;

                const previewTitle = document.createElement('h6');
                previewTitle.textContent = 'Selected Files Preview';
                previewTitle.style.cssText = `
                margin: 0 0 15px 0;
                color: #495057;
                font-weight: 600;
                font-size: 16px;
            `;

                const filesGrid = document.createElement('div');
                filesGrid.className = 'files-grid';
                filesGrid.style.cssText = `
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                gap: 15px;
                max-height: 400px;
                overflow-y: auto;
            `;

                Array.from(files).forEach((file, index) => {
                    const fileCard = createFileCard(file, index);
                    filesGrid.appendChild(fileCard);
                });

                previewContainer.appendChild(previewTitle);
                previewContainer.appendChild(filesGrid);

                // Insert after upload area
                uploadArea.insertAdjacentElement('afterend', previewContainer);
            }

            function createFileCard(file, index) {
                const fileCard = document.createElement('div');
                fileCard.className = 'file-card';
                fileCard.style.cssText = `
                background: #f8f9fa;
                border: 1px solid #e9ecef;
                border-radius: 10px;
                padding: 15px;
                position: relative;
                transition: all 0.3s ease;
                display: flex;
                flex-direction: column;
                align-items: center;
                text-align: center;
            `;

                // Remove button
                const removeBtn = document.createElement('button');
                removeBtn.innerHTML = '×';
                removeBtn.title = 'Remove file';
                removeBtn.style.cssText = `
                position: absolute;
                top: 8px;
                right: 8px;
                width: 24px;
                height: 24px;
                border-radius: 50%;
                border: none;
                background: #dc3545;
                color: white;
                cursor: pointer;
                font-size: 16px;
                font-weight: bold;
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 10;
            `;

                removeBtn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    removeFile(index);
                });

                // File preview area
                const previewArea = document.createElement('div');
                previewArea.style.cssText = `
                width: 100%;
                height: 120px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 10px;
                border-radius: 8px;
                overflow: hidden;
                background: white;
            `;

                if (file.type.startsWith('image/')) {
                    // Image preview
                    const img = document.createElement('img');
                    img.style.cssText = `
                    max-width: 100%;
                    max-height: 100%;
                    object-fit: cover;
                    border-radius: 6px;
                `;

                    const reader = new FileReader();
                    reader.onload = function (e) {
                        img.src = e.target.result;
                    };
                    reader.readAsDataURL(file);

                    previewArea.appendChild(img);

                    // Add click to view full size
                    previewArea.style.cursor = 'pointer';
                    previewArea.addEventListener('click', function () {
                        showImageModal(img.src, file.name);
                    });
                } else {
                    // Document icon
                    const fileIcon = document.createElement('div');
                    fileIcon.style.cssText = `
                    font-size: 48px;
                    color: #6c757d;
                `;
                    fileIcon.textContent = getFileIcon(file.type);
                    previewArea.appendChild(fileIcon);
                }

                // File info
                const fileName = document.createElement('div');
                fileName.textContent = file.name.length > 25 ? file.name.substring(0, 25) + '...' : file.name;
                fileName.title = file.name;
                fileName.style.cssText = `
                font-weight: 600;
                color: #495057;
                margin-bottom: 5px;
                font-size: 14px;
                word-break: break-word;
            `;

                const fileSize = document.createElement('div');
                fileSize.textContent = formatFileSize(file.size);
                fileSize.style.cssText = `
                color: #6c757d;
                font-size: 12px;
                margin-bottom: 5px;
            `;

                const fileType = document.createElement('div');
                fileType.textContent = getFileTypeLabel(file.type);
                fileType.style.cssText = `
                color: #28a745;
                font-size: 11px;
                background: #d4edda;
                padding: 2px 6px;
                border-radius: 4px;
                display: inline-block;
            `;

                fileCard.appendChild(removeBtn);
                fileCard.appendChild(previewArea);
                fileCard.appendChild(fileName);
                fileCard.appendChild(fileSize);
                fileCard.appendChild(fileType);

                // Hover effect
                fileCard.addEventListener('mouseenter', function () {
                    this.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
                    this.style.transform = 'translateY(-2px)';
                });

                fileCard.addEventListener('mouseleave', function () {
                    this.style.boxShadow = 'none';
                    this.style.transform = 'translateY(0)';
                });

                return fileCard;
            }

            function removeFile(indexToRemove) {
                const dt = new DataTransfer();
                const files = Array.from(fileInput.files);

                files.forEach((file, index) => {
                    if (index !== indexToRemove) {
                        dt.items.add(file);
                    }
                });

                fileInput.files = dt.files;

                if (fileInput.files.length === 0) {
                    resetUploadArea();
                } else {
                    handleFileSelection();
                }

                showNotification('File removed successfully', 'info');
            }

            function resetUploadArea() {
                uploadText.innerHTML = `
                <strong>Click to attach files</strong><br>
                <small>Support: Images (JPG, PNG, GIF), Documents (PDF, DOC) - Max 10MB each</small>
            `;

                const existingPreview = document.querySelector('.files-preview-container');
                if (existingPreview) {
                    existingPreview.remove();
                }
            }

            function validateFiles(files) {
                const maxSize = 10 * 1024 * 1024; // 10MB
                const allowedTypes = [
                    'image/jpeg', 'image/jpg', 'image/png', 'image/gif',
                    'application/pdf', 'application/msword',
                    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                ];

                let hasErrors = false;
                let errorCount = 0;

                Array.from(files).forEach(file => {
                    if (file.size > maxSize) {
                        showNotification(`"${file.name}" is too large (max 10MB)`, 'warning');
                        hasErrors = true;
                        errorCount++;
                    }

                    if (!allowedTypes.includes(file.type)) {
                        showNotification(`"${file.name}" file type not allowed`, 'warning');
                        hasErrors = true;
                        errorCount++;
                    }
                });

                if (!hasErrors && files.length > 0) {
                    showNotification(`${files.length} file(s) ready to upload!`, 'success');
                } else if (hasErrors) {
                    showNotification(`${errorCount} file(s) have issues. Please review and remove invalid files.`, 'danger');
                }
            }

            function showImageModal(imageSrc, fileName) {
                // Create modal overlay
                const modal = document.createElement('div');
                modal.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.8);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 9999;
                cursor: pointer;
            `;

                const modalContent = document.createElement('div');
                modalContent.style.cssText = `
                max-width: 90%;
                max-height: 90%;
                background: white;
                border-radius: 10px;
                padding: 20px;
                cursor: default;
            `;

                const modalImg = document.createElement('img');
                modalImg.src = imageSrc;
                modalImg.style.cssText = `
                max-width: 100%;
                max-height: 70vh;
                border-radius: 6px;
            `;

                const modalTitle = document.createElement('h5');
                modalTitle.textContent = fileName;
                modalTitle.style.cssText = `
                margin: 15px 0 0 0;
                text-align: center;
                color: #495057;
            `;

                modalContent.appendChild(modalImg);
                modalContent.appendChild(modalTitle);
                modal.appendChild(modalContent);

                // Close modal on click
                modal.addEventListener('click', function (e) {
                    if (e.target === modal) {
                        document.body.removeChild(modal);
                    }
                });

                // Close on escape key
                const closeOnEscape = function (e) {
                    if (e.key === 'Escape') {
                        document.body.removeChild(modal);
                        document.removeEventListener('keydown', closeOnEscape);
                    }
                };
                document.addEventListener('keydown', closeOnEscape);

                // Prevent content click from closing modal
                modalContent.addEventListener('click', function (e) {
                    e.stopPropagation();
                });

                document.body.appendChild(modal);
            }

            function getFileIcon(fileType) {
                if (fileType.startsWith('image/')) return '🖼️';
                if (fileType === 'application/pdf') return '📄';
                if (fileType.includes('word')) return '📝';
                if (fileType.includes('excel') || fileType.includes('spreadsheet')) return '📊';
                if (fileType.includes('powerpoint') || fileType.includes('presentation')) return '📊';
                return '📎';
            }

            function getFileTypeLabel(fileType) {
                if (fileType.startsWith('image/')) return 'Image';
                if (fileType === 'application/pdf') return 'PDF';
                if (fileType.includes('word')) return 'Word Doc';
                if (fileType.includes('excel')) return 'Excel';
                if (fileType.includes('powerpoint')) return 'PowerPoint';
                return 'Document';
            }

            function formatFileSize(bytes) {
                if (bytes === 0) return '0 Bytes';
                const k = 1024;
                const sizes = ['Bytes', 'KB', 'MB', 'GB'];
                const i = Math.floor(Math.log(bytes) / Math.log(k));
                return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
            }

            // Clear preview when page unloads
            window.addEventListener('beforeunload', function () {
                const existingPreview = document.querySelector('.files-preview-container');
                if (existingPreview) {
                    existingPreview.remove();
                }
            });
        });

        // Additional CSS for the preview system
        const previewStyles = `
        <style>
            .files-grid::-webkit-scrollbar {
                width: 8px;
            }
            
            .files-grid::-webkit-scrollbar-track {
                background: #f1f1f1;
                border-radius: 4px;
            }
            
            .files-grid::-webkit-scrollbar-thumb {
                background: #c1c1c1;
                border-radius: 4px;
            }
            
            .files-grid::-webkit-scrollbar-thumb:hover {
                background: #a8a8a8;
            }

            .file-card:hover {
                background: #e8f4fd !important;
                border-color: #667eea !important;
            }

            @media (max-width: 768px) {
                .files-grid {
                    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)) !important;
                    gap: 10px !important;
                }
                
                .file-card {
                    padding: 12px !important;
                }
            }
        </style>
    `;

        document.head.insertAdjacentHTML('beforeend', previewStyles);
    </script>
</asp:Content>