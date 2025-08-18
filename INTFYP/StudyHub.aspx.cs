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
                await LoadGroups();
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

                    // Apply search filter
                    if (!string.IsNullOrEmpty(txtSearch.Text))
                    {
                        // Note: Firestore doesn't support full-text search, so we'll filter after retrieval
                    }

                    // Apply subject filter
                    if (!string.IsNullOrEmpty(ddlSubject.SelectedValue))
                    {
                        groupQuery = groupQuery.WhereEqualTo("subject", ddlSubject.SelectedValue);
                    }

                    QuerySnapshot groupSnapshot = await groupQuery.GetSnapshotAsync();
                    groups = await ProcessGroupSnapshots(groupSnapshot, false);

                    // Apply client-side search filter if needed
                    if (!string.IsNullOrEmpty(txtSearch.Text))
                    {
                        string searchTerm = txtSearch.Text.ToLower();
                        groups = groups.Where(g =>
                            g.groupName.ToString().ToLower().Contains(searchTerm) ||
                            g.description.ToString().ToLower().Contains(searchTerm) ||
                            g.hosterName.ToString().ToLower().Contains(searchTerm)
                        ).ToList();
                    }

                    // Apply sorting
                    groups = ApplySorting(groups);
                }

                rptGroups.DataSource = groups;
                rptGroups.DataBind();

                pnlNoGroups.Visible = groups.Count == 0;
            }
            catch (Exception ex)
            {
                // Log error
                ShowMessage("Error loading groups: " + ex.Message, "danger");
            }
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

                // Skip if viewing discover and user is already a member (optional)
                if (currentView == "discover" && memberOnly && isMember)
                    continue;

                // Get post count
                int postCount = await GetPostCount(doc.Id);

                // Get last activity
                string lastActivity = await GetLastActivity(doc.Id);

                // Determine if group is active (has activity in last 7 days)
                bool isActive = await IsGroupActive(doc.Id);

                groups.Add(new
                {
                    groupId = doc.Id,
                    groupName = data.GetValueOrDefault("groupName", "").ToString(),
                    hosterName = data.GetValueOrDefault("hosterName", "").ToString(),
                    capacity = data.GetValueOrDefault("capacity", "0").ToString(),
                    description = data.GetValueOrDefault("description", "").ToString(),
                    subject = data.GetValueOrDefault("subject", "").ToString(),
                    groupImage = data.GetValueOrDefault("groupImage", "Images/default-group.jpg").ToString(),
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

                        if (timeAgo.TotalDays > 7)
                            return $"{(int)timeAgo.TotalDays} days ago";
                        else if (timeAgo.TotalDays > 1)
                            return $"{(int)timeAgo.TotalDays} days ago";
                        else if (timeAgo.TotalHours > 1)
                            return $"{(int)timeAgo.TotalHours} hours ago";
                        else
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

        private List<dynamic> ApplySorting(List<dynamic> groups)
        {
            switch (ddlSortBy.SelectedValue)
            {
                case "newest":
                    return groups.OrderByDescending(g => g.createdAt).ToList();
                case "oldest":
                    return groups.OrderBy(g => g.createdAt).ToList();
                case "popular":
                    return groups.OrderByDescending(g => g.memberCount).ThenByDescending(g => g.postCount).ToList();
                case "alphabetical":
                    return groups.OrderBy(g => g.groupName).ToList();
                default:
                    return groups.OrderByDescending(g => g.createdAt).ToList();
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

        protected async void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
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

                    // Get current group data
                    DocumentSnapshot groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                    if (!groupSnap.Exists)
                    {
                        ShowMessage("Group not found.", "danger");
                        return;
                    }

                    var groupData = groupSnap.ToDictionary();
                    var members = groupData.ContainsKey("members") ? (List<object>)groupData["members"] : new List<object>();
                    var membersList = members.Cast<string>().ToList();

                    // Check if user is already a member
                    if (membersList.Contains(currentUserId))
                    {
                        ShowMessage("You are already a member of this group.", "warning");
                        return;
                    }

                    // Check capacity
                    int capacity = int.Parse(groupData.GetValueOrDefault("capacity", "0").ToString());
                    if (membersList.Count >= capacity)
                    {
                        ShowMessage("This group is full.", "warning");
                        return;
                    }

                    // Add user to group
                    membersList.Add(currentUserId);
                    await db.Collection("studyHubs").Document(groupId).UpdateAsync("members", membersList);

                    // Create join activity log
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
                // Log error but don't fail the main operation
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