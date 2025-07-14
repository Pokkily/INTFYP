<%@ Page Title="Manage Classrooms" Language="C#" MasterPageFile="~/TeacherSite.master"
    AutoEventWireup="true" CodeBehind="ManageClassroom.aspx.cs"
    Inherits="YourProjectNamespace.ManageClassroom" Async="true" %>

<asp:Content ID="ManageClassroomContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
        }

        .page-header {
            color: #212121;
            font-weight: 600;
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .classroom-card {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
            border: 1px solid #e0e0e0;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .classroom-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .classroom-title {
            color: #212121;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 18px;
        }

        .classroom-meta {
            color: #616161;
            font-size: 14px;
            margin-bottom: 12px;
        }

        .classroom-description {
            color: #424242;
            font-size: 14px;
            margin-bottom: 16px;
            padding: 12px 0;
            border-top: 1px solid #f5f5f5;
            border-bottom: 1px solid #f5f5f5;
        }

        .student-count {
            display: inline-block;
            background-color: #f5f5f5;
            color: #616161;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            margin-right: 8px;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
            margin-top: 16px;
        }

        .btn {
            border-radius: 4px;
            font-weight: 500;
            font-size: 13px;
            padding: 8px 16px;
            transition: all 0.2s;
            border: none;
        }

        .btn-edit {
            background-color: #e0e0e0;
            color: #424242;
        }

        .btn-edit:hover {
            background-color: #bdbdbd;
        }

        .btn-delete {
            background-color: #f5f5f5;
            color: #e53935;
        }

        .btn-delete:hover {
            background-color: #ffebee;
        }

        .btn-view {
            background-color: #212121;
            color: #ffffff;
        }

        .btn-view:hover {
            background-color: #000000;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #9e9e9e;
            border: 1px dashed #e0e0e0;
            border-radius: 8px;
            background-color: #fafafa;
        }

        .modal-header {
            border-bottom: 1px solid #f0f0f0;
            padding: 16px 24px;
        }

        .modal-title {
            font-weight: 600;
            color: #212121;
        }

        .modal-body {
            padding: 24px;
        }

        .modal-footer {
            border-top: 1px solid #f0f0f0;
            padding: 16px 24px;
        }

        .search-container {
            margin-bottom: 24px;
        }

        .search-input {
            border-radius: 20px;
            padding-left: 16px;
            border: 1px solid #e0e0e0;
        }

        .filter-dropdown {
            border-radius: 20px;
            border: 1px solid #e0e0e0;
        }
    </style>

    <div class="container-fluid">
        <h3 class="page-header">Manage Your Classrooms</h3>

        <div class="row mb-4">
            <div class="col-md-8">
                <div class="input-group search-container">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" placeholder="Search classrooms..." />
                    <div class="input-group-append">
                        <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-view" Text="Search" OnClick="btnSearch_Click" />
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <asp:DropDownList ID="ddlFilter" runat="server" CssClass="form-control filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                    <asp:ListItem Text="All Classrooms" Value="all" Selected="True" />
                    <asp:ListItem Text="Active" Value="active" />
                    <asp:ListItem Text="Archived" Value="archived" />
                </asp:DropDownList>
            </div>
        </div>

        <asp:Panel ID="pnlClassrooms" runat="server">
            <!-- Classroom cards will be populated here -->
        </asp:Panel>

        <asp:Panel ID="pnlEmptyState" runat="server" Visible="false" CssClass="empty-state">
            <i class="fas fa-chalkboard-teacher" style="font-size: 48px; margin-bottom: 16px;"></i>
            <h4>No Classrooms Found</h4>
            <p>You haven't created any classrooms yet or no classrooms match your search.</p>
            <asp:HyperLink ID="lnkCreateClassroom" runat="server" NavigateUrl="~/CreateClassroom.aspx" CssClass="btn btn-view">Create New Classroom</asp:HyperLink>
        </asp:Panel>
    </div>

    <!-- Edit Classroom Modal -->
    <div class="modal fade" id="editClassroomModal" tabindex="-1" role="dialog" aria-labelledby="editClassroomModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editClassroomModalLabel">Edit Classroom</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label class="form-label">Class Name</label>
                        <asp:TextBox ID="txtEditClassName" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Description</label>
                        <asp:TextBox ID="txtEditDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">Day of Week</label>
                                <asp:DropDownList ID="ddlEditDayOfWeek" runat="server" CssClass="form-control">
                                    <asp:ListItem Text="Monday" />
                                    <asp:ListItem Text="Tuesday" />
                                    <asp:ListItem Text="Wednesday" />
                                    <asp:ListItem Text="Thursday" />
                                    <asp:ListItem Text="Friday" />
                                    <asp:ListItem Text="Saturday" />
                                    <asp:ListItem Text="Sunday" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">Venue</label>
                                <asp:TextBox ID="txtEditVenue" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">Start Time</label>
                                <asp:TextBox ID="txtEditStartTime" runat="server" TextMode="Time" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">End Time</label>
                                <asp:TextBox ID="txtEditEndTime" runat="server" TextMode="Time" CssClass="form-control" />
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Text="Active" Value="active" />
                            <asp:ListItem Text="Archived" Value="archived" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-edit" data-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSaveChanges" runat="server" Text="Save Changes" CssClass="btn btn-view" OnClick="btnSaveChanges_Click" />
                    <asp:HiddenField ID="hdnEditClassroomId" runat="server" />
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteConfirmationModal" tabindex="-1" role="dialog" aria-labelledby="deleteConfirmationModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteConfirmationModalLabel">Confirm Deletion</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this classroom? This action cannot be undone.</p>
                    <p class="text-muted">All associated student enrollments and class data will be permanently removed.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-edit" data-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnConfirmDelete" runat="server" Text="Delete Classroom" CssClass="btn btn-delete" OnClick="btnConfirmDelete_Click" />
                    <asp:HiddenField ID="hdnDeleteClassroomId" runat="server" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>