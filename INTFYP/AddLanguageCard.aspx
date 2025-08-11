<%@ Page Async="true" Title="Language Lesson Management" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="AddLanguageCard.aspx.cs" Inherits="INTFYP.AddLanguageCard" %>

<asp:Content ID="LanguageCardContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    
    <style>
        /* Design System Implementation */
        :root {
            /* Color Palette */
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --accent-primary: #ff6b6b;
            --accent-secondary: #4ecdc4;
            --success-gradient: linear-gradient(135deg, #56ab2f 0%, #a8e6cf 100%);
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

        /* Body Background */
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* Glass Card Implementation */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            box-shadow: var(--glass-shadow);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            animation: slideInFromBottom 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            animation-fill-mode: both;
        }

        .glass-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
            cursor: pointer;
        }

        /* Page Header */
        .page-header {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: var(--space-2xl);
            margin-bottom: var(--space-xl);
            border: 1px solid var(--glass-border);
            box-shadow: var(--glass-shadow);
            text-align: center;
            animation: slideInFromTop 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .page-title {
            color: var(--text-primary);
            font-size: 32px;
            font-weight: 700;
            margin-bottom: var(--space-sm);
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .page-subtitle {
            color: var(--text-secondary);
            font-size: 16px;
            margin-bottom: 0;
        }

        /* Language Selection Cards */
        .language-selection-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: var(--space-xl);
            margin-bottom: var(--space-lg);
            box-shadow: var(--glass-shadow);
            animation: fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .section-header {
            color: var(--text-primary);
            font-size: 24px;
            font-weight: 600;
            margin-bottom: var(--space-lg);
            padding-bottom: var(--space-sm);
            border-bottom: 1px solid rgba(255, 255, 255, 0.3);
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Language Cards */
        .language-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            cursor: pointer;
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

        .lesson-count-badge {
            background: var(--success-gradient);
            color: white;
            padding: var(--space-sm) var(--space-md);
            border-radius: 20px;
            text-align: center;
            margin: var(--space-sm) 0;
            box-shadow: 0 4px 15px rgba(86, 171, 47, 0.3);
            position: relative;
            overflow: hidden;
        }

        .lesson-count-badge::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            animation: shimmer 2s infinite;
        }

        /* Lesson Cards */
        .lesson-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 15px;
            padding: var(--space-lg);
            margin-bottom: var(--space-md);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .lesson-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--accent-primary);
        }

        .lesson-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
        }

        .lesson-title {
            color: var(--text-primary);
            font-size: 18px;
            font-weight: 600;
            margin-bottom: var(--space-xs);
        }

        .lesson-description {
            color: var(--text-secondary);
            font-size: 14px;
            margin-bottom: var(--space-sm);
        }

        .lesson-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: var(--text-muted);
            font-size: 12px;
        }

        .difficulty-badge {
            padding: 4px 8px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 500;
        }

        .difficulty-beginner {
            background: linear-gradient(45deg, #56ab2f, #a8e6cf);
            color: white;
        }

        .difficulty-intermediate {
            background: linear-gradient(45deg, #f7971e, #ffd200);
            color: white;
        }

        .difficulty-advanced {
            background: linear-gradient(45deg, #ff6b6b, #ee5a52);
            color: white;
        }

        /* Question Cards */
        .question-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 15px;
            padding: var(--space-lg);
            margin-bottom: var(--space-md);
            animation: fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            animation-delay: calc(var(--index) * 0.1s);
            animation-fill-mode: both;
        }

        .question-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-sm);
        }

        .question-number {
            background: var(--primary-gradient);
            color: white;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 14px;
        }

        .question-type {
            background: linear-gradient(45deg, var(--accent-secondary), #44a08d);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .question-text {
            color: var(--text-primary);
            font-size: 16px;
            font-weight: 500;
            margin-bottom: var(--space-sm);
        }

        .answer-option {
            background: rgba(255, 255, 255, 0.5);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 10px;
            padding: var(--space-sm);
            margin-bottom: var(--space-xs);
            color: var(--text-primary);
            transition: all 0.3s ease;
        }

        .answer-option.correct {
            background: linear-gradient(45deg, #56ab2f, #a8e6cf);
            color: white;
            border-color: #56ab2f;
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

        /* Back Button */
        .back-button {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 15px;
            padding: var(--space-sm) var(--space-md);
            color: var(--text-primary);
            font-weight: 500;
            font-size: 14px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            margin-bottom: var(--space-lg);
            display: inline-block;
        }

        .back-button:hover {
            background: var(--primary-gradient);
            color: white;
            transform: scale(1.05);
            text-decoration: none;
        }

        /* Empty State */
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

        /* Staggered Animation for Cards */
        .language-card:nth-child(1) { animation-delay: 0.1s; }
        .language-card:nth-child(2) { animation-delay: 0.2s; }
        .language-card:nth-child(3) { animation-delay: 0.3s; }
        .language-card:nth-child(4) { animation-delay: 0.4s; }
        .language-card:nth-child(5) { animation-delay: 0.5s; }

        .question-card:nth-child(1) { animation-delay: 0.1s; }
        .question-card:nth-child(2) { animation-delay: 0.2s; }
        .question-card:nth-child(3) { animation-delay: 0.3s; }
        .question-card:nth-child(4) { animation-delay: 0.4s; }
        .question-card:nth-child(5) { animation-delay: 0.5s; }
    </style>

    <div class="container-fluid py-4">
            <!-- Page Header -->
            <div class="page-header">
                <h1 class="page-title">
                    <i class="fas fa-chalkboard-teacher me-2"></i>
                    Language Lesson Management
                </h1>
                <p class="page-subtitle">Manage and preview language courses, lessons, and questions</p>
            </div>

            <!-- Alert Messages -->
            <asp:Panel ID="pnlAlert" runat="server" Visible="false">
                <div class="alert-glass" id="alertDiv" runat="server">
                    <i class="fas fa-info-circle me-2"></i>
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </div>
            </asp:Panel>

            <!-- Back Button (for lesson and question views) -->
            <asp:Panel ID="pnlBackButton" runat="server" Visible="false">
                <asp:LinkButton ID="btnBack" runat="server" CssClass="back-button" OnClick="btnBack_Click">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </asp:LinkButton>
            </asp:Panel>

            <!-- Language Selection View -->
            <asp:Panel ID="pnlLanguages" runat="server" Visible="true">
                <div class="language-selection-card">
                    <h3 class="section-header">
                        <i class="fas fa-globe me-2"></i>
                        Language Courses Overview
                    </h3>
                    
                    <div class="grid">
                        <asp:Repeater ID="rptLanguages" runat="server" OnItemCommand="rptLanguages_ItemCommand">
                            <ItemTemplate>
                                <div class="language-card" onclick="selectLanguage('<%# Eval("Id") %>')">
                                    <div class="language-header">
                                        <div class="language-info-wrapper">
                                            <div class="language-flag"><%# Eval("Flag") %></div>
                                            <div class="language-info">
                                                <h5><%# Eval("Name") %></h5>
                                                <small><%# Eval("Description") %></small>
                                            </div>
                                        </div>
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
                                                <i class="fas fa-book me-1"></i>Difficulty:
                                            </span>
                                            <span class="stat-value"><%# Eval("Difficulty") %></span>
                                        </div>
                                        
                                        <div class="lesson-count-badge">
                                            <i class="fas fa-book-open me-2"></i>
                                            <strong><%# Eval("LessonCount") %> Lessons Available</strong>
                                        </div>
                                    </div>
                                    
                                    <asp:HiddenField ID="hdnLanguageId" runat="server" Value='<%# Eval("Id") %>' />
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:Panel ID="pnlNoLanguages" runat="server" Visible="false" CssClass="empty-state">
                            <i class="fas fa-globe"></i>
                            <h4>No Language Courses Found</h4>
                            <p>Create your first language course to get started with lesson management</p>
                        </asp:Panel>
                    </div>
                </div>
            </asp:Panel>

            <!-- Lessons View -->
            <asp:Panel ID="pnlLessons" runat="server" Visible="false">
                <div class="language-selection-card">
                    <h3 class="section-header">
                        <asp:Label ID="lblSelectedLanguage" runat="server"></asp:Label>
                        <span class="ms-2">Lessons</span>
                    </h3>
                    
                    <div class="row">
                        <asp:Repeater ID="rptLessons" runat="server" OnItemCommand="rptLessons_ItemCommand">
                            <ItemTemplate>
                                <div class="col-md-6 col-lg-4 mb-3">
                                    <div class="lesson-card" onclick="selectLesson('<%# Eval("Id") %>')">
                                        <div class="lesson-title">
                                            <i class="fas fa-book-open me-2"></i>
                                            <%# Eval("Title") %>
                                        </div>
                                        <div class="lesson-description">
                                            <%# Eval("Description") %>
                                        </div>
                                        <div class="lesson-meta">
                                            <span>
                                                <i class="fas fa-question-circle me-1"></i>
                                                <%# Eval("QuestionCount") %> Questions
                                            </span>
                                            <span class="difficulty-badge difficulty-<%# Eval("Difficulty").ToString().ToLower() %>">
                                                <%# Eval("Difficulty") %>
                                            </span>
                                        </div>
                                        <asp:HiddenField ID="hdnLessonId" runat="server" Value='<%# Eval("Id") %>' />
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:Panel ID="pnlNoLessons" runat="server" Visible="false" CssClass="empty-state col-12">
                            <i class="fas fa-book-open"></i>
                            <h4>No Lessons Created</h4>
                            <p>Add lessons to this language course to help students learn effectively</p>
                        </asp:Panel>
                    </div>
                </div>
            </asp:Panel>

            <!-- Questions View -->
            <asp:Panel ID="pnlQuestions" runat="server" Visible="false">
                <div class="language-selection-card">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3 class="section-header mb-0">
                            <asp:Label ID="lblSelectedLesson" runat="server"></asp:Label>
                            <span class="ms-2">Questions</span>
                        </h3>
                        <div class="text-muted">
                            <i class="fas fa-clock me-1"></i>
                            <asp:Label ID="lblQuestionCount" runat="server"></asp:Label>
                        </div>
                    </div>
                    
                    <asp:Repeater ID="rptQuestions" runat="server">
                        <ItemTemplate>
                            <div class="question-card">
                                <div class="question-header">
                                    <div class="question-number"><%# Container.ItemIndex + 1 %></div>
                                    <div class="question-type"><%# Eval("Type") %></div>
                                </div>
                                
                                <div class="question-text">
                                    <%# Eval("QuestionText") %>
                                </div>
                                
                                <asp:Repeater ID="rptAnswers" runat="server" DataSource='<%# Eval("Options") %>'>
                                    <ItemTemplate>
                                        <div class="answer-option <%# (bool)Eval("IsCorrect") ? "correct" : "" %>">
                                            <i class="fas <%# (bool)Eval("IsCorrect") ? "fa-check-circle" : "fa-circle" %> me-2"></i>
                                            <%# Eval("Text") %>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                                
                                <asp:Panel ID="pnlExplanation" runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("Explanation")?.ToString()) %>' CssClass="mt-3">
                                    <div class="alert alert-info">
                                        <i class="fas fa-lightbulb me-2"></i>
                                        <strong>Explanation:</strong> <%# Eval("Explanation") %>
                                    </div>
                                </asp:Panel>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoQuestions" runat="server" Visible="false" CssClass="empty-state">
                        <i class="fas fa-question-circle"></i>
                        <h4>No Questions Created</h4>
                        <p>Add questions to this lesson to create engaging assessments for students</p>
                    </asp:Panel>
                </div>
            </asp:Panel>

            <!-- Hidden Fields for State Management -->
            <asp:HiddenField ID="hdnSelectedLanguageId" runat="server" />
            <asp:HiddenField ID="hdnSelectedLessonId" runat="server" />
        </div>
    
    <script>
        // Page load animation
        document.addEventListener('DOMContentLoaded', function () {
            document.body.style.opacity = '1';
            document.body.style.transform = 'translateY(0)';

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

            // Apply staggered animations
            const cards = document.querySelectorAll('.language-card, .question-card');
            cards.forEach((card, index) => {
                card.style.setProperty('--index', index);
                card.style.animationDelay = `${index * 0.1}s`;
            });
        });

        // Language selection
        function selectLanguage(languageId) {
            document.getElementById('<%= hdnSelectedLanguageId.ClientID %>').value = languageId;
            __doPostBack('<%= hdnSelectedLanguageId.UniqueID %>', 'SelectLanguage');
        }

        // Lesson selection
        function selectLesson(lessonId) {
            document.getElementById('<%= hdnSelectedLessonId.ClientID %>').value = lessonId;
            __doPostBack('<%= hdnSelectedLessonId.UniqueID %>', 'SelectLesson');
        }
    </script>
</asp:Content>