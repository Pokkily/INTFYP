<%@ Page Title="Book Review" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="PreviewBook.aspx.cs" Inherits="INTFYP.PreviewBook" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Book Review
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Book Review</h1>
            <p class="lead text-muted">Rreview of Uploaded Material</p>
        </div>
    </section>

    <!-- PDF Preview -->
    <div class="container mb-5 text-center">
        <h4 class="mb-4">Preview Book</h4>
        <asp:Literal ID="litPdfPreview" runat="server" Mode="PassThrough" />
    </div>

</asp:Content>
