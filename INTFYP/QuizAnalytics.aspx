<%@ Page Title="Quiz Analytics" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" Async="true" CodeBehind="QuizAnalytics.aspx.cs" Inherits="YourProjectNamespace.QuizAnalytics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .analytics-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
            font-family: 'Segoe UI', sans-serif;
        }

        .analytics-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            text-align: center;
        }

        .analytics-title {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .analytics-subtitle {
            font-size: 16px;
            opacity: 0.9;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            border-left: 5px solid #667eea;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.1), transparent);
            transition: left 0.8s ease;
        }

        .stat-card:hover::before {
            left: 100%;
        }

        .stat-card h3 {
            color: #2c3e50;
            font-size: 18px;
            margin-bottom: 15px;
            font-weight: 600;
            position: relative;
            z-index: 1;
        }

        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
            position: relative;
            z-index: 1;
            transition: transform 0.3s ease;
        }

        .stat-card:hover .stat-number {
            transform: scale(1.1);
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 14px;
            position: relative;
            z-index: 1;
        }

        .filters-section {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }

        .filters-row {
            display: flex;
            align-items: end;
            gap: 20px;
        }

        .filter-group {
            flex: 1;
            max-width: 300px;
        }

        .filter-label {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 5px;
            display: block;
        }

        .filter-control {
            width: 100%;
            padding: 12px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s ease;
        }

        .filter-control:focus {
            border-color: #667eea;
            outline: none;
        }

        .btn-filter {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-filter:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        .charts-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }

        .chart-container {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            position: relative;
        }

        .chart-title {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 20px;
            text-align: center;
        }

        .chart-canvas {
            max-height: 300px;
        }

        .attempts-section {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }

        .attempts-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .attempts-title {
            font-size: 22px;
            font-weight: bold;
            color: #2c3e50;
        }

        .export-btn {
            background: linear-gradient(135deg, #56ab2f, #a8e6cf);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .export-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(86, 171, 47, 0.3);
        }

        .attempts-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .attempts-table th {
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
            padding: 15px 12px;
            text-align: left;
            font-weight: 600;
            color: #2c3e50;
            border-bottom: 2px solid #dee2e6;
        }

        .attempts-table td {
            padding: 12px;
            border-bottom: 1px solid #dee2e6;
            vertical-align: top;
        }

        .attempts-table tr {
            transition: background-color 0.3s ease;
        }

        .attempts-table tr:hover {
            background: #f8f9fa;
        }

        .score-badge {
            padding: 8px 12px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 12px;
            text-align: center;
            min-width: 60px;
            display: inline-block;
            transition: transform 0.2s ease;
        }

        .score-badge:hover {
            transform: scale(1.05);
        }

        .grade-a { background: #d4edda; color: #155724; }
        .grade-b { background: #cce5ff; color: #0056b3; }
        .grade-c { background: #fff3cd; color: #856404; }
        .grade-d { background: #ffeaa7; color: #856404; }
        .grade-f { background: #f8d7da; color: #721c24; }

        .time-badge {
            background: #e3f2fd;
            color: #1565c0;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 500;
        }

        .details-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s ease;
        }

        .details-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(102, 126, 234, 0.3);
        }

        .details-panel {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-top: 15px;
            display: none;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                max-height: 0;
                padding: 0 20px;
            }
            to {
                opacity: 1;
                max-height: 1000px;
                padding: 20px;
            }
        }

        .question-analysis {
            margin-bottom: 15px;
            padding: 15px;
            background: white;
            border-radius: 8px;
            border-left: 4px solid #667eea;
            transition: transform 0.2s ease;
        }

        .question-analysis:hover {
            transform: translateX(5px);
        }

        .question-text {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .answer-comparison {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .user-answer, .correct-answer {
            padding: 10px;
            border-radius: 6px;
            font-size: 14px;
            transition: transform 0.2s ease;
        }

        .user-answer:hover, .correct-answer:hover {
            transform: scale(1.02);
        }

        .user-answer {
            background: #fff3cd;
            border: 1px solid #ffeeba;
        }

        .user-answer.correct {
            background: #d4edda;
            border: 1px solid #c3e6cb;
        }

        .correct-answer {
            background: #d1ecf1;
            border: 1px solid #bee5eb;
        }

        .no-data {
            text-align: center;
            padding: 40px;
            color: #6c757d;
            font-style: italic;
        }

        .loading-spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @media (max-width: 1024px) {
            .charts-section {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .analytics-container {
                padding: 15px;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .filters-row {
                flex-direction: column;
                gap: 15px;
            }

            .filter-group {
                max-width: none;
            }

            .attempts-table {
                font-size: 12px;
            }

            .attempts-table th,
            .attempts-table td {
                padding: 8px 6px;
            }

            .answer-comparison {
                grid-template-columns: 1fr;
            }

            .charts-section {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }
    </style>

    <div class="analytics-container">
        <!-- Header -->
        <div class="analytics-header">
            <div class="analytics-title">Quiz Analytics Dashboard</div>
            <div class="analytics-subtitle">
                Comprehensive analysis of quiz performance and user engagement
            </div>
        </div>

        <!-- Overall Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Attempts</h3>
                <div class="stat-number">
                    <asp:Label ID="lblTotalAttempts" runat="server" Text="0" />
                </div>
                <div class="stat-label">Across selected quiz(es)</div>
            </div>

            <div class="stat-card">
                <h3>Average Score</h3>
                <div class="stat-number">
                    <asp:Label ID="lblAverageScore" runat="server" Text="0" />%
                </div>
                <div class="stat-label">Overall performance</div>
            </div>

            <div class="stat-card">
                <h3>Average Time</h3>
                <div class="stat-number">
                    <asp:Label ID="lblAverageTime" runat="server" Text="0" />
                </div>
                <div class="stat-label">Minutes per quiz</div>
            </div>

            <div class="stat-card">
                <h3>Pass Rate</h3>
                <div class="stat-number">
                    <asp:Label ID="lblPassRate" runat="server" Text="0" />%
                </div>
                <div class="stat-label">Scores ≥ 60%</div>
            </div>
        </div>

        <!-- Filters -->
        <div class="filters-section">
            <div class="filters-row">
                <div class="filter-group">
                    <label class="filter-label">Select Quiz</label>
                    <asp:DropDownList ID="ddlQuizCode" runat="server" CssClass="filter-control">
                        <asp:ListItem Text="All Quizzes" Value="" />
                    </asp:DropDownList>
                </div>
                <div>
                    <asp:Button ID="btnApplyFilters" runat="server" Text="Load Analytics" CssClass="btn-filter" OnClick="btnApplyFilters_Click" />
                </div>
            </div>
        </div>

        <!-- Charts Section -->
        <div class="charts-section">
            <div class="chart-container">
                <div class="chart-title">Score Distribution</div>
                <canvas id="scoreChart" class="chart-canvas"></canvas>
            </div>
            <div class="chart-container">
                <div class="chart-title">Grade Distribution</div>
                <canvas id="gradeChart" class="chart-canvas"></canvas>
            </div>
        </div>

        <!-- Quiz Attempts -->
        <div class="attempts-section">
            <div class="attempts-header">
                <div class="attempts-title">Quiz Attempts</div>
                <asp:Button ID="btnExportCSV" runat="server" Text="Export to CSV" CssClass="export-btn" OnClick="btnExportCSV_Click" />
            </div>

            <asp:Panel ID="pnlAttempts" runat="server">
                <table class="attempts-table">
                    <thead>
                        <tr>
                            <th>Date/Time</th>
                            <th>Quiz</th>
                            <th>User</th>
                            <th>Score</th>
                            <th>Grade</th>
                            <th>Time</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptAttempts" runat="server" OnItemCommand="rptAttempts_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td><%# ((DateTime)Eval("CompletedAt")).ToString("MMM dd, yyyy HH:mm") %></td>
                                    <td>
                                        <strong><%# Eval("QuizTitle") %></strong><br />
                                        <small style="color: #6c757d;"><%# Eval("QuizCode") %></small>
                                    </td>
                                    <td>
                                        <%# Eval("UserName") %><br />
                                        <small style="color: #6c757d;"><%# Eval("UserIP") %></small>
                                    </td>
                                    <td>
                                        <div class="score-badge grade-<%# Eval("Grade").ToString().ToLower() %>">
                                            <%# Eval("CorrectAnswers") %>/<%# Eval("TotalQuestions") %><br />
                                            <%# Math.Round((double)Eval("ScorePercentage"), 1) %>%
                                        </div>
                                    </td>
                                    <td>
                                        <span class="score-badge grade-<%# Eval("Grade").ToString().ToLower() %>">
                                            <%# Eval("Grade") %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="time-badge">
                                            <%# FormatTime((int)Eval("TotalTimeSeconds")) %>
                                        </span>
                                    </td>
                                    <td>
                                        <asp:Button runat="server" 
                                                    Text="View Details" 
                                                    CssClass="details-btn" 
                                                    CommandName="ViewDetails" 
                                                    CommandArgument='<%# Eval("AttemptId") %>' />
                                    </td>
                                </tr>
                                <tr id="details_<%# Eval("AttemptId") %>" style="display: none;">
                                    <td colspan="7">
                                        <div class="details-panel">
                                            <h4 style="color: #2c3e50; margin-bottom: 15px;">Question-by-Question Analysis</h4>
                                            <asp:Repeater runat="server" DataSource='<%# Eval("QuestionAttempts") %>'>
                                                <ItemTemplate>
                                                    <div class="question-analysis">
                                                        <div class="question-text">
                                                            Question <%# (int)Eval("QuestionIndex") + 1 %>: <%# Eval("QuestionText") %>
                                                        </div>
                                                        <div class="answer-comparison">
                                                            <div class="user-answer <%# (bool)Eval("IsCorrect") ? "correct" : "" %>">
                                                                <strong>User Answer:</strong><br />
                                                                <%# GetSelectedOptions(Eval("Options"), Eval("UserSelectedIndexes")) %>
                                                                <div style="margin-top: 5px;">
                                                                    <small>Time: <%# FormatTime((int)Eval("TimeSpentSeconds")) %></small>
                                                                </div>
                                                            </div>
                                                            <div class="correct-answer">
                                                                <strong>Correct Answer:</strong><br />
                                                                <%# GetSelectedOptions(Eval("Options"), Eval("CorrectIndexes")) %>
                                                                <div style="margin-top: 5px;">
                                                                    <small>Result: <strong><%# (bool)Eval("IsCorrect") ? "✓ Correct" : "✗ Incorrect" %></strong></small>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </asp:Panel>

            <asp:Panel ID="pnlNoData" runat="server" CssClass="no-data" Visible="false">
                <h3>No quiz attempts found</h3>
                <p>Try selecting a different quiz or check back later when users have taken quizzes.</p>
            </asp:Panel>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <script type="text/javascript">
        function toggleDetails(attemptId) {
            var detailsRow = document.getElementById('details_' + attemptId);
            if (detailsRow.style.display === 'none') {
                detailsRow.style.display = 'table-row';
                detailsRow.querySelector('.details-panel').style.display = 'block';
            } else {
                detailsRow.style.display = 'none';
            }
        }

        // Initialize charts when page loads
        window.addEventListener('load', function () {
            initializeCharts();
        });

        function initializeCharts() {
            // Get chart data from hidden fields (populated by code-behind)
            var scoreData = JSON.parse(document.getElementById('<%= hdnScoreData.ClientID %>').value || '[]');
            var gradeData = JSON.parse(document.getElementById('<%= hdnGradeData.ClientID %>').value || '{}');

            // Score Distribution Chart
            var scoreCtx = document.getElementById('scoreChart').getContext('2d');
            var scoreChart = new Chart(scoreCtx, {
                type: 'bar',
                data: {
                    labels: ['0-20%', '21-40%', '41-60%', '61-80%', '81-100%'],
                    datasets: [{
                        label: 'Number of Attempts',
                        data: scoreData,
                        backgroundColor: [
                            'rgba(231, 76, 60, 0.7)',
                            'rgba(241, 196, 15, 0.7)',
                            'rgba(52, 152, 219, 0.7)',
                            'rgba(155, 89, 182, 0.7)',
                            'rgba(46, 204, 113, 0.7)'
                        ],
                        borderColor: [
                            'rgba(231, 76, 60, 1)',
                            'rgba(241, 196, 15, 1)',
                            'rgba(52, 152, 219, 1)',
                            'rgba(155, 89, 182, 1)',
                            'rgba(46, 204, 113, 1)'
                        ],
                        borderWidth: 2,
                        borderRadius: 5
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    animation: {
                        duration: 2000,
                        easing: 'easeOutBounce'
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            backgroundColor: 'rgba(0, 0, 0, 0.8)',
                            titleColor: 'white',
                            bodyColor: 'white',
                            borderColor: 'rgba(102, 126, 234, 1)',
                            borderWidth: 1
                        }
                    }
                }
            });

            // Grade Distribution Chart (Doughnut)
            var gradeCtx = document.getElementById('gradeChart').getContext('2d');
            var gradeChart = new Chart(gradeCtx, {
                type: 'doughnut',
                data: {
                    labels: ['A', 'B', 'C', 'D', 'F'],
                    datasets: [{
                        data: [
                            gradeData.A || 0,
                            gradeData.B || 0,
                            gradeData.C || 0,
                            gradeData.D || 0,
                            gradeData.F || 0
                        ],
                        backgroundColor: [
                            'rgba(46, 204, 113, 0.8)',
                            'rgba(52, 152, 219, 0.8)',
                            'rgba(241, 196, 15, 0.8)',
                            'rgba(230, 126, 34, 0.8)',
                            'rgba(231, 76, 60, 0.8)'
                        ],
                        borderColor: [
                            'rgba(46, 204, 113, 1)',
                            'rgba(52, 152, 219, 1)',
                            'rgba(241, 196, 15, 1)',
                            'rgba(230, 126, 34, 1)',
                            'rgba(231, 76, 60, 1)'
                        ],
                        borderWidth: 2,
                        hoverBorderWidth: 3,
                        hoverBackgroundColor: [
                            'rgba(46, 204, 113, 0.9)',
                            'rgba(52, 152, 219, 0.9)',
                            'rgba(241, 196, 15, 0.9)',
                            'rgba(230, 126, 34, 0.9)',
                            'rgba(231, 76, 60, 0.9)'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    animation: {
                        animateRotate: true,
                        animateScale: true,
                        duration: 2000,
                        easing: 'easeOutElastic'
                    },
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                padding: 20,
                                usePointStyle: true,
                                font: {
                                    size: 12,
                                    weight: 'bold'
                                }
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(0, 0, 0, 0.8)',
                            titleColor: 'white',
                            bodyColor: 'white',
                            borderColor: 'rgba(102, 126, 234, 1)',
                            borderWidth: 1,
                            callbacks: {
                                label: function (context) {
                                    var total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    var percentage = total > 0 ? ((context.parsed * 100) / total).toFixed(1) : 0;
                                    return context.label + ': ' + context.parsed + ' (' + percentage + '%)';
                                }
                            }
                        }
                    }
                }
            });
        }

        // Add loading animation for buttons
        document.addEventListener('DOMContentLoaded', function () {
            var buttons = document.querySelectorAll('.btn-filter, .export-btn');
            buttons.forEach(function (button) {
                button.addEventListener('click', function () {
                    var originalText = this.innerHTML;
                    this.innerHTML = '<span class="loading-spinner"></span> Loading...';
                    this.disabled = true;

                    // Re-enable after a delay (in case of no postback)
                    setTimeout(function () {
                        button.innerHTML = originalText;
                        button.disabled = false;
                    }, 3000);
                });
            });
        });
    </script>

    <!-- Hidden fields for chart data -->
    <asp:HiddenField ID="hdnScoreData" runat="server" />
    <asp:HiddenField ID="hdnGradeData" runat="server" />
</asp:Content>