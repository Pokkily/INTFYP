<%@ Page Title="My Classes"
    Language="C#"
    MasterPageFile="~/Site.master"
    AutoEventWireup="true"
    CodeBehind="Class.aspx.cs"
    Inherits="YourProjectNamespace.Class"
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Classes
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .class-card {
            display: flex;
            align-items: center;
            border: 1px solid #ddd;
            padding: 16px;
            margin-bottom: 12px;
            border-radius: 8px;
            background-color: white;
            gap: 16px;
        }

        .placeholder-img {
            width: 80px;
            height: 80px;
            background-color: #f0f0f0;
            border-radius: 8px;
        }

        .class-details {
            flex-grow: 1;
        }

        .class-details h5 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        .class-details small {
            color: #777;
        }

        .btn {
            padding: 6px 14px;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }

        .btn-join {
            background-color: #007bff;
            color: white;
        }

        .btn-enter {
            background-color: #28a745;
            color: white;
        }
    </style>

    <div style="padding: 24px; max-width: 800px; margin: auto;">
        <h2>📚 Your Classes</h2>
        <asp:Repeater ID="rptClasses" runat="server" OnItemCommand="rptClasses_ItemCommand">
            <ItemTemplate>
                <div class="class-card">
                    <div class="placeholder-img"></div>
                    <div class="class-details">
                        <h5><%# Eval("name") %></h5>
                        <small>Invitation From <%# Eval("createdByName") %></small>
                    </div>
                    <asp:Button ID="btnAction" runat="server"
                        Text='<%# Eval("status").ToString() == "pending" ? "Join" : "Enter" %>'
                        CommandName='<%# Eval("status").ToString() == "pending" ? "Join" : "Enter" %>'
                        CommandArgument='<%# Eval("classId") %>'
                        CssClass='<%# Eval("status").ToString() == "pending" ? "btn btn-join" : "btn btn-enter" %>' />
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>
