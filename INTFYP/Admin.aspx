<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="Admin.aspx.cs" Inherits="YourProjectNamespace.Admin" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | User Management</title>
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
        
        .admin-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, #3a5bc7 100%);
            color: white;
            padding: 2rem 0;
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
        
        .user-card {
            background: white;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
            border-left: 4px solid var(--warning-color);
        }
        
        .user-card.approved {
            border-left-color: var(--success-color);
        }
        
        .user-card.rejected {
            border-left-color: var(--danger-color);
        }
        
        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
        }
        
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status-approved {
            background-color: #d1edff;
            color: #0c5460;
        }
        
        .status-rejected {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .user-info {
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
        }
        
        .btn-approve {
            background-color: var(--success-color);
            border-color: var(--success-color);
            color: white;
        }
        
        .btn-approve:hover {
            background-color: #17a673;
            border-color: #17a673;
            color: white;
        }
        
        .btn-reject {
            background-color: var(--danger-color);
            border-color: var(--danger-color);
            color: white;
        }
        
        .btn-reject:hover {
            background-color: #c73321;
            border-color: #c73321;
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
        
        .no-users {
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="admin-header">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h1><i class="bi bi-shield-check"></i> Admin Dashboard</h1>
                        <p class="mb-0">User Registration Management System</p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <asp:Button ID="btnLogout" runat="server" Text="Logout" OnClick="btnLogout_Click" 
                                   CssClass="btn btn-outline-light" />
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

            <!-- Filter Section -->
            <div class="filter-section">
                <div class="row align-items-center">
                    <div class="col-md-4">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-box" 
                                   placeholder="Search by name, email, or username..." AutoPostBack="true" 
                                   OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select" 
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                            <asp:ListItem Text="All Status" Value="" Selected="True" />
                            <asp:ListItem Text="Pending" Value="pending" />
                            <asp:ListItem Text="Approved" Value="approved" />
                            <asp:ListItem Text="Rejected" Value="rejected" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlPositionFilter" runat="server" CssClass="form-select" 
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlPositionFilter_SelectedIndexChanged">
                            <asp:ListItem Text="All Positions" Value="" Selected="True" />
                            <asp:ListItem Text="Student" Value="Student" />
                            <asp:ListItem Text="Teacher" Value="Teacher" />
                            <asp:ListItem Text="Administrator" Value="Administrator" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-2">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" OnClick="btnRefresh_Click" 
                                   CssClass="btn btn-primary w-100" />
                    </div>
                </div>
            </div>

            <!-- Users List -->
            <div class="row">
                <div class="col-12">
                    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                        <HeaderTemplate>
                            <div class="users-container">
                        </HeaderTemplate>
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
                                            <%# !string.IsNullOrEmpty(Eval("birthdate")?.ToString()) ? 
                                                "<div class='info-item'><div class='info-label'>Birthdate</div><div class='info-value'>" + 
                                                Convert.ToDateTime(Eval("birthdate")).ToString("MMM dd, yyyy") + "</div></div>" : "" %>
                                        </div>
                                        
                                        <%# !string.IsNullOrEmpty(Eval("address")?.ToString()) ? 
                                            "<div class='mt-2'><strong>Address:</strong> " + Eval("address") + "</div>" : "" %>
                                        
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
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoUsers" runat="server" Visible="false" CssClass="no-users">
                        <i class="bi bi-people" style="font-size: 3rem; color: #dee2e6;"></i>
                        <h4 class="mt-3">No users found</h4>
                        <p>There are no users matching your current filters.</p>
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
        
        <asp:HiddenField ID="hiddenUserIdToReject" runat="server" />
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function showRejectModal(userId, userName) {
            document.getElementById('<%= hiddenUserIdToReject.ClientID %>').value = userId;
            document.getElementById('rejectUserName').innerText = userName;
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
        });
    </script>
</body>
</html>