<%@ Page Async="true" Title="Feedback" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Feedback.aspx.cs" Inherits="YourProjectNamespace.Feedback" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Feedback
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Student Feedback</h1>
            <p class="lead text-muted">Submit your feedback with description, image, or video</p>
        </div>
    </section>

    <!-- Two-Column Layout -->
    <div class="container mb-5">
        <div class="row">
            <!-- LEFT: Student Info -->
            <div class="col-md-4">
                <div class="card p-3 shadow-sm">
                    <h5 class="fw-bold mb-3">Student Information</h5>
                    <p><strong>Name:</strong> <asp:Label ID="lblName" runat="server" /></p>
                    <p><strong>Username:</strong> <asp:Label ID="lblUsername" runat="server" /></p>
                    <p><strong>Email:</strong> <asp:Label ID="lblEmail" runat="server" /></p>
                    <p><strong>Phone:</strong> <asp:Label ID="lblPhone" runat="server" /></p>
                    <p><strong>Gender:</strong> <asp:Label ID="lblGender" runat="server" /></p>
                    <p><strong>Birthdate:</strong> <asp:Label ID="lblBirthdate" runat="server" /></p>
                    <p><strong>Position:</strong> <asp:Label ID="lblPosition" runat="server" /></p>
                    <p><strong>Address:</strong> <asp:Label ID="lblAddress" runat="server" /></p>
                </div>
            </div>

            <!-- RIGHT: Feedback Form -->
            <div class="col-md-8">
                <div class="card p-4 shadow-sm">
                    <h5 class="fw-bold mb-3">Submit Feedback</h5>

                    <asp:Label ID="lblMessage" runat="server" Visible="false" />

                    <div class="mb-3">
                        <label class="form-label">Username</label>
                        <asp:TextBox ID="txtFeedbackUsername" runat="server" CssClass="form-control" ReadOnly="true" />
                    </div>

                    <div class="mb-3">
                        <label for="txtDescription" class="form-label">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Enter your feedback here" />
                    </div>

                    <div class="mb-3">
                        <label for="fileUpload" class="form-label">Upload Image/Video (optional)</label>
                        <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" />
                    </div>

                    <asp:Button ID="btnSubmit" runat="server" CssClass="btn btn-primary" Text="Submit Feedback" OnClick="btnSubmit_Click" />
                </div>

                <!-- Feedback Posts -->
                <div class="mt-5" id="feedbackPosts" runat="server"></div>
            </div>
        </div>
    </div>
</asp:Content>
