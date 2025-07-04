<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Register.aspx.cs" Inherits="YourProjectNamespace.Register" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Register</title>
    <style>
        body { font-family: 'Segoe UI'; background: #f8f9fa; }
        .container { max-width: 600px; margin: auto; padding: 20px; background: white; border-radius: 10px; box-shadow: 0 0 10px #ccc; margin-top: 30px; }
        input, select { width: 100%; margin: 5px 0 15px; padding: 8px; border: 1px solid #ccc; border-radius: 5px; }
        button { width: 100%; padding: 10px; background: #28a745; color: white; border: none; border-radius: 5px; }
        .msg { text-align: center; color: red; margin-top: 10px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2 style="text-align:center;">Register</h2>

            <asp:TextBox ID="txtFirstName" runat="server" Placeholder="First Name" />
            <asp:TextBox ID="txtLastName" runat="server" Placeholder="Last Name" />
            <asp:TextBox ID="txtUsername" runat="server" Placeholder="Username" />
            <asp:TextBox ID="txtEmail" runat="server" Placeholder="Email" TextMode="Email" />
            <asp:TextBox ID="txtPassword" runat="server" Placeholder="Password" TextMode="Password" />
            <asp:TextBox ID="txtPhone" runat="server" Placeholder="Phone Number" />
            <asp:DropDownList ID="ddlGender" runat="server">
                <asp:ListItem Text="Select Gender" Value="" />
                <asp:ListItem Text="Male" Value="Male" />
                <asp:ListItem Text="Female" Value="Female" />
                <asp:ListItem Text="Other" Value="Other" />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlPosition" runat="server">
                <asp:ListItem Text="Select Position" Value="" />
                <asp:ListItem Text="Student" Value="Student" />
                <asp:ListItem Text="Teacher" Value="Teacher" />
            </asp:DropDownList>
            <asp:TextBox ID="txtBirthdate" runat="server" Placeholder="Birthdate (yyyy-mm-dd)" TextMode="Date" />
            <asp:TextBox ID="txtAddress" runat="server" Placeholder="Home Address" />

            <asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click" />
            <asp:Label ID="lblMessage" runat="server" CssClass="msg" />
        </div>
    </form>
</body>
</html>
