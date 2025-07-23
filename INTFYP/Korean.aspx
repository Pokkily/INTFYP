<%@ Page Title="Korean Learning" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Korean.aspx.cs" Inherits="YourNamespace.Korean" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Korean Learning
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Korean Language</h1>
            <p class="lead text-muted">Track your lesson progress and continue learning.</p>
        </div>
    </section>

    <div class="container">
        <div class="row">
            <!-- Left Sidebar -->
            <div class="col-md-3">
                <div class="card mb-3 shadow-sm ms-2">
                    <div class="card-header fw-bold">Language Joined</div>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item d-flex justify-content-between small">Mandarin Chinese <span>50%</span></li>
                        <li class="list-group-item d-flex justify-content-between small">French <span>28%</span></li>
                        <li class="list-group-item d-flex justify-content-between small">Japanese <span>87%</span></li>
                    </ul>
                </div>

                <!-- Question Button -->
                <div class="d-grid mt-3 ms-2">
                    <button class="btn btn-outline-dark" type="button">
                        <i class="bi bi-question-circle"></i> Question
                    </button>
                </div>
            </div>

            <!-- Right Content: Korean Lessons -->
            <div class="col-md-9">
                <div class="card mb-3 shadow-sm">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div class="ms-2">
                            <h5 class="card-title mb-1">Korean Lesson 1</h5>
                            <asp:Literal ID="lesson1StatusLiteral" runat="server" />
                        </div>
                        <a href="Klesson1.aspx" class="btn btn-dark me-2">Start</a>
                    </div>
                </div>

                <div class="card mb-3 shadow-sm">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div class="ms-2">
                            <h5 class="card-title mb-1">Korean Lesson 2</h5>
                            <p class="mb-0">Done <i class="bi bi-check-circle-fill text-success"></i></p>
                        </div>
                        <button class="btn btn-dark me-2">Review</button>
                    </div>
                </div>

                <div class="card mb-3 shadow-sm">
                    <div class="card-body d-flex justify-content-between align-items-center">
                        <div class="ms-2">
                            <h5 class="card-title mb-1">Korean Lesson 3</h5>
                            <p class="mb-0">Progress 20%</p>
                        </div>
                        <button class="btn btn-dark me-2">Continue</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
