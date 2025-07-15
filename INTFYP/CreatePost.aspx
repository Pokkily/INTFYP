<%@ Page Title="Create Post"
    Language="C#"
    MasterPageFile="~/TeacherSite.master"
    AutoEventWireup="true"
    CodeBehind="CreatePost.aspx.cs"
    Inherits="YourProjectNamespace.CreatePost"
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        .form-wrapper {
            max-width: 700px;
            margin: auto;
            padding: 24px;
            border: 1px solid #e1e1e1;
            border-radius: 12px;
            background-color: #f9f9f9;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

            .form-wrapper h2 {
                margin-bottom: 24px;
                font-size: 24px;
                font-weight: 600;
                border-bottom: 1px solid #ddd;
                padding-bottom: 12px;
            }

        .form-group {
            margin-bottom: 16px;
        }

            .form-group label {
                display: block;
                font-weight: 500;
                margin-bottom: 6px;
            }

            .form-group input,
            .form-group textarea,
            .form-group select {
                width: 100%;
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 6px;
                font-size: 14px;
            }

        .btn {
            padding: 10px 20px;
            font-size: 15px;
            border-radius: 6px;
            border: none;
            cursor: pointer;
        }

        .btn-submit {
            background-color: #007bff;
            color: white;
            margin-right: 10px;
        }

        .btn-reset {
            background-color: #6c757d;
            color: white;
        }

        .success-summary {
            margin-top: 20px;
            padding: 12px;
            background-color: #e6f4ea;
            border-left: 4px solid #28a745;
            border-radius: 6px;
        }
    </style>

    <div class="form-wrapper">
        <h2>Create New Post</h2>

        <asp:Label ID="lblStatus" runat="server" CssClass="success-summary" Visible="false" />

        <div class="form-group">
            <label for="ddlClasses">Class</label>
            <asp:DropDownList ID="ddlClasses" runat="server" AppendDataBoundItems="true">
                <asp:ListItem Text="-- Select Class --" Value="" />
            </asp:DropDownList>
        </div>

        <div class="form-group">
            <label for="ddlPostType">Post Type</label>
            <asp:DropDownList ID="ddlPostType" runat="server">
                <asp:ListItem Text="Announcement" Value="announcement" />
                <asp:ListItem Text="Assignment" Value="assignment" />
                <asp:ListItem Text="Reminder" Value="reminder" />
            </asp:DropDownList>
        </div>

        <div class="form-group">
            <label for="txtPostTitle">Post Title</label>
            <asp:TextBox ID="txtPostTitle" runat="server" />
        </div>

        <div class="form-group">
            <label for="txtPostContent">Content</label>
            <asp:TextBox ID="txtPostContent" runat="server" TextMode="MultiLine" Rows="6" />
        </div>

        <div class="form-group">
            <label for="FileUpload1">Attach File (Optional)</label>
            <div class="form-group">
                <label>Attach Files</label>

                <asp:FileUpload ID="fileUploadAdd" runat="server" />
                <asp:Button ID="btnAddFile" runat="server" Text="Add File" CssClass="btn btn-secondary"
                    OnClick="btnAddFile_Click" />

                <asp:HiddenField ID="hfUploadedFiles" runat="server" />

                <asp:PlaceHolder ID="phAttachedFiles" runat="server" Visible="false">
                    <div class="file-preview" style="margin-top: 10px;">
                        <asp:Repeater ID="rptAttachedFiles" runat="server">
                            <ItemTemplate>
                                <div class="file-item">
                                    <a href='<%# Eval("Url") %>' target="_blank"><%# Eval("Name") %></a>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:PlaceHolder>
            </div>



        </div>

        <div class="form-group">
            <label for="txtScheduleDate">Schedule Publish Date/Time (Optional)</label>
            <asp:TextBox ID="txtScheduleDate" runat="server" TextMode="DateTimeLocal" />
        </div>

        <asp:Button ID="btnSubmitPost" runat="server" Text="Submit Post" CssClass="btn btn-submit" OnClick="btnSubmitPost_Click" />
        <asp:Button ID="btnReset" runat="server" Text="Clear Form" CssClass="btn btn-reset" OnClientClick="return clearForm();" />

        <script type="text/javascript">
            function clearForm() {
                document.getElementById('<%= txtPostTitle.ClientID %>').value = '';
                document.getElementById('<%= txtPostContent.ClientID %>').value = '';
                document.getElementById('<%= ddlPostType.ClientID %>').selectedIndex = 0;
                document.getElementById('<%= ddlClasses.ClientID %>').selectedIndex = 0;
                document.getElementById('<%= txtScheduleDate.ClientID %>').value = '';
                return false; // Prevent postback
            }
        </script>
    </div>
</asp:Content>