<%@ Page Title="Library" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="Library.aspx.cs" Inherits="INTFYP.Library" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Library
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Welcome to Library</h1>
            <p class="lead text-muted">All Materials You Need</p>
        </div>
    </section>

    <!-- Main Content Grid -->
    <div class="container mb-5">
        <div class="row">
            <!-- Left Sidebar -->
            <div class="col-md-3 mb-4">
                <div class="mb-4">
                    <h5 class="fw-bold">Search by Category</h5>
                    <asp:TextBox ID="txtCategorySearch" runat="server" CssClass="form-control mb-2" placeholder="Type category name..." AutoPostBack="true" OnTextChanged="txtCategorySearch_TextChanged" />
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
                    <asp:TextBox ID="txtBookSearch" runat="server" CssClass="form-control w-25" placeholder="Search by title or author..." AutoPostBack="true" OnTextChanged="txtBookSearch_TextChanged" />
                </div>

                <asp:Repeater ID="Repeater1" runat="server">
                    <HeaderTemplate>
                        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-4">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="col">
                            <a href='<%# "PreviewBook.aspx?pdfUrl=" + HttpUtility.UrlEncode(Eval("PdfUrl").ToString()) %>' style="text-decoration: none; color: inherit;">
                                <div class="card h-100 shadow-sm">
                                    <div class="card-body">
                                        <h5 class="card-title"><%# Eval("Title") %></h5>
                                        <p class="card-text"><%# Eval("Author") %></p>
                                        <span class="badge bg-secondary">#<%# Eval("Category") %></span>
                                    </div>
                                </div>
                            </a>
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
