<%@ Page Async="true" Title="Library" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Library.aspx.cs" Inherits="INTFYP.Library" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Library
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

        .category-filter {
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

        .category-filter:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: rgba(255, 255, 255, 1);
        }

        .filter-label {
            font-weight: 600;
            color: #2c3e50;
            font-size: 14px;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .filter-label::before {
            content: '🏷️';
            font-size: 16px;
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

        .section-header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 20px 25px;
            margin-bottom: 20px;
            border-radius: 20px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            animation: slideInFromRight 0.8s ease-out both;
        }

        .section-title {
            font-size: 24px;
            font-weight: 700;
            color: #2c3e50;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-newest .section-title::before {
            content: '🆕';
            font-size: 28px;
        }

        .section-recommended .section-title::before {
            content: '🔥';
            font-size: 28px;
        }

        .section-alphabetical .section-title::before {
            content: '📖';
            font-size: 28px;
        }

        .section-search .section-title::before {
            content: '🔍';
            font-size: 28px;
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

        .book-section {
            margin-bottom: 40px;
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
            content: '📖';
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

        .book-badges {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
            margin-bottom: 12px;
        }

        .category-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
            color: white;
        }

        .tag-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
        }

        .book-actions {
            display: flex;
            gap: 6px;
            margin-top: auto;
            flex-wrap: wrap;
        }

        .book-action-btn {
            padding: 7px 12px !important; 
            border-radius: 18px !important; 
            border: none !important;
            cursor: pointer !important;
            font-size: 11px !important; 
            font-weight: 600 !important;
            text-decoration: none !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 4px !important; 
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            position: relative !important;
            overflow: hidden !important;
            flex: 1 !important;
            justify-content: center !important;
            min-width: 75px !important;
            font-family: inherit !important;
            line-height: 1 !important;
            text-align: center !important;
            vertical-align: middle !important;
            touch-action: manipulation !important;
            user-select: none !important;
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
            transform: translateY(-2px) !important;
        }

        .btn-recommend {
            background: linear-gradient(135deg, #e8e8e8 0%, #d0d0d0 100%) !important;
            color: #2c3e50 !important;
            box-shadow: 0 4px 15px rgba(200, 200, 200, 0.3) !important;
        }

        .btn-recommend:hover {
            background: linear-gradient(135deg, #d8b5f0 0%, #c9a9e0 100%) !important;
            box-shadow: 0 8px 25px rgba(216, 181, 240, 0.4) !important;
        }

        .btn-recommend.active {
            background: linear-gradient(135deg, #d8b5f0 0%, #c9a9e0 100%) !important;
            box-shadow: 0 8px 25px rgba(216, 181, 240, 0.5) !important;
            color: #ffffff !important;
        }

        .btn-recommend.active:hover {
            background: linear-gradient(135deg, #c9a9e0 0%, #b899d0 100%) !important;
            box-shadow: 0 10px 30px rgba(216, 181, 240, 0.6) !important;
        }

        .btn-favorite {
            background: linear-gradient(135deg, #e8e8e8 0%, #d0d0d0 100%) !important;
            color: #2c3e50 !important;
            box-shadow: 0 4px 15px rgba(200, 200, 200, 0.3) !important;
        }

        .btn-favorite:hover {
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.4) !important;
        }

        .btn-favorite.active {
            background: linear-gradient(135deg, #9caf88 0%, #8a9c78 100%) !important;
            box-shadow: 0 8px 25px rgba(156, 175, 136, 0.5) !important;
            color: #ffffff !important;
        }

        .btn-favorite.active:hover {
            background: linear-gradient(135deg, #8a9c78 0%, #7a8c68 100%) !important;
            box-shadow: 0 10px 30px rgba(156, 175, 136, 0.6) !important;
        }

        .btn-recommend.clicked,
        .btn-favorite.clicked {
            animation: buttonPulse 0.6s ease-out !important;
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

        @media (max-width: 768px) {
            .library-page {
                padding: 20px 15px;
            }

            .books-grid {
                grid-template-columns: 1fr;
                gap: 12px;
            }

            .search-input {
                width: 100%;
            }

            .book-actions {
                flex-direction: column;
                gap: 6px;
            }

            .book-action-btn {
                width: 100% !important;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 28px;
            }

            .sidebar-card,
            .section-header {
                padding: 15px;
                margin-bottom: 12px;
                border-radius: 12px;
            }

            .book-card {
                padding: 12px;
                border-radius: 12px;
            }
        }

        .book-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }
    </style>

    <asp:HiddenField ID="hdnScrollToBook" runat="server" />

    <div class="library-page">
        <div class="library-container">
            <div class="page-header">
                <h2 class="page-title">Welcome to Library</h2>
                <p class="page-subtitle">All Materials You Need</p>
            </div>

            <div class="row">
                <div class="col-md-3 mb-4">
                    <div class="sidebar-card">
                        <h5 class="sidebar-title">Search Books</h5>
                        
                        <asp:TextBox ID="txtBookSearch" runat="server" 
                            CssClass="search-input"
                            placeholder="Search by title, author, category, or tag..." AutoPostBack="true"
                            OnTextChanged="txtBookSearch_TextChanged" />

                        <label class="filter-label">Filter by Category</label>
                        <asp:DropDownList ID="ddlCategoryFilter" runat="server" CssClass="category-filter"
                                          AutoPostBack="true" OnSelectedIndexChanged="ddlCategoryFilter_SelectedIndexChanged">
                            <asp:ListItem Value="" Text="-- All Categories --" />
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
                            <asp:ListItem Value="Reference" Text="Reference" />
                        </asp:DropDownList>

                        <div class="d-grid gap-2">
                            <button type="button" class="nav-button nav-button-primary" onclick="location.href='FavBooks.aspx';">
                                ⭐ Favorite Books
                            </button>
                            <button type="button" class="nav-button nav-button-secondary" onclick="location.href='CitationGenerator.aspx';">
                                📝 Citation Generator
                            </button>
                        </div>
                    </div>
                </div>

                <div class="col-md-9">
                    <asp:Panel ID="pnlNoBooks" runat="server" Visible="false" CssClass="no-books">
                        <div class="no-books-icon">📚</div>
                        <h3>No Books Found</h3>
                        <p>Try adjusting your search criteria or browse all books!</p>
                    </asp:Panel>

                    <asp:Panel ID="pnlBookSections" runat="server">
                        
                        <asp:Panel ID="pnlSearchResults" runat="server" Visible="false" CssClass="book-section">
                            <div class="section-header section-search">
                                <h3 class="section-title">Search Results</h3>
                            </div>
                            <asp:Repeater ID="RepSearchResults" runat="server" OnItemCommand="Repeater_ItemCommand">
                                <HeaderTemplate>
                                    <div class="books-grid">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div class="book-card" id="book-card-<%# Eval("DocumentId") %>" style="--card-index: <%# Container.ItemIndex %>;">
                                        <div class="book-icon"></div>
                                        
                                        <a href='<%# "PreviewBook.aspx?pdfUrl=" + HttpUtility.UrlEncode(Eval("PdfUrl").ToString()) %>' 
                                           style="text-decoration: none; color: inherit; flex: 1; display: flex; flex-direction: column;">
                                            
                                            <h5 class="book-title"><%# Eval("Title") %></h5>
                                            <p class="book-author"><%# Eval("Author") %></p>
                                            
                                            <div class="book-badges">
                                                <span class="category-badge"><%# Eval("Category") %></span>
                                                <%# !string.IsNullOrEmpty(Eval("Tag")?.ToString()) ? "<span class='tag-badge'>#" + Eval("Tag") + "</span>" : "" %>
                                            </div>
                                        </a>
                                        
                                        <div class="book-actions">
                                            <asp:Button ID="btnRecommend" runat="server"
                                                Text='<%# String.Format("{0} ❤️", Eval("Recommendations")) %>'
                                                CommandName="Recommend"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# "book-action-btn btn-recommend" + (Convert.ToBoolean(Eval("IsRecommended")) ? " active" : "") %>'
                                                OnClientClick='<%# "return storeScrollPosition(\"" + Eval("DocumentId") + "\");" %>' />
                                            <asp:Button ID="btnFavorite" runat="server"
                                                Text="⭐"
                                                CommandName="Favorite"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# "book-action-btn btn-favorite" + (Convert.ToBoolean(Eval("IsFavorited")) ? " active" : "") %>'
                                                OnClientClick='<%# "return storeScrollPosition(\"" + Eval("DocumentId") + "\");" %>' />
                                        </div>
                                    </div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </div>
                                </FooterTemplate>
                            </asp:Repeater>
                        </asp:Panel>

                        <asp:Panel ID="pnlNewest" runat="server" CssClass="book-section">
                            <div class="section-header section-newest">
                                <h3 class="section-title">Newest Books</h3>
                            </div>
                            <asp:Repeater ID="RepNewest" runat="server" OnItemCommand="Repeater_ItemCommand">
                                <HeaderTemplate>
                                    <div class="books-grid">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div class="book-card" id="book-card-<%# Eval("DocumentId") %>" style="--card-index: <%# Container.ItemIndex %>;">
                                        <div class="book-icon"></div>
                                        
                                        <a href='<%# "PreviewBook.aspx?pdfUrl=" + HttpUtility.UrlEncode(Eval("PdfUrl").ToString()) %>' 
                                           style="text-decoration: none; color: inherit; flex: 1; display: flex; flex-direction: column;">
                                            
                                            <h5 class="book-title"><%# Eval("Title") %></h5>
                                            <p class="book-author"><%# Eval("Author") %></p>
                                            
                                            <div class="book-badges">
                                                <span class="category-badge"><%# Eval("Category") %></span>
                                                <%# !string.IsNullOrEmpty(Eval("Tag")?.ToString()) ? "<span class='tag-badge'>#" + Eval("Tag") + "</span>" : "" %>
                                            </div>
                                        </a>
                                        
                                        <div class="book-actions">
                                            <asp:Button ID="btnRecommend" runat="server"
                                                Text='<%# String.Format("{0} ❤️", Eval("Recommendations")) %>'
                                                CommandName="Recommend"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# "book-action-btn btn-recommend" + (Convert.ToBoolean(Eval("IsRecommended")) ? " active" : "") %>'
                                                OnClientClick='<%# "return storeScrollPosition(\"" + Eval("DocumentId") + "\");" %>' />
                                            <asp:Button ID="btnFavorite" runat="server"
                                                Text="⭐"
                                                CommandName="Favorite"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# "book-action-btn btn-favorite" + (Convert.ToBoolean(Eval("IsFavorited")) ? " active" : "") %>'
                                                OnClientClick='<%# "return storeScrollPosition(\"" + Eval("DocumentId") + "\");" %>' />
                                        </div>
                                    </div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </div>
                                </FooterTemplate>
                            </asp:Repeater>
                        </asp:Panel>

                        <asp:Panel ID="pnlMostRecommended" runat="server" CssClass="book-section">
                            <div class="section-header section-recommended">
                                <h3 class="section-title">Most Recommended</h3>
                            </div>
                            <asp:Repeater ID="RepMostRecommended" runat="server" OnItemCommand="Repeater_ItemCommand">
                                <HeaderTemplate>
                                    <div class="books-grid">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div class="book-card" id="book-card-<%# Eval("DocumentId") %>" style="--card-index: <%# Container.ItemIndex %>;">
                                        <div class="book-icon"></div>
                                        
                                        <a href='<%# "PreviewBook.aspx?pdfUrl=" + HttpUtility.UrlEncode(Eval("PdfUrl").ToString()) %>' 
                                           style="text-decoration: none; color: inherit; flex: 1; display: flex; flex-direction: column;">
                                            
                                            <h5 class="book-title"><%# Eval("Title") %></h5>
                                            <p class="book-author"><%# Eval("Author") %></p>
                                            
                                            <div class="book-badges">
                                                <span class="category-badge"><%# Eval("Category") %></span>
                                                <%# !string.IsNullOrEmpty(Eval("Tag")?.ToString()) ? "<span class='tag-badge'>#" + Eval("Tag") + "</span>" : "" %>
                                            </div>
                                        </a>
                                        
                                        <div class="book-actions">
                                            <asp:Button ID="btnRecommend" runat="server"
                                                Text='<%# String.Format("{0} ❤️", Eval("Recommendations")) %>'
                                                CommandName="Recommend"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# "book-action-btn btn-recommend" + (Convert.ToBoolean(Eval("IsRecommended")) ? " active" : "") %>'
                                                OnClientClick='<%# "return storeScrollPosition(\"" + Eval("DocumentId") + "\");" %>' />
                                            <asp:Button ID="btnFavorite" runat="server"
                                                Text="⭐"
                                                CommandName="Favorite"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# "book-action-btn btn-favorite" + (Convert.ToBoolean(Eval("IsFavorited")) ? " active" : "") %>'
                                                OnClientClick='<%# "return storeScrollPosition(\"" + Eval("DocumentId") + "\");" %>' />
                                        </div>
                                    </div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </div>
                                </FooterTemplate>
                            </asp:Repeater>
                        </asp:Panel>

                        <asp:Panel ID="pnlAlphabetical" runat="server" CssClass="book-section">
                            <div class="section-header section-alphabetical">
                                <h3 class="section-title">All Books (A-Z)</h3>
                            </div>
                            <asp:Repeater ID="RepAlphabetical" runat="server" OnItemCommand="Repeater_ItemCommand">
                                <HeaderTemplate>
                                    <div class="books-grid">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div class="book-card" id="book-card-<%# Eval("DocumentId") %>" style="--card-index: <%# Container.ItemIndex %>;">
                                        <div class="book-icon"></div>
                                        
                                        <a href='<%# "PreviewBook.aspx?pdfUrl=" + HttpUtility.UrlEncode(Eval("PdfUrl").ToString()) %>' 
                                           style="text-decoration: none; color: inherit; flex: 1; display: flex; flex-direction: column;">
                                            
                                            <h5 class="book-title"><%# Eval("Title") %></h5>
                                            <p class="book-author"><%# Eval("Author") %></p>
                                            
                                            <div class="book-badges">
                                                <span class="category-badge"><%# Eval("Category") %></span>
                                                <%# !string.IsNullOrEmpty(Eval("Tag")?.ToString()) ? "<span class='tag-badge'>#" + Eval("Tag") + "</span>" : "" %>
                                            </div>
                                        </a>
                                        
                                        <div class="book-actions">
                                            <asp:Button ID="btnRecommend" runat="server"
                                                Text='<%# String.Format("{0} ❤️", Eval("Recommendations")) %>'
                                                CommandName="Recommend"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# "book-action-btn btn-recommend" + (Convert.ToBoolean(Eval("IsRecommended")) ? " active" : "") %>'
                                                OnClientClick='<%# "return storeScrollPosition(\"" + Eval("DocumentId") + "\");" %>' />
                                            <asp:Button ID="btnFavorite" runat="server"
                                                Text="⭐"
                                                CommandName="Favorite"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# "book-action-btn btn-favorite" + (Convert.ToBoolean(Eval("IsFavorited")) ? " active" : "") %>'
                                                OnClientClick='<%# "return storeScrollPosition(\"" + Eval("DocumentId") + "\");" %>' />
                                        </div>
                                    </div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </div>
                                </FooterTemplate>
                            </asp:Repeater>
                        </asp:Panel>

                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <script>
        function storeScrollPosition(bookId) {
            console.log('Storing scroll position for book:', bookId);
            
            document.getElementById('<%= hdnScrollToBook.ClientID %>').value = bookId;
            
            return true;
        }

        function scrollToStoredBook() {
            var hiddenField = document.getElementById('<%= hdnScrollToBook.ClientID %>');
            if (hiddenField && hiddenField.value) {
                var bookId = hiddenField.value;
                var bookCard = document.getElementById('book-card-' + bookId);
                
                if (bookCard) {
                    console.log('Scrolling to book:', bookId);
                    
                    bookCard.scrollIntoView({
                        behavior: 'smooth',
                        block: 'center',
                        inline: 'nearest'
                    });
                    
                    bookCard.style.boxShadow = '0 0 20px rgba(103, 126, 234, 0.5)';
                    setTimeout(function() {
                        bookCard.style.boxShadow = '';
                    }, 2000);
                    
                    hiddenField.value = '';
                }
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            console.log('Library page loaded');
            
            setTimeout(scrollToStoredBook, 100);
        });

        window.addEventListener('load', function() {
            setTimeout(scrollToStoredBook, 200);
        });

        function addClickEffect(button) {
            console.log('Button clicked:', button.id);

            button.classList.add('clicked');

            setTimeout(function () {
                button.classList.remove('clicked');
            }, 600);

            return true;
        }

        $(document).ready(function () {
            $('.book-action-btn').off('click.bs.button');
        });
    </script>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>