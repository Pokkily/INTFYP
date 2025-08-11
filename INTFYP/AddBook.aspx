<%@ Page Async="true" Title="Add Book" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeFile="AddBook.aspx.cs" Inherits="INTFYP.AddBook" %>
<asp:Content ID="AddBookContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        .form-section {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            margin-bottom: 24px;
            border: 1px solid #e0e0e0;
        }
        .form-header {
            color: #212121;
            font-weight: 600;
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f0f0;
        }
        .form-label {
            font-weight: 500;
            color: #424242;
            font-size: 14px;
            margin-bottom: 6px;
        }
        .form-control {
            border-radius: 4px;
            border: 1px solid #e0e0e0;
            padding: 10px 12px;
            font-size: 14px;
        }
        .form-control:focus {
            border-color: #9e9e9e;
            box-shadow: none;
        }
        .btn {
            border-radius: 4px;
            font-weight: 500;
            font-size: 14px;
            padding: 10px 20px;
        }
        .btn-dark {
            background-color: #212121;
            border-color: #212121;
            color: #ffffff;
        }
        .btn-dark:hover {
            background-color: #000000;
            border-color: #000000;
        }
        .book-card {
            transition: transform 0.2s ease;
        }
        .book-card:hover {
            transform: translateY(-2px);
        }
        .book-category {
            background-color: #f8f9fa;
            color: #6c757d;
            font-size: 12px;
            padding: 4px 8px;
            border-radius: 12px;
            display: inline-block;
        }
        .edit-section {
            background-color: #f8f9fa;
            border-radius: 6px;
            padding: 20px;
            margin-top: 15px;
        }
        .action-buttons .btn {
            margin-right: 8px;
        }
    </style>

    <!-- Add Book Form -->
    <div class="form-section">
        <h3 class="form-header">New Materials for Student</h3>
        <asp:Label ID="lblStatus" runat="server" Text="" ForeColor="Green" />
        <div class="row g-3">
            <div class="col-md-6">
                <label class="form-label">Title</label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="e.g., Advanced Physics" />
            </div>
            <div class="col-md-6">
                <label class="form-label">Author</label>
                <asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" placeholder="e.g., John Doe" />
            </div>
            <div class="col-md-6">
                <label class="form-label">Category</label>
                <asp:TextBox ID="txtCategory" runat="server" CssClass="form-control" placeholder="e.g., Science" />
            </div>
            <div class="col-md-6">
                <label class="form-label">PDF File</label>
                <asp:FileUpload ID="filePdf" runat="server" CssClass="form-control" />
            </div>
        </div>
        <div class="d-flex justify-content-end mt-4">
            <asp:Button ID="btnSubmit" runat="server" Text="Add Book" CssClass="btn btn-dark" OnClick="btnSubmit_Click" />
        </div>
    </div>

    <!-- Book List Section -->
    <div class="form-section">
        <h3 class="form-header">Your Books</h3>
        <asp:Label ID="lblBookStatus" runat="server" Text="" />
        
        <asp:Repeater ID="rptBooks" runat="server" OnItemCommand="rptBooks_ItemCommand">
            <ItemTemplate>
                <div class="card mb-3 shadow-sm book-card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="mb-1"><%# Eval("Title") %></h5>
                            <small class="text-muted">by <%# Eval("Author") %></small>
                            <span class="book-category ms-2"><%# Eval("Category") %></span>
                        </div>
                        <button class="btn btn-sm btn-outline-primary" type="button" 
                                data-bs-toggle="collapse" 
                                data-bs-target="#book<%# Container.ItemIndex %>" 
                                aria-expanded="false" 
                                aria-controls="book<%# Container.ItemIndex %>">
                            Manage
                        </button>
                    </div>
                    
                    <div class="collapse" id="book<%# Container.ItemIndex %>">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="edit-section">
                                        <h6>Edit Book Details</h6>
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Title</label>
                                                <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" 
                                                           Text='<%# Eval("Title") %>' />
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Author</label>
                                                <asp:TextBox ID="txtEditAuthor" runat="server" CssClass="form-control" 
                                                           Text='<%# Eval("Author") %>' />
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Category</label>
                                                <asp:TextBox ID="txtEditCategory" runat="server" CssClass="form-control" 
                                                           Text='<%# Eval("Category") %>' />
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Replace PDF (Optional)</label>
                                                <asp:FileUpload ID="fileEditPdf" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="col-md-4">
                                    <h6>Current PDF</h6>
                                    <asp:Panel ID="pnlPdfPreview" runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("PdfUrl").ToString()) %>'>
                                        <a href='<%# Eval("PdfUrl") %>' target="_blank" class="btn btn-outline-info btn-sm mb-3">
                                            📄 View PDF
                                        </a>
                                    </asp:Panel>
                                    
                                    <div class="action-buttons">
                                        <asp:LinkButton ID="btnUpdate" runat="server" 
                                                      CssClass="btn btn-success btn-sm" 
                                                      CommandName="Update" 
                                                      CommandArgument='<%# Eval("Id") %>'
                                                      OnClientClick="return confirm('Update this book?');">
                                            💾 Update
                                        </asp:LinkButton>
                                        
                                        <asp:LinkButton ID="btnDelete" runat="server" 
                                                      CssClass="btn btn-danger btn-sm" 
                                                      CommandName="Delete" 
                                                      CommandArgument='<%# Eval("Id") %>'
                                                      OnClientClick="return confirm('Are you sure you want to delete this book? This action cannot be undone.');">
                                            🗑️ Delete
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
        
        <asp:Panel ID="pnlNoBooks" runat="server" Visible="false" CssClass="text-center py-4">
            <div class="text-muted">
                <i class="fas fa-book fa-3x mb-3"></i>
                <p>No books found. Add your first book above!</p>
            </div>
        </asp:Panel>
    </div>
</asp:Content>