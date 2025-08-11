<%@ Page Async="true" Title="Language Learning" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Learning.aspx.cs" Inherits="YourNamespace.Learning" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Language Learning
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Design System Variables */
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --reverse-gradient: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --glass-border: rgba(255, 255, 255, 0.2);
            --text-primary: #2c3e50;
            --text-secondary: #7f8c8d;
            --spacing-xs: 8px;
            --spacing-sm: 15px;
            --spacing-md: 20px;
            --spacing-lg: 25px;
            --spacing-xl: 30px;
        }

        /* Glass Card Effect */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
            border: 1px solid var(--glass-border);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* Page Header - match Library */
        .page-header {
            background: var(--primary-gradient);
            color: rgba(255, 255, 255, 0.9);
            border-radius: 20px;
            padding: var(--spacing-lg);
            margin-bottom: var(--spacing-lg);
            animation: fadeInUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* Glass Input - match Library */
        .glass-input {
            background: var(--glass-bg);
            backdrop-filter: blur(5px);
            border: 1px solid var(--glass-border);
            border-radius: 30px;
            padding: 10px 20px;
        }

        /* Top Lessons Box */
        .top-lessons-box {
            padding: var(--spacing-lg);
            overflow-x: auto; /* allow scroll if needed */
        }

        .top-lessons-header {
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            padding-bottom: var(--spacing-sm);
            margin-bottom: var(--spacing-sm);
        }

        /* Gradient Button */
        .btn-primary {
            background: var(--primary-gradient);
            color: white;
            border: none;
            border-radius: 25px;
            padding: 8px 20px;
            font-weight: 600;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .btn-primary:hover {
            background: var(--reverse-gradient);
        }

        /* Table Styling */
        .lesson-table {
            width: 100%;
            table-layout: fixed; /* prevent float issues */
        }
        .lesson-table th, 
        .lesson-table td {
            word-wrap: break-word;
            white-space: normal;
            padding: var(--spacing-xs) 4px;
        }
        .lesson-table th {
            color: var(--text-secondary);
            font-weight: 600;
            text-align: left;
        }
        .lesson-table td {
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }
        .lesson-table tr:last-child td {
            border-bottom: none;
        }

        /* Animations */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>

    <!-- Header -->
    <section class="page-header text-center mb-5">
        <div class="container">
            <h1 class="display-4 fw-bold mb-3">Language Learning</h1>
            <p class="lead fs-5">Master new languages with interactive lessons</p>
        </div>
    </section>

    <div class="container">
        <div class="row g-4">
            <!-- LEFT SIDEBAR - widened to col-lg-4 -->
            <div class="col-lg-4">
                <div class="glass-card top-lessons-box">
                    <div class="top-lessons-header">
                        <h5 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2"></i>Top Lessons by Attempts</h5>
                    </div>
                    <asp:Repeater ID="rptTopLessons" runat="server">
                        <HeaderTemplate>
                            <table class="lesson-table">
                                <thead>
                                    <tr>
                                        <th>Lesson</th>
                                        <th class="text-end">Attempts</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("LessonName") %></td>
                                <td class="text-end"><%# Eval("Attempts") %></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>

                <!-- REPORT BUTTON -->
                <div class="d-grid mt-4">
                    <a href="LearningReport.aspx" class="btn btn-primary py-2">
                        <i class="bi bi-flag-fill me-2"></i>Learning Report
                    </a>
                </div>
            </div>

            <!-- MAIN CONTENT - shrunk to col-lg-8 -->
            <div class="col-lg-8">
                <!-- SEARCH BAR - match Library -->
                <div class="glass-card p-3 mb-4 d-flex align-items-center gap-2">
                    <input type="text" class="glass-input flex-grow-1" placeholder="Search languages...">
                </div>

                <!-- LANGUAGE GRID -->
                <div class="row g-4">
                    <div class="col-md-6 col-lg-4">
                        <div class="glass-card h-100 p-4">
                            <h3 class="card-title">Korean</h3>
                            <p class="card-text text-muted mb-4">한국어</p>
                            <div class="d-flex justify-content-end">
                                <a href="Korean.aspx" class="btn btn-primary">
                                    <i class="bi bi-play-fill me-2"></i>Start
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
