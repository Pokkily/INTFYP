using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using Newtonsoft.Json;

namespace YourProjectNamespace
{
    public partial class QuizAnalytics : Page
    {
        private FirestoreDb db;

        public class QuizAttemptView
        {
            public string AttemptId { get; set; }
            public string QuizCode { get; set; }
            public string QuizTitle { get; set; }
            public string QuizCreatedBy { get; set; }
            public string UserId { get; set; }
            public string UserName { get; set; }
            public string UserEmail { get; set; }
            public string UserIP { get; set; }
            public DateTime StartedAt { get; set; }
            public DateTime CompletedAt { get; set; }
            public int TotalTimeSeconds { get; set; }
            public int TotalQuestions { get; set; }
            public int CorrectAnswers { get; set; }
            public double ScorePercentage { get; set; }
            public string Grade { get; set; }
            public List<QuestionAttemptView> QuestionAttempts { get; set; } = new List<QuestionAttemptView>();
        }

        public class QuestionAttemptView
        {
            public int QuestionIndex { get; set; }
            public string QuestionText { get; set; }
            public List<string> Options { get; set; } = new List<string>();
            public List<int> UserSelectedIndexes { get; set; } = new List<int>();
            public List<int> CorrectIndexes { get; set; } = new List<int>();
            public bool IsCorrect { get; set; }
            public bool IsMultipleChoice { get; set; }
            public DateTime AnsweredAt { get; set; }
            public int TimeSpentSeconds { get; set; }
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            await InitializeFirestore();

            if (!IsPostBack)
            {
                await LoadQuizDropdown();
                await LoadAnalyticsData();
            }
        }

