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
                                                <asp:Button ID="btnLike" runat="server"
                                                    Text='<%# "👍 " + Eval("Likes") %>'
                                                    CommandName="Like"
                                                    CommandArgument='<%# Eval("PostId") %>'
                                                    CssClass="btn btn-sm btn-outline-danger" />

                                                <asp:Button ID="btnComment" runat="server"
                                                    Text="💬 Comment"
                                                    CssClass="btn btn-sm btn-outline-secondary"
                                                    OnClientClick='<%# "openCommentModal(\"" + Eval("PostId") + "\"); return false;" %>' />
                                            </div>

                                            <!-- Comments List -->
                                            <div class="mt-3 border-top pt-2">
                                                <strong>Comments:</strong>

                                                <asp:Repeater ID="rptComments" runat="server">
                                                    <ItemTemplate>
                                                        <div class="comment mb-2 p-2 rounded border bg-light">
                                                            <small class="fw-bold"><%# Eval("username") %></small>
                                                            <small class="text-muted ms-2"><%# Eval("createdAt", "{0:dd MMM yyyy hh:mm tt}") %></small>
                                                            <p class="mb-0"><%# Eval("text") %></p>
                                                        </div>
                                                    </ItemTemplate>
                                                </asp:Repeater>

                                                <div id="noCommentsDiv" runat="server" style="display:none;" class="text-muted fst-italic">
                                                    No comments yet.
                                                </div>
                                            </div>
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
                    <h5 class="modal-title fw-bold" id="feedbackModalLabel">Submit Feedback</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="text-danger" />

                    <div class="mb-3">
                        <label class="form-label">Username</label>
                        <asp:TextBox ID="txtFeedbackUsername" runat="server" CssClass="form-control" ReadOnly="true" />
                    </div>

                    <div class="mb-3">
                        <label for="txtDescription" class="form-label">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" Placeholder="Enter your feedback here" />
                    </div>

                    <div class="mb-3">
                        <label for="fileUpload" class="form-label">Upload Image/Video (optional)</label>
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

    <!-- Comment Modal -->
    <div class="modal fade" id="commentModal" tabindex="-1" aria-labelledby="commentModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="commentModalLabel">Add Comment</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblCommentMessage" runat="server" Visible="false" CssClass="text-danger" />
                    <asp:HiddenField ID="hfPostId" runat="server" />
                    <asp:TextBox ID="txtComment" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" Placeholder="Write your comment here..." />
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnSubmitComment" runat="server" Text="Submit Comment" CssClass="btn btn-primary" OnClick="btnSubmitComment_Click" />
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Zoom Hover CSS -->
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
    </style>

    <script>
        function openCommentModal(postId) {
            var hf = document.getElementById('<%= hfPostId.ClientID %>');
            hf.value = postId;

            var lbl = document.getElementById('<%= lblCommentMessage.ClientID %>');
            if (lbl) lbl.style.display = 'none';

            var txt = document.getElementById('<%= txtComment.ClientID %>');
            if (txt) txt.value = '';

            var modal = new bootstrap.Modal(document.getElementById('commentModal'));
            modal.show();
        }
    </script>
</asp:Content>
