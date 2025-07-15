<%@ Page Title="Library" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="Library.aspx.cs" Inherits="INTFYP.Library" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Library
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Bootstrap CSS (in case not already in Site.master) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

    <!-- Welcome Section -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Welcome to Library</h1>
            <p class="lead text-muted">All Materials You Need</p>
        </div>
    </section>

    <!-- Main Content Grid -->
    <div class="container mb-5">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 mb-4">
                <div class="mb-4">
                    <h5 class="fw-bold">CATEGORY</h5>
                    <div class="d-grid gap-2">
                        <button class="btn btn-outline-secondary">#Fiction</button>
                        <button class="btn btn-outline-secondary">#Horror</button>
                        <button class="btn btn-outline-secondary">#Adventure</button>
                        <button class="btn btn-outline-secondary">#Fantasy</button>
                        <button class="btn btn-outline-secondary">#Drama</button>
                        <button class="btn btn-outline-secondary">#English</button>
                        <button class="btn btn-outline-secondary">#Article</button>
                    </div>
                </div>
                <div class="d-grid gap-2">
                    <button class="btn btn-primary">Your Bookmark</button>
                    <button class="btn btn-dark" type="button" onclick="location.href='CitationGenerator.aspx';">Citation Generator</button>
                    <button class="btn btn-dark" type="button" onclick="location.href='AddBook.aspx';">Add Books</button>
                </div>
            </div>

            <!-- Main Library Section -->
            <div class="col-md-9">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="fw-bold mb-0">Recommend</h3>
                    <input type="text" class="form-control w-25" placeholder="Search..." />
                </div>

                <asp:Repeater ID="Repeater1" runat="server">
                    <HeaderTemplate>
                        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-4">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="col">
                            <div class="card h-100 shadow-sm">
                                <div class="card-body">
                                    <h5 class="card-title"><%# Eval("Title") %></h5>
                                    <p class="card-text"><%# Eval("Author") %></p>
                                    <span class="badge bg-secondary">#<%# Eval("Category") %></span>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</asp:Content>
