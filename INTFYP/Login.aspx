<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="YourProjectNamespace.Login" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login | Your Application</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary-color: #4e73df;
            --secondary-color: #f8f9fc;
            --success-color: #1cc88a;
            --danger-color: #e74a3b;
            --warning-color: #f6c23e;
        }
        
        body {
            background-color: var(--secondary-color);
            font-family: 'Nunito', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }
        
        .login-container {
            max-width: 500px;
            margin: 5rem auto;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            border-radius: 0.35rem;
            overflow: hidden;
        }
        
        .login-header {
            background-color: var(--primary-color);
            color: white;
            padding: 1.5rem;
            text-align: center;
        }
        
        .login-body {
            background-color: white;
            padding: 2rem;
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(78, 115, 223, 0.25);
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-primary:hover {
            background-color: #3a5bc7;
            border-color: #3a5bc7;
        }
        
        .reset-code-input {
            letter-spacing: 2px;
            font-size: 1.5rem;
            text-align: center;
        }
        
        .password-strength-meter {
            height: 5px;
            background-color: #e9ecef;
            border-radius: 3px;
            margin: 10px 0;
        }
        
        .strength-indicator {
            height: 100%;
            width: 0;
            border-radius: 3px;
            transition: width 0.3s, background-color 0.3s;
        }
        
        .requirement-list {
            list-style-type: none;
            padding-left: 1.5rem;
            font-size: 0.9rem;
        }
        
        .requirement-list li {
            position: relative;
            margin-bottom: 0.3rem;
        }
        
        .requirement-list li:before {
            position: absolute;
            left: -1.5rem;
            content: "○";
            color: #6c757d;
        }
        
        .requirement-list li.valid:before {
            content: "✓";
            color: var(--success-color);
        }
        
        .back-button {
            position: absolute;
            top: 1rem;
            left: 1rem;
            z-index: 10;
        }
        
        .success-icon {
            font-size: 4rem;
            color: var(--success-color);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <!-- Login Panel -->
            <asp:Panel ID="loginPanel" runat="server">
                <div class="login-header">
                    <h4><i class="bi bi-person-circle"></i> Login to Your Account</h4>
                </div>
                <div class="login-body">
                    <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none" Visible="false"></asp:Label>
                    
                    <div class="mb-3">
                        <label for="<%= txtUsernameOrEmail.ClientID %>" class="form-label">Username or Email</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-person"></i></span>
                            <asp:TextBox ID="txtUsernameOrEmail" runat="server" CssClass="form-control" placeholder="Enter username or email"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtPassword.ClientID %>" class="form-label">Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock"></i></span>
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Enter password"></asp:TextBox>
                            <button class="btn btn-outline-secondary toggle-password" type="button">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                    </div>
                    
                    <div class="d-grid mb-3">
                        <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" CssClass="btn btn-primary btn-lg" />
                    </div>
                    
                    <div class="text-center">
                        <asp:LinkButton ID="btnShowForgotPassword" runat="server" OnClick="btnShowForgotPassword_Click" CssClass="text-primary">
                            <i class="bi bi-key"></i> Forgot Password?
                        </asp:LinkButton>
                    </div>
                    
                    <div class="text-center mt-3">
                        <p>Don't have an account? <a href="Register.aspx">Register</a></p>
                    </div>
                </div>
            </asp:Panel>

            <!-- Forgot Password Panel -->
            <asp:Panel ID="forgotPasswordPanel" runat="server" Visible="false">
                <div class="login-header position-relative">
                    <asp:LinkButton ID="btnBackToLogin" runat="server" OnClick="btnBackToLogin_Click" CssClass="btn btn-link text-white back-button">
                        <i class="bi bi-arrow-left"></i>
                    </asp:LinkButton>
                    <h4><i class="bi bi-key"></i> Forgot Password</h4>
                </div>
                <div class="login-body">
                    <asp:Label ID="Label1" runat="server" CssClass="alert d-none" Visible="false"></asp:Label>
                    
                    <p class="text-muted mb-4">Enter your email address and we'll send you a reset code.</p>
                    
                    <div class="mb-3">
                        <label for="<%= txtForgotEmail.ClientID %>" class="form-label">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                            <asp:TextBox ID="txtForgotEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="Enter your email"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="d-grid">
                        <asp:Button ID="btnSendResetCode" runat="server" Text="Send Reset Code" OnClick="btnSendResetCode_Click" CssClass="btn btn-primary btn-lg" />
                    </div>
                </div>
            </asp:Panel>

            <!-- Reset Password Panel -->
            <asp:Panel ID="resetPasswordPanel" runat="server" Visible="false">
                <div class="login-header position-relative">
                    <asp:LinkButton ID="btnBackToForgot" runat="server" OnClick="btnBackToLogin_Click" CssClass="btn btn-link text-white back-button">
                        <i class="bi bi-arrow-left"></i>
                    </asp:LinkButton>
                    <h4><i class="bi bi-shield-lock"></i> Reset Password</h4>
                </div>
                <div class="login-body">
                    <asp:Label ID="Label2" runat="server" CssClass="alert d-none" Visible="false"></asp:Label>
                    
                    <div class="text-center mb-4">
                        <asp:Label ID="lblResetEmail" runat="server" CssClass="text-muted"></asp:Label>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtResetCode.ClientID %>" class="form-label">Reset Code</label>
                        <asp:TextBox ID="txtResetCode" runat="server" CssClass="form-control reset-code-input" MaxLength="6" placeholder="123456"></asp:TextBox>
                        <small class="form-text text-muted">Enter the 6-digit code sent to your email</small>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtNewPassword.ClientID %>" class="form-label">New Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock"></i></span>
                            <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Enter new password"></asp:TextBox>
                            <button class="btn btn-outline-secondary toggle-new-password" type="button">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                        <div class="password-strength-meter mt-2">
                            <div class="strength-indicator" id="newPasswordStrengthIndicator"></div>
                        </div>
                        <ul class="requirement-list mt-2">
                            <li id="newLengthReq">At least 8 characters</li>
                            <li id="newUpperReq">At least 1 uppercase letter</li>
                            <li id="newLowerReq">At least 1 lowercase letter</li>
                            <li id="newNumberReq">At least 1 number</li>
                            <li id="newSpecialReq">At least 1 special character</li>
                        </ul>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtConfirmNewPassword.ClientID %>" class="form-label">Confirm New Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                            <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Confirm new password"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="d-grid mb-3">
                        <asp:Button ID="btnResetPassword" runat="server" Text="Reset Password" OnClick="btnResetPassword_Click" CssClass="btn btn-primary btn-lg" />
                    </div>
                    
                    <div class="text-center">
                        <p>Didn't receive the code? <asp:LinkButton ID="btnResendResetCode" runat="server" OnClick="btnResendResetCode_Click" CssClass="text-primary">Resend Code</asp:LinkButton></p>
                    </div>
                </div>
            </asp:Panel>

            <!-- Success Panel -->
            <asp:Panel ID="successPanel" runat="server" Visible="false">
                <div class="login-header">
                    <h4><i class="bi bi-check-circle"></i> Password Reset Complete</h4>
                </div>
                <div class="login-body text-center">
                    <div class="mb-4">
                        <i class="bi bi-check-circle-fill success-icon"></i>
                    </div>
                    <h5 class="mb-3">Password Reset Successfully!</h5>
                    <p class="text-muted mb-4">Your password has been reset successfully. You can now login with your new password.</p>
                    <div class="d-grid">
                        <asp:Button ID="btnLoginFromSuccess" runat="server" Text="Continue to Login" OnClick="btnLoginFromSuccess_Click" CssClass="btn btn-primary btn-lg" />
                    </div>
                </div>
            </asp:Panel>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            // Toggle password visibility for login
            $('.toggle-password').click(function () {
                const icon = $(this).find('i');
                const input = $(this).closest('.input-group').find('input');

                if (input.attr('type') === 'password') {
                    input.attr('type', 'text');
                    icon.removeClass('bi-eye').addClass('bi-eye-slash');
                } else {
                    input.attr('type', 'password');
                    icon.removeClass('bi-eye-slash').addClass('bi-eye');
                }
            });

            // Toggle password visibility for new password
            $('.toggle-new-password').click(function () {
                const icon = $(this).find('i');
                const input = $(this).closest('.input-group').find('input');

                if (input.attr('type') === 'password') {
                    input.attr('type', 'text');
                    icon.removeClass('bi-eye').addClass('bi-eye-slash');
                } else {
                    input.attr('type', 'password');
                    icon.removeClass('bi-eye-slash').addClass('bi-eye');
                }
            });

            // Password strength indicator for new password
            $('#<%= txtNewPassword.ClientID %>').on('input', function () {
                const password = $(this).val();

                // Check requirements
                const hasMinLength = password.length >= 8;
                const hasUpperCase = /[A-Z]/.test(password);
                const hasLowerCase = /[a-z]/.test(password);
                const hasNumbers = /\d/.test(password);
                const hasSpecialChars = /[!@#$%^&*(),.?":{}|<>]/.test(password);

                // Update requirement indicators
                $('#newLengthReq').toggleClass('valid', hasMinLength);
                $('#newUpperReq').toggleClass('valid', hasUpperCase);
                $('#newLowerReq').toggleClass('valid', hasLowerCase);
                $('#newNumberReq').toggleClass('valid', hasNumbers);
                $('#newSpecialReq').toggleClass('valid', hasSpecialChars);

                // Calculate strength
                const strength = [hasMinLength, hasUpperCase, hasLowerCase, hasNumbers, hasSpecialChars]
                    .filter(Boolean).length;
                const strengthPercent = (strength / 5) * 100;

                // Update strength meter
                const $indicator = $('#newPasswordStrengthIndicator');
                $indicator.css('width', strengthPercent + '%');

                // Set meter color
                if (strength <= 2) {
                    $indicator.css('background-color', '#e74a3b');
                } else if (strength <= 4) {
                    $indicator.css('background-color', '#f6c23e');
                } else {
                    $indicator.css('background-color', '#1cc88a');
                }
            });

            // Confirm password match validation
            $('#<%= txtConfirmNewPassword.ClientID %>').on('input', function () {
                const password = $('#<%= txtNewPassword.ClientID %>').val();
                const confirmPassword = $(this).val();

                if (confirmPassword !== '' && password !== confirmPassword) {
                    $(this).addClass('is-invalid');
                } else {
                    $(this).removeClass('is-invalid');
                }
            });

            // Reset code input validation
            $('#<%= txtResetCode.ClientID %>').on('input', function () {
                const code = $(this).val();
                if (code.length === 6 && /^\d+$/.test(code)) {
                    $(this).removeClass('is-invalid');
                } else {
                    $(this).addClass('is-invalid');
                }
            });

            // Email validation
            $('#<%= txtForgotEmail.ClientID %>').on('blur', function () {
                const email = $(this).val().trim();
                if (email !== '' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                    $(this).addClass('is-invalid');
                } else {
                    $(this).removeClass('is-invalid');
                }
            });

            // Auto-focus appropriate fields when panels are shown
            if ($('#<%= resetPasswordPanel.ClientID %>').is(':visible')) {
                $('#<%= txtResetCode.ClientID %>').focus();
            } else if ($('#<%= forgotPasswordPanel.ClientID %>').is(':visible')) {
                $('#<%= txtForgotEmail.ClientID %>').focus();
            } else if ($('#<%= loginPanel.ClientID %>').is(':visible')) {
                $('#<%= txtUsernameOrEmail.ClientID %>').focus();
            }

            // Form validation before submit
            $('form').on('submit', function(e) {
                let isValid = true;
                
                // Validate forgot password form
                if ($('#<%= forgotPasswordPanel.ClientID %>').is(':visible')) {
                    const email = $('#<%= txtForgotEmail.ClientID %>').val().trim();
                    if (email === '' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                        $('#<%= txtForgotEmail.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                }
                
                // Validate reset password form
                if ($('#<%= resetPasswordPanel.ClientID %>').is(':visible')) {
                    const resetCode = $('#<%= txtResetCode.ClientID %>').val().trim();
                    const newPassword = $('#<%= txtNewPassword.ClientID %>').val();
                    const confirmPassword = $('#<%= txtConfirmNewPassword.ClientID %>').val();
                    
                    if (resetCode.length !== 6 || !/^\d+$/.test(resetCode)) {
                        $('#<%= txtResetCode.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                    
                    if (newPassword.length < 8 || 
                        !/[A-Z]/.test(newPassword) || 
                        !/[a-z]/.test(newPassword) || 
                        !/\d/.test(newPassword) || 
                        !/[^A-Za-z0-9]/.test(newPassword)) {
                        $('#<%= txtNewPassword.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                    
                    if (newPassword !== confirmPassword) {
                        $('#<%= txtConfirmNewPassword.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                }
                
                // Validate login form
                if ($('#<%= loginPanel.ClientID %>').is(':visible')) {
                    const userInput = $('#<%= txtUsernameOrEmail.ClientID %>').val().trim();
                    const password = $('#<%= txtPassword.ClientID %>').val();
                    
                    if (userInput === '') {
                        $('#<%= txtUsernameOrEmail.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                    
                    if (password === '') {
                        $('#<%= txtPassword.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                }

                return isValid;
            });

            // Remove validation classes on input
            $('.form-control').on('input', function () {
                $(this).removeClass('is-invalid');
            });
        });
    </script>
</body>
</html>