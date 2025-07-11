<%@ Page Title="Create Post"
    Language="C#"
    MasterPageFile="~/TeacherSite.master"
    AutoEventWireup="true"
    CodeBehind="CreatePost.aspx.cs"
    Inherits="YourProjectNamespace.CreatePost"
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <h2>Create Post</h2>

    <asp:Label ID="lblStatus" runat="server" ForeColor="Green" />
    <br /><br />

    <div style="max-width: 600px;">
        <label for="ddlClasses">Select Class:</label><br />
        <asp:DropDownList ID="ddlClasses" runat="server" Width="100%" AppendDataBoundItems="true">
            <asp:ListItem Text="-- Select Class --" Value="" />
        </asp:DropDownList>
        <br /><br />

        <label for="txtPostContent">Post Content:</label><br />
        <asp:TextBox ID="txtPostContent" runat="server" TextMode="MultiLine" Rows="6" Width="100%" />
        <br /><br />

        <label for="FileUpload1">Attach File (Optional):</label><br />
        <asp:FileUpload ID="FileUpload1" runat="server" />
        <br /><br />

        <asp:Button ID="btnSubmitPost" runat="server" Text="Post to Class"
            CssClass="btn btn-primary" OnClick="btnSubmitPost_Click" />
    </div>
</asp:Content>
