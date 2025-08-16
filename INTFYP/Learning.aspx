<%@ Page Async="true" Title="Language Learning" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Learning.aspx.cs" Inherits="INTFYP.Learning" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Language Learning
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Design System Variables */
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --reverse-gradient: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            --success-gradient: linear-gradient(45deg, #56ab2f, #a8e6cf);
            --danger-gradient: linear-gradient(45deg, #ff6b6b, #ff8e8e);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --glass-border: rgba(255, 255, 255, 0.2);
            --text-primary: #2c3e50;
            --text-secondary: #7f8c8d;
            --text-muted: #95a5a6;
            --spacing-sm: 15px;
            --spacing-md: 20px;
            --spacing-lg: 25px;
            --spacing-xl: 30px;
        }

        /* Glass Card Effect */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
            border: 1px solid var(--glass-border);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .glass-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--primary-gradient);
        }

        .glass-card:hover {
            transform: translateY(-5px) scale(1.02);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
        }

        /* Page Header */
        .page-header {
            background: var(--primary-gradient);
            color: white;
            border-radius: 20px;
            padding: var(--spacing-xl);
            margin-bottom: var(--spacing-xl);
            text-align: center;
            animation: fadeInUp 0.6s ease;
        }

        /* Search Bar */
        .search-section {
            margin-bottom: var(--spacing-xl);
        }

        .search-input {
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            border-radius: 30px;
            padding: 15px 25px;
            font-size: 16px;
            width: 100%;
            transition: all 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
            transform: scale(1.02);
        }

        /* Language Cards */
        .language-card {
            background: var(--glass-bg);
            border-radius: 20px;
            border: 1px solid var(--glass-border);
            padding: var(--spacing-lg);
            height: 100%;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .language-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--primary-gradient);
        }

        .language-card:hover {
            transform: translateY(-8px) scale(1.05);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        /* Enrolled card styling */
        .language-card.enrolled::before {
            background: var(--success-gradient);
        }

        .language-card.enrolled {
            border-color: rgba(86, 171, 47, 0.3);
            background: rgba(86, 171, 47, 0.05);
        }

        .language-header {
            text-align: center;
            margin-bottom: var(--spacing-md);
        }

        .language-flag {
            font-size: 4rem;
            margin-bottom: var(--spacing-sm);
            filter: drop-shadow(0 4px 8px rgba(0,0,0,0.1));
        }

        .language-title {
            color: var(--text-primary);
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .language-code {
            color: var(--text-secondary);
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .language-description {
            color: var(--text-muted);
            font-size: 0.95rem;
            margin: var(--spacing-sm) 0;
            line-height: 1.5;
        }

        .enrollment-status {
            background: var(--success-gradient);
            color: white;
            padding: 8px 15px;
            border-radius: 15px;
            font-size: 0.85rem;
            text-align: center;
            margin: var(--spacing-sm) 0;
            font-weight: 500;
        }

        /* Action Buttons */
        .btn-action {
            border: none;
            border-radius: 25px;
            padding: 12px 24px;
            font-weight: 600;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            margin: 2px;
            cursor: pointer;
        }

        .btn-action:active {
            transform: scale(0.98);
        }

        .btn-join {
            background: var(--primary-gradient);
            color: white;
            width: 100%;
        }

        .btn-join:hover {
            background: var(--reverse-gradient);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .btn-start {
            background: var(--success-gradient);
            color: white;
            width: 48%;
        }

        .btn-start:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(86, 171, 47, 0.4);
        }

        .btn-quit {
            background: var(--danger-gradient);
            color: white;
            width: 48%;
        }

        .btn-quit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 107, 107, 0.4);
        }

        /* Alert System */
        .alert-glass {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: var(--spacing-sm) var(--spacing-md);
            margin-bottom: var(--spacing-md);
            border: 1px solid var(--glass-border);
            animation: slideInFromTop 0.5s ease;
        }

        .alert-success-glass {
            border-left: 4px solid #56ab2f;
            color: #2d5016;
        }

        .alert-danger-glass {
            border-left: 4px solid #ff6b6b;
            color: #721c24;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: var(--spacing-xl);
            color: var(--text-muted);
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: var(--spacing-md);
            opacity: 0.5;
        }

        /* Animations */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes slideInFromTop {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .page-header {
                padding: var(--spacing-md);
            }
            
            .page-header h1 {
                font-size: 2rem;
            }

            .btn-start, .btn-quit {
                width: 100%;
                margin-bottom: 5px;
            }
        }
    </style>

    <!-- Alert Messages -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div class="container">
            <div class="alert-glass" id="alertDiv" runat="server">
                <i class="fas fa-info-circle me-2"></i>
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </div>
        </div>
    </asp:Panel>

    <!-- Header -->
    <section class="page-header">
        <div class="container">
            <h1 class="display-4 fw-bold mb-3">
                <i class="fas fa-globe me-3"></i>
                Language Learning Classes
            </h1>
            <p class="lead fs-5">Join interactive language classes and start learning today</p>
        </div>
    </section>

    <div class="container">
        <!-- Search Bar -->
        <div class="search-section">
            <div class="glass-card p-3 d-flex align-items-center gap-3">
                <i class="fas fa-search text-muted"></i>
                <asp:TextBox ID="txtLanguageSearch" runat="server" 
                    CssClass="search-input flex-grow-1" 
                    placeholder="🔍 Search for language classes..."
                    AutoPostBack="true"
                    OnTextChanged="txtLanguageSearch_TextChanged"
                    style="border: none; background: transparent;"></asp:TextBox>
            </div>
        </div>

        <!-- Language Cards Grid -->
        <div class="row g-4" id="languageGrid">
            <asp:Repeater ID="rptLanguages" runat="server" OnItemCommand="rptLanguages_ItemCommand" OnItemDataBound="rptLanguages_ItemDataBound">
                <ItemTemplate>
                    <div class="col-md-6 col-lg-4">
                        <div class="language-card glass-card <%# (bool)Eval("IsEnrolled") ? "enrolled" : "" %>">
                            <div class="language-header">
                                <div class="language-flag"><%# Eval("Flag") %></div>
                                <h3 class="language-title"><%# Eval("Name") %></h3>
                                <p class="language-code"><%# Eval("Code") %></p>
                            </div>
                            
                            <p class="language-description"><%# Eval("Description") %></p>
                            
                            <!-- Action Buttons Area -->
                            <div class="mt-4">
                                <!-- Join Button (shown when not enrolled) -->
                                <asp:Panel ID="pnlJoinButton" runat="server" CssClass="d-grid">
                                    <asp:Button ID="btnJoinClass" runat="server" 
                                              CssClass="btn-action btn-join" 
                                              CommandName="JoinClass" 
                                              CommandArgument='<%# Eval("DocumentId") %>' 
                                              Text="🚀 Join Class" />
                                </asp:Panel>
                                
                                <!-- Enrolled Actions (shown when enrolled) -->
                                <asp:Panel ID="pnlEnrolledActions" runat="server" Visible="false" 
                                          CssClass="enrolled-panel">
                                    <div class="enrollment-status mb-3">
                                        <i class="fas fa-check-circle me-2"></i>
                                        You're enrolled!
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <asp:Button ID="btnStartLearning" runat="server" 
                                                  CssClass="btn-action btn-start" 
                                                  CommandName="StartLearning" 
                                                  CommandArgument='<%# Eval("DocumentId") %>' 
                                                  Text="📚 Start Learning" />
                                        <asp:Button ID="btnQuitClass" runat="server" 
                                                  CssClass="btn-action btn-quit" 
                                                  CommandName="QuitClass" 
                                                  CommandArgument='<%# Eval("DocumentId") %>' 
                                                  Text="❌ Quit Class"
                                                  OnClientClick="return confirm('Are you sure you want to quit this class?');" />
                                    </div>
                                </asp:Panel>
                            </div>
                            
                            <div class="mt-2 text-center">
                                <small class="text-muted">
                                    <i class="fas fa-calendar me-1"></i>
                                    Created <%# Eval("CreatedDate", "{0:MMM yyyy}") %>
                                </small>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        
        <!-- Empty State -->
        <asp:Panel ID="pnlNoLanguages" runat="server" Visible="false">
            <div class="glass-card">
                <div class="empty-state">
                    <i class="fas fa-globe"></i>
                    <h4>No Language Classes Available</h4>
                    <p>Check back later for new language classes!</p>
                </div>
            </div>
        </asp:Panel>
    </div>

    <script>
        // Auto-hide alerts
        document.addEventListener('DOMContentLoaded', function () {
            setTimeout(function () {
                var alert = document.querySelector('.alert-glass');
                if (alert) {
                    alert.style.opacity = '0';
                    alert.style.transform = 'translateY(-20px)';
                    alert.style.transition = 'all 0.5s ease';
                    setTimeout(function () {
                        alert.style.display = 'none';
                    }, 500);
                }
            }, 5000);

            // Enhanced card animations
            const cards = document.querySelectorAll('.language-card');
            cards.forEach((card, index) => {
                card.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-8px) scale(1.05)';
                });

                card.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0) scale(1)';
                });
            });
        });
    </script>
</asp:Content>