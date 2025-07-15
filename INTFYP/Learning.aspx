<%@ Page Title="Learning" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Learning.aspx.cs" Inherits="INTFYP.Learning" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Learning
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Learning Center</h1>
            <p class="lead text-muted">Explore educational content, materials, and videos</p>
        </div>
    </section>

    <div class="container">
        <div class="row">
            <!-- Left Panel -->
            <div class="col-md-3">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">Learning Menu</h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled">
                            <li><a href="#" class="text-decoration-none">My Courses</a></li>
                            <li><a href="#" class="text-decoration-none">Progress</a></li>
                            <li><a href="#" class="text-decoration-none">Resources</a></li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Right Panel -->
            <div class="col-md-9">
                <div class="card shadow-sm">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0">Learning Content</h5>
                    </div>
                    <div class="card-body">
                        <p class="mb-3">This section will display your educational videos, assignments, and learning tools.</p>
                        <p class="text-muted">Features will be added soon.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
