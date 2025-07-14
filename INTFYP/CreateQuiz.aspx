<%@ Page Title="Create Quiz" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="CreateQuiz.aspx.cs" Inherits="YourProjectNamespace.CreateQuiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        .form-container {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        
        .question-preview {
            margin-bottom: 20px;
            padding: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            background-color: #fff;
        }
        
        .question-image {
            max-width: 300px;
            max-height: 200px;
            margin: 10px 0;
        }
        
        .correct-option {
            font-weight: bold;
            color: green;
        }
        
        .error-message {
            color: red;
            margin: 10px 0;
        }
    </style>

    <h2>Create Quiz</h2>
    
    <div class="form-group">
        <label>Quiz Title</label>
        <asp:TextBox ID="txtQuizTitle" runat="server" CssClass="form-control"></asp:TextBox>
    </div>
    
    <asp:Label ID="lblError" runat="server" CssClass="error-message" Visible="false"></asp:Label>
    
    <div class="form-container">
        <h3>Add New Question</h3>
        
        <div class="form-group">
            <label>Question Text</label>
            <asp:TextBox ID="txtQuestion" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control"></asp:TextBox>
        </div>
        
        <div class="form-group">
            <label>Options</label>
            <div class="option-row">
                <asp:CheckBox ID="chkOption1" runat="server" />
                <asp:TextBox ID="txtOption1" runat="server" CssClass="form-control option-input"></asp:TextBox>
            </div>
            <div class="option-row">
                <asp:CheckBox ID="chkOption2" runat="server" />
                <asp:TextBox ID="txtOption2" runat="server" CssClass="form-control option-input"></asp:TextBox>
            </div>
            <div class="option-row">
                <asp:CheckBox ID="chkOption3" runat="server" />
                <asp:TextBox ID="txtOption3" runat="server" CssClass="form-control option-input"></asp:TextBox>
            </div>
            <div class="option-row">
                <asp:CheckBox ID="chkOption4" runat="server" />
                <asp:TextBox ID="txtOption4" runat="server" CssClass="form-control option-input"></asp:TextBox>
            </div>
        </div>
        
        <div class="form-group">
            <label>Question Image (Optional)</label>
            <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" />
        </div>
        
        <asp:Button ID="btnAddQuestion" runat="server" Text="Add Question" 
            CssClass="btn btn-primary" OnClick="btnAddQuestion_Click" />
    </div>
    
    <div class="questions-preview">
        <h3>Questions Preview</h3>
        <asp:Panel ID="pnlQuestionPreview" runat="server"></asp:Panel>
    </div>
    
    <div class="form-group">
        <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" 
            CssClass="btn btn-success" OnClick="btnSubmitQuiz_Click" />
    </div>
</asp:Content>