<%@ Page Async="true" Title="Add Book" Language="C#" MasterPageFile="~/TeacherSite.master" Async="true" AutoEventWireup="true" CodeFile="AddBook.aspx.cs" Inherits="INTFYP.AddBook" %>

<asp:Content ID="AddBookContent" ContentPlaceHolderID="TeacherMainContent" runat="server">

    <style>
        .form-section {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            margin-bottom: 24px;
            border: 1px solid #e0e0e0;
        }

        .form-header {
            color: #212121;
            font-weight: 600;
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .form-label {
            font-weight: 500;
            color: #424242;
            font-size: 14px;
            margin-bottom: 6px;
        }

        .form-control {
            border-radius: 4px;
            border: 1px solid #e0e0e0;
            padding: 10px 12px;
            font-size: 14px;
        }

        .form-control:focus {
            border-color: #9e9e9e;
            box-shadow: none;
        }

        .btn {
            border-radius: 4px;
            font-weight: 500;
            font-size: 14px;
            padding: 10px 20px;
        }

        .btn-dark {
            background-color: #212121;
            border-color: #212121;
            color: #ffffff;
        }

        .btn-dark:hover {
            background-color: #000000;
            border-color: #000000;
        }
    </style>

    <div class="form-section">
        <h3 class="form-header">New Materials for Student</h3>

        <asp:Label ID="lblStatus" runat="server" Text="" ForeColor="Green" />

        <div class="row g-3">
            <div class="col-md-6">
                <label class="form-label">Title</label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="e.g., Advanced Physics" />
            </div>
            <div class="col-md-6">
                <label class="form-label">Author</label>
                <asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" placeholder="e.g., John Doe" />
            </div>
            <div class="col-md-6">
                <label class="form-label">Category</label>
                <asp:TextBox ID="txtCategory" runat="server" CssClass="form-control" placeholder="e.g., Science" />
            </div>
            <div class="col-md-6">
                <label class="form-label">PDF File</label>
                <asp:FileUpload ID="filePdf" runat="server" CssClass="form-control" />
            </div>
        </div>

        <div class="d-flex justify-content-end mt-4">
            <asp:Button ID="btnSubmit" runat="server" Text="Add Book" CssClass="btn btn-dark" OnClick="btnSubmit_Click" />
        </div>
    </div>
</asp:Content>
