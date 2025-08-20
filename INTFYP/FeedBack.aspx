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
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            overflow: hidden;
            position: relative;
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
            border-radius: 20px;
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

        /* Teal Submit Button - Matching Language Page Student Report Button */
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

        /* Enhanced Feedback Card Styles - PRESERVED */
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

        /* Library-Style Like Button - Dark Green (Same as Favorite Button) */
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
            /* Override Bootstrap defaults */
            font-family: inherit !important;
            line-height: 1 !important;
            text-align: center !important;
            vertical-align: middle !important;
            touch-action: manipulation !important;
            user-select: none !important;

            /* Default state - gray (same as Library buttons) */
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

        /* Hover state - Dark Green (same as favorite button) */
        .btn-like:hover {
            transform: translateY(-2px) !important;
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.4) !important;
            color: white !important;
        }

        /* ACTIVE STATE - When user has liked (Dark Green) */
        .btn-like.active {
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.5) !important;
            color: #ffffff !important;
        }

        .btn-like.active:hover {
            background: linear-gradient(135deg, #8a9c78 0%, #7a8c68 100%) !important;
            box-shadow: 0 10px 30px rgba(156, 175, 136, 0.6) !important;
        }

        /* Temporary click animation */
        .btn-like.clicked {
            animation: buttonPulse 0.6s ease-out !important;
        }

        @keyframes buttonPulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }

        .btn-sm {
            padding: 0.35rem 0.75rem;
            font-size: 0.85rem;
            white-space: nowrap;
        }

        /* Comment Modal Styles */
        .modal-header {
            background: var(--primary-gradient);
            color: white;
        }
        
        .modal-header .btn-close {
            filter: invert(1);
        }
        
        .comment-input textarea {
            resize: none;
            border: 2px solid #e9ecef;
            transition: border-color 0.3s ease;
        }
        
        .comment-input textarea:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .comment {
            transition: all 0.2s ease;
            margin-bottom: 0.75rem;
            padding: 0.75rem;
            border-radius: 12px;
            background: rgba(248, 249, 250, 0.8);
        }
        
        .comment:hover {
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.1);
        }
        
        .comments-list {
            max-height: 400px;
            overflow-y: auto;
            padding-right: 0.5rem;
        }
        
        .comments-list::-webkit-scrollbar {
            width: 6px;
        }
        
        .comments-list::-webkit-scrollbar-track {
            background: #f8f9fa;
            border-radius: 10px;
        }
        
        .comments-list::-webkit-scrollbar-thumb {
            background: #dee2e6;
            border-radius: 10px;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .feedback-image-container {
                height: 150px;
            }
            
            .feedback-description {
                -webkit-line-clamp: 2;
            }
            
            .row-cols-md-3 {
                grid-template-columns: 1fr !important;
            }
        }
    </style>

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
                            <div class="glass-card feedback-card h-100" style='animation-delay: calc(<%# Container.ItemIndex %> * 0.1s)'>
                                <!-- Image Section -->
                                <div class="feedback-image-container">
                                    <img src='<%# Eval("MediaUrl") %>' alt="Feedback media"
                                         class="feedback-image"
                                         data-bs-toggle="modal"
                                         data-bs-target='<%# "#imgModal" + Eval("PostId") %>' />
                                </div>
                                
                                <!-- Content Section -->
                                <div class="feedback-content">
                                    <div class="feedback-header">
                                        <div class="feedback-username"><%# Eval("Username") %></div>
                                        <div class="feedback-date"><%# Eval("CreatedAt", "{0:dd MMM yyyy hh:mm tt}") %></div>
                                    </div>
                                    
                                    <p class="feedback-description"><%# Eval("Description") %></p>
                                    
                                    <div class="feedback-actions">
                                        <!-- Like Button with Library Style - Now Dark Green with Active State -->
                                        <asp:Button ID="btnLike" runat="server"
                                            Text='<%# "❤️ " + Eval("Likes") %>'
                                            CommandName="Like"
                                            CommandArgument='<%# Eval("PostId") %>'
                                            CssClass='<%# "btn-like" + (Convert.ToBoolean(Eval("IsLiked")) ? " active" : "") %>'
                                            OnClientClick="addClickEffect(this); return true;" />

                                        <!-- Comment Button -->
                                        <button type="button"
                                            class="btn btn-sm btn-outline-secondary"
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
                                                <i class="fas fa-comments me-2"></i>Comments - <%# Eval("Username") %>
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
                                                    <div id="noCommentsDiv" runat="server" style="display:none;" class="text-center text-muted py-5">
                                                        <i class="fas fa-comment-slash fa-3x mb-3 opacity-50"></i>
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
                                            <img src='<%# Eval("MediaUrl") %>' class="img-fluid w-100" style="max-height:90vh; object-fit: contain;" />
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

    <!-- Feedback Modal -->
    <div class="modal fade" id="feedbackModal" tabindex="-1" aria-labelledby="feedbackModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="feedbackModalLabel">
                        <i class="fas fa-plus-circle me-2"></i>Submit Feedback
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
                    <!-- Submit Button in Modal - Also with Teal Color -->
                    <asp:Button ID="btnSubmit" runat="server" CssClass="btn btn-submit-teal" Text="Submit Feedback" OnClick="btnSubmit_Click" />
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
            console.log('Feedback page loaded with teal submit buttons (matching Language page)');

            // Add hover effects to all glass cards
            const cards = document.querySelectorAll('.glass-card');
            cards.forEach(card => {
                card.addEventListener('mouseenter', () => {
                    card.style.transform = 'translateY(-8px)';
                    card.style.boxShadow = '0 15px 35px rgba(0, 0, 0, 0.15)';
                });
                card.addEventListener('mouseleave', () => {
                    card.style.transform = '';
                    card.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.1)';
                });
            });

            // Animation when modals open
            $('.modal').on('shown.bs.modal', function () {
                $(this).find('.modal-dialog').addClass('animate__animated animate__fadeInUp');
            });
        });

        // Library-style click effect for like button - Updated for proper active state
        function addClickEffect(button) {
            // Add clicked class for animation
            button.classList.add('clicked');

            // Remove only the clicked animation class after animation completes
            // Don't manually add "active" class - let the server-side code handle it
            setTimeout(function () {
                button.classList.remove('clicked');
            }, 600);
        }

        // Function to load comments
        function loadCommentsInModal(postId) {
            console.log('Opening comment modal for post:', postId);
            // You can add AJAX loading logic here if needed
        }

        // Page load function for postbacks
        function pageLoad() {
            console.log('PageLoad fired');
            // Re-initialize any JavaScript if needed after postback
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
    </script>
</asp:Content>