<%@ Page Async="true" Title="Feedback" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Feedback.aspx.cs" Inherits="YourProjectNamespace.Feedback" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Feedback
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Feedback Page with Library Design Formula */
        
        .feedback-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        .feedback-page::before {
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

        .feedback-container {
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            animation: slideInFromTop 1s ease-out;
        }

        @keyframes slideInFromTop {
            from { 
                opacity: 0; 
                transform: translateY(-50px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .page-title {
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 15px;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            position: relative;
            display: inline-block;
        }

        .page-title::after {
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

        .page-subtitle {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.8);
            margin: 0;
        }

        /* Student Info Sidebar Card */
        .student-info-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 25px;
            margin-bottom: 20px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            animation: slideInFromLeft 0.8s ease-out 0.2s both;
        }

        @keyframes slideInFromLeft {
            from { 
                opacity: 0; 
                transform: translateX(-50px); 
            }
            to { 
                opacity: 1; 
                transform: translateX(0); 
            }
        }

        .student-info-card::before {
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

        .student-info-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .info-title {
            font-size: 20px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .info-title::before {
            content: '👤';
            font-size: 24px;
        }

        .info-item {
            margin-bottom: 12px;
            padding: 8px 0;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        .info-item:last-child {
            border-bottom: none;
        }

        .info-label {
            font-weight: 600;
            color: #2c3e50;
            margin-right: 8px;
        }

        .info-value {
            color: #7f8c8d;
        }

        /* Submit Button */
        .submit-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 20px;
            border-radius: 25px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            width: 100%;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .submit-btn::before {
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

        .submit-btn:hover::before {
            width: 300px;
            height: 300px;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        /* Feedback Cards Grid */
        .feedback-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            animation: slideInFromBottom 1s ease-out 0.4s both;
        }

        @keyframes slideInFromBottom {
            from { 
                opacity: 0; 
                transform: translateY(50px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .feedback-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            animation: cardEntrance 0.8s ease-out both;
            animation-delay: calc(var(--card-index, 0) * 0.1s);
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        @keyframes cardEntrance {
            from { 
                opacity: 0; 
                transform: translateX(-30px) rotate(-1deg); 
            }
            to { 
                opacity: 1; 
                transform: translateX(0) rotate(0deg); 
            }
        }

        .feedback-card::before {
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

        .feedback-card:hover {
            transform: translateY(-8px) translateX(3px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
        }

        .feedback-image-container {
            height: 180px;
            overflow: hidden;
            position: relative;
            border-radius: 20px 20px 0 0;
            cursor: pointer;
        }

        .feedback-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .feedback-card:hover .feedback-image {
            transform: scale(1.05);
        }

        .feedback-content {
            padding: 20px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .feedback-header {
            margin-bottom: 15px;
        }

        .feedback-username {
            font-weight: 700;
            font-size: 16px;
            color: #2c3e50;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 8px;
            line-height: 1.2;
        }

        .feedback-username::before {
            content: '👤';
            font-size: 14px;
            flex-shrink: 0;
        }

        .feedback-date {
            color: #7f8c8d;
            font-size: 12px;
            font-weight: 500;
        }

        .feedback-description {
            margin-bottom: 15px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            line-height: 1.5;
            flex-grow: 1;
            color: #2c3e50;
        }

        .feedback-actions {
            display: flex;
            gap: 8px;
            margin-top: auto;
        }

        .feedback-action-btn {
            padding: 8px 15px;
            border-radius: 20px;
            border: none;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            flex: 1;
            justify-content: center;
            min-width: 80px;
        }

        .feedback-action-btn::before {
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

        .feedback-action-btn:hover::before {
            width: 200px;
            height: 200px;
        }

        .feedback-action-btn:hover {
            transform: translateY(-2px);
        }

        .btn-outline-danger {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
            border: none;
        }

        .btn-outline-danger:hover {
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.4);
            background: linear-gradient(135deg, #ee5a52 0%, #ff6b6b 100%);
            color: white;
        }

        .btn-outline-secondary {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
            border: none;
        }

        .btn-outline-secondary:hover {
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
            color: white;
        }

        /* Modal Enhancements */
        .modal-content {
            border-radius: 20px;
            border: none;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(10px);
        }

        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 20px 20px 0 0;
            border-bottom: none;
            padding: 20px 25px;
        }

        .modal-body {
            padding: 25px;
        }

        .modal-footer {
            border-top: none;
            padding: 20px 25px;
            border-radius: 0 0 20px 20px;
        }

        .form-control {
            border-radius: 15px;
            border: 2px solid rgba(103, 126, 234, 0.1);
            padding: 12px 15px;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
        }

        .btn-close {
            filter: invert(1);
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            border: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(103, 126, 234, 0.4);
            color: white;
        }

        .btn-secondary {
            background: rgba(108, 117, 125, 0.9);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
            border: none;
            transition: all 0.3s ease;
        }

        .btn-secondary:hover {
            background: rgba(108, 117, 125, 1);
            transform: translateY(-1px);
            color: white;
        }

        /* Comment Section */
        .comment {
            background: rgba(248, 249, 250, 0.8);
            border-radius: 15px;
            padding: 15px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
        }

        .comment:hover {
            background: rgba(248, 249, 250, 1);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        .comments-list {
            max-height: 400px;
            overflow-y: auto;
            padding-right: 10px;
        }

        .comments-list::-webkit-scrollbar {
            width: 6px;
        }

        .comments-list::-webkit-scrollbar-track {
            background: rgba(248, 249, 250, 0.5);
            border-radius: 10px;
        }

        .comments-list::-webkit-scrollbar-thumb {
            background: rgba(103, 126, 234, 0.3);
            border-radius: 10px;
        }

        .comment-input textarea {
            resize: none;
            border: 2px solid rgba(103, 126, 234, 0.1);
            transition: border-color 0.3s ease;
        }

        .comment-input textarea:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }

        /* No Comments Message Enhancement */
        .no-comments-message {
            text-align: center;
            color: #6c757d;
            padding: 40px 20px;
        }

        .no-comments-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.7;
            animation: iconBounce 2s ease-in-out infinite;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .feedback-page {
                padding: 20px 15px;
            }

            .feedback-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }

            .feedback-image-container {
                height: 150px;
            }

            .feedback-actions {
                flex-direction: column;
                gap: 8px;
            }

            .feedback-action-btn {
                width: 100%;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 28px;
            }

            .student-info-card {
                padding: 20px;
                margin-bottom: 15px;
                border-radius: 15px;
            }

            .feedback-card {
                border-radius: 15px;
            }

            .feedback-image-container {
                height: 120px;
            }
        }

        /* Loading states */
        .feedback-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }
    </style>

    <div class="feedback-page">
        <div class="feedback-container">
            <div class="page-header">
                <h2 class="page-title">Student Feedback</h2>
                <p class="page-subtitle">Submit your feedback with description, image, or video</p>
            </div>

            <div class="row">
                <!-- Student Info Sidebar -->
                <div class="col-md-4 mb-4">
                    <div class="student-info-card">
                        <h5 class="info-title">Student Information</h5>
                        
                        <div class="info-item">
                            <span class="info-label">Name:</span>
                            <span class="info-value"><asp:Label ID="lblName" runat="server" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Username:</span>
                            <span class="info-value"><asp:Label ID="lblUsername" runat="server" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Email:</span>
                            <span class="info-value"><asp:Label ID="lblEmail" runat="server" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Phone:</span>
                            <span class="info-value"><asp:Label ID="lblPhone" runat="server" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Gender:</span>
                            <span class="info-value"><asp:Label ID="lblGender" runat="server" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Birthdate:</span>
                            <span class="info-value"><asp:Label ID="lblBirthdate" runat="server" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Position:</span>
                            <span class="info-value"><asp:Label ID="lblPosition" runat="server" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Address:</span>
                            <span class="info-value"><asp:Label ID="lblAddress" runat="server" /></span>
                        </div>

                        <div class="mt-4">
                            <button type="button" class="submit-btn" data-bs-toggle="modal" data-bs-target="#feedbackModal">
                                📝 Submit Feedback
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Feedback Cards -->
                <div class="col-md-8">
                    <asp:Repeater ID="rptFeedback" runat="server" OnItemCommand="rptFeedback_ItemCommand" OnItemDataBound="rptFeedback_ItemDataBound">
                        <HeaderTemplate>
                            <div class="feedback-grid">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div class="feedback-card" style="--card-index: <%# Container.ItemIndex %>;">
                                <!-- Image Section -->
                                <div class="feedback-image-container"
                                     data-bs-toggle="modal"
                                     data-bs-target='<%# "#imgModal" + Eval("PostId") %>'>
                                    <img src='<%# Eval("MediaUrl") %>' alt="Feedback media" class="feedback-image" />
                                </div>
                                
                                <!-- Content Section -->
                                <div class="feedback-content">
                                    <div class="feedback-header">
                                        <div class="feedback-username"><%# Eval("Username") %></div>
                                        <div class="feedback-date"><%# Eval("CreatedAt", "{0:dd MMM yyyy hh:mm tt}") %></div>
                                    </div>
                                    
                                    <p class="feedback-description"><%# Eval("Description") %></p>
                                    
                                    <div class="feedback-actions">
                                        <!-- Like Button -->
                                        <asp:Button ID="btnLike" runat="server"
                                            Text='<%# "👍 " + Eval("Likes") %>'
                                            CommandName="Like"
                                            CommandArgument='<%# Eval("PostId") %>'
                                            CssClass="feedback-action-btn btn-outline-danger" />

                                        <!-- Comment Button -->
                                        <button type="button"
                                            class="feedback-action-btn btn-outline-secondary"
                                            data-bs-toggle="modal"
                                            data-bs-target='<%# "#commentModal" + Eval("PostId") %>'
                                            onclick="loadCommentsInModal('<%# Eval("PostId") %>')">
                                            💬 <%# ((System.Collections.ICollection)Eval("Comments")).Count %>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Comment Modal for each post -->
                            <div class="modal fade" id='<%# "commentModal" + Eval("PostId") %>' tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-dialog-centered">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title fw-bold">
                                                💬 Comments - <%# Eval("Username") %>
                                            </h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <!-- Original Post Info -->
                                            <div class="border-bottom pb-3 mb-4">
                                                <div class="d-flex align-items-center mb-2">
                                                    <h6 class="fw-bold mb-0 me-3"><%# Eval("Username") %></h6>
                                                    <small class="text-muted"><%# Eval("CreatedAt", "{0:dd MMM yyyy hh:mm tt}") %></small>
                                                </div>
                                                <p class="mb-0"><%# Eval("Description") %></p>
                                            </div>

                                            <!-- Comment Input Section -->
                                            <div class="comment-input mb-4">
                                                <label class="form-label fw-bold">Add a Comment</label>
                                                <asp:TextBox ID="txtCommentInput" runat="server" 
                                                    TextMode="MultiLine" 
                                                    Rows="3" 
                                                    CssClass="form-control mb-2" 
                                                    placeholder="Write your comment..." />
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <asp:Label ID="lblCommentError" runat="server" CssClass="text-danger small" Visible="false" />
                                                    <asp:Button ID="btnSubmitComment" runat="server"
                                                        Text="Post Comment"
                                                        CommandName="SubmitComment"
                                                        CommandArgument='<%# Eval("PostId") %>'
                                                        CssClass="btn btn-primary" />
                                                </div>
                                            </div>

                                            <!-- Comments List -->
                                            <div class="comments-section">
                                                <h6 class="fw-bold mb-3 border-bottom pb-2">
                                                    All Comments (<%# ((System.Collections.ICollection)Eval("Comments")).Count %>)
                                                </h6>
                                                
                                                <div class="comments-list">
                                                    <asp:Repeater ID="rptComments" runat="server">
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
                                                                    <small class="text-muted"><%# Eval("createdAt", "{0:dd MMM yyyy hh:mm tt}") %></small>
                                                                </div>
                                                                <p class="mb-0 ps-5"><%# Eval("text") %></p>
                                                            </div>
                                                        </ItemTemplate>
                                                    </asp:Repeater>

                                                    <!-- No Comments Message -->
                                                    <div id="noCommentsDiv" runat="server" style="display:none;" class="no-comments-message">
                                                        <div class="no-comments-icon">💬</div>
                                                        <p class="mb-0">No comments yet. Be the first to comment!</p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Image Modal -->
                            <div class="modal fade" id='<%# "imgModal" + Eval("PostId") %>' tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-xl">
                                    <div class="modal-content">
                                        <div class="modal-body text-center p-0">
                                            <img src='<%# Eval("MediaUrl") %>' class="img-fluid w-100" style="max-height:90vh; object-fit: contain; border-radius: 20px;" />
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
    </div>

    <!-- Feedback Modal -->
    <div class="modal fade" id="feedbackModal" tabindex="-1" aria-labelledby="feedbackModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="feedbackModalLabel">
                        📝 Submit Feedback
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="text-danger" />

                    <div class="mb-3">
                        <label class="form-label fw-bold">Username</label>
                        <asp:TextBox ID="txtFeedbackUsername" runat="server" CssClass="form-control" ReadOnly="true" />
                    </div>

                    <div class="mb-3">
                        <label for="txtDescription" class="form-label fw-bold">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" Placeholder="Enter your feedback here" />
                    </div>

                    <div class="mb-3">
                        <label for="fileUpload" class="form-label fw-bold">Upload Image/Video (optional)</label>
                        <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnSubmit" runat="server" CssClass="btn btn-primary" Text="Submit Feedback" OnClick="btnSubmit_Click" />
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Include Required Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>

    <!-- JavaScript -->
    <script type="text/javascript">
        $(document).ready(function () {
            console.log('Enhanced Feedback page loaded with Library styling');

            // Add hover effects to all cards
            const cards = document.querySelectorAll('.student-info-card, .feedback-card');
            cards.forEach(card => {
                card.addEventListener('mouseenter', () => {
                    if (card.classList.contains('student-info-card')) {
                        card.style.transform = 'translateY(-8px) scale(1.02)';
                        card.style.boxShadow = '0 20px 40px rgba(0, 0, 0, 0.15)';
                    }
                });
                card.addEventListener('mouseleave', () => {
                    if (card.classList.contains('student-info-card')) {
                        card.style.transform = '';
                        card.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.1)';
                    }
                });
            });

            // Animation when modals open
            $('.modal').on('shown.bs.modal', function () {
                $(this).find('.modal-dialog').addClass('animate__animated animate__fadeInUp');
            });

            // Add entrance animation delay to feedback cards
            $('.feedback-card').each(function (index) {
                $(this).css('animation-delay', (index * 0.1) + 's');
            });

            // Enhanced button interactions
            $('.feedback-action-btn, .submit-btn').hover(
                function () {
                    $(this).css('transform', 'translateY(-2px)');
                },
                function () {
                    $(this).css('transform', '');
                }
            );
        });

        // Function to load comments
        function loadCommentsInModal(postId) {
            console.log('Opening comment modal for post:', postId);
            // You can add AJAX loading logic here if needed
        }

        // Page load function for postbacks
        function pageLoad() {
            console.log('PageLoad fired - reinitializing animations');

            // Re-initialize any JavaScript if needed after postback
            setTimeout(function () {
                $('.feedback-card').addClass('loading');

                // Reinitialize hover effects after postback
                const cards = document.querySelectorAll('.student-info-card');
                cards.forEach(card => {
                    card.addEventListener('mouseenter', () => {
                        card.style.transform = 'translateY(-8px) scale(1.02)';
                        card.style.boxShadow = '0 20px 40px rgba(0, 0, 0, 0.15)';
                    });
                    card.addEventListener('mouseleave', () => {
                        card.style.transform = '';
                        card.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.1)';
                    });
                });
            }, 100);
        }

        // Auto-focus on comment input when modal opens
        $(document).on('shown.bs.modal', '[id^="commentModal"]', function () {
            $(this).find('textarea[id*="txtCommentInput"]').focus();
        });

        // Clear comment input and errors when modal closes
        $(document).on('hidden.bs.modal', '[id^="commentModal"]', function () {
            var modal = $(this);
            modal.find('textarea[id*="txtCommentInput"]').val('');
            modal.find('[id*="lblCommentError"]').hide();
        });

        // Add click effect to buttons
        $(document).on('click', '.feedback-action-btn, .submit-btn', function () {
            $(this).addClass('clicked');
            setTimeout(() => {
                $(this).removeClass('clicked');
            }, 300);
        });

        // Enhanced scroll animations
        function animateOnScroll() {
            const cards = document.querySelectorAll('.feedback-card');
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            }, { threshold: 0.1 });

            cards.forEach(card => {
                observer.observe(card);
            });
        }

        // Initialize scroll animations
        animateOnScroll();

        // CSS for clicked effect and additional animations
        $('<style>')
            .prop('type', 'text/css')
            .html(`
                .feedback-action-btn.clicked,
                .submit-btn.clicked {
                    animation: buttonPulse 0.3s ease-out;
                }
                
                @keyframes buttonPulse {
                    0% { transform: scale(1); }
                    50% { transform: scale(1.05); }
                    100% { transform: scale(1); }
                }
                
                .modal-dialog.animate__animated {
                    animation-duration: 0.5s;
                }
                
                /* Additional hover effects */
                .feedback-image:hover {
                    filter: brightness(1.1);
                }
                
                .info-item:hover {
                    background: rgba(103, 126, 234, 0.05);
                    border-radius: 8px;
                    margin: 0 -8px;
                    padding: 8px;
                }
            `)
            .appendTo('head');
    </script>

    <!-- Font Awesome for additional icons if needed -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>