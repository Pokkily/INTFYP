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
        
        .logo {
            height: 50px;
            margin-bottom: 1rem;
        }
        
        .divider {
            display: flex;
            align-items: center;
            text-align: center;
            margin: 1.5rem 0;
            color: #6c757d;
        }
        
        .divider::before,
        .divider::after {
            content: "";
            flex: 1;
            border-bottom: 1px solid #dee2e6;
        }
        
        .divider::before {
            margin-right: 1rem;
        }
        
        .divider::after {
            margin-left: 1rem;
        }
        
        @media (max-width: 768px) {
            .register-container {
                margin: 1rem;
            }
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
                <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none" Visible="false"></asp:Label>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="<%= txtFirstName.ClientID %>" class="form-label">First Name <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" placeholder="John"></asp:TextBox>
                        <div class="invalid-feedback" id="firstNameFeedback">Please enter your first name</div>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label for="<%= txtLastName.ClientID %>" class="form-label">Last Name <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" placeholder="Doe"></asp:TextBox>
                        <div class="invalid-feedback" id="lastNameFeedback">Please enter your last name</div>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label for="<%= txtUsername.ClientID %>" class="form-label">Username <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text">@</span>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="johndoe"></asp:TextBox>
                    </div>
                    <small class="form-text text-muted">3-20 characters, letters, numbers and underscores only</small>
                    <div class="invalid-feedback" id="usernameFeedback">Please choose a valid username</div>
                </div>
                
                <div class="mb-3">
                    <label for="<%= txtEmail.ClientID %>" class="form-label">Email <span class="text-danger">*</span></label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="john@example.com"></asp:TextBox>
                    <div class="invalid-feedback" id="emailFeedback">Please enter a valid email address</div>
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
                    <div class="invalid-feedback" id="confirmPasswordFeedback">Passwords do not match</div>
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
                        <div class="invalid-feedback" id="genderFeedback">Please select your gender</div>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label for="<%= ddlPosition.ClientID %>" class="form-label">Position <span class="text-danger">*</span></label>
                        <asp:DropDownList ID="ddlPosition" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Select Position" Value="" Selected="True" />
                            <asp:ListItem Text="Student" Value="Student" />
                            <asp:ListItem Text="Teacher" Value="Teacher" />
                            <asp:ListItem Text="Administrator" Value="Administrator" />
                        </asp:DropDownList>
                        <div class="invalid-feedback" id="positionFeedback">Please select your position</div>
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
                    <asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click" CssClass="btn btn-primary btn-lg" />
                </div>
                
                <div class="divider">OR</div>
                
                <div class="text-center">
                    <p>Already have an account? <a href="Login.aspx">Sign in</a></p>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            // Toggle password visibility
            $('.toggle-password').click(function() {
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
            $('#<%= txtPassword.ClientID %>').on('input', function() {
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
                    $('#confirmPasswordFeedback').text('Passwords do not match').show();
                } else {
                    $(this).removeClass('is-invalid');
                    $('#confirmPasswordFeedback').hide();
                }
            });

            // Basic client-side validation before submit
            $('form').on('submit', function() {
                let isValid = true;
                
                // Validate required fields
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
                    $('#usernameFeedback').text('Username must be 3-20 characters with only letters, numbers and underscores');
                    isValid = false;
                }
                
                // Validate email format
                const email = $('#<%= txtEmail.ClientID %>').val().trim();
                if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                    $('#<%= txtEmail.ClientID %>').addClass('is-invalid');
                    $('#emailFeedback').text('Please enter a valid email address');
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

                return isValid;
            });
        });
    </script>
</body>
</html>