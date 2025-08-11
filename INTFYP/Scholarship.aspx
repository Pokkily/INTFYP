<%@ Page Async="true" Title="Scholarship Application" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Scholarship.aspx.cs" Inherits="YourNamespace.Scholarship" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Scholarship Application
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --reverse-gradient: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --glass-border: rgba(255, 255, 255, 0.2);
            --text-primary: #2c3e50;
            --spacing-lg: 25px;
            --spacing-xl: 30px;
        }

        .btn-primary {
            background: var(--primary-gradient);
            color: white;
            padding: 12px 24px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            border: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .btn-primary:hover {
            background: var(--reverse-gradient);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(103, 126, 234, 0.4);
        }

        .page-header {
            background: var(--primary-gradient);
            color: rgba(255, 255, 255, 0.9);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 40px;
            animation: fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes cardEntrance {
            from { opacity: 0; transform: translateY(50px) rotate(2deg); }
            to { opacity: 1; transform: translateY(0) rotate(0deg); }
        }

        .scholarship-card {
            animation: cardEntrance 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards;
            opacity: 0;
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            margin-bottom: var(--spacing-xl);
        }

        .scholarship-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
        }

        .scholarship-card .card-header {
            background: transparent;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            border-radius: 20px 20px 0 0;
            padding: var(--spacing-lg);
            font-size: 1.25rem;
        }

        .scholarship-card .card-header h5 {
            word-wrap: break-word;
            overflow-wrap: break-word;
            max-width: 70%;
            line-height: 1.3;
            margin-bottom: 0;
        }

        .scholarship-card .card-body {
            padding: var(--spacing-lg);
            border-radius: 0 0 20px 20px;
        }

        .scholarship-card .card-body > div {
            margin-bottom: var(--spacing-lg);
            padding: 20px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 15px;
            border: 1px solid rgba(0, 0, 0, 0.05);
        }

        .scholarship-card .card-body strong {
            color: var(--text-primary);
            font-weight: 600;
        }
    </style>

    <section class="page-header text-center">
        <div class="container">
            <h1 class="display-4 fw-bold">Scholarship Application</h1>
            <p class="lead fs-4">Review your submitted results and apply for available scholarships</p>
        </div>
    </section>

    <div class="container mb-5">
        <div class="row g-4">
            <div class="col-12">
                <asp:Repeater ID="rptScholarships" runat="server">
                    <ItemTemplate>
                        <div class="card mb-3 shadow-sm scholarship-card" 
                             style='animation-delay: calc(<%# Container.ItemIndex %> * 0.1s)'>
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
