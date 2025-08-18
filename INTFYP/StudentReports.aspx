<%@ Page Async="true" Title="Student Reports" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="StudentReports.aspx.cs" Inherits="INTFYP.StudentReports" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Student Reports
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .reports-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
        }

        .reports-container {
            max-width: 1200px;
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
            margin-bottom: 20px;
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

        .language-selector {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 15px;
            padding: 12px 20px;
            font-size: 14px;
            margin-bottom: 20px;
            width: 100%;
        }

        .progress-bar {
            background: #e9ecef;
            border-radius: 10px;
            height: 20px;
            overflow: hidden;
            margin-top: 5px;
        }

        .progress-fill {
            background: linear-gradient(90deg, #667eea, #764ba2);
            height: 100%;
            border-radius: 10px;
            transition: width 0.5s ease;
        }

        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
            }
        }
    </style>

    <div class="reports-page">
        <div class="reports-container">
            <div class="page-header">
                <h2 class="page-title">📊 Your Learning Progress</h2>
                <p style="color: rgba(255,255,255,0.8); font-size: 16px;">Track your language learning journey</p>
            </div>

            <!-- Back Button -->
            <div class="mb-4">
                <asp:Button ID="btnBackToLanguages" runat="server" 
                    Text="⬅️ Back to Languages" 
                    CssClass="nav-button"
                    OnClick="btnBackToLanguages_Click" />
            </div>

            <!-- Language Selection -->
            <div class="card">
                <div class="card-header">
                    🌍 Select Language
                </div>
                <div class="card-body">
                    <asp:DropDownList ID="ddlLanguages" runat="server" 
                        CssClass="language-selector"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="ddlLanguages_SelectedIndexChanged">
                        <asp:ListItem Value="" Text="-- Select a Language --" />
                    </asp:DropDownList>
                </div>
            </div>

            <!-- Overall Statistics -->
            <asp:Panel ID="pnlStats" runat="server" Visible="false">
                <div class="card">
                    <div class="card-header">
                        📈 Overall Statistics
                    </div>
                    <div class="card-body">
                        <div class="stats-grid">
                            <div class="stat-card">
                                <span class="stat-number">
                                    <asp:Label ID="lblTotalAttempts" runat="server" Text="0" />
                                </span>
                                <span class="stat-label">Total Attempts</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-number">
                                    <asp:Label ID="lblCompletedLessons" runat="server" Text="0" />
                                </span>
                                <span class="stat-label">Completed Lessons</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-number">
                                    <asp:Label ID="lblAverageScore" runat="server" Text="0" />%
                                </span>
                                <span class="stat-label">Average Score</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-number">
                                    <asp:Label ID="lblCurrentStreak" runat="server" Text="0" />
                                </span>
                                <span class="stat-label">Day Streak</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-number">
                                    <asp:Label ID="lblTotalTime" runat="server" Text="0" />h
                                </span>
                                <span class="stat-label">Total Time</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Progress Chart -->
                <div class="card">
                    <div class="card-header">
                        📊 Score Progress Over Time
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="progressChart" width="400" height="200"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Topic Progress -->
                <div class="card">
                    <div class="card-header">
                        📚 Topic Progress
                    </div>
                    <div class="card-body">
                        <asp:Repeater ID="rptTopicProgress" runat="server">
                            <ItemTemplate>
                                <div style="margin-bottom: 20px;">
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
                                        <strong><%# Eval("TopicName") %></strong>
                                        <span><%# Eval("Progress") %>% Complete</span>
                                    </div>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: <%# Eval("Progress") %>%;"></div>
                                    </div>
                                    <small style="color: #6c757d;">
                                        <%# Eval("CompletedLessons") %> of <%# Eval("TotalLessons") %> lessons completed
                                    </small>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <!-- Recent Activity -->
                <div class="card">
                    <div class="card-header">
                        🕒 Recent Activity
                    </div>
                    <div class="card-body">
                        <asp:Repeater ID="rptRecentActivity" runat="server">
                            <ItemTemplate>
                                <div style="border-bottom: 1px solid #e9ecef; padding: 15px 0;">
                                    <div style="display: flex; justify-content: between; align-items: center;">
                                        <div>
                                            <strong><%# Eval("LessonName") %></strong> - <%# Eval("TopicName") %>
                                            <br />
                                            <small style="color: #6c757d;"><%# Eval("CompletedAt") %></small>
                                        </div>
                                        <div style="text-align: right;">
                                            <span style="font-size: 18px; font-weight: 700; color: <%# Convert.ToInt32(Eval("Score")) >= 70 ? "#28a745" : "#dc3545" %>;">
                                                <%# Eval("Score") %>%
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </asp:Panel>

            <!-- No Data Message -->
            <asp:Panel ID="pnlNoData" runat="server" Visible="false">
                <div class="card">
                    <div class="card-body" style="text-align: center; padding: 60px;">
                        <div style="font-size: 48px; margin-bottom: 20px;">📚</div>
                        <h3>No Progress Data Found</h3>
                        <p style="color: #6c757d;">Complete some quizzes to see your progress here!</p>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <!-- Chart.js for graphs -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    
    <!-- Hidden field for chart data -->
    <asp:HiddenField ID="hfChartData" runat="server" />
    
    <script type="text/javascript">
        window.onload = function() {
            var chartDataElement = document.getElementById('<%= hfChartData.ClientID %>');
            if (chartDataElement && chartDataElement.value) {
                var chartData = JSON.parse(chartDataElement.value);
                createProgressChart(chartData);
            }
        };

        function createProgressChart(data) {
            var ctx = document.getElementById('progressChart');
            if (ctx) {
                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: data.labels,
                        datasets: [{
                            label: 'Quiz Scores',
                            data: data.scores,
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
                                text: 'Your Quiz Performance Over Time'
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 100,
                                title: {
                                    display: true,
                                    text: 'Score (%)'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Quiz Attempts'
                                }
                            }
                        }
                    }
                });
            }
        }
    </script>
</asp:Content>