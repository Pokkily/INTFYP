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

    <!-- Report Container -->
    <div class="container">
        <div class="row">
            <div class="col-12">
                <!-- Literal will render lesson cards -->
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
