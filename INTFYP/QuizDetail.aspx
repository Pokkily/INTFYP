<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="QuizDetail.aspx.cs" Inherits="YourProjectNamespace.QuizDetail" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Quiz Detail</title>
    <style>
        .container {
            max-width: 700px;
            margin: 50px auto;
            background: #fff;
            border: 1px solid #ccc;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        h2 {
            margin-bottom: 20px;
            color: #333;
        }

        #questionText {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
        }

        .rblOptions label {
            display: block;
            margin: 10px 0;
        }

        .btn-container {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            background: #007bff;
            color: #fff;
            border-radius: 6px;
            cursor: pointer;
        }

        .btn:disabled {
            background-color: #ccc;
            cursor: not-allowed;
        }

        .btn-submit {
            background-color: #28a745;
        }

        .quiz-image {
            max-width: 100%;
            max-height: 200px;
            margin-bottom: 15px;
            border-radius: 6px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">

            <!-- Question Text -->
            <div id="questionText" runat="server"></div>

            <!-- Optional Question Image -->
            <asp:Image ID="imgQuestionImage" runat="server" CssClass="quiz-image" Visible="false" />

            <!-- Options -->
            <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="rblOptions" />

            <!-- Navigation Buttons -->
            <div class="btn-container">
                <asp:Button ID="btnNext" runat="server" Text="Next Question" CssClass="btn" OnClick="btnNext_Click" />
                <asp:Button ID="btnSubmit" runat="server" Text="Submit Quiz" CssClass="btn btn-submit" Visible="false" OnClick="btnSubmit_Click" />
            </div>
        </div>
    </form>
</body>
</html>
