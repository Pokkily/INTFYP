using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;
using Newtonsoft.Json;

namespace INTFYP
{
    public partial class StudentReports : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();
        private string currentUserId;

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
            currentUserId = GetCurrentUserId();

            if (string.IsNullOrEmpty(currentUserId))
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                await LoadAvailableLanguages();

                string languageId = Request.QueryString["languageId"];
                if (!string.IsNullOrEmpty(languageId))
                {
                    ddlLanguages.SelectedValue = languageId;
                    await LoadStudentProgress(languageId);
                }
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

        private string GetCurrentUserId()
        {
            return Session["UserId"]?.ToString();
        }

        protected string FormatRelativeTime(DateTime timestamp)
        {
            DateTime localTime = timestamp.Kind == DateTimeKind.Utc ? timestamp.ToLocalTime() : timestamp;
            var timeSpan = DateTime.Now - localTime;

            if (timeSpan.Days > 0)
                return $"{timeSpan.Days}d ago";
            else if (timeSpan.Hours > 0)
                return $"{timeSpan.Hours}h ago";
            else if (timeSpan.Minutes > 0)
                return $"{timeSpan.Minutes}m ago";
            else
                return "Just now";
        }

        protected string FormatMessageTime(DateTime timestamp)
        {
            DateTime localTime = timestamp.Kind == DateTimeKind.Utc ? timestamp.ToLocalTime() : timestamp;
            return localTime.ToString("HH:mm");
        }

        protected string FormatFullDateTime(DateTime timestamp)
        {
            DateTime localTime = timestamp.Kind == DateTimeKind.Utc ? timestamp.ToLocalTime() : timestamp;
            return localTime.ToString("MMM dd, yyyy HH:mm");
        }

        private DateTime ConvertTimestampToLocal(Timestamp timestamp)
        {
            try
            {
                var utcDateTime = timestamp.ToDateTime();
                if (utcDateTime.Kind == DateTimeKind.Unspecified)
                {
                    utcDateTime = DateTime.SpecifyKind(utcDateTime, DateTimeKind.Utc);
                }
                return utcDateTime.ToLocalTime();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error converting timestamp: {ex.Message}");
                return DateTime.Now;
            }
        }

        private DateTime SafeParseDateTime(object dateValue, DateTime defaultValue = default(DateTime))
        {
            try
            {
                if (dateValue == null)
                {
                    return defaultValue == default(DateTime) ? DateTime.Now : defaultValue;
                }

                if (dateValue is Timestamp timestamp)
                {
                    return ConvertTimestampToLocal(timestamp);
                }

                if (dateValue is DateTime dateTime)
                {
                    if (dateTime.Kind == DateTimeKind.Unspecified)
                    {
                        dateTime = DateTime.SpecifyKind(dateTime, DateTimeKind.Utc);
                    }
                    return dateTime.Kind == DateTimeKind.Utc ? dateTime.ToLocalTime() : dateTime;
                }

                if (DateTime.TryParse(dateValue.ToString(), out DateTime parsedDate))
                {
                    if (parsedDate.Kind == DateTimeKind.Unspecified)
                    {
                        parsedDate = DateTime.SpecifyKind(parsedDate, DateTimeKind.Utc);
                    }
                    return parsedDate.Kind == DateTimeKind.Utc ? parsedDate.ToLocalTime() : parsedDate;
                }

                return defaultValue == default(DateTime) ? DateTime.Now : defaultValue;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error parsing DateTime: {ex.Message}");
                return defaultValue == default(DateTime) ? DateTime.Now : defaultValue;
            }
        }

        private async System.Threading.Tasks.Task LoadAvailableLanguages()
        {
            try
            {
                CollectionReference progressRef = db.Collection("users").Document(currentUserId).Collection("progress");
                QuerySnapshot progressSnapshot = await progressRef.GetSnapshotAsync();

                ddlLanguages.Items.Clear();
                ddlLanguages.Items.Add(new ListItem("-- Select a Language --", ""));

                foreach (DocumentSnapshot progressDoc in progressSnapshot.Documents)
                {
                    string languageId = progressDoc.Id;

                    DocumentSnapshot languageDoc = await db.Collection("languages").Document(languageId).GetSnapshotAsync();
                    if (languageDoc.Exists)
                    {
                        var languageData = languageDoc.ToDictionary();
                        string languageName = languageData.ContainsKey("Name") ? languageData["Name"].ToString() : languageId;
                        ddlLanguages.Items.Add(new ListItem(languageName, languageId));
                    }
                    else
                    {
                        ddlLanguages.Items.Add(new ListItem(languageId, languageId));
                    }
                }

                if (ddlLanguages.Items.Count == 1)
                {
                    pnlNoData.Visible = true;
                    pnlStats.Visible = false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading languages: {ex.Message}");
                ShowErrorMessage("Error loading available languages.");
            }
        }

        protected async void ddlLanguages_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selectedLanguageId = ddlLanguages.SelectedValue;
            if (!string.IsNullOrEmpty(selectedLanguageId))
            {
                await LoadStudentProgress(selectedLanguageId);
            }
            else
            {
                pnlStats.Visible = false;
                pnlNoData.Visible = false;
            }
        }

