using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class StudyHub : Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        private string currentView = "myGroups"; // Default view

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            currentUserId = Session["userId"].ToString();
            db = FirestoreDb.Create("intorannetto");

            // Check if specific view is requested
            string viewType = Request.QueryString["view"];
            if (!string.IsNullOrEmpty(viewType))
                currentView = viewType;

            if (!IsPostBack)
            {
                // Initialize dropdowns
                InitializeFilters();
                await LoadGroups();
            }
        }

        private void InitializeFilters()
        {
            // Ensure dropdown maintains its state
            if (!string.IsNullOrEmpty(ddlSubject.SelectedValue))
            {
                ddlSubject.SelectedValue = ddlSubject.SelectedValue;
            }
        }

        protected async Task LoadGroups()
        {
            try
            {
                var groups = new List<dynamic>();

                if (currentView == "myGroups")
                {
                    // Load only groups user is a member of
                    Query groupQuery = db.Collection("studyHubs").WhereArrayContains("members", currentUserId);
                    QuerySnapshot groupSnapshot = await groupQuery.GetSnapshotAsync();
                    groups = await ProcessGroupSnapshots(groupSnapshot, true);
                }
                else if (currentView == "discover")
                {
                    // Load all public groups
                    Query groupQuery = db.Collection("studyHubs");
                    QuerySnapshot groupSnapshot = await groupQuery.GetSnapshotAsync();
                    groups = await ProcessGroupSnapshots(groupSnapshot, false);
                }

                // Apply filters (removed sorting)
                groups = ApplyFilters(groups);

                // Default ordering by creation date (newest first)
                groups = groups.OrderByDescending(g => g.createdAt).ToList();

                rptGroups.DataSource = groups;
                rptGroups.DataBind();

                pnlNoGroups.Visible = groups.Count == 0;
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading groups: " + ex.Message, "danger");
            }
        }

        private List<dynamic> ApplyFilters(List<dynamic> groups)
        {
            var filteredGroups = groups;

            // Apply search filter
            if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
            {
                string searchTerm = txtSearch.Text.Trim().ToLower();
                filteredGroups = filteredGroups.Where(g =>
                {
                    string groupName = g.groupName?.ToString()?.ToLower() ?? "";
                    string description = g.description?.ToString()?.ToLower() ?? "";
                    string hosterName = g.hosterName?.ToString()?.ToLower() ?? "";
                    string subject = g.subject?.ToString()?.ToLower() ?? "";

                    return groupName.Contains(searchTerm) ||
                           description.Contains(searchTerm) ||
                           hosterName.Contains(searchTerm) ||
                           subject.Contains(searchTerm);
                }).ToList();
            }

            // Apply subject filter
            if (!string.IsNullOrEmpty(ddlSubject.SelectedValue))
            {
                filteredGroups = filteredGroups.Where(g =>
                {
                    string groupSubject = g.subject?.ToString() ?? "";
                    return groupSubject.Equals(ddlSubject.SelectedValue, StringComparison.OrdinalIgnoreCase);
                }).ToList();
            }

            // For discover view, exclude groups user is already a member of
            if (currentView == "discover")
            {
                filteredGroups = filteredGroups.Where(g => !(bool)g.isMember).ToList();
            }

            return filteredGroups;
        }

        private async Task<List<dynamic>> ProcessGroupSnapshots(QuerySnapshot groupSnapshot, bool memberOnly)
        {
            var groups = new List<dynamic>();

            foreach (DocumentSnapshot doc in groupSnapshot.Documents)
            {
                var data = doc.ToDictionary();

                // Get member list
                var members = data.ContainsKey("members") ? (List<object>)data["members"] : new List<object>();
                var membersList = members.Cast<string>().ToList();

                // Calculate member count
                int memberCount = membersList.Count;

                // Check if current user is a member
                bool isMember = membersList.Contains(currentUserId);

                // Get post count
                int postCount = await GetPostCount(doc.Id);

                // Get last activity
                string lastActivity = await GetLastActivity(doc.Id);

                // Determine if group is active
                bool isActive = await IsGroupActive(doc.Id);

                // Get safe values with null checking
                string groupName = GetSafeString(data, "groupName");
                string hosterName = GetSafeString(data, "hosterName");
                string description = GetSafeString(data, "description");
                string subject = GetSafeString(data, "subject");
                string groupImage = GetSafeString(data, "groupImage", "Images/default-group.jpg");
                int capacity = GetSafeInt(data, "capacity", 10);

                groups.Add(new
                {
                    groupId = doc.Id,
                    groupName = groupName,
                    hosterName = hosterName,
                    capacity = capacity,
                    description = description,
                    subject = subject,
                    groupImage = groupImage,
                    memberCount = memberCount,
                    postCount = postCount,
                    lastActivity = lastActivity,
                    isActive = isActive,
                    isMember = isMember,
                    createdAt = data.ContainsKey("createdAt") ? (Timestamp)data["createdAt"] : Timestamp.GetCurrentTimestamp()
                });
            }

            return groups;
        }

        private string GetSafeString(Dictionary<string, object> data, string key, string defaultValue = "")
        {
            return data.ContainsKey(key) && data[key] != null ? data[key].ToString() : defaultValue;
        }

        private int GetSafeInt(Dictionary<string, object> data, string key, int defaultValue = 0)
        {
            if (data.ContainsKey(key) && data[key] != null && int.TryParse(data[key].ToString(), out int result))
            {
                return result;
            }
            return defaultValue;
        }

        private async Task<int> GetPostCount(string groupId)
        {
            try
            {
                var postsSnapshot = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").GetSnapshotAsync();
                return postsSnapshot.Count;
            }
            catch
            {
                return 0;
            }
        }

        private async Task<string> GetLastActivity(string groupId)
        {
            try
            {
                var lastPostSnapshot = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").OrderByDescending("timestamp").Limit(1).GetSnapshotAsync();

                if (lastPostSnapshot.Count > 0)
                {
                    var lastPost = lastPostSnapshot.Documents[0].ToDictionary();
                    if (lastPost.ContainsKey("timestamp"))
                    {
                        var timestamp = (Timestamp)lastPost["timestamp"];
                        var timeAgo = DateTime.Now - timestamp.ToDateTime();

                        if (timeAgo.TotalDays > 7) return $"{(int)timeAgo.TotalDays} days ago";
                        if (timeAgo.TotalDays > 1) return $"{(int)timeAgo.TotalDays} days ago";
                        if (timeAgo.TotalHours > 1) return $"{(int)timeAgo.TotalHours} hours ago";
                        return "Recently";
                    }
                }
                return "No recent activity";
            }
            catch
            {
                return "Unknown";
            }
        }

        private async Task<bool> IsGroupActive(string groupId)
        {
            try
            {
                var weekAgo = Timestamp.FromDateTime(DateTime.UtcNow.AddDays(-7));
                var recentPostsSnapshot = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").WhereGreaterThan("timestamp", weekAgo).GetSnapshotAsync();
                return recentPostsSnapshot.Count > 0;
            }
            catch
            {
                return false;
            }
        }

        protected void btnCreateGroup_Click(object sender, EventArgs e)
        {
            Response.Redirect("CreateStudyGroup.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnJoinGroup_Click(object sender, EventArgs e)
        {
            currentView = "discover";
            Response.Redirect("StudyHub.aspx?view=discover", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnMyGroups_Click(object sender, EventArgs e)
        {
            currentView = "myGroups";
            Response.Redirect("StudyHub.aspx?view=myGroups", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected async void txtSearch_TextChanged(object sender, EventArgs e)
        {
            await LoadGroups();
        }

        protected async void ddlSubject_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadGroups();
        }

        protected async void rptGroups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "JoinGroup")
            {
                try
                {
                    string groupId = e.CommandArgument.ToString();
                    DocumentSnapshot groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                    if (!groupSnap.Exists)
                    {
                        ShowMessage("Group not found.", "danger");
                        return;
                    }

                    var groupData = groupSnap.ToDictionary();
                    var members = groupData.ContainsKey("members") ? (List<object>)groupData["members"] : new List<object>();
                    var membersList = members.Cast<string>().ToList();

                    if (membersList.Contains(currentUserId))
                    {
                        ShowMessage("You are already a member of this group.", "warning");
                        return;
                    }

                    int capacity = GetSafeInt(groupData, "capacity", 10);
                    if (membersList.Count >= capacity)
                    {
                        ShowMessage("This group is full.", "warning");
                        return;
                    }

                    membersList.Add(currentUserId);
                    await db.Collection("studyHubs").Document(groupId).UpdateAsync("members", membersList);
                    await LogGroupActivity(groupId, "user_joined", $"{Session["username"]} joined the group");

                    ShowMessage("Successfully joined the group!", "success");
                    await LoadGroups();
                }
                catch (Exception ex)
                {
                    ShowMessage("Error joining group: " + ex.Message, "danger");
                }
            }
        }

        private async Task LogGroupActivity(string groupId, string activityType, string description)
        {
            try
            {
                var activityRef = db.Collection("studyHubs").Document(groupId).Collection("activities").Document();
                await activityRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", activityType },
                    { "description", description },
                    { "userId", currentUserId },
                    { "username", Session["username"]?.ToString() ?? "Unknown" },
                    { "timestamp", Timestamp.GetCurrentTimestamp() }
                });
            }
            catch
            {
                // Silent catch to not interrupt main operation
            }
        }

        private void ShowMessage(string message, string type)
        {
            string alertClass = type == "success" ? "alert-success" :
                               type == "warning" ? "alert-warning" :
                               "alert-danger";

            string script = $@"
                $(document).ready(function() {{
                    var alertHtml = '<div class=""alert {alertClass} alert-dismissible fade show"" role=""alert"">' +
                                   '{message}' +
                                   '<button type=""button"" class=""btn-close"" data-bs-dismiss=""alert""></button>' +
                                   '</div>';
                    $('body').prepend(alertHtml);
                    setTimeout(function() {{
                        $('.alert').fadeOut();
                    }}, 5000);
                }});
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "showMessage", script, true);
        }
    }
}