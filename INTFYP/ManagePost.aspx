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
            background-color: #1c1c1c;
            color: #eaeaea;
        }

        .post-container {
            max-width: 800px;
            margin: auto;
            background: #2a2a2a;
            padding: 24px;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.2);
        }

        .form-group label,
        .form-group input,
        .form-group textarea,
        .form-group select {
            color: #fff;
            background-color: #3a3a3a;
            border: 1px solid #555;
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
            background-color: #444;
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
            background-color: #383838;
            padding: 10px;
            border-radius: 6px;
            margin-top: 10px;
        }

        .file-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 6px;
            color: #ccc;
        }

        .file-item a {
            text-decoration: none;
            color: #ccc;
        }

        .file-item a:hover {
            text-decoration: underline;
        }

        .remove-btn {
            cursor: pointer;
            color: #ff5f57;
            font-weight: bold;
        }

        .dropdown-class {
            margin-bottom: 24px;
        }
    </style>

    <div class="post-container">
        <div class="dropdown-class">
            <label for="ddlClassFilter"><strong>Select a Class:</strong></label>
            <asp:DropDownList ID="ddlClassFilter" runat="server" AutoPostBack="true"
                              OnSelectedIndexChanged="ddlClassFilter_SelectedIndexChanged"
                              CssClass="form-control" />
        </div>

        <asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand">
            <ItemTemplate>
                <div class="post-item">
                    <asp:Panel ID="pnlView" runat="server">
                        <%-- We avoid Eval("IsEditing") logic here to bypass Func<> usage --%>
                        <asp:PlaceHolder ID="phView" runat="server" Visible='<%# Convert.ToBoolean(DataBinder.Eval(Container.DataItem, "IsEditing")) == false %>'>
                            <h4><%# DataBinder.Eval(Container.DataItem, "Title") %></h4>
                            <p><%# DataBinder.Eval(Container.DataItem, "Content") %></p>

                            <asp:PlaceHolder ID="phFiles" runat="server" Visible='<%# ((System.Collections.IList)DataBinder.Eval(Container.DataItem, "FileUrls")).Count > 0 %>'>
                                <div class="file-preview">
                                    <asp:Repeater ID="rptFiles" runat="server" DataSource='<%# DataBinder.Eval(Container.DataItem, "FileUrls") %>'>
                                        <ItemTemplate>
                                            <div class="file-item">
                                                <a href='<%# Container.DataItem.ToString() %>' target="_blank">View File</a>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </asp:PlaceHolder>

                            <asp:Button ID="btnEdit" runat="server" CommandName="Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "Id") %>'
                                        Text="Edit" CssClass="btn btn-edit" />
                            <asp:Button ID="btnDelete" runat="server" CommandName="Delete" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "Id") %>'
                                        Text="Delete" CssClass="btn btn-delete"
                                        OnClientClick="return confirm('Are you sure you want to delete this post?');" />
                        </asp:PlaceHolder>

                        <asp:PlaceHolder ID="phEdit" runat="server" Visible='<%# Convert.ToBoolean(DataBinder.Eval(Container.DataItem, "IsEditing")) %>'>
                            <div class="form-group">
                                <label>Title</label>
                                <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control"
                                             Text='<%# DataBinder.Eval(Container.DataItem, "Title") %>' />
                            </div>

                            <div class="form-group">
                                <label>Content</label>
                                <asp:TextBox ID="txtEditContent" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5"
                                             Text='<%# DataBinder.Eval(Container.DataItem, "Content") %>' />
                            </div>

                            <div class="form-group">
                                <label>Upload New File(s)</label>
                                <asp:FileUpload ID="fileUploadEdit" runat="server" AllowMultiple="true" />
                            </div>

                            <asp:PlaceHolder ID="phEditFiles" runat="server" Visible='<%# ((System.Collections.IList)DataBinder.Eval(Container.DataItem, "FileUrls")).Count > 0 %>'>
                                <label>Existing Files:</label>
                                <div class="file-preview">
                                    <asp:Repeater ID="rptEditFiles" runat="server" DataSource='<%# DataBinder.Eval(Container.DataItem, "FileUrls") %>'>
                                        <ItemTemplate>
                                            <div class="file-item">
                                                <a href='<%# Container.DataItem %>' target="_blank">
                                                    <%# Container.DataItem.ToString().Split('/')[Container.DataItem.ToString().Split('/').Length - 1] %>
                                                </a>
                                                <asp:HiddenField ID="hdnFileUrl" runat="server" Value='<%# Container.DataItem %>' />
                                                <asp:LinkButton ID="lnkRemove" runat="server" Text="❌" CssClass="remove-btn"
                                                                CommandName="RemoveFile" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "Id") + "|" + Container.DataItem %>'
                                                                OnClientClick="return confirm('Are you sure you want to remove this file?');" />
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </asp:PlaceHolder>

                            <asp:Button ID="btnSave" runat="server" CommandName="Save" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "Id") %>'
                                        Text="Save" CssClass="btn btn-save" />
                            <asp:Button ID="btnCancel" runat="server" CommandName="CancelEdit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "Id") %>'
                                        Text="Cancel" CssClass="btn btn-cancel" />
                        </asp:PlaceHolder>
                    </asp:Panel>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>
