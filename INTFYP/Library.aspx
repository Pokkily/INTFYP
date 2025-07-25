﻿    <%@ Page Async="true" Title="Library" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Library.aspx.cs" Inherits="INTFYP.Library" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
        Library
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <section class="text-center bg-light py-4 border rounded mb-4">
            <div class="container">
                <h1 class="display-5 fw-bold">Welcome to Library</h1>
                <p class="lead text-muted">All Materials You Need</p>
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
                        <button type="button" class="btn btn-primary" onclick="location.href='FavBooks.aspx';">Favorite Book</button>
                        <button type="button" class="btn btn-dark" onclick="location.href='CitationGenerator.aspx';">Citation Generator</button>
                        <button type="button" class="btn btn-dark" onclick="location.href='AddBook.aspx';">Add Books</button>
                    </div>
                </div>

                <div class="col-md-9">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="fw-bold mb-0">Books</h3>
                        <asp:TextBox ID="txtBookSearch" runat="server" CssClass="form-control w-25"
                            placeholder="Search by title/author..." AutoPostBack="true"
                            OnTextChanged="txtBookSearch_TextChanged" />
                    </div>

                    <asp:Repeater ID="Repeater1" runat="server" OnItemCommand="Repeater1_ItemCommand">
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
                                            Text='<%# String.Format("{0} ❤️", Eval("Recommendations")) %>'
                                            CommandName="Recommend"
                                            CommandArgument='<%# Eval("DocumentId") %>'
                                            CssClass='<%# (bool)Eval("IsRecommended") ? "btn btn-lavender btn-sm me-2" : "btn btn-outline-black btn-sm me-2" %>' />

                                        <asp:Button ID="btnFavorite" runat="server"
                                            Text="⭐"
                                            CommandName="Favorite"
                                            CommandArgument='<%# Eval("DocumentId") %>'
                                            CssClass='<%# (bool)Eval("IsFavorited") ? "btn btn-young-sage btn-sm" : "btn btn-outline-black btn-sm" %>' />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
        <style>
            .btn-outline-black {
                background-color: white;
                color: black;
                border: 1px solid black;
            }

            .btn-outline-black:hover {
                background-color: black;
                color: white;
            }

            .btn-lavender {
                background-color: #d8b5f0; 
                color: black;
                border: 1px solid black;
            }

            .btn-young-sage {
                background-color: #9caf88; 
                color: black;
                border: 1px solid black;
            }
        </style>
    </asp:Content>