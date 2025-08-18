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

            // No demo users - require real authentication
            if (string.IsNullOrEmpty(currentUserId))
            {
                Response.Redirect("Login.aspx"); // Redirect to your login page
                return;
            }

            if (!IsPostBack)
            {
                await LoadAvailableLanguages();

                // Check if languageId is passed in URL
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
            // REMOVED DEMO USER - Only real authenticated users
            return Session["UserId"]?.ToString();
        }

        private async System.Threading.Tasks.Task LoadAvailableLanguages()
        {
            try
            {
                // Get languages that the user has progress in from user progress structure
                CollectionReference progressRef = db.Collection("users").Document(currentUserId).Collection("progress");
                QuerySnapshot progressSnapshot = await progressRef.GetSnapshotAsync();

                ddlLanguages.Items.Clear();
                ddlLanguages.Items.Add(new ListItem("-- Select a Language --", ""));

                foreach (DocumentSnapshot progressDoc in progressSnapshot.Documents)
                {
                    string languageId = progressDoc.Id;

                    // Get language details
                    DocumentSnapshot languageDoc = await db.Collection("languages").Document(languageId).GetSnapshotAsync();
                    if (languageDoc.Exists)
                    {
                        var languageData = languageDoc.ToDictionary();
                        string languageName = languageData.ContainsKey("Name") ? languageData["Name"].ToString() : languageId;
                        ddlLanguages.Items.Add(new ListItem(languageName, languageId));
                    }
                    else
                    {
                        // Add with ID as name if language doc doesn't exist
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
                // Get user's progress for this language from user progress structure
                DocumentReference languageProgressRef = db.Collection("users")
                    .Document(currentUserId)
                    .Collection("progress")
                    .Document(languageId);

                DocumentSnapshot languageProgressSnap = await languageProgressRef.GetSnapshotAsync();

                if (languageProgressSnap.Exists)
                {
                    var progressData = languageProgressSnap.ToDictionary();

                    // Load overall statistics from user progress
                    lblTotalAttempts.Text = progressData.ContainsKey("totalAttempts") ? progressData["totalAttempts"].ToString() : "0";
                    lblCompletedLessons.Text = progressData.ContainsKey("completedLessons") ? progressData["completedLessons"].ToString() : "0";
                    lblAverageScore.Text = progressData.ContainsKey("averageScore") ? Math.Round(Convert.ToDouble(progressData["averageScore"]), 1).ToString() : "0";
                    lblCurrentStreak.Text = progressData.ContainsKey("currentStreak") ? progressData["currentStreak"].ToString() : "0";

                    double totalMinutes = progressData.ContainsKey("totalTimeSpent") ? Convert.ToDouble(progressData["totalTimeSpent"]) : 0;
                    lblTotalTime.Text = Math.Round(totalMinutes, 1).ToString();

                    // Load topic progress from user progress structure
                    await LoadTopicProgress(languageId);

                    // Load recent activity and chart data from user progress structure
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

                    double progress = lessonsInTopic > 0 ? Math.Round((double)completedLessons / lessonsInTopic * 100, 1) : 0;

                    topicProgressList.Add(new
                    {
                        TopicName = topicName,
                        TotalLessons = lessonsInTopic,
                        CompletedLessons = completedLessons,
                        Progress = progress
                    });
                }

                rptTopicProgress.DataSource = topicProgressList;
                rptTopicProgress.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading topic progress: {ex.Message}");
            }
        }

        private async System.Threading.Tasks.Task LoadRecentActivityAndChartData(string languageId)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"🔍 Loading recent activity from user progress structure for language: {languageId}");

                var allAttempts = new List<dynamic>();

                // Get all topics for this language from user progress
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

                    // Get all lessons for this topic
                    CollectionReference lessonsRef = topicDoc.Reference.Collection("lessons");
                    QuerySnapshot lessonsSnapshot = await lessonsRef.GetSnapshotAsync();

                    System.Diagnostics.Debug.WriteLine($"📖 Topic '{topicDisplayName}' has {lessonsSnapshot.Documents.Count} lessons");

                    foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                    {
                        string lessonId = lessonDoc.Id;
                        var lessonData = lessonDoc.ToDictionary();
                        string lessonName = lessonData.ContainsKey("lessonName") ? lessonData["lessonName"].ToString() : lessonId;

                        // Get all attempts for this lesson
                        CollectionReference attemptsRef = lessonDoc.Reference.Collection("attempts");
                        QuerySnapshot attemptsSnapshot = await attemptsRef.GetSnapshotAsync();

                        System.Diagnostics.Debug.WriteLine($"🎯 Lesson '{lessonName}' has {attemptsSnapshot.Documents.Count} attempts");

                        foreach (DocumentSnapshot attemptDoc in attemptsSnapshot.Documents)
                        {
                            var attemptData = attemptDoc.ToDictionary();

                            // Extract attempt information
                            int score = attemptData.ContainsKey("score") ? Convert.ToInt32(attemptData["score"]) : 0;
                            int attemptNumber = attemptData.ContainsKey("attemptNumber") ? Convert.ToInt32(attemptData["attemptNumber"]) : 1;

                            DateTime completedAt = DateTime.Now;
                            if (attemptData.ContainsKey("completedAt"))
                            {
                                if (attemptData["completedAt"] is Timestamp timestamp)
                                    completedAt = timestamp.ToDateTime();
                                else if (DateTime.TryParse(attemptData["completedAt"].ToString(), out DateTime parsedDate))
                                    completedAt = parsedDate;
                            }

                            // Create attempt object
                            allAttempts.Add(new
                            {
                                LessonName = lessonName,
                                TopicName = topicDisplayName,
                                Score = score,
                                AttemptNumber = attemptNumber,
                                CompletedAt = completedAt,
                                CompletedAtFormatted = completedAt.ToString("MMM dd, yyyy HH:mm"),
                                // Add sorting keys
                                SortKey = completedAt.Ticks
                            });

                            System.Diagnostics.Debug.WriteLine($"✅ Added attempt: {lessonName} - {score}% on {completedAt:MMM dd HH:mm}");
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"📊 Total attempts collected: {allAttempts.Count}");

                if (allAttempts.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("⚠️ No attempts found in user progress structure");

                    // Set empty data
                    rptRecentActivity.DataSource = new List<object>();
                    rptRecentActivity.DataBind();

                    hfChartData.Value = JsonConvert.SerializeObject(new { labels = new string[0], scores = new int[0] });
                    return;
                }

                // Sort all attempts by date (most recent first) for recent activity
                var sortedAttempts = allAttempts
                    .OrderByDescending(a => a.SortKey)
                    .Take(20) // Limit to last 20 attempts for recent activity
                    .ToList();

                System.Diagnostics.Debug.WriteLine($"📋 Showing {sortedAttempts.Count} recent activities");

                // Prepare recent activity data
                var recentActivity = sortedAttempts.Select(a => new
                {
                    LessonName = a.LessonName,
                    TopicName = a.TopicName,
                    Score = a.Score,
                    CompletedAt = a.CompletedAtFormatted
                }).ToList();

                // FIXED: Prepare chart data (chronological order for graph, ALL attempts)
                var chartAttempts = allAttempts
                    .OrderBy(a => a.SortKey) // Chronological order (oldest first)
                    .ToList();

                var chartLabels = new List<string>();
                var chartScores = new List<int>();

                System.Diagnostics.Debug.WriteLine($"📈 Preparing chart data for {chartAttempts.Count} attempts");

                // Add ALL attempts to chart (not just recent ones)
                for (int i = 0; i < chartAttempts.Count; i++)
                {
                    chartLabels.Add($"Quiz {i + 1}");
                    chartScores.Add(chartAttempts[i].Score);

                    System.Diagnostics.Debug.WriteLine($"Chart point {i + 1}: {chartAttempts[i].LessonName} = {chartAttempts[i].Score}%");
                }

                // Bind to UI
                rptRecentActivity.DataSource = recentActivity;
                rptRecentActivity.DataBind();

                System.Diagnostics.Debug.WriteLine($"✅ Bound {recentActivity.Count} recent activities to repeater");

                // Prepare chart data
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
}