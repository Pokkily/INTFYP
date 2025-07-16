<%@ Page Title="Main Page" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="MainPage.aspx.cs" Inherits="YourProjectNamespace.MainPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Main Page
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding: 30px;">
        <h2>Welcome, <%= Session["username"] != null ? Session["username"].ToString() : "Guest" %>!</h2>
        <p>This is your dashboard. Use the menu above to navigate your study tools.</p>

        <div style="margin-top: 20px;">
            <ul>
                <li><a href="Class.aspx">Go to Classes</a></li>
                <li><a href="StudyHub.aspx">Open Study Hub</a></li>
                <li><a href="Library.aspx">Visit Library</a></li>
                <li><a href="Quiz.aspx">Start Quiz</a></li>
                <li><a href="FeedBack.aspx">Give Feedback</a></li>
            </ul>
        </div>
    </div>
</asp:Content>
