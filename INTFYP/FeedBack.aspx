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

    <!-- Two-Column Layout -->
    <div class="container mb-5">
        <div class="row">
            <!-- LEFT: Student Info -->
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

                    <!-- Trigger Modal -->
                    <button type="button" class="btn btn-primary mt-3" data-bs-toggle="modal" data-bs-target="#feedbackModal">
                        Submit Feedback
                    </button>
                </div>
            </div>

            <!-- RIGHT: Feedback Posts -->
            <div class="col-md-8">
                <asp:Repeater ID="rptFeedback" runat="server" OnItemCommand="rptFeedback_ItemCommand">
                    <HeaderTemplate>
                        <div class="row row-cols-1 row-cols-md-2 g-4">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="col">
                            <div class="card h-100 shadow-sm p-3">
                                <h6 class="fw-bold"><%# Eval("Username") %></h6>
                                <p><%# Eval("Description") %></p>

                                <div class="mb-2">
                                    <%# GetMediaHtml(Eval("MediaUrl")?.ToString()) %>
                                </div>

                                <hr class="my-2" />

                                <div class="d-flex justify-content-between">
                                    <asp:Button ID="btnLike" runat="server"
                                        Text='<%# String.Format("👍 {0}", Eval("Likes")) %>'
                                        CommandName="Like"
                                        CommandArgument='<%# Eval("PostId") %>'
                                        CssClass="btn btn-sm btn-outline-primary" />

                                    <asp:Button ID="btnComment" runat="server"
                                        Text="💬 Comment"
                                        CommandName="Comment"
                                        CommandArgument='<%# Eval("PostId") %>'
                                        CssClass="btn btn-sm btn-outline-secondary" />
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

    <!-- Bootstrap Modal for Submit Feedback -->
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
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Enter your feedback here" />
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
</asp:Content>
