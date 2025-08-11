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

    <!-- Left: Student Result | Right: Scholarships -->
    <div class="container mb-5">
        <div class="row g-4">

            <!-- LEFT SIDEBAR -->
            <div class="col-md-3">
                <div class="card mb-3 shadow-sm">
                    <div class="card-header bg-white fw-bold">Your Submitted Result</div>
                    <div class="card-body">
                        <div class="mb-2">
                            <strong>Submitted On:</strong><br />
                            <asp:Label ID="lblSubmittedTime" runat="server" Text="-" />
                        </div>
                        <div class="mb-3">
                            <strong>Status:</strong><br />
                            <asp:Label ID="lblStatus" runat="server" Text="Pending" CssClass="badge bg-warning text-dark" />
                        </div>

                        <h6 class="fw-bold">Subjects & Grades:</h6>
                        <asp:Repeater ID="rptSubjects" runat="server">
                            <ItemTemplate>
                                <div class="d-flex justify-content-between border-bottom py-1">
                                    <span><%# Eval("Subject") %></span>
                                    <span class="fw-bold text-primary"><%# Eval("Grade") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <div class="card-footer bg-white">
                        <asp:HyperLink ID="btnSubmitResult" runat="server" NavigateUrl="~/SubmitResult.aspx" CssClass="btn btn-outline-secondary w-100 py-2 fw-bold">
                            Submit Result
                        </asp:HyperLink>
                    </div>
                </div>
            </div>

<!-- RIGHT SIDE: Scholarships -->
<div class="col-md-9">
    <asp:Repeater ID="rptScholarships" runat="server">
        <ItemTemplate>
            <!-- Each Scholarship as Collapsible Card -->
            <div class="card mb-3 shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><%# Eval("Title") %></h5>
                    <button class="btn btn-sm btn-outline-primary" type="button" 
                            data-bs-toggle="collapse" 
                            data-bs-target="#scholarship<%# Container.ItemIndex %>" 
                            aria-expanded="false" 
                            aria-controls="scholarship<%# Container.ItemIndex %>">
                        View Details
                    </button>
                </div>
                <div class="collapse" id="scholarship<%# Container.ItemIndex %>">
                    <div class="card-body">
                        <div class="mb-3">
                            <strong>Requirements:</strong><br />
                            <asp:Literal ID="litRequirement" runat="server" Text='<%# Eval("Requirement").ToString().Replace("\n", "<br/>") %>' />
                        </div>

                        <div class="mb-3">
                            <strong>Terms:</strong><br />
                            <asp:Literal ID="litTerms" runat="server" Text='<%# Eval("Terms").ToString().Replace("\n", "<br/>") %>' />
                        </div>

                        <div class="mb-4">
                            <strong>Courses:</strong><br />
                            <asp:Literal ID="litCourses" runat="server" Text='<%# Eval("Courses").ToString().Replace("\n", "<br/>") %>' />
                        </div>

                        <!-- Link Button at Bottom -->
                        <div class="d-grid">
                            <a href='<%# Eval("Link") %>' target="_blank" class="btn btn-primary">
                                Apply for This Scholarship
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

        </div>
    </div>
</asp:Content>
