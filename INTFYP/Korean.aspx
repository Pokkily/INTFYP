<%@ Page Async="true" Title="Korean Learning" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Korean.aspx.cs" Inherits="YourNamespace.Korean" %>

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
    <div class="row justify-content-center">
        <!-- Center Column for Lessons -->
        <div class="col-md-8">
            <!-- Lesson 1 -->
            <div class="card mb-3 shadow-sm">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <div class="ms-2">
                        <h5 class="card-title mb-1">Korean Lesson 1</h5>
                        <asp:Literal ID="lesson1StatusLiteral" runat="server" />
                    </div>
                    <a href="Klesson1.aspx" class="btn btn-dark">Start</a>
                </div>
            </div>

            <!-- Lesson 2 -->
            <div class="card mb-3 shadow-sm">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <div class="ms-2">
                        <h5 class="card-title mb-1">Korean Lesson 2</h5>
                        <asp:Literal ID="lesson2StatusLiteral" runat="server" />
                    </div>
                    <a href="Klesson2.aspx" class="btn btn-dark">Start</a>
                </div>
            </div>

            <!-- Lesson 3 -->
            <div class="card mb-3 shadow-sm">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <div class="ms-2">
                        <h5 class="card-title mb-1">Korean Lesson 3</h5>
                        <asp:Literal ID="lesson3StatusLiteral" runat="server" />
                    </div>
                    <a href="Klesson3.aspx" class="btn btn-dark">Start</a>
                </div>
            </div>
        </div>
    </div>
</div>

</asp:Content>
