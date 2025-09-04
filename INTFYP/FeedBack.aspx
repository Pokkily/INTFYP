<%@ Page Async="true" Title="Feedback" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Feedback.aspx.cs" Inherits="YourProjectNamespace.Feedback" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Feedback
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Design System Variables */
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --glass-border: rgba(255, 255, 255, 0.2);
            --text-primary: #2c3e50;
            --text-secondary: #7f8c8d;
            --spacing-xs: 8px;
            --spacing-sm: 15px;
            --spacing-md: 20px;
            --spacing-lg: 25px;
            --spacing-xl: 30px;
            --border-radius-lg: 20px;
            --border-radius-md: 12px;
            --border-radius-sm: 8px;
        }

        /* Page Background with Library Style */
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(120, 119, 198, 0.2) 0%, transparent 50%);
            animation: backgroundFloat 20s ease-in-out infinite;
            z-index: -1;
        }

        @keyframes backgroundFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-20px, -20px) rotate(1deg); }
            50% { transform: translate(20px, -10px) rotate(-1deg); }
            75% { transform: translate(-10px, 10px) rotate(0.5deg); }
        }

        /* Glass Morphism Effects */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: var(--border-radius-lg);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            overflow: hidden;
            position: relative;
            cursor: pointer;
        }

        .glass-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .glass-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
        }

        /* Page Header */
        .page-header {
            background: var(--primary-gradient);
            color: rgba(255, 255, 255, 0.9);
            border-radius: var(--border-radius-lg);
            padding: var(--spacing-lg);
            margin-bottom: var(--spacing-lg);
            animation: fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
        }

        .page-header h1 {
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            position: relative;
            display: inline-block;
        }

        .page-header h1::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 4px;
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            border-radius: 2px;
            animation: expandWidth 1.5s ease-out 0.5s both;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 60px; }
        }

        /* Animations */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes cardEntrance {
            from { opacity: 0; transform: translateY(50px) rotate(2deg); }
            to { opacity: 1; transform: translateY(0) rotate(0deg); }
        }

        .btn-primary {
            background: var(--primary-gradient);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            border: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .btn-primary::before {
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

        .btn-primary:hover::before {
            width: 300px;
            height: 300px;
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(103, 126, 234, 0.4);
        }

        /* Teal Submit Button */
        .btn-submit-teal {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%) !important;
            color: white !important;
            padding: 10px 20px !important;
            border-radius: 25px !important;
            font-weight: 600 !important;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3) !important;
            border: none !important;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            position: relative !important;
            overflow: hidden !important;
        }

        .btn-submit-teal::before {
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

        .btn-submit-teal:hover::before {
            width: 300px;
            height: 300px;
        }

        .btn-submit-teal:hover {
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%) !important;
            transform: translateY(-2px) !important;
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4) !important;
            color: white !important;
        }

        /* Submit Button Container */
        .submit-button-container {
            text-align: center;
            margin-bottom: var(--spacing-lg);
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* Enhanced Feedback Card Styles */
        .feedback-card {
            height: 100%;
            display: flex;
            flex-direction: column;
            animation: cardEntrance 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards;
            opacity: 0;
        }

        .feedback-image-container {
            height: 180px;
            overflow: hidden;
            position: relative;
        }

        .feedback-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }

        .feedback-image:hover {
            transform: scale(1.05);
        }

        .feedback-content {
            padding: var(--spacing-md);
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .feedback-header {
            margin-bottom: 0.5rem;
        }

        .feedback-username {
            font-weight: 600;
            font-size: 1rem;
            margin-bottom: 0.25rem;
            display: -webkit-box;
            -webkit-line-clamp: 1;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .feedback-date {
            color: var(--text-secondary);
            font-size: 0.8rem;
        }

        .feedback-description {
            margin-bottom: var(--spacing-sm);
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            line-height: 1.5;
            flex-grow: 1;
        }

        .feedback-actions {
            display: flex;
            gap: 0.5rem;
            margin-top: auto;
        }

        /* Library-Style Like Button - Card Version */
        .btn-like {
            padding: 0.35rem 0.75rem !important;
            border-radius: 18px !important;
            border: none !important;
            cursor: pointer !important;
            font-size: 0.85rem !important;
            font-weight: 600 !important;
            text-decoration: none !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 4px !important;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            position: relative !important;
            overflow: hidden !important;
            flex: 1 !important;
            justify-content: center !important;
            min-width: 75px !important;
            white-space: nowrap !important;
            font-family: inherit !important;
            line-height: 1 !important;
            text-align: center !important;
            vertical-align: middle !important;
            touch-action: manipulation !important;
            user-select: none !important;
            background: linear-gradient(135deg, #e8e8e8 0%, #d0d0d0 100%) !important;
            color: #2c3e50 !important;
            box-shadow: 0 4px 15px rgba(200, 200, 200, 0.3) !important;
        }

        .btn-like::before {
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

        .btn-like:hover::before {
            width: 200px;
            height: 200px;
        }

        .btn-like:hover {
            transform: translateY(-2px) !important;
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.4) !important;
            color: white !important;
        }

        .btn-like.active {
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.5) !important;
            color: #ffffff !important;
        }

        .btn-like.active:hover {
            background: linear-gradient(135deg, #8a9c78 0%, #7a8c68 100%) !important;
            box-shadow: 0 10px 30px rgba(156, 175, 136, 0.6) !important;
        }

        .btn-like.clicked {
            animation: buttonPulse 0.6s ease-out !important;
        }

        @keyframes buttonPulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }

        /* Detail Modal Like Button - Same size as post comment button */
        .btn-like-detail {
            padding: 10px 20px !important;
            border-radius: 25px !important;
            border: none !important;
            cursor: pointer !important;
            font-size: 1rem !important;
            font-weight: 600 !important;
            text-decoration: none !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 6px !important;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            position: relative !important;
            overflow: hidden !important;
            justify-content: center !important;
            min-width: 120px !important;
            white-space: nowrap !important;
            font-family: inherit !important;
            line-height: 1 !important;
            text-align: center !important;
            vertical-align: middle !important;
            touch-action: manipulation !important;
            user-select: none !important;
            background: linear-gradient(135deg, #e8e8e8 0%, #d0d0d0 100%) !important;
            color: #2c3e50 !important;
            box-shadow: 0 4px 15px rgba(200, 200, 200, 0.3) !important;
        }

        .btn-like-detail::before {
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

        .btn-like-detail:hover::before {
            width: 200px;
            height: 200px;
        }

        .btn-like-detail:hover {
            transform: translateY(-2px) !important;
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.4) !important;
            color: white !important;
        }

        .btn-like-detail.active {
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.5) !important;
            color: #ffffff !important;
        }

        .btn-like-detail.active:hover {
            background: linear-gradient(135deg, #8a9c78 0%, #7a8c68 100%) !important;
            box-shadow: 0 10px 30px rgba(156, 175, 136, 0.6) !important;
        }

        .btn-like-detail.clicked {
            animation: buttonPulse 0.6s ease-out !important;
        }

        .btn-sm {
            padding: 0.35rem 0.75rem;
            font-size: 0.85rem;
            white-space: nowrap;
        }

        /* Enhanced Card Detail Modal Styles */
        .card-detail-modal .modal-dialog {
            max-width: 95vw;
            width: 95vw;
            margin: 1rem auto;
        }

        .card-detail-modal .modal-content {
            border-radius: var(--border-radius-lg);
            border: none;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
            overflow: hidden;
            background: rgba(0, 0, 0, 0.9);
        }

        /* Dark backdrop for better focus */
        .card-detail-modal .modal-backdrop {
            background-color: rgba(0, 0, 0, 0.9) !important;
        }

        .card-detail-modal .modal-header {
            background: var(--primary-gradient);
            color: white;
            border-bottom: none;
            padding: 1.5rem 2rem;
            position: relative;
        }

        .card-detail-modal .modal-header::before {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        }

        .card-detail-modal .modal-title {
            font-size: 1.25rem;
            font-weight: 700;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        }

        .card-detail-modal .btn-close {
            filter: brightness(0) invert(1);
            opacity: 0.8;
            transition: opacity 0.3s ease;
        }

        .card-detail-modal .btn-close:hover {
            opacity: 1;
        }

        .card-detail-content {
            display: flex;
            min-height: 75vh;
        }

        .card-detail-image {
            flex: 0 0 33.333%;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
            cursor: pointer;
            padding: 2rem;
        }

        .card-detail-image img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
            border-radius: var(--border-radius-sm);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }

        .card-detail-image img:hover {
            transform: scale(1.05);
        }

        .card-detail-info {
            flex: 0 0 33.333%;
            padding: 2.5rem;
            display: flex;
            flex-direction: column;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-right: 1px solid #e9ecef;
        }

        .card-detail-comments {
            flex: 1;
            padding: 2.5rem;
            display: flex;
            flex-direction: column;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
        }

        /* Comment input section styles */
        .comment-input {
            margin-bottom: 1.5rem;
            background: rgba(255, 255, 255, 0.8);
            padding: 1rem;
            border-radius: var(--border-radius-md);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }

        .comment-input textarea {
            resize: none;
            border: 2px solid #e9ecef;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
            border-radius: var(--border-radius-md);
            background: rgba(255, 255, 255, 0.9);
        }

        .comment-input textarea:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
            background: white;
        }

        .detail-header {
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 1.5rem;
            margin-bottom: 2rem;
            position: relative;
        }

        .detail-header::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 80px;
            height: 2px;
            background: var(--primary-gradient);
            border-radius: 1px;
        }

        .detail-header h4 {
            margin: 0;
            color: var(--text-primary);
            font-weight: 700;
            font-size: 1.4rem;
            margin-bottom: 0.5rem;
        }

        .detail-date {
            color: var(--text-secondary);
            font-size: 0.95rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .detail-date::before {
            content: '🕒';
            font-size: 0.9rem;
        }

        .detail-description {
            font-size: 1.1rem;
            line-height: 1.7;
            margin-bottom: 2.5rem;
            color: var(--text-primary);
            background: rgba(248, 249, 250, 0.8);
            padding: 1.5rem;
            border-radius: var(--border-radius-md);
            border-left: 4px solid #667eea;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }

        .detail-actions {
            display: flex !important;
            align-items: center !important;
            gap: 1rem !important;
            margin-bottom: 1rem !important;
        }

        .like-section {
            display: flex;
            align-items: center;
            gap: 1rem;
            position: relative;
        }

        .comments-header {
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: var(--text-primary);
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .comments-header::before {
            content: '💬';
            font-size: 1rem;
        }

        .comments-list {
            flex: 1;
            max-height: 350px;
            overflow-y: auto;
            padding-right: 0.5rem;
        }

        .comment {
            transition: all 0.3s ease;
            margin-bottom: 1rem;
            padding: 1.25rem;
            border-radius: var(--border-radius-md);
            background: rgba(248, 249, 250, 0.9);
            border-left: 4px solid #667eea;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            position: relative;
        }

        .comment:hover {
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            transform: translateX(8px);
            background: rgba(255, 255, 255, 0.95);
        }

        .comment::before {
            content: '';
            position: absolute;
            left: -4px;
            top: 0;
            bottom: 0;
            width: 4px;
            background: var(--primary-gradient);
            transition: width 0.3s ease;
        }

        .comment:hover::before {
            width: 6px;
        }

        .comments-list::-webkit-scrollbar {
            width: 8px;
        }

        .comments-list::-webkit-scrollbar-track {
            background: #f8f9fa;
            border-radius: 10px;
        }

        .comments-list::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 10px;
        }

        .comments-list::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(135deg, #764ba2, #667eea);
        }

        /* Image Zoom Modal */
        .image-zoom-modal .modal-dialog {
            max-width: 90vw;
            width: 90vw;
            height: 90vh;
            margin: 5vh auto;
        }

        .image-zoom-modal .modal-content {
            height: 100%;
            border: none;
            border-radius: var(--border-radius-lg);
            background: rgba(0, 0, 0, 0.9);
            overflow: hidden;
        }

        .image-zoom-modal .modal-body {
            padding: 0;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .image-zoom-modal img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
            border-radius: var(--border-radius-sm);
        }

        .image-zoom-modal .btn-close {
            position: absolute;
            top: 1rem;
            right: 1rem;
            z-index: 1000;
            filter: brightness(0) invert(1);
            opacity: 0.8;
            transition: opacity 0.3s ease;
        }

        .image-zoom-modal .btn-close:hover {
            opacity: 1;
        }

        /* Validation Styles */
        .form-control.is-invalid {
            border-color: #dc3545 !important;
            box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25) !important;
        }
        
        .text-danger.small {
            font-size: 0.875em;
            margin-top: 0.25rem;
            display: block;
        }
        
        .validation-summary-custom {
            margin-bottom: 1rem;
        }
        
        .required-asterisk {
            color: #dc3545;
            font-weight: bold;
        }

        /* Fix for modal backdrop issues */
        .modal-backdrop {
            z-index: 1040 !important;
        }

        .modal {
            z-index: 1050 !important;
        }

        body.modal-open {
            overflow: hidden !important;
            padding-right: 0 !important;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .card-detail-modal .modal-dialog {
                max-width: 95vw;
                width: 95vw;
                margin: 0.5rem auto;
            }
            
            .card-detail-content {
                flex-direction: column;
                min-height: auto;
            }
            
            .card-detail-image {
                flex: none;
                height: 300px;
            }
            
            .card-detail-info, .card-detail-comments {
                flex: none;
                padding: 1.5rem;
                border-right: none;
            }
            
            .card-detail-info {
                border-bottom: 1px solid #e9ecef;
            }
            
            .feedback-image-container {
                height: 150px;
            }
            
            .feedback-description {
                -webkit-line-clamp: 2;
            }
            
            .row-cols-md-3 {
                grid-template-columns: 1fr !important;
            }

            .detail-actions {
                flex-direction: column !important;
                align-items: flex-start !important;
                gap: 1rem !important;
            }
        }
    </style>

    <!-- Hidden field to store the post ID of the clicked like button -->
    <asp:HiddenField ID="hdnScrollToPost" runat="server" />

    <!-- Header with Gradient Background -->
    <section class="page-header text-center">
        <div class="container">
            <h1 class="display-5 fw-bold">Student Feedback</h1>
            <p class="lead">Submit your feedback with description, image, or video</p>
        </div>
    </section>

    <div class="container mb-5">
        <!-- Submit Button - Full Width Centered -->
        <div class="submit-button-container">
            <button type="button" class="btn btn-submit-teal px-5 py-2" data-bs-toggle="modal" data-bs-target="#feedbackModal" style="font-size: 1.1rem;">
                Submit Feedback
            </button>
        </div>

        <!-- Feedback Cards - Now Full Width -->
        <div class="row">
            <div class="col-12">
                <asp:Repeater ID="rptFeedback" runat="server" OnItemCommand="rptFeedback_ItemCommand" OnItemDataBound="rptFeedback_ItemDataBound">
                    <HeaderTemplate>
                        <div class="row row-cols-1 row-cols-md-3 g-4">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="col">
                            <div class="glass-card feedback-card h-100" 
                                 id="feedback-card-<%# Eval("PostId") %>"
                                 style='animation-delay: calc(<%# Container.ItemIndex %> * 0.1s)'
                                 data-post-id='<%# Eval("PostId") %>'
                                 onclick="openCardDetail('<%# Eval("PostId") %>')">
                                <!-- Image Section -->
                                <div class="feedback-image-container">
                                    <img src='<%# Eval("MediaUrl") %>' alt="Feedback media" class="feedback-image" />
                                </div>
                                
                                <!-- Content Section -->
                                <div class="feedback-content">
                                    <div class="feedback-header">
                                        <div class="feedback-username"><%# Eval("Username") %></div>
                                        <div class="feedback-date"><%# FormatFullDateTime((DateTime)Eval("CreatedAt")) %></div>
                                    </div>
                                    
                                    <p class="feedback-description"><%# Eval("Description") %></p>
                                    
                                    <div class="feedback-actions" onclick="event.stopPropagation();">
                                        <!-- Like Button with Library Style and Scroll Position Memory -->
                                        <asp:Button ID="btnLike" runat="server"
                                            Text='<%# "❤️ " + Eval("Likes") %>'
                                            CommandName="Like"
                                            CommandArgument='<%# Eval("PostId") %>'
                                            CssClass='<%# "btn-like" + (Convert.ToBoolean(Eval("IsLiked")) ? " active" : "") %>'
                                            OnClientClick='<%# "return storeScrollPosition(\"" + Eval("PostId") + "\");" %>' />

                                        <!-- Comment Button -->
                                        <button type="button"
                                            class="btn btn-sm btn-outline-secondary"
                                            onclick="openCardDetail('<%# Eval("PostId") %>')">
                                            💬 <%# ((System.Collections.ICollection)Eval("Comments")).Count %>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Enhanced Card Detail Modal -->
                            <div class="modal fade card-detail-modal" id='<%# "cardDetailModal" + Eval("PostId") %>' tabindex="-1" aria-hidden="true" data-bs-backdrop="true" data-bs-keyboard="true">
                                <div class="modal-dialog modal-dialog-centered">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title fw-bold">
                                                <i class="fas fa-expand-alt me-2"></i>Feedback Details
                                            </h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body p-0">
                                            <div class="card-detail-content">
                                                <!-- Image Section - Left Column (Now clickable) -->
                                                <div class="card-detail-image" onclick="openImageZoom('<%# Eval("MediaUrl") %>')">
                                                    <img src='<%# Eval("MediaUrl") %>' alt="Feedback media" />
                                                </div>
                                                
                                                <!-- Info Section - Middle Column -->
                                                <div class="card-detail-info">
                                                    <!-- Header -->
                                                    <div class="detail-header">
                                                        <h4><%# Eval("Username") %></h4>
                                                        <div class="detail-date"><%# FormatFullDateTime((DateTime)Eval("CreatedAt")) %></div>
                                                    </div>
                                                    
                                                    <!-- Description -->
                                                    <div class="detail-description">
                                                        <%# Eval("Description") %>
                                                    </div>
                                                    
                                                    <!-- Actions Section - Simplified without box -->
                                                    <div class="detail-actions">
                                                        <asp:Button ID="btnLikeDetail" runat="server"
                                                            Text='<%# "❤️ " + Eval("Likes") %>'
                                                            CommandName="Like"
                                                            CommandArgument='<%# Eval("PostId") %>'
                                                            CssClass='<%# "btn-like-detail" + (Convert.ToBoolean(Eval("IsLiked")) ? " active" : "") %>'
                                                            OnClientClick='<%# "return storeScrollPosition(\"" + Eval("PostId") + "\");" %>' />
                                                    </div>
                                                    
                                                    <!-- Comment Input Section - In Middle Column -->
                                                    <div class="comment-input">
                                                        <label class="form-label fw-bold mb-2">Add Comment</label>
                                                        <asp:TextBox ID="txtCommentInputDetail" runat="server" 
                                                            TextMode="MultiLine" 
                                                            Rows="3" 
                                                            CssClass="form-control mb-2" 
                                                            placeholder="Write your comment..." />
                                                        <div class="d-flex justify-content-between align-items-center">
                                                            <asp:Label ID="lblCommentErrorDetail" runat="server" CssClass="text-danger small" Visible="false" />
                                                            <asp:Button ID="btnSubmitCommentDetail" runat="server"
                                                                Text="Post Comment"
                                                                CommandName="SubmitComment"
                                                                CommandArgument='<%# Eval("PostId") %>'
                                                                CssClass="btn btn-primary" />
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Comments List Section - Right Column -->
                                                <div class="card-detail-comments">
                                                    <h6 class="comments-header">
                                                        Comments (<%# ((System.Collections.ICollection)Eval("Comments")).Count %>)
                                                    </h6>
                                                    
                                                    <!-- Comments List Only -->
                                                    <div class="comments-list">
                                                        <asp:Repeater ID="rptCommentsDetail" runat="server">
                                                            <ItemTemplate>
                                                                <div class="comment">
                                                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                                                        <div class="d-flex align-items-center">
                                                                            <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center me-2" 
                                                                                 style="width: 32px; height: 32px; font-size: 14px;">
                                                                                <%# Eval("username").ToString().Substring(0, 1).ToUpper() %>
                                                                            </div>
                                                                            <small class="fw-bold"><%# Eval("username") %></small>
                                                                        </div>
                                                                        <small class="text-muted"><%# FormatFullDateTime((DateTime)Eval("createdAt")) %></small>
                                                                    </div>
                                                                    <p class="mb-0 ps-5"><%# Eval("text") %></p>
                                                                </div>
                                                            </ItemTemplate>
                                                        </asp:Repeater>

                                                        <!-- No Comments Message -->
                                                        <div id="noCommentsDetailDiv" runat="server" style="display:none;" class="text-center text-muted py-4">
                                                            <i class="fas fa-comment-slash fa-2x mb-3 opacity-50"></i>
                                                            <p class="mb-0">No comments yet. Be the first to comment!</p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- Image Zoom Modal -->
    <div class="modal fade image-zoom-modal" id="imageZoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                <div class="modal-body">
                    <img id="zoomedImage" src="" alt="Zoomed image" />
                </div>
            </div>
        </div>
    </div>

    <!-- Updated Feedback Modal with Required Field Validation -->
    <div class="modal fade" id="feedbackModal" tabindex="-1" aria-labelledby="feedbackModalLabel" aria-hidden="true" data-bs-backdrop="true" data-bs-keyboard="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="feedbackModalLabel">
                        <i class="fas fa-plus-circle me-2"></i>Submit Feedback
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <!-- Validation Summary -->
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" 
                        CssClass="alert alert-danger" 
                        HeaderText="Please correct the following errors:"
                        ShowSummary="true"
                        DisplayMode="BulletList" 
                        ValidationGroup="FeedbackValidation" />
                    
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="text-danger" />

                    <!-- Username Field -->
                    <div class="mb-3">
                        <label class="form-label fw-bold">Username <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtFeedbackUsername" runat="server" CssClass="form-control" ReadOnly="true" />
                        <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                            ControlToValidate="txtFeedbackUsername"
                            ErrorMessage="Username is required"
                            Text="Username is required"
                            CssClass="text-danger small mt-1"
                            Display="Dynamic"
                            ValidationGroup="FeedbackValidation" />
                    </div>

                    <!-- Description Field -->
                    <div class="mb-3">
                        <label for="txtDescription" class="form-label fw-bold">Description <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtDescription" runat="server" 
                            CssClass="form-control" 
                            TextMode="MultiLine" 
                            Rows="4" 
                            Placeholder="Enter your feedback here"
                            MaxLength="1000" />
                        <asp:RequiredFieldValidator ID="rfvDescription" runat="server"
                            ControlToValidate="txtDescription"
                            ErrorMessage="Description is required"
                            Text="Please enter a description"
                            CssClass="text-danger small mt-1"
                            Display="Dynamic"
                            ValidationGroup="FeedbackValidation" />
                        <div class="form-text">Maximum 1000 characters</div>
                    </div>

                    <!-- File Upload Field -->
                    <div class="mb-3">
                        <label for="fileUpload" class="form-label fw-bold">Upload Image/Video <span class="text-danger">*</span></label>
                        <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" />
                        <asp:RequiredFieldValidator ID="rfvFileUpload" runat="server"
                            ControlToValidate="fileUpload"
                            ErrorMessage="Please select a file to upload"
                            Text="Please select a file to upload"
                            CssClass="text-danger small mt-1"
                            Display="Dynamic"
                            ValidationGroup="FeedbackValidation" />
                        <div class="form-text">Supported formats: JPG, PNG, GIF, MP4, AVI (Max: 10MB)</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnSubmit" runat="server" 
                        CssClass="btn btn-submit-teal" 
                        Text="Submit Feedback" 
                        OnClick="btnSubmit_Click"
                        ValidationGroup="FeedbackValidation"
                        OnClientClick="return validateFeedbackForm();" />
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Include Required Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>

    <script type="text/javascript">
        // Client-side validation function
        function validateFeedbackForm() {
            var isValid = true;
            var errorMessages = [];

            // Clear previous error styling
            clearValidationErrors();

            // Validate Username
            var username = document.getElementById('<%= txtFeedbackUsername.ClientID %>').value.trim();
            if (username === '') {
                isValid = false;
                errorMessages.push('Username is required');
                addFieldError('<%= txtFeedbackUsername.ClientID %>');
            }

            // Validate Description
            var description = document.getElementById('<%= txtDescription.ClientID %>').value.trim();
            if (description === '') {
                isValid = false;
                errorMessages.push('Description is required');
                addFieldError('<%= txtDescription.ClientID %>');
            } else if (description.length > 1000) {
                isValid = false;
                errorMessages.push('Description cannot exceed 1000 characters');
                addFieldError('<%= txtDescription.ClientID %>');
            }

            // Validate File Upload
            var fileUpload = document.getElementById('<%= fileUpload.ClientID %>');
            if (fileUpload.files.length === 0) {
                isValid = false;
                errorMessages.push('Please select a file to upload');
                addFieldError('<%= fileUpload.ClientID %>');
            } else {
                // Validate file size and type
                var file = fileUpload.files[0];
                var maxSize = 10 * 1024 * 1024; // 10MB
                var allowedTypes = ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.avi'];
                
                if (file.size > maxSize) {
                    isValid = false;
                    errorMessages.push('File size must be less than 10MB');
                    addFieldError('<%= fileUpload.ClientID %>');
                }
                
                var fileName = file.name.toLowerCase();
                var isValidType = allowedTypes.some(type => fileName.endsWith(type));
                if (!isValidType) {
                    isValid = false;
                    errorMessages.push('Invalid file type. Please upload JPG, PNG, GIF, MP4, or AVI files only');
                    addFieldError('<%= fileUpload.ClientID %>');
                }
            }

            // Show error summary if validation failed
            if (!isValid) {
                showValidationSummary(errorMessages);
                
                // Focus on first invalid field
                var firstErrorField = document.querySelector('.form-control.is-invalid');
                if (firstErrorField) {
                    firstErrorField.focus();
                }
            }

            return isValid;
        }

        // Helper function to add error styling to fields
        function addFieldError(fieldId) {
            var field = document.getElementById(fieldId);
            if (field) {
                field.classList.add('is-invalid');
                field.style.borderColor = '#dc3545';
            }
        }

        // Helper function to clear validation errors
        function clearValidationErrors() {
            // Remove error styling from all form controls
            document.querySelectorAll('.form-control').forEach(function(field) {
                field.classList.remove('is-invalid');
                field.style.borderColor = '';
            });
            
            // Hide validation summary
            var validationSummary = document.querySelector('.validation-summary-custom');
            if (validationSummary) {
                validationSummary.remove();
            }
        }

        // Helper function to show validation summary
        function showValidationSummary(errorMessages) {
            // Remove existing summary
            var existingSummary = document.querySelector('.validation-summary-custom');
            if (existingSummary) {
                existingSummary.remove();
            }

            // Create new summary
            var summary = document.createElement('div');
            summary.className = 'alert alert-danger validation-summary-custom';
            summary.innerHTML = '<strong>Please correct the following errors:</strong><ul>' + 
                errorMessages.map(msg => '<li>' + msg + '</li>').join('') + '</ul>';

            // Insert at the beginning of modal body
            var modalBody = document.querySelector('#feedbackModal .modal-body');
            modalBody.insertBefore(summary, modalBody.firstChild);

            // Scroll to top of modal
            modalBody.scrollTop = 0;
        }

        // Function to store which feedback post was liked before postback
        function storeScrollPosition(postId) {
            console.log('Storing scroll position for post:', postId);
            
            // Store the post ID in the hidden field
            document.getElementById('<%= hdnScrollToPost.ClientID %>').value = postId;
            
            // Allow the postback to continue
            return true;
        }

        // Function to scroll to the stored feedback card after page reload
        function scrollToStoredPost() {
            var hiddenField = document.getElementById('<%= hdnScrollToPost.ClientID %>');
            if (hiddenField && hiddenField.value) {
                var postId = hiddenField.value;
                var feedbackCard = document.getElementById('feedback-card-' + postId);

                if (feedbackCard) {
                    console.log('Scrolling to feedback post:', postId);

                    // Smooth scroll to the feedback card
                    feedbackCard.scrollIntoView({
                        behavior: 'smooth',
                        block: 'center',
                        inline: 'nearest'
                    });

                    // Add a temporary highlight effect
                    feedbackCard.style.boxShadow = '0 0 25px rgba(103, 126, 234, 0.6)';
                    feedbackCard.style.transform = 'translateY(-5px) scale(1.02)';

                    setTimeout(function () {
                        feedbackCard.style.boxShadow = '';
                        feedbackCard.style.transform = '';
                    }, 2000);

                    // Clear the hidden field
                    hiddenField.value = '';
                }
            }
        }

        // Simplified modal tracking
        let modalInstances = new Map();

        $(document).ready(function () {
            console.log('Enhanced Feedback page loaded with validation and scroll position memory');

            // Small delay to ensure all elements are rendered, then scroll to stored post
            setTimeout(scrollToStoredPost, 100);

            // Real-time validation feedback
            $('#<%= txtDescription.ClientID %>').on('input', function() {
                var length = $(this).val().length;
                var remaining = 1000 - length;
                var formText = $(this).siblings('.form-text');
                
                if (remaining < 0) {
                    $(this).addClass('is-invalid');
                    formText.text('Maximum 1000 characters exceeded by ' + Math.abs(remaining) + ' characters').addClass('text-danger');
                } else {
                    $(this).removeClass('is-invalid');
                    formText.text('Maximum 1000 characters (' + remaining + ' remaining)').removeClass('text-danger');
                }
            });

            // Clear validation on field focus
            $('.form-control').on('focus', function() {
                $(this).removeClass('is-invalid').css('border-color', '');
            });

            // Reset form when modal is hidden
            $('#feedbackModal').on('hidden.bs.modal', function() {
                clearValidationErrors();
                // Clear form fields (optional)
                $('#<%= txtDescription.ClientID %>').val('');
                $('#<%= fileUpload.ClientID %>').val('');
            });

            // Add hover effects to all glass cards
            const cards = document.querySelectorAll('.glass-card');
            cards.forEach(card => {
                card.addEventListener('mouseenter', () => {
                    if (!card.classList.contains('hover-disabled')) {
                        card.style.transform = 'translateY(-8px)';
                        card.style.boxShadow = '0 15px 35px rgba(0, 0, 0, 0.15)';
                    }
                });
                card.addEventListener('mouseleave', () => {
                    if (!card.classList.contains('hover-disabled')) {
                        card.style.transform = '';
                        card.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.1)';
                    }
                });
            });

            // Setup minimal event listeners
            setupMinimalEventListeners();
        });

        // Alternative - also try when window loads (backup)
        window.addEventListener('load', function () {
            setTimeout(scrollToStoredPost, 200);
        });

        // COMPLETELY REWRITTEN: Simple image zoom function
        function openImageZoom(imageSrc) {
            // Stop event propagation
            if (event) {
                event.stopPropagation();
                event.preventDefault();
            }

            console.log('Opening image zoom for:', imageSrc);

            const zoomedImage = document.getElementById('zoomedImage');
            zoomedImage.src = imageSrc;

            const modalElement = document.getElementById('imageZoomModal');

            // Get or create modal instance
            let imageZoomModal = bootstrap.Modal.getInstance(modalElement);
            if (!imageZoomModal) {
                imageZoomModal = new bootstrap.Modal(modalElement, {
                    backdrop: true,
                    keyboard: true,
                    focus: true
                });
            }

            imageZoomModal.show();
        }

        // MINIMAL event listener setup - let Bootstrap handle its own lifecycle
        function setupMinimalEventListeners() {
            // Only track modal instances for reference, don't interfere with Bootstrap lifecycle
            $(document).on('show.bs.modal', '.modal', function (e) {
                console.log('Modal showing:', this.id);
                const modalId = this.id;
                const modalInstance = bootstrap.Modal.getInstance(this);
                if (modalInstance) {
                    modalInstances.set(modalId, modalInstance);
                }
            });

            $(document).on('shown.bs.modal', '.modal', function (e) {
                console.log('Modal shown:', this.id);

                // Auto-focus on comment input if available (but not for image zoom)
                if (this.id !== 'imageZoomModal') {
                    $(this).find('textarea[id*="txtCommentInputDetail"]').focus();
                }
            });

            $(document).on('hide.bs.modal', '.modal', function (e) {
                console.log('Modal hiding:', this.id);
                const modalId = this.id;

                // Clear comment inputs and errors (but not for image zoom)
                if (modalId !== 'imageZoomModal') {
                    $(this).find('textarea[id*="txtCommentInputDetail"]').val('');
                    $(this).find('[id*="lblCommentErrorDetail"]').hide();
                }
            });

            $(document).on('hidden.bs.modal', '.modal', function (e) {
                console.log('Modal hidden:', this.id);
                const modalId = this.id;

                // Remove from our tracking
                if (modalInstances.has(modalId)) {
                    modalInstances.delete(modalId);
                }

                // NO AUTOMATIC CLEANUP - let Bootstrap handle its own lifecycle
            });

            // Handle ESC key naturally - let Bootstrap handle it
            $(document).on('keydown', function (e) {
                if (e.key === 'Escape') {
                    // Let Bootstrap handle ESC naturally
                    console.log('ESC pressed - letting Bootstrap handle modal closure');
                }
            });
        }

        // SIMPLIFIED: Only close card detail modals, never interfere with image zoom
        function openCardDetail(postId) {
            const modalId = 'cardDetailModal' + postId;
            console.log('Opening card detail modal:', modalId);

            try {
                // Close other CARD DETAIL modals only - never touch image zoom
                $('.card-detail-modal.show').each(function () {
                    const existingModal = bootstrap.Modal.getInstance(this);
                    if (existingModal && this.id !== modalId) {
                        existingModal.hide();
                    }
                });

                // Open the requested modal
                const modalElement = document.getElementById(modalId);
                if (modalElement) {
                    let modal = bootstrap.Modal.getInstance(modalElement);
                    if (!modal) {
                        modal = new bootstrap.Modal(modalElement, {
                            backdrop: true,
                            keyboard: true,
                            focus: true
                        });
                    }
                    modal.show();
                } else {
                    console.error('Modal element not found:', modalId);
                }

            } catch (error) {
                console.error('Error opening card detail modal:', error);
            }
        }

        // Enhanced click effect for like buttons
        function addClickEffect(button) {
            // Add clicked class for animation
            button.classList.add('clicked');

            // Create a temporary ripple effect
            const ripple = document.createElement('span');
            ripple.className = 'ripple-effect';
            ripple.style.cssText = `
                position: absolute;
                top: 50%;
                left: 50%;
                width: 20px;
                height: 20px;
                background: rgba(255, 255, 255, 0.6);
                border-radius: 50%;
                transform: translate(-50%, -50%) scale(0);
                animation: ripple 0.6s ease-out;
                pointer-events: none;
                z-index: 10;
            `;

            button.appendChild(ripple);

            // Remove effects after animation
            setTimeout(function () {
                button.classList.remove('clicked');
                if (ripple.parentNode) {
                    ripple.parentNode.removeChild(ripple);
                }
            }, 600);
        }

        // Add ripple effect keyframes dynamically
        const style = document.createElement('style');
        style.textContent = `
            @keyframes ripple {
                to {
                    transform: translate(-50%, -50%) scale(4);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);

        // Simplified page load function
        function pageLoad() {
            console.log('PageLoad fired - re-initializing scroll memory and event listeners');

            // Re-check for stored scroll position after postback
            setTimeout(scrollToStoredPost, 100);

            // Re-setup minimal event listeners
            setupMinimalEventListeners();

            // Re-initialize hover effects
            const cards = document.querySelectorAll('.glass-card');
            cards.forEach(card => {
                card.addEventListener('mouseenter', () => {
                    if (!card.classList.contains('hover-disabled')) {
                        card.style.transform = 'translateY(-8px)';
                        card.style.boxShadow = '0 15px 35px rgba(0, 0, 0, 0.15)';
                    }
                });
                card.addEventListener('mouseleave', () => {
                    if (!card.classList.contains('hover-disabled')) {
                        card.style.transform = '';
                        card.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.1)';
                    }
                });
            });
        }

        // Prevent modal from closing when clicking on action buttons
        $(document).on('click', '.feedback-actions', function (e) {
            e.stopPropagation();
        });

        // Handle card click vs button click
        $(document).on('click', '.feedback-card', function (e) {
            if (!$(e.target).closest('.feedback-actions, button, input, textarea').length) {
                const postId = $(this).data('post-id');
                if (postId) {
                    openCardDetail(postId);
                }
            }
        });

        // Only emergency cleanup for genuinely orphaned backdrops
        setInterval(function () {
            const visibleModals = $('.modal.show').length;
            const backdrops = $('.modal-backdrop').length;

            // Only cleanup if there are backdrops but no visible modals
            if (backdrops > 0 && visibleModals === 0) {
                console.log('Emergency cleanup: found orphaned backdrops with no visible modals');
                $('.modal-backdrop').remove();
                $('body').removeClass('modal-open').css({
                    'overflow': '',
                    'padding-right': ''
                });
            }
        }, 10000); // Check every 10 seconds instead of 5
    </script>
</asp:Content>