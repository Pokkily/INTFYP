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

        private static Dictionary<string, UserInfo> userCache = new Dictionary<string, UserInfo>();

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
            try
            {
                InitializeFirestore();

                if (!IsPostBack)
                {
                    await LoadFilters();
                    await LoadLanguageAnalytics();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Page_Load Error: {ex.Message}");
                ShowErrorMessage("Error loading page. Please refresh and try again.");
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
                        try
                        {
                            string path = Server.MapPath("~/serviceAccountKey.json");
                            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                            db = FirestoreDb.Create("intorannetto");
                            System.Diagnostics.Debug.WriteLine("Firestore initialized successfully");
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Firestore initialization error: {ex.Message}");
                            throw new Exception("Failed to initialize database connection", ex);
                        }
                    }
                }
            }
        }

        private static T GetFieldValue<T>(Dictionary<string, object> doc, string fieldName, T defaultValue = default(T))
        {
            try
            {
                if (doc.ContainsKey(fieldName) && doc[fieldName] != null)
                {
                    if (typeof(T) == typeof(string))
                    {
                        return (T)(object)doc[fieldName].ToString();
                    }
                    else if (typeof(T) == typeof(int))
                    {
                        return (T)(object)Convert.ToInt32(doc[fieldName]);
                    }
                    else if (typeof(T) == typeof(double))
                    {
                        return (T)(object)Convert.ToDouble(doc[fieldName]);
                    }
                    else if (typeof(T) == typeof(DateTime))
                    {
                        if (doc[fieldName] is Timestamp timestamp)
                        {
                            return (T)(object)timestamp.ToDateTime();
                        }
                    }
                    else if (typeof(T) == typeof(Timestamp))
                    {
                        if (doc[fieldName] is Timestamp timestamp)
                        {
                            return (T)(object)timestamp;
                        }
                    }
                    return (T)doc[fieldName];
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting field {fieldName}: {ex.Message}");
            }
            return defaultValue;
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

        private async System.Threading.Tasks.Task<UserInfo> GetUserDetailsAsync(string userId)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    return new UserInfo { UserId = userId };
                }

                if (userCache.ContainsKey(userId))
                {
                    return userCache[userId];
                }

                DocumentReference userDoc = db.Collection("users").Document(userId);
                DocumentSnapshot userSnapshot = await userDoc.GetSnapshotAsync();

                UserInfo userInfo = new UserInfo { UserId = userId };

                if (userSnapshot.Exists)
                {
                    var userData = userSnapshot.ToDictionary();
                    userInfo.Username = GetFieldValue(userData, "username", "");
                    userInfo.Email = GetFieldValue(userData, "email", "");
                }

                userCache[userId] = userInfo;
                return userInfo;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error fetching user details for {userId}: {ex.Message}");
                var fallbackUser = new UserInfo { UserId = userId };
                userCache[userId] = fallbackUser;
                return fallbackUser;
            }
        }

        private async System.Threading.Tasks.Task<Dictionary<string, UserInfo>> GetMultipleUsersAsync(List<string> userIds)
        {
            var result = new Dictionary<string, UserInfo>();
            var uncachedUserIds = new List<string>();

            try
            {
                foreach (string userId in userIds.Distinct().Where(id => !string.IsNullOrEmpty(id)))
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

                if (uncachedUserIds.Count > 0)
                {
                    for (int i = 0; i < uncachedUserIds.Count; i += 10)
                    {
                        var batchIds = uncachedUserIds.Skip(i).Take(10).ToList();
                        await FetchUserBatch(batchIds, result);
                    }
                }

                return result;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in GetMultipleUsersAsync: {ex.Message}");
                return result;
            }
        }

        private async System.Threading.Tasks.Task FetchUserBatch(List<string> userIds, Dictionary<string, UserInfo> result)
        {
            try
            {
                var tasks = userIds.Select(async userId =>
                {
                    try
                    {
                        DocumentReference userDoc = db.Collection("users").Document(userId);
                        DocumentSnapshot userSnapshot = await userDoc.GetSnapshotAsync();

                        UserInfo userInfo = new UserInfo { UserId = userId };

                        if (userSnapshot.Exists)
                        {
                            var userData = userSnapshot.ToDictionary();
                            userInfo.Username = GetFieldValue(userData, "username", "");
                            userInfo.Email = GetFieldValue(userData, "email", "");
                        }

                        userCache[userId] = userInfo;
                        return new { UserId = userId, UserInfo = userInfo };
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error fetching user {userId}: {ex.Message}");
                        var fallbackUser = new UserInfo { UserId = userId };
                        userCache[userId] = fallbackUser;
                        return new { UserId = userId, UserInfo = fallbackUser };
                    }
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
                System.Diagnostics.Debug.WriteLine("Loading filters...");

                ddlLanguageFilter.Items.Clear();
                ddlLanguageFilter.Items.Add(new ListItem("All Languages", ""));

                Query languagesQuery = db.Collection("languageResults").Limit(1000);
                QuerySnapshot languagesSnapshot = await languagesQuery.GetSnapshotAsync();

                System.Diagnostics.Debug.WriteLine($"Found {languagesSnapshot.Documents.Count} language result documents");

                var uniqueLanguages = new Dictionary<string, string>();

                foreach (var doc in languagesSnapshot.Documents)
                {
                    var data = doc.ToDictionary();

                    string languageId = GetFieldValue(data, "languageId", "");
                    string languageName = GetFieldValue(data, "languageName", "");

                    if (!string.IsNullOrEmpty(languageId) && !string.IsNullOrEmpty(languageName))
                    {
                        if (!uniqueLanguages.ContainsKey(languageId))
                        {
                            uniqueLanguages[languageId] = languageName;
                        }
                    }
                }

                foreach (var lang in uniqueLanguages.OrderBy(l => l.Value))
                {
                    ddlLanguageFilter.Items.Add(new ListItem(lang.Value, lang.Key));
                }

                System.Diagnostics.Debug.WriteLine($"Added {uniqueLanguages.Count} unique languages to filter");

                await LoadTopicsForLanguage("");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading filters: {ex.Message}");
                ShowErrorMessage("Error loading filter options. Please refresh the page.");
            }
        }

        private async System.Threading.Tasks.Task LoadTopicsForLanguage(string languageId)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"Loading topics for language: {languageId}");

                ddlTopicFilter.Items.Clear();
                ddlTopicFilter.Items.Add(new ListItem("All Topics", ""));

                Query topicsQuery = db.Collection("languageResults").Limit(1000);

                QuerySnapshot topicsSnapshot = await topicsQuery.GetSnapshotAsync();

                var uniqueTopics = new HashSet<string>();

                foreach (var doc in topicsSnapshot.Documents)
                {
                    var data = doc.ToDictionary();

                    if (!string.IsNullOrEmpty(languageId))
                    {
                        string docLanguageId = GetFieldValue(data, "languageId", "");
                        if (docLanguageId != languageId)
                        {
                            continue;
                        }
                    }

                    string topicName = GetFieldValue(data, "topicName", "");

                    if (!string.IsNullOrEmpty(topicName))
                    {
                        uniqueTopics.Add(topicName);
                    }
                }

                foreach (var topic in uniqueTopics.OrderBy(t => t))
                {
                    ddlTopicFilter.Items.Add(new ListItem(topic, topic));
                }

                System.Diagnostics.Debug.WriteLine($"Added {uniqueTopics.Count} unique topics to filter");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading topics: {ex.Message}");
            }
        }

        protected async void ddlLanguageFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                await LoadTopicsForLanguage(ddlLanguageFilter.SelectedValue);
                await LoadLanguageAnalytics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Language filter error: {ex.Message}");
                ShowErrorMessage("Error applying language filter.");
            }
        }

        protected async void ApplyFilters(object sender, EventArgs e)
        {
            try
            {
                await LoadLanguageAnalytics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Apply filters error: {ex.Message}");
                ShowErrorMessage("Error applying filters.");
            }
        }

        private async System.Threading.Tasks.Task LoadLanguageAnalytics()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("Loading language analytics...");
                System.Diagnostics.Debug.WriteLine($"Language filter: {ddlLanguageFilter.SelectedValue}");
                System.Diagnostics.Debug.WriteLine($"Topic filter: {ddlTopicFilter.SelectedValue}");
                System.Diagnostics.Debug.WriteLine($"Date range: {ddlDateRange.SelectedValue}");

                List<Dictionary<string, object>> allResults = await GetLanguageResultsWithFallback();

                if (allResults.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("No documents found, showing no data panel");
                    pnlNoData.Visible = true;
                    ClearAllDisplays();
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"Retrieved {allResults.Count} total results");

                var filteredResults = ApplyClientSideFilters(allResults);

                System.Diagnostics.Debug.WriteLine($"Final filtered results: {filteredResults.Count}");

                if (filteredResults.Count == 0)
                {
                    pnlNoData.Visible = true;
                    ClearAllDisplays();
                    return;
                }

                pnlNoData.Visible = false;

                await CalculateOverallStats(filteredResults);
                await LoadLanguagePerformance(filteredResults);
                await LoadRecentActivityAsync(filteredResults);
                GenerateChartData(filteredResults);

                System.Diagnostics.Debug.WriteLine("Analytics loading completed successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading language analytics: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                ShowErrorMessage($"Error loading analytics data. Please try refreshing the page.");
                pnlNoData.Visible = true;
            }
        }

        private async System.Threading.Tasks.Task<List<Dictionary<string, object>>> GetLanguageResultsWithFallback()
        {
            var allResults = new List<Dictionary<string, object>>();

            try
            {
                Query baseQuery = db.Collection("languageResults");

                if (!string.IsNullOrEmpty(ddlLanguageFilter.SelectedValue))
                {
                    try
                    {
                        baseQuery = baseQuery.WhereEqualTo("languageId", ddlLanguageFilter.SelectedValue);
                        System.Diagnostics.Debug.WriteLine("Applied language filter on server-side");
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Server-side language filter failed: {ex.Message}");
                        baseQuery = db.Collection("languageResults");
                    }
                }

                try
                {
                    baseQuery = baseQuery.OrderByDescending("completedAt").Limit(5000);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"OrderBy failed, using basic query: {ex.Message}");
                    baseQuery = db.Collection("languageResults").Limit(5000);
                }

                QuerySnapshot snapshot = await baseQuery.GetSnapshotAsync();
                System.Diagnostics.Debug.WriteLine($"Retrieved {snapshot.Documents.Count} documents from Firestore");

                foreach (var doc in snapshot.Documents)
                {
                    try
                    {
                        var data = doc.ToDictionary();

                        if (data.ContainsKey("userId") && data.ContainsKey("score") &&
                            data.ContainsKey("languageId") && data.ContainsKey("languageName"))
                        {
                            allResults.Add(data);
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error processing document {doc.Id}: {ex.Message}");
                    }
                }

                System.Diagnostics.Debug.WriteLine($"Valid results after processing: {allResults.Count}");

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error retrieving language results: {ex.Message}");

                try
                {
                    System.Diagnostics.Debug.WriteLine("Attempting fallback query without filters...");
                    Query fallbackQuery = db.Collection("languageResults").Limit(1000);
                    QuerySnapshot fallbackSnapshot = await fallbackQuery.GetSnapshotAsync();

                    foreach (var doc in fallbackSnapshot.Documents)
                    {
                        try
                        {
                            var data = doc.ToDictionary();
                            if (data.ContainsKey("userId") && data.ContainsKey("score"))
                            {
                                allResults.Add(data);
                            }
                        }
                        catch (Exception docEx)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error in fallback processing: {docEx.Message}");
                        }
                    }

                    System.Diagnostics.Debug.WriteLine($"Fallback query retrieved {allResults.Count} results");
                }
                catch (Exception fallbackEx)
                {
                    System.Diagnostics.Debug.WriteLine($"Fallback query also failed: {fallbackEx.Message}");
                }
            }

            return allResults;
        }

        private List<Dictionary<string, object>> ApplyClientSideFilters(List<Dictionary<string, object>> allResults)
        {
            var filteredResults = allResults.AsEnumerable();

            try
            {
                if (!string.IsNullOrEmpty(ddlLanguageFilter.SelectedValue))
                {
                    filteredResults = filteredResults.Where(r =>
                        GetFieldValue(r, "languageId", "") == ddlLanguageFilter.SelectedValue);
                    System.Diagnostics.Debug.WriteLine("Applied client-side language filter");
                }

                if (!string.IsNullOrEmpty(ddlTopicFilter.SelectedValue))
                {
                    filteredResults = filteredResults.Where(r =>
                        GetFieldValue(r, "topicName", "") == ddlTopicFilter.SelectedValue);
                    System.Diagnostics.Debug.WriteLine("Applied client-side topic filter");
                }

                int daysBack = Convert.ToInt32(ddlDateRange.SelectedValue);
                if (daysBack > 0)
                {
                    DateTime cutoffDate = DateTime.Now.AddDays(-daysBack);
                    filteredResults = filteredResults.Where(r =>
                    {
                        try
                        {
                            Timestamp completedAt = GetFieldValue(r, "completedAt", Timestamp.GetCurrentTimestamp());
                            DateTime localCompletedAt = ConvertTimestampToLocal(completedAt);
                            return localCompletedAt >= cutoffDate;
                        }
                        catch
                        {
                            return false;
                        }
                    });
                    System.Diagnostics.Debug.WriteLine($"Applied client-side date filter: last {daysBack} days");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in client-side filtering: {ex.Message}");
                return allResults.ToList();
            }

            return filteredResults.ToList();
        }

        private void ClearAllDisplays()
        {
            lblTotalStudents.Text = "0";
            lblTotalAttempts.Text = "0";
            lblAverageScore.Text = "0";
            lblPassRate.Text = "0";
            lblTotalLanguages.Text = "0";
            lblAvgTimeSpent.Text = "0";

            rptLanguageStats.DataSource = null;
            rptLanguageStats.DataBind();
            rptRecentActivity.DataSource = null;
            rptRecentActivity.DataBind();

            hfScoreDistributionData.Value = "[0,0,0,0,0]";
            hfDailyActivityData.Value = JsonConvert.SerializeObject(new { labels = new string[0], attempts = new int[0] });
        }

        private async System.Threading.Tasks.Task CalculateOverallStats(List<Dictionary<string, object>> results)
        {
            try
            {
                if (results.Count == 0) return;

                var uniqueStudents = results.Select(r => GetFieldValue(r, "userId", "")).Where(id => !string.IsNullOrEmpty(id)).Distinct().Count();
                lblTotalStudents.Text = uniqueStudents.ToString();

                lblTotalAttempts.Text = results.Count.ToString();

                var scores = results.Select(r => GetFieldValue(r, "score", 0.0)).Where(s => s > 0).ToList();
                if (scores.Any())
                {
                    double avgScore = scores.Average();
                    lblAverageScore.Text = Math.Round(avgScore, 1).ToString();
                }
                else
                {
                    lblAverageScore.Text = "0";
                }

                if (scores.Any())
                {
                    int passedAttempts = scores.Count(s => s >= 70);
                    double passRate = (double)passedAttempts / scores.Count * 100;
                    lblPassRate.Text = Math.Round(passRate, 1).ToString();
                }
                else
                {
                    lblPassRate.Text = "0";
                }

                var uniqueLanguages = results.Select(r => GetFieldValue(r, "languageId", "")).Where(id => !string.IsNullOrEmpty(id)).Distinct().Count();
                lblTotalLanguages.Text = uniqueLanguages.ToString();

                var timeSpentValues = results.Select(r => GetFieldValue(r, "timeSpentSeconds", 0.0)).Where(t => t > 0).ToList();
                if (timeSpentValues.Any())
                {
                    double avgTime = timeSpentValues.Average() / 60.0;
                    lblAvgTimeSpent.Text = Math.Round(avgTime, 1).ToString();
                }
                else
                {
                    lblAvgTimeSpent.Text = "0";
                }

                System.Diagnostics.Debug.WriteLine($"Overall stats calculated: {uniqueStudents} students, {results.Count} attempts");
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
                    .Where(r => !string.IsNullOrEmpty(GetFieldValue(r, "languageId", "")) &&
                               !string.IsNullOrEmpty(GetFieldValue(r, "languageName", "")))
                    .GroupBy(r => GetFieldValue(r, "languageId", ""))
                    .Select(g => new
                    {
                        LanguageId = g.Key,
                        LanguageName = GetFieldValue(g.First(), "languageName", ""),
                        StudentCount = g.Select(r => GetFieldValue(r, "userId", "")).Where(id => !string.IsNullOrEmpty(id)).Distinct().Count(),
                        TotalAttempts = g.Count(),
                        AverageScore = g.Select(r => GetFieldValue(r, "score", 0.0)).Where(s => s > 0).DefaultIfEmpty(0).Average(),
                        PassRate = g.Select(r => GetFieldValue(r, "score", 0.0)).Where(s => s > 0).Any() ?
                                  (double)g.Count(r => GetFieldValue(r, "score", 0.0) >= 70) / g.Select(r => GetFieldValue(r, "score", 0.0)).Where(s => s > 0).Count() * 100 : 0,
                        MostPopularTopic = g.GroupBy(r => GetFieldValue(r, "topicName", "Unknown"))
                                           .Where(tg => !string.IsNullOrEmpty(tg.Key))
                                           .OrderByDescending(tg => tg.Count())
                                           .FirstOrDefault()?.Key ?? "N/A"
                    })
                    .OrderByDescending(l => l.TotalAttempts)
                    .ToList();

                rptLanguageStats.DataSource = languageStats;
                rptLanguageStats.DataBind();

                System.Diagnostics.Debug.WriteLine($"Language performance loaded: {languageStats.Count} languages");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading language performance: {ex.Message}");
                rptLanguageStats.DataSource = null;
                rptLanguageStats.DataBind();
            }
        }

        private async System.Threading.Tasks.Task LoadRecentActivityAsync(List<Dictionary<string, object>> results)
        {
            try
            {
                var recentResults = results
                    .Where(r => r.ContainsKey("completedAt") && r["completedAt"] is Timestamp)
                    .OrderByDescending(r => ((Timestamp)r["completedAt"]).ToDateTime())
                    .Take(20)
                    .ToList();

                if (recentResults.Count == 0)
                {
                    rptRecentActivity.Visible = false;
                    return;
                }

                var userIds = recentResults.Select(r => GetFieldValue(r, "userId", "")).Where(id => !string.IsNullOrEmpty(id)).Distinct().ToList();

                var userLookup = await GetMultipleUsersAsync(userIds);

                var recentActivity = recentResults.Select(r =>
                {
                    string userId = GetFieldValue(r, "userId", "");
                    UserInfo userInfo = userLookup.ContainsKey(userId) ? userLookup[userId] : new UserInfo { UserId = userId };

                    Timestamp completedTimestamp = GetFieldValue(r, "completedAt", Timestamp.GetCurrentTimestamp());
                    DateTime localCompletedAt = ConvertTimestampToLocal(completedTimestamp);

                    return new
                    {
                        UserName = userInfo.DisplayName,
                        UserId = userId,
                        LanguageName = GetFieldValue(r, "languageName", "Unknown"),
                        TopicName = GetFieldValue(r, "topicName", "Unknown"),
                        LessonName = GetFieldValue(r, "lessonName", "Unknown"),
                        Score = GetFieldValue(r, "score", 0),
                        TimeSpent = Math.Round(GetFieldValue(r, "timeSpentSeconds", 0.0) / 60.0, 1),
                        CompletedAt = FormatFullDateTime(localCompletedAt)
                    };
                }).ToList();

                rptRecentActivity.DataSource = recentActivity;
                rptRecentActivity.DataBind();
                rptRecentActivity.Visible = true;

                System.Diagnostics.Debug.WriteLine($"Recent activity loaded: {recentActivity.Count} records");
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
                var scoreRanges = new int[5];

                foreach (var result in results)
                {
                    int score = GetFieldValue(result, "score", 0);
                    if (score >= 90) scoreRanges[0]++;
                    else if (score >= 80) scoreRanges[1]++;
                    else if (score >= 70) scoreRanges[2]++;
                    else if (score >= 60) scoreRanges[3]++;
                    else if (score > 0) scoreRanges[4]++;
                }

                hfScoreDistributionData.Value = JsonConvert.SerializeObject(scoreRanges);

                var dailyActivity = new Dictionary<string, int>();
                for (int i = 6; i >= 0; i--)
                {
                    DateTime date = DateTime.Now.AddDays(-i);
                    dailyActivity[date.ToString("MMM dd")] = 0;
                }

                foreach (var result in results)
                {
                    try
                    {
                        Timestamp completedTimestamp = GetFieldValue(result, "completedAt", Timestamp.GetCurrentTimestamp());
                        DateTime localCompletedDate = ConvertTimestampToLocal(completedTimestamp);
                        string dateKey = localCompletedDate.ToString("MMM dd");

                        if (dailyActivity.ContainsKey(dateKey))
                        {
                            dailyActivity[dateKey]++;
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error processing date for chart: {ex.Message}");
                    }
                }

                var activityData = new
                {
                    labels = dailyActivity.Keys.ToArray(),
                    attempts = dailyActivity.Values.ToArray()
                };

                hfDailyActivityData.Value = JsonConvert.SerializeObject(activityData);

                System.Diagnostics.Debug.WriteLine("Chart data generated successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error generating chart data: {ex.Message}");
                hfScoreDistributionData.Value = "[0,0,0,0,0]";
                hfDailyActivityData.Value = JsonConvert.SerializeObject(new { labels = new string[0], attempts = new int[0] });
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
                $"alert('{message.Replace("'", "\\'")}');", true);
        }

        protected void ClearUserCache()
        {
            lock (dbLock)
            {
                userCache.Clear();
                System.Diagnostics.Debug.WriteLine("User cache cleared");
            }
        }
    }
}