<%@ Page Title="Classroom Details"
    Language="C#"
    MasterPageFile="~/Site.master"
    AutoEventWireup="true"
    CodeBehind="ClassDetails.aspx.cs"
    Inherits="YourProjectNamespace.ClassDetails"
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Classroom Details
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>.classroom-page {
            padding: 30px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            position: relative;
        }

        .classroom-container {
            max-width: 800px;
            margin: 0 auto;
            position: relative;
        }

        .classroom-header {
            background: white;
            padding: 25px 30px;
            border-radius: 16px;
            margin-bottom: 30px;
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.06);
            border: 1px solid rgba(0, 0, 0, 0.04);
            animation: slideInFromTop 0.6s ease-out;
        }

        @keyframes slideInFromTop {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .classroom-title {
            font-size: 28px;
            font-weight: 700;
            color: #1a202c;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        /* Authentication Alert */
        .auth-alert {
            background: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 20px;
            display: none;
            align-items: center;
            gap: 12px;
            color: #dc2626;
            font-weight: 500;
        }

            .auth-alert.show {
                display: flex;
                animation: slideInFromTop 0.4s ease-out;
            }

            .auth-alert button {
                background: #dc2626;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 6px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                transition: background 0.3s ease;
            }

                .auth-alert button:hover {
                    background: #b91c1c;
                }

        .posts-container {
            animation: slideInFromBottom 0.6s ease-out 0.2s both;
        }

        @keyframes slideInFromBottom {
            from {
                opacity: 0;
                transform: translateY(30px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Enhanced Post Card Design with clear visual distinction */
        .post-card {
            background: linear-gradient(145deg, #ffffff 0%, #fafbfc 100%);
            border: 2px solid #e2e8f0;
            border-left: 6px solid #3b82f6; /* Accent border for posts */
            border-radius: 18px;
            margin-bottom: 40px; /* Increased spacing between posts */
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.07), 0 1px 3px rgba(0, 0, 0, 0.06);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            animation: cardEntrance 0.5s ease-out both;
            animation-delay: calc(var(--card-index, 0) * 0.1s);
            position: relative;
        }

        /* Post type specific accent colors */
        .post-card:has(.post-type.Assignment) {
            border-left-color: #dc2626;
        }

        .post-card:has(.post-type.Announcement) {
            border-left-color: #059669;
        }

        .post-card:has(.post-type.Material) {
            border-left-color: #2563eb;
        }

        .post-card:has(.post-type.Note) {
            border-left-color: #7c3aed;
        }

        .post-card:has(.post-type.Quiz) {
            border-left-color: #ca8a04;
        }

        @keyframes cardEntrance {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .post-card:hover {
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1), 0 4px 10px rgba(0, 0, 0, 0.06);
            transform: translateY(-3px);
            border-color: #cbd5e1;
        }

        /* Post Header with enhanced styling */
        .post-header {
            padding: 28px 28px 0 28px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
            background: linear-gradient(135deg, rgba(255,255,255,0.8) 0%, rgba(248,250,252,0.8) 100%);
            border-bottom: 1px solid rgba(226, 232, 240, 0.3);
        }

        .post-title {
            font-size: 22px;
            font-weight: 700;
            color: #1a202c;
            margin: 0;
            line-height: 1.4;
            flex: 1;
        }

        .post-type {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: 22px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            white-space: nowrap;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

            .post-type.Assignment {
                background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
                color: #dc2626;
                border: 1px solid #fecaca;
            }

            .post-type.Announcement {
                background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
                color: #059669;
                border: 1px solid #a7f3d0;
            }

            .post-type.Material {
                background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
                color: #2563eb;
                border: 1px solid #bfdbfe;
            }

            .post-type.Note {
                background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 100%);
                color: #7c3aed;
                border: 1px solid #c4b5fd;
            }

            .post-type.Quiz {
                background: linear-gradient(135deg, #fefce8 0%, #fef3c7 100%);
                color: #ca8a04;
                border: 1px solid #fde68a;
            }

        /* Post Meta with enhanced styling and Profile Image Support */
        .post-meta {
            padding: 12px 28px 20px 28px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            color: #64748b;
            background: rgba(248, 250, 252, 0.5);
        }

        /* Enhanced Post Author with Profile Image Support */
        .post-author {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .post-author-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            border: 2px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        }

        .post-author-avatar:hover {
            transform: scale(1.1);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.25);
        }

        .post-author-avatar-image {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
        }

        .post-author-avatar-initials {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            z-index: 1;
        }

        .post-author-avatar-initials.hide {
            display: none;
        }

        .post-author {
            color: #3b82f6;
            font-weight: 600;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .post-author:hover {
            color: #2563eb;
        }

        .meta-divider {
            width: 4px;
            height: 4px;
            background: #cbd5e1;
            border-radius: 50%;
        }

        /* Post Content */
        .post-content {
            padding: 0 28px 24px 28px;
            color: #374151;
            font-size: 15px;
            line-height: 1.7;
            white-space: pre-line;
        }

        /* Attachments Section */
        .attachments-section {
            padding: 24px 28px;
            border-top: 1px solid #f1f5f9;
            background: rgba(248, 250, 252, 0.3);
        }

        .attachments-title {
            font-size: 15px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .attachments-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 12px;
        }

        .attachment-card {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
        }

            .attachment-card:hover {
                border-color: #3b82f6;
                box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
                transform: translateY(-2px);
            }

        .attachment-icon {
            width: 48px;
            height: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            font-size: 20px;
            color: white;
        }

            .attachment-icon.pdf {
                background: #dc2626;
            }

            .attachment-icon.image {
                background: #059669;
            }

            .attachment-icon.doc {
                background: #2563eb;
            }

            .attachment-icon.default {
                background: #6b7280;
            }

        .attachment-name {
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            text-align: center;
            word-break: break-word;
        }

        .attachment-actions {
            display: flex;
            gap: 8px;
            margin-top: 8px;
        }

        .btn-preview, .btn-download {
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-preview {
            background: #3b82f6;
            color: white;
        }

            .btn-preview:hover {
                background: #2563eb;
            }

        .btn-download {
            background: #f1f5f9;
            color: #64748b;
        }

            .btn-download:hover {
                background: #e2e8f0;
                color: #374151;
            }

        /* Enhanced Comments Section - Visually Distinct from Posts */
        .comments-section {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 14px;
            margin-top: 24px;
            overflow: hidden;
            box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.05);
            animation: slideInFromBottom 0.5s ease-out both;
            animation-delay: 0.1s;
            position: relative;
        }

        /* Add subtle pattern overlay to distinguish comments */
        .comments-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image: 
                radial-gradient(circle at 1px 1px, rgba(59, 130, 246, 0.05) 1px, transparent 0);
            background-size: 20px 20px;
            pointer-events: none;
            z-index: 1;
        }

        .comments-header {
            padding: 18px 24px;
            border-bottom: 2px solid #e2e8f0;
            background: linear-gradient(135deg, #ffffff 0%, #f1f5f9 100%);
            display: flex;
            align-items: center;
            gap: 8px;
            position: relative;
            z-index: 2;
        }

        .comments-title {
            font-size: 16px;
            font-weight: 600;
            color: #475569;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .comments-title::before {
            content: '';
            width: 3px;
            height: 16px;
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            border-radius: 2px;
        }

        .comments-count {
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            color: #64748b;
            padding: 4px 10px;
            border-radius: 14px;
            font-size: 12px;
            font-weight: 600;
            border: 1px solid #cbd5e1;
        }

        .comments-list {
            max-height: 400px;
            overflow-y: auto;
            position: relative;
            z-index: 2;
            background: rgba(255, 255, 255, 0.7);
        }

        .comment-item {
            padding: 20px 24px;
            border-bottom: 1px solid rgba(226, 232, 240, 0.6);
            display: flex;
            gap: 14px;
            transition: all 0.3s ease;
            position: relative;
            background: rgba(255, 255, 255, 0.5);
        }

            .comment-item:last-child {
                border-bottom: none;
            }

            .comment-item:hover {
                background: rgba(255, 255, 255, 0.8);
                box-shadow: inset 0 0 0 1px rgba(59, 130, 246, 0.1);
            }

        /* Enhanced Comment Avatar with Profile Image Support */
        .comment-avatar {
            width: 40px;
            height: 40px;
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
            flex-shrink: 0;
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
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
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

        .comment-content {
            flex: 1;
        }

        .comment-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
            width: 100%;
        }

        .comment-author {
            font-weight: 600;
            color: #475569;
            font-size: 14px;
            margin-right: 8px;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .comment-author:hover {
            color: #3b82f6;
        }

        .comment-date {
            color: #64748b;
            font-size: 12px;
            margin-right: auto;
            font-style: italic;
        }

        /* Comment Actions */
        .comment-actions {
            display: flex;
            gap: 8px;
            opacity: 0.7;
            transition: opacity 0.3s ease;
        }

        .comment-item:hover .comment-actions {
            opacity: 1;
        }

        .comment-action-btn {
            background: rgba(255, 255, 255, 0.8);
            border: 1px solid #e2e8f0;
            color: #6c757d;
            font-size: 14px;
            cursor: pointer;
            padding: 6px 8px;
            border-radius: 6px;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .comment-action-btn:hover {
            background: white;
            color: #495057;
            text-decoration: none;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            transform: translateY(-1px);
        }

        .comment-action-btn.delete-btn:hover {
            background: #ffeaea;
            color: #dc3545;
            border-color: #f5c6cb;
        }

        .comment-text {
            color: #475569;
            line-height: 1.6;
            font-size: 15px;
        }

        /* Comment Edit Form */
        .comment-edit-form {
            margin-top: 12px;
            padding: 16px;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 12px;
            border: 2px solid #e9ecef;
            transition: all 0.3s ease;
            animation: slideInEdit 0.3s ease-out;
            display: none;
            backdrop-filter: blur(5px);
        }

        .comment-edit-form.show {
            display: block;
        }

        @keyframes slideInEdit {
            from {
                opacity: 0;
                transform: translateY(-10px);
                max-height: 0;
            }
            to {
                opacity: 1;
                transform: translateY(0);
                max-height: 300px;
            }
        }

        .comment-edit-form:focus-within {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: white;
        }

        .edit-textarea {
            width: 100%;
            min-height: 80px;
            padding: 12px 16px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            resize: vertical;
            transition: all 0.3s ease;
            background: white;
            margin-bottom: 12px;
        }

        .edit-textarea:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
        }

        .edit-textarea::placeholder {
            color: #9ca3af;
        }

        /* Edit Controls */
        .edit-controls {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 12px;
        }

        .btn-save, .btn-cancel {
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .btn-save {
            background: #28a745;
            color: white;
        }

        .btn-save:hover {
            background: #218838;
            transform: translateY(-1px);
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
        }

        .btn-cancel:hover {
            background: #5a6268;
            transform: translateY(-1px);
        }

        /* Loading state for save button */
        .btn-save.loading {
            opacity: 0.7;
            pointer-events: none;
        }

        .btn-save.loading::after {
            content: '';
            display: inline-block;
            width: 12px;
            height: 12px;
            border: 2px solid transparent;
            border-top: 2px solid white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 8px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .no-comments {
            padding: 40px 24px;
            text-align: center;
            color: #64748b;
            font-size: 14px;
            position: relative;
            z-index: 2;
            background: rgba(255, 255, 255, 0.7);
        }

        .no-comments-icon {
            font-size: 32px;
            margin-bottom: 12px;
            opacity: 0.6;
        }

        /* Enhanced Comment Form */
        .comment-form {
            padding: 20px 24px;
            border-top: 2px solid #e2e8f0;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            position: relative;
            z-index: 2;
        }

        .comment-form-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
        }

        /* Enhanced Form Avatar with Profile Image Support */
        .form-avatar {
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

        .form-avatar:hover {
            transform: scale(1.1);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.25);
        }

        .form-avatar-image {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
        }

        .form-avatar-initials {
            background: linear-gradient(135deg, #059669, #047857);
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            z-index: 1;
        }

        .form-avatar-initials.hide {
            display: none;
        }

        .form-user-name {
            font-weight: 600;
            color: #374151;
            font-size: 14px;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .form-user-name:hover {
            color: #3b82f6;
        }

        .comment-textarea {
            width: 100%;
            min-height: 80px;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            font-size: 14px;
            font-family: inherit;
            resize: vertical;
            transition: all 0.3s ease;
            background: white;
        }

            .comment-textarea:focus {
                outline: none;
                border-color: #3b82f6;
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            }

            .comment-textarea::placeholder {
                color: #9ca3af;
            }

        .comment-form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 16px;
        }

        .btn-cancel, .btn-submit {
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-cancel {
            background: #f1f5f9;
            color: #64748b;
        }

            .btn-cancel:hover {
                background: #e2e8f0;
                color: #374151;
            }

        .btn-submit {
            background: #3b82f6;
            color: white;
            display: flex;
            align-items: center;
            gap: 8px;
        }

            .btn-submit:hover {
                background: #2563eb;
            }

            .btn-submit:disabled {
                background: #9ca3af;
                cursor: not-allowed;
            }

            .btn-submit .loading {
                display: none;
                width: 16px;
                height: 16px;
                border: 2px solid transparent;
                border-top: 2px solid white;
                border-radius: 50%;
                animation: spin 1s linear infinite;
            }

        /* Preview Modal */
        .preview-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.9);
            z-index: 10000;
            display: none;
            align-items: center;
            justify-content: center;
            animation: modalFadeIn 0.3s ease-out;
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
            }

            to {
                opacity: 1;
            }
        }

        .preview-content {
            background: white;
            border-radius: 12px;
            padding: 0;
            max-width: 90vw;
            max-height: 90vh;
            overflow: hidden;
            position: relative;
            animation: modalSlideIn 0.3s ease-out;
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: scale(0.9) translateY(20px);
            }

            to {
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }

        .preview-header {
            padding: 16px 20px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .preview-title {
            font-weight: 600;
            color: #374151;
            margin: 0;
        }

        .btn-close {
            background: none;
            border: none;
            font-size: 24px;
            color: #9ca3af;
            cursor: pointer;
            padding: 4px;
            border-radius: 6px;
            transition: all 0.3s ease;
        }

            .btn-close:hover {
                background: #f1f5f9;
                color: #374151;
            }

        .preview-body {
            padding: 20px;
            max-height: 70vh;
            overflow: auto;
        }

        .preview-image {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
        }

        .preview-iframe {
            width: 100%;
            height: 60vh;
            border: none;
            border-radius: 8px;
        }

        /* No Posts State */
        .no-posts {
            text-align: center;
            padding: 60px 40px;
            background: white;
            border-radius: 16px;
            border: 2px dashed #e2e8f0;
            animation: fadeInUp 0.6s ease-out;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .no-posts-icon {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.6;
        }

        .no-posts h3 {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 8px;
            color: #374151;
        }

        .no-posts p {
            font-size: 14px;
            color: #64748b;
            margin: 0;
        }

        /* Success/Error messages for comment operations */
        .comment-message {
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 13px;
            margin: 8px 0;
            animation: fadeInMessage 0.3s ease-out;
        }

        .comment-message.success {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #b8daff;
        }

        .comment-message.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        @keyframes fadeInMessage {
            from {
                opacity: 0;
                transform: translateY(-5px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .classroom-page {
                padding: 20px 16px;
            }

            .classroom-header {
                padding: 20px;
            }

            .classroom-title {
                font-size: 24px;
            }

            .post-header {
                padding: 20px 20px 0 20px;
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }

            .post-meta {
                padding: 8px 20px 16px 20px;
                flex-wrap: wrap;
            }

            .post-content {
                padding: 0 20px 16px 20px;
            }

            .attachments-section {
                padding: 16px 20px;
            }

            .attachments-grid {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            }

            .comments-section {
                margin-top: 12px;
            }

            .comment-item {
                padding: 16px 20px;
            }

            .comment-form {
                padding: 16px 20px;
            }

            .preview-content {
                max-width: 95vw;
                max-height: 95vh;
            }

            .comment-actions {
                flex-direction: column;
                gap: 4px;
                align-items: flex-start;
            }

            .comment-action-btn {
                font-size: 12px;
                padding: 6px;
            }

            .edit-controls {
                flex-direction: column;
                gap: 8px;
            }

            .btn-save, .btn-cancel {
                width: 100%;
                justify-content: center;
            }

            .comment-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }

            .comment-actions {
                margin-top: 8px;
                flex-direction: row;
            }
        }

        /* Loading States */
        .loading-skeleton {
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
            border-radius: 4px;
        }

        @keyframes loading {
            0% {
                background-position: 200% 0;
            }

            100% {
                background-position: -200% 0;
            }
        }

        /* Accessibility */
        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }

        /* Focus states */
        .attachment-card:focus,
        .btn-preview:focus,
        .btn-download:focus,
        .btn-submit:focus,
        .btn-cancel:focus,
        .comment-textarea:focus,
        .comment-action-btn:focus,
        .btn-save:focus,
        .post-author:focus,
        .comment-author:focus,
        .form-user-name:focus,
        .post-author-avatar:focus,
        .comment-avatar:focus,
        .form-avatar:focus {
            outline: 2px solid #3b82f6;
            outline-offset: 2px;
        }

        /* Hide elements */
        .hidden {
            display: none;
        }</style>

    <div class="classroom-page">
        <div class="classroom-container">
            <!-- Authentication Alert -->
            <div id="authAlert" class="auth-alert">
                <i class="fas fa-exclamation-triangle"></i>
                <span id="authMessage">Session expired. Please log in again.</span>
                <button onclick="redirectToLogin()">Login</button>
            </div>

            <div class="classroom-header">
                <h2 class="classroom-title" runat="server" id="classTitle">
                    <span>📚</span>
                    <span>Classroom Posts</span>
                </h2>
            </div>

            <div class="posts-container">
                <asp:Panel ID="pnlNoPosts" runat="server" CssClass="no-posts">
                    <div class="no-posts-icon">📮</div>
                    <h3>No Posts Yet</h3>
                    <p>This classroom doesn't have any posts yet. Check back later for updates and assignments!</p>
                </asp:Panel>

                <asp:Repeater ID="rptPosts" runat="server">
                    <ItemTemplate>
                        <div class="post-card" style="--card-index: <%# Container.ItemIndex %>;" data-post-id="<%# Eval("Id") %>">
                            <!-- Post Header -->
                            <div class="post-header">
                                <h3 class="post-title"><%# Eval("Title") %></h3>
                                <span class="post-type <%# Eval("Type") %>"><%# Eval("Type") %></span>
                            </div>

                            <!-- Enhanced Post Meta with Profile Image Support -->
                            <div class="post-meta">
                                <div class="post-author" onclick="navigateToProfile('<%# Eval("CreatedByUserId") %>')">
                                    <div class="post-author-avatar">
                                        <!-- Profile Image (if available) -->
                                        <img class="post-author-avatar-image" 
                                             src='<%# Eval("CreatedByProfileImage") %>' 
                                             alt="Profile Picture" 
                                             style='<%# (bool)Eval("HasCreatorProfileImage") ? "display: block;" : "display: none;" %>'
                                             onerror="this.style.display='none'; this.nextElementSibling.classList.remove('hide');" />
                                        
                                        <!-- Profile Initials (fallback) -->
                                        <div class='<%# "post-author-avatar-initials" + ((bool)Eval("HasCreatorProfileImage") ? " hide" : "") %>'>
                                            <%# Eval("CreatedByInitials") %>
                                        </div>
                                    </div>
                                    <span class="post-author"><%# Eval("CreatedByName") %></span>
                                </div>
                                <div class="meta-divider"></div>
                                <span class="post-date"><%# Eval("CreatedAtFormatted") %></span>
                            </div>

                            <!-- Post Content -->
                            <div class="post-content"><%# Eval("Content") %></div>

                            <!-- Attachments Section -->
                            <asp:Panel runat="server" CssClass="attachments-section"
                                Visible='<%# ((System.Collections.IEnumerable)Eval("FileUrls")).Cast<object>().Any() %>'>
                                <div class="attachments-title">
                                    <span>📎</span>
                                    <span>Attachments</span>
                                </div>
                                <div class="attachments-grid">
                                    <asp:Repeater ID="rptFiles" runat="server" DataSource='<%# Eval("FileUrls") %>'>
                                        <ItemTemplate>
                                            <div class="attachment-card" onclick="previewFile('<%# Container.DataItem %>')">
                                                <div class="attachment-icon" data-file-type="">
                                                    <i class="fas fa-file"></i>
                                                </div>
                                                <div class="attachment-name"><%# GetFileName(Container.DataItem.ToString()) %></div>
                                                <div class="attachment-actions">
                                                    <button type="button" class="btn-preview" onclick="event.stopPropagation(); previewFile('<%# Container.DataItem %>')">
                                                        <i class="fas fa-eye"></i>Preview
                                                    </button>
                                                    <a href="<%# Container.DataItem %>" target="_blank" class="btn-download" onclick="event.stopPropagation()">
                                                        <i class="fas fa-download"></i>Download
                                                    </a>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </asp:Panel>

                            <!-- Enhanced Comments Section with Profile Images -->
                            <div class="comments-section">
                                <div class="comments-header">
                                    <h4 class="comments-title">💬 Comments</h4>
                                    <span class="comments-count"><%# Eval("CommentsCount") %></span>
                                </div>

                                <!-- Comments List -->
                                <div class="comments-list">
                                    <asp:Panel runat="server" CssClass="no-comments"
                                        Visible='<%# !((System.Collections.IEnumerable)Eval("Comments")).Cast<object>().Any() %>'>
                                        <div class="no-comments-icon">💭</div>
                                        <p>No comments yet. Be the first to comment!</p>
                                    </asp:Panel>

                                    <asp:Repeater ID="rptComments" runat="server" DataSource='<%# Eval("Comments") %>' OnItemCommand="rptComments_ItemCommand">
                                        <ItemTemplate>
                                            <div class="comment-item" data-comment-id="<%# Eval("Id") %>" data-post-id="<%# Eval("PostId") %>">
                                                <!-- Enhanced Comment Avatar with Profile Image Support -->
                                                <div class="comment-avatar" onclick="navigateToProfile('<%# Eval("AuthorUserId") %>')">
                                                    <!-- Profile Image (if available) -->
                                                    <img class="comment-avatar-image" 
                                                         src='<%# Eval("AuthorProfileImage") %>' 
                                                         alt="Profile Picture" 
                                                         style='<%# (bool)Eval("HasAuthorProfileImage") ? "display: block;" : "display: none;" %>'
                                                         onerror="this.style.display='none'; this.nextElementSibling.classList.remove('hide');" />
                                                    
                                                    <!-- Profile Initials (fallback) -->
                                                    <div class='<%# "comment-avatar-initials" + ((bool)Eval("HasAuthorProfileImage") ? " hide" : "") %>'>
                                                        <%# GetInitials(Eval("AuthorName").ToString()) %>
                                                    </div>
                                                </div>
                                                <div class="comment-content">
                                                    <div class="comment-header">
                                                        <span class="comment-author" onclick="navigateToProfile('<%# Eval("AuthorUserId") %>')"><%# Eval("AuthorName") %></span>
                                                        <span class="comment-date"><%# Eval("CreatedAtFormatted") %></span>
                                                        
                                                        <!-- Edit/Delete buttons for comment owner (client-side) -->
                                                        <div class="comment-actions" style='<%# (bool)Eval("IsOwner") ? "" : "display: none;" %>'>
                                                            <button type="button" class="comment-action-btn edit-btn"
                                                                onclick="toggleEditComment('<%# Eval("PostId") %>', '<%# Eval("Id") %>')"
                                                                title="Edit comment">
                                                                ✏️
                                                            </button>
                                                            <button type="button" class="comment-action-btn delete-btn"
                                                                onclick="deleteComment('<%# Eval("PostId") %>', '<%# Eval("Id") %>')"
                                                                title="Delete comment">
                                                                🗑️
                                                            </button>
                                                        </div>
                                                    </div>

                                                    <!-- Comment View Mode -->
                                                    <div class="comment-view">
                                                        <div class="comment-text"><%# Eval("Content") %></div>
                                                    </div>

                                                    <!-- Comment Edit Mode (initially hidden) -->
                                                    <div class="comment-edit-form">
                                                        <textarea class="edit-textarea" 
                                                            placeholder="Edit your comment..."><%# Eval("Content") %></textarea>
                                                        <div class="edit-controls">
                                                            <button type="button" class="btn-save" 
                                                                onclick="saveEditComment('<%# Eval("PostId") %>', '<%# Eval("Id") %>')">
                                                                💾 Save
                                                            </button>
                                                            <button type="button" class="btn-cancel" 
                                                                onclick="cancelEditComment('<%# Eval("PostId") %>', '<%# Eval("Id") %>')">
                                                                ❌ Cancel
                                                            </button>
                                                        </div>
                                                    </div>

                                                    <!-- Hidden server-side controls for fallback -->
                                                    <asp:Panel ID="pnlServerControls" runat="server" Style="display: none;">
                                                        <asp:TextBox ID="txtEditComment" runat="server" 
                                                            Text='<%# Eval("Content") %>' 
                                                            Style="display: none;"></asp:TextBox>
                                                        <asp:Button ID="btnSaveComment" runat="server" 
                                                            CommandName="SaveComment" 
                                                            CommandArgument='<%# Eval("PostId") + "|" + Eval("Id") %>' 
                                                            Style="display: none;" />
                                                        <asp:Button ID="btnDeleteComment" runat="server" 
                                                            CommandName="DeleteComment" 
                                                            CommandArgument='<%# Eval("PostId") + "|" + Eval("Id") %>' 
                                                            Style="display: none;" />
                                                    </asp:Panel>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>

                                <!-- Enhanced Comment Form with Profile Image Support -->
                                <div class="comment-form">
                                    <div class="comment-form-header">
                                        <div class="form-avatar" onclick="navigateToProfile('<%# GetCurrentUserId() %>')">
                                            <!-- Current User Profile Image (if available) -->
                                            <img class="form-avatar-image" 
                                                 src='<%# GetCurrentUserProfileImage() %>' 
                                                 alt="Your Profile Picture" 
                                                 style='<%# HasCurrentUserProfileImage() ? "display: block;" : "display: none;" %>'
                                                 onerror="this.style.display='none'; this.nextElementSibling.classList.remove('hide');" />
                                            
                                            <!-- Current User Initials (fallback) -->
                                            <div class='<%# "form-avatar-initials" + (HasCurrentUserProfileImage() ? " hide" : "") %>'>
                                                <%# GetUserInitials() %>
                                            </div>
                                        </div>
                                        <span class="form-user-name" onclick="navigateToProfile('<%# GetCurrentUserId() %>')"><%# GetCurrentUserName() %></span>
                                    </div>
                                    <textarea class="comment-textarea"
                                        placeholder="Write a comment..."
                                        data-post-id='<%# Eval("Id") %>'></textarea>
                                    <div class="comment-form-actions">
                                        <button type="button" class="btn-cancel" onclick="clearComment(this)">Cancel</button>
                                        <button type="button" class="btn-submit" onclick="submitComment(this)" data-post-id='<%# Eval("Id") %>'>
                                            <span class="btn-text">Post Comment</span>
                                            <div class="loading"></div>
                                        </button>
                                    </div>

                                    <!-- Hidden form for fallback -->
                                    <asp:Panel ID="pnlCommentForm" runat="server" Style="display: none;">
                                        <asp:TextBox ID="txtComment" runat="server" Style="display: none;"></asp:TextBox>
                                        <asp:Button ID="btnSubmitComment" runat="server"
                                            OnClick="SubmitComment_Click"
                                            CommandArgument='<%# Eval("Id") %>'
                                            Style="display: none;" />
                                    </asp:Panel>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- Preview Modal -->
    <div id="previewModal" class="preview-modal" onclick="closePreview(event)">
        <div class="preview-content" onclick="event.stopPropagation()">
            <div class="preview-header">
                <h3 id="previewTitle" class="preview-title">File Preview</h3>
                <button type="button" class="btn-close" onclick="closePreview()">&times;</button>
            </div>
            <div id="previewBody" class="preview-body">
                <!-- Preview content will be loaded here -->
            </div>
        </div>
    </div>

    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />

    <script>
        // Initialize page
        document.addEventListener('DOMContentLoaded', function () {
            console.log('Page loaded, initializing...');
            initializeAttachmentIcons();
            initializeCommentForms();

            // Test if basic functionality works
            console.log('Class ID from URL:', getClassIdFromUrl());
        });

        function redirectToLogin() {
            window.location.href = 'Login.aspx';
        }

        // Initialize attachment icons based on file types
        function initializeAttachmentIcons() {
            document.querySelectorAll('.attachment-card').forEach(card => {
                const fileName = card.querySelector('.attachment-name').textContent.toLowerCase();
                const icon = card.querySelector('.attachment-icon');
                const iconElement = icon.querySelector('i');

                if (fileName.match(/\.(jpg|jpeg|png|gif|webp|svg)$/)) {
                    icon.className = 'attachment-icon image';
                    iconElement.className = 'fas fa-image';
                } else if (fileName.match(/\.(pdf)$/)) {
                    icon.className = 'attachment-icon pdf';
                    iconElement.className = 'fas fa-file-pdf';
                } else if (fileName.match(/\.(doc|docx)$/)) {
                    icon.className = 'attachment-icon doc';
                    iconElement.className = 'fas fa-file-word';
                } else if (fileName.match(/\.(xls|xlsx)$/)) {
                    icon.className = 'attachment-icon doc';
                    iconElement.className = 'fas fa-file-excel';
                } else if (fileName.match(/\.(ppt|pptx)$/)) {
                    icon.className = 'attachment-icon doc';
                    iconElement.className = 'fas fa-file-powerpoint';
                } else if (fileName.match(/\.(mp4|avi|mov|wmv|webm)$/)) {
                    icon.className = 'attachment-icon default';
                    iconElement.className = 'fas fa-file-video';
                } else {
                    icon.className = 'attachment-icon default';
                    iconElement.className = 'fas fa-file';
                }
            });
        }

        // Initialize comment forms
        function initializeCommentForms() {
            document.querySelectorAll('.comment-textarea').forEach(textarea => {
                textarea.addEventListener('input', function () {
                    const submitBtn = this.closest('.comment-form').querySelector('.btn-submit');
                    submitBtn.disabled = this.value.trim() === '';
                });

                textarea.addEventListener('keydown', function (event) {
                    if (event.ctrlKey && event.key === 'Enter') {
                        const submitBtn = this.closest('.comment-form').querySelector('.btn-submit');
                        if (!submitBtn.disabled) {
                            submitComment(submitBtn);
                        }
                    }
                });
            });

            // Set initial state for submit buttons
            document.querySelectorAll('.btn-submit').forEach(btn => {
                const textarea = btn.closest('.comment-form').querySelector('.comment-textarea');
                btn.disabled = textarea.value.trim() === '';
            });
        }

        // Profile navigation function - same as StudyHubGroup
        function navigateToProfile(userId) {
            if (userId && userId !== '<%= currentUserId %>') {
                window.location.href = 'ProfileOthers.aspx?userId=' + userId;
            } else if (userId === '<%= currentUserId %>') {
                window.location.href = 'Profile.aspx';
            }
        }

        // NEW: Toggle edit mode for comments (client-side only)
        function toggleEditComment(postId, commentId) {
            const commentItem = document.querySelector(`[data-comment-id="${commentId}"][data-post-id="${postId}"]`);
            if (!commentItem) return;

            const viewMode = commentItem.querySelector('.comment-view');
            const editForm = commentItem.querySelector('.comment-edit-form');
            const editBtn = commentItem.querySelector('.edit-btn');
            const deleteBtn = commentItem.querySelector('.delete-btn');

            // Toggle visibility
            if (editForm.classList.contains('show')) {
                // Cancel edit
                cancelEditComment(postId, commentId);
            } else {
                // Enter edit mode
                viewMode.style.display = 'none';
                editForm.classList.add('show');
                editBtn.style.display = 'none';
                deleteBtn.style.display = 'none';

                // Focus on textarea
                const textarea = editForm.querySelector('.edit-textarea');
                textarea.focus();
                textarea.setSelectionRange(textarea.value.length, textarea.value.length);

                // Store scroll position to maintain it
                window.currentScrollPosition = window.pageYOffset;
            }
        }

        // NEW: Cancel edit mode
        function cancelEditComment(postId, commentId) {
            const commentItem = document.querySelector(`[data-comment-id="${commentId}"][data-post-id="${postId}"]`);
            if (!commentItem) return;

            const viewMode = commentItem.querySelector('.comment-view');
            const editForm = commentItem.querySelector('.comment-edit-form');
            const editBtn = commentItem.querySelector('.edit-btn');
            const deleteBtn = commentItem.querySelector('.delete-btn');
            const originalText = commentItem.querySelector('.comment-text').textContent;
            const textarea = editForm.querySelector('.edit-textarea');

            // Reset textarea to original content
            textarea.value = originalText;

            // Show view mode, hide edit form
            viewMode.style.display = 'block';
            editForm.classList.remove('show');
            editBtn.style.display = 'inline-flex';
            deleteBtn.style.display = 'inline-flex';

            // Restore scroll position
            if (window.currentScrollPosition !== undefined) {
                window.scrollTo(0, window.currentScrollPosition);
            }
        }

        // NEW: Save edited comment
        async function saveEditComment(postId, commentId) {
            const commentItem = document.querySelector(`[data-comment-id="${commentId}"][data-post-id="${postId}"]`);
            if (!commentItem) return;

            const editForm = commentItem.querySelector('.comment-edit-form');
            const textarea = editForm.querySelector('.edit-textarea');
            const saveBtn = editForm.querySelector('.btn-save');
            const newContent = textarea.value.trim();

            if (!newContent) {
                showToast('Comment content cannot be empty.', 'error');
                return;
            }

            // Show loading state
            saveBtn.classList.add('loading');
            saveBtn.disabled = true;
            const originalText = saveBtn.textContent;
            saveBtn.textContent = 'Saving...';

            try {
                const classId = getClassIdFromUrl();

                // Try AJAX first
                const response = await fetch('ClassDetails.aspx/UpdateComment', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=utf-8'
                    },
                    body: JSON.stringify({
                        classId: classId,
                        postId: postId,
                        commentId: commentId,
                        newContent: newContent
                    })
                });

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const result = JSON.parse(await response.text());

                if (result.d && result.d.success) {
                    // Update the comment text in view mode
                    const commentTextElement = commentItem.querySelector('.comment-text');
                    commentTextElement.textContent = newContent;

                    // Exit edit mode
                    cancelEditComment(postId, commentId);

                    showToast('Comment updated successfully!', 'success');
                } else {
                    throw new Error(result.d ? result.d.error : 'Failed to update comment');
                }
            } catch (error) {
                console.error('AJAX update failed, trying fallback:', error);

                // Fallback to server-side update
                try {
                    const hiddenTextbox = commentItem.querySelector('[id*="txtEditComment"]');
                    const hiddenSaveBtn = commentItem.querySelector('[id*="btnSaveComment"]');

                    if (hiddenTextbox && hiddenSaveBtn) {
                        hiddenTextbox.value = newContent;
                        showToast('Saving comment...', 'info');
                        hiddenSaveBtn.click(); // This will cause a postback
                    } else {
                        throw new Error('Fallback controls not found');
                    }
                } catch (fallbackError) {
                    console.error('Fallback also failed:', fallbackError);
                    showToast('Failed to save comment. Please try again.', 'error');
                }
            } finally {
                // Reset button state
                saveBtn.classList.remove('loading');
                saveBtn.disabled = false;
                saveBtn.textContent = originalText;
            }
        }

        // NEW: Delete comment
        async function deleteComment(postId, commentId) {
            if (!confirm('Are you sure you want to delete this comment?')) {
                return;
            }

            const commentItem = document.querySelector(`[data-comment-id="${commentId}"][data-post-id="${postId}"]`);
            if (!commentItem) return;

            // Store scroll position
            window.currentScrollPosition = window.pageYOffset;

            try {
                const classId = getClassIdFromUrl();

                // Try AJAX first
                const response = await fetch('ClassDetails.aspx/DeleteComment', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=utf-8'
                    },
                    body: JSON.stringify({
                        classId: classId,
                        postId: postId,
                        commentId: commentId
                    })
                });

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const result = JSON.parse(await response.text());

                if (result.d && result.d.success) {
                    // Remove comment from UI with animation
                    commentItem.style.animation = 'slideOutToRight 0.3s ease-out';
                    setTimeout(() => {
                        commentItem.remove();

                        // Update comment count
                        updateCommentCount(commentItem.closest('.post-card'), -1);

                        // Check if this was the last comment
                        const commentsList = commentItem.closest('.comments-list');
                        if (commentsList.querySelectorAll('.comment-item').length === 0) {
                            // Show "no comments" message
                            commentsList.innerHTML = `
                                <div class="no-comments">
                                    <div class="no-comments-icon">💭</div>
                                    <p>No comments yet. Be the first to comment!</p>
                                </div>
                            `;
                        }

                        // Restore scroll position
                        window.scrollTo(0, window.currentScrollPosition);
                    }, 300);

                    showToast('Comment deleted successfully!', 'success');
                } else {
                    throw new Error(result.d ? result.d.error : 'Failed to delete comment');
                }
            } catch (error) {
                console.error('AJAX delete failed, trying fallback:', error);

                // Fallback to server-side delete
                try {
                    const hiddenDeleteBtn = commentItem.querySelector('[id*="btnDeleteComment"]');

                    if (hiddenDeleteBtn) {
                        showToast('Deleting comment...', 'info');
                        hiddenDeleteBtn.click(); // This will cause a postback
                    } else {
                        throw new Error('Fallback controls not found');
                    }
                } catch (fallbackError) {
                    console.error('Fallback also failed:', fallbackError);
                    showToast('Failed to delete comment. Please try again.', 'error');
                }
            }
        }

        // Submit comment via AJAX with fallback
        async function submitComment(btn) {
            const commentForm = btn.closest('.comment-form');
            const textarea = commentForm.querySelector('.comment-textarea');
            const postId = btn.getAttribute('data-post-id');
            const commentText = textarea.value.trim();

            console.log('Submit comment called:', { postId, commentText }); // Debug log

            if (!commentText || btn.disabled) {
                console.log('Comment text empty or button disabled');
                return;
            }

            // Show loading state
            btn.disabled = true;
            const btnText = btn.querySelector('.btn-text');
            const loading = btn.querySelector('.loading');

            if (btnText) btnText.style.display = 'none';
            if (loading) loading.style.display = 'block';
            btn.style.cursor = 'not-allowed';

            try {
                const classId = getClassIdFromUrl();
                console.log('Making AJAX call with:', { classId, postId, commentText });

                // First try AJAX approach
                const response = await fetch('ClassDetails.aspx/AddComment', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=utf-8'
                    },
                    body: JSON.stringify({
                        classId: classId,
                        postId: postId,
                        commentText: commentText
                    })
                });

                console.log('Response status:', response.status);

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const responseText = await response.text();
                console.log('Response text:', responseText);

                const result = JSON.parse(responseText);
                console.log('Parsed result:', result);

                if (result.d && result.d.success) {
                    // Clear the textarea
                    textarea.value = '';

                    // Add the new comment to the UI immediately
                    addCommentToUI(btn.closest('.post-card'), result.d.comment);

                    // Update comment count
                    updateCommentCount(btn.closest('.post-card'), 1);

                    // Show success feedback
                    showToast('Comment posted successfully!', 'success');
                } else {
                    throw new Error(result.d ? result.d.error : 'Failed to post comment');
                }
            } catch (error) {
                console.error('AJAX failed, trying fallback:', error);

                // Fallback to traditional postback
                try {
                    await submitCommentFallback(btn, commentText);
                } catch (fallbackError) {
                    console.error('Fallback also failed:', fallbackError);
                    showToast('Failed to post comment. Please try again.', 'error');
                }
            } finally {
                // Reset button state
                if (btnText) btnText.style.display = 'inline';
                if (loading) loading.style.display = 'none';
                btn.disabled = textarea.value.trim() === ''; // Enable only if there's text
                btn.style.cursor = 'pointer';
            }
        }

        // Fallback method using traditional postback
        async function submitCommentFallback(btn, commentText) {
            console.log('Using fallback postback method');

            const postCard = btn.closest('.post-card');
            const hiddenPanel = postCard.querySelector('[id*="pnlCommentForm"]');
            const hiddenTextBox = postCard.querySelector('[id*="txtComment"]');
            const hiddenButton = postCard.querySelector('[id*="btnSubmitComment"]');

            if (hiddenTextBox && hiddenButton) {
                // Set the comment text in hidden textbox
                hiddenTextBox.value = commentText;

                // Show a message that we're submitting
                showToast('Submitting comment...', 'info');

                // Trigger the postback
                hiddenButton.click();
            } else {
                throw new Error('Fallback controls not found');
            }
        }

        // Add comment to UI without page refresh
        function addCommentToUI(postCard, commentData) {
            const commentsList = postCard.querySelector('.comments-list');
            const noComments = commentsList.querySelector('.no-comments');

            // Remove "no comments" message if it exists
            if (noComments) {
                noComments.remove();
            }

            // Create new comment HTML with profile image support
            const commentHtml = `
                <div class="comment-item" style="animation: slideInFromBottom 0.3s ease-out;" data-comment-id="new-${Date.now()}" data-post-id="${commentData.postId || ''}">
                    <div class="comment-avatar" onclick="navigateToProfile('${commentData.authorUserId}')">
                        <!-- Profile Image (if available) -->
                        <img class="comment-avatar-image" 
                             src="${commentData.authorProfileImage || ''}" 
                             alt="Profile Picture" 
                             style="${commentData.hasProfileImage ? 'display: block;' : 'display: none;'}"
                             onerror="this.style.display='none'; this.nextElementSibling.classList.remove('hide');" />
                        
                        <!-- Profile Initials (fallback) -->
                        <div class="comment-avatar-initials${commentData.hasProfileImage ? ' hide' : ''}">
                            ${commentData.authorInitials}
                        </div>
                    </div>
                    <div class="comment-content">
                        <div class="comment-header">
                            <span class="comment-author" onclick="navigateToProfile('${commentData.authorUserId}')">${commentData.authorName}</span>
                            <span class="comment-date">Just now</span>
                        </div>
                        <div class="comment-view">
                            <div class="comment-text">${commentData.content}</div>
                        </div>
                    </div>
                </div>
            `;

            // Add the new comment to the end of the list
            commentsList.insertAdjacentHTML('beforeend', commentHtml);

            // Scroll the new comment into view smoothly
            const newComment = commentsList.lastElementChild;
            newComment.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }

        // Update comment count in the header
        function updateCommentCount(postCard, increment) {
            const commentCount = postCard.querySelector('.comments-count');
            const currentCount = parseInt(commentCount.textContent) || 0;
            const newCount = currentCount + increment;
            commentCount.textContent = newCount;
        }

        // Get class ID from URL
        function getClassIdFromUrl() {
            const urlParams = new URLSearchParams(window.location.search);
            return urlParams.get('classId');
        }

        // Show toast notification
        function showToast(message, type = 'info') {
            // Remove existing toasts
            document.querySelectorAll('.toast').forEach(toast => toast.remove());

            const toast = document.createElement('div');
            toast.className = `toast toast-${type}`;
            toast.innerHTML = `
                <div class="toast-content">
                    <span class="toast-icon">${type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️'}</span>
                    <span class="toast-message">${message}</span>
                </div>
            `;

            // Add toast styles
            toast.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6'};
                color: white;
                padding: 12px 20px;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                z-index: 10001;
                animation: slideInFromRight 0.3s ease-out;
                font-size: 14px;
                font-weight: 500;
                max-width: 350px;
            `;

            document.body.appendChild(toast);

            // Auto remove after 3 seconds
            setTimeout(() => {
                toast.style.animation = 'slideOutToRight 0.3s ease-out';
                setTimeout(() => toast.remove(), 300);
            }, 3000);
        }

        // Add CSS animations for toast
        const toastStyles = document.createElement('style');
        toastStyles.textContent = `
            @keyframes slideInFromRight {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            
            @keyframes slideOutToRight {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
            
            .toast-content {
                display: flex;
                align-items: center;
                gap: 8px;
            }
        `;
        document.head.appendChild(toastStyles);

        // Clear comment function
        function clearComment(btn) {
            const textarea = btn.closest('.comment-form').querySelector('.comment-textarea');
            textarea.value = '';
            const submitBtn = btn.closest('.comment-form').querySelector('.btn-submit');
            submitBtn.disabled = true;
            textarea.focus();
        }

        function previewFile(fileUrl) {
            const fileName = fileUrl.split('/').pop().toLowerCase();
            const modal = document.getElementById('previewModal');
            const title = document.getElementById('previewTitle');
            const body = document.getElementById('previewBody');

            title.textContent = fileName;
            body.innerHTML = '';

            if (fileName.match(/\.(jpg|jpeg|png|gif|webp|svg)$/)) {
                // Image preview
                const img = document.createElement('img');
                img.src = fileUrl;
                img.className = 'preview-image';
                img.alt = fileName;
                body.appendChild(img);
            } else if (fileName.match(/\.(pdf)$/)) {
                // PDF preview
                const iframe = document.createElement('iframe');
                iframe.src = fileUrl + '#view=FitH';
                iframe.className = 'preview-iframe';
                body.appendChild(iframe);
            } else if (fileName.match(/\.(mp4|webm)$/)) {
                // Video preview
                const video = document.createElement('video');
                video.src = fileUrl;
                video.controls = true;
                video.className = 'preview-image';
                video.style.maxHeight = '60vh';
                body.appendChild(video);
            } else {
                // Generic preview with download option
                const message = document.createElement('div');
                message.innerHTML = `
                <div style="text-align: center; padding: 40px;">
                    <i class="fas fa-file fa-3x" style="color: #9ca3af; margin-bottom: 20px;"></i>
                    <p style="margin-bottom: 20px; color: #64748b;">Preview not available for this file type.</p>
                    <a href="${fileUrl}" target="_blank" class="btn-download" style="display: inline-flex; align-items: center; gap: 8px; padding: 12px 24px; text-decoration: none;">
                        <i class="fas fa-download"></i>
                        Download File
                    </a>
                </div>
            `;
                body.appendChild(message);
            }

            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }

        function closePreview(event) {
            if (!event || event.target === document.getElementById('previewModal')) {
                document.getElementById('previewModal').style.display = 'none';
                document.body.style.overflow = 'auto';
            }
        }

        // Keyboard navigation for accessibility
        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                closePreview();

                // Also cancel any active comment edits
                document.querySelectorAll('.comment-edit-form.show').forEach(editForm => {
                    const commentItem = editForm.closest('.comment-item');
                    const postId = commentItem.dataset.postId;
                    const commentId = commentItem.dataset.commentId;
                    if (postId && commentId) {
                        cancelEditComment(postId, commentId);
                    }
                });
            }
        });

        // Show loading state when submitting comment
        function showCommentLoading(btn) {
            const loadingSpinner = btn.querySelector('.loading');
            if (loadingSpinner) {
                loadingSpinner.style.display = 'block';
            }
            btn.disabled = true;
            btn.innerHTML = '<div class="loading"></div>Posting...';
        }
    </script>
</asp:Content>