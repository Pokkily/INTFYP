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
            background-color: #f9f9f9;
            color: #222;
        }

        .post-container {
            max-width: 900px;
            margin: auto;
            background: #ffffff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
        }

        .form-group label,
        .form-group input,
        .form-group textarea,
        .form-group select {
            color: #333;
            background-color: #f1f1f1;
            border: 1px solid #ccc;
        }

        .btn {
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 14px;
            border: none;
            margin-right: 6px;
            cursor: pointer;
        }

        .btn-edit {
            background-color: #555;
            color: white;
        }

        .btn-save {
            background-color: #007bff;
            color: white;
        }

        .btn-cancel {
            background-color: #6c757d;
            color: white;
        }

        .btn-delete {
            background-color: #dc3545;
            color: white;
        }

        .file-preview {
            background-color: #f1f1f1;
            padding: 10px;
            border-radius: 6px;
            margin-top: 10px;
        }

        .file-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 6px;
            color: #333;
        }

        .file-item a {
            text-decoration: none;
            color: #007bff;
        }

        .file-item a:hover {
            text-decoration: underline;
        }

        .remove-btn {
            cursor: pointer;
            color: #e60023;
            font-weight: bold;
        }

        .filter-row {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 24px;
        }
    </style>

    <div class="post-container">
        <div class="filter-row">
            <div>
                <label for="ddlClassFilter"><strong>Select Class:</strong></label>
                <asp:DropDownList ID="ddlClassFilter" runat="server" AutoPostBack="true"
                                  OnSelectedIndexChanged="ddlClassFilter_SelectedIndexChanged"
                                  CssClass="form-control" />
            </div>
            <div>
                <label for="ddlPostTypeFilter"><strong>Filter By Type:</strong></label>
                <asp:DropDownList ID="ddlPostTypeFilter" runat="server" AutoPostBack="true"
                                  OnSelectedIndexChanged="ddlPostTypeFilter_SelectedIndexChanged"
                                  CssClass="form-control">
                    <asp:ListItem Text="All" Value="all" />
                    <asp:ListItem Text="Announcement" Value="announcement" />
                    <asp:ListItem Text="Assignment" Value="assignment" />
                    <asp:ListItem Text="Reminder" Value="reminder" />
                </asp:DropDownList>
            </div>
        </div>

        <asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand">
            <ItemTemplate>
                <div class="post-item">
                    <asp:Panel ID="pnlView" runat="server">
                        <asp:PlaceHolder ID="phView" runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsEditing")) %>'>
                            <h4><%# Eval("Title") %> - <small><%# Eval("PostType") %></small></h4>
                            <p><%# Eval("Content") %></p>

                            <asp:PlaceHolder ID="phFile" runat="server" Visible='<%# Eval("FileUrl") != null && Eval("FileUrl").ToString() != "" %>'>
                                <div class="file-preview">
                                    <div class="file-item">
                                        <a href='<%# Eval("FileUrl") %>' target="_blank"><%# Eval("FileName") %></a>
                                    </div>
                                </div>
                            </asp:PlaceHolder>

                            <asp:Button ID="btnEdit" runat="server" CommandName="Edit" CommandArgument='<%# Eval("Id") %>'
                                        Text="Edit" CssClass="btn btn-edit" />
                            <asp:Button ID="btnDelete" runat="server" CommandName="Delete" CommandArgument='<%# Eval("Id") %>'
                                        Text="Delete" CssClass="btn btn-delete"
                                        OnClientClick="return confirm('Are you sure you want to delete this post?');" />
                        </asp:PlaceHolder>

                        <asp:PlaceHolder ID="phEdit" runat="server" Visible='<%# Convert.ToBoolean(Eval("IsEditing")) %>'>
                            <div class="form-group">
                                <label>Title</label>
                                <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control"
                                             Text='<%# Eval("Title") %>' />
                            </div>

                            <div class="form-group">
                                <label>Content</label>
                                <asp:TextBox ID="txtEditContent" runat="server" CssClass="form-control"
                                             TextMode="MultiLine" Rows="5" Text='<%# Eval("Content") %>' />
                            </div>

                            <div class="form-group">
                                <label>Upload New File</label>
                                <asp:FileUpload ID="fileUploadEdit" runat="server" />
                            </div>

                            <asp:PlaceHolder ID="phEditFiles" runat="server" Visible='<%# Eval("FileUrl") != null && Eval("FileUrl").ToString() != "" %>'>
                                <label>Existing File:</label>
                                <div class="file-preview">
                                    <div class="file-item">
                                        <a href='<%# Eval("FileUrl") %>' target="_blank"><%# Eval("FileName") %></a>
                                        <asp:LinkButton ID="lnkRemove" runat="server" Text="❌" CssClass="remove-btn"
                                                        CommandName="RemoveFile" CommandArgument='<%# Eval("Id") %>'
                                                        OnClientClick="return confirm('Remove this file?');" />
                                    </div>
                                </div>
                            </asp:PlaceHolder>

                            <asp:Button ID="btnSave" runat="server" CommandName="Save" CommandArgument='<%# Eval("Id") %>'
                                        Text="Save" CssClass="btn btn-save" />
                            <asp:Button ID="btnCancel" runat="server" CommandName="CancelEdit" CommandArgument='<%# Eval("Id") %>'
                                        Text="Cancel" CssClass="btn btn-cancel" />
                        </asp:PlaceHolder>
                    </asp:Panel>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlNoPosts" runat="server" Visible="false">
            <p>No posts found for the selected class and type.</p>
        </asp:Panel>
    </div>
</asp:Content>
