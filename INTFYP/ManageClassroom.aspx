<%@ Page Title="Manage Classrooms" Language="C#" MasterPageFile="~/TeacherSite.master"
    AutoEventWireup="true" CodeBehind="ManageClassroom.aspx.cs" Inherits="YourProjectNamespace.ManageClassroom" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        .card {
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            background-color: #ffffff;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
        }
        .card h5 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .card-actions button {
            margin-right: 8px;
        }
        .form-inline .form-control {
            margin-bottom: 10px;
            width: 100%;
        }
        .form-label {
    font-weight: 500;
    margin-top: 10px;
    display: block;
    color: #333;
}
.form-inline .form-control {
    border-radius: 4px;
    padding: 10px;
    margin-bottom: 8px;
}
.card-actions .btn {
    margin-right: 10px;
}

    </style>

    <h3 class="mb-4">Manage Your Classrooms</h3>

    <asp:Repeater ID="rptClassrooms" runat="server" OnItemCommand="rptClassrooms_ItemCommand">
        <ItemTemplate>
            <div class="card">
                <asp:HiddenField ID="hfClassId" runat="server" Value='<%# Eval("Id") %>' />
                <asp:Panel ID="pnlView" runat="server" Visible='<%# !(bool)Eval("IsEditing") %>'>
                    <h5><%# Eval("Name") %> (<%# Eval("WeeklyDay") %>)</h5>
                    <p>
                        <b>Description:</b> <%# Eval("Description") %><br />
                        <%# FormatTime(Eval("StartTime")) %> - <%# FormatTime(Eval("EndTime")) %>

                        <b>Venue:</b> <%# Eval("Venue") %><br />
                        <b>Status:</b> <%# Eval("Status") %>
                    </p>
                    <div class="card-actions">
                        <asp:Button runat="server" CommandName="Edit" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-outline-primary" Text="Edit" />
                        <asp:Button runat="server" CommandName="Delete" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-outline-danger" Text="Delete" OnClientClick="return confirm('Delete this class?');" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlEdit" runat="server" Visible='<%# (bool)Eval("IsEditing") %>'>
    <div class="form-inline">
        <label class="form-label d-block">Class Name</label>
        <asp:TextBox ID="txtEditName" runat="server" CssClass="form-control" Text='<%# Eval("Name") %>' />

        <label class="form-label d-block">Description</label>
        <asp:TextBox ID="txtEditDescription" runat="server" CssClass="form-control" Text='<%# Eval("Description") %>' TextMode="MultiLine" Rows="2" />

        <label class="form-label d-block">Venue</label>
        <asp:TextBox ID="txtEditVenue" runat="server" CssClass="form-control" Text='<%# Eval("Venue") %>' />

        <label class="form-label d-block">Recurring Day</label>
        <asp:DropDownList ID="ddlEditDay" runat="server" CssClass="form-control">
            <asp:ListItem Text="Monday" />
            <asp:ListItem Text="Tuesday" />
            <asp:ListItem Text="Wednesday" />
            <asp:ListItem Text="Thursday" />
            <asp:ListItem Text="Friday" />
            <asp:ListItem Text="Saturday" />
            <asp:ListItem Text="Sunday" />
        </asp:DropDownList>

        <label class="form-label d-block">Start Time</label>
        <asp:TextBox ID="txtEditStart" runat="server" CssClass="form-control" Text='<%# Eval("StartTime") %>' TextMode="Time" />

        <label class="form-label d-block">End Time</label>
        <asp:TextBox ID="txtEditEnd" runat="server" CssClass="form-control" Text='<%# Eval("EndTime") %>' TextMode="Time" />
    </div>

    <div class="card-actions mt-3">
        <asp:Button runat="server" CommandName="Update" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-success" Text="Save" />
        <asp:Button runat="server" CommandName="Cancel" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-secondary" Text="Cancel" />
    </div>
</asp:Panel>

            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Content>
