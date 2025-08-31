<%@ Page Async="true" Title="Add Language" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="AddLanguage.aspx.cs" Inherits="INTFYP.AddLanguage" %>

<asp:Content ID="AddLanguageContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        /* Modern Design System Implementation */
        .add-language-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
        }

        .languages-container {
            max-width: 1400px;
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
            text-decoration: none;
        }

        .success-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(86, 171, 47, 0.3);
            color: white;
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
            text-decoration: none;
        }

        .danger-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 107, 107, 0.3);
            color: white;
        }

        /* Language Card Styles */
        .language-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.3s ease;
            position: relative;
            animation: slideInFromLeft 0.6s ease-out;
            margin-bottom: 20px;
        }

        .language-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            animation: gradientSlide 3s ease-in-out infinite;
        }

        .language-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .language-header {
            padding: 25px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .language-info-wrapper {
            display: flex;
            align-items: center;
            flex: 1;
        }

        .language-flag {
            font-size: clamp(32px, 5vw, 48px);
            margin-right: 15px;
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1));
        }

        .language-info h5 {
            color: #2c3e50;
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .language-info small {
            color: #7f8c8d;
            font-size: 14px;
        }

        /* Language Details Section */
        .language-details {
            padding: 20px 25px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            padding: 10px 0;
        }

        .detail-label {
            color: #7f8c8d;
            font-weight: 500;
            font-size: 14px;
        }

        .detail-value {
            color: #2c3e50;
            font-weight: 600;
            font-size: 16px;
        }



        /* Edit Section */
        .edit-section {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            backdrop-filter: blur(5px);
            border-radius: 15px;
            padding: 20px;
            margin-top: 15px;
            border: 1px solid rgba(255,255,255,0.1);
        }

        .edit-section h6 {
            color: #2c3e50;
            font-weight: 600;
            margin-bottom: 15px;
        }

        /* Action Buttons */
        .action-buttons {
            display: grid;
            gap: 10px;
            margin-top: 15px;
        }

        /* Form Grid */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            position: relative;
        }

        /* Alert Messages */
        .alert-message {
            background: rgba(86, 171, 47, 0.1);
            border: 1px solid rgba(86, 171, 47, 0.3);
            color: #2d5016;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            animation: slideInFromTop 0.5s ease-out;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-danger {
            background: rgba(255, 107, 107, 0.1);
            border-color: rgba(255, 107, 107, 0.3);
            color: #721c24;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #7f8c8d;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            backdrop-filter: blur(5px);
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        /* Grid Layout for Language Cards */
        .languages-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 25px;
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

        @keyframes shimmer {
            0% { left: -100%; }
            100% { left: 100%; }
        }

        @keyframes gradientSlide {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .languages-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .language-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .action-buttons {
                grid-template-columns: 1fr;
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
        .me-1 { margin-right: 5px; }
        .me-2 { margin-right: 10px; }
    </style>

    <div class="add-language-page">
        <div class="languages-container">
            <div class="page-header">
                <h2 class="page-title">🌍 Language Course Manager</h2>
                <p class="page-subtitle">Create and manage international language learning programs</p>
            </div>

            <!-- Alert Messages -->
            <asp:Panel ID="pnlAlert" runat="server" Visible="false">
                <div class="alert-message" id="alertDiv" runat="server">
                    <i class="fas fa-info-circle"></i>
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </div>
            </asp:Panel>

            <!-- Add Language Form -->
            <div class="glass-card">
                <div class="card-header">
                    <i class="fas fa-plus-circle"></i>
                    Add New Language Course
                </div>
                <div class="card-body">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-language me-1"></i>
                                Language Name
                            </label>
                            <asp:TextBox ID="txtLanguageName" runat="server" CssClass="form-control" 
                                       placeholder="e.g., Korean, Japanese, Spanish" />
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-code me-1"></i>
                                Language Code
                            </label>
                            <asp:TextBox ID="txtLanguageCode" runat="server" CssClass="form-control" 
                                       placeholder="e.g., KR, JP, ES" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-flag me-1"></i>
                                Flag Emoji
                            </label>
                            <asp:TextBox ID="txtFlag" runat="server" CssClass="form-control" 
                                       placeholder="e.g., 🇰🇷, 🇯🇵, 🇪🇸" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-align-left me-1"></i>
                                Description
                            </label>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" 
                                       TextMode="MultiLine" Rows="3" 
                                       placeholder="Brief description of the language course..." />
                        </div>
                    </div>

                    <div class="d-flex justify-content-end mt-4">
                        <asp:Button ID="btnAddLanguage" runat="server" Text="✨ Add Language Course" 
                                  CssClass="primary-button" OnClick="btnAddLanguage_Click" />
                    </div>
                </div>
            </div>

            <!-- Language Courses Section -->
            <div class="glass-card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-globe me-2"></i>
                        Language Courses
                    </div>
                </div>
                <div class="card-body">
                    <div class="languages-grid">
                        <asp:Repeater ID="rptLanguages" runat="server" OnItemCommand="rptLanguages_ItemCommand">
                            <ItemTemplate>
                                <div class="language-card">
                                    <div class="language-header">
                                        <div class="language-info-wrapper">
                                            <div class="language-flag"><%# Eval("Flag") %></div>
                                            <div class="language-info">
                                                <h5><%# Eval("Name") %></h5>
                                                <small><%# Eval("Description") %></small>
                                            </div>
                                        </div>
                                        <button class="secondary-button" type="button" 
                                                data-bs-toggle="collapse" 
                                                data-bs-target="#language<%# Container.ItemIndex %>" 
                                                aria-expanded="false">
                                            <i class="fas fa-cog"></i> Manage
                                        </button>
                                    </div>
                                    
                                    <div class="language-details">
                                        <div class="detail-row">
                                            <span class="detail-label">
                                                <i class="fas fa-code me-1"></i>Code:
                                            </span>
                                            <span class="detail-value"><%# Eval("Code") %></span>
                                        </div>
                                        <div class="detail-row">
                                            <span class="detail-label">
                                                <i class="fas fa-calendar me-1"></i>Created:
                                            </span>
                                            <span class="detail-value"><%# Eval("CreatedDate", "{0:MMM dd, yyyy}") %></span>
                                        </div>
                                        
                                        <div class="status-badge">
                                            <i class="fas fa-check-circle me-2"></i>
                                        </div>
                                    </div>
                                    
                                    <div class="collapse" id="language<%# Container.ItemIndex %>">
                                        <div class="card-body">
                                            <div class="edit-section">
                                                <h6 class="mb-3">
                                                    <i class="fas fa-edit me-1"></i>
                                                    Edit Language Details
                                                </h6>
                                                <div class="form-grid">
                                                    <div class="form-group">
                                                        <label class="form-label">Language Name</label>
                                                        <asp:TextBox ID="txtEditLanguageName" runat="server" CssClass="form-control" 
                                                                   Text='<%# Eval("Name") %>' />
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Language Code</label>
                                                        <asp:TextBox ID="txtEditLanguageCode" runat="server" CssClass="form-control" 
                                                                   Text='<%# Eval("Code") %>' />
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Flag Emoji</label>
                                                        <asp:TextBox ID="txtEditFlag" runat="server" CssClass="form-control" 
                                                                   Text='<%# Eval("Flag") %>' />
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Description</label>
                                                        <asp:TextBox ID="txtEditDescription" runat="server" CssClass="form-control" 
                                                                   TextMode="MultiLine" Rows="3" 
                                                                   Text='<%# Eval("Description") %>' />
                                                    </div>
                                                </div>
                                                
                                                <div class="action-buttons">
                                                    <asp:LinkButton ID="btnUpdate" runat="server" 
                                                                  CssClass="success-button" 
                                                                  CommandName="UpdateLanguage" 
                                                                  CommandArgument='<%# Eval("Id") %>'
                                                                  OnClientClick="return confirm('Update this language course?');">
                                                        <i class="fas fa-save"></i> Update Course
                                                    </asp:LinkButton>
                                                    
                                                    <asp:LinkButton ID="btnDelete" runat="server" 
                                                                  CssClass="danger-button" 
                                                                  CommandName="DeleteLanguage" 
                                                                  CommandArgument='<%# Eval("Id") %>'
                                                                  OnClientClick="return confirm('⚠️ Delete this language course permanently?');">
                                                        <i class="fas fa-trash"></i> Delete Course
                                                    </asp:LinkButton>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    
                    <asp:Panel ID="pnlNoLanguages" runat="server" Visible="false" CssClass="empty-state">
                        <i class="fas fa-globe"></i>
                        <h4>No Language Courses Found</h4>
                        <p>Create your first language course using the form above</p>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Modern JavaScript enhancements
        document.addEventListener('DOMContentLoaded', function () {
            // Auto-hide alerts
            setTimeout(function () {
                var alert = document.querySelector('.alert-message');
                if (alert) {
                    alert.style.opacity = '0';
                    alert.style.transform = 'translateY(-20px)';
                    alert.style.transition = 'all 0.5s ease';
                    setTimeout(function () {
                        alert.style.display = 'none';
                    }, 500);
                }
            }, 5000);

            // Apply staggered animations to language cards
            const cards = document.querySelectorAll('.language-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;

                card.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-8px) scale(1.02)';
                    this.style.boxShadow = '0 20px 40px rgba(0, 0, 0, 0.15)';
                });

                card.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0) scale(1)';
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

            // Add smooth scroll behavior
            document.documentElement.style.scrollBehavior = 'smooth';
        });
    </script>
</asp:Content>