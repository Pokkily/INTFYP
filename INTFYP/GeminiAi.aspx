<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="GeminiAi.aspx.cs" Inherits="INTFYP.GeminiAi" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Gemini AI Chat</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:TextBox ID="txtPrompt" runat="server" TextMode="MultiLine" Rows="5" Columns="60" />
            <asp:Button ID="btnSend" runat="server" Text="Ask Gemini" OnClick="btnSend_Click" />
            <br /><br />
            <asp:Label ID="lblResponse" runat="server" Text=""></asp:Label>
        </div>
    </form>
</body>
</html>
