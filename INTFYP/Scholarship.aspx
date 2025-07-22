<%@ Page Async="true" Title="Scholarship Application" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Scholarship.aspx.cs" Inherits="YourNamespace.Scholarship" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Scholarship Application
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Scholarship Application</h1>
            <p class="lead text-muted">Review your submitted results and apply for available scholarships.</p>
        </div>
    </section>

    <div class="container mb-5">
        <div class="row g-4">
            <!-- LEFT: Submitted Result -->
            <div class="col-md-6">
                <div class="card p-4 shadow-sm mb-3">
                    <h5 class="fw-bold mb-3">Your Submitted Result</h5>

                    <div class="mb-2">
                        <strong>Submitted On:</strong>
                        <asp:Label ID="lblSubmittedTime" runat="server" Text="-" />
                    </div>

                    <div class="mb-3">
                        <strong>Status:</strong>
                        <asp:Label ID="lblStatus" runat="server" Text="Pending" CssClass="badge bg-warning text-dark" />
                    </div>

                    <hr />
                    <h6 class="fw-bold mb-2">Subjects & Grades:</h6>

                    <asp:Repeater ID="rptSubjects" runat="server">
                        <ItemTemplate>
                            <div class="d-flex justify-content-between border-bottom py-2">
                                <span><%# Eval("Subject") %></span>
                                <span class="fw-bold text-primary"><%# Eval("Grade") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                    <asp:Button ID="btnApplyScholarship" runat="server" CssClass="btn btn-success w-100 py-2 fw-bold mb-2" Text="Submit Application" />

                    <asp:HyperLink ID="btnSubmitResult" runat="server" NavigateUrl="~/SubmitResult.aspx" CssClass="btn btn-outline-secondary w-100 py-2 fw-bold">
                        Submit Result
                    </asp:HyperLink>

            <!-- RIGHT: Application Form -->
            <div class="col-md-6">
                <div class="card p-4 shadow-sm">
                    <h5 class="fw-bold mb-3">Scholarship Application Form</h5>

                    <div class="mb-3">
                        <label for="txtScholarshipTitle" class="form-label">Scholarship Title</label>
                        <asp:TextBox ID="txtScholarshipTitle" runat="server" CssClass="form-control" placeholder="Enter scholarship name" />
                    </div>

                    <div class="mb-3">
                        <label for="txtWhy" class="form-label">Why Do You Deserve This?</label>
                        <asp:TextBox ID="txtWhy" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Explain your motivation" />
                    </div>

                    <div class="mb-3">
                        <label for="fuSupportingDoc" class="form-label">Supporting Document</label>
                        <asp:FileUpload ID="fuSupportingDoc" runat="server" CssClass="form-control" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
