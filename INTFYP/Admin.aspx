<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Admin.aspx.cs" Inherits="YourProjectNamespace.Admin" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | User & Content Management</title>
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

        .nav-badge {
            background-color: var(--danger-color);
            color: white;
            border-radius: 50%;
            padding: 0.2rem 0.5rem;
            font-size: 0.75rem;
            margin-left: 0.5rem;
        }

        /* Tab Navigation */
        .admin-tabs {
            background: white;
            border-radius: 12px;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            margin-bottom: 2rem;
        }

        .nav-tabs {
            border-bottom: 2px solid #e9ecef;
        }

        .nav-tabs .nav-link {
            color: #6c757d;
            border: none;
            padding: 1rem 1.5rem;
            font-weight: 600;
            border-radius: 0;
        }

        .nav-tabs .nav-link.active {
            color: var(--primary-color);
            background-color: transparent;
            border-bottom: 3px solid var(--primary-color);
        }

        .nav-tabs .nav-link:hover {
            color: var(--primary-color);
            background-color: rgba(78, 115, 223, 0.1);
        }

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
        
        .user-card, .report-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            border-left: 4px solid var(--warning-color);
            transition: all 0.3s ease;
        }

        .user-card:hover, .report-card:hover {
            box-shadow: 0 0.25rem 2rem 0 rgba(58, 59, 69, 0.2);
            transform: translateY(-1px);
        }
        
        .user-card.approved {
            border-left-color: var(--success-color);
        }
        
        .user-card.rejected {
            border-left-color: var(--danger-color);
        }

        .report-card.priority-high {
            border-left-color: var(--danger-color);
        }

        .report-card.priority-medium {
            border-left-color: var(--warning-color);
        }

        .report-card.priority-low {
            border-left-color: var(--info-color);
        }

        .report-card.resolved {
            opacity: 0.7;
            border-left-color: var(--success-color);
        }
        
        .status-badge, .priority-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
        }

        .priority-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 15px;
            font-size: 0.75rem;
            text-transform: uppercase;
        }

        .priority-high {
            background-color: rgba(231, 74, 59, 0.1);
            color: #721c24;
        }

        .priority-medium {
            background-color: rgba(246, 194, 62, 0.1);
            color: #856404;
        }

        .priority-low {
            background-color: rgba(54, 185, 204, 0.1);
            color: #0c5460;
        }
        
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status-approved, .status-resolved {
            background-color: #d1edff;
            color: #0c5460;
        }
        
        .status-rejected, .status-dismissed {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .user-info, .report-metadata {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin: 1rem 0;
        }
        
        .info-item, .metadata-item {
            padding: 0.5rem;
            background-color: #f8f9fc;
            border-radius: 6px;
        }
        
        .info-label, .metadata-label {
            font-weight: 600;
            color: #5a5c69;
            font-size: 0.875rem;
        }
        
        .info-value, .metadata-value {
            color: #3a3b45;
            margin-top: 0.25rem;
        }

        .reported-content {
            background-color: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 1rem;
            margin: 1rem 0;
            max-height: 150px;
            overflow-y: auto;
        }

        .reporter-info {
            background-color: #e3f2fd;
            border-radius: 6px;
            padding: 0.75rem;
            margin: 0.5rem 0;
        }

        .admin-action-section {
            background-color: #e8f5e8;
            border: 1px solid #c3e6c3;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
        }

        .admin-action-section.dismissed {
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        
        .action-buttons {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        
        .btn-approve, .btn-resolve {
            background-color: var(--success-color);
            border-color: var(--success-color);
            color: white;
        }
        
        .btn-approve:hover, .btn-resolve:hover {
            background-color: #17a673;
            border-color: #17a673;
            color: white;
        }
        
        .btn-reject, .btn-delete {
            background-color: var(--danger-color);
            border-color: var(--danger-color);
            color: white;
        }
        
        .btn-reject:hover, .btn-delete:hover {
            background-color: #c73321;
            border-color: #c73321;
            color: white;
        }

        .btn-dismiss {
            background-color: #6c757d;
            border-color: #6c757d;
            color: white;
        }

        .btn-dismiss:hover {
            background-color: #545b62;
            border-color: #545b62;
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
        
        .no-data {
            text-align: center;
            padding: 3rem;
            color: #6c757d;
        }
        
        .rejection-modal .modal-content, .action-modal .modal-content {
            border-radius: 12px;
        }
        
        .rejection-modal .modal-header, .action-modal .modal-header {
            background-color: var(--danger-color);
            color: white;
            border-radius: 12px 12px 0 0;
        }

        .tab-content {
            background: white;
            border-radius: 0 0 12px 12px;
            padding: 2rem;
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
                            <a class="nav-link active" href="Admin.aspx">
                                <i class="bi bi-speedometer2"></i> Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="AdminScholarship.aspx">
                                <i class="bi bi-award"></i> Scholarships
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

        <div class="admin-header">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-12">
                        <h1><i class="bi bi-speedometer2"></i> Admin Dashboard</h1>
                        <p class="mb-0">Manage users, content, and system oversight</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="container mt-4">
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none" Visible="false"></asp:Label>

            <!-- Tab Navigation -->
            <div class="admin-tabs">
                <ul class="nav nav-tabs" id="adminTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="users-tab" data-bs-toggle="tab" data-bs-target="#users-content" type="button" role="tab">
                            <i class="bi bi-people"></i> User Management
                            <span class="nav-badge" id="usersBadge">
                                <asp:Label ID="lblNavPending" runat="server" Text="0"></asp:Label>
                            </span>
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="reports-tab" data-bs-toggle="tab" data-bs-target="#reports-content" type="button" role="tab">
                            <i class="bi bi-flag"></i> Content Reports
                            <span class="nav-badge" id="reportsBadge">
                                <asp:Label ID="lblNavReports" runat="server" Text="0"></asp:Label>
                            </span>
                        </button>
                    </li>
                </ul>

                <!-- Tab Content -->
                <div class="tab-content" id="adminTabsContent">
                    
                    <!-- Users Tab -->
                    <div class="tab-pane fade show active" id="users-content" role="tabpanel">
                        <!-- User Statistics -->
                        <div class="row mb-4">
                            <div class="col-md-3">
                                <div class="stats-card text-center">
                                    <div class="stats-number text-warning">
                                        <asp:Label ID="lblPendingCount" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="text-muted">Pending Approval</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stats-card text-center">
                                    <div class="stats-number text-success">
                                        <asp:Label ID="lblApprovedCount" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="text-muted">Approved Users</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stats-card text-center">
                                    <div class="stats-number text-danger">
                                        <asp:Label ID="lblRejectedCount" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="text-muted">Rejected Users</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stats-card text-center">
                                    <div class="stats-number text-info">
                                        <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="text-muted">Total Users</div>
                                </div>
                            </div>
                        </div>

                        <!-- User Filter Section -->
                        <div class="filter-section">
                            <div class="row align-items-center">
                                <div class="col-md-4">
                                    <asp:TextBox ID="txtUserSearch" runat="server" CssClass="form-control search-box" 
                                               placeholder="Search by name, email, or username..." AutoPostBack="true" 
                                               OnTextChanged="txtUserSearch_TextChanged"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <asp:DropDownList ID="ddlUserStatusFilter" runat="server" CssClass="form-select" 
                                                    AutoPostBack="true" OnSelectedIndexChanged="ddlUserStatusFilter_SelectedIndexChanged">
                                        <asp:ListItem Text="All Status" Value="" Selected="True" />
                                        <asp:ListItem Text="Pending" Value="pending" />
                                        <asp:ListItem Text="Approved" Value="approved" />
                                        <asp:ListItem Text="Rejected" Value="rejected" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <asp:DropDownList ID="ddlUserPositionFilter" runat="server" CssClass="form-select" 
                                                    AutoPostBack="true" OnSelectedIndexChanged="ddlUserPositionFilter_SelectedIndexChanged">
                                        <asp:ListItem Text="All Positions" Value="" Selected="True" />
                                        <asp:ListItem Text="Student" Value="Student" />
                                        <asp:ListItem Text="Teacher" Value="Teacher" />
                                        <asp:ListItem Text="Administrator" Value="Administrator" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <asp:Button ID="btnUserRefresh" runat="server" Text="Refresh" OnClick="btnUserRefresh_Click" 
                                               CssClass="btn btn-primary w-100" />
                                </div>
                            </div>
                        </div>

                        <!-- Users List -->
                        <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                            <ItemTemplate>
                                <div class="user-card <%# GetStatusClass(Eval("status").ToString()) %>">
                                    <div class="row align-items-center">
                                        <div class="col-md-8">
                                            <div class="d-flex justify-content-between align-items-start mb-2">
                                                <h5 class="mb-1">
                                                    <%# Eval("firstName") %> <%# Eval("lastName") %>
                                                    <small class="text-muted">(@<%# Eval("username") %>)</small>
                                                </h5>
                                                <span class="status-badge status-<%# Eval("status") %>">
                                                    <%# Eval("status").ToString().ToUpper() %>
                                                </span>
                                            </div>
                                            
                                            <div class="user-info">
                                                <div class="info-item">
                                                    <div class="info-label">Email</div>
                                                    <div class="info-value"><%# Eval("email") %></div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Position</div>
                                                    <div class="info-value"><%# Eval("position") %></div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Gender</div>
                                                    <div class="info-value"><%# Eval("gender") %></div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Phone</div>
                                                    <div class="info-value"><%# Eval("phone") ?? "Not provided" %></div>
                                                </div>
                                                <div class="info-item">
                                                    <div class="info-label">Registration Date</div>
                                                    <div class="info-value"><%# Convert.ToDateTime(Eval("createdAt")).ToString("MMM dd, yyyy HH:mm") %></div>
                                                </div>
                                            </div>
                                            
                                            <%# !string.IsNullOrEmpty(Eval("rejectionReason")?.ToString()) ? 
                                                "<div class='mt-2 p-2 bg-danger bg-opacity-10 border border-danger border-opacity-25 rounded'>" +
                                                "<strong class='text-danger'>Rejection Reason:</strong> " + Eval("rejectionReason") + "</div>" : "" %>
                                        </div>
                                        
                                        <div class="col-md-4">
                                            <div class="action-buttons justify-content-end">
                                                <asp:Button runat="server" ID="btnApprove" CommandName="Approve" 
                                                          CommandArgument='<%# Eval("uid") %>' Text="Approve" 
                                                          CssClass="btn btn-approve" Visible='<%# Eval("status").ToString() == "pending" %>' />
                                                
                                                <asp:Button runat="server" ID="btnReApprove" CommandName="Approve" 
                                                          CommandArgument='<%# Eval("uid") %>' Text="Re-approve" 
                                                          CssClass="btn btn-approve" Visible='<%# Eval("status").ToString() == "rejected" %>' />
                                                
                                                <button type="button" class='btn btn-reject' 
                                                      onclick='showRejectModal("<%# Eval("uid") %>", "<%# Eval("firstName") %> <%# Eval("lastName") %>")' 
                                                      style='<%# Eval("status").ToString() == "approved" ? "display:inline-block" : (Eval("status").ToString() == "pending" ? "display:inline-block" : "display:none") %>'>
                                                    <%# Eval("status").ToString() == "approved" ? "Revoke Approval" : "Reject" %>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:Panel ID="pnlNoUsers" runat="server" Visible="false" CssClass="no-data">
                            <i class="bi bi-people" style="font-size: 3rem; color: #dee2e6;"></i>
                            <h4 class="mt-3">No users found</h4>
                            <p>There are no users matching your current filters.</p>
                        </asp:Panel>
                    </div>

                    <!-- Reports Tab -->
                    <div class="tab-pane fade" id="reports-content" role="tabpanel">
                        <!-- Report Statistics -->
                        <div class="row mb-4">
                            <div class="col-md-3">
                                <div class="stats-card text-center">
                                    <div class="stats-number text-danger">
                                        <asp:Label ID="lblPendingReports" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="text-muted">Pending Reports</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stats-card text-center">
                                    <div class="stats-number text-warning">
                                        <asp:Label ID="lblHighPriorityReports" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="text-muted">High Priority</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stats-card text-center">
                                    <div class="stats-number text-success">
                                        <asp:Label ID="lblResolvedReports" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="text-muted">Resolved</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stats-card text-center">
                                    <div class="stats-number text-info">
                                        <asp:Label ID="lblTotalReports" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="text-muted">Total Reports</div>
                                </div>
                            </div>
                        </div>

                        <!-- Report Filter Section -->
                        <div class="filter-section">
                            <div class="row align-items-center">
                                <div class="col-md-3">
                                    <asp:TextBox ID="txtReportSearch" runat="server" CssClass="form-control search-box" 
                                               placeholder="Search reports..." AutoPostBack="true" 
                                               OnTextChanged="txtReportSearch_TextChanged"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <asp:DropDownList ID="ddlReportStatusFilter" runat="server" CssClass="form-select" 
                                                    AutoPostBack="true" OnSelectedIndexChanged="ddlReportStatusFilter_SelectedIndexChanged">
                                        <asp:ListItem Text="All Status" Value="" Selected="True" />
                                        <asp:ListItem Text="Pending" Value="pending" />
                                        <asp:ListItem Text="Resolved" Value="resolved" />
                                        <asp:ListItem Text="Dismissed" Value="dismissed" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <asp:DropDownList ID="ddlReportPriorityFilter" runat="server" CssClass="form-select" 
                                                    AutoPostBack="true" OnSelectedIndexChanged="ddlReportPriorityFilter_SelectedIndexChanged">
                                        <asp:ListItem Text="All Priority" Value="" Selected="True" />
                                        <asp:ListItem Text="High" Value="high" />
                                        <asp:ListItem Text="Medium" Value="medium" />
                                        <asp:ListItem Text="Low" Value="low" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <asp:DropDownList ID="ddlReportTypeFilter" runat="server" CssClass="form-select" 
                                                    AutoPostBack="true" OnSelectedIndexChanged="ddlReportTypeFilter_SelectedIndexChanged">
                                        <asp:ListItem Text="All Types" Value="" Selected="True" />
                                        <asp:ListItem Text="Posts" Value="post" />
                                        <asp:ListItem Text="Comments" Value="comment" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <asp:DropDownList ID="ddlReportSortBy" runat="server" CssClass="form-select" 
                                                    AutoPostBack="true" OnSelectedIndexChanged="ddlReportSortBy_SelectedIndexChanged">
                                        <asp:ListItem Text="Newest First" Value="newest" Selected="True" />
                                        <asp:ListItem Text="Oldest First" Value="oldest" />
                                        <asp:ListItem Text="Priority" Value="priority" />
                                        <asp:ListItem Text="Status" Value="status" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-1">
                                    <asp:Button ID="btnReportRefresh" runat="server" Text="Refresh" OnClick="btnReportRefresh_Click" 
                                               CssClass="btn btn-primary w-100" />
                                </div>
                            </div>
                        </div>

                        <!-- Reports List -->
                        <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
                            <ItemTemplate>
                                <div class="report-card priority-<%# Eval("priority") %> <%# Eval("isResolved").ToString().ToLower() == "true" ? "resolved" : "" %>">
                                    <!-- Report Header -->
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <div>
                                            <h5 class="mb-1">
                                                <i class="bi bi-<%# Eval("reportedItemType").ToString() == "post" ? "file-post" : "chat-dots" %>"></i>
                                                <%# Eval("reportedItemType").ToString() == "post" ? "Post Report" : "Comment Report" %>
                                                <span class="priority-badge priority-<%# Eval("priority") %>">
                                                    <%# Eval("priority") %> Priority
                                                </span>
                                            </h5>
                                            <small class="text-muted">
                                                Report ID: <%# Eval("reportId") %> | 
                                                <%# Eval("reasonText") %> | 
                                                <%# Convert.ToDateTime(Eval("reportedAt")).ToString("MMM dd, yyyy HH:mm") %>
                                            </small>
                                        </div>
                                        <span class="status-badge status-<%# Eval("status") %>">
                                            <%# Eval("status").ToString().ToUpper() %>
                                        </span>
                                    </div>

                                    <!-- Reporter Information -->
                                    <div class="reporter-info">
                                        <strong>Reported by:</strong> <%# Eval("reporterName") %> 
                                        <small class="text-muted">(<%# Eval("reporterId") %>)</small>
                                        <br>
                                        <strong>Group:</strong> <%# Eval("groupName") %>
                                    </div>

                                    <!-- Reported Content -->
                                    <div class="reported-content">
                                        <strong>Reported Content:</strong><br>
                                        <em>"<%# Eval("reportedContent") %>"</em>
                                        <hr class="my-2">
                                        <small>
                                            <strong>Author:</strong> <%# Eval("reportedAuthor") %> |
                                            <strong>Original Date:</strong> <%# Convert.ToDateTime(Eval("originalTimestamp")).ToString("MMM dd, yyyy HH:mm") %>
                                        </small>
                                    </div>

                                    <!-- Report Details -->
                                    <%# !string.IsNullOrEmpty(Eval("details")?.ToString()) ? 
                                        "<div class='mt-2 p-2 bg-info bg-opacity-10 border border-info border-opacity-25 rounded'>" +
                                        "<strong>Additional Details:</strong><br>" + Eval("details") + "</div>" : "" %>

                                    <!-- Report Metadata -->
                                    <div class="report-metadata">
                                        <div class="metadata-item">
                                            <div class="metadata-label">Content Length</div>
                                            <div class="metadata-value"><%# Eval("reportedContentLength") %> characters</div>
                                        </div>
                                        <div class="metadata-item">
                                            <div class="metadata-label">Report Count</div>
                                            <div class="metadata-value"><%# Eval("reportCount") %> reports</div>
                                        </div>
                                        <div class="metadata-item">
                                            <div class="metadata-label">Last Reported</div>
                                            <div class="metadata-value"><%# Convert.ToDateTime(Eval("lastReportedAt")).ToString("MMM dd HH:mm") %></div>
                                        </div>
                                        <%# !string.IsNullOrEmpty(Eval("parentPostId")?.ToString()) ? 
                                            "<div class='metadata-item'><div class='metadata-label'>Parent Post ID</div>" +
                                            "<div class='metadata-value'>" + Eval("parentPostId") + "</div></div>" : "" %>
                                    </div>

                                    <!-- Admin Action Section (if resolved) -->
                                    <%# Eval("isResolved").ToString().ToLower() == "true" ? 
                                        "<div class='admin-action-section " + (Eval("status").ToString() == "dismissed" ? "dismissed" : "") + "'>" +
                                        "<strong>Admin Action:</strong> " + Eval("adminAction") +
                                        (!string.IsNullOrEmpty(Eval("adminNotes")?.ToString()) ? "<br><strong>Notes:</strong> " + Eval("adminNotes") : "") +
                                        "<br><small><strong>Reviewed by:</strong> " + Eval("reviewedBy") + " on " + 
                                        Convert.ToDateTime(Eval("reviewedAt")).ToString("MMM dd, yyyy HH:mm") + "</small>" +
                                        "</div>" : "" %>

                                    <!-- Action Buttons -->
                                    <div class="action-buttons mt-3" style='<%# Eval("isResolved").ToString().ToLower() == "true" ? "display:none;" : "" %>'>
                                        <button type="button" class="btn btn-resolve btn-sm" 
                                               onclick="showActionModal('<%# Eval("reportId") %>', 'resolve', '<%# Eval("reportedItemType") %>', '<%# Eval("reportedItemId") %>')">
                                            <i class="bi bi-check-circle"></i> Resolve & Keep Content
                                        </button>
                                        <button type="button" class="btn btn-delete btn-sm" 
                                               onclick="showActionModal('<%# Eval("reportId") %>', 'delete', '<%# Eval("reportedItemType") %>', '<%# Eval("reportedItemId") %>')">
                                            <i class="bi bi-trash"></i> Delete Content
                                        </button>
                                        <button type="button" class="btn btn-dismiss btn-sm" 
                                               onclick="showActionModal('<%# Eval("reportId") %>', 'dismiss', '<%# Eval("reportedItemType") %>', '<%# Eval("reportedItemId") %>')">
                                            <i class="bi bi-x-circle"></i> Dismiss Report
                                        </button>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:Panel ID="pnlNoReports" runat="server" Visible="false" CssClass="no-data">
                            <i class="bi bi-flag" style="font-size: 3rem; color: #dee2e6;"></i>
                            <h4 class="mt-3">No reports found</h4>
                            <p>There are no reports matching your current filters.</p>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>

        <!-- User Rejection Modal -->
        <div class="modal fade rejection-modal" id="rejectModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-x-circle"></i> Reject User Registration
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>You are about to reject the registration for <strong id="rejectUserName"></strong>.</p>
                        <div class="mb-3">
                            <label for="txtRejectionReason" class="form-label">Reason for rejection <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtRejectionReason" runat="server" TextMode="MultiLine" Rows="4" 
                                       CssClass="form-control" placeholder="Please provide a clear reason for rejection..."></asp:TextBox>
                        </div>
                        <div class="alert alert-warning">
                            <i class="bi bi-exclamation-triangle"></i>
                            <strong>Note:</strong> The user will receive an email notification with this rejection reason.
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

        <!-- Report Admin Action Modal -->
        <div class="modal fade action-modal" id="actionModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="actionModalTitle">Admin Action</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div id="actionDescription"></div>
                        <div class="mb-3 mt-3">
                            <label for="adminNotes" class="form-label">Admin Notes (optional)</label>
                            <asp:TextBox ID="txtAdminNotes" runat="server" TextMode="MultiLine" Rows="3" 
                                       CssClass="form-control" placeholder="Add notes about this decision..."></asp:TextBox>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnConfirmAction" runat="server" Text="Confirm" 
                                   OnClick="btnConfirmAction_Click" CssClass="btn btn-primary" />
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Hidden fields -->
        <asp:HiddenField ID="hiddenUserIdToReject" runat="server" />
        <asp:HiddenField ID="hdnReportId" runat="server" />
        <asp:HiddenField ID="hdnActionType" runat="server" />
        <asp:HiddenField ID="hdnItemType" runat="server" />
        <asp:HiddenField ID="hdnItemId" runat="server" />
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // User rejection modal
        function showRejectModal(userId, userName) {
            document.getElementById('<%= hiddenUserIdToReject.ClientID %>').value = userId;
            document.getElementById('rejectUserName').innerText = userName;
            document.getElementById('<%= txtRejectionReason.ClientID %>').value = '';

            var modal = new bootstrap.Modal(document.getElementById('rejectModal'));
            modal.show();
        }

        // Report action modal
        function showActionModal(reportId, actionType, itemType, itemId) {
            document.getElementById('<%= hdnReportId.ClientID %>').value = reportId;
            document.getElementById('<%= hdnActionType.ClientID %>').value = actionType;
            document.getElementById('<%= hdnItemType.ClientID %>').value = itemType;
            document.getElementById('<%= hdnItemId.ClientID %>').value = itemId;

            const modal = document.getElementById('actionModal');
            const title = document.getElementById('actionModalTitle');
            const description = document.getElementById('actionDescription');
            const confirmBtn = document.getElementById('<%= btnConfirmAction.ClientID %>');

            // Clear previous notes
            document.getElementById('<%= txtAdminNotes.ClientID %>').value = '';

            let actionText = '';
            let buttonClass = 'btn-primary';
            let buttonText = 'Confirm';

            switch (actionType) {
                case 'resolve':
                    actionText = 'You are about to <strong>resolve this report and keep the content</strong>. This means the reported content will remain visible and the report will be marked as resolved.';
                    title.innerHTML = '<i class="bi bi-check-circle text-success"></i> Resolve Report';
                    buttonClass = 'btn btn-success';
                    buttonText = 'Resolve & Keep Content';
                    break;
                case 'delete':
                    actionText = 'You are about to <strong>delete the reported content</strong>. This action cannot be undone. The content will be permanently removed and the report will be marked as resolved.';
                    title.innerHTML = '<i class="bi bi-trash text-danger"></i> Delete Content';
                    buttonClass = 'btn btn-danger';
                    buttonText = 'Delete Content';
                    break;
                case 'dismiss':
                    actionText = 'You are about to <strong>dismiss this report</strong>. The reported content will remain visible and the report will be marked as dismissed (not requiring action).';
                    title.innerHTML = '<i class="bi bi-x-circle text-warning"></i> Dismiss Report';
                    buttonClass = 'btn btn-warning';
                    buttonText = 'Dismiss Report';
                    break;
            }

            description.innerHTML = `
                <div class="alert alert-info">
                    ${actionText}
                </div>
                <div class="mt-3">
                    <strong>Report Details:</strong><br>
                    <small class="text-muted">Type: ${itemType.charAt(0).toUpperCase() + itemType.slice(1)} | ID: ${itemId}</small>
                </div>
            `;

            // Update button
            confirmBtn.className = buttonClass;
            confirmBtn.innerText = buttonText;

            // Show modal
            const bsModal = new bootstrap.Modal(modal);
            bsModal.show();
        }

        // Update navigation badges
        function updateNavBadges() {
            const pendingUsers = document.querySelector('#lblPendingCount').innerText;
            document.querySelector('#lblNavPending').innerText = pendingUsers;

            const pendingReports = document.querySelector('#lblPendingReports').innerText;
            document.querySelector('#lblNavReports').innerText = pendingReports;

            const userBadge = document.querySelector('#usersBadge');
            const reportBadge = document.querySelector('#reportsBadge');

            if (pendingUsers === '0') {
                userBadge.style.display = 'none';
            } else {
                userBadge.style.display = 'inline-block';
            }

            if (pendingReports === '0') {
                reportBadge.style.display = 'none';
            } else {
                reportBadge.style.display = 'inline-block';
            }
        }

        // Auto-hide alerts
        window.addEventListener('load', function () {
            updateNavBadges();

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
        });

        // Tab change handling
        document.addEventListener('DOMContentLoaded', function () {
            const triggerTabList = document.querySelectorAll('#adminTabs button');
            triggerTabList.forEach(triggerEl => {
                const tabTrigger = new bootstrap.Tab(triggerEl);

                triggerEl.addEventListener('click', event => {
                    event.preventDefault();
                    tabTrigger.show();
                });
            });
        });
    </script>
</body>
</html>