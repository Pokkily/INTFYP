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
            --accent-gradient: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            --success-gradient: linear-gradient(45deg, #56ab2f, #a8e6cf);
            --danger-gradient: linear-gradient(45deg, #ff6b6b, #ff8e8e);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --glass-border: rgba(255, 255, 255, 0.2);
            --text-primary: #2c3e50;
            --text-secondary: #7f8c8d;
            --text-muted: #95a5a6;
            --spacing-xs: 8px;
            --spacing-sm: 15px;
            --spacing-md: 20px;
            --spacing-lg: 25px;
            --spacing-xl: 30px;
            --spacing-2xl: 40px;
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
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
        }

        /* Page Header */
        .page-header {
            background: var(--primary-gradient);
            color: rgba(255, 255, 255, 0.9);
            border-radius: 20px;
            padding: var(--spacing-2xl);
            margin-bottom: var(--spacing-xl);
            text-align: center;
            animation: fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .page-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
            animation: shimmer 3s infinite;
        }

        /* Search Bar */
        .search-section {
            margin-bottom: var(--spacing-xl);
        }

        .glass-input {
            background: var(--glass-bg);
            backdrop-filter: blur(5px);
            border: 1px solid var(--glass-border);
            border-radius: 30px;
            padding: 15px 25px;
            font-size: 16px;
            width: 100%;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .glass-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
            transform: scale(1.02);
        }

        /* Language Cards */
        .language-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            border: 1px solid var(--glass-border);
            padding: var(--spacing-lg);
            height: 100%;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            animation: slideInFromBottom 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            animation-fill-mode: both;
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
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
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
            margin-bottom: var(--spacing-xs);
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

        .student-count {
            background: linear-gradient(45deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            color: var(--text-primary);
            padding: var(--spacing-xs) var(--spacing-sm);
            border-radius: 15px;
            font-size: 0.85rem;
            text-align: center;
            margin: var(--spacing-sm) 0;
            font-weight: 500;
        }

        /* Enrollment Status */
        .enrollment-status {
            background: linear-gradient(45deg, rgba(86, 171, 47, 0.1), rgba(168, 230, 207, 0.1));
            color: var(--text-primary);
            padding: var(--spacing-xs) var(--spacing-sm);
            border-radius: 15px;
            font-size: 0.85rem;
            text-align: center;
            margin: var(--spacing-xs) 0;
            font-weight: 500;
            border: 1px solid rgba(86, 171, 47, 0.2);
        }

        /* Button Styles */
        .btn-join {
            background: var(--primary-gradient);
            color: white;
            border: none;
            border-radius: 25px;
            padding: 12px 24px;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .btn-join:hover {
            background: var(--reverse-gradient);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .btn-join:active {
            transform: scale(0.98);
        }

        .btn-learn {
            background: var(--success-gradient);
            color: white;
            border: none;
            border-radius: 25px;
            padding: 12px 24px;
            font-weight: 600;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            margin-bottom: var(--spacing-xs);
        }

        .btn-learn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(86, 171, 47, 0.4);
        }

        .btn-quit {
            background: var(--danger-gradient);
            color: white;
            border: none;
            border-radius: 25px;
            padding: 10px 24px;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .btn-quit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 107, 107, 0.4);
        }

        .btn-quit:active {
            transform: scale(0.98);
        }

        /* Enrolled Actions Container */
        .enrolled-actions {
            display: flex;
            flex-direction: column;
            gap: var(--spacing-xs);
        }

        /* Alert System */
        .alert-glass {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: var(--spacing-sm) var(--spacing-md);
            margin-bottom: var(--spacing-md);
            border: 1px solid var(--glass-border);
            animation: slideInFromTop 0.5s cubic-bezier(0.4, 0, 0.2, 1);
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
            padding: var(--spacing-2xl);
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

        @keyframes slideInFromBottom {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes shimmer {
            0% { left: -100%; }
            100% { left: 100%; }
        }

        /* Staggered Animation */
        .language-card:nth-child(1) { animation-delay: 0.1s; }
        .language-card:nth-child(2) { animation-delay: 0.2s; }
        .language-card:nth-child(3) { animation-delay: 0.3s; }
        .language-card:nth-child(4) { animation-delay: 0.4s; }
        .language-card:nth-child(5) { animation-delay: 0.5s; }
        .language-card:nth-child(6) { animation-delay: 0.6s; }

        /* Responsive Design */
        @media (max-width: 768px) {
            .page-header {
                padding: var(--spacing-md);
            }
            
            .page-header h1 {
                font-size: 2rem;
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
                Language Learning
            </h1>
            <p class="lead fs-5">Master new languages with interactive courses</p>
        </div>
    </section>

    <div class="container">
        <!-- Search Bar -->
        <div class="search-section">
            <div class="glass-card p-3 d-flex align-items-center gap-3">
                <i class="fas fa-search text-muted"></i>
                <input type="text" id="searchInput" class="glass-input flex-grow-1" 
                       placeholder="🔍 Search for languages to learn..." 
                       style="border: none; background: transparent;">
            </div>
        </div>

        <!-- Language Cards Grid -->
        <div class="row g-4" id="languageGrid">
            <asp:Repeater ID="rptLanguages" runat="server" OnItemCommand="rptLanguages_ItemCommand">
                <ItemTemplate>
                    <div class="col-md-6 col-lg-4 language-item" 
                         data-name="<%# Eval("Name").ToString().ToLower() %>" 
                         data-code="<%# Eval("Code").ToString().ToLower() %>">
                        <div class="language-card glass-card">
                            <div class="language-header">
                                <div class="language-flag"><%# Eval("Flag") %></div>
                                <h3 class="language-title"><%# Eval("Name") %></h3>
                                <p class="language-code"><%# Eval("Code") %></p>
                            </div>
                            
                            <p class="language-description"><%# Eval("Description") %></p>
                            
                            <div class="student-count">
                                <i class="fas fa-users me-2"></i>
                                <%# Eval("StudentCount") %> students joined
                            </div>

                            <div class="student-count" style="font-size: 0.8rem; margin-top: 5px; opacity: 0.8;">
                                <i class="fas fa-chart-line me-1"></i>
                                <%# Eval("JoinCount") %> total joins
                            </div>
                            
                            <!-- Action Buttons -->
                            <div class="mt-4">
                                <!-- Show Join button if not enrolled -->
                                <asp:Panel ID="pnlJoinButton" runat="server" Visible='<%# !IsStudentEnrolled(Eval("Id").ToString()) %>'>
                                    <div class="d-grid">
                                        <asp:Button ID="btnJoinLanguage" runat="server" 
                                                  CssClass="btn-join" 
                                                  CommandName="JoinLanguage" 
                                                  CommandArgument='<%# Eval("Id") %>' 
                                                  Text="🚀 Join Course" />
                                    </div>
                                </asp:Panel>

                                <!-- Show Learn and Quit buttons if enrolled -->
                                <asp:Panel ID="pnlEnrolledButtons" runat="server" Visible='<%# IsStudentEnrolled(Eval("Id").ToString()) %>'>
                                    <div class="enrolled-actions">
                                        <asp:Button ID="btnLearnLanguage" runat="server" 
                                                  CssClass="btn-learn w-100" 
                                                  CommandName="LearnLanguage" 
                                                  CommandArgument='<%# Eval("Id") %>' 
                                                  Text="📚 Start Learning" />
                                        <asp:Button ID="btnQuitLanguage" runat="server" 
                                                  CssClass="btn-quit w-100" 
                                                  CommandName="QuitLanguage" 
                                                  CommandArgument='<%# Eval("Id") %>' 
                                                  Text="❌ Quit Course"
                                                  OnClientClick="return confirm('Are you sure you want to quit this course?');" />
                                    </div>
                                </asp:Panel>
                            </div>
                            
                            <div class="mt-2 text-center">
                                <small class="text-muted">
                                    <i class="fas fa-calendar me-1"></i>
                                    Added <%# Eval("CreatedDate", "{0:MMM yyyy}") %>
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
                    <h4>No Language Courses Available</h4>
                    <p>Check back later for new language courses!</p>
                </div>
            </div>
        </asp:Panel>
    </div>

    <script>
        // Search functionality
        document.addEventListener('DOMContentLoaded', function () {
            const searchInput = document.getElementById('searchInput');
            const languageItems = document.querySelectorAll('.language-item');

            searchInput.addEventListener('input', function () {
                const searchTerm = this.value.toLowerCase();

                languageItems.forEach(item => {
                    const name = item.getAttribute('data-name');
                    const code = item.getAttribute('data-code');
                    const isVisible = name.includes(searchTerm) || code.includes(searchTerm);

                    if (isVisible) {
                        item.style.display = 'block';
                        item.style.animation = 'fadeInUp 0.3s ease-out';
                    } else {
                        item.style.display = 'none';
                    }
                });
            });

            // Auto-hide alerts
            setTimeout(function () {
                var alert = document.querySelector('.alert-glass');
                if (alert) {
                    alert.style.opacity = '0';
                    alert.style.transform = 'translateY(-20px)';
                    alert.style.transition = 'all 0.5s cubic-bezier(0.4, 0, 0.2, 1)';
                    setTimeout(function () {
                        alert.style.display = 'none';
                    }, 500);
                }
            }, 5000);

            // Enhanced card animations
            const cards = document.querySelectorAll('.language-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;

                card.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-8px) scale(1.05)';
                });

                card.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0) scale(1)';
                });
            });

            // Search input focus effect
            searchInput.addEventListener('focus', function () {
                this.parentElement.style.transform = 'scale(1.02)';
                this.parentElement.style.boxShadow = '0 12px 30px rgba(102, 126, 234, 0.2)';
            });

            searchInput.addEventListener('blur', function () {
                this.parentElement.style.transform = 'scale(1)';
                this.parentElement.style.boxShadow = '0 8px 20px rgba(0, 0, 0, 0.15)';
            });
        });

        // Smooth animations
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </script>
</asp:Content>