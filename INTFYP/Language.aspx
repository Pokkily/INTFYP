<%@ Page Async="true" Title="Languages" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Language.aspx.cs" Inherits="INTFYP.Language" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Languages
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        
        
        .language-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        .language-page::before {
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

        .language-container {
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

        /* Sidebar Card */
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

        /* Search Input */
        .search-input {
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

        .search-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: rgba(255, 255, 255, 1);
        }

        /* Navigation Buttons */
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

        /* Main Content Card */
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
            content: '🌍';
            font-size: 22px;
        }

        /* Language Cards Grid */
        .languages-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
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

        .language-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 18px;
            border-radius: 18px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            animation: cardEntrance 0.8s ease-out both;
            animation-delay: calc(var(--card-index, 0) * 0.1s);
            height: 100%;
            display: flex;
            flex-direction: column;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
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

        .language-card::before {
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

        .language-card:hover {
            transform: translateY(-6px) translateX(3px) scale(1.01);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
            text-decoration: none;
            color: inherit;
        }

        .language-flag {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px auto;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.2);
            font-size: 35px;
        }

        .language-card:hover .language-flag {
            transform: scale(1.05) rotate(3deg);
            box-shadow: 0 6px 20px rgba(103, 126, 234, 0.3);
        }

        .language-name {
            font-size: 18px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 8px;
            text-align: center;
            line-height: 1.3;
        }

        .language-code {
            color: #7f8c8d;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 12px;
            text-align: center;
            text-transform: uppercase;
        }

        .language-description {
            color: #95a5a6;
            font-size: 13px;
            text-align: center;
            line-height: 1.4;
            flex: 1;
            margin-bottom: 0;
        }

        /* No Languages Message */
        .no-languages {
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

        .no-languages-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.7;
            animation: iconBounce 2s ease-in-out infinite;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .no-languages h3 {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 8px;
            color: rgba(255, 255, 255, 0.9);
        }

        .no-languages p {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.7);
            margin: 0;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .language-page {
                padding: 20px 15px;
            }

            .languages-grid {
                grid-template-columns: 1fr;
                gap: 12px;
            }

            .content-header {
                flex-direction: column;
                align-items: stretch;
                gap: 12px;
            }

            .search-input {
                width: 100%;
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

            .language-card {
                padding: 12px;
                border-radius: 12px;
            }

            .language-flag {
                width: 60px;
                height: 60px;
                font-size: 28px;
            }
        }

        /* Loading states */
        .language-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }
    </style>

    <div class="language-page">
        <div class="language-container">
            <div class="page-header">
                <h2 class="page-title">Choose Your Language</h2>
                <p class="page-subtitle">Start Learning Today</p>
            </div>

            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-3 mb-4">
                    <div class="sidebar-card">
                        <h5 class="sidebar-title">Search Languages</h5>
        
                        <asp:TextBox ID="txtLanguageSearch" runat="server" 
                            CssClass="search-input"
                            placeholder="Search by language name..." AutoPostBack="true"
                            OnTextChanged="txtLanguageSearch_TextChanged" />
        
                        <!-- Student Report Button -->
                        <div class="d-grid">
                            <asp:Button ID="btnStudentReport" runat="server" 
                                Text="📊 Student Reports" 
                                CssClass="nav-button nav-button-secondary"
                                OnClick="btnStudentReport_Click" />
                        </div>
                    </div>
                </div>

                <!-- Main Content -->
                <div class="col-md-9">
                    <div class="main-content-card">
                        <div class="content-header">
                            <h3 class="content-title">Available Languages</h3>
                        </div>
                    </div>

                    <asp:Panel ID="pnlNoLanguages" runat="server" Visible="false" CssClass="no-languages">
                        <div class="no-languages-icon">🌍</div>
                        <h3>No Languages Found</h3>
                        <p>Try adjusting your search criteria or add a new language!</p>
                    </asp:Panel>

                    <asp:Repeater ID="rptLanguages" runat="server" OnItemCommand="rptLanguages_ItemCommand">
                        <HeaderTemplate>
                            <div class="languages-grid">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkLanguageCard" runat="server" 
                                CommandName="SelectLanguage" 
                                CommandArgument='<%# Eval("Id") %>'
                                CssClass="language-card" 
                                style="--card-index: <%# Container.ItemIndex %>;">
                                
                                <div class="language-flag"><%# Eval("Flag") %></div>
                                <h5 class="language-name"><%# Eval("Name") %></h5>
                                <p class="language-code"><%# Eval("Code") %></p>
                                <p class="language-description"><%# Eval("Description") %></p>
                            </asp:LinkButton>
                        </ItemTemplate>
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>

    <!-- Font Awesome for additional icons if needed -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>