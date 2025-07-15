<%@ Page Title="Quiz" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" Async="true" CodeBehind="Quiz.aspx.cs" Inherits="YourProjectNamespace.Quiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .quiz-page {
            padding: 40px;
            font-family: 'Segoe UI', sans-serif;
            background-color: #f8f9fa;
            max-width: 1200px;
            margin: 0 auto;
        }

        .page-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .page-title {
            font-size: 28px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .page-subtitle {
            font-size: 16px;
            color: #7f8c8d;
            margin-bottom: 30px;
        }

        .search-container {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .search-box {
            display: flex;
            align-items: center;
            background: white;
            padding: 10px 15px;
            border-radius: 25px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            width: 350px;
        }

            .search-box i {
                color: #7f8c8d;
                margin-right: 10px;
            }

            .search-box input {
                border: none;
                outline: none;
                width: 100%;
                font-size: 14px;
            }

        .quiz-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
            margin-top: 20px;
        }

        .quiz-card {
            background-color: white;
            border-radius: 12px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: transform 0.3s ease;
        }

            .quiz-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 6px 12px rgba(0,0,0,0.15);
            }

        .quiz-header {
            background-color: #3498db;
            color: white;
            padding: 15px;
            font-weight: bold;
            text-align: center;
        }

        .quiz-body {
            padding: 20px;
        }

        .quiz-title {
            font-size: 18px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .quiz-meta {
            font-size: 14px;
            color: #7f8c8d;
            margin-bottom: 5px;
        }

        .quiz-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 20px;
            border-top: 1px solid #ecf0f1;
        }

        .quiz-code {
            font-size: 13px;
            color: #7f8c8d;
        }

        .play-button {
            background-color: #2ecc71;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 20px;
            cursor: pointer;
            font-weight: 500;
            transition: background-color 0.3s;
            text-decoration: none;
            display: inline-block;
        }

            .play-button:hover {
                background-color: #27ae60;
                color: white;
            }

        .no-results {
            text-align: center;
            color: #7f8c8d;
            padding: 40px;
            grid-column: 1 / -1;
        }

        @media (max-width: 768px) {
            .quiz-grid {
                grid-template-columns: 1fr;
            }

            .search-container {
                flex-direction: column;
                align-items: center;
            }

            .search-box {
                width: 100%;
            }
        }

        
        .quiz-image-container {
    width: 100%;
    height: 180px;
    background-color: #ecf0f1;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
}

.quiz-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-bottom: 1px solid #dcdcdc;
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
