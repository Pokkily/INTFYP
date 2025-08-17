<%@ Page Title="Study Hub Group" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="StudyHubGroup.aspx.cs" Inherits="YourProjectNamespace.StudyHubGroup" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Study Group
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    

    <style>
        .card {
            border-radius: 12px;
        }

        .edit-textarea {
            width: 100%;
            height: auto;
            resize: vertical;
        }

        .form-control {
            border-radius: 8px;
        }

        .img-fluid {
            max-height: 300px;
            object-fit: contain;
        }

        .post-container {
            border: 1px solid #ddd;
            border-radius: 12px;
            padding: 16px;
            background-color: #fff;
            margin-bottom: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
        }

        .comment-container {
            border-top: 1px solid #eee;
            padding-top: 10px;
            margin-top: 10px;
        }

        .edit-textarea {
            width: 100%;
            height: 80px;
            resize: vertical;
        }

        .btn-sm:hover {
            background-color: #f8f9fa;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .btn-outline-secondary:hover {
            background-color: #6c757d;
            color: white;
        }

        .btn-outline-danger:hover {
            background-color: #dc3545;
            color: white;
        }

        .post-actions {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #eee;
        }

        .action-btn {
            display: flex;
            align-items: center;
            gap: 5px;
            background: none;
            border: 1px solid #ddd;
            padding: 5px 10px;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .action-btn:hover {
            background-color: #f8f9fa;
        }

        .action-btn.liked {
            color: #dc3545;
            border-color: #dc3545;
        }

        .action-btn.saved {
            color: #28a745;
            border-color: #28a745;
        }

        .report-btn {
            color: #6c757d;
        }

        .report-btn:hover {
            color: #dc3545;
        }
    </style>

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="container py-4">
                <!-- Group Header -->
                <asp:Literal ID="ltGroupDetails" runat="server" />

                <!-- Create Post Section -->
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <h5 class="card-title">📌 Create a New Post</h5>
                        <asp:TextBox ID="txtPostContent" runat="server" TextMode="MultiLine" CssClass="form-control mb-2" Rows="3" placeholder="What's on your mind?"></asp:TextBox>
                        <div class="mb-3">
                            <label class="form-label">📎 Attach Files (Images/PDFs - Multiple allowed)</label>
                            <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" AllowMultiple="true" accept=".jpg,.jpeg,.png,.gif,.pdf" />
                            <small class="text-muted">Supported: JPG, PNG, GIF, PDF (Max 5 files)</small>
                        </div>
                        <asp:Button ID="btnPost" runat="server" CssClass="btn btn-primary" Text="📤 Post" OnClick="btnPost_Click" />
                    </div>
                </div>

                <!-- Posts List -->
                <asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand">
                    <ItemTemplate>
                        <div class="card shadow-sm mb-4">
                            <div class="card-body">
                                <!-- Post Header -->
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <div>
                                        <strong class="text-dark"><%# Eval("creatorUsername") %></strong>
                                        <small class="text-muted"> • <%# Eval("timestamp") %></small>
                                    </div>
                                    <div>
                                        <asp:LinkButton ID="btnEditPost" runat="server" 
                                            CommandName="EditPost" 
                                            CommandArgument='<%# Eval("postId") %>' 
                                            CssClass="btn btn-sm btn-outline-secondary me-2"
                                            Visible='<%# (bool)Eval("isOwner") %>'>
                                            ✏️ Edit
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDeletePost" runat="server" 
                                            CommandName="DeletePost" 
                                            CommandArgument='<%# Eval("postId") %>' 
                                            CssClass="btn btn-sm btn-outline-danger"
                                            Visible='<%# (bool)Eval("isOwner") %>'
                                            OnClientClick="return confirm('Are you sure you want to delete this post?')">
                                            🗑️ Delete
                                        </asp:LinkButton>
                                    </div>
                                </div>

                                <!-- Post Content / Edit -->
                                <asp:Panel ID="pnlPostView" runat="server" Visible='<%# !(bool)Eval("IsEditingPost") %>'>
                                    <p class="mb-3"><%# Eval("content") %></p>
                                    <%# !string.IsNullOrEmpty(Eval("imageUrl").ToString()) ? "<img src='" + Eval("imageUrl") + "' class='img-fluid rounded mb-3'/>" : "" %>
                                </asp:Panel>

                                <asp:Panel ID="pnlPostEdit" runat="server" Visible='<%# (bool)Eval("IsEditingPost") %>'>
                                    <asp:TextBox ID="txtEditPost" runat="server" CssClass="form-control mb-2" Text='<%# Eval("content") %>' TextMode="MultiLine" Rows="3"></asp:TextBox>
                                    <div class="d-flex gap-2">
                                        <asp:Button ID="btnSavePost" runat="server" CommandName="SavePost" CommandArgument='<%# Eval("postId") %>' Text="💾 Save" CssClass="btn btn-success btn-sm me-2" />
                                        <asp:Button ID="btnCancelPost" runat="server" CommandName="CancelPost" CommandArgument='<%# Eval("postId") %>' Text="❌ Cancel" CssClass="btn btn-outline-secondary btn-sm" />
                                    </div>
                                </asp:Panel>

                                <!-- Post Actions (Like, Save, Report) -->
                                <div class="post-actions">
                                    <asp:LinkButton ID="btnLike" runat="server" 
                                        CommandName="ToggleLike" 
                                        CommandArgument='<%# Eval("postId") %>' 
                                        CssClass='<%# "action-btn " + ((bool)Eval("isLiked") ? "liked" : "") %>'>
                                        <%# (bool)Eval("isLiked") ? "❤️" : "🤍" %> <%# Eval("likeCount") %>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnSave" runat="server" 
                                        CommandName="ToggleSave" 
                                        CommandArgument='<%# Eval("postId") %>' 
                                        CssClass='<%# "action-btn " + ((bool)Eval("isSaved") ? "saved" : "") %>'>
                                        <%# (bool)Eval("isSaved") ? "💾" : "📌" %> <%# (bool)Eval("isSaved") ? "Saved" : "Save" %>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnReport" runat="server" 
                                        CommandName="ReportPost" 
                                        CommandArgument='<%# Eval("postId") %>' 
                                        CssClass="action-btn report-btn"
                                        Visible='<%# !(bool)Eval("isOwner") %>'
                                        OnClientClick="return confirm('Report this post as inappropriate?')">
                                        🚩 Report
                                    </asp:LinkButton>
                                </div>

                                <hr />

                                <!-- Comments Section -->
                                <div>
                                    <h6 class="mb-2">💬 Comments (<%# ((List<dynamic>)Eval("comments")).Count %>)</h6>
                                    
                                    <asp:Repeater ID="rptComments" runat="server" DataSource='<%# Eval("comments") %>' OnItemCommand="rptComments_ItemCommand">
                                        <ItemTemplate>
                                            <div class="mb-3 ps-3 border-start border-2">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <strong><%# Eval("username") %></strong>
                                                        <small class="text-muted"> • <%# Eval("timestamp") %></small>
                                                    </div>
                                                    <div>
                                                        <asp:LinkButton ID="btnEditComment" runat="server" 
                                                            CommandName="EditComment" 
                                                            CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                            CssClass="btn btn-sm btn-outline-secondary me-1"
                                                            Visible='<%# (bool)Eval("isOwner") %>'>
                                                            ✏️
                                                        </asp:LinkButton>
                                                        <asp:LinkButton ID="btnDeleteComment" runat="server" 
                                                            CommandName="DeleteComment" 
                                                            CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' 
                                                            CssClass="btn btn-sm btn-outline-danger"
                                                            Visible='<%# (bool)Eval("isOwner") %>'
                                                            OnClientClick="return confirm('Delete this comment?')">
                                                            🗑️
                                                        </asp:LinkButton>
                                                    </div>
                                                </div>

                                                <!-- View or Edit Mode -->
                                                <asp:Panel ID="pnlCommentView" runat="server" Visible='<%# !(bool)Eval("IsEditingComment") %>'>
                                                    <p class="mb-1 mt-2"><%# Eval("content") %></p>
                                                </asp:Panel>

                                                <asp:Panel ID="pnlCommentEdit" runat="server" Visible='<%# (bool)Eval("IsEditingComment") %>'>
                                                    <asp:TextBox ID="txtEditComment" runat="server" CssClass="form-control mb-2 mt-2" Text='<%# Eval("content") %>' TextMode="MultiLine" Rows="2"></asp:TextBox>
                                                    <div class="d-flex gap-2">
                                                        <asp:Button ID="btnSaveComment" runat="server" CommandName="SaveComment" CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' Text="💾 Save" CssClass="btn btn-success btn-sm me-2" />
                                                        <asp:Button ID="btnCancelComment" runat="server" CommandName="CancelComment" CommandArgument='<%# Eval("postId") + "|" + Eval("commentId") %>' Text="❌ Cancel" CssClass="btn btn-outline-secondary btn-sm" />
                                                    </div>
                                                </asp:Panel>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>

                                    <!-- New Comment Input -->
                                    <div class="mt-3 ps-3 border-start border-2">
                                        <asp:TextBox ID="txtNewComment" runat="server" CssClass="form-control mb-2" placeholder="Write a comment..." TextMode="MultiLine" Rows="2"></asp:TextBox>
                                        <asp:Button ID="btnComment" runat="server" CommandName="AddComment" CommandArgument='<%# Eval("postId") %>' Text="💬 Post Comment" CssClass="btn btn-dark btn-sm" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnPost" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>