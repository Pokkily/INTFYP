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
            if (Session["UserId"] != null)
                return Session["UserId"].ToString();

            if (Session["DemoUserId"] != null)
                return Session["DemoUserId"].ToString();

            string demoUserId = "DEMO_" + DateTime.Now.Ticks.ToString();
            Session["DemoUserId"] = demoUserId;
            return demoUserId;
        }

        private async System.Threading.Tasks.Task LoadAvailableLanguages()
        {
            try
            {
                // Get languages that the user has progress in
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
                // Get user's progress for this language
                DocumentReference languageProgressRef = db.Collection("users")
                    .Document(currentUserId)
                    .Collection("progress")
                    .Document(languageId);

                DocumentSnapshot languageProgressSnap = await languageProgressRef.GetSnapshotAsync();

                if (languageProgressSnap.Exists)
                {
                    var progressData = languageProgressSnap.ToDictionary();

                    // Load overall statistics
                    lblTotalAttempts.Text = progressData.ContainsKey("totalAttempts") ? progressData["totalAttempts"].ToString() : "0";
                    lblCompletedLessons.Text = progressData.ContainsKey("completedLessons") ? progressData["completedLessons"].ToString() : "0";
                    lblAverageScore.Text = progressData.ContainsKey("averageScore") ? Math.Round(Convert.ToDouble(progressData["averageScore"]), 1).ToString() : "0";
                    lblCurrentStreak.Text = progressData.ContainsKey("currentStreak") ? progressData["currentStreak"].ToString() : "0";

                    double totalHours = progressData.ContainsKey("totalTimeSpent") ? Convert.ToDouble(progressData["totalTimeSpent"]) / 60.0 : 0;
                    lblTotalTime.Text = Math.Round(totalHours, 1).ToString();

                    // Load topic progress
                    await LoadTopicProgress(languageId);

                    // Load recent activity and chart data
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
                // Get recent quiz attempts from languageResults collection
                Query recentQuery = db.Collection("languageResults")
                    .WhereEqualTo("userId", currentUserId)
                    .WhereEqualTo("languageId", languageId)
                    .OrderByDescending("completedAt")
                    .Limit(10);

                QuerySnapshot recentSnapshot = await recentQuery.GetSnapshotAsync();

                var recentActivity = new List<object>();
                var chartLabels = new List<string>();
                var chartScores = new List<int>();

                int attemptNumber = recentSnapshot.Documents.Count;

                foreach (DocumentSnapshot doc in recentSnapshot.Documents)
                {
                    var data = doc.ToDictionary();

                    string lessonName = data.ContainsKey("lessonName") ? data["lessonName"].ToString() : "Unknown Lesson";
                    string topicName = data.ContainsKey("topicName") ? data["topicName"].ToString() : "Unknown Topic";
                    int score = data.ContainsKey("score") ? Convert.ToInt32(data["score"]) : 0;
                    DateTime completedAt = data.ContainsKey("completedAt") ? ((Timestamp)data["completedAt"]).ToDateTime() : DateTime.Now;

                    recentActivity.Add(new
                    {
                        LessonName = lessonName,
                        TopicName = topicName,
                        Score = score,
                        CompletedAt = completedAt.ToString("MMM dd, yyyy HH:mm")
                    });

                    // For chart (reverse order for chronological display)
                    chartLabels.Insert(0, $"Attempt {attemptNumber}");
                    chartScores.Insert(0, score);
                    attemptNumber--;
                }

                rptRecentActivity.DataSource = recentActivity;
                rptRecentActivity.DataBind();

                // Prepare chart data
                var chartData = new
                {
                    labels = chartLabels,
                    scores = chartScores
                };

                hfChartData.Value = JsonConvert.SerializeObject(chartData);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading recent activity: {ex.Message}");
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