<%@ Page Title="Manage Posts"
    Language="C#"
    MasterPageFile="~/TeacherSite.master"
    AutoEventWireup="true"
    CodeBehind="ManagePost.aspx.cs"
    Inherits="YourProjectNamespace.ManagePost"
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        body {
            background-color: #f5f5f5;
            font-family: 'Segoe UI', sans-serif;
        }

        .post-container {
            max-width: 1000px;
            margin: 30px auto;
            padding: 30px;
            background-color: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .filter-row {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            margin-bottom: 30px;
            gap: 20px;
        }

        .form-control {
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
            width: 220px;
        }

        .post-item {
            background-color: #f9f9f9;
            border: 1px solid #e1e1e1;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
        }

        .file-preview {
            background-color: #fff;
            border: 1px dashed #ccc;
            padding: 10px;
            margin-top: 10px;
            border-radius: 6px;
        }

        .file-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 6px;
        }

        .file-item a {
            text-decoration: none;
            color: #007bff;
        }

        .file-item a:hover {
            text-decoration: underline;
        }

        .btn {
            padding: 8px 16px;
            margin-right: 6px;
            margin-top: 10px;
            border-radius: 6px;
            border: none;
            font-size: 14px;
            cursor: pointer;
        }

        .btn-edit { background-color: #333; color: white; }
        .btn-save { background-color: #007bff; color: white; }
        .btn-cancel { background-color: #6c757d; color: white; }
        .btn-delete { background-color: #dc3545; color: white; }
        .remove-btn { color: #e60023; font-weight: bold; cursor: pointer; }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            font-weight: 600;
            margin-bottom: 5px;
            display: block;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border-radius: 6px;
            border: 1px solid #ccc;
            font-size: 14px;
        }

        .no-posts {
            background-color: #fff;
            border: 1px solid #ccc;
            text-align: center;
            padding: 20px;
            border-radius: 8px;
            color: #888;
        }
    </style>

    <div class="post-container">
        <div class="filter-row">
            <div>
                <label>Select Class:</label>
                <asp:DropDownList ID="ddlClassFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlClassFilter_SelectedIndexChanged" CssClass="form-control" />
            </div>
            <div>
                <label>Filter by Type:</label>
                <asp:DropDownList ID="ddlPostTypeFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPostTypeFilter_SelectedIndexChanged" CssClass="form-control">
                    <asp:ListItem Text="All" Value="all" />
                    <asp:ListItem Text="Announcement" Value="announcement" />
                    <asp:ListItem Text="Assignment" Value="assignment" />
                    <asp:ListItem Text="Reminder" Value="reminder" />
                </asp:DropDownList>
            </div>
        </div>

        <asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand" OnItemDataBound="rptPosts_ItemDataBound">
            <ItemTemplate>
                <asp:HiddenField ID="hfPostId" runat="server" Value='<%# Eval("Id") %>' />

                <div class="post-item">
                    <%-- View Mode --%>
                    <asp:PlaceHolder ID="phView" runat="server" Visible='<%# !(bool)Eval("IsEditing") %>'>
                        <h4><%# Eval("Title") %> <small style="color:#888;">- <%# Eval("PostType") %></small></h4>
                        <p><%# Eval("Content") %></p>

                       <asp:PlaceHolder ID="phFileView" runat="server" Visible='<%# ((Container.DataItem as PostItem)?.FileUrls?.Count ?? 0) > 0 %>'>
    <div class="file-preview">
        <asp:Repeater ID="rptFiles" runat="server" 
                      DataSource='<%# (Container.DataItem as PostItem)?.FileUrls ?? new List<string>() %>'>
            <ItemTemplate>
                <div class="file-item">
                    <a href='<%# Container.DataItem %>' target="_blank">
                        <%# System.IO.Path.GetFileName(Container.DataItem.ToString()) %>
                    </a>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:PlaceHolder>

                        <asp:Button ID="btnEdit" runat="server" Text="Edit" CommandName="Edit" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-edit" />
                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CommandName="Delete" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-delete"
                                    OnClientClick="return confirm('Are you sure you want to delete this post?');" />
                    </asp:PlaceHolder>

                    <%-- Edit Mode --%>
                    <asp:PlaceHolder ID="phEdit" runat="server" Visible='<%# (bool)Eval("IsEditing") %>'>
                        <div class="form-group">
                            <label>Title</label>
                            <asp:TextBox ID="txtEditTitle" runat="server" Text='<%# Eval("Title") %>' CssClass="form-control" />
                        </div>

                        <div class="form-group">
                            <label>Content</label>
                            <asp:TextBox ID="txtEditContent" runat="server" Text='<%# Eval("Content") %>' CssClass="form-control" TextMode="MultiLine" Rows="4" />
                        </div>

                        <div class="form-group">
                            <label>Upload New File(s)</label>
                            <asp:FileUpload ID="fileUploadEdit" runat="server" AllowMultiple="true" />
                        </div>

                        <asp:Repeater ID="rptEditFiles" runat="server" 
              DataSource='<%# (Container.DataItem as PostItem)?.FileUrls ?? new List<string>() %>'
              OnItemDataBound="rptEditFiles_ItemDataBound">
    <ItemTemplate>
        <div class="file-item">
            <a href='<%# Container.DataItem %>' target="_blank">
                <%# System.IO.Path.GetFileName(Container.DataItem.ToString()) %>
            </a>
            <asp:HiddenField ID="hdnFileUrl" runat="server" Value='<%# Container.DataItem %>' />
            <asp:LinkButton ID="lnkRemove" runat="server" Text="❌" CssClass="remove-btn" CommandName="RemoveFile" />
        </div>
    </ItemTemplate>
</asp:Repeater>

                        <asp:Button ID="btnSave" runat="server" Text="Save" CommandName="Save" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-save" />
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CommandName="CancelEdit" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-cancel" />
                    </asp:PlaceHolder>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlNoPosts" runat="server" Visible="false" CssClass="no-posts">
            <p>No posts found for the selected class and type.</p>
        </asp:Panel>
    </div>
</asp:Content>
