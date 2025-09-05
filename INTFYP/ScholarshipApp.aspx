<%@ Page Async="true" Title="Scholarship Application Form" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="scholarshipApp.aspx.cs" Inherits="INTFYP.ScholarshipApp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Scholarship Application Form
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .scholarship-application-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
        }

        .scholarship-application-page::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(120, 119, 198, 0.2) 0%, transparent 50%);
            animation: backgroundFloat 20s ease-in-out infinite;
            z-index: -1;
            pointer-events: none;
        }

        @keyframes backgroundFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-20px, -20px) rotate(1deg); }
            50% { transform: translate(20px, -10px) rotate(-1deg); }
            75% { transform: translate(-10px, 10px) rotate(0.5deg); }
        }

        .scholarship-container {
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            animation: slideInFromTop 1s ease-out;
        }

        @keyframes slideInFromTop {
            from { 
                opacity: 0; 
                transform: translateY(-50px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .page-title {
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 15px;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            position: relative;
            display: inline-block;
        }

        .page-title::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 4px;
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            border-radius: 2px;
            animation: expandWidth 1.5s ease-out 0.5s both;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 80px; }
        }

        .page-subtitle {
            color: rgba(255,255,255,0.8);
            font-size: 18px;
            margin-bottom: 0;
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            margin-bottom: 25px;
            overflow: hidden;
            animation: slideInFromBottom 0.8s ease-out;
            position: relative;
        }

        .glass-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            font-weight: 700;
            font-size: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-radius: 20px 20px 0 0;
        }

        .card-body {
            padding: 30px;
        }

        .form-section {
            margin-bottom: 35px;
        }

        .section-header {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid rgba(103, 126, 234, 0.2);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            position: relative;
        }

        .form-label {
            font-weight: 600;
            color: #2c3e50;
            font-size: 14px;
            margin-bottom: 8px;
            display: block;
        }

        .form-control {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 14px;
            transition: all 0.3s ease;
            width: 100%;
            min-height: 45px;
        }

        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.3);
            outline: none;
            transform: scale(1.02);
        }

        .form-control.large {
            min-height: 120px;
            resize: vertical;
        }

        .primary-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 30px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            position: relative;
            overflow: hidden;
        }

        .primary-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.3s ease;
            pointer-events: none;
        }

        .primary-button:hover::before {
            width: 300px;
            height: 300px;
        }

        .primary-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            color: white;
            text-decoration: none;
        }

        .status-message {
            background: rgba(86, 171, 47, 0.1);
            border: 1px solid rgba(86, 171, 47, 0.3);
            color: #2d5016;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            animation: slideInFromTop 0.5s ease-out;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .status-message.error {
            background: rgba(255, 107, 107, 0.1);
            border-color: rgba(255, 107, 107, 0.3);
            color: #8b2635;
        }

        .application-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            overflow: hidden;
            transition: all 0.3s ease;
            margin-bottom: 20px;
            animation: slideInFromLeft 0.6s ease-out;
        }

        .application-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.12);
        }

        .application-header {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .application-info h5 {
            color: #2c3e50;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .application-info small {
            color: #7f8c8d;
            font-size: 14px;
        }

        .status-badge {
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-pending {
            background: linear-gradient(45deg, #f39c12, #f1c40f);
            color: white;
        }

        .status-approved {
            background: linear-gradient(45deg, #27ae60, #2ecc71);
            color: white;
        }

        .status-rejected {
            background: linear-gradient(45deg, #e74c3c, #c0392b);
            color: white;
        }

        .documents-section {
            background: rgba(248, 249, 250, 0.8);
            border-radius: 10px;
            padding: 15px;
            margin-top: 15px;
            border: 1px solid rgba(0, 0, 0, 0.05);
        }

        .documents-title {
            font-weight: 600;
            color: #2c3e50;
            font-size: 14px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .documents-title::before {
            content: '📄';
            font-size: 16px;
        }

        .document-links {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .document-link {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 12px;
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            text-decoration: none;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 500;
            transition: all 0.2s ease;
            box-shadow: 0 2px 8px rgba(78, 205, 196, 0.3);
        }

        .document-link:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
            color: white;
            text-decoration: none;
        }

        .document-link::before {
            content: '📎';
            font-size: 12px;
        }

        .no-documents {
            color: #7f8c8d;
            font-size: 12px;
            font-style: italic;
        }

        .no-applications {
            text-align: center;
            padding: 60px 20px;
            color: #7f8c8d;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            backdrop-filter: blur(5px);
        }

        .no-applications i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
            animation: iconBounce 2s ease-in-out infinite;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .file-upload-wrapper {
            position: relative;
            overflow: hidden;
            display: inline-block;
            width: 100%;
        }

        .file-upload-wrapper .form-control {
            cursor: pointer;
        }

        .file-upload-wrapper::after {
            content: '📎';
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            pointer-events: none;
            font-size: 16px;
        }

        @media (max-width: 768px) {
            .scholarship-application-page {
                padding: 20px 10px;
            }

            .form-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .card-body {
                padding: 20px;
            }
            
            .application-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }

            .document-links {
                flex-direction: column;
            }

            .document-link {
                justify-content: center;
            }
        }

        @keyframes slideInFromBottom {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideInFromLeft {
            from {
                opacity: 0;
                transform: translateX(-50px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .mb-0 { margin-bottom: 0; }
        .mb-2 { margin-bottom: 10px; }
        .mb-3 { margin-bottom: 15px; }
        .mb-4 { margin-bottom: 20px; }
        .mt-4 { margin-top: 20px; }
        .d-flex { display: flex; }
        .justify-content-end { justify-content: flex-end; }
        .justify-content-center { justify-content: center; }
        .text-center { text-align: center; }
        .full-width { grid-column: 1 / -1; }
    </style>

    <div class="scholarship-application-page">
        <div class="scholarship-container">
            <div class="page-header">
                <h2 class="page-title">🎓 Scholarship Application</h2>
                <p class="page-subtitle">Apply for educational scholarships and funding opportunities</p>
            </div>

            <div class="glass-card">
                <div class="card-header">
                    <i class="fas fa-user-graduate"></i>
                    Submit New Scholarship Application
                </div>
                <div class="card-body">
                    <div class="form-section">
                        <asp:Panel ID="pnlStatus" runat="server" Visible="false">
                            <div class="status-message" id="statusMessage">
                                <i class="fas fa-check-circle"></i>
                                <asp:Label ID="lblStatus" runat="server" Text="" />
                            </div>
                        </asp:Panel>
                        
                        <div class="section-header">
                            <i class="fas fa-user"></i>
                            Personal Information
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-signature me-1"></i>
                                    Full Name *
                                </label>
                                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" 
                                           placeholder="Enter your full name" />
                                <asp:RequiredFieldValidator ID="rfvFullName" runat="server" 
                                    ControlToValidate="txtFullName" 
                                    ErrorMessage="Full name is required" 
                                    ForeColor="Red" Display="Dynamic" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-envelope me-1"></i>
                                    Email Address *
                                </label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" 
                                           TextMode="Email" placeholder="your.email@example.com" />
                                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                                    ControlToValidate="txtEmail" 
                                    ErrorMessage="Email is required" 
                                    ForeColor="Red" Display="Dynamic" />
                                <asp:RegularExpressionValidator ID="revEmail" runat="server" 
                                    ControlToValidate="txtEmail" 
                                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                    ErrorMessage="Please enter a valid email address" 
                                    ForeColor="Red" Display="Dynamic" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-phone me-1"></i>
                                    Phone Number *
                                </label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" 
                                           placeholder="+1 (555) 123-4567" />
                                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" 
                                    ControlToValidate="txtPhone" 
                                    ErrorMessage="Phone number is required" 
                                    ForeColor="Red" Display="Dynamic" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-calendar me-1"></i>
                                    Date of Birth *
                                </label>
                                <asp:TextBox ID="txtDateOfBirth" runat="server" CssClass="form-control" 
                                           TextMode="Date" />
                                <asp:RequiredFieldValidator ID="rfvDateOfBirth" runat="server" 
                                    ControlToValidate="txtDateOfBirth" 
                                    ErrorMessage="Date of birth is required" 
                                    ForeColor="Red" Display="Dynamic" />
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <div class="section-header">
                            <i class="fas fa-graduation-cap"></i>
                            Academic Information
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-university me-1"></i>
                                    Current Institution *
                                </label>
                                <asp:TextBox ID="txtInstitution" runat="server" CssClass="form-control" 
                                           placeholder="Name of your school/university" />
                                <asp:RequiredFieldValidator ID="rfvInstitution" runat="server" 
                                    ControlToValidate="txtInstitution" 
                                    ErrorMessage="Institution name is required" 
                                    ForeColor="Red" Display="Dynamic" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-book-open me-1"></i>
                                    Field of Study *
                                </label>
                                <asp:TextBox ID="txtFieldOfStudy" runat="server" CssClass="form-control" 
                                           placeholder="e.g., Computer Science, Medicine, Engineering" />
                                <asp:RequiredFieldValidator ID="rfvFieldOfStudy" runat="server" 
                                    ControlToValidate="txtFieldOfStudy" 
                                    ErrorMessage="Field of study is required" 
                                    ForeColor="Red" Display="Dynamic" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-layer-group me-1"></i>
                                    Academic Level *
                                </label>
                                <asp:DropDownList ID="ddlAcademicLevel" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="" Text="-- Select Academic Level --" />
                                    <asp:ListItem Value="High School" Text="High School" />
                                    <asp:ListItem Value="Associate Degree" Text="Associate Degree" />
                                    <asp:ListItem Value="Bachelor's Degree" Text="Bachelor's Degree" />
                                    <asp:ListItem Value="Master's Degree" Text="Master's Degree" />
                                    <asp:ListItem Value="Doctoral Degree" Text="Doctoral Degree" />
                                    <asp:ListItem Value="Professional Degree" Text="Professional Degree" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvAcademicLevel" runat="server" 
                                    ControlToValidate="ddlAcademicLevel" 
                                    InitialValue=""
                                    ErrorMessage="Please select your academic level" 
                                    ForeColor="Red" Display="Dynamic" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-chart-line me-1"></i>
                                    Current Result
                                </label>
                                <asp:TextBox ID="txtCurrentResult" runat="server" CssClass="form-control" 
                                           placeholder="e.g., 3.5, 4A3B, 85%" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-calendar-check me-1"></i>
                                    Expected Graduation Date
                                </label>
                                <asp:TextBox ID="txtGraduationDate" runat="server" CssClass="form-control" 
                                           TextMode="Date" />
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <div class="section-header">
                            <i class="fas fa-file-upload"></i>
                            Supporting Documents
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-file-alt me-1"></i>
                                    Transcript (PDF/Image) *
                                </label>
                                <div class="file-upload-wrapper">
                                    <asp:FileUpload ID="fileTranscript" runat="server" CssClass="form-control" />
                                </div>
                                <asp:RequiredFieldValidator ID="rfvTranscript" runat="server" 
                                    ControlToValidate="fileTranscript" 
                                    ErrorMessage="Transcript is required" 
                                    ForeColor="Red" Display="Dynamic" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-file-signature me-1"></i>
                                    Letter of Recommendation (PDF/Image)
                                </label>
                                <div class="file-upload-wrapper">
                                    <asp:FileUpload ID="fileRecommendation" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-file-invoice me-1"></i>
                                    Financial Documents (PDF/Image)
                                </label>
                                <div class="file-upload-wrapper">
                                    <asp:FileUpload ID="fileFinancial" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">
                                    <i class="fas fa-file-plus me-1"></i>
                                    Additional Documents (PDF/Image)
                                </label>
                                <div class="file-upload-wrapper">
                                    <asp:FileUpload ID="fileAdditional" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-center mt-4">
                        <asp:Button ID="btnSubmitApplication" runat="server" Text="🚀 Submit Application" 
                                  CssClass="primary-button" OnClick="btnSubmitApplication_Click" />
                    </div>
                </div>
            </div>

            <div class="glass-card">
                <div class="card-header">
                    <i class="fas fa-history"></i>
                    My Applications
                </div>
                <div class="card-body">
                    <asp:Repeater ID="rptApplications" runat="server">
                        <ItemTemplate>
                            <div class="application-card">
                                <div class="application-header">
                                    <div class="application-info">
                                        <h5>Scholarship Application</h5>
                                        <small>Applied on <%# Eval("CreatedAt", "{0:MMM dd, yyyy}") %></small>
                                    </div>
                                    <span class="status-badge status-<%# Eval("Status").ToString().ToLower() %>">
                                        <%# Eval("Status") %>
                                    </span>
                                </div>
                                <div style="padding: 15px 20px;">
                                    <strong>Applicant:</strong> <%# Eval("FullName") %><br/>
                                    <strong>Institution:</strong> <%# Eval("Institution") %><br/>
                                    <strong>Field of Study:</strong> <%# Eval("FieldOfStudy") %><br/>
                                    <strong>Current Result:</strong> <%# Eval("CurrentResult") %>
                                    
                                    <div class="documents-section">
                                        <div class="documents-title">Supporting Documents</div>
                                        <div class="document-links">
                                            <%# !string.IsNullOrEmpty(Eval("TranscriptUrl").ToString()) ? 
                                                "<a href='" + Eval("TranscriptUrl") + "' target='_blank' class='document-link'>Transcript</a>" : "" %>
                                            <%# !string.IsNullOrEmpty(Eval("RecommendationUrl").ToString()) ? 
                                                "<a href='" + Eval("RecommendationUrl") + "' target='_blank' class='document-link'>Recommendation</a>" : "" %>
                                            <%# !string.IsNullOrEmpty(Eval("FinancialUrl").ToString()) ? 
                                                "<a href='" + Eval("FinancialUrl") + "' target='_blank' class='document-link'>Financial</a>" : "" %>
                                            <%# !string.IsNullOrEmpty(Eval("AdditionalUrl").ToString()) ? 
                                                "<a href='" + Eval("AdditionalUrl") + "' target='_blank' class='document-link'>Additional</a>" : "" %>
                                            <%# string.IsNullOrEmpty(Eval("TranscriptUrl").ToString()) && 
                                                string.IsNullOrEmpty(Eval("RecommendationUrl").ToString()) && 
                                                string.IsNullOrEmpty(Eval("FinancialUrl").ToString()) && 
                                                string.IsNullOrEmpty(Eval("AdditionalUrl").ToString()) ? 
                                                "<span class='no-documents'>No documents uploaded</span>" : "" %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoApplications" runat="server" Visible="false" CssClass="no-applications">
                        <i class="fas fa-clipboard-list"></i>
                        <h4>No Applications Found</h4>
                        <p>Submit your first scholarship application using the form above!</p>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            console.log('Scholarship Application page loaded');

            setTimeout(function () {
                var statusMessage = document.getElementById('statusMessage');
                if (statusMessage) {
                    statusMessage.style.opacity = '0';
                    statusMessage.style.transform = 'translateY(-20px)';
                    statusMessage.style.transition = 'all 0.5s ease';
                    setTimeout(function () {
                        statusMessage.style.display = 'none';
                    }, 500);
                }
            }, 6000);

            const cards = document.querySelectorAll('.application-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;

                card.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-3px)';
                    this.style.boxShadow = '0 12px 30px rgba(0, 0, 0, 0.12)';
                });

                card.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0)';
                    this.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.1)';
                });
            });

            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.style.transform = 'scale(1.02)';
                    this.style.borderColor = '#667eea';
                    this.style.boxShadow = '0 0 0 3px rgba(103, 126, 234, 0.3)';
                });

                input.addEventListener('blur', function () {
                    this.style.transform = 'scale(1)';
                });
            });

            const fileInputs = document.querySelectorAll('input[type="file"]');
            fileInputs.forEach(input => {
                input.addEventListener('change', function () {
                    if (this.files.length > 0) {
                        this.style.borderColor = '#27ae60';
                        this.style.background = 'rgba(46, 204, 113, 0.1)';
                        const wrapper = this.closest('.file-upload-wrapper');
                        if (wrapper) {
                            wrapper.style.borderColor = '#27ae60';
                        }
                    }
                });
            });

            const sectionHeaders = document.querySelectorAll('.section-header');
            sectionHeaders.forEach((header, index) => {
                header.style.animationDelay = `${(index + 1) * 0.2}s`;
            });

            const docLinks = document.querySelectorAll('.document-link');
            docLinks.forEach(link => {
                link.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-1px)';
                });

                link.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0)';
                });
            });
        });

        function validateForm() {
            const requiredFields = document.querySelectorAll('[required]');
            let isValid = true;

            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    field.style.borderColor = '#e74c3c';
                    field.style.background = 'rgba(231, 76, 60, 0.1)';
                    isValid = false;
                } else {
                    field.style.borderColor = '#27ae60';
                    field.style.background = 'rgba(46, 204, 113, 0.1)';
                }
            });

            return isValid;
        }
    </script>
</asp:Content>