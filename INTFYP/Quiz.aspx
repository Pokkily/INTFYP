<%@ Page Title="Quiz" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" Async="true" CodeBehind="Quiz.aspx.cs" Inherits="YourProjectNamespace.Quiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced CSS with robust animations and modern design */
        
        .quiz-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        .quiz-page::before {
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

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            width: 100%;
            max-width: 1200px;
            margin-left: auto;
            margin-right: auto;
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
            width: 60px;
            height: 4px;
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            border-radius: 2px;
            animation: expandWidth 1.5s ease-out 0.5s both;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 60px; }
        }

        .page-subtitle {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.9);
            margin-bottom: 40px;
            font-weight: 300;
        }

        .search-container {
            display: flex;
            justify-content: center;
            gap: 25px;
            margin-bottom: 40px;
            flex-wrap: wrap;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
            animation: slideInFromBottom 1s ease-out 0.3s both;
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

        .search-box {
            display: flex;
            align-items: center;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 15px 20px;
            border-radius: 30px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
            width: 350px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .search-box::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
            transition: left 0.6s;
        }

        .search-box:hover::before {
            left: 100%;
        }

        .search-box:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 35px rgba(0, 0, 0, 0.2);
            background: rgba(255, 255, 255, 1);
        }

        .search-box:focus-within {
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 12px 35px rgba(102, 126, 234, 0.3);
            border-color: #667eea;
        }

        .search-box i {
            color: #667eea;
            margin-right: 12px;
            font-size: 16px;
            transition: color 0.3s ease;
        }

        .search-box input {
            border: none;
            outline: none;
            width: 100%;
            font-size: 15px;
            background: transparent;
            color: #2c3e50;
            font-weight: 500;
        }

        .search-box input::placeholder {
            color: #95a5a6;
        }

        .quiz-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: 30px;
            margin-top: 30px;
            max-width: 1400px;
            margin-left: auto;
            margin-right: auto;
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

        .quiz-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            border: 1px solid rgba(255, 255, 255, 0.2);
            animation: cardEntrance 0.8s ease-out both;
            animation-delay: calc(var(--card-index, 0) * 0.1s);
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

        .quiz-card::before {
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

        .quiz-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
        }

        .quiz-card:hover .quiz-image {
            transform: scale(1.1);
        }

        .quiz-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 18px;
            font-weight: 600;
            text-align: center;
            font-size: 16px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .quiz-image-container {
            width: 100%;
            height: 200px;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .quiz-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .quiz-body {
            padding: 25px;
        }

        .quiz-title {
            font-size: 20px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 12px;
            line-height: 1.3;
            transition: color 0.3s ease;
        }

        .quiz-card:hover .quiz-title {
            color: #667eea;
        }

        .quiz-meta {
            font-size: 14px;
            color: #7f8c8d;
            margin-bottom: 8px;
            font-weight: 500;
            display: flex;
            align-items: center;
        }

        .quiz-meta::before {
            content: '';
            width: 6px;
            height: 6px;
            background: #667eea;
            border-radius: 50%;
            margin-right: 10px;
        }

        .quiz-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 25px;
            border-top: 1px solid rgba(236, 240, 241, 0.5);
            background: rgba(248, 249, 250, 0.5);
        }

        .quiz-code {
            font-size: 13px;
            color: #95a5a6;
            font-weight: 600;
            background: rgba(103, 126, 234, 0.1);
            padding: 6px 12px;
            border-radius: 15px;
            border: 1px solid rgba(103, 126, 234, 0.2);
        }

        .play-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
        }

        .play-button::before {
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

        .play-button:hover::before {
            width: 300px;
            height: 300px;
        }

        .play-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        .play-button:active {
            transform: translateY(0);
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .no-results {
            text-align: center;
            color: rgba(255, 255, 255, 0.8);
            padding: 60px 40px;
            grid-column: 1 / -1;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            font-size: 18px;
            font-weight: 500;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .quiz-page {
                padding: 30px 15px;
            }

            .quiz-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .search-container {
                flex-direction: column;
                align-items: center;
                gap: 15px;
            }

            .search-box {
                width: 100%;
                max-width: 400px;
            }

            .page-title {
                font-size: 36px;
            }
        }

        @media (max-width: 480px) {
            .quiz-card {
                border-radius: 15px;
            }

            .quiz-body {
                padding: 20px;
            }

            .quiz-footer {
                padding: 15px 20px;
                flex-direction: column;
                gap: 15px;
                align-items: stretch;
            }

            .play-button {
                width: 100%;
                justify-content: center;
            }
        }

        /* Loading animation for cards */
        .quiz-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }

        /* Pulse effect for interactive elements */
        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(103, 126, 234, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(103, 126, 234, 0); }
            100% { box-shadow: 0 0 0 0 rgba(103, 126, 234, 0); }
        }

        .search-box:focus-within {
            animation: pulse 2s infinite;
        }
    </style>

    <div class="quiz-page">
        <div class="page-header">
            <div class="page-title">Welcome to Quizzes</div>
            <div class="page-subtitle">Score & Get your badges here</div>
        </div>

        <div class="search-container">
            <div class="search-box">
                <i class="fas fa-search"></i>
                <asp:TextBox ID="txtSearchTitle" runat="server" placeholder="Search by quiz title..." AutoPostBack="true" OnTextChanged="txtSearchTitle_TextChanged" />
            </div>
            <div class="search-box">
                <i class="fas fa-hashtag"></i>
                <asp:TextBox ID="txtSearchCode" runat="server" placeholder="Search by quiz code..." AutoPostBack="true" OnTextChanged="txtSearchCode_TextChanged" />
            </div>
        </div>

        <div class="quiz-grid">
            <asp:Repeater ID="rptQuizzes" runat="server" OnItemCommand="rptQuizzes_ItemCommand">
                <ItemTemplate>
                    <div class="quiz-card">
                        <div class="quiz-image-container">
                            <img src='<%# Eval("QuizImageUrl") %>' alt="Quiz Image" class="quiz-image" />
                        </div>
                        <div class="quiz-body">
                            <div class="quiz-title"><%# Eval("Title") %></div>
                            <div class="quiz-meta">Uploaded by: <%# Eval("CreatedBy") %></div>
                            <div class="quiz-meta">Upload date: <%# Eval("CreatedAtString") %></div>
                        </div>
                        <div class="quiz-footer">
                            <div class="quiz-code">Code: <%# Eval("QuizCode") %></div>
                            <asp:LinkButton ID="btnPlay" runat="server"
                                CommandName="Play"
                                CommandArgument='<%# Eval("QuizCode") %>'
                                CssClass="play-button"
                                Text="Try Out!" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoResults" runat="server" CssClass="no-results" Visible="false">
                No quizzes found. Try a different search.
            </asp:Panel>
        </div>
    </div>

    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>