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
        <div class="row">
            <!-- LEFT: Student Submitted Result -->
<div class="col-md-6 mb-4">
    <div class="card p-4 shadow-sm">
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

    <!-- Submit Result Button -->
    <div class="text-end mt-3">
        <asp:HyperLink ID="HyperLink1" runat="server" CssClass="btn btn-outline-primary" NavigateUrl="SubmitResult.aspx">
            Submit Result
        </asp:HyperLink>
    </div>
</div>


                <!-- Submit Result Button -->
                <div class="text-end mt-3">
                    <asp:HyperLink ID="btnSubmitResult" runat="server" CssClass="btn btn-outline-primary" NavigateUrl="SubmitResult.aspx">
                        Submit Result
                    </asp:HyperLink>
                </div>
            </div>

            <!-- RIGHT: Scholarship Application Form -->
            <div class="col-md-6">
                <div class="card p-4 shadow-sm">
                    <h5 class="fw-bold mb-3">Scholarship Application Form</h5>

                    <div class="mb-3">
                        <label for="txtScholarshipTitle" class="form-label">Scholarship Title</label>
                        <asp:TextBox ID="txtScholarshipTitle" runat="server" CssClass="form-control" placeholder="Enter scholarship name"></asp:TextBox>
                    </div>

                    <div class="mb-3">
                        <label for="txtWhy" class="form-label">Why Do You Deserve This?</label>
                        <asp:TextBox ID="txtWhy" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Explain your motivation and achievements"></asp:TextBox>
                    </div>

                    <div class="mb-3">
                        <label for="fuSupportingDoc" class="form-label">Supporting Document (Optional)</label>
                        <asp:FileUpload ID="fuSupportingDoc" runat="server" CssClass="form-control" />
                    </div>

                    <asp:Button ID="btnApplyScholarship" runat="server" CssClass="btn btn-success w-100" Text="Apply Now" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
