<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="YourProjectNamespace.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login | Your Application</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card shadow">
                        <div class="card-header text-center bg-primary text-white">
                            <h4>Login to Your Account</h4>
                        </div>
                        <div class="card-body">
                            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none" Visible="false"></asp:Label>

                            <div class="mb-3">
                                <label for="<%= txtUsernameOrEmail.ClientID %>" class="form-label">Username or Email</label>
                                <asp:TextBox ID="txtUsernameOrEmail" runat="server" CssClass="form-control" placeholder="Enter username or email"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label for="<%= txtPassword.ClientID %>" class="form-label">Password</label>
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Enter password"></asp:TextBox>
                            </div>

                            <div class="d-grid">
                                <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" CssClass="btn btn-primary" />
                            </div>

                            <div class="text-center mt-3">
                                <p>Don't have an account? <a href="Register.aspx">Register</a></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
