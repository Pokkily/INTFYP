<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="INTFYP.Register" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Register Account</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(to right, #dbe9f4, #ffffff);
            margin: 0;
            padding: 0;
        }

        .container {
            width: 500px;
            margin: 40px auto;
            padding: 30px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }

        h2 {
            text-align: center;
            color: #333;
        }

        label {
            margin-top: 12px;
            display: block;
            font-weight: 600;
            color: #444;
        }

        input, select {
            width: 100%;
            padding: 10px;
            margin-top: 6px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
        }

        .hint {
            font-size: 12px;
            color: #888;
        }

        .error-icon {
            color: red;
            margin-right: 5px;
        }

        .success {
            color: green;
            text-align: center;
            margin-top: 15px;
        }

        .error {
            color: red;
            text-align: center;
            margin-top: 15px;
        }

        button {
            width: 100%;
            padding: 12px;
            background-color: #007bff;
            border: none;
            color: white;
            font-size: 16px;
            border-radius: 6px;
            margin-top: 20px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #0056b3;
        }

        .g-recaptcha {
            margin-top: 15px;
            text-align: center;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2>Create Your Account</h2>

            <asp:Label runat="server" ID="lblMessage" />

            <label>First Name</label>
            <asp:TextBox ID="txtFirstName" runat="server" />

            <label>Last Name</label>
            <asp:TextBox ID="txtLastName" runat="server" />

            <label>Username</label>
            <asp:TextBox ID="txtUsername" runat="server" />

            <label>Phone Number</label>
            <asp:TextBox ID="txtPhone" runat="server" />

            <label>Email</label>
            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />

            <label>Password</label>
            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
            <span class="hint">Must be at least 6 characters</span>

            <label>Confirm Password</label>
            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" />

            <label>Gender</label>
            <asp:DropDownList ID="ddlGender" runat="server">
                <asp:ListItem Text="Male" />
                <asp:ListItem Text="Female" />
                <asp:ListItem Text="Other" />
            </asp:DropDownList>

            <label>Position</label>
            <asp:DropDownList ID="ddlPosition" runat="server">
                <asp:ListItem Text="Student" />
                <asp:ListItem Text="Teacher" />
            </asp:DropDownList>

            <label>Birthdate</label>
            <asp:TextBox ID="txtBirthdate" runat="server" TextMode="Date" />

            <label>Home Address</label>
            <asp:TextBox ID="txtAddress" runat="server" />

            <div class="g-recaptcha" data-sitekey="YOUR_RECAPTCHA_SITE_KEY"></div>

            <asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click" />
        </div>
    </form>
</body>
</html>
