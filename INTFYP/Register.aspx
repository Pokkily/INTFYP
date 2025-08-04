<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Register.aspx.cs" Inherits="YourProjectNamespace.Register" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | Your Application</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary-color: #4e73df;
            --secondary-color: #f8f9fc;
            --success-color: #1cc88a;
            --danger-color: #e74a3b;
            --warning-color: #f6c23e;
            --info-color: #36b9cc;
        }
        
        body {
            background-color: var(--secondary-color);
            font-family: 'Nunito', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }
        
        .register-container {
            max-width: 800px;
            margin: 3rem auto;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            border-radius: 0.35rem;
            overflow: hidden;
        }
        
        .register-header {
            background-color: var(--primary-color);
            color: white;
            padding: 1.5rem;
            text-align: center;
        }
        
        .register-body {
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
        }
        
        .requirement-list li {
            position: relative;
            margin-bottom: 0.5rem;
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
        
        .otp-input {
            letter-spacing: 2px;
            font-size: 1.5rem;
            text-align: center;
        }
        
        .step-indicator {
            display: flex;
            justify-content: space-between;
            margin-bottom: 2rem;
        }
        
        .step {
            text-align: center;
            flex: 1;
            position: relative;
        }
        
        .step-number {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #e9ecef;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 10px;
            font-weight: bold;
        }
        
        .step.active .step-number {
            background-color: var(--primary-color);
            color: white;
        }
        
        .step.completed .step-number {
            background-color: var(--success-color);
            color: white;
        }
        
        .step-title {
            font-size: 0.9rem;
            color: #6c757d;
        }
        
        .step.active .step-title {
            color: var(--primary-color);
            font-weight: bold;
        }
        
        .step.completed .step-title {
            color: var(--success-color);
        }
        
        .step:not(:last-child)::after {
            content: "";
            position: absolute;
            top: 20px;
            left: 60%;
            width: 80%;
            height: 2px;
            background-color: #e9ecef;
            z-index: -1;
        }
        
        .step.completed:not(:last-child)::after {
            background-color: var(--success-color);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="register-container">
            <div class="register-header">
                <h2><i class="bi bi-person-plus"></i> Create Your Account</h2>
            </div>
            
            <div class="register-body">
                <!-- Step Indicator -->
                <div class="step-indicator">
                    <div class="step <%= registrationStep1.Visible ? "active" : registrationStep2.Visible || registrationComplete.Visible ? "completed" : "" %>">
                        <div class="step-number">1</div>
                        <div class="step-title">Registration</div>
                    </div>
                    <div class="step <%= registrationStep2.Visible ? "active" : registrationComplete.Visible ? "completed" : "" %>">
                        <div class="step-number">2</div>
                        <div class="step-title">OTP Verification</div>
                    </div>
                    <div class="step <%= registrationComplete.Visible ? "active" : "" %>">
                        <div class="step-number">3</div>
                        <div class="step-title">Complete</div>
                    </div>
                </div>
                
                <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none" Visible="false"></asp:Label>
                
                <!-- Step 1: Registration Form -->
                <asp:Panel ID="registrationStep1" runat="server">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="<%= txtFirstName.ClientID %>" class="form-label">First Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" placeholder="John"></asp:TextBox>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="<%= txtLastName.ClientID %>" class="form-label">Last Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" placeholder="Doe"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtUsername.ClientID %>" class="form-label">Username <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text">@</span>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="johndoe"></asp:TextBox>
                        </div>
                        <small class="form-text text-muted">3-20 characters, letters, numbers and underscores only</small>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtEmail.ClientID %>" class="form-label">Email <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="john@example.com"></asp:TextBox>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtPassword.ClientID %>" class="form-label">Password <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Create a password"></asp:TextBox>
                            <button class="btn btn-outline-secondary toggle-password" type="button">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                        <div class="password-strength-meter mt-2">
                            <div class="strength-indicator" id="strengthIndicator"></div>
                        </div>
                        <ul class="requirement-list mt-2">
                            <li id="lengthReq">At least 8 characters</li>
                            <li id="upperReq">At least 1 uppercase letter</li>
                            <li id="lowerReq">At least 1 lowercase letter</li>
                            <li id="numberReq">At least 1 number</li>
                            <li id="specialReq">At least 1 special character</li>
                        </ul>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtConfirmPassword.ClientID %>" class="form-label">Confirm Password <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Confirm your password"></asp:TextBox>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtPhone.ClientID %>" class="form-label">Phone Number</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="1234567890"></asp:TextBox>
                        <small class="form-text text-muted">Optional - digits only</small>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="<%= ddlGender.ClientID %>" class="form-label">Gender <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select Gender" Value="" Selected="True" />
                                <asp:ListItem Text="Male" Value="Male" />
                                <asp:ListItem Text="Female" Value="Female" />
                                <asp:ListItem Text="Other" Value="Other" />
                                <asp:ListItem Text="Prefer not to say" Value="Undisclosed" />
                            </asp:DropDownList>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="<%= ddlPosition.ClientID %>" class="form-label">Position <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlPosition" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select Position" Value="" Selected="True" />
                                <asp:ListItem Text="Student" Value="Student" />
                                <asp:ListItem Text="Teacher" Value="Teacher" />
                                <asp:ListItem Text="Administrator" Value="Administrator" />
                            </asp:DropDownList>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="<%= txtBirthdate.ClientID %>" class="form-label">Birthdate</label>
                            <asp:TextBox ID="txtBirthdate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtAddress.ClientID %>" class="form-label">Address</label>
                        <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" placeholder="Enter your address"></asp:TextBox>
                    </div>
                    
                    <div class="d-grid gap-2">
                        <asp:Button ID="btnRegister" runat="server" Text="Continue" OnClick="btnRegister_Click" CssClass="btn btn-primary btn-lg" />
                    </div>
                    
                    <div class="text-center mt-3">
                        <p>Already have an account? <a href="Login.aspx">Sign in</a></p>
                    </div>
                </asp:Panel>
                
                <!-- Step 2: OTP Verification -->
                <asp:Panel ID="registrationStep2" runat="server" Visible="false">
                    <div class="text-center mb-4">
                        <h3>Verify Your Email</h3>
                        <asp:Label ID="lblOtpEmail" runat="server" CssClass="text-muted"></asp:Label>
                    </div>
                    
                    <div class="mb-3">
                        <label for="<%= txtOtp.ClientID %>" class="form-label">Enter 6-digit OTP <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtOtp" runat="server" CssClass="form-control otp-input" MaxLength="6" placeholder="123456"></asp:TextBox>
                    </div>
                    
                    <div class="d-grid gap-2 mb-3">
                        <asp:Button ID="btnVerifyOtp" runat="server" Text="Verify & Complete Registration" OnClick="btnVerifyOtp_Click" CssClass="btn btn-primary btn-lg" />
                    </div>
                    
                    <div class="text-center">
                        <p>Didn't receive the OTP? <asp:LinkButton ID="btnResendOtp" runat="server" OnClick="btnResendOtp_Click" CssClass="text-primary">Resend OTP</asp:LinkButton></p>
                        <p>Want to change email? <asp:LinkButton ID="btnBackToRegister" runat="server" OnClick="btnBackToRegister_Click" CssClass="text-primary">Go back</asp:LinkButton></p>
                    </div>
                </asp:Panel>
                
                <!-- Step 3: Registration Complete -->
                <asp:Panel ID="registrationComplete" runat="server" Visible="false">
                    <div class="text-center py-4">
                        <div class="mb-4">
                            <i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i>
                        </div>
                        <h3 class="mb-3">Registration Successful!</h3>
                        <p class="text-muted mb-4">Your account has been created successfully.</p>
                        <div class="d-grid gap-2 col-md-6 mx-auto">
                            <a href="Login.aspx" class="btn btn-primary">Continue to Login</a>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            // Toggle password visibility
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

            // Password strength indicator
            $('#<%= txtPassword.ClientID %>').on('input', function () {
                const password = $(this).val();

                // Check requirements
                const hasMinLength = password.length >= 8;
                const hasUpperCase = /[A-Z]/.test(password);
                const hasLowerCase = /[a-z]/.test(password);
                const hasNumbers = /\d/.test(password);
                const hasSpecialChars = /[!@#$%^&*(),.?":{}|<>]/.test(password);

                // Update requirement indicators
                $('#lengthReq').toggleClass('valid', hasMinLength);
                $('#upperReq').toggleClass('valid', hasUpperCase);
                $('#lowerReq').toggleClass('valid', hasLowerCase);
                $('#numberReq').toggleClass('valid', hasNumbers);
                $('#specialReq').toggleClass('valid', hasSpecialChars);

                // Calculate strength
                const strength = [hasMinLength, hasUpperCase, hasLowerCase, hasNumbers, hasSpecialChars]
                    .filter(Boolean).length;
                const strengthPercent = (strength / 5) * 100;

                // Update strength meter
                const $indicator = $('#strengthIndicator');
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

            // Confirm password match
            $('#<%= txtConfirmPassword.ClientID %>').on('input', function() {
                const password = $('#<%= txtPassword.ClientID %>').val();
                const confirmPassword = $(this).val();
                
                if (confirmPassword !== '' && password !== confirmPassword) {
                    $(this).addClass('is-invalid');
                } else {
                    $(this).removeClass('is-invalid');
                }
            });

            // OTP input validation
            $('#<%= txtOtp.ClientID %>').on('input', function() {
                const otp = $(this).val();
                if (otp.length === 6 && /^\d+$/.test(otp)) {
                    $(this).removeClass('is-invalid');
                } else {
                    $(this).addClass('is-invalid');
                }
            });

            // Auto-focus OTP input when panel is shown
            if ($('#<%= registrationStep2.ClientID %>').is(':visible')) {
                $('#<%= txtOtp.ClientID %>').focus();
            }

            // Basic client-side validation before submit
            $('form').on('submit', function() {
                let isValid = true;
                
                // Validate required fields in registration form
                if ($('#<%= registrationStep1.ClientID %>').is(':visible')) {
                    $('[required]').each(function() {
                        if ($(this).val().trim() === '') {
                            $(this).addClass('is-invalid');
                            isValid = false;
                        } else {
                            $(this).removeClass('is-invalid');
                        }
                    });
                    
                    // Validate username format
                    const username = $('#<%= txtUsername.ClientID %>').val().trim();
                    if (username.length < 3 || !/^[a-zA-Z0-9_]+$/.test(username)) {
                        $('#<%= txtUsername.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                    
                    // Validate email format
                    const email = $('#<%= txtEmail.ClientID %>').val().trim();
                    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                        $('#<%= txtEmail.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                    
                    // Validate password strength
                    const password = $('#<%= txtPassword.ClientID %>').val();
                    if (password.length < 8 || 
                        !/[A-Z]/.test(password) || 
                        !/[a-z]/.test(password) || 
                        !/\d/.test(password) || 
                        !/[^A-Za-z0-9]/.test(password)) {
                        $('#<%= txtPassword.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }

                    // Validate phone if provided
                    const phone = $('#<%= txtPhone.ClientID %>').val().trim();
                    if (phone !== '' && (!/^\d+$/.test(phone) || phone.length < 6)) {
                        $('#<%= txtPhone.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                }
                
                // Validate OTP form
                if ($('#<%= registrationStep2.ClientID %>').is(':visible')) {
                    const otp = $('#<%= txtOtp.ClientID %>').val().trim();
                    if (otp.length !== 6 || !/^\d+$/.test(otp)) {
                        $('#<%= txtOtp.ClientID %>').addClass('is-invalid');
                        isValid = false;
                    }
                }

                return isValid;
            });
        });
    </script>
</body>
</html>