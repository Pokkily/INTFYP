<%@ Page Title="Create Quiz" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="CreateQuiz.aspx.cs" Inherits="YourProjectNamespace.CreateQuiz" MaintainScrollPositionOnPostback="true" %>

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

        .btn-danger {
            background-color: #dc3545;
            color: white;
            margin-top: 10px;
        }

        .image-preview {
            max-width: 400px;
            margin-top: 10px;
            display: block;
        }

        .quiz-image-section {
            border: 2px dashed #ddd;
            padding: 20px;
            border-radius: 10px;
            background-color: #f8f9fa;
            margin-bottom: 30px;
        }

        .upload-success {
            color: green;
            font-weight: bold;
            margin-top: 10px;
        }
    </style>

    <h2>Create Quiz</h2>

    <div class="form-group">
        <label for="txtQuizTitle">Quiz Title</label><br />
        <asp:TextBox ID="txtQuizTitle" runat="server" CssClass="form-control" Width="400px" />
    </div>

    <div class="quiz-image-section">
        <div class="form-group">
            <label for="fileQuizImage">Quiz Image (Required)</label><br />
            <asp:FileUpload ID="fileQuizImage" runat="server" onchange="uploadQuizImage()" />
            <asp:Button ID="btnUploadQuizImage" runat="server" Text="Upload Image" 
                OnClick="btnUploadQuizImage_Click" CssClass="btn btn-secondary" 
                style="margin-left: 10px;" />
            <asp:Label ID="lblImageError" runat="server" ForeColor="Red" Visible="false"></asp:Label>
            <asp:Label ID="lblUploadSuccess" runat="server" CssClass="upload-success" Visible="false"></asp:Label>
            <br />
            <asp:Image ID="imgQuizPreview" runat="server" CssClass="image-preview" Visible="false" />
        </div>
    </div>

    <asp:UpdatePanel ID="UpdatePanelQuestions" runat="server">
        <ContentTemplate>
            <asp:Repeater ID="rptQuestions" runat="server" OnItemCommand="rptQuestions_ItemCommand" OnItemDataBound="rptQuestions_ItemDataBound">
                <ItemTemplate>
                    <div class="question-container">
                        <asp:Button ID="btnRemove" runat="server" Text="❌ Remove" CommandName="Remove" 
                            CommandArgument='<%# Container.ItemIndex %>' CssClass="btn btn-danger" />

                        <h5>Question <%# Container.ItemIndex + 1 %></h5>
                        <asp:TextBox ID="txtQuestion" runat="server" Text='<%# Eval("Question") %>' 
                            CssClass="form-control" TextMode="MultiLine" Rows="3" Width="100%" /><br /><br />

                        <div class="option-input">
                            <asp:CheckBox ID="chk0" runat="server" Checked='<%# ((List<bool>)Eval("IsCorrect"))[0] %>' />
                            <asp:TextBox ID="opt0" runat="server" Text='<%# ((List<string>)Eval("Options"))[0] %>' 
                                CssClass="form-control" Width="300px" />
                        </div>
                        <div class="option-input">
                            <asp:CheckBox ID="chk1" runat="server" Checked='<%# ((List<bool>)Eval("IsCorrect"))[1] %>' />
                            <asp:TextBox ID="opt1" runat="server" Text='<%# ((List<string>)Eval("Options"))[1] %>' 
                                CssClass="form-control" Width="300px" />
                        </div>
                        <div class="option-input">
                            <asp:CheckBox ID="chk2" runat="server" Checked='<%# ((List<bool>)Eval("IsCorrect"))[2] %>' />
                            <asp:TextBox ID="opt2" runat="server" Text='<%# ((List<string>)Eval("Options"))[2] %>' 
                                CssClass="form-control" Width="300px" />
                        </div>
                        <div class="option-input">
                            <asp:CheckBox ID="chk3" runat="server" Checked='<%# ((List<bool>)Eval("IsCorrect"))[3] %>' />
                            <asp:TextBox ID="opt3" runat="server" Text='<%# ((List<string>)Eval("Options"))[3] %>' 
                                CssClass="form-control" Width="300px" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <div class="form-group">
                <asp:Button ID="btnAddQuestion" runat="server" Text="Add Question" 
                    CssClass="btn btn-secondary" OnClick="btnAddQuestion_Click" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <div class="form-group">
        <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" 
            CssClass="btn btn-primary" OnClick="btnSubmitQuiz_Click" />
    </div>

    <script type="text/javascript">
        function uploadQuizImage() {
            // Auto-trigger upload when file is selected
            var fileUpload = document.getElementById('<%= fileQuizImage.ClientID %>');
            if (fileUpload.files.length > 0) {
                document.getElementById('<%= btnUploadQuizImage.ClientID %>').click();
            }
        }
    </script>
</asp:Content>