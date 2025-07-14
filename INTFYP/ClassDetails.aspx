<%@ Page Title="Classroom Details" 
    Language="C#" 
    MasterPageFile="~/Site.master" 
    AutoEventWireup="true" 
    CodeBehind="ClassDetails.aspx.cs" 
    Inherits="YourProjectNamespace.ClassDetails" 
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Classroom Details
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .classroom-header {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .post-card {
            border: 1px solid #ddd;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            background: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .post-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        .post-title {
            font-size: 18px;
            font-weight: 600;
            margin: 0;
        }
        .post-meta {
            font-size: 14px;
            color: #6c757d;
        }
        .post-type {
            display: inline-block;
            padding: 2px 8px;
            background: #e9ecef;
            border-radius: 4px;
            font-size: 12px;
        }
        .post-content {
            margin: 15px 0;
            white-space: pre-line;
        }
        .file-attachment {
            display: block;
            margin-top: 10px;
            color: #0d6efd;
        }
        .no-posts {
            text-align: center;
            padding: 40px;
            color: #6c757d;
            border: 1px dashed #dee2e6;
            border-radius: 8px;
        }
    </style>

    <div class="container" style="max-width: 800px; margin: 0 auto;">
        <div class="classroom-header">
            <h2 runat="server" id="classTitle">Classroom Posts</h2>
        </div>

        <asp:Panel ID="pnlNoPosts" runat="server" CssClass="no-posts">
            <i class="fas fa-inbox" style="font-size: 48px; margin-bottom: 15px;"></i>
            <p>No posts found in this classroom.</p>
        </asp:Panel>

        <asp:Repeater ID="rptPosts" runat="server">
            <ItemTemplate>
                <div class="post-card">
                    <div class="post-header">
                        <h3 class="post-title"><%# Eval("Title") %></h3>
                        <span class="post-type"><%# Eval("Type") %></span>
                    </div>
                    <div class="post-meta">
                        Posted by <%# Eval("CreatedByName") %> on <%# Eval("CreatedAtFormatted") %>
                    </div>
                    <div class="post-content">
                        <%# Eval("Content") %>
                    </div>
                    <asp:Repeater ID="rptFiles" runat="server" DataSource='<%# Eval("FileUrls") %>'>
                        <ItemTemplate>
                            <a href="<%# Container.DataItem %>" target="_blank" class="file-attachment">
                                <i class="fas fa-paperclip"></i> Download Attachment
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>