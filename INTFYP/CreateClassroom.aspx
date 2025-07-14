<%@ Page Title="Create Classroom" Language="C#" MasterPageFile="~/TeacherSite.master"
    AutoEventWireup="true" CodeBehind="CreateClassroom.aspx.cs"
    Inherits="YourProjectNamespace.CreateClassroom" Async="true" %>

<asp:Content ID="ClassroomContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
        }

        .form-section {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            margin-bottom: 24px;
            border: 1px solid #e0e0e0;
        }

        .form-header {
            color: #212121;
            font-weight: 600;
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .form-label {
            font-weight: 500;
            color: #424242;
            font-size: 14px;
            margin-bottom: 6px;
        }

        .form-control {
            border-radius: 4px;
            border: 1px solid #e0e0e0;
            padding: 10px 12px;
            font-size: 14px;
            transition: border-color 0.2s;
        }

        .form-control:focus {
            border-color: #9e9e9e;
            box-shadow: none;
        }

        .btn {
            border-radius: 4px;
            font-weight: 500;
            font-size: 14px;
            padding: 10px 20px;
            transition: all 0.2s;
        }

        .btn-primary {
            background-color: #212121;
            border-color: #212121;
            color: #ffffff;
        }

        .btn-primary:hover {
            background-color: #000000;
            border-color: #000000;
        }

        .btn-outline-primary {
            border-color: #e0e0e0;
            color: #424242;
            background-color: #ffffff;
        }

        .btn-outline-primary:hover {
            background-color: #f5f5f5;
            border-color: #bdbdbd;
            color: #212121;
        }

        .student-list {
            max-height: 200px;
            overflow-y: auto;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 0;
            background-color: #ffffff;
            margin-top: 12px;
        }

        .student-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 16px;
            border-bottom: 1px solid #f5f5f5;
            font-size: 14px;
            color: #424242;
        }

        .student-item:last-child {
            border-bottom: none;
        }

        .student-item:hover {
            background-color: #fafafa;
        }

        .preview-box {
            background: #fafafa;
            border: 1px solid #e0e0e0;
            padding: 20px;
            border-radius: 6px;
            margin-top: 24px;
            color: #424242;
            font-size: 14px;
        }

        .preview-box h5 {
            color: #212121;
            margin-bottom: 16px;
            font-weight: 600;
        }

        .status-message {
            font-size: 13px;
            margin-top: 6px;
            padding: 6px 0;
        }

        .time-input-group {
            display: flex;
            gap: 8px;
        }

        .time-input-group .form-control {
            flex: 1;
        }

        .remove-btn {
            color: #9e9e9e;
            cursor: pointer;
            font-size: 16px;
            background: none;
            border: none;
            padding: 0 4px;
        }

        .remove-btn:hover {
            color: #e53935;
        }

        .input-group {
            box-shadow: none;
        }

        .input-group .btn {
            border-left: 1px solid #e0e0e0;
            background-color: #f5f5f5;
        }

        /* Custom scrollbar */
        .student-list::-webkit-scrollbar {
            width: 6px;
        }

        .student-list::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 4px;
        }

        .student-list::-webkit-scrollbar-thumb {
            background: #bdbdbd;
            border-radius: 4px;
        }

        .student-list::-webkit-scrollbar-thumb:hover {
            background: #9e9e9e;
        }
    </style>

    <div class="form-section">
        <h3 class="form-header">Create a New Classroom</h3>

        <div class="row g-3">
            <div class="col-md-6">
                <label class="form-label">Class Name</label>
                <asp:TextBox ID="txtClassName" runat="server" CssClass="form-control" placeholder="e.g., Software Engineering" />
            </div>
            <div class="col-md-6">
                <label class="form-label">Description</label>
                <asp:TextBox ID="txtClassDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Optional class description" />
            </div>

            <div class="col-md-4">
                <label class="form-label">Recurring Day</label>
                <asp:DropDownList ID="ddlDayOfWeek" runat="server" CssClass="form-control">
                    <asp:ListItem Text="Monday" />
                    <asp:ListItem Text="Tuesday" />
                    <asp:ListItem Text="Wednesday" />
                    <asp:ListItem Text="Thursday" />
                    <asp:ListItem Text="Friday" />
                    <asp:ListItem Text="Saturday" />
                    <asp:ListItem Text="Sunday" />
                </asp:DropDownList>
            </div>

            <div class="col-md-4">
                <label class="form-label">Start Time</label>
                <div class="time-input-group">
                    <asp:TextBox ID="txtStartTime" runat="server" TextMode="Time" CssClass="form-control" />
                    
                </div>
            </div>

            <div class="col-md-4">
                <label class="form-label">End Time</label>
                <div class="time-input-group">
                    <asp:TextBox ID="txtEndTime" runat="server" TextMode="Time" CssClass="form-control" />
                    
                </div>
            </div>

            <div class="col-md-6">
                <label class="form-label">Venue</label>
                <asp:TextBox ID="txtVenue" runat="server" CssClass="form-control" placeholder="e.g., Lab A" />
            </div>

            <div class="col-md-6">
                <label class="form-label">Invite Students</label>
                <div class="input-group">
                    <asp:TextBox ID="txtStudentEmail" runat="server" CssClass="form-control" placeholder="student@example.com" />
                    <asp:Button ID="btnAddStudent" runat="server" Text="Add" CssClass="btn btn-outline-primary" OnClick="btnAddStudent_Click" />
                </div>
                <asp:Label ID="lblInviteStatus" runat="server" CssClass="status-message" EnableViewState="false" />
                <div class="student-list">
                    <asp:Repeater ID="rptStudents" runat="server" OnItemCommand="rptStudents_ItemCommand">
                        <ItemTemplate>
                            <div class="student-item">
                                <span><%# Eval("Name") %> (<%# Eval("Email") %>)</span>
                                <asp:LinkButton ID="btnRemove" runat="server" CommandName="Remove" CommandArgument='<%# Eval("Email") %>' Text="✕" CssClass="remove-btn" />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <!-- Preview -->
        <asp:Panel ID="pnlPreview" runat="server" CssClass="preview-box" Visible="false">
            <h5>Classroom Preview</h5>
            <asp:Label ID="lblPreview" runat="server" />
        </asp:Panel>

        <div class="d-flex justify-content-end mt-4">
            <asp:Button ID="btnCreateClass" runat="server" Text="Create Classroom" CssClass="btn btn-primary" OnClick="btnCreateClass_Click" />
        </div>
    </div>
</asp:Content>