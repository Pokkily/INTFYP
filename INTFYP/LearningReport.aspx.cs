using System;
using System.Threading.Tasks;
using System.Web.UI;
using System.Collections.Generic;
using Google.Cloud.Firestore;

namespace YourNamespace
{
    public partial class LearningReport : Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await LoadLessonReportsAsync();
            }
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

        private async Task LoadLessonReportsAsync()
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

                // Table header without "Attempt" column
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
                    <th>Duration (s)</th>
                    <th>Timestamp</th>
                </tr>
            </thead>
            <tbody>";

                foreach (var lesson in lessons)
                {
                    try
                    {
                        var attempts = await GetAllAttempts(userId, lesson);

                        // Skip lessons with no attempts
                        if (attempts.Count == 0)
                            continue;

                        // Render each attempt as a separate row
                        foreach (var attempt in attempts)
                        {
                            int totalSeconds = (int)Math.Round(attempt.DurationSeconds);
                            int minutes = totalSeconds / 60;
                            int seconds = totalSeconds % 60;
                            string durationFormatted = $"{minutes}m {seconds}s";

                            htmlOutput += "<tr>" +
                                $"<td>{lesson}</td>" +
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
                    catch (Exception ex)
                    {
                        htmlOutput += $"<tr><td colspan='8' style='color:red;'>Error loading {lesson}: {ex.Message}</td></tr>";
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
                .OrderBy("timestamp") // Newest first
                .GetSnapshotAsync();

            var attemptsList = new List<LessonAttempt>();

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                if (!doc.Exists) continue;

                Dictionary<string, object> data = doc.ToDictionary();

                // Parse each field safely, with fallback values
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
