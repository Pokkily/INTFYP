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
                <div class="card mb-3 shadow-sm">
                    <div class="card-header bg-white fw-bold">Language Joined</div>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item d-flex justify-content-between">Mandarin Chinese <span>50%</span></li>
                        <li class="list-group-item d-flex justify-content-between">French <span>20%</span></li>
                        <li class="list-group-item d-flex justify-content-between">Japanese <span>87%</span></li>
                    </ul>
                </div>

                <div class="card shadow-sm mb-3">
                    <div class="card-header bg-white fw-bold">Other Language</div>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item">Spanish</li>
                        <li class="list-group-item">Thai</li>
                        <li class="list-group-item">Russian</li>
                    </ul>
                </div>

                <!-- Question Button -->
                <div class="d-grid">
                    <button class="btn btn-secondary mb-3"><i class="bi bi-question-circle"></i> Question</button>
                </div>
                <div class="d-grid">
                    <button class="btn btn-danger"><i class="bi bi-flag-fill"></i> Report</button>
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
                                    <a href="Korean.aspx" class="btn btn-outline-primary me-2">참여하다</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title ms-2">French</h5>
                                <p class="card-text ms-2">Français</p>
                                <div class="d-flex justify-content-end">
                                    <button class="btn btn-outline-primary me-2">Insert</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title ms-2">Japanese</h5>
                                <p class="card-text ms-2">日本語</p>
                                <div class="d-flex justify-content-end">
                                    <button class="btn btn-outline-primary me-2">参加</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Additional Cards -->
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title ms-2">Spanish</h5>
                                <p class="card-text ms-2">español</p>
                                <div class="d-flex justify-content-end">
                                    <button class="btn btn-outline-primary me-2">preguntar</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title ms-2">Thai</h5>
                                <p class="card-text ms-2">แบบไทย</p>
                                <div class="d-flex justify-content-end">
                                    <button class="btn btn-outline-primary me-2">ถาม</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title ms-2">Russian</h5>
                                <p class="card-text ms-2">русский</p>
                                <div class="d-flex justify-content-end">
                                    <button class="btn btn-outline-primary me-2">просить</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>         
            </div>
        </div>
    </div>
</asp:Content>
