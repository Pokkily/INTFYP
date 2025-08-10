<%@ Page Async="true" Title="Learning Report" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="LearningReport.aspx.cs" Inherits="YourNamespace.LearningReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Learning Report
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4 shadow-sm">
        <div class="container">
            <h1 class="display-5 fw-bold text-primary">📚 Your Learning Report</h1>
            <p class="lead text-muted">Review all lessons and every attempt you’ve made, from first try to latest.</p>
        </div>
    </section>

    <!-- Sorting controls -->
    <div class="container mb-3">
        <div class="row">
            <div class="col-md-4 d-flex align-items-center gap-2">
                <label for="SortSelect" class="form-label mb-0 fw-bold">Sort By:</label>
                <asp:DropDownList ID="SortSelect" runat="server" AutoPostBack="true" OnSelectedIndexChanged="SortSelect_SelectedIndexChanged" CssClass="form-select form-select-sm w-auto">
                    <asp:ListItem Value="name_asc" Text="Name A-Z" />
                    <asp:ListItem Value="name_desc" Text="Name Z-A" />
                    <asp:ListItem Value="newest" Text="Newest" Selected="True" />
                    <asp:ListItem Value="older" Text="Older" />
                    <asp:ListItem Value="shortest_duration" Text="Shortest Duration" />
                    <asp:ListItem Value="longest_duration" Text="Longest Duration" />
                    <asp:ListItem Value="most_correct" Text="Most Correct" />
                    <asp:ListItem Value="most_incorrect" Text="Most Incorrect" />                  
                </asp:DropDownList>
            </div>
        </div>
    </div>

    <!-- Report Container -->
    <div class="container">
        <div class="row">
            <div class="col-12">
                <asp:Literal ID="ReportLiteral" runat="server"></asp:Literal>
            </div>
        </div>
    </div>

    <!-- Optional styling -->
    <style>
        .lesson-card {
            margin-bottom: 1.5rem;
        }
        .lesson-card h5 {
            margin-bottom: 0;
        }
    </style>
</asp:Content>