        private async Task InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadQuizDropdown()
        {
            try
            {
                Query quizzesQuery = db.Collection("quizzes").OrderBy("title");
                QuerySnapshot snapshot = await quizzesQuery.GetSnapshotAsync();

                ddlQuizCode.Items.Clear();
                ddlQuizCode.Items.Add(new ListItem("All Quizzes", ""));

                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    if (doc.Exists)
                    {
                        string title = doc.ContainsField("title") ? doc.GetValue<string>("title") : "Untitled Quiz";
                        string code = doc.Id;
                        ddlQuizCode.Items.Add(new ListItem($"{title} ({code})", code));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading quiz dropdown: {ex.Message}");
            }
        }

        private async Task LoadAnalyticsData()
        {
            try
            {
                var attempts = await GetFilteredAttempts();

                if (attempts.Any())
                {
                    // Calculate overall statistics
                    lblTotalAttempts.Text = attempts.Count.ToString();
                    lblAverageScore.Text = Math.Round(attempts.Average(a => a.ScorePercentage), 1).ToString();
                    lblAverageTime.Text = Math.Round(attempts.Average(a => a.TotalTimeSeconds) / 60.0, 1).ToString();

                    // Calculate pass rate (scores >= 60%)
                    double passRate = attempts.Count > 0 ?
                        (double)attempts.Count(a => a.ScorePercentage >= 60) / attempts.Count * 100 : 0;
                    lblPassRate.Text = Math.Round(passRate, 1).ToString();

                    // Generate chart data
                    GenerateChartData(attempts);

                    // Bind attempts to repeater
                    rptAttempts.DataSource = attempts.OrderByDescending(a => a.CompletedAt).ToList();
                    rptAttempts.DataBind();

                    pnlAttempts.Visible = true;
                    pnlNoData.Visible = false;
                }
                else
                {
                    // Show no data message
                    lblTotalAttempts.Text = "0";
                    lblAverageScore.Text = "0";
                    lblAverageTime.Text = "0";
                    lblPassRate.Text = "0";

                    // Clear chart data
                    hdnScoreData.Value = "[]";
                    hdnGradeData.Value = "{}";

                    pnlAttempts.Visible = false;
                    pnlNoData.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading analytics data: {ex.Message}");
                pnlAttempts.Visible = false;
                pnlNoData.Visible = true;
            }
        }

        private void GenerateChartData(List<QuizAttemptView> attempts)
        {
            // Score distribution data for bar chart
            var scoreDistribution = new int[5]; // 0-20, 21-40, 41-60, 61-80, 81-100

            foreach (var attempt in attempts)
            {
                var score = attempt.ScorePercentage;
                if (score <= 20) scoreDistribution[0]++;
                else if (score <= 40) scoreDistribution[1]++;
                else if (score <= 60) scoreDistribution[2]++;
                else if (score <= 80) scoreDistribution[3]++;
                else scoreDistribution[4]++;
            }

            hdnScoreData.Value = JsonConvert.SerializeObject(scoreDistribution);

            // Grade distribution data for doughnut chart
            var gradeDistribution = new Dictionary<string, int>
            {
                ["A"] = attempts.Count(a => a.Grade == "A"),
                ["B"] = attempts.Count(a => a.Grade == "B"),
                ["C"] = attempts.Count(a => a.Grade == "C"),
                ["D"] = attempts.Count(a => a.Grade == "D"),
                ["F"] = attempts.Count(a => a.Grade == "F")
            };

            hdnGradeData.Value = JsonConvert.SerializeObject(gradeDistribution);
        }

        private async Task<List<QuizAttemptView>> GetFilteredAttempts()
        {
            var attempts = new List<QuizAttemptView>();

            try
            {
                Query query = db.Collection("quiz_attempts").OrderByDescending("completedAt").Limit(500);

                // Apply quiz code filter
                string selectedQuizCode = ddlQuizCode.SelectedValue;
                if (!string.IsNullOrEmpty(selectedQuizCode))
                {
                    query = query.WhereEqualTo("quizCode", selectedQuizCode);
                }

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    if (doc.Exists)
                    {
                        var attempt = ConvertDocumentToAttempt(doc);
                        attempts.Add(attempt);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error retrieving attempts: {ex.Message}");
            }

            return attempts;
        }

        private QuizAttemptView ConvertDocumentToAttempt(DocumentSnapshot doc)
        {
            var attempt = new QuizAttemptView
            {
                AttemptId = doc.ContainsField("attemptId") ? doc.GetValue<string>("attemptId") : doc.Id,
                QuizCode = doc.ContainsField("quizCode") ? doc.GetValue<string>("quizCode") : "",
                QuizTitle = doc.ContainsField("quizTitle") ? doc.GetValue<string>("quizTitle") : "Unknown Quiz",
                QuizCreatedBy = doc.ContainsField("quizCreatedBy") ? doc.GetValue<string>("quizCreatedBy") : "Unknown",
                UserId = doc.ContainsField("userId") ? doc.GetValue<string>("userId") : "",
                UserName = doc.ContainsField("userName") ? doc.GetValue<string>("userName") : "Anonymous",
                UserEmail = doc.ContainsField("userEmail") ? doc.GetValue<string>("userEmail") : "",
                UserIP = doc.ContainsField("userIP") ? doc.GetValue<string>("userIP") : "",
                TotalTimeSeconds = doc.ContainsField("totalTimeSeconds") ? doc.GetValue<int>("totalTimeSeconds") : 0,
                TotalQuestions = doc.ContainsField("totalQuestions") ? doc.GetValue<int>("totalQuestions") : 0,
                CorrectAnswers = doc.ContainsField("correctAnswers") ? doc.GetValue<int>("correctAnswers") : 0,
                ScorePercentage = doc.ContainsField("scorePercentage") ? doc.GetValue<double>("scorePercentage") : 0,
                Grade = doc.ContainsField("grade") ? doc.GetValue<string>("grade") : "F"
            };

            // Handle timestamps
            if (doc.ContainsField("startedAt"))
            {
                var timestamp = doc.GetValue<Timestamp>("startedAt");
                attempt.StartedAt = timestamp.ToDateTime().ToLocalTime();
            }

            if (doc.ContainsField("completedAt"))
            {
                var timestamp = doc.GetValue<Timestamp>("completedAt");
                attempt.CompletedAt = timestamp.ToDateTime().ToLocalTime();
            }

            // Handle question attempts
            if (doc.ContainsField("questionAttempts"))
            {
                var questionAttempts = doc.GetValue<List<Dictionary<string, object>>>("questionAttempts");
                foreach (var qa in questionAttempts)
                {
                    var questionAttempt = new QuestionAttemptView
                    {
                        QuestionIndex = qa.ContainsKey("questionIndex") ? Convert.ToInt32(qa["questionIndex"]) : 0,
                        QuestionText = qa.ContainsKey("questionText") ? qa["questionText"].ToString() : "",
                        IsCorrect = qa.ContainsKey("isCorrect") ? (bool)qa["isCorrect"] : false,
                        IsMultipleChoice = qa.ContainsKey("isMultipleChoice") ? (bool)qa["isMultipleChoice"] : false,
                        TimeSpentSeconds = qa.ContainsKey("timeSpentSeconds") ? Convert.ToInt32(qa["timeSpentSeconds"]) : 0
                    };

                    // Handle options
                    if (qa.ContainsKey("options"))
                    {
                        var options = qa["options"] as List<object>;
                        questionAttempt.Options = options?.Select(o => o.ToString()).ToList() ?? new List<string>();
                    }

                    // Handle user selected indexes
                    if (qa.ContainsKey("userSelectedIndexes"))
                    {
                        var indexes = qa["userSelectedIndexes"] as List<object>;
                        questionAttempt.UserSelectedIndexes = indexes?.Select(i => Convert.ToInt32(i)).ToList() ?? new List<int>();
                    }

                    // Handle correct indexes
                    if (qa.ContainsKey("correctIndexes"))
                    {
                        var indexes = qa["correctIndexes"] as List<object>;
                        questionAttempt.CorrectIndexes = indexes?.Select(i => Convert.ToInt32(i)).ToList() ?? new List<int>();
                    }

                    // Handle timestamp
                    if (qa.ContainsKey("answeredAt"))
                    {
                        if (qa["answeredAt"] is Timestamp timestamp)
                        {
                            questionAttempt.AnsweredAt = timestamp.ToDateTime().ToLocalTime();
                        }
                    }

                    attempt.QuestionAttempts.Add(questionAttempt);
                }
            }

            return attempt;
        }

        protected async void btnApplyFilters_Click(object sender, EventArgs e)
        {
            await LoadAnalyticsData();
        }

        protected void rptAttempts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                string attemptId = e.CommandArgument.ToString();

                // Add JavaScript to toggle the details panel
                string script = $"toggleDetails('{attemptId}');";
                ClientScript.RegisterStartupScript(this.GetType(), "ToggleDetails", script, true);
            }
        }

        protected async void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                var attempts = await GetFilteredAttempts();
                var csv = GenerateCSV(attempts);

                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AddHeader("Content-Disposition",
                    $"attachment; filename=quiz_analytics_{DateTime.Now:yyyyMMdd_HHmmss}.csv");
                Response.Write(csv);
                Response.End();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error exporting CSV: {ex.Message}");
            }
        }

        private string GenerateCSV(List<QuizAttemptView> attempts)
        {
            var csv = new StringBuilder();

            // Header
            csv.AppendLine("Attempt ID,Quiz Code,Quiz Title,User Name,User IP,Started At,Completed At,Total Time (seconds),Total Questions,Correct Answers,Score Percentage,Grade");

            // Data
            foreach (var attempt in attempts)
            {
                csv.AppendLine($"{attempt.AttemptId}," +
                              $"{attempt.QuizCode}," +
                              $"\"{attempt.QuizTitle}\"," +
                              $"{attempt.UserName}," +
                              $"{attempt.UserIP}," +
                              $"{attempt.StartedAt:yyyy-MM-dd HH:mm:ss}," +
                              $"{attempt.CompletedAt:yyyy-MM-dd HH:mm:ss}," +
                              $"{attempt.TotalTimeSeconds}," +
                              $"{attempt.TotalQuestions}," +
                              $"{attempt.CorrectAnswers}," +
                              $"{attempt.ScorePercentage}," +
                              $"{attempt.Grade}");
            }

            return csv.ToString();
        }

        // Helper method for formatting time in the ASPX page
        public string FormatTime(int totalSeconds)
        {
            if (totalSeconds < 60)
                return $"{totalSeconds}s";
            else if (totalSeconds < 3600)
                return $"{totalSeconds / 60}m {totalSeconds % 60}s";
            else
                return $"{totalSeconds / 3600}h {(totalSeconds % 3600) / 60}m";
        }

        // Helper method for displaying selected options in the ASPX page
        public string GetSelectedOptions(object optionsObj, object selectedIndexesObj)
        {
            try
            {
                var options = optionsObj as List<string>;
                var selectedIndexes = selectedIndexesObj as List<int>;

                if (options == null || selectedIndexes == null || !selectedIndexes.Any())
                    return "No answer selected";

                var selectedOptions = selectedIndexes
                    .Where(index => index >= 0 && index < options.Count)
                    .Select(index => $"• {options[index]}")
                    .ToList();

                return selectedOptions.Any() ? string.Join("<br/>", selectedOptions) : "No answer selected";
            }
            catch
            {
                return "Error loading options";
            }
        }

        // Method to get quiz performance summary (can be called from other pages)
        public static async Task<Dictionary<string, object>> GetQuizPerformanceSummary(string quizCode)
        {
            string path = System.Web.HttpContext.Current.Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            var db = FirestoreDb.Create("intorannetto");

            var summary = new Dictionary<string, object>();

            try
            {
                Query query = db.Collection("quiz_attempts").WhereEqualTo("quizCode", quizCode);
                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                if (snapshot.Count > 0)
                {
                    var scores = snapshot.Documents
                        .Where(doc => doc.ContainsField("scorePercentage"))
                        .Select(doc => doc.GetValue<double>("scorePercentage"))
                        .ToList();

                    var times = snapshot.Documents
                        .Where(doc => doc.ContainsField("totalTimeSeconds"))
                        .Select(doc => doc.GetValue<int>("totalTimeSeconds"))
                        .ToList();

                    summary["TotalAttempts"] = snapshot.Count;
                    summary["AverageScore"] = scores.Any() ? Math.Round(scores.Average(), 2) : 0;
                    summary["HighestScore"] = scores.Any() ? scores.Max() : 0;
                    summary["LowestScore"] = scores.Any() ? scores.Min() : 0;
                    summary["AverageTime"] = times.Any() ? Math.Round(times.Average() / 60.0, 2) : 0;
                    summary["PassRate"] = scores.Any() ? Math.Round((double)scores.Count(s => s >= 60) / scores.Count * 100, 2) : 0;
                }
                else
                {
                    summary["TotalAttempts"] = 0;
                    summary["AverageScore"] = 0;
                    summary["HighestScore"] = 0;
                    summary["LowestScore"] = 0;
                    summary["AverageTime"] = 0;
                    summary["PassRate"] = 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting performance summary: {ex.Message}");
                summary["Error"] = ex.Message;
            }

            return summary;
        }
    }
}