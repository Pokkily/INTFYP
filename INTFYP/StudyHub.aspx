<%@ Page Title="Study Hub" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="StudyHub.aspx.cs" Inherits="YourProjectNamespace.StudyHub" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Study Hub
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="mb-0">Your Study Groups</h3>
            <asp:Button ID="btnCreateGroup" runat="server" Text="Create Group" CssClass="btn btn-dark" OnClick="btnCreateGroup_Click" />
        </div>

        <asp:Repeater ID="rptGroups" runat="server">
            <ItemTemplate>
                <div class="col-md-4 mb-4">
    <div class="card shadow-sm border-0">
        <%-- Group Image --%>
        <img src='<%# Eval("groupImage") %>' class="card-img-top rounded-top" style="height: 180px; object-fit: cover;" alt="Group Image" />

        <div class="card-body d-flex flex-column">
            <h5 class="card-title mb-1"><%# Eval("groupName") %></h5>
            <small class="text-muted mb-2">Hoster: <%# Eval("hosterName") %></small>
            <small class="text-muted mb-2">Capacity: <%# Eval("capacity") %></small>

            <a href='StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>' class="btn btn-sm btn-outline-dark mt-auto">View Group</a>
        </div>
    </div>
</div>

            </ItemTemplate>

            <SeparatorTemplate>
                <%-- Close and open row every 3 items --%>
                </div><div class="row">
            </SeparatorTemplate>
        </asp:Repeater>
    </div>

    <style>
        .card-title {
            font-weight: 600;
        }
        .card {
    transition: all 0.3s ease;
    border-radius: 12px;
    overflow: hidden;
}

.card:hover {
    box-shadow: 0 8px 18px rgba(0, 0, 0, 0.1);
}

    </style>
</asp:Content>
