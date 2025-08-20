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

        // Cache for user lookups to avoid repeated database calls
        private static Dictionary<string, UserInfo> userCache = new Dictionary<string, UserInfo>();

        // User info class to store user details
        public class UserInfo
        {
            public string UserId { get; set; }
            public string Username { get; set; }
            public string Email { get; set; }
            public string DisplayName => !string.IsNullOrEmpty(Username) ? Username :
                                       (!string.IsNullOrEmpty(Email) ? Email.Split('@')[0] : $"User {UserId?.Substring(0, Math.Min(8, UserId?.Length ?? 0))}");
        }

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

        // NEW: Method to fetch user details from users collection
        private async System.Threading.Tasks.Task<UserInfo> GetUserDetailsAsync(string userId)
        {
            try
            {
                // Check cache first
                if (userCache.ContainsKey(userId))
                {
                    System.Diagnostics.Debug.WriteLine($"📋 Using cached user data for: {userId}");
                    return userCache[userId];
                }

                // Query users collection
                DocumentReference userDoc = db.Collection("users").Document(userId);
                DocumentSnapshot userSnapshot = await userDoc.GetSnapshotAsync();

                UserInfo userInfo = new UserInfo { UserId = userId };

                if (userSnapshot.Exists)
                {
                    var userData = userSnapshot.ToDictionary();

                    // Extract username - adjust field names based on your Firestore structure
                    if (userData.ContainsKey("username") && userData["username"] != null)
                    {
                        userInfo.Username = userData["username"].ToString().Trim();
                    }

                    // Extract email - adjust field names based on your Firestore structure
                    if (userData.ContainsKey("email") && userData["email"] != null)
                    {
                        userInfo.Email = userData["email"].ToString().Trim();
                    }

                    System.Diagnostics.Debug.WriteLine($"✅ Found user in database: {userInfo.DisplayName}");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"⚠️ User not found in database: {userId}");
                }

                // Cache the result (even if user not found)
                userCache[userId] = userInfo;

                return userInfo;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error fetching user details for {userId}: {ex.Message}");

                // Return basic user info on error
                var fallbackUser = new UserInfo { UserId = userId };
                userCache[userId] = fallbackUser;
                return fallbackUser;
            }
        }

        // NEW: Method to batch fetch multiple users efficiently
        private async System.Threading.Tasks.Task<Dictionary<string, UserInfo>> GetMultipleUsersAsync(List<string> userIds)
        {
            var result = new Dictionary<string, UserInfo>();
            var uncachedUserIds = new List<string>();

            // Check cache first
            foreach (string userId in userIds.Distinct())
            {
                if (userCache.ContainsKey(userId))
                {
                    result[userId] = userCache[userId];
                }
                else
                {
                    uncachedUserIds.Add(userId);
                }
            }

            // Fetch uncached users in batches
            if (uncachedUserIds.Count > 0)
            {
                System.Diagnostics.Debug.WriteLine($"🔍 Fetching {uncachedUserIds.Count} users from database");

                // Firestore supports batch reads of up to 10 documents
                for (int i = 0; i < uncachedUserIds.Count; i += 10)
                {
                    var batchIds = uncachedUserIds.Skip(i).Take(10).ToList();
                    await FetchUserBatch(batchIds, result);
                }
            }

            return result;
        }

        private async System.Threading.Tasks.Task FetchUserBatch(List<string> userIds, Dictionary<string, UserInfo> result)
        {
            try
            {
                var tasks = userIds.Select(async userId =>
                {
                    DocumentReference userDoc = db.Collection("users").Document(userId);
                    DocumentSnapshot userSnapshot = await userDoc.GetSnapshotAsync();

                    UserInfo userInfo = new UserInfo { UserId = userId };

                    if (userSnapshot.Exists)
                    {
                        var userData = userSnapshot.ToDictionary();

                        if (userData.ContainsKey("username") && userData["username"] != null)
                        {
                            userInfo.Username = userData["username"].ToString().Trim();
                        }

                        if (userData.ContainsKey("email") && userData["email"] != null)
                        {
                            userInfo.Email = userData["email"].ToString().Trim();
                        }
                    }

                    // Cache and return
                    userCache[userId] = userInfo;
                    return new { UserId = userId, UserInfo = userInfo };
                });

                var batchResults = await System.Threading.Tasks.Task.WhenAll(tasks);

                foreach (var item in batchResults)
                {
                    result[item.UserId] = item.UserInfo;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in batch user fetch: {ex.Message}");
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

                // Load recent activity with user lookup
                await LoadRecentActivityAsync(results);

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

        // UPDATED: LoadRecentActivity method with proper user lookup
        private async System.Threading.Tasks.Task LoadRecentActivityAsync(List<Dictionary<string, object>> results)
        {
            try
            {
                var recentResults = results
                    .OrderByDescending(r => ((Timestamp)r["completedAt"]).ToDateTime())
                    .Take(20)
                    .ToList();

                if (recentResults.Count == 0)
                {
                    rptRecentActivity.Visible = false;
                    System.Diagnostics.Debug.WriteLine("⚠️ No recent activity records found");
                    return;
                }

                // Get all unique user IDs
                var userIds = recentResults.Select(r => r["userId"].ToString()).Distinct().ToList();
                System.Diagnostics.Debug.WriteLine($"🔍 Looking up {userIds.Count} unique users for recent activity");

                // Batch fetch user details
                var userLookup = await GetMultipleUsersAsync(userIds);

                // Build activity data with proper user names
                var recentActivity = recentResults.Select(r =>
                {
                    string userId = r["userId"].ToString();
                    UserInfo userInfo = userLookup.ContainsKey(userId) ? userLookup[userId] : new UserInfo { UserId = userId };

                    return new
                    {
                        UserName = userInfo.DisplayName,
                        UserId = userId,
                        LanguageName = r["languageName"].ToString(),
                        TopicName = r["topicName"].ToString(),
                        LessonName = r["lessonName"].ToString(),
                        Score = Convert.ToInt32(r["score"]),
                        TimeSpent = Math.Round(Convert.ToDouble(r["timeSpentSeconds"]) / 60.0, 1),
                        CompletedAt = ((Timestamp)r["completedAt"]).ToDateTime().ToString("MMM dd, HH:mm")
                    };
                }).ToList();

                rptRecentActivity.DataSource = recentActivity;
                rptRecentActivity.DataBind();
                rptRecentActivity.Visible = true;

                System.Diagnostics.Debug.WriteLine($"✅ Loaded {recentActivity.Count} recent activity records with proper user lookups");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading recent activity: {ex.Message}");
                rptRecentActivity.Visible = false;
            }
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

        // NEW: Method to clear user cache if needed (call this periodically or when users are updated)
        protected void ClearUserCache()
        {
            lock (dbLock)
            {
                userCache.Clear();
                System.Diagnostics.Debug.WriteLine("🗑️ User cache cleared");
            }
        }
    }
}