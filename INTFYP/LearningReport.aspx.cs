using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using Google.Cloud.Firestore;

namespace YourNamespace
{
    public partial class LearningReport : Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        // Store current sort method
        private string currentSort = "timestamp";

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                currentSort = "timestamp"; // default sorting
                await LoadLessonReportsAsync(currentSort);
            }
        }

        protected async void SortSelect_SelectedIndexChanged(object sender, EventArgs e)
        {
            currentSort = SortSelect.SelectedValue;
            await LoadLessonReportsAsync(currentSort);
        }

        private void InitializeFirestore()
        {
            if (db == null)
            {
                lock (dbLock)
                {
                    if (db == null)
                    {
                        string path = Server.MapPath("~/serviceAccountKey.json");
                        Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                        db = FirestoreDb.Create("intorannetto");
                    }
                }
            }
        }

        private async Task LoadLessonReportsAsync(string sortBy)
        {
            InitializeFirestore();

            string userId = Session["userId"]?.ToString();

            if (string.IsNullOrEmpty(userId))
            {
                ReportLiteral.Text = "<div style='color:red;'>User ID missing in session. Please log in.</div>";
                return;
            }

            var lessons = new List<string>
            {
                "KoreanTravelLesson1Result",
                "KoreanTravelLesson2Result",
                "KoreanTravelLesson3Result",
                "KoreanCoffeeShopLesson1Result",
                "KoreanCoffeeShopLesson2Result",
                "KoreanCoffeeShopLesson3Result",
                "KoreanMarketLesson1Result",
                "KoreanMarketLesson2Result",
                "KoreanMarketLesson3Result",
                "KoreanRestaurantLesson1Result",
                "KoreanRestaurantLesson2Result",
                "KoreanRestaurantLesson3Result"
            };

            // 1) Get lesson completion status per lesson (1 = completed, 0 = incomplete)
            var lessonCompletionStatus = new Dictionary<string, int>();

            foreach (var lesson in lessons)
            {
                var attempts = await GetAllAttempts(userId, lesson);

                if (attempts.Count == 0)
                {
                    lessonCompletionStatus[lesson] = 0; // no attempts = incomplete
                    continue;
                }

                var latestAttempt = attempts.OrderByDescending(a => a.Timestamp).FirstOrDefault();

                if (latestAttempt != null && latestAttempt.TotalQuestions > 0 && latestAttempt.CorrectCount == latestAttempt.TotalQuestions)
                    lessonCompletionStatus[lesson] = 1; // completed = 100% correct latest attempt
                else
                    lessonCompletionStatus[lesson] = 0; // incomplete
            }

            // 2) Get time spent per week (for weekly bar chart)
            var (_, _, timePerWeek) = await GetChartDataAsync(userId, lessons);

            // 3) Get time spent per day (last 7 days including today) for daily bar chart
            var timePerDay = await GetTimePerDayAsync(userId, lessons);

            // 4) Build lesson attempts table with sorting
            var lessonsWithAggregates = new List<(string LessonName, List<LessonAttempt> Attempts, double AvgDuration, int MaxCorrect, DateTime LatestTimestamp)>();

            foreach (var lesson in lessons)
            {
                var attempts = await GetAllAttempts(userId, lesson);
                if (attempts.Count == 0) continue;

                double avgDuration = attempts.Average(a => a.DurationSeconds);
                int maxCorrect = attempts.Max(a => a.CorrectCount);
                DateTime latestTimestamp = attempts.Max(a => a.Timestamp);

                lessonsWithAggregates.Add((lesson, attempts, avgDuration, maxCorrect, latestTimestamp));
            }

            // Sort the table data
            switch (sortBy)
            {
                case "name_asc":
                    lessonsWithAggregates = lessonsWithAggregates.OrderBy(l => l.LessonName).ToList();
                    break;
                case "name_desc":
                    lessonsWithAggregates = lessonsWithAggregates.OrderByDescending(l => l.LessonName).ToList();
                    break;
                case "newest":
                    lessonsWithAggregates = lessonsWithAggregates.OrderByDescending(l => l.LatestTimestamp).ToList();
                    break;
                case "older":
                    lessonsWithAggregates = lessonsWithAggregates.OrderBy(l => l.LatestTimestamp).ToList();
                    break;
                case "shortest_duration":
                    lessonsWithAggregates = lessonsWithAggregates.OrderBy(l => l.AvgDuration).ToList();
                    break;
                case "longest_duration":
                    lessonsWithAggregates = lessonsWithAggregates.OrderByDescending(l => l.AvgDuration).ToList();
                    break;
                case "most_correct":
                    lessonsWithAggregates = lessonsWithAggregates.OrderByDescending(l => l.MaxCorrect).ToList();
                    break;
                default:
                    lessonsWithAggregates = lessonsWithAggregates.OrderByDescending(l => l.LatestTimestamp).ToList();
                    break;
            }

            // Prepare lesson completion bar chart data
            var lessonNames = lessonCompletionStatus.Keys.ToList();
            var completionValues = lessonCompletionStatus.Values.ToList();
            var barColors = completionValues.Select(val => val == 1 ? "'#4caf50'" : "'#f44336'").ToList();

            string lessonBarLabels = string.Join(",", lessonNames.Select(n => $"'{n}'"));
            string lessonBarData = string.Join(",", completionValues);
            string lessonBarColorsStr = string.Join(",", barColors);

            // Prepare weekly time spent bar chart data
            var sortedWeeks = timePerWeek.Keys.OrderBy(k => k).ToList();
            var weeklyLabels = string.Join(",", sortedWeeks.Select(w => $"'{w}'"));
            var weeklyData = string.Join(",", sortedWeeks.Select(w => timePerWeek[w].ToString("F1")));

            // Calculate total and average weekly time spent (minutes)
            double totalMinutes = timePerWeek.Values.Sum();
            int totalDays = timePerWeek.Count * 7;
            double avgPerDay = totalDays > 0 ? totalMinutes / totalDays : 0;

            TotalTimeAfterDailyBar.Text = $"<p class='mt-2 mb-0'><strong>Total Time Spent:</strong> {totalMinutes:F1} minutes &nbsp;&nbsp;&nbsp; <strong>Average Per Day:</strong> {avgPerDay:F1} minutes</p>";


            // Prepare daily time spent bar chart data (last 7 days)
            var today = DateTime.Today;
            var past7Days = Enumerable.Range(0, 7)
                .Select(i => today.AddDays(-6 + i))
                .ToList();

            string dailyLabels = string.Join(",", past7Days.Select(d => $"'{d:MM-dd}'"));
            string dailyData = string.Join(",", past7Days.Select(d =>
                timePerDay.ContainsKey(d.ToString("yyyy-MM-dd")) ? timePerDay[d.ToString("yyyy-MM-dd")] : 0));

            // Build chart scripts with window.onload
            string chartScripts = $@"
<script>
window.onload = function() {{
    // Lesson Completion Status bar chart
    const completionCtx = document.getElementById('donutChart').getContext('2d');
    new Chart(completionCtx, {{
        type: 'bar',
        data: {{
            labels: [{lessonBarLabels}],
            datasets: [{{
                label: 'Completion Status (1=Completed, 0=Incomplete)',
                data: [{lessonBarData}],
                backgroundColor: [{lessonBarColorsStr}],
                borderWidth: 1
            }}]
        }},
        options: {{
            scales: {{
                y: {{
                    beginAtZero: true,
                    max: 1,
                    ticks: {{
                        stepSize: 1,
                        callback: function(value) {{
                            return value === 1 ? 'Completed' : 'Incomplete';
                        }}
                    }},
                    title: {{
                        display: true,
                        text: 'Completion Status'
                    }}
                }},
                x: {{
                    ticks: {{
                        maxRotation: 45,
                        minRotation: 45
                    }}
                }}
            }},
            plugins: {{
                legend: {{
                    display: false
                }},
                title: {{
                    display: true,
                    text: 'Lesson Completion Status'
                }},
                tooltip: {{
                    callbacks: {{
                        label: function(context) {{
                            return context.parsed.y === 1 ? 'Completed' : 'Incomplete';
                        }}
                    }}
                }}
            }},
            responsive: true,
            maintainAspectRatio: false
        }}
    }});

    // Daily Time Spent (past 7 days) bar chart
    const dailyCtx = document.getElementById('dailyBarChart').getContext('2d');
    new Chart(dailyCtx, {{
        type: 'bar',
        data: {{
            labels: [{dailyLabels}],
            datasets: [{{
                label: 'Minutes Spent',
                data: [{dailyData}],
                backgroundColor: '#ff9800'
            }}]
        }},
        options: {{
            responsive: true,
            scales: {{
                y: {{
                    beginAtZero: true,
                    title: {{
                        display: true,
                        text: 'Minutes'
                    }}
                }}
            }},
            plugins: {{
                legend: {{ display: false }},
                title: {{
                    display: true,
                    text: 'Time Spent Learning Over Past 7 Days (Daily)'
                }}
            }}
        }}
    }});
}};
</script>";

            // Build the lessons attempts table
            string htmlOutput = @"
<table class='table table-bordered table-striped'>
    <thead>
        <tr>
            <th>Lesson</th>
            <th>Status</th>
            <th>Correct</th>
            <th>Total Questions</th>
            <th>Start Time</th>
            <th>End Time</th>
            <th>Duration</th>
            <th>Timestamp</th>
        </tr>
    </thead>
    <tbody>";

            foreach (var lessonData in lessonsWithAggregates)
            {
                var sortedAttempts = lessonData.Attempts.OrderByDescending(a => a.Timestamp).ToList();

                foreach (var attempt in sortedAttempts)
                {
                    int totalSeconds = (int)Math.Round(attempt.DurationSeconds);
                    int minutes = totalSeconds / 60;
                    int seconds = totalSeconds % 60;
                    string durationFormatted = $"{minutes}m {seconds}s";

                    htmlOutput += "<tr>" +
                        $"<td>{lessonData.LessonName}</td>" +
                        $"<td>{attempt.Status}</td>" +
                        $"<td>{attempt.CorrectCount}</td>" +
                        $"<td>{attempt.TotalQuestions}</td>" +
                        $"<td>{attempt.StartTime:g}</td>" +
                        $"<td>{attempt.EndTime:g}</td>" +
                        $"<td>{durationFormatted}</td>" +
                        $"<td>{attempt.Timestamp:g}</td>" +
                        "</tr>";
                }
            }

            htmlOutput += "</tbody></table>";

            // Render charts + total/avg info + table
            // IMPORTANT: Add <canvas> elements with ids 'donutChart', 'barChart', and 'dailyBarChart' to your .aspx markup
            string canvasesHtml = @"

            <div style='width: 100%; height: 400px; margin-top: 30px;'>
                <canvas id='barChart'></canvas>
            </div>
            <div style='width: 100%; height: 400px; margin-top: 30px;'>
                <canvas id='dailyBarChart'></canvas>
            </div>
            ";

            ReportLiteral.Text = chartScripts + htmlOutput;
        }

        // New method: get time spent per day for past 7 days
        private async Task<Dictionary<string, double>> GetTimePerDayAsync(string userId, List<string> lessons)
        {
            var timePerDay = new Dictionary<string, double>();
            var today = DateTime.Today;
            var fromDate = today.AddDays(-6); // 6 days ago

            foreach (var lesson in lessons)
            {
                var attempts = await GetAllAttempts(userId, lesson);
                foreach (var attempt in attempts)
                {
                    if (attempt.StartTime == DateTime.MinValue) continue;

                    if (attempt.StartTime.Date >= fromDate && attempt.StartTime.Date <= today)
                    {
                        string dayKey = attempt.StartTime.ToString("yyyy-MM-dd");
                        double minutes = attempt.DurationSeconds / 60.0;
                        if (timePerDay.ContainsKey(dayKey))
                            timePerDay[dayKey] += minutes;
                        else
                            timePerDay[dayKey] = minutes;
                    }
                }
            }
            return timePerDay;
        }

        private async Task<(int completedLessons, int notCompletedLessons, Dictionary<string, double> timePerWeek)> GetChartDataAsync(string userId, List<string> lessons)
        {
            int completed = 0;
            int notCompleted = 0;
            var timePerWeek = new Dictionary<string, double>();

            foreach (var lesson in lessons)
            {
                var attempts = await GetAllAttempts(userId, lesson);

                if (attempts.Count == 0)
                {
                    notCompleted++;
                    continue;
                }

                bool isCompleted = attempts.Any(a => a.Status?.Equals("Completed", StringComparison.OrdinalIgnoreCase) == true);

                if (isCompleted)
                    completed++;
                else
                    notCompleted++;

                foreach (var attempt in attempts)
                {
                    if (attempt.StartTime == DateTime.MinValue) continue;

                    var calendar = CultureInfo.CurrentCulture.Calendar;
                    int weekNum = calendar.GetWeekOfYear(attempt.StartTime, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
                    string weekLabel = $"{attempt.StartTime.Year}-W{weekNum:D2}";

                    double minutes = attempt.DurationSeconds / 60.0;

                    if (timePerWeek.ContainsKey(weekLabel))
                        timePerWeek[weekLabel] += minutes;
                    else
                        timePerWeek[weekLabel] = minutes;
                }
            }

            return (completed, notCompleted, timePerWeek);
        }

        private async Task<List<LessonAttempt>> GetAllAttempts(string userId, string lessonName)
        {
            DocumentReference userDoc = db.Collection("users").Document(userId);
            CollectionReference attemptsCol = userDoc
                .Collection("results")
                .Document(lessonName)
                .Collection("attempts");

            QuerySnapshot snapshot = await attemptsCol
                .OrderBy("timestamp")
                .GetSnapshotAsync();

            var attemptsList = new List<LessonAttempt>();

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                if (!doc.Exists) continue;

                Dictionary<string, object> data = doc.ToDictionary();

                int correctCount = data.ContainsKey("score") ? Convert.ToInt32(data["score"]) : 0;
                int totalQuestions = data.ContainsKey("total") ? Convert.ToInt32(data["total"]) : 0;
                string status = data.ContainsKey("status") ? data["status"]?.ToString() : "N/A";

                DateTime startTime = DateTime.MinValue;
                if (data.ContainsKey("startTime") && data["startTime"] is Timestamp startTs)
                    startTime = startTs.ToDateTime();

                DateTime endTime = DateTime.MinValue;
                if (data.ContainsKey("endTime") && data["endTime"] is Timestamp endTs)
                    endTime = endTs.ToDateTime();

                double durationSeconds = data.ContainsKey("durationSeconds") ? Convert.ToDouble(data["durationSeconds"]) : 0;

                DateTime timestamp = DateTime.MinValue;
                if (data.ContainsKey("timestamp") && data["timestamp"] is Timestamp ts)
                    timestamp = ts.ToDateTime();

                attemptsList.Add(new LessonAttempt
                {
                    CorrectCount = correctCount,
                    TotalQuestions = totalQuestions,
                    Status = status,
                    StartTime = startTime,
                    EndTime = endTime,
                    DurationSeconds = durationSeconds,
                    Timestamp = timestamp
                });
            }

            return attemptsList;
        }

        private class LessonAttempt
        {
            public int CorrectCount { get; set; }
            public int TotalQuestions { get; set; }
            public string Status { get; set; }
            public DateTime StartTime { get; set; }
            public DateTime EndTime { get; set; }
            public double DurationSeconds { get; set; }
            public DateTime Timestamp { get; set; }
        }
    }
}
