<%@ Page Async="true" Title="FavBooks" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="FavBooks.aspx.cs" Inherits="INTFYP.FavBooks" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Favorite Books
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        
        .library-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        .library-page::before {
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

        .library-container {
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
            color: rgba(255, 255, 255, 0.8);
            margin: 0;
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
            content: '⭐';
            font-size: 22px;
        }

        .books-grid {
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

        .book-card {
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

        .book-card::before {
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

        .book-card:hover {
            transform: translateY(-6px) translateX(3px) scale(1.01);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
        }

        .book-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.2);
        }

        .book-icon::before {
            content: '⭐';
            font-size: 20px;
            opacity: 0.9;
        }

        .book-card:hover .book-icon {
            transform: scale(1.05) rotate(3deg);
            box-shadow: 0 6px 20px rgba(103, 126, 234, 0.3);
        }

        .book-title {
            font-size: 16px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 6px;
            line-height: 1.3;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            min-height: 2.4em;
        }

        .book-author {
            color: #7f8c8d;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 10px;
            display: -webkit-box;
            -webkit-line-clamp: 1;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .category-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            margin-bottom: 12px;
            background: rgba(103, 126, 234, 0.1);
            color: #667eea;
            border: 1px solid rgba(103, 126, 234, 0.2);
        }

        .book-actions {
            display: flex;
            gap: 6px;
            margin-top: auto;
            flex-wrap: wrap;
        }

        .book-action-btn {
            padding: 7px 12px;
            border-radius: 18px;
            border: none;
            cursor: pointer;
            font-size: 11px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            flex: 1;
            justify-content: center;
            min-width: 75px;
        }

        .book-action-btn::before {
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

        .book-action-btn:hover::before {
            width: 200px;
            height: 200px;
        }

        .book-action-btn:hover {
            transform: translateY(-2px);
        }

        .btn-recommend {
            background: linear-gradient(135deg, #e8e8e8 0%, #d0d0d0 100%);
            color: #2c3e50;
            box-shadow: 0 4px 15px rgba(200, 200, 200, 0.3);
        }

        .btn-recommend:hover {
            background: linear-gradient(135deg, #d8b5f0 0%, #c9a9e0 100%);
            box-shadow: 0 8px 25px rgba(216, 181, 240, 0.4);
        }

        .btn-recommend.active {
            background: linear-gradient(135deg, #d8b5f0 0%, #c9a9e0 100%) !important;
            box-shadow: 0 8px 25px rgba(216, 181, 240, 0.5) !important;
            color: #ffffff !important;
        }

        .btn-favorite {
            background: linear-gradient(135deg, #e8e8e8 0%, #d0d0d0 100%);
            color: #2c3e50;
            box-shadow: 0 4px 15px rgba(200, 200, 200, 0.3);
        }

        .btn-favorite:hover {
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%);
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.4);
        }

        .btn-favorite.active {
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.5) !important;
            color: #ffffff !important;
        }

        .btn-recommend.clicked,
        .btn-favorite.clicked {
            animation: buttonPulse 0.6s ease-out;
        }

        @keyframes buttonPulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }

        .no-books {
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

        .no-books-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.7;
            animation: iconBounce 2s ease-in-out infinite;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .no-books h3 {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 8px;
            color: rgba(255, 255, 255, 0.9);
        }

        .no-books p {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.7);
            margin: 0;
        }

        .top-search-bar {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(5px);
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 25px;
            padding: 10px 18px;
            font-size: 14px;
            transition: all 0.3s ease;
            width: 250px;
        }

        .top-search-bar:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: rgba(255, 255, 255, 1);
        }

        @media (max-width: 768px) {
            .library-page {
                padding: 20px 15px;
            }

            .books-grid {
                grid-template-columns: 1fr;
                gap: 12px;
            }

            .content-header {
                flex-direction: column;
                align-items: stretch;
                gap: 12px;
            }

            .search-input,
            .top-search-bar {
                width: 100%;
            }

            .book-actions {
                flex-direction: column;
                gap: 6px;
            }

            .book-action-btn {
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

            .book-card {
                padding: 12px;
                border-radius: 12px;
            }
        }

        .content-header-with-search {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }
    </style>

    <div class="library-page">
        <div class="library-container">
            <div class="page-header">
                <h2 class="page-title">Your Favorite Books</h2>
                <p class="page-subtitle">All Books You've Loved</p>
            </div>

            <div class="row">
                <div class="col-md-3 mb-4">
                    <div class="sidebar-card">
                        <h5 class="sidebar-title">Search Books</h5>
                        
                        <asp:TextBox ID="txtBookSearch" runat="server" 
                            CssClass="search-input"
                            placeholder="Search by title, author, or category..." AutoPostBack="true"
                            OnTextChanged="txtBookSearch_TextChanged" />

                        <div class="d-grid gap-2">
                            <button type="button" class="nav-button nav-button-primary" onclick="location.href='Library.aspx';">
                                📚 Back to Library
                            </button>
                            <button type="button" class="nav-button nav-button-secondary" onclick="location.href='CitationGenerator.aspx';">
                                📝 Citation Generator
                            </button>
                        </div>
                    </div>
                </div>

                <div class="col-md-9">
                    <div class="main-content-card">
                        <div class="content-header">
                            <h3 class="content-title">Your Favorites</h3>
                        </div>
                    </div>

                    <asp:Panel ID="pnlNoBooks" runat="server" Visible="false" CssClass="no-books">
                        <div class="no-books-icon">⭐</div>
                        <h3>No Favorite Books Found</h3>
                        <p>Start exploring the library and mark your favorite books!</p>
                    </asp:Panel>

                    <asp:Repeater ID="Repeater1" runat="server" OnItemCommand="Repeater1_ItemCommand">
                        <HeaderTemplate>
                            <div class="books-grid">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div class="book-card" style="--card-index: <%# Container.ItemIndex %>;">
                                <div class="book-icon"></div>
                                
                                <a href='<%# "PreviewBook.aspx?pdfUrl=" + HttpUtility.UrlEncode(Eval("PdfUrl").ToString()) %>' 
                                   style="text-decoration: none; color: inherit; flex: 1; display: flex; flex-direction: column;">
                                    
                                    <h5 class="book-title"><%# Eval("Title") %></h5>
                                    <p class="book-author"><%# Eval("Author") %></p>
                                    <span class="category-badge">#<%# Eval("Category") %></span>
                                </a>
                                
                                <div class="book-actions">
                                    <asp:Button ID="btnRecommend" runat="server"
                                        Text='<%# String.Format("{0} ❤️", Eval("Recommendations")) %>'
                                        CommandName="Recommend"
                                        CommandArgument='<%# Eval("DocumentId") %>'
                                        CssClass='<%# "book-action-btn btn-recommend" + (Convert.ToBoolean(Eval("IsRecommended")) ? " active" : "") %>'
                                        OnClientClick="addClickEffect(this); return true;" />
                                    <asp:Button ID="btnFavorite" runat="server"
                                        Text="⭐"
                                        CommandName="Favorite"
                                        CommandArgument='<%# Eval("DocumentId") %>'
                                        CssClass='<%# "book-action-btn btn-favorite" + (Convert.ToBoolean(Eval("IsFavorited")) ? " active" : "") %>'
                                        OnClientClick="addClickEffect(this); return true;" />
                                </div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>

    <script>
        function addClickEffect(button) {
            button.classList.add('clicked');

            setTimeout(function () {
                button.classList.remove('clicked');
            }, 600);
        }
    </script>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>