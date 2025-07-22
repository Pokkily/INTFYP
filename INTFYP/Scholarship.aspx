<%@ Page Async="true" Title="Scholarship" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Scholarship.aspx.cs" Inherits="YourProjectNamespace.Scholarship" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Scholarship
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Scholarship Application</h1>
            <p class="lead text-muted">Fill out your scholarship application and check your result</p>
        </div>
    </section>

    <!-- Two-Column Layout -->
    <div class="container mb-5">
        <div class="row">
            <!-- LEFT: Student Result -->
            <div class="col-md-4">
                <div class="card p-3 shadow-sm mb-3">
                    <h5 class="fw-bold mb-3">Student Result</h5>
                    <p><strong>Name:</strong> <asp:Label ID="lblName" runat="server" /></p>
                    <p><strong>Student ID:</strong> <asp:Label ID="lblStudentId" runat="server" /></p>
                    <p><strong>Course:</strong> <asp:Label ID="lblCourse" runat="server" /></p>
                    <p><strong>GPA:</strong> <asp:Label ID="lblGPA" runat="server" /></p>
                    <p><strong>Status:</strong> <asp:Label ID="lblStatus" runat="server" /></p>
                </div>

                <!-- Submit Buttons Below Student Result -->
                <div class="d-grid gap-2">
                    <asp:Button ID="btnApplyScholarship" runat="server" CssClass="btn btn-success" Text="Submit Scholarship Application" />
                    <asp:Button ID="btnGoToSubmitResult" runat="server" CssClass="btn btn-success mt-3" Text="Submit Result"
                    PostBackUrl="SubmitResult.aspx" />
                </div>
            </div>

            <!-- RIGHT: Scholarship Form -->
            <div class="col-md-8">
                <div class="card p-4 shadow-sm">
                    <h5 class="fw-bold mb-3">Apply for Scholarship</h5>

                    <asp:Label ID="lblMessage" runat="server" Visible="false" />

                    <div class="mb-3">
                        <label class="form-label">Scholarship Name</label>
                        <asp:TextBox ID="txtScholarshipName" runat="server" CssClass="form-control" placeholder="Enter scholarship name" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Sponsor</label>
                        <asp:TextBox ID="txtSponsor" runat="server" CssClass="form-control" placeholder="Enter sponsor name" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Describe the scholarship" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Deadline</label>
                        <asp:TextBox ID="txtDeadline" runat="server" CssClass="form-control" placeholder="e.g. 2025-12-31" />
                    </div>

                    <asp:Button ID="btnSubmitScholarship" runat="server" CssClass="btn btn-primary" Text="Submit Application" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
