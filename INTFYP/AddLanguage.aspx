<%@ Page Async="true" Title="Add Language" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="AddLanguage.aspx.cs" Inherits="INTFYP.AddLanguage" %>

<asp:Content ID="AddLanguageContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        /* Design System Implementation */
        :root {
            /* Color Palette */
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --accent-primary: #ff6b6b;
            --accent-secondary: #4ecdc4;
            --text-primary: #2c3e50;
            --text-secondary: #7f8c8d;
            --text-muted: #95a5a6;
            --light-text: rgba(255, 255, 255, 0.9);
            
            /* Glass Morphism */
            --glass-bg: rgba(255, 255, 255, 0.95);
            --glass-border: rgba(255, 255, 255, 0.2);
            --glass-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            
            /* Spacing System (8px base) */
            --space-xs: 8px;
            --space-sm: 15px;
            --space-md: 20px;
            --space-lg: 25px;
            --space-xl: 30px;
            --space-2xl: 40px;
            --space-3xl: 60px;
        }

        /* Typography */
        * {
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        }

        /* Glass Card Implementation */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            box-shadow: var(--glass-shadow);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            animation: slideInFromTop 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .glass-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
        }

        /* Form Sections */
        .form-section {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: var(--space-2xl);
            margin-bottom: var(--space-lg);
            border: 1px solid var(--glass-border);
            box-shadow: var(--glass-shadow);
            animation: fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .form-header {
            color: var(--text-primary);
            font-size: 28px;
            font-weight: 600;
            margin-bottom: var(--space-lg);
            padding-bottom: var(--space-sm);
            border-bottom: 1px solid rgba(255, 255, 255, 0.3);
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Form Controls with Glass Effect */
        .glass-input {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 15px;
            padding: 15px 20px;
            font-size: 16px;
            color: var(--text-primary);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            width: 100%;
        }

        .glass-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.3);
            outline: none;
            transform: scale(1.02);
        }

        .form-label {
            font-weight: 500;
            color: var(--text-primary);
            font-size: 14px;
            margin-bottom: var(--space-xs);
            display: block;
        }

        /* Primary Button with Design System */
        .primary-button {
            background: var(--primary-gradient);
            color: white;
            padding: 12px 24px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: none;
            cursor: pointer;
            font-size: 14px;
        }

        .primary-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
        }

        .primary-button:active {
            transform: scale(0.98);
        }

        /* Language Cards with Glass Morphism */
        .language-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            animation: slideInFromBottom 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            animation-delay: calc(var(--index) * 0.1s);
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
            animation: gradientSlide 3s ease-in-out infinite;
        }

        .language-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .language-header {
            padding: var(--space-lg);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
        }

        .language-info-wrapper {
            display: flex;
            align-items: center;
            flex: 1;
        }

        .language-flag {
            font-size: clamp(32px, 5vw, 48px);
            margin-right: var(--space-sm);
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1));
        }

        .language-info h5 {
            color: var(--text-primary);
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .language-info small {
            color: var(--text-secondary);
            font-size: 14px;
        }

        .language-category {
            background: linear-gradient(45deg, var(--accent-primary), var(--accent-secondary));
            color: white;
            font-size: 12px;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 500;
            margin-left: var(--space-xs);
            display: none; /* Hidden since no difficulty level */
        }

        /* Statistics Section */
        .language-stats {
            padding: var(--space-md);
        }

        .stat-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: var(--space-xs);
            padding: var(--space-xs) 0;
        }

        .stat-label {
            color: var(--text-secondary);
            font-weight: 500;
            font-size: 14px;
        }

        .stat-value {
            color: var(--text-primary);
            font-weight: 600;
            font-size: 16px;
        }

        /* Student Count Badge */
        .student-count-badge {
            background: var(--primary-gradient);
            color: white;
            padding: var(--space-sm) var(--space-md);
            border-radius: 20px;
            text-align: center;
            margin: var(--space-sm) 0;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
        }

        .student-count-badge::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            animation: shimmer 2s infinite;
        }

        /* Manage Button */
        .manage-button {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 15px;
            padding: var(--space-xs) var(--space-sm);
            color: var(--text-primary);
            font-weight: 500;
            font-size: 13px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .manage-button:hover {
            background: var(--primary-gradient);
            color: white;
            transform: scale(1.05);
        }

        /* Edit Section */
        .edit-section {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            backdrop-filter: blur(5px);
            border-radius: 15px;
            padding: var(--space-md);
            margin-top: var(--space-sm);
            border: 1px solid rgba(255,255,255,0.1);
        }

        /* Action Buttons */
        .action-buttons .btn {
            margin-right: var(--space-xs);
            border-radius: 15px;
            padding: var(--space-xs) var(--space-sm);
            font-weight: 500;
            font-size: 13px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .btn-success-glass {
            background: linear-gradient(45deg, #56ab2f, #a8e6cf);
            border: none;
            color: white;
        }

        .btn-info-glass {
            background: linear-gradient(45deg, #4ecdc4, #44a08d);
            border: none;
            color: white;
        }

        .btn-danger-glass {
            background: linear-gradient(45deg, #ff6b6b, #ee5a52);
            border: none;
            color: white;
        }

        .btn-success-glass:hover,
        .btn-info-glass:hover,
        .btn-danger-glass:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
        }

        /* Alert System */
        .alert-glass {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: var(--space-sm);
            margin-bottom: var(--space-md);
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

        /* Animations from Design System */
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

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(40px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes cardEntrance {
            from {
                opacity: 0;
                transform: translateY(50px) rotate(2deg);
            }
            to {
                opacity: 1;
                transform: translateY(0) rotate(0deg);
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

        /* Grid System */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: var(--space-xl);
        }

        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
                gap: var(--space-md);
            }
        }

        /* Form Layout */
        .form-row {
            display: flex;
            gap: var(--space-sm);
            margin-bottom: var(--space-md);
        }

        .form-group {
            flex: 1;
        }

        @media (max-width: 768px) {
            .form-row {
                flex-direction: column;
                gap: var(--space-xs);
            }
        }

        /* Staggered Animation for Cards */
        .language-card:nth-child(1) { animation-delay: 0.1s; }
        .language-card:nth-child(2) { animation-delay: 0.2s; }
        .language-card:nth-child(3) { animation-delay: 0.3s; }
        .language-card:nth-child(4) { animation-delay: 0.4s; }
        .language-card:nth-child(5) { animation-delay: 0.5s; }

        /* Utility Classes */
        .hover-lift {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .hover-lift:hover {
            transform: translateY(-8px);
        }

        .gradient-text {
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* No Languages State */
        .empty-state {
            text-align: center;
            padding: var(--space-3xl);
            color: var(--text-muted);
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: var(--space-md);
            opacity: 0.5;
        }
    </style>

    <!-- Alert Messages with Glass Effect -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div class="alert-glass" id="alertDiv" runat="server">
            <i class="fas fa-info-circle me-2"></i>
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </div>
    </asp:Panel>

    <!-- Add Language Form with Glass Morphism -->
    <div class="form-section">
        <h3 class="form-header">
            <i class="fas fa-plus-circle me-2"></i>
            Add New Language Course
        </h3>
        
        <div class="form-row">
            <div class="form-group">
                <label class="form-label">
                    <i class="fas fa-language me-1"></i>
                    Language Name
                </label>
                <asp:TextBox ID="txtLanguageName" runat="server" CssClass="glass-input" 
                           placeholder="e.g., Korean, Japanese, Spanish" />
            </div>
            
            <div class="form-group">
                <label class="form-label">
                    <i class="fas fa-code me-1"></i>
                    Language Code
                </label>
                <asp:TextBox ID="txtLanguageCode" runat="server" CssClass="glass-input" 
                           placeholder="e.g., KR, JP, ES" />
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">
                    <i class="fas fa-flag me-1"></i>
                    Flag Emoji
                </label>
                <asp:TextBox ID="txtFlag" runat="server" CssClass="glass-input" 
                           placeholder="e.g., 🇰🇷, 🇯🇵, 🇪🇸" />
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">
                <i class="fas fa-align-left me-1"></i>
                Description
            </label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="glass-input" 
                       TextMode="MultiLine" Rows="3" 
                       placeholder="Brief description of the language course..." />
        </div>

        <div class="d-flex justify-content-end mt-4">
            <asp:Button ID="btnAddLanguage" runat="server" Text="✨ Add Language Course" 
                      CssClass="primary-button" OnClick="btnAddLanguage_Click" />
        </div>
    </div>

    <!-- Language Courses Section -->
    <div class="form-section">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="form-header mb-0">
                <i class="fas fa-globe me-2"></i>
                Language Courses
            </h3>
            <asp:Button ID="btnRefreshLanguages" runat="server" Text="🔄 Refresh" 
                      CssClass="primary-button" OnClick="btnRefreshLanguages_Click" />
        </div>
        
        <div class="grid">
            <asp:Repeater ID="rptLanguages" runat="server" OnItemCommand="rptLanguages_ItemCommand">
                <ItemTemplate>
                    <div class="language-card glass-card">
                        <div class="language-header">
                            <div class="language-info-wrapper">
                                <div class="language-flag"><%# Eval("Flag") %></div>
                                <div class="language-info">
                                    <h5><%# Eval("Name") %></h5>
                                    <small><%# Eval("Description") %></small>
                                </div>
                            </div>
                            <button class="manage-button" type="button" 
                                    data-bs-toggle="collapse" 
                                    data-bs-target="#language<%# Container.ItemIndex %>" 
                                    aria-expanded="false">
                                <i class="fas fa-cog"></i> Manage
                            </button>
                        </div>
                        
                        <div class="language-stats">
                            <div class="stat-row">
                                <span class="stat-label">
                                    <i class="fas fa-code me-1"></i>Code:
                                </span>
                                <span class="stat-value"><%# Eval("Code") %></span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">
                                    <i class="fas fa-calendar me-1"></i>Created:
                                </span>
                                <span class="stat-value"><%# Eval("CreatedDate", "{0:MMM dd, yyyy}") %></span>
                            </div>
                            
                            <div class="student-count-badge">
                                <i class="fas fa-users me-2"></i>
                                <strong><%# Eval("StudentCount") %> Students Enrolled</strong>
                            </div>
                        </div>
                        
                        <div class="collapse" id="language<%# Container.ItemIndex %>">
                            <div class="p-3">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="edit-section">
                                            <h6 class="gradient-text mb-3">
                                                <i class="fas fa-edit me-1"></i>
                                                Edit Language Details
                                            </h6>
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label class="form-label">Language Name</label>
                                                    <asp:TextBox ID="txtEditLanguageName" runat="server" CssClass="glass-input" 
                                                               Text='<%# Eval("Name") %>' />
                                                </div>
                                                <div class="form-group">
                                                    <label class="form-label">Language Code</label>
                                                    <asp:TextBox ID="txtEditLanguageCode" runat="server" CssClass="glass-input" 
                                                               Text='<%# Eval("Code") %>' />
                                                </div>
                                            </div>
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label class="form-label">Flag Emoji</label>
                                                    <asp:TextBox ID="txtEditFlag" runat="server" CssClass="glass-input" 
                                                               Text='<%# Eval("Flag") %>' />
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="form-label">Description</label>
                                                <asp:TextBox ID="txtEditDescription" runat="server" CssClass="glass-input" 
                                                           TextMode="MultiLine" Rows="3" 
                                                           Text='<%# Eval("Description") %>' />
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-4">
                                        <div class="edit-section">
                                            <h6 class="gradient-text mb-3">
                                                <i class="fas fa-chart-bar me-1"></i>
                                                Course Statistics
                                            </h6>
                                            <div class="mb-3">
                                                <small class="text-muted d-block">Students Enrolled:</small>
                                                <div class="fs-3 fw-bold gradient-text"><%# Eval("StudentCount") %></div>
                                            </div>
                                            <div class="mb-4">
                                                <small class="text-muted d-block">Course Status:</small>
                                                <span class="badge" style="background: linear-gradient(45deg, #56ab2f, #a8e6cf); color: white;">
                                                    ✅ Active
                                                </span>
                                            </div>
                                            
                                            <div class="action-buttons d-grid gap-2">
                                                <asp:LinkButton ID="btnUpdate" runat="server" 
                                                              CssClass="btn btn-success-glass btn-sm" 
                                                              CommandName="UpdateLanguage" 
                                                              CommandArgument='<%# Eval("Id") %>'
                                                              OnClientClick="return confirm('Update this language course?');">
                                                    💾 Update Course
                                                </asp:LinkButton>
                                                
                                                <asp:LinkButton ID="btnViewStudents" runat="server" 
                                                              CssClass="btn btn-info-glass btn-sm" 
                                                              CommandName="ViewStudents" 
                                                              CommandArgument='<%# Eval("Id") %>'>
                                                    👥 View Students
                                                </asp:LinkButton>
                                                
                                                <asp:LinkButton ID="btnDelete" runat="server" 
                                                              CssClass="btn btn-danger-glass btn-sm" 
                                                              CommandName="DeleteLanguage" 
                                                              CommandArgument='<%# Eval("Id") %>'
                                                              OnClientClick="return confirm('⚠️ Delete this language course permanently?');">
                                                    🗑️ Delete Course
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
        </div>
        
        <asp:Panel ID="pnlNoLanguages" runat="server" Visible="false" CssClass="empty-state">
            <i class="fas fa-globe"></i>
            <h4>No Language Courses Found</h4>
            <p>Create your first language course using the form above</p>
        </asp:Panel>
    </div>

    <script>
        // Enhanced JavaScript with Design System Animations
        document.addEventListener('DOMContentLoaded', function () {
            // Auto-hide alerts with glass effect
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

            // Apply staggered animations to language cards
            const cards = document.querySelectorAll('.language-card');
            cards.forEach((card, index) => {
                card.style.setProperty('--index', index);
                card.style.animationDelay = `${index * 0.1}s`;
            });

            // Enhanced hover effects
            cards.forEach(card => {
                card.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-8px) scale(1.02)';
                    this.style.boxShadow = '0 20px 40px rgba(0, 0, 0, 0.15)';
                });

                card.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0) scale(1)';
                    this.style.boxShadow = 'var(--glass-shadow)';
                });
            });

            // Form input focus effects
            const inputs = document.querySelectorAll('.glass-input');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.parentElement.style.transform = 'scale(1.02)';
                    this.parentElement.style.transition = 'transform 0.3s cubic-bezier(0.4, 0, 0.2, 1)';
                });

                input.addEventListener('blur', function () {
                    this.parentElement.style.transform = 'scale(1)';
                });
            });

            // Bootstrap tooltip initialization with glass effect
            if (typeof bootstrap !== 'undefined' && bootstrap.Tooltip) {
                var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
                var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                    return new bootstrap.Tooltip(tooltipTriggerEl);
                });
            }

            // Add smooth scroll behavior
            document.documentElement.style.scrollBehavior = 'smooth';
        });

        // Page entrance animation
        window.addEventListener('load', function () {
            document.body.style.opacity = '1';
            document.body.style.transform = 'translateY(0)';
        });
    </script>

    <style>
        /* Page load animation */
        body {
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }
    </style>
</asp:Content>