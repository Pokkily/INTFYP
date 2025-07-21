<%@ Page Async="true" Title="FavBooks" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="FavBooks.aspx.cs" Inherits="INTFYP.FavBooks" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Favorite Books
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Your Favorite Books</h1>
            <p class="lead text-muted">All Books You've Loved</p>
        </div>
    </section>

    <div class="container mb-5">
        <div class="row">
            <div class="col-md-3 mb-4">
                <h5 class="fw-bold">Search by Category</h5>
                <asp:TextBox ID="txtCategorySearch" runat="server" CssClass="form-control mb-3"
                    placeholder="Type category..." AutoPostBack="true"
                    OnTextChanged="txtCategorySearch_TextChanged" />

                <div class="d-grid gap-2">
                    <button type="button" class="btn btn-primary" onclick="location.href='Library.aspx';">Back to Library</button>
                    <button type="button" class="btn btn-dark" onclick="location.href='CitationGenerator.aspx';">Citation Generator</button>
                    <button type="button" class="btn btn-dark" onclick="location.href='AddBook.aspx';">Add Books</button>
                </div>
            </div>

            <div class="col-md-9">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="fw-bold mb-0">Your Favorites</h3>
                    <asp:TextBox ID="txtBookSearch" runat="server" CssClass="form-control w-25"
                        placeholder="Search by title/author..." AutoPostBack="true"
                        OnTextChanged="txtBookSearch_TextChanged" />
                </div>

                <asp:Repeater ID="Repeater1" runat="server">
                    <HeaderTemplate>
                        <div class="row row-cols-1 row-cols-md-3 g-4">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="col">
                            <div class="card h-100 shadow-sm">
                                <div class="card-body">
                                    <h5 class="card-title"><%# Eval("Title") %></h5>
                                    <p class="card-text"><%# Eval("Author") %></p>
                                    <span class="badge bg-secondary">#<%# Eval("Category") %></span>

                                    <div class="mt-2 d-flex align-items-center">
                                        <asp:Button ID="btnRecommend" runat="server"
                                            Text='<%# String.Format("{0} 👍", Eval("Recommendations")) %>'
                                            Enabled="false"
                                            CssClass='<%# (bool)Eval("IsRecommended") ? "btn btn-success btn-sm me-2" : "btn btn-outline-danger btn-sm me-2" %>' />

                                        <asp:Button ID="btnFavorite" runat="server"
                                            Text="⭐"
                                            Enabled="false"
                                            CssClass='<%# (bool)Eval("IsFavorited") ? "btn btn-dark btn-sm" : "btn btn-outline-secondary btn-sm" %>' />
                                    </div>
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
