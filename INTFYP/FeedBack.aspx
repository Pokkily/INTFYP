<%@ Page Async="true" Title="Feedback" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Feedback.aspx.cs" Inherits="YourProjectNamespace.Feedback" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Feedback
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Student Feedback</h1>
            <p class="lead text-muted">Submit your feedback with description, image, or video</p>
        </div>
    </section>

    <div class="container mb-5">
        <div class="row">
            <!-- Student Info -->
            <div class="col-md-4">
                <div class="card p-3 shadow-sm">
                    <h5 class="fw-bold mb-3">Student Information</h5>
                    <p><strong>Name:</strong> <asp:Label ID="lblName" runat="server" /></p>
                    <p><strong>Username:</strong> <asp:Label ID="lblUsername" runat="server" /></p>
                    <p><strong>Email:</strong> <asp:Label ID="lblEmail" runat="server" /></p>
                    <p><strong>Phone:</strong> <asp:Label ID="lblPhone" runat="server" /></p>
                    <p><strong>Gender:</strong> <asp:Label ID="lblGender" runat="server" /></p>
                    <p><strong>Birthdate:</strong> <asp:Label ID="lblBirthdate" runat="server" /></p>
                    <p><strong>Position:</strong> <asp:Label ID="lblPosition" runat="server" /></p>
                    <p><strong>Address:</strong> <asp:Label ID="lblAddress" runat="server" /></p>
                </div>

                <!-- Submit Button Full Width -->
                <div class="mt-3">
                    <button type="button" class="btn btn-primary w-100" data-bs-toggle="modal" data-bs-target="#feedbackModal">
                        Submit Feedback
                    </button>
                </div>
            </div>

            <!-- Feedback Cards -->
            <div class="col-md-8">
<asp:Repeater ID="rptFeedback" runat="server" OnItemCommand="rptFeedback_ItemCommand" OnItemDataBound="rptFeedback_ItemDataBound">
    <HeaderTemplate>
        <div class="row row-cols-1 row-cols-md-2 g-3">
    </HeaderTemplate>
    <ItemTemplate>
        <div class="col">
            <div class="card h-100 shadow-sm">
                <div class="row g-0 h-100">
                    <!-- Image -->
                    <div class="col-5">
                        <img src='<%# Eval("MediaUrl") %>' alt="Media"
                             class="img-fluid w-100 h-100 object-cover rounded-start zoom-effect"
                             style="object-fit: cover; cursor: pointer;"
                             data-bs-toggle="modal"
                             data-bs-target='<%# "#imgModal" + Eval("PostId") %>' />
                    </div>

                    <!-- Text -->
                    <div class="col-7">
                        <div class="card-body d-flex flex-column justify-content-between h-100">
                            <div>
                                <h6 class="fw-bold mb-1 mb-0"><%# Eval("Username") %></h6>
                                <small class="text-muted d-block mb-2"><%# Eval("CreatedAt", "{0:dd MMM yyyy hh:mm tt}") %></small>
                                <p class="mb-2"><%# Eval("Description") %></p>
                            </div>
                            <div class="d-flex gap-2 mt-auto mb-2">
                                <!-- Like Button -->
                                <asp:Button ID="btnLike" runat="server"
                                    Text='<%# "👍 " + Eval("Likes") %>'
                                    CommandName="Like"
                                    CommandArgument='<%# Eval("PostId") %>'
                                    CssClass="btn btn-sm btn-outline-danger" />

                                <!-- Comment Button (Modal Trigger) -->
                                <button type="button"
                                    class="btn btn-sm btn-outline-secondary"
                                    data-bs-toggle="modal"
                                    data-bs-target='<%# "#commentModal" + Eval("PostId") %>'
                                    onclick="loadCommentsInModal('<%# Eval("PostId") %>')">
                                    💬 Comments (<%# ((System.Collections.ICollection)Eval("Comments")).Count %>)
                                </button>
                            </div>
                        </div>
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
                                
                                <div class="comments-list" style="max-height: 400px; overflow-y: auto;">
                                    <asp:Repeater ID="rptComments" runat="server">
                                        <ItemTemplate>
                                            <div class="comment mb-3 p-3 rounded border bg-light">
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
                    <asp:Button ID="btnSubmit" runat="server" CssClass="btn btn-primary" Text="Submit Feedback" OnClick="btnSubmit_Click" />
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Styles -->
    <style>
        .zoom-effect {
            transition: transform 0.3s ease;
        }
        .zoom-effect:hover {
            transform: scale(1.03);
        }
        .object-cover {
            object-fit: cover;
        }
        .comment {
            transition: all 0.2s ease;
        }
        .comment:hover {
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.1);
            transform: translateY(-1px);
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
        .comments-list::-webkit-scrollbar-thumb:hover {
            background: #adb5bd;
        }
        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
    </style>

    <!-- Include Required Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>

    <!-- JavaScript -->
    <script type="text/javascript">
        $(document).ready(function () {
            console.log('Feedback page loaded with modal comments');

            // Optional: Add some animation when modals open
            $('.modal').on('shown.bs.modal', function () {
                $(this).find('.modal-dialog').addClass('animate__animated animate__fadeInUp');
            });
        });

        // Function to load comments (optional - for future AJAX loading)
        function loadCommentsInModal(postId) {
            console.log('Opening comment modal for post:', postId);
            // You can add AJAX loading logic here if needed
            // For now, comments are already loaded via Repeater
        }

        // Page load function for postbacks
        function pageLoad() {
            console.log('PageLoad fired');
            // Re-initialize any JavaScript if needed after postback
        }

        // Optional: Auto-focus on comment input when modal opens
        $(document).on('shown.bs.modal', '[id^="commentModal"]', function () {
            $(this).find('textarea[id*="txtCommentInput"]').focus();
        });

        // Optional: Clear comment input and errors when modal closes
        $(document).on('hidden.bs.modal', '[id^="commentModal"]', function () {
            var modal = $(this);
            modal.find('textarea[id*="txtCommentInput"]').val('');
            modal.find('[id*="lblCommentError"]').hide();
        });
    </script>
</asp:Content>