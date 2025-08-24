<%@ Page Async="true" Title="Add Book" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeFile="AddBook.aspx.cs" Inherits="INTFYP.AddBook" %>
<asp:Content ID="AddBookContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        /* Modern Design System Implementation */
        .add-book-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
        }

        .books-container {
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            animation: slideInFromTop 1s ease-out;
        }

        .page-title {
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 15px;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }

        .page-subtitle {
            color: rgba(255,255,255,0.8);
            font-size: 16px;
            margin-bottom: 0;
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            margin-bottom: 25px;
            overflow: hidden;
            animation: slideInFromBottom 0.8s ease-out;
        }

        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            font-weight: 700;
            font-size: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-body {
            padding: 25px;
        }

        .form-label {
            font-weight: 600;
            color: #2c3e50;
            font-size: 14px;
            margin-bottom: 8px;
            display: block;
        }

        .form-control {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 14px;
            transition: all 0.3s ease;
            width: 100%;
        }

        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.3);
            outline: none;
            transform: scale(1.02);
        }

        .primary-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 24px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
        }

        .primary-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            color: white;
            text-decoration: none;
        }

        .secondary-button {
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            border: 1px solid rgba(103, 126, 234, 0.3);
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .secondary-button:hover {
            background: #667eea;
            color: white;
            transform: scale(1.05);
            text-decoration: none;
        }

        .success-button {
            background: linear-gradient(45deg, #56ab2f, #a8e6cf);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s ease;
        }

        .success-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(86, 171, 47, 0.3);
        }

        .danger-button {
            background: linear-gradient(45deg, #ff6b6b, #ee5a52);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s ease;
        }

        .danger-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 107, 107, 0.3);
        }

        .book-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            overflow: hidden;
            transition: all 0.3s ease;
            margin-bottom: 20px;
            animation: slideInFromLeft 0.6s ease-out;
        }

        .book-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
        }

        .book-header {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .book-info h5 {
            color: #2c3e50;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .book-info small {
            color: #7f8c8d;
            font-size: 14px;
        }

        .book-category {
            background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
            color: white;
            font-size: 12px;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 500;
            margin-left: 10px;
        }

        .book-tag {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            font-size: 12px;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 500;
            margin-left: 10px;
        }

        .edit-section {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            backdrop-filter: blur(5px);
            border-radius: 15px;
            padding: 20px;
            margin-top: 15px;
            border: 1px solid rgba(255,255,255,0.1);
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }

        .status-message {
            background: rgba(86, 171, 47, 0.1);
            border: 1px solid rgba(86, 171, 47, 0.3);
            color: #2d5016;
            padding: 12px 16px;
            border-radius: 10px;
            margin-left: 15px;
            animation: slideInFromRight 0.5s ease-out;
            display: inline-block;
        }

        .error-message {
            background: rgba(255, 107, 107, 0.1);
            border: 1px solid rgba(255, 107, 107, 0.3);
            color: #8b2635;
            padding: 12px 16px;
            border-radius: 10px;
            margin-left: 15px;
            animation: slideInFromRight 0.5s ease-out;
            display: inline-block;
        }

        .no-data-panel {
            text-align: center;
            padding: 60px 20px;
            color: #7f8c8d;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            backdrop-filter: blur(5px);
        }

        .no-data-panel i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        .file-hint {
            font-size: 12px;
            color: #7f8c8d;
            margin-top: 5px;
            font-style: italic;
        }

        .file-hint i {
            color: #3498db;
            margin-right: 5px;
        }

        .button-group {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        /* Grid System */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            position: relative;
        }

        /* Animations */
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

        @keyframes slideInFromRight {
            from {
                opacity: 0;
                transform: translateX(50px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .book-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .action-buttons {
                flex-direction: column;
            }

            .button-group {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .status-message, .error-message {
                margin-left: 0;
                margin-top: 10px;
                display: block;
            }
        }

        /* Utility Classes */
        .mb-0 { margin-bottom: 0; }
        .mb-1 { margin-bottom: 5px; }
        .mb-2 { margin-bottom: 10px; }
        .mb-3 { margin-bottom: 15px; }
        .mb-4 { margin-bottom: 20px; }
        .mt-3 { margin-top: 15px; }
        .mt-4 { margin-top: 20px; }
        .d-flex { display: flex; }
        .justify-content-end { justify-content: flex-end; }
        .justify-content-between { justify-content: space-between; }
        .align-items-center { align-items: center; }
        .text-center { text-align: center; }
    </style>

    <div class="add-book-page">
        <div class="books-container">
            <div class="page-header">
                <h2 class="page-title">📚 Learning Materials Manager</h2>
                <p class="page-subtitle">Upload and manage educational resources for students</p>
            </div>

            <!-- Add Book Form -->
            <div class="glass-card">
                <div class="card-header">
                    <i class="fas fa-plus-circle"></i>
                    Add New Learning Material
                </div>
                <div class="card-body">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book me-1"></i>
                                Title
                            </label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" 
                                       placeholder="e.g., Advanced Physics Textbook" />
                            <asp:RequiredFieldValidator ID="rfvTitle" runat="server" 
                                ControlToValidate="txtTitle" 
                                ErrorMessage="Title is required" 
                                CssClass="text-danger" 
                                Display="Dynamic" />
                        </div>
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-user-edit me-1"></i>
                                Author
                            </label>
                            <asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" 
                                       placeholder="e.g., Dr. John Smith" />
                            <asp:RequiredFieldValidator ID="rfvAuthor" runat="server" 
                                ControlToValidate="txtAuthor" 
                                ErrorMessage="Author is required" 
                                CssClass="text-danger" 
                                Display="Dynamic" />
                        </div>
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-tag me-1"></i>
                                Category
                            </label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                                <asp:ListItem Value="" Text="-- Select Category --" />
                                <asp:ListItem Value="Novels" Text="Novels" />
                                <asp:ListItem Value="Short stories" Text="Short stories" />
                                <asp:ListItem Value="Drama/plays" Text="Drama/plays" />
                                <asp:ListItem Value="Poetry" Text="Poetry" />
                                <asp:ListItem Value="Fantasy" Text="Fantasy" />
                                <asp:ListItem Value="Science fiction" Text="Science fiction" />
                                <asp:ListItem Value="Mystery/Thriller" Text="Mystery/Thriller" />
                                <asp:ListItem Value="Romance" Text="Romance" />
                                <asp:ListItem Value="Horror" Text="Horror" />
                                <asp:ListItem Value="Historical fiction" Text="Historical fiction" />
                                <asp:ListItem Value="Biography & Autobiography" Text="Biography & Autobiography" />
                                <asp:ListItem Value="Memoir" Text="Memoir" />
                                <asp:ListItem Value="Self-help" Text="Self-help" />
                                <asp:ListItem Value="History" Text="History" />
                                <asp:ListItem Value="Science & Technology" Text="Science & Technology" />
                                <asp:ListItem Value="Philosophy" Text="Philosophy" />
                                <asp:ListItem Value="Religion & Spirituality" Text="Religion & Spirituality" />
                                <asp:ListItem Value="Travel" Text="Travel" />
                                <asp:ListItem Value="Essays" Text="Essays" />
                                <asp:ListItem Value="Business & Economics" Text="Business & Economics" />
                                <asp:ListItem Value="Reference" Text="Reference (dictionaries, encyclopedias, textbooks)" />
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvCategory" runat="server" 
                                ControlToValidate="ddlCategory" 
                                ErrorMessage="Please select a category" 
                                CssClass="text-danger" 
                                Display="Dynamic" />
                        </div>
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-tags me-1"></i>
                                Tag
                            </label>
                            <asp:TextBox ID="txtTag" runat="server" CssClass="form-control" 
                                       placeholder="e.g., Advanced, Beginner, Recommended" />
                        </div>
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-file-pdf me-1"></i>
                                PDF File
                            </label>
                            <asp:FileUpload ID="filePdf" runat="server" CssClass="form-control" />
                            <div class="file-hint">
                                <i class="fas fa-info-circle"></i>
                                Maximum file size: 10 MB. Only PDF files are allowed.
                            </div>
                            <asp:RequiredFieldValidator ID="rfvPdf" runat="server" 
                                ControlToValidate="filePdf" 
                                ErrorMessage="PDF file is required" 
                                CssClass="text-danger" 
                                Display="Dynamic" />
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-end mt-4">
                        <div class="button-group">
                            <asp:Button ID="btnSubmit" runat="server" Text="✨ Add Material" 
                                      CssClass="primary-button" OnClick="btnSubmit_Click" />
                            
                            <!-- Status Message Panel (beside button) -->
                            <asp:Panel ID="pnlStatus" runat="server" Visible="false">
                                <div class="status-message">
                                    <i class="fas fa-check-circle me-2"></i>
                                    <asp:Label ID="lblStatus" runat="server" Text="" />
                                </div>
                            </asp:Panel>
                            
                            <!-- Error Message Panel (beside button) -->
                            <asp:Panel ID="pnlError" runat="server" Visible="false">
                                <div class="error-message">
                                    <i class="fas fa-exclamation-circle me-2"></i>
                                    <asp:Label ID="lblError" runat="server" Text="" />
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Book List Section -->
            <div class="glass-card">
                <div class="card-header">
                    <i class="fas fa-library"></i>
                    Your Learning Materials
                </div>
                <div class="card-body">
                    <asp:Label ID="lblBookStatus" runat="server" Text="" />
                    
                    <asp:Repeater ID="rptBooks" runat="server" OnItemCommand="rptBooks_ItemCommand">
                        <ItemTemplate>
                            <div class="book-card">
                                <div class="book-header">
                                    <div class="book-info">
                                        <h5><%# Eval("Title") %></h5>
                                        <small>by <%# Eval("Author") %></small>
                                        <span class="book-category"><%# Eval("Category") %></span>
                                        <%# !string.IsNullOrEmpty(Eval("Tag")?.ToString()) ? "<span class='book-tag'>#" + Eval("Tag") + "</span>" : "" %>
                                    </div>
                                    <button class="secondary-button" type="button" 
                                            data-bs-toggle="collapse" 
                                            data-bs-target="#book<%# Container.ItemIndex %>" 
                                            aria-expanded="false" 
                                            aria-controls="book<%# Container.ItemIndex %>">
                                        <i class="fas fa-cog"></i> Manage
                                    </button>
                                </div>
                                
                                <div class="collapse" id="book<%# Container.ItemIndex %>">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-8">
                                                <div class="edit-section">
                                                    <h6 class="mb-3">
                                                        <i class="fas fa-edit me-1"></i>
                                                        Edit Book Details
                                                    </h6>
                                                    <div class="form-grid">
                                                        <div class="form-group">
                                                            <label class="form-label">Title</label>
                                                            <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" 
                                                                       Text='<%# Eval("Title") %>' />
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="form-label">Author</label>
                                                            <asp:TextBox ID="txtEditAuthor" runat="server" CssClass="form-control" 
                                                                       Text='<%# Eval("Author") %>' />
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="form-label">Category</label>
                                                            <asp:DropDownList ID="ddlEditCategory" runat="server" CssClass="form-control">
                                                                <asp:ListItem Value="" Text="-- Select Category --" />
                                                                <asp:ListItem Value="Novels" Text="Novels" />
                                                                <asp:ListItem Value="Short stories" Text="Short stories" />
                                                                <asp:ListItem Value="Drama" Text="Drama/plays" />
                                                                <asp:ListItem Value="Poetry" Text="Poetry" />
                                                                <asp:ListItem Value="Fantasy" Text="Fantasy" />
                                                                <asp:ListItem Value="Science fiction" Text="Science fiction" />
                                                                <asp:ListItem Value="Mystery" Text="Mystery/Thriller" />
                                                                <asp:ListItem Value="Romance" Text="Romance" />
                                                                <asp:ListItem Value="Horror" Text="Horror" />
                                                                <asp:ListItem Value="Historical fiction" Text="Historical fiction" />
                                                                <asp:ListItem Value="Biography & Autobiography" Text="Biography & Autobiography" />
                                                                <asp:ListItem Value="Memoir" Text="Memoir" />
                                                                <asp:ListItem Value="Self-help" Text="Self-help" />
                                                                <asp:ListItem Value="History" Text="History" />
                                                                <asp:ListItem Value="Science & Technology" Text="Science & Technology" />
                                                                <asp:ListItem Value="Philosophy" Text="Philosophy" />
                                                                <asp:ListItem Value="Religion & Spirituality" Text="Religion & Spirituality" />
                                                                <asp:ListItem Value="Travel" Text="Travel" />
                                                                <asp:ListItem Value="Essays" Text="Essays" />
                                                                <asp:ListItem Value="Business & Economics" Text="Business & Economics" />
                                                                <asp:ListItem Value="Reference" Text="Reference" />
                                                            </asp:DropDownList>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="form-label">Tag</label>
                                                            <asp:TextBox ID="txtEditTag" runat="server" CssClass="form-control" 
                                                                       Text='<%# Eval("Tag") %>' />
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="form-label">Replace PDF (Optional)</label>
                                                            <asp:FileUpload ID="fileEditPdf" runat="server" CssClass="form-control" />
                                                            <div class="file-hint">
                                                                <i class="fas fa-info-circle"></i>
                                                                Maximum file size: 10 MB. Only PDF files are allowed.
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="col-md-4">
                                                <div class="edit-section">
                                                    <h6 class="mb-3">
                                                        <i class="fas fa-file-pdf me-1"></i>
                                                        Current PDF
                                                    </h6>
                                                    <asp:Panel ID="pnlPdfPreview" runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("PdfUrl").ToString()) %>'>
                                                        <a href='<%# Eval("PdfUrl") %>' target="_blank" class="secondary-button mb-3 d-block text-center">
                                                            <i class="fas fa-external-link-alt me-1"></i>
                                                            View PDF
                                                        </a>
                                                    </asp:Panel>
                                                    
                                                    <div class="action-buttons">
                                                        <asp:LinkButton ID="btnUpdate" runat="server" 
                                                                      CssClass="success-button" 
                                                                      CommandName="Update" 
                                                                      CommandArgument='<%# Eval("Id") %>'
                                                                      OnClientClick="return confirm('Update this book?');">
                                                            <i class="fas fa-save"></i> Update
                                                        </asp:LinkButton>
                                                        
                                                        <asp:LinkButton ID="btnDelete" runat="server" 
                                                                      CssClass="danger-button" 
                                                                      CommandName="Delete" 
                                                                      CommandArgument='<%# Eval("Id") %>'
                                                                      OnClientClick="return confirm('Are you sure you want to delete this book? This action cannot be undone.');">
                                                            <i class="fas fa-trash"></i> Delete
                                                        </asp:LinkButton>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoBooks" runat="server" Visible="false" CssClass="no-data-panel">
                        <i class="fas fa-book-open"></i>
                        <h4>No Learning Materials Found</h4>
                        <p>Upload your first educational resource using the form above!</p>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Modern JavaScript enhancements
        document.addEventListener('DOMContentLoaded', function () {
            // Auto-hide status messages
            setTimeout(function () {
                var statusMessages = document.querySelectorAll('.status-message, .error-message');
                statusMessages.forEach(function (message) {
                    message.style.opacity = '0';
                    message.style.transform = 'translateX(20px)';
                    message.style.transition = 'all 0.5s ease';
                    setTimeout(function () {
                        message.style.display = 'none';
                    }, 500);
                });
            }, 5000);

            // Enhanced hover effects for cards
            const cards = document.querySelectorAll('.book-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;

                card.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-5px)';
                    this.style.boxShadow = '0 15px 35px rgba(0, 0, 0, 0.15)';
                });

                card.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0)';
                    this.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.1)';
                });
            });

            // Form input focus effects
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.style.transform = 'scale(1.02)';
                    this.style.borderColor = '#667eea';
                    this.style.boxShadow = '0 0 0 3px rgba(103, 126, 234, 0.3)';
                });

                input.addEventListener('blur', function () {
                    this.style.transform = 'scale(1)';
                });
            });

            // PDF file validation
            const pdfInputs = document.querySelectorAll('input[type="file"]');
            pdfInputs.forEach(input => {
                input.addEventListener('change', function () {
                    const file = this.files[0];
                    if (file) {
                        // Check file type
                        if (file.type !== 'application/pdf') {
                            alert('Please select a PDF file only.');
                            this.value = '';
                            return;
                        }

                        // Check file size (10 MB = 10 * 1024 * 1024 bytes)
                        const maxSize = 10 * 1024 * 1024;
                        if (file.size > maxSize) {
                            alert('File size exceeds 10 MB limit. Please select a smaller file.');
                            this.value = '';
                            return;
                        }
                    }
                });
            });
        });
    </script>
</asp:Content>