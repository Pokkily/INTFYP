<%@ Page Async="true" Title="Library" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Library.aspx.cs" Inherits="INTFYP.Library" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Library
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Design System Variables */
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --glass-border: rgba(255, 255, 255, 0.2);
            --text-primary: #2c3e50;
            --text-secondary: #7f8c8d;
            --spacing-xs: 8px;
            --spacing-sm: 15px;
            --spacing-md: 20px;
            --spacing-lg: 25px;
            --spacing-xl: 30px;
        }

        /* Glass Morphism Effects */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .glass-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
        }

        /* Page Header */
        .page-header {
            background: var(--primary-gradient);
            color: rgba(255, 255, 255, 0.9);
            border-radius: 20px;
            padding: var(--spacing-lg);
            margin-bottom: var(--spacing-lg);
            animation: fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* Animations */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes cardEntrance {
            from { opacity: 0; transform: translateY(50px) rotate(2deg); }
            to { opacity: 1; transform: translateY(0) rotate(0deg); }
        }

        /* Buttons */
        .btn-primary {
            background: var(--primary-gradient);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            border: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(103, 126, 234, 0.4);
        }

        .btn-dark {
            background: #2c3e50;
            border-radius: 25px;
            transition: all 0.3s ease;
        }

        /* Custom Button Styles */
        .btn-lavender {
            background-color: #d8b5f0;
            color: var(--text-primary);
            border-radius: 20px;
            transition: all 0.3s ease;
        }

        .btn-young-sage {
            background-color: #9caf88;
            color: var(--text-primary);
            border-radius: 20px;
            transition: all 0.3s ease;
        }

        .btn-outline-black {
            background-color: transparent;
            color: var(--text-primary);
            border: 1px solid var(--text-primary);
            border-radius: 20px;
            transition: all 0.3s ease;
        }

        .btn-outline-black:hover {
            background-color: var(--text-primary);
            color: white;
        }

        /* Search Input */
        .glass-input {
            background: var(--glass-bg);
            backdrop-filter: blur(5px);
            border: 1px solid var(--glass-border);
            border-radius: 30px;
            padding: 10px 20px;
        }

        /* Badge */
        .category-badge {
            background: rgba(103, 126, 234, 0.1);
            color: #667eea;
            border-radius: 20px;
            padding: 5px 12px;
            font-size: 0.8rem;
            display: inline-block;
            margin-bottom: var(--spacing-sm);
        }

        /* Enhanced Book Card Styles */
        .book-card {
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            animation: cardEntrance 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards;
            opacity: 0;
        }

        .book-card-content {
            padding: var(--spacing-md);
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .book-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            min-height: 3em;
            line-height: 1.4;
        }

        .book-author {
            color: var(--text-secondary);
            font-size: 0.9rem;
            margin-bottom: var(--spacing-sm);
            display: -webkit-box;
            -webkit-line-clamp: 1;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .book-actions {
            margin-top: auto;
            padding-top: var(--spacing-sm);
            display: flex;
            gap: var(--spacing-xs);
        }

        .btn-sm {
            padding: 0.35rem 0.75rem;
            font-size: 0.85rem;
            white-space: nowrap;
        }

        /* Responsive Grid */
        @media (max-width: 768px) {
            .book-title {
                font-size: 1rem;
            }
            .book-author {
                font-size: 0.85rem;
            }
        }
    </style>

    <!-- Header with Gradient Background -->
    <section class="page-header text-center">
        <div class="container">
            <h1 class="display-5 fw-bold">Welcome to Library</h1>
            <p class="lead">All Materials You Need</p>
        </div>
    </section>

    <div class="container mb-5">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 mb-4">
                <div class="glass-card p-4 mb-4">
                    <h5 class="fw-bold mb-3">Search by Category</h5>
                    <asp:TextBox ID="txtCategorySearch" runat="server" 
                        CssClass="glass-input form-control mb-3"
                        placeholder="Type category..." AutoPostBack="true"
                        OnTextChanged="txtCategorySearch_TextChanged" />

                    <div class="d-grid gap-2">
                        <button type="button" class="btn btn-primary" onclick="location.href='FavBooks.aspx';">Favorite Book</button>
                        <button type="button" class="btn btn-primary" onclick="location.href='CitationGenerator.aspx';">Citation Generator</button>
                    </div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-9">
                <div class="glass-card p-4 mb-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <h3 class="fw-bold mb-0">Books</h3>
                        <asp:TextBox ID="txtBookSearch" runat="server" 
                            CssClass="glass-input form-control"
                            placeholder="Search by title/author..." AutoPostBack="true"
                            OnTextChanged="txtBookSearch_TextChanged" />
                    </div>
                </div>

                <asp:Repeater ID="Repeater1" runat="server" OnItemCommand="Repeater1_ItemCommand">
                    <HeaderTemplate>
                        <div class="row row-cols-1 row-cols-md-3 g-4">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="col">
                            <div class="glass-card book-card h-100" 
                                style='animation-delay: calc(<%# Container.ItemIndex %> * 0.1s)'>
                                <a href='<%# "PreviewBook.aspx?pdfUrl=" + HttpUtility.UrlEncode(Eval("PdfUrl").ToString()) %>' 
                                   style="text-decoration: none; color: inherit;">
                                    <div class="book-card-content">
                                        <h5 class="book-title"><%# Eval("Title") %></h5>
                                        <p class="book-author"><%# Eval("Author") %></p>
                                        <span class="category-badge">#<%# Eval("Category") %></span>
                                        <div class="book-actions">
                                            <asp:Button ID="btnRecommend" runat="server"
                                                Text='<%# String.Format("{0} ❤️", Eval("Recommendations")) %>'
                                                CommandName="Recommend"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# (bool)Eval("IsRecommended") ? "btn btn-lavender btn-sm" : "btn btn-outline-black btn-sm" %>' />
                                            <asp:Button ID="btnFavorite" runat="server"
                                                Text="⭐"
                                                CommandName="Favorite"
                                                CommandArgument='<%# Eval("DocumentId") %>'
                                                CssClass='<%# (bool)Eval("IsFavorited") ? "btn btn-young-sage btn-sm" : "btn btn-outline-black btn-sm" %>' />
                                        </div>
                                    </div>
                                </a>
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

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Add hover effects to all glass cards
            const cards = document.querySelectorAll('.glass-card');
            cards.forEach(card => {
                card.addEventListener('mouseenter', () => {
                    card.style.transform = 'translateY(-8px) scale(1.02)';
                    card.style.boxShadow = '0 15px 35px rgba(0, 0, 0, 0.15)';
                });
                card.addEventListener('mouseleave', () => {
                    card.style.transform = '';
                    card.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.1)';
                });
            });
        });
    </script>
</asp:Content>