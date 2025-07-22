<%@ Page Title="Create Study Group" Language="C#" Async="true" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="CreateStudyGroup.aspx.cs" Inherits="YourProjectNamespace.CreateStudyGroup" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Create Study Group
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-5" style="max-width: 600px;">
        <h3 class="mb-4">Create a New Study Group</h3>

        <div class="mb-3">
            <label>Group Name</label>
            <asp:TextBox ID="txtGroupName" runat="server" CssClass="form-control" />
        </div>

        <div class="mb-3">
            <label>Capacity</label>
            <asp:TextBox ID="txtCapacity" runat="server" CssClass="form-control" TextMode="Number" />
        </div>

        <div class="mb-3">
            <label>Description</label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" />
        </div>

        <div class="mb-3">
            <label>Upload Group Image</label>
            <asp:FileUpload ID="fileGroupImage" runat="server" CssClass="form-control" />
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="text-success mb-2 d-block" />

        <asp:Button ID="btnCreate" runat="server" Text="Create Group" CssClass="btn btn-dark" OnClick="btnCreate_Click" />
    </div>
</asp:Content>
