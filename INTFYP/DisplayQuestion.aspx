<%@ Page Async="true" Title="Questions" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="DisplayQuestion.aspx.cs" Inherits="INTFYP.DisplayQuestion" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Questions
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        
        .questions-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        .questions-page::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(120, 119, 198, 0.2) 0%, transparent 50%);
            animation: backgroundFloat 20s ease-in-out infinite;
            z-index: -1;
        }

        @keyframes backgroundFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-20px, -20px) rotate(1deg); }
            50% { transform: translate(20px, -10px) rotate(-1deg); }
            75% { transform: translate(-10px, 10px) rotate(0.5deg); }
        }

        .questions-container {
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            animation: slideInFromTop 1s ease-out;
        }

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

        .page-title {
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 15px;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            position: relative;
            display: inline-block;
        }

        .page-title::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 4px;
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            border-radius: 2px;
            animation: expandWidth 1.5s ease-out 0.5s both;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 80px; }
        }

        .page-subtitle {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.8);
            margin: 0;
        }

        .language-info {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            animation: slideInFromTop 0.8s ease-out 0.2s both;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .language-flag-large {
            font-size: 40px;
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .language-details h3 {
            margin: 0 0 5px 0;
            color: #2c3e50;
            font-size: 20px;
            font-weight: 700;
        }

        .language-details p {
            margin: 0;
            color: #7f8c8d;
            font-size: 14px;
        }

        .sidebar-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 25px;
            margin-bottom: 20px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            animation: slideInFromLeft 0.8s ease-out 0.2s both;
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

        .sidebar-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .sidebar-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .sidebar-title {
            font-size: 20px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .sidebar-title::before {
            content: '🔍';
            font-size: 24px;
        }

        .filter-dropdown {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(5px);
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 25px;
            padding: 12px 20px;
            font-size: 14px;
            transition: all 0.3s ease;
            width: 100%;
            margin-bottom: 20px;
        }

        .filter-dropdown:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: rgba(255, 255, 255, 1);
        }

        .nav-button {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 20px;
            border-radius: 25px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            width: 100%;
            justify-content: center;
            margin-bottom: 12px;
        }

        .nav-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .nav-button:hover::before {
            width: 300px;
            height: 300px;
        }

        .nav-button:hover {
            transform: translateY(-2px);
        }

        .nav-button-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .nav-button-primary:hover {
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        .nav-button-secondary {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .nav-button-secondary:hover {
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
        }

        .main-content-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            animation: slideInFromRight 0.8s ease-out 0.3s both;
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

        .content-header {
            text-align: center;
            margin-bottom: 15px;
        }

        .content-title {
            font-size: 20px;
            font-weight: 700;
            color: #2c3e50;
            margin: 0 0 10px 0;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .content-title::before {
            content: '📄';
            font-size: 22px;
        }

        .questions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 15px;
            animation: slideInFromBottom 1s ease-out 0.4s both;
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

        .question-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 20px;
            border-radius: 18px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            animation: cardEntrance 0.8s ease-out both;
            animation-delay: calc(var(--card-index, 0) * 0.1s);
            height: auto;
            display: flex;
            flex-direction: column;
        }

        @keyframes cardEntrance {
            from { 
                opacity: 0; 
                transform: translateX(-30px) rotate(-1deg); 
            }
            to { 
                opacity: 1; 
                transform: translateX(0) rotate(0deg); 
            }
        }

        .question-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
        }

        .question-card:hover {
            transform: translateY(-6px) translateX(3px) scale(1.01);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
        }

        .question-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .question-number {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 8px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .question-type {
            background: rgba(78, 205, 196, 0.1);
            color: #4ecdc4;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            border: 1px solid rgba(78, 205, 196, 0.2);
        }

        .question-text {
            font-size: 16px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 15px;
            line-height: 1.4;
            min-height: 3em;
        }

        .question-media {
            margin-bottom: 15px;
            text-align: center;
        }

        .question-image {
            max-width: 100%;
            max-height: 150px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        .question-audio {
            width: 100%;
            border-radius: 12px;
        }

        .question-options {
            flex: 1;
            margin-bottom: 15px;
        }

        .option-item {
            background: rgba(103, 126, 234, 0.05);
            border: 1px solid rgba(103, 126, 234, 0.1);
            border-radius: 10px;
            padding: 10px 12px;
            margin-bottom: 8px;
            font-size: 14px;
            color: #2c3e50;
            transition: all 0.3s ease;
            position: relative;
        }

        .option-item:last-child {
            margin-bottom: 0;
        }

        .option-item.correct {
            background: rgba(40, 167, 69, 0.1);
            border-color: rgba(40, 167, 69, 0.3);
            color: #28a745;
            font-weight: 600;
        }

        .option-item.correct::before {
            content: '✓';
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #28a745;
            font-weight: bold;
        }

        .question-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 15px;
            border-top: 1px solid rgba(0, 0, 0, 0.1);
        }

        .lesson-info {
            font-size: 12px;
            color: #7f8c8d;
            font-weight: 500;
        }

        .question-actions {
            display: flex;
            gap: 8px;
        }

        .action-btn {
            padding: 6px 12px;
            border-radius: 15px;
            border: none;
            cursor: pointer;
            font-size: 11px;
            font-weight: 600;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .action-btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .action-btn:hover::before {
            width: 100px;
            height: 100px;
        }

        .action-btn:hover {
            transform: translateY(-2px);
        }

        .btn-edit {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .btn-edit:hover {
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
        }

        .btn-delete {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
        }

        .btn-delete:hover {
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.4);
        }

        .no-questions {
            text-align: center;
            padding: 40px 30px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: rgba(255, 255, 255, 0.9);
            animation: fadeInUp 1s ease-out 0.6s both;
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

        .no-questions-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.7;
            animation: iconBounce 2s ease-in-out infinite;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .no-questions h3 {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 8px;
            color: rgba(255, 255, 255, 0.9);
        }

        .no-questions p {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.7);
            margin: 0;
        }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 15px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            animation: slideInFromTop 0.8s ease-out both;
            animation-delay: calc(var(--stat-index, 0) * 0.1s);
        }

        .stat-number {
            font-size: 24px;
            font-weight: 700;
            color: #667eea;
            display: block;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 12px;
            color: #7f8c8d;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        @media (max-width: 768px) {
            .questions-page {
                padding: 20px 15px;
            }

            .questions-grid {
                grid-template-columns: 1fr;
                gap: 12px;
            }

            .language-info {
                flex-direction: column;
                text-align: center;
                gap: 10px;
            }

            .stats-row {
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 28px;
            }

            .sidebar-card,
            .main-content-card {
                padding: 15px;
                margin-bottom: 12px;
                border-radius: 12px;
            }

            .question-card {
                padding: 15px;
                border-radius: 12px;
            }

            .language-flag-large {
                width: 50px;
                height: 50px;
                font-size: 30px;
            }

            .stats-row {
                grid-template-columns: 1fr;
            }
        }

        .question-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }
    </style>

    <div class="questions-page">
        <div class="questions-container">
            <div class="page-header">
                <h2 class="page-title">
                    <asp:Label ID="lblLanguageName" runat="server" Text="Language Questions" />
                </h2>
                <p class="page-subtitle">Practice and Learn</p>
            </div>

            <div class="language-info">
                <div class="language-flag-large">
                    <asp:Label ID="lblLanguageFlag" runat="server" Text="🌍" />
                </div>
                <div class="language-details">
                    <h3><asp:Label ID="lblLanguageTitle" runat="server" Text="Language Name" /></h3>
                    <p><asp:Label ID="lblLanguageDescription" runat="server" Text="Language description..." /></p>
                </div>
            </div>

            <div class="stats-row">
                <div class="stat-card" style="--stat-index: 0;">
                    <span class="stat-number">
                        <asp:Label ID="lblTotalQuestions" runat="server" Text="0" />
                    </span>
                    <span class="stat-label">Total Questions</span>
                </div>
                <div class="stat-card" style="--stat-index: 1;">
                    <span class="stat-number">
                        <asp:Label ID="lblTotalLessons" runat="server" Text="0" />
                    </span>
                    <span class="stat-label">Lessons</span>
                </div>
            </div>

            <div class="row">
                <div class="col-md-3 mb-4">
                    <div class="sidebar-card">
                        <h5 class="sidebar-title">Course Navigation</h5>
                        
                        <div class="d-grid gap-2">
                            <asp:Button ID="btnBackToLanguages" runat="server" 
                                Text="⬅️ Back to Languages" 
                                CssClass="nav-button nav-button-primary"
                                OnClick="btnBackToLanguages_Click" />
                        </div>
                        
                        <div class="mt-4">
                            <h6 style="color: #2c3e50; font-weight: 600; margin-bottom: 15px;">📊 Quick Stats</h6>
                            <div class="stat-card mb-2" style="background: rgba(103, 126, 234, 0.1); padding: 10px; border-radius: 10px;">
                                <div class="stat-number" style="font-size: 18px; font-weight: 700; color: #667eea;">
                                    <asp:Label ID="lblQuickTopics" runat="server" Text="0" />
                                </div>
                                <div class="stat-label" style="font-size: 11px; color: #7f8c8d;">Topics Available</div>
                            </div>
                            <div class="stat-card mb-2" style="background: rgba(78, 205, 196, 0.1); padding: 10px; border-radius: 10px;">
                                <div class="stat-number" style="font-size: 18px; font-weight: 700; color: #4ecdc4;">
                                    <asp:Label ID="lblQuickLessons" runat="server" Text="0" />
                                </div>
                                <div class="stat-label" style="font-size: 11px; color: #7f8c8d;">Total Lessons</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-9">
                    <div class="main-content-card">
                        <div class="content-header">
                            <h3 class="content-title">Questions Collection</h3>
                        </div>
                    </div>

                    <asp:Panel ID="pnlNoQuestions" runat="server" Visible="false" CssClass="no-questions">
                        <div class="no-questions-icon">📚</div>
                        <h3>No Topics Found</h3>
                        <p>Add topics and lessons to get started with this language!</p>
                    </asp:Panel>

                    <asp:Repeater ID="rptTopics" runat="server" OnItemDataBound="rptTopics_ItemDataBound">
                        <ItemTemplate>
                            <div class="card mb-3 shadow-sm" style="background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 18px;">
                                <div class="card-header d-flex justify-content-between align-items-center" style="background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05)); border-bottom: 1px solid rgba(0,0,0,0.1);">
                                    <div>
                                        <h5 class="mb-0" style="color: #2c3e50; font-weight: 700;">📖 Topic: <%# Eval("TopicDisplayName") %></h5>
                                        <small style="color: #7f8c8d;"><%# Eval("LessonCount") %> Lessons • <%# Eval("QuestionCount") %> Questions</small>
                                    </div>
                                    <button class="btn btn-sm" type="button" data-bs-toggle="collapse" data-bs-target="#<%# Eval("CollapseId") %>" aria-expanded="false" 
                                            style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 15px; padding: 8px 15px; font-weight: 600;">
                                        View Lessons
                                    </button>
                                </div>
                                <div class="collapse" id="<%# Eval("CollapseId") %>">
                                    <div class="card-body" style="padding: 20px;">
                                        <asp:Repeater ID="rptLessons" runat="server" OnItemCommand="rptLessons_ItemCommand">
                                            <ItemTemplate>
                                                <div class="card mb-2 shadow-sm" style="background: rgba(255, 255, 255, 0.9); border: 1px solid rgba(103, 126, 234, 0.1); border-radius: 12px;">
                                                    <div class="card-body d-flex justify-content-between align-items-center" style="padding: 15px;">
                                                        <div style="flex: 1;">
                                                            <h6 class="card-title mb-1" style="color: #2c3e50; font-weight: 600;">📝 <%# Eval("Name") %></h6>
                                                            <p class="text-muted mb-1" style="font-size: 13px;"><%# Eval("Description") %></p>
                                                            <small style="color: #667eea; font-weight: 500;">
                                                                <i class="fas fa-question-circle me-1"></i><%# Eval("QuestionCount") %> Questions
                                                            </small>
                                                        </div>
                                                        <div>
                                                            <asp:Button ID="btnStartLesson" runat="server" 
                                                                Text="▶️ Start" 
                                                                CommandName="StartLesson"
                                                                CommandArgument='<%# Eval("Id") + "|" + Eval("TopicName") %>'
                                                                CssClass="btn btn-sm"
                                                                style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 15px; padding: 10px 20px; font-weight: 600; box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>