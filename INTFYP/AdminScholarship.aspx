<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="AdminScholarship.aspx.cs" Inherits="YourProjectNamespace.AdminScholarship" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Scholarship Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #4e73df;
            --secondary-color: #f8f9fc;
            --success-color: #1cc88a;
            --danger-color: #e74a3b;
            --warning-color: #f6c23e;
            --info-color: #36b9cc;
            --dark-color: #2c3e50;
        }
        
        body {
            background-color: var(--secondary-color);
            font-family: 'Nunito', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        /* Navigation Bar Styles */
        .admin-navbar {
            background-color: var(--dark-color);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .admin-navbar .navbar-brand {
            font-weight: bold;
            color: white !important;
        }

        .admin-navbar .nav-link {
            color: #ecf0f1 !important;
            padding: 0.75rem 1rem !important;
            transition: all 0.3s ease;
        }

        .admin-navbar .nav-link:hover {
            color: var(--primary-color) !important;
            background-color: rgba(255,255,255,0.1);
            border-radius: 6px;
        }

        .admin-navbar .nav-link.active {
            color: var(--primary-color) !important;
            background-color: rgba(78, 115, 223, 0.2);
            border-radius: 6px;
        }

        .navbar-toggler {
            border-color: rgba(255,255,255,0.3);
        }

        .navbar-toggler-icon {
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='rgba%28255, 255, 255, 0.8%29' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e");
        }

        /* Badge styles for navigation */
        .nav-badge {
            background-color: var(--danger-color);
            color: white;
            border-radius: 50%;
            padding: 0.2rem 0.5rem;
            font-size: 0.75rem;
            margin-left: 0.5rem;
        }

        /* Admin header */
        .admin-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, #3a5bc7 100%);
            color: white;
            padding: 1.5rem 0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .stats-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            margin-bottom: 1.5rem;
            transition: transform 0.2s;
        }
        
        .stats-card:hover {
            transform: translateY(-2px);
        }
        
        .stats-number {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        
        /* Scholarship Application Card - Based on your design */
        .scholarship-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            overflow: hidden;
            transition: all 0.3s ease;
            margin-bottom: 20px;
            animation: slideInFromLeft 0.6s ease-out;
            position: relative;
        }

        .scholarship-card::before {
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

        .scholarship-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.12);
        }

        .scholarship-card.approved {
            border-left: 4px solid var(--success-color);
        }
        
        .scholarship-card.rejected {
            border-left: 4px solid var(--danger-color);
        }

        .scholarship-card.pending {
            border-left: 4px solid var(--warning-color);
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
        
        .applicant-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin: 1rem 0;
        }
        
        .info-item {
            padding: 0.5rem;
            background-color: #f8f9fc;
            border-radius: 6px;
        }
        
        .info-label {
            font-weight: 600;
            color: #5a5c69;
            font-size: 0.875rem;
        }
        
        .info-value {
            color: #3a3b45;
            margin-top: 0.25rem;
        }
        
        .action-buttons {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
            justify-content: center;
            margin-top: 1rem;
        }
        
        .btn-approve {
            background: linear-gradient(135deg, var(--success-color) 0%, #17a673 100%);
            border: none;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(28, 200, 138, 0.3);
        }
        
        .btn-approve:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(28, 200, 138, 0.4);
            background: linear-gradient(135deg, #17a673 0%, var(--success-color) 100%);
            color: white;
        }
        
        .btn-reject {
            background: linear-gradient(135deg, var(--danger-color) 0%, #c73321 100%);
            border: none;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(231, 76, 60, 0.3);
        }
        
        .btn-reject:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(231, 76, 60, 0.4);
            background: linear-gradient(135deg, #c73321 0%, var(--danger-color) 100%);
            color: white;
        }
        
        .filter-section {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        }
        
        .search-box {
            border-radius: 25px;
            border: 2px solid #e3e6f0;
            padding: 0.75rem 1.5rem;
        }
        
        .search-box:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(78, 115, 223, 0.25);
        }

        /* Supporting Documents Section */
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
            padding: 3rem;
            color: #6c757d;
        }
        
        .rejection-modal .modal-content {
            border-radius: 12px;
        }
        
        .rejection-modal .modal-header {
            background-color: var(--danger-color);
            color: white;
            border-radius: 12px 12px 0 0;
        }

        /* Animations */
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

        /* Responsive Design */
        @media (max-width: 768px) {
            .applicant-info {
                grid-template-columns: 1fr;
                gap: 10px;
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

            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        
        <!-- Navigation Bar -->
        <nav class="navbar navbar-expand-lg admin-navbar">
            <div class="container-fluid">
                <a class="navbar-brand" href="#">
                    <i class="bi bi-shield-check"></i> Admin Panel
                </a>
                
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbar" aria-controls="adminNavbar" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                
                <div class="collapse navbar-collapse" id="adminNavbar">
                    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                        <li class="nav-item">
                            <a class="nav-link" href="Admin.aspx">
                                <i class="bi bi-people"></i> User Management
                                <span class="nav-badge" id="userBadge" style="display:none;">
                                    <asp:Label ID="lblNavUsers" runat="server" Text="0"></asp:Label>
                                </span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="AdminScholarship.aspx">
                                <i class="bi bi-award"></i> Scholarship Management
                                <span class="nav-badge" id="scholarshipBadge">
                                    <asp:Label ID="lblNavScholarship" runat="server" Text="0"></asp:Label>
                                </span>
                            </a>
                        </li>
                    </ul>
                    
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <asp:Button ID="btnNavLogout" runat="server" Text="Logout" OnClick="btnLogout_Click" 
                                       CssClass="nav-link btn btn-link text-white" style="border:none; background:none;" />
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
        <!-- End Navigation Bar -->

        <div class="admin-header">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-12">
                        <h1><i class="bi bi-award"></i> Scholarship Management</h1>
                        <p class="mb-0">Review and manage scholarship applications</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="container mt-4">
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none" Visible="false"></asp:Label>

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="stats-card text-center">
                        <div class="stats-number text-warning">
                            <asp:Label ID="lblPendingCount" runat="server" Text="0"></asp:Label>
                        </div>
                        <div class="text-muted">Pending Review</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card text-center">
                        <div class="stats-number text-success">
                            <asp:Label ID="lblApprovedCount" runat="server" Text="0"></asp:Label>
                        </div>
                        <div class="text-muted">Approved Applications</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card text-center">
                        <div class="stats-number text-danger">
                            <asp:Label ID="lblRejectedCount" runat="server" Text="0"></asp:Label>
                        </div>
                        <div class="text-muted">Rejected Applications</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card text-center">
                        <div class="stats-number text-info">
                            <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label>
                        </div>
                        <div class="text-muted">Total Applications</div>
                    </div>
                </div>
            </div>

            <!-- Filter Section -->
            <div class="filter-section">
                <div class="row align-items-center">
                    <div class="col-md-4">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-box" 
                                   placeholder="Search by name, email, or institution..." AutoPostBack="true" 
                                   OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select" 
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                            <asp:ListItem Text="All Status" Value="" Selected="True" />
                            <asp:ListItem Text="Pending" Value="Pending" />
                            <asp:ListItem Text="Approved" Value="Approved" />
                            <asp:ListItem Text="Rejected" Value="Rejected" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlLevelFilter" runat="server" CssClass="form-select" 
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlLevelFilter_SelectedIndexChanged">
                            <asp:ListItem Text="All Levels" Value="" Selected="True" />
                            <asp:ListItem Text="High School" Value="High School" />
                            <asp:ListItem Text="Associate Degree" Value="Associate Degree" />
                            <asp:ListItem Text="Bachelor's Degree" Value="Bachelor's Degree" />
                            <asp:ListItem Text="Master's Degree" Value="Master's Degree" />
                            <asp:ListItem Text="Doctoral Degree" Value="Doctoral Degree" />
                            <asp:ListItem Text="Professional Degree" Value="Professional Degree" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-2">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" OnClick="btnRefresh_Click" 
                                   CssClass="btn btn-primary w-100" />
                    </div>
                </div>
            </div>

            <!-- Scholarship Applications List -->
            <div class="row">
                <div class="col-12">
                    <asp:Repeater ID="rptApplications" runat="server" OnItemCommand="rptApplications_ItemCommand">
                        <HeaderTemplate>
                            <div class="applications-container">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div class="scholarship-card <%# GetStatusClass(Eval("Status").ToString()) %>">
                                <div class="application-header">
                                    <div class="application-info">
                                        <h5><%# Eval("FullName") %></h5>
                                        <small><i class="fas fa-calendar"></i> Applied on <%# Eval("CreatedAt", "{0:MMM dd, yyyy}") %></small>
                                    </div>
                                    <span class="status-badge status-<%# Eval("Status").ToString().ToLower() %>">
                                        <%# Eval("Status") %>
                                    </span>
                                </div>
                                
                                <div style="padding: 20px;">
                                    <div class="applicant-info">
                                        <div class="info-item">
                                            <div class="info-label"><i class="fas fa-envelope me-1"></i> Email</div>
                                            <div class="info-value"><%# Eval("Email") %></div>
                                        </div>
                                        <div class="info-item">
                                            <div class="info-label"><i class="fas fa-phone me-1"></i> Phone</div>
                                            <div class="info-value"><%# Eval("Phone") ?? "Not provided" %></div>
                                        </div>
                                        <div class="info-item">
                                            <div class="info-label"><i class="fas fa-university me-1"></i> Institution</div>
                                            <div class="info-value"><%# Eval("Institution") %></div>
                                        </div>
                                        <div class="info-item">
                                            <div class="info-label"><i class="fas fa-book-open me-1"></i> Field of Study</div>
                                            <div class="info-value"><%# Eval("FieldOfStudy") %></div>
                                        </div>
                                        <div class="info-item">
                                            <div class="info-label"><i class="fas fa-layer-group me-1"></i> Academic Level</div>
                                            <div class="info-value"><%# Eval("AcademicLevel") ?? "Not specified" %></div>
                                        </div>
                                        <div class="info-item">
                                            <div class="info-label"><i class="fas fa-chart-line me-1"></i> Current Result</div>
                                            <div class="info-value"><%# Eval("CurrentResult") ?? "Not provided" %></div>
                                        </div>
                                        <%# !string.IsNullOrEmpty(Eval("DateOfBirth")?.ToString()) ? 
                                            "<div class='info-item'><div class='info-label'><i class='fas fa-birthday-cake me-1'></i> Date of Birth</div><div class='info-value'>" + 
                                            Convert.ToDateTime(Eval("DateOfBirth")).ToString("MMM dd, yyyy") + "</div></div>" : "" %>
                                        <%# !string.IsNullOrEmpty(Eval("GraduationDate")?.ToString()) ? 
                                            "<div class='info-item'><div class='info-label'><i class='fas fa-graduation-cap me-1'></i> Expected Graduation</div><div class='info-value'>" + 
                                            Convert.ToDateTime(Eval("GraduationDate")).ToString("MMM dd, yyyy") + "</div></div>" : "" %>
                                    </div>
                                    
                                    <!-- Supporting Documents Section -->
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

                                    <div class="action-buttons">
                                        <asp:Button runat="server" ID="btnApprove" CommandName="Approve" 
                                                  CommandArgument='<%# Eval("Id") %>' Text="✓ Approve" 
                                                  CssClass="btn-approve" Visible='<%# Eval("Status").ToString() != "Approved" %>' />
                                        
                                        <button type="button" class="btn-reject" 
                                              onclick="showRejectModal('<%# Eval("Id") %>', '<%# Eval("FullName") %>')" 
                                              style='<%# Eval("Status").ToString() == "Rejected" ? "display:none" : "" %>'>
                                            <i class="fas fa-times"></i> Reject
                                        </button>

                                        <%# Eval("Status").ToString() == "Rejected" ? 
                                            "<asp:Button runat='server' CommandName='Approve' CommandArgument='" + Eval("Id") + "' Text='↻ Re-approve' CssClass='btn-approve' />" : "" %>
                                    </div>
                                    
                                    <%# !string.IsNullOrEmpty(Eval("RejectionReason")?.ToString()) ? 
                                        "<div class='mt-3 p-3 bg-danger bg-opacity-10 border border-danger border-opacity-25 rounded'>" +
                                        "<strong class='text-danger'><i class='fas fa-exclamation-triangle me-1'></i> Rejection Reason:</strong><br>" + Eval("RejectionReason") + "</div>" : "" %>
                                </div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoApplications" runat="server" Visible="false" CssClass="no-applications">
                        <i class="fas fa-clipboard-list" style="font-size: 4rem; opacity: 0.3;"></i>
                        <h4 class="mt-3">No scholarship applications found</h4>
                        <p>There are no applications matching your current filters.</p>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Rejection Modal -->
        <div class="modal fade rejection-modal" id="rejectModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-times-circle"></i> Reject Scholarship Application
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>You are about to reject the scholarship application for <strong id="rejectApplicantName"></strong>.</p>
                        <div class="mb-3">
                            <label for="txtRejectionReason" class="form-label">Reason for rejection <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlRejectionReason" runat="server" CssClass="form-select mb-2">
                                <asp:ListItem Text="-- Select Reason --" Value="" />
                                <asp:ListItem Text="Incomplete Application" Value="Incomplete Application" />
                                <asp:ListItem Text="Does Not Meet Eligibility Requirements" Value="Does Not Meet Eligibility Requirements" />
                                <asp:ListItem Text="Insufficient Academic Performance" Value="Insufficient Academic Performance" />
                                <asp:ListItem Text="Missing Required Documents" Value="Missing Required Documents" />
                                <asp:ListItem Text="Application Submitted After Deadline" Value="Application Submitted After Deadline" />
                                <asp:ListItem Text="Financial Need Not Demonstrated" Value="Financial Need Not Demonstrated" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                            <asp:TextBox ID="txtRejectionReason" runat="server" TextMode="MultiLine" Rows="4" 
                                       CssClass="form-control" placeholder="Provide additional details or specify other reasons..."></asp:TextBox>
                        </div>
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle"></i>
                            <strong>Note:</strong> The applicant will receive an email notification with this rejection reason.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnConfirmReject" runat="server" Text="Confirm Rejection" 
                                   OnClick="btnConfirmReject_Click" CssClass="btn btn-danger" />
                    </div>
                </div>
            </div>
        </div>
        
        <asp:HiddenField ID="hiddenApplicationIdToReject" runat="server" />
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Update the navigation badge with pending count
        function updateNavBadge() {
            const pendingCount = document.querySelector('#lblPendingCount').innerText;
            document.querySelector('#lblNavScholarship').innerText = pendingCount;
            
            // Hide badge if no pending applications
            const badge = document.querySelector('#scholarshipBadge');
            if (pendingCount === '0') {
                badge.style.display = 'none';
            } else {
                badge.style.display = 'inline-block';
            }
        }

        // Call on page load
        window.addEventListener('load', updateNavBadge);

        function showRejectModal(applicationId, applicantName) {
            document.getElementById('<%= hiddenApplicationIdToReject.ClientID %>').value = applicationId;
            document.getElementById('rejectApplicantName').innerText = applicantName;
            document.getElementById('<%= ddlRejectionReason.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= txtRejectionReason.ClientID %>').value = '';

            var modal = new bootstrap.Modal(document.getElementById('rejectModal'));
            modal.show();
        }

        // Auto-hide alerts after 5 seconds
        window.addEventListener('load', function () {
            const alerts = document.querySelectorAll('.alert:not(.d-none)');
            alerts.forEach(function (alert) {
                setTimeout(function () {
                    alert.style.transition = 'opacity 0.5s';
                    alert.style.opacity = '0';
                    setTimeout(function () {
                        alert.style.display = 'none';
                    }, 500);
                }, 5000);
            });

            // Enhanced hover effects for scholarship cards
            const cards = document.querySelectorAll('.scholarship-card');
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

            // Document link hover effects
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
    </script>
</body>
</html>