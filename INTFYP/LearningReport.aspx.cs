using System;
using System.Collections.Generic;
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

            // Prepare a list to hold lessons + aggregate info
            var lessonsWithAggregates = new List<(string LessonName, List<LessonAttempt> Attempts, double AvgDuration, int MaxCorrect, DateTime LatestTimestamp)>();

            foreach (var lesson in lessons)
            {
                try
                {
                    var attempts = await GetAllAttempts(userId, lesson);
                    if (attempts.Count == 0)
                        continue;

                    double avgDuration = attempts.Average(a => a.DurationSeconds);
                    int maxCorrect = attempts.Max(a => a.CorrectCount);
                    DateTime latestTimestamp = attempts.Max(a => a.Timestamp);

                    lessonsWithAggregates.Add((lesson, attempts, avgDuration, maxCorrect, latestTimestamp));
                }
                catch (Exception ex)
                {
                    // Optionally handle or log error here
                }
            }

            // Sort the lessons themselves based on chosen criteria
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

                case "most_incorrect":
                    lessonsWithAggregates = lessonsWithAggregates.OrderBy(l => l.MaxCorrect).ToList();
                    break;

                default:
                    // Default sort by newest
                    lessonsWithAggregates = lessonsWithAggregates.OrderByDescending(l => l.LatestTimestamp).ToList();
                    break;
            }


            // Now build HTML output
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
                // Sort attempts inside each lesson by newest first (or keep as-is)
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
                        $"<td>{attempt.StartTime.ToString("g")}</td>" +
                        $"<td>{attempt.EndTime.ToString("g")}</td>" +
                        $"<td>{durationFormatted}</td>" +
                        $"<td>{attempt.Timestamp.ToString("g")}</td>" +
                        "</tr>";
                }
            }

            htmlOutput += "</tbody></table>";

            ReportLiteral.Text = htmlOutput;
        }


        private async Task<List<LessonAttempt>> GetAllAttempts(string userId, string lessonName)
        {
            DocumentReference userDoc = db.Collection("users").Document(userId);
            CollectionReference attemptsCol = userDoc
                .Collection("results")
                .Document(lessonName)
                .Collection("attempts");

            QuerySnapshot snapshot = await attemptsCol
                .OrderBy("timestamp") // ascending (oldest first)
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
