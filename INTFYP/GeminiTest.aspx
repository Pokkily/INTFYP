<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="GeminiTest.aspx.cs" Inherits="YourNamespace.GeminiTest" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Gemini API Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            line-height: 1.6;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        .input-area, .output-area {
            margin-bottom: 20px;
        }
        textarea {
            width: 100%;
            height: 150px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        button {
            background-color: #4285f4;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #3367d6;
        }
        .response {
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 4px;
            white-space: pre-wrap;
        }
        .error {
            color: #d32f2f;
            background-color: #fde0e0;
            padding: 10px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Gemini API Test</h1>
        <form id="form1" runat="server">
            <div class="input-area">
                <h3>Enter your prompt:</h3>
                <asp:TextBox ID="txtPrompt" runat="server" TextMode="MultiLine" placeholder="Type your question or prompt here..."></asp:TextBox>
            </div>
            <div>
                <asp:Button ID="btnSubmit" runat="server" Text="Send to Gemini" OnClick="btnSubmit_Click" />
            </div>
            <div class="output-area">
                <h3>Response:</h3>
                <div class="response">
                    <asp:Literal ID="litResponse" runat="server"></asp:Literal>
                </div>
            </div>
            <div>
                <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false"></asp:Label>
            </div>
        </form>
    </div>
</body>
</html>