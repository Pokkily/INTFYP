<%@ Page Title="Language Learning" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Learning.aspx.cs" Inherits="YourNamespace.Learning" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Learning
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Language Learning</h1>
            <p class="lead text-muted">Explore and learn new languages with interactive lessons.</p>
        </div>
    </section>

    <div class="container">
        <div class="row">
            <!-- LEFT SIDEBAR -->
            <div class="col-md-3">          

                <div class="d-grid">
                    <a href="LearningReport.aspx" class="btn btn-danger">
                        <i class="bi bi-flag-fill"></i> Report
                    </a>
                </div>
            </div>

            <!-- MAIN CONTENT -->
            <div class="col-md-9">
                <!-- SEARCH BAR -->
                <div class="input-group mb-4">
                    <input type="text" class="form-control" placeholder="Search">
                </div>

                <!-- LANGUAGE GRID -->
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title ms-2">Korean</h5>
                                <p class="card-text ms-2">한국인</p>
                                <div class="d-flex justify-content-end">
                                    <a href="Korean.aspx" class="btn btn-outline-primary me-2">Start</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>         
            </div>
        </div>
      </div>
</asp:Content>
