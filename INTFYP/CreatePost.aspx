<%@ Page Title="Create Quiz" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="CreateQuiz.aspx.cs" Inherits="YourProjectNamespace.CreateQuiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        .form-group {
            margin-bottom: 20px;
        }

        .question-container {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 10px;
            background-color: #f8f9fa;
        }

        .option-input {
            margin-left: 20px;
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }

        .option-input input[type="text"] {
            margin-left: 8px;
        }

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
        }

        .btn-primary {
            background-color: #0d6efd;
            color: white;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
    </style>

    <h2>Create Quiz</h2>

    <div class="form-group">
        <label for="txtQuizTitle">Quiz Title</label><br />
        <asp:TextBox ID="txtQuizTitle" runat="server" CssClass="form-control" Width="400px" />
    </div>

    <asp:Repeater ID="rptQuestions" runat="server">
        <ItemTemplate>
            <div class="question-container">
                <h5>Question <%# Container.ItemIndex + 1 %></h5>
                <asp:TextBox ID="txtQuestion" runat="server" Text='<%# Eval("Question") %>' CssClass="form-control" TextMode="MultiLine" Rows="3" Width="100%" /><br /><br />
                <% for (int j = 0; j < 4; j++) { %>
                    <div class="option-input">
                        <asp:CheckBox ID="CheckBox1" runat="server" Checked='<%# ((List<bool>)Eval("IsCorrect"))[j] %>' />
                        <asp:TextBox ID="TextBox1" runat="server" Text='<%# ((List<string>)Eval("Options"))[j] %>' CssClass="form-control" Width="300px" />
                    </div>
                <% } %>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <div class="form-group">
        <asp:Button ID="btnAddQuestion" runat="server" Text="Add Question" CssClass="btn btn-secondary" OnClick="btnAddQuestion_Click" />
    </div>

    <div class="form-group">
        <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" CssClass="btn btn-primary" OnClick="btnSubmitQuiz_Click" />
    </div>
</asp:Content>
