using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;
using Newtonsoft.Json;

namespace INTFYP
{
    public partial class LanguageReports : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
            {
                await LoadFilters();
                await LoadLanguageAnalytics();
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

        private async System.Threading.Tasks.Task LoadFilters()
        {
            try
            {
                // Load available languages from languageResults
                Query languagesQuery = db.Collection("languageResults");
                QuerySnapshot languagesSnapshot = await languagesQuery.GetSnapshotAsync();

                var uniqueLanguages = languagesSnapshot.Documents
                    .Select(doc => new {
                        Id = doc.ToDictionary()["languageId"].ToString(),
                        Name = doc.ToDictionary()["languageName"].ToString()
                    })
                    .GroupBy(l => l.Id)
                    .Select(g => g.First())
                    .OrderBy(l => l.Name)
                    .ToList();

                ddlLanguageFilter.Items.Clear();
                ddlLanguageFilter.Items.Add(new ListItem("All Languages", ""));

                foreach (var lang in uniqueLanguages)
                {
                    ddlLanguageFilter.Items.Add(new ListItem(lang.Name, lang.Id));
                }

                // Load topics for selected language
                await LoadTopicsForLanguage("");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading filters: {ex.Message}");
            }
        }

        private async System.Threading.Tasks.Task LoadTopicsForLanguage(string languageId)
        {
            try
            {
                ddlTopicFilter.Items.Clear();
                ddlTopicFilter.Items.Add(new ListItem("All Topics", ""));

                if (!string.IsNullOrEmpty(languageId))
                {
                    Query topicsQuery = db.Collection("languageResults")
                        .WhereEqualTo("languageId", languageId);

                    QuerySnapshot topicsSnapshot = await topicsQuery.GetSnapshotAsync();

                    var uniqueTopics = topicsSnapshot.Documents
                        .Select(doc => doc.ToDictionary()["topicName"].ToString())
                        .Distinct()
                        .OrderBy(t => t)
                        .ToList();

                    foreach (var topic in uniqueTopics)
                    {
                        ddlTopicFilter.Items.Add(new ListItem(topic, topic));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading topics: {ex.Message}");
            }
        }

        protected async void ddlLanguageFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadTopicsForLanguage(ddlLanguageFilter.SelectedValue);
            await LoadLanguageAnalytics();
        }

        protected async void ApplyFilters(object sender, EventArgs e)
        {
            await LoadLanguageAnalytics();
        }

        private async System.Threading.Tasks.Task LoadLanguageAnalytics()
        {
            try
            {
                // Build query based on filters
                Query baseQuery = db.Collection("languageResults");

                // Apply language filter
                if (!string.IsNullOrEmpty(ddlLanguageFilter.SelectedValue))
                {
                    baseQuery = baseQuery.WhereEqualTo("languageId", ddlLanguageFilter.SelectedValue);
                }

                // Apply date filter
                int daysBack = Convert.ToInt32(ddlDateRange.SelectedValue);
                if (daysBack > 0)
                {
                    DateTime cutoffDate = DateTime.Now.AddDays(-daysBack);
                    Timestamp cutoffTimestamp = Timestamp.FromDateTime(cutoffDate.ToUniversalTime());
                    baseQuery = baseQuery.WhereGreaterThanOrEqualTo("completedAt", cutoffTimestamp);
                }

                QuerySnapshot snapshot = await baseQuery.GetSnapshotAsync();

                if (snapshot.Documents.Count == 0)
                {
                    pnlNoData.Visible = true;
                    return;
                }

                pnlNoData.Visible = false;

                // Filter by topic if selected
                var filteredResults = snapshot.Documents.AsEnumerable();
                if (!string.IsNullOrEmpty(ddlTopicFilter.SelectedValue))
                {
                    filteredResults = filteredResults.Where(doc =>
                        doc.ToDictionary()["topicName"].ToString() == ddlTopicFilter.SelectedValue);
                }

                var results = filteredResults.Select(doc => doc.ToDictionary()).ToList();

                // Calculate overall statistics
                await CalculateOverallStats(results);

                // Load language performance
                await LoadLanguagePerformance(results);

                // Load recent activity
                LoadRecentActivity(results);

                // Generate chart data
                GenerateChartData(results);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading language analytics: {ex.Message}");
                ShowErrorMessage("Error loading analytics data.");
            }
        }

        private async System.Threading.Tasks.Task CalculateOverallStats(List<Dictionary<string, object>> results)
        {
            try
            {
                if (results.Count == 0) return;

                // Unique students
                int uniqueStudents = results.Select(r => r["userId"].ToString()).Distinct().Count();
                lblTotalStudents.Text = uniqueStudents.ToString();

                // Total attempts
                lblTotalAttempts.Text = results.Count.ToString();

                // Average score
                double avgScore = results.Average(r => Convert.ToDouble(r["score"]));
                lblAverageScore.Text = Math.Round(avgScore, 1).ToString();

                // Pass rate (≥70%)
                int passedAttempts = results.Count(r => Convert.ToInt32(r["score"]) >= 70);
                double passRate = (double)passedAttempts / results.Count * 100;
                lblPassRate.Text = Math.Round(passRate, 1).ToString();

                // Total languages
                int uniqueLanguages = results.Select(r => r["languageId"].ToString()).Distinct().Count();
                lblTotalLanguages.Text = uniqueLanguages.ToString();

                // Average time spent
                double avgTime = results.Average(r => Convert.ToDouble(r["timeSpentSeconds"])) / 60.0;
                lblAvgTimeSpent.Text = Math.Round(avgTime, 1).ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error calculating overall stats: {ex.Message}");
            }
        }

        private async System.Threading.Tasks.Task LoadLanguagePerformance(List<Dictionary<string, object>> results)
        {
            try
            {
                var languageStats = results
                    .GroupBy(r => r["languageId"].ToString())
                    .Select(g => new
                    {
                        LanguageId = g.Key,
                        LanguageName = g.First()["languageName"].ToString(),
                        StudentCount = g.Select(r => r["userId"].ToString()).Distinct().Count(),
                        TotalAttempts = g.Count(),
                        AverageScore = g.Average(r => Convert.ToDouble(r["score"])),
                        PassRate = (double)g.Count(r => Convert.ToInt32(r["score"]) >= 70) / g.Count() * 100,
                        MostPopularTopic = g.GroupBy(r => r["topicName"].ToString())
                                           .OrderByDescending(tg => tg.Count())
                                           .First().Key
                    })
                    .OrderByDescending(l => l.TotalAttempts)
                    .ToList();

                rptLanguageStats.DataSource = languageStats;
                rptLanguageStats.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading language performance: {ex.Message}");
            }
        }

        // UPDATED: LoadRecentActivity method to show student names
        private void LoadRecentActivity(List<Dictionary<string, object>> results)
        {
            try
            {
                var recentActivity = results
                    .OrderByDescending(r => ((Timestamp)r["completedAt"]).ToDateTime())
                    .Take(20)
                    .Select(r => new
                    {
                        // Use userName if available, fallback to userId for older records
                        UserName = GetUserNameFromResult(r),
                        UserId = r["userId"].ToString(), // Keep for reference if needed
                        LanguageName = r["languageName"].ToString(),
                        TopicName = r["topicName"].ToString(),
                        LessonName = r["lessonName"].ToString(),
                        Score = Convert.ToInt32(r["score"]),
                        TimeSpent = Math.Round(Convert.ToDouble(r["timeSpentSeconds"]) / 60.0, 1),
                        CompletedAt = ((Timestamp)r["completedAt"]).ToDateTime().ToString("MMM dd, HH:mm")
                    })
                    .ToList();

                // Check if we have any recent activity
                if (recentActivity.Count > 0)
                {
                    rptRecentActivity.DataSource = recentActivity;
                    rptRecentActivity.DataBind();
                    rptRecentActivity.Visible = true;

                    System.Diagnostics.Debug.WriteLine($"✅ Loaded {recentActivity.Count} recent activity records with student names");
                }
                else
                {
                    // No recent activity found
                    rptRecentActivity.Visible = false;
                    System.Diagnostics.Debug.WriteLine("⚠️ No recent activity records found");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading recent activity: {ex.Message}");

                // Hide repeater on error
                rptRecentActivity.Visible = false;
            }
        }

        // NEW: Helper method to get user name with intelligent fallbacks
        private string GetUserNameFromResult(Dictionary<string, object> result)
        {
            try
            {
                // First try to get userName (from newer records saved by TakeQuiz)
                if (result.ContainsKey("userName") && result["userName"] != null)
                {
                    string userName = result["userName"].ToString().Trim();
                    if (!string.IsNullOrEmpty(userName) && userName != "Guest User" && userName != "null")
                    {
                        System.Diagnostics.Debug.WriteLine($"📝 Found userName: {userName}");
                        return userName;
                    }
                }

                // Fallback: try to get userEmail (from newer records)
                if (result.ContainsKey("userEmail") && result["userEmail"] != null)
                {
                    string userEmail = result["userEmail"].ToString().Trim();
                    if (!string.IsNullOrEmpty(userEmail) && userEmail != "null")
                    {
                        // Extract name part from email (before @)
                        string emailName = userEmail.Split('@')[0];
                        string formattedName = emailName.Replace(".", " ").Replace("_", " ");
                        System.Diagnostics.Debug.WriteLine($"📧 Using email-based name: {formattedName}");
                        return CapitalizeWords(formattedName);
                    }
                }

                // Final fallback: format userId for display
                if (result.ContainsKey("userId") && result["userId"] != null)
                {
                    string userId = result["userId"].ToString();

                    // If it's a demo user ID, make it more readable
                    if (userId.StartsWith("DEMO_"))
                    {
                        System.Diagnostics.Debug.WriteLine("🎭 Using Demo User for demo ID");
                        return "Demo User";
                    }

                    // If it's an email used as ID, extract the name part
                    if (userId.Contains("@"))
                    {
                        string emailName = userId.Split('@')[0];
                        string formattedName = emailName.Replace(".", " ").Replace("_", " ");
                        System.Diagnostics.Debug.WriteLine($"🔗 Using userId as email name: {formattedName}");
                        return CapitalizeWords(formattedName);
                    }

                    // Return shortened userId for display
                    string shortId = userId.Length > 8 ? userId.Substring(0, 8) : userId;
                    System.Diagnostics.Debug.WriteLine($"🆔 Using shortened userId: User {shortId}");
                    return $"User {shortId}";
                }

                System.Diagnostics.Debug.WriteLine("❓ No valid user identifier found");
                return "Unknown User";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting user name: {ex.Message}");
                return "Unknown User";
            }
        }

        // NEW: Helper method to capitalize words properly
        private string CapitalizeWords(string input)
        {
            if (string.IsNullOrEmpty(input))
                return input;

            var words = input.Split(' ');
            for (int i = 0; i < words.Length; i++)
            {
                if (!string.IsNullOrEmpty(words[i]))
                {
                    words[i] = char.ToUpper(words[i][0]) + words[i].Substring(1).ToLower();
                }
            }
            return string.Join(" ", words);
        }

        private void GenerateChartData(List<Dictionary<string, object>> results)
        {
            try
            {
                // Score Distribution Data
                var scoreRanges = new int[5]; // 90-100, 80-89, 70-79, 60-69, <60

                foreach (var result in results)
                {
                    int score = Convert.ToInt32(result["score"]);
                    if (score >= 90) scoreRanges[0]++;
                    else if (score >= 80) scoreRanges[1]++;
                    else if (score >= 70) scoreRanges[2]++;
                    else if (score >= 60) scoreRanges[3]++;
                    else scoreRanges[4]++;
                }

                hfScoreDistributionData.Value = JsonConvert.SerializeObject(scoreRanges);

                // Daily Activity Data (last 7 days)
                var dailyActivity = new Dictionary<string, int>();
                for (int i = 6; i >= 0; i--)
                {
                    DateTime date = DateTime.Now.AddDays(-i);
                    dailyActivity[date.ToString("MMM dd")] = 0;
                }

                foreach (var result in results)
                {
                    DateTime completedDate = ((Timestamp)result["completedAt"]).ToDateTime();
                    string dateKey = completedDate.ToString("MMM dd");

                    if (dailyActivity.ContainsKey(dateKey))
                    {
                        dailyActivity[dateKey]++;
                    }
                }

                var activityData = new
                {
                    labels = dailyActivity.Keys.ToArray(),
                    attempts = dailyActivity.Values.ToArray()
                };

                hfDailyActivityData.Value = JsonConvert.SerializeObject(activityData);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating chart data: {ex.Message}");
            }
        }

        protected string GetScoreClass(double score)
        {
            if (score >= 90) return "score-excellent";
            if (score >= 80) return "score-good";
            if (score >= 70) return "score-average";
            if (score >= 60) return "score-average";
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
}