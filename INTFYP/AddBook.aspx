<%@ Page Title="Add Book" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeFile="AddBook.aspx.cs" Inherits="INTFYP.AddBook" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Add Book
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

  <section class="text-center bg-light py-4 border rounded mb-4">
    <div class="container">
      <h1 class="display-5 fw-bold">Add New Book</h1>
      <p class="lead text-muted">Enter book information to save it to Firebase</p>
    </div>
  </section>

  <div class="d-flex justify-content-center">
    <div class="bg-white p-4 border rounded shadow" style="max-width: 600px; width: 100%;">
      <h3 class="mb-4 text-center">Book Details</h3>

      <asp:Label ID="lblStatus" runat="server" Text="" ForeColor="Green" />

      <div class="mb-3">
        <asp:Label Text="Title:" runat="server" AssociatedControlID="txtTitle" CssClass="form-label" />
        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" />
      </div>

      <div class="mb-3">
        <asp:Label Text="Author:" runat="server" AssociatedControlID="txtAuthor" CssClass="form-label" />
        <asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" />
      </div>

      <div class="mb-3">
        <asp:Label Text="Category:" runat="server" AssociatedControlID="txtCategory" CssClass="form-label" />
        <asp:TextBox ID="txtCategory" runat="server" CssClass="form-control" />
      </div>

      <div class="mb-3">
        <asp:Label Text="PDF File:" runat="server" AssociatedControlID="filePdf" CssClass="form-label" />
        <asp:FileUpload ID="filePdf" runat="server" CssClass="form-control" />
      </div>

      <asp:Button ID="btnSubmit" runat="server" Text="Add Book" OnClick="btnSubmit_Click" CssClass="btn btn-dark w-100" />

      <p id="status" class="mt-3 text-success fw-semibold"></p>
    </div>
  </div>

</asp:Content>
