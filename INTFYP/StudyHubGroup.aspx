<%@ Page Title="Study Hub Group" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="StudyHubGroup.aspx.cs" Inherits="YourProjectNamespace.StudyHubGroup" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Study Group
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Study Group Page Design with Profile Image Support */
        
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

        /* Updated File Upload Styles */
        .file-upload-section {
            margin-bottom: 20px;
        }

        .file-input-wrapper {
            position: relative;
            display: inline-block;
            margin-bottom: 15px;
        }

        .file-input-btn {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .file-input-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(78, 205, 196, 0.3);
        }

        .file-input-btn i {
            font-size: 16px;
        }

        .file-input-hidden {
            position: absolute;
            left: -9999px;
            opacity: 0;
        }

        .file-preview-container {
            display: none;
            margin-top: 15px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 12px;
            border: 1px solid #e9ecef;
        }

        .file-preview-container.has-files {
            display: block;
        }

        .file-preview-header {
            font-size: 14px;
            font-weight: 600;
            color: #495057;
            margin-bottom: 10px;
        }

        .file-preview-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .file-preview-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px;
            background: white;
            border-radius: 8px;
            border: 1px solid #e9ecef;
            transition: all 0.3s ease;
        }

        .file-preview-item:hover {
            border-color: #667eea;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .file-preview-icon {
            width: 40px;
            height: 40px;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            color: white;
            flex-shrink: 0;
        }

        .file-preview-icon.image {
            background: linear-gradient(135deg, #667eea, #764ba2);
        }

        .file-preview-icon.document {
            background: linear-gradient(135deg, #fd79a8, #e84393);
        }

        .file-preview-icon.pdf {
            background: linear-gradient(135deg, #e17055, #d63031);
        }

        .file-preview-icon.other {
            background: linear-gradient(135deg, #6c757d, #495057);
        }

        .file-preview-thumbnail {
            width: 40px;
            height: 40px;
            border-radius: 6px;
            object-fit: cover;
            flex-shrink: 0;
        }

        .file-preview-info {
            flex: 1;
            min-width: 0;
        }

        .file-preview-name {
            font-size: 14px;
            font-weight: 500;
            color: #2c3e50;
            margin-bottom: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .file-preview-size {
            font-size: 12px;
            color: #6c757d;
        }

        .file-remove-btn {
            background: #dc3545;
            color: white;
            border: none;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            cursor: pointer;
            font-size: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            flex-shrink: 0;
        }

        .file-remove-btn:hover {
            background: #c82333;
            transform: scale(1.1);
        }

        .file-info-text {
            font-size: 12px;
            color: #6c757d;
            margin-top: 8px;
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

        /* Enhanced Author Avatar with Profile Image Support */
        .author-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 18px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            border: 2px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 3px 12px rgba(0, 0, 0, 0.15);
        }

        .author-avatar:hover {
            transform: scale(1.1);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25);
        }

        .author-avatar-image {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
        }

        .author-avatar-initials {
            background: linear-gradient(135deg, #667eea, #764ba2);
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            z-index: 1;
        }

        .author-avatar-initials.hide {
            display: none;
        }

        .author-info {
            display: flex;
            flex-direction: column;
        }

        .author-name {
            font-weight: 600;
            color: #2c3e50;
            font-size: 16px;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .author-name:hover {
            color: #667eea;
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
        }

        .reaction-btn:hover {
            background: #f8f9fa;
            color: #495057;
        }

        .reaction-btn.liked {
            color: #e74c3c;
        }

        .reaction-btn.saved {
            color: #f39c12;
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

        /* Enhanced Comment Avatar with Profile Image Support */
        .comment-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            border: 2px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        }

        .comment-avatar:hover {
            transform: scale(1.1);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.25);
        }

        .comment-avatar-image {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
        }

        .comment-avatar-initials {
            background: linear-gradient(135deg, #4ecdc4, #44a08d);
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            z-index: 1;
        }

        .comment-avatar-initials.hide {
            display: none;
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

            .file-preview-list {
                gap: 10px;
            }

            .file-preview-item {
                padding: 8px;
            }

            .author-avatar {
                width: 42px;
                height: 42px;
            }

            .comment-avatar {
                width: 32px;
                height: 32px;
            }
        }

        /* Accessibility improvements */
        .reaction-btn:focus,
        .comment-action-btn:focus,
        .btn-post:focus,
        .comment-submit-btn:focus,
        .file-input-btn:focus,
        .file-remove-btn:focus {
            outline: 3px solid rgba(103, 126, 234, 0.5);
            outline-offset: 2px;
        }

        /* Dark mode support (optional) */
        @media (prefers-color-scheme: dark) {
            .post-card,
            .post-creation-card,
            .comment-item,
            .new-comment-form,
            .file-preview-container,
            .file-preview-item {
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

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
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
                        
                        <!-- Updated File Upload Section -->
                        <div class="file-upload-section">
                            <div class="file-input-wrapper">
                                <button type="button" class="file-input-btn" onclick="document.getElementById('<%= fileUpload.ClientID %>').click();">
                                    <i>📎</i> Attach Files
                                </button>
                                <asp:FileUpload ID="fileUpload" runat="server" AllowMultiple="true" 
                                    accept=".jpg,.jpeg,.png,.gif,.pdf,.doc,.docx" CssClass="file-input-hidden" />
                            </div>
                            
                            <div id="filePreviewContainer" class="file-preview-container">
                                <div class="file-preview-header">Selected Files:</div>
                                <div id="filePreviewList" class="file-preview-list"></div>
                                <div class="file-info-text">Support: Images (JPG, PNG, GIF), Documents (PDF, DOC) - Max 10MB each</div>
                            </div>
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

                <!-- Enhanced Posts List with Profile Images -->
                <asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand">
                    <ItemTemplate>
                        <div class="post-card" data-post-id='<%# Eval("postId") %>'>
                            <!-- Post Header with Profile Image -->
                            <div class="post-header">
                                <div class="post-author">
                                    <div class="author-avatar" onclick="navigateToProfile('<%# Eval("creatorUserId") %>')">
                                        <!-- Profile Image (if available) -->
                                        <img class="author-avatar-image" 
                                             src='<%# Eval("creatorProfileImage") %>' 
                                             alt="Profile Picture" 
                                             style='<%# (bool)Eval("hasProfileImage") ? "display: block;" : "display: none;" %>'
                                             onerror="this.style.display='none'; this.nextElementSibling.classList.remove('hide');" />
                                        
                                        <!-- Profile Initials (fallback) -->
                                        <div class='<%# "author-avatar-initials" + ((bool)Eval("hasProfileImage") ? " hide" : "") %>'>
                                            <%# Eval("creatorInitials") %>
                                        </div>
                                    </div>
                                    <div class="author-info">
                                        <div class="author-name" onclick="navigateToProfile('<%# Eval("creatorUserId") %>')">
                                            <%# Eval("creatorUsername") %>
                                        </div>
                                        <div class="post-timestamp"><%# Eval("timestamp") %></div>
                                    </div>
                                </div>
                                
                                <div class="post-actions-menu" runat="server" visible='<%# (bool)Eval("isOwner") %>'>
                                    <button class="post-menu-btn" type="button" onclick="toggleDropdown(this)">⋯</button>
                                    <div class="post-dropdown" style="display: none;">
                                        <asp:LinkButton ID="btnEditPost" runat="server" 
                                            CommandName="EditPost" 
                                            CommandArgument='<%# Eval("postId") %>' 
                                            CssClass="dropdown-item">
                                            ✏️ Edit Post
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDeletePost" runat="server" 
                                            CommandName="DeletePost" 
                                            CommandArgument='<%# Eval("postId") %>' 
                                            CssClass="dropdown-item danger"
                                            OnClientClick="return confirm('Are you sure you want to delete this post?')">
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
                                                CommandArgument='<%# Eval("postId") %>' Text="💾 Save" CssClass="btn-save" />
                                            <asp:Button ID="btnCancelPost" runat="server" CommandName="CancelPost" 
                                                CommandArgument='<%# Eval("postId") %>' Text="❌ Cancel" CssClass="btn-cancel" />
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
                                        CssClass='<%# "reaction-btn " + ((bool)Eval("isLiked") ? "liked" : "") %>'>
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
                                                CssClass="share-option">
                                                <span>🔄</span> Share to Timeline
                                            </asp:LinkButton>
                                        </div>
                                    </div>

                                    <asp:LinkButton ID="btnSave" runat="server" 
                                        CommandName="ToggleSave" 
                                        CommandArgument='<%# Eval("postId") %>' 
                                        CssClass='<%# "reaction-btn " + ((bool)Eval("isSaved") ? "saved" : "") %>'>
                                        <span class="reaction-icon"><%# (bool)Eval("isSaved") ? "⭐" : "☆" %></span>
                                        <span><%# (bool)Eval("isSaved") ? "Saved" : "Save" %></span>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnReport" runat="server" 
                                        CommandName="ReportPost" 
                                        CommandArgument='<%# Eval("postId") %>' 
                                        CssClass="reaction-btn"
                                        Visible='<%# !(bool)Eval("isOwner") %>'
                                        OnClientClick="return confirm('Report this post as inappropriate?')">
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

                            <!-- Enhanced Comments Section with Profile Images -->
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
                                                    <div class="comment-avatar" onclick="navigateToProfile('<%# Eval("userId") %>')">
                                                        <!-- Comment Profile Image (if available) -->
                                                        <img class="comment-avatar-image" 
                                                             src='<%# Eval("profileImage") %>' 
                                                             alt="Profile Picture" 
                                                             style='<%# (bool)Eval("hasProfileImage") ? "display: block;" : "display: none;" %>'
                                                             onerror="this.style.display='none'; this.nextElementSibling.classList.remove('hide');" />
                                                        
                                                        <!-- Comment Profile Initials (fallback) -->
                                                        <div class='<%# "comment-avatar-initials" + ((bool)Eval("hasProfileImage") ? " hide" : "") %>'>
                                                            <%# Eval("initials") %>
                                                        </div>
                                                    </div>
                                                    <div>
                                                        <strong onclick="navigateToProfile('<%# Eval("userId") %>')" style="cursor: pointer;">
                                                            <%# Eval("username") %>
                                                        </strong>
                                                        <div class="post-timestamp"><%# Eval("timestamp") %></div>
                                                    </div>
                                                </div>
                                                <div runat="server" visible='<%# (bool)Eval("isOwner") %>'>
                                                    <asp:LinkButton ID="btnEditComment" runat="server" 
                                                        CommandName="EditComment" 
                                                        CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                        CssClass="comment-action-btn">
                                                        ✏️
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="btnDeleteComment" runat="server" 
                                                        CommandName="DeleteComment" 
                                                        CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                        CssClass="comment-action-btn"
                                                        OnClientClick="return confirm('Delete this comment?')">
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
                                                            Text="💾 Save" CssClass="btn-save" />
                                                        <asp:Button ID="btnCancelComment" runat="server" CommandName="CancelComment" 
                                                            CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                            Text="❌ Cancel" CssClass="btn-cancel" />
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
                                            CssClass="comment-submit-btn" />
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
        </Triggers>
    </asp:UpdatePanel>

    <script>
        // File handling variables
        let selectedFiles = [];
        let fileInput = null;

        // Initialize file handling
        document.addEventListener('DOMContentLoaded', function () {
            fileInput = document.querySelector('input[type="file"]');
            if (fileInput) {
                fileInput.addEventListener('change', handleFileSelection);
            }
        });

        // Handle file selection
        function handleFileSelection() {
            selectedFiles = Array.from(fileInput.files);
            updateFilePreview();
        }

        // Update file preview display
        function updateFilePreview() {
            const container = document.getElementById('filePreviewContainer');
            const list = document.getElementById('filePreviewList');

            if (selectedFiles.length === 0) {
                container.classList.remove('has-files');
                list.innerHTML = '';
                return;
            }

            container.classList.add('has-files');
            list.innerHTML = '';

            selectedFiles.forEach((file, index) => {
                const item = createFilePreviewItem(file, index);
                list.appendChild(item);
            });
        }

        // Create file preview item
        function createFilePreviewItem(file, index) {
            const item = document.createElement('div');
            item.className = 'file-preview-item';
            item.setAttribute('data-index', index);

            const isImage = file.type.startsWith('image/');
            const isPdf = file.type === 'application/pdf';
            const isDoc = file.type.includes('word') || file.type.includes('document');

            let iconHtml = '';
            if (isImage) {
                // For images, show thumbnail
                const reader = new FileReader();
                reader.onload = function (e) {
                    const thumbnail = item.querySelector('.file-preview-thumbnail');
                    if (thumbnail) {
                        thumbnail.src = e.target.result;
                    }
                };
                reader.readAsDataURL(file);
                iconHtml = '<img class="file-preview-thumbnail" src="" alt="Preview" />';
            } else {
                // For other files, show icon
                let iconClass = 'other';
                let iconText = '📄';

                if (isPdf) {
                    iconClass = 'pdf';
                    iconText = '📄';
                } else if (isDoc) {
                    iconClass = 'document';
                    iconText = '📝';
                }

                iconHtml = `<div class="file-preview-icon ${iconClass}">${iconText}</div>`;
            }

            item.innerHTML = `
                ${iconHtml}
                <div class="file-preview-info">
                    <div class="file-preview-name">${file.name}</div>
                    <div class="file-preview-size">${formatFileSize(file.size)}</div>
                </div>
                <button type="button" class="file-remove-btn" onclick="removeFile(${index})" title="Remove file">
                    ×
                </button>
            `;

            return item;
        }

        // Remove file from selection
        function removeFile(index) {
            selectedFiles.splice(index, 1);
            updateFileInput();
            updateFilePreview();
        }

        // Update the file input with current selection
        function updateFileInput() {
            if (selectedFiles.length === 0) {
                fileInput.value = '';
                return;
            }

            // Create a new FileList from selected files
            const dataTransfer = new DataTransfer();
            selectedFiles.forEach(file => {
                dataTransfer.items.add(file);
            });
            fileInput.files = dataTransfer.files;
        }

        // Format file size for display
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        // Clear file selection (call this after successful post)
        function clearFileSelection() {
            selectedFiles = [];
            if (fileInput) {
                fileInput.value = '';
            }
            updateFilePreview();
        }

        // Toggle dropdown menus
        function toggleDropdown(button) {
            const dropdown = button.nextElementSibling;
            dropdown.style.display = dropdown.style.display === 'none' ? 'block' : 'none';

            // Close when clicking outside
            document.addEventListener('click', function closeDropdown(e) {
                if (!button.contains(e.target) && !dropdown.contains(e.target)) {
                    dropdown.style.display = 'none';
                    document.removeEventListener('click', closeDropdown);
                }
            });
        }

        // Toggle share menu
        function toggleShareMenu(button) {
            const shareMenu = button.nextElementSibling;
            shareMenu.style.display = shareMenu.style.display === 'none' ? 'block' : 'none';

            // Close when clicking outside
            document.addEventListener('click', function closeShareMenu(e) {
                if (!button.contains(e.target) && !shareMenu.contains(e.target)) {
                    shareMenu.style.display = 'none';
                    document.removeEventListener('click', closeShareMenu);
                }
            });
        }

        // Share functions
        function shareToClipboard(postId) {
            const url = window.location.origin + window.location.pathname + '?postId=' + postId;
            navigator.clipboard.writeText(url).then(() => {
                showNotification('Link copied to clipboard!', 'success');
            });
        }

        function shareViaEmail(postId) {
            const url = window.location.origin + window.location.pathname + '?postId=' + postId;
            const subject = 'Check out this post from our study group';
            const body = 'I thought you might find this interesting: ' + url;
            window.location.href = `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
        }

        // Comment interactions
        function toggleCommentLike(button, commentId) {
            button.classList.toggle('liked');
            const icon = button.querySelector('span');
            icon.textContent = button.classList.contains('liked') ? '👍' : '👍';
            showNotification('Comment liked!', 'success');
        }

        function replyToComment(commentId) {
            const commentInput = document.querySelector('.comment-input');
            commentInput.focus();
            commentInput.value = '@' + commentId + ' ';
        }

        // Show notifications
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.className = `alert alert-${type} alert-dismissible fade show`;
            notification.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 300px;';
            notification.innerHTML = `
                ${message}
                <button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
            `;
            document.body.appendChild(notification);

            setTimeout(() => {
                notification.remove();
            }, 5000);
        }

        // Auto-expand textareas
        document.addEventListener('input', function (e) {
            if (e.target.tagName === 'TEXTAREA') {
                e.target.style.height = 'auto';
                e.target.style.height = e.target.scrollHeight + 'px';
            }
        });

        // Loading states
        function setLoading(element, isLoading) {
            if (isLoading) {
                element.classList.add('loading');
                element.setAttribute('data-original-text', element.textContent);
                element.innerHTML = '<span class="spinner"></span> Loading...';
            } else {
                element.classList.remove('loading');
                element.textContent = element.getAttribute('data-original-text');
            }
        }

        // Clear files after successful post (called from code-behind)
        function clearFilesAfterPost() {
            clearFileSelection();
        }
    </script>
</asp:Content>