        private async System.Threading.Tasks.Task LoadStudentProgress(string languageId)
        {
            try
            {
                DocumentReference languageProgressRef = db.Collection("users")
                    .Document(currentUserId)
                    .Collection("progress")
                    .Document(languageId);

                DocumentSnapshot languageProgressSnap = await languageProgressRef.GetSnapshotAsync();

                if (languageProgressSnap.Exists)
                {
                    var progressData = languageProgressSnap.ToDictionary();

                    lblTotalAttempts.Text = progressData.ContainsKey("totalAttempts") ? progressData["totalAttempts"].ToString() : "0";
                    lblCompletedLessons.Text = progressData.ContainsKey("completedLessons") ? progressData["completedLessons"].ToString() : "0";
                    lblCurrentStreak.Text = progressData.ContainsKey("currentStreak") ? progressData["currentStreak"].ToString() : "0";

                    double totalMinutes = progressData.ContainsKey("totalTimeSpent") ? Convert.ToDouble(progressData["totalTimeSpent"]) : 0;
                    lblTotalTime.Text = Math.Round(totalMinutes, 1).ToString();

                    var allAttempts = await GetAllAttemptsForLanguage(languageId);
                    if (allAttempts.Any())
                    {
                        double averageScore = allAttempts.Average(a => a.Score);
                        lblAverageScore.Text = Math.Round(averageScore, 1).ToString();
                        System.Diagnostics.Debug.WriteLine($"📊 Calculated average score: {Math.Round(averageScore, 1)}% from {allAttempts.Count} attempts");
                    }
                    else
                    {
                        lblAverageScore.Text = "0";
                        System.Diagnostics.Debug.WriteLine("📊 No attempts found, average score set to 0");
                    }

                    await LoadTopicProgress(languageId);

                    await LoadRecentActivityAndChartData(languageId);

                    pnlStats.Visible = true;
                    pnlNoData.Visible = false;
                }
                else
                {
                    pnlStats.Visible = false;
                    pnlNoData.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading student progress: {ex.Message}");
                ShowErrorMessage("Error loading progress data.");
            }
        }

        private async System.Threading.Tasks.Task<List<AttemptData>> GetAllAttemptsForLanguage(string languageId)
        {
            var allAttempts = new List<AttemptData>();

            try
            {
                CollectionReference topicsRef = db.Collection("users")
                    .Document(currentUserId)
                    .Collection("progress")
                    .Document(languageId)
                    .Collection("topics");

                QuerySnapshot topicsSnapshot = await topicsRef.GetSnapshotAsync();

                foreach (DocumentSnapshot topicDoc in topicsSnapshot.Documents)
                {
                    CollectionReference lessonsRef = topicDoc.Reference.Collection("lessons");
                    QuerySnapshot lessonsSnapshot = await lessonsRef.GetSnapshotAsync();

                    foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                    {
                        CollectionReference attemptsRef = lessonDoc.Reference.Collection("attempts");
                        QuerySnapshot attemptsSnapshot = await attemptsRef.GetSnapshotAsync();

                        foreach (DocumentSnapshot attemptDoc in attemptsSnapshot.Documents)
                        {
                            var attemptData = attemptDoc.ToDictionary();
                            int score = attemptData.ContainsKey("score") ? Convert.ToInt32(attemptData["score"]) : 0;

                            allAttempts.Add(new AttemptData { Score = score });
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"🔢 Retrieved {allAttempts.Count} attempts for average calculation");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ Error getting attempts for average: {ex.Message}");
            }

            return allAttempts;
        }

        private async System.Threading.Tasks.Task LoadTopicProgress(string languageId)
        {
            try
            {
                var topicProgressList = new List<object>();

                CollectionReference topicsRef = db.Collection("users")
                    .Document(currentUserId)
                    .Collection("progress")
                    .Document(languageId)
                    .Collection("topics");

                QuerySnapshot topicsSnapshot = await topicsRef.GetSnapshotAsync();

                foreach (DocumentSnapshot topicDoc in topicsSnapshot.Documents)
                {
                    var topicData = topicDoc.ToDictionary();

                    string topicName = topicData.ContainsKey("topicName") ? topicData["topicName"].ToString() : topicDoc.Id;
                    int lessonsInTopic = topicData.ContainsKey("lessonsInTopic") ? Convert.ToInt32(topicData["lessonsInTopic"]) : 0;
                    int completedLessons = topicData.ContainsKey("completedLessons") ? Convert.ToInt32(topicData["completedLessons"]) : 0;

                    var lessonScores = await GetLessonScoresForTopic(topicDoc.Reference);
                    int lessonsWithPerfectScore = lessonScores.Count(score => score >= 100);

                    double progress = lessonsInTopic > 0 ? Math.Round((double)completedLessons / lessonsInTopic * 100, 1) : 0;

                    bool isComplete = (completedLessons >= lessonsInTopic && lessonsWithPerfectScore >= lessonsInTopic && lessonsInTopic > 0);

                    string statusText;
                    string statusClass;

                    if (isComplete)
                    {
                        statusText = "Complete";
                        statusClass = "complete";
                    }
                    else if (completedLessons >= lessonsInTopic && lessonsInTopic > 0)
                    {
                        statusText = "Needs Review";
                        statusClass = "needs-review";
                    }
                    else
                    {
                        statusText = $"{progress}%";
                        statusClass = "in-progress";
                    }

                    topicProgressList.Add(new
                    {
                        TopicName = topicName,
                        TotalLessons = lessonsInTopic,
                        CompletedLessons = completedLessons,
                        LessonsWithPerfectScore = lessonsWithPerfectScore,
                        Progress = progress,
                        IsComplete = isComplete,
                        StatusText = statusText,
                        StatusClass = statusClass
                    });

                    System.Diagnostics.Debug.WriteLine($"📚 Topic '{topicName}': {completedLessons}/{lessonsInTopic} lessons, {lessonsWithPerfectScore} with 100% ({statusText})");
                }

                rptTopicProgress.DataSource = topicProgressList.OrderByDescending(t => ((dynamic)t).Progress).ToList();
                rptTopicProgress.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading topic progress: {ex.Message}");
            }
        }

        private async System.Threading.Tasks.Task<List<int>> GetLessonScoresForTopic(DocumentReference topicRef)
        {
            var lessonScores = new List<int>();

            try
            {
                CollectionReference lessonsRef = topicRef.Collection("lessons");
                QuerySnapshot lessonsSnapshot = await lessonsRef.GetSnapshotAsync();

                foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                {
                    CollectionReference attemptsRef = lessonDoc.Reference.Collection("attempts");
                    QuerySnapshot attemptsSnapshot = await attemptsRef.GetSnapshotAsync();

                    int bestScore = 0;
                    foreach (DocumentSnapshot attemptDoc in attemptsSnapshot.Documents)
                    {
                        var attemptData = attemptDoc.ToDictionary();
                        int score = attemptData.ContainsKey("score") ? Convert.ToInt32(attemptData["score"]) : 0;

                        if (score > bestScore)
                        {
                            bestScore = score;
                        }
                    }

                    if (attemptsSnapshot.Documents.Count > 0)
                    {
                        lessonScores.Add(bestScore);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ Error getting lesson scores: {ex.Message}");
            }

            return lessonScores;
        }

        private async System.Threading.Tasks.Task LoadRecentActivityAndChartData(string languageId)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"🔍 Loading recent activity from user progress structure for language: {languageId}");

                var allAttempts = new List<dynamic>();

                CollectionReference topicsRef = db.Collection("users")
                    .Document(currentUserId)
                    .Collection("progress")
                    .Document(languageId)
                    .Collection("topics");

                QuerySnapshot topicsSnapshot = await topicsRef.GetSnapshotAsync();

                System.Diagnostics.Debug.WriteLine($"📚 Found {topicsSnapshot.Documents.Count} topics");

                foreach (DocumentSnapshot topicDoc in topicsSnapshot.Documents)
                {
                    string topicName = topicDoc.Id;
                    var topicData = topicDoc.ToDictionary();
                    string topicDisplayName = topicData.ContainsKey("topicName") ? topicData["topicName"].ToString() : topicName;

                    CollectionReference lessonsRef = topicDoc.Reference.Collection("lessons");
                    QuerySnapshot lessonsSnapshot = await lessonsRef.GetSnapshotAsync();

                    System.Diagnostics.Debug.WriteLine($"📖 Topic '{topicDisplayName}' has {lessonsSnapshot.Documents.Count} lessons");

                    foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                    {
                        string lessonId = lessonDoc.Id;
                        var lessonData = lessonDoc.ToDictionary();
                        string lessonName = lessonData.ContainsKey("lessonName") ? lessonData["lessonName"].ToString() : lessonId;

                        CollectionReference attemptsRef = lessonDoc.Reference.Collection("attempts");
                        QuerySnapshot attemptsSnapshot = await attemptsRef.GetSnapshotAsync();

                        System.Diagnostics.Debug.WriteLine($"🎯 Lesson '{lessonName}' has {attemptsSnapshot.Documents.Count} attempts");

                        foreach (DocumentSnapshot attemptDoc in attemptsSnapshot.Documents)
                        {
                            var attemptData = attemptDoc.ToDictionary();

                            int score = attemptData.ContainsKey("score") ? Convert.ToInt32(attemptData["score"]) : 0;
                            int attemptNumber = attemptData.ContainsKey("attemptNumber") ? Convert.ToInt32(attemptData["attemptNumber"]) : 1;

                            DateTime completedAt = DateTime.Now;
                            if (attemptData.ContainsKey("completedAt"))
                            {
                                completedAt = SafeParseDateTime(attemptData["completedAt"], DateTime.Now);
                            }

                            allAttempts.Add(new
                            {
                                LessonName = lessonName,
                                TopicName = topicDisplayName,
                                Score = score,
                                AttemptNumber = attemptNumber,
                                CompletedAt = completedAt,
                                CompletedAtFormatted = FormatFullDateTime(completedAt),
                                ScoreText = $"{score}%",
                                ScoreClass = GetScoreClass(score),
                                SortKey = completedAt.Ticks
                            });

                            System.Diagnostics.Debug.WriteLine($"✅ Added attempt: {lessonName} - {score}% on {FormatFullDateTime(completedAt)}");
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"📊 Total attempts collected: {allAttempts.Count}");

                if (allAttempts.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("⚠️ No attempts found in user progress structure");

                    rptRecentActivity.DataSource = new List<object>();
                    rptRecentActivity.DataBind();

                    hfChartData.Value = JsonConvert.SerializeObject(new { labels = new string[0], scores = new int[0] });
                    return;
                }

                var sortedAttempts = allAttempts
                    .OrderByDescending(a => a.SortKey)
                    .Take(20)
                    .ToList();

                System.Diagnostics.Debug.WriteLine($"📋 Showing {sortedAttempts.Count} recent activities");

                var recentActivity = sortedAttempts.Select(a => new
                {
                    LessonName = a.LessonName,
                    TopicName = a.TopicName,
                    Score = a.Score,
                    ScoreText = a.ScoreText,
                    ScoreClass = a.ScoreClass,
                    CompletedAt = a.CompletedAtFormatted
                }).ToList();

                var chartAttempts = allAttempts
                    .OrderBy(a => a.SortKey)
                    .ToList();

                var chartLabels = new List<string>();
                var chartScores = new List<int>();

                System.Diagnostics.Debug.WriteLine($"📈 Preparing chart data for {chartAttempts.Count} attempts");

                for (int i = 0; i < chartAttempts.Count; i++)
                {
                    chartLabels.Add($"Quiz {i + 1}");
                    chartScores.Add(chartAttempts[i].Score);

                    System.Diagnostics.Debug.WriteLine($"Chart point {i + 1}: {chartAttempts[i].LessonName} = {chartAttempts[i].Score}%");
                }

                rptRecentActivity.DataSource = recentActivity;
                rptRecentActivity.DataBind();

                System.Diagnostics.Debug.WriteLine($"✅ Bound {recentActivity.Count} recent activities to repeater");

                var chartData = new
                {
                    labels = chartLabels.ToArray(),
                    scores = chartScores.ToArray()
                };

                hfChartData.Value = JsonConvert.SerializeObject(chartData);

                System.Diagnostics.Debug.WriteLine($"📈 Chart data prepared with {chartLabels.Count} data points");
                System.Diagnostics.Debug.WriteLine($"Chart labels: [{string.Join(", ", chartLabels)}]");
                System.Diagnostics.Debug.WriteLine($"Chart scores: [{string.Join(", ", chartScores)}]");

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ Error loading recent activity from user progress: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
            }
        }

        private string GetScoreClass(int score)
        {
            if (score >= 90) return "score-excellent";
            if (score >= 80) return "score-good";
            if (score >= 70) return "score-average";
            if (score >= 60) return "score-below-average";
            return "score-poor";
        }

        protected void btnBackToLanguages_Click(object sender, EventArgs e)
        {
            Response.Redirect("Language.aspx");
        }

        private void ShowErrorMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                $"alert('{message}');", true);
        }
    }

    public class AttemptData
    {
        public int Score { get; set; }
    }
}