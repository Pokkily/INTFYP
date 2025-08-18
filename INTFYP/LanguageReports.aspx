<%@ Page Async="true" Title="Language Reports" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="LanguageReports.aspx.cs" Inherits="INTFYP.LanguageReports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Language Reports
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .language-reports-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
        }

        .reports-container {
            max-width: 1400px;
            margin: 0 auto;
            position: relative;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            animation: slideInFromTop 1s ease-out;
        }

        .page-title {
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 15px;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }

        .card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            margin-bottom: 25px;
            overflow: hidden;
        }

        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            font-weight: 700;
            font-size: 18px;
        }

        .card-body {
            padding: 25px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            border: 1px solid rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-number {
            font-size: 32px;
            font-weight: 700;
            color: #667eea;
            display: block;
            margin-bottom: 8px;
        }

        .stat-label {
            font-size: 14px;
            color: #6c757d;
            font-weight: 500;
        }

        .chart-container {
            background: white;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .filters-section {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 25px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            align-items: end;
        }

        .filter-group label {
            display: block;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 5px;
            font-size: 14px;
        }

        .filter-control {
            background: white;
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 10px;
            padding: 10px 15px;
            font-size: 14px;
            width: 100%;
        }

        .nav-button {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 24px;
            border-radius: 25px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .nav-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            color: white;
            text-decoration: none;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .data-table th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 12px;
            text-align: left;
            font-weight: 600;
            font-size: 14px;
        }

        .data-table td {
            padding: 12px;
            border-bottom: 1px solid #e9ecef;
            font-size: 14px;
        }

        .data-table tr:hover {
            background-color: #f8f9fa;
        }

        .score-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .score-excellent { background-color: #d4edda; color: #155724; }
        .score-good { background-color: #d1ecf1; color: #0c5460; }
        .score-average { background-color: #fff3cd; color: #856404; }
        .score-poor { background-color: #f8d7da; color: #721c24; }

        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
            }
            
            .filters-section {
                grid-template-columns: 1fr;
            }
            
            .data-table {
                font-size: 12px;
            }
        }
    </style>

    <div class="language-reports-page">
        <div class="reports-container">
            <div class="page-header">
                <h2 class="page-title">📊 Language Analytics Dashboard</h2>
                <p style="color: rgba(255,255,255,0.8); font-size: 16px;">Monitor student performance across all languages</p>
            </div>

            <!-- Back Button -->
            <div class="mb-4">
                <asp:Button ID="btnBackToLanguages" runat="server" 
                    Text="⬅️ Back to Languages" 
                    CssClass="nav-button"
                    OnClick="btnBackToLanguages_Click" />
            </div>

            <!-- Filters Section -->
            <div class="filters-section">
                <div class="filter-group">
                    <label>Language</label>
                    <asp:DropDownList ID="ddlLanguageFilter" runat="server" 
                        CssClass="filter-control"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlLanguageFilter_SelectedIndexChanged">
                        <asp:ListItem Value="" Text="All Languages" />
                    </asp:DropDownList>
                </div>
                <div class="filter-group">
                    <label>Topic</label>
                    <asp:DropDownList ID="ddlTopicFilter" runat="server" 
                        CssClass="filter-control"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ApplyFilters">
                        <asp:ListItem Value="" Text="All Topics" />
                    </asp:DropDownList>
                </div>
                <div class="filter-group">
                    <label>Date Range</label>
                    <asp:DropDownList ID="ddlDateRange" runat="server" 
                        CssClass="filter-control"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ApplyFilters">
                        <asp:ListItem Value="7" Text="Last 7 days" />
                        <asp:ListItem Value="30" Text="Last 30 days" Selected="true" />
                        <asp:ListItem Value="90" Text="Last 90 days" />
                        <asp:ListItem Value="0" Text="All time" />
                    </asp:DropDownList>
                </div>
            </div>

            <!-- Overall Statistics -->
            <div class="card">
                <div class="card-header">
                    📊 Overall Performance Metrics
                </div>
                <div class="card-body">
                    <div class="stats-grid">
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblTotalStudents" runat="server" Text="0" />
                            </span>
                            <span class="stat-label">Active Students</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblTotalAttempts" runat="server" Text="0" />
                            </span>
                            <span class="stat-label">Total Quiz Attempts</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblAverageScore" runat="server" Text="0" />%
                            </span>
                            <span class="stat-label">Average Score</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblPassRate" runat="server" Text="0" />%
                            </span>
                            <span class="stat-label">Pass Rate (≥70%)</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblTotalLanguages" runat="server" Text="0" />
                            </span>
                            <span class="stat-label">Languages</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <asp:Label ID="lblAvgTimeSpent" runat="server" Text="0" />m
                            </span>
                            <span class="stat-label">Avg. Time per Quiz</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            📈 Score Distribution
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <canvas id="scoreDistributionChart" width="400" height="300"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            📅 Daily Activity
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <canvas id="dailyActivityChart" width="400" height="300"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Language Performance -->
            <div class="card">
                <div class="card-header">
                    🌍 Language Performance Summary
                </div>
                <div class="card-body">
                    <asp:Repeater ID="rptLanguageStats" runat="server">
                        <HeaderTemplate>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Language</th>
                                        <th>Students</th>
                                        <th>Total Attempts</th>
                                        <th>Avg Score</th>
                                        <th>Pass Rate</th>
                                        <th>Most Popular Topic</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><strong><%# Eval("LanguageName") %></strong></td>
                                <td><%# Eval("StudentCount") %></td>
                                <td><%# Eval("TotalAttempts") %></td>
                                <td>
                                    <span class="score-badge <%# GetScoreClass(Convert.ToDouble(Eval("AverageScore"))) %>">
                                        <%# Math.Round(Convert.ToDouble(Eval("AverageScore")), 1) %>%
                                    </span>
                                </td>
                                <td><%# Math.Round(Convert.ToDouble(Eval("PassRate")), 1) %>%</td>
                                <td><%# Eval("MostPopularTopic") %></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Recent Student Activity -->
            <div class="card">
                <div class="card-header">
                    🕒 Recent Student Activity
                </div>
                <div class="card-body">
                    <asp:Repeater ID="rptRecentActivity" runat="server">
                        <HeaderTemplate>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Student ID</th>
                                        <th>Language</th>
                                        <th>Topic</th>
                                        <th>Lesson</th>
                                        <th>Score</th>
                                        <th>Time Spent</th>
                                        <th>Completed</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("UserId").ToString().Length > 10 ? Eval("UserId").ToString().Substring(0, 10) + "..." : Eval("UserId") %></td>
                                <td><%# Eval("LanguageName") %></td>
                                <td><%# Eval("TopicName") %></td>
                                <td><%# Eval("LessonName") %></td>
                                <td>
                                    <span class="score-badge <%# GetScoreClass(Convert.ToInt32(Eval("Score"))) %>">
                                        <%# Eval("Score") %>%
                                    </span>
                                </td>
                                <td><%# Eval("TimeSpent") %>m</td>
                                <td><%# Eval("CompletedAt") %></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- No Data Message -->
            <asp:Panel ID="pnlNoData" runat="server" Visible="false">
                <div class="card">
                    <div class="card-body" style="text-align: center; padding: 60px;">
                        <div style="font-size: 48px; margin-bottom: 20px;">📊</div>
                        <h3>No Data Available</h3>
                        <p style="color: #6c757d;">No quiz attempts found for the selected criteria.</p>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <!-- Chart.js for graphs -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    
    <!-- Hidden fields for chart data -->
    <asp:HiddenField ID="hfScoreDistributionData" runat="server" />
    <asp:HiddenField ID="hfDailyActivityData" runat="server" />
    
    <script type="text/javascript">
        window.onload = function() {
            // Score Distribution Chart
            var scoreDataElement = document.getElementById('<%= hfScoreDistributionData.ClientID %>');
            if (scoreDataElement && scoreDataElement.value) {
                var scoreData = JSON.parse(scoreDataElement.value);
                createScoreDistributionChart(scoreData);
            }

            // Daily Activity Chart
            var activityDataElement = document.getElementById('<%= hfDailyActivityData.ClientID %>');
            if (activityDataElement && activityDataElement.value) {
                var activityData = JSON.parse(activityDataElement.value);
                createDailyActivityChart(activityData);
            }
        };

        function createScoreDistributionChart(data) {
            var ctx = document.getElementById('scoreDistributionChart');
            if (ctx) {
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['90-100%', '80-89%', '70-79%', '60-69%', 'Below 60%'],
                        datasets: [{
                            data: data,
                            backgroundColor: [
                                '#28a745', // Excellent
                                '#17a2b8', // Good
                                '#ffc107', // Average
                                '#fd7e14', // Below average
                                '#dc3545'  // Poor
                            ],
                            borderWidth: 2,
                            borderColor: '#fff'
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            title: {
                                display: true,
                                text: 'Quiz Score Distribution'
                            },
                            legend: {
                                position: 'bottom'
                            }
                        }
                    }
                });
            }
        }

        function createDailyActivityChart(data) {
            var ctx = document.getElementById('dailyActivityChart');
            if (ctx) {
                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: data.labels,
                        datasets: [{
                            label: 'Quiz Attempts',
                            data: data.attempts,
                            borderColor: '#667eea',
                            backgroundColor: 'rgba(102, 126, 234, 0.1)',
                            borderWidth: 3,
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            title: {
                                display: true,
                                text: 'Daily Quiz Activity'
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: {
                                    display: true,
                                    text: 'Number of Attempts'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Date'
                                }
                            }
                        }
                    }
                });
            }
        }
    </script>
</asp:Content>