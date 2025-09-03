using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using SendGrid;
using SendGrid.Helpers.Mail;
using System.Threading;

namespace YourProjectNamespace
{
    public partial class Admin : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        // SendGrid configuration
        private static readonly string SendGridApiKey = GetConfigValue("SendGridApiKey");
        private static readonly string SendGridFromEmail = GetConfigValue("SendGridFromEmail");
        private static readonly string SendGridFromName = GetConfigValue("SendGridFromName");

        private static string GetConfigValue(string key)
        {
            string value = ConfigurationManager.AppSettings[key];
            if (string.IsNullOrEmpty(value))
            {
                value = Environment.GetEnvironmentVariable(key);
            }
            return value;
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // Check if user is admin (implement your admin authentication logic here)
                if (!IsAdminAuthenticated())
                {
                    // Use false parameter to prevent ThreadAbortException
                    Response.Redirect("Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest(); // Complete the request cleanly
                    return;
                }

                InitializeFirestore();

                if (!IsPostBack)
                {
                    await LoadUsers();
                    await LoadReports();
                    await LoadStatistics();
                }
            }
            catch (ThreadAbortException)
            {
                // ThreadAbortException is normal for Response.Redirect
                // Don't log or show error message for this
                // Don't re-throw - just let it complete
                return;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Page_Load error: {ex.Message}");
                ShowErrorMessage("System error. Please try again later.");
            }
        }

        private bool IsAdminAuthenticated()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== Admin Authentication Check ===");

                // Debug: Log all session variables
                foreach (string key in Session.Keys)
                {
                    System.Diagnostics.Debug.WriteLine($"Session[{key}] = {Session[key]}");
                }

                // Check multiple possible session variable names for flexibility
                string userRole = Session["UserRole"]?.ToString() ?? Session["position"]?.ToString();
                bool isLoggedIn = false;

                // Check both possible login status variables
                if (Session["IsLoggedIn"] != null)
                {
                    isLoggedIn = (bool)Session["IsLoggedIn"];
                }
                else if (Session["isLoggedIn"] != null)
                {
                    isLoggedIn = (bool)Session["isLoggedIn"];
                }

                System.Diagnostics.Debug.WriteLine($"UserRole/Position: '{userRole}'");
                System.Diagnostics.Debug.WriteLine($"IsLoggedIn: {isLoggedIn}");

                // Check if user has admin role (case-insensitive)
                bool isAdmin = !string.IsNullOrEmpty(userRole) &&
                               userRole.Equals("Administrator", StringComparison.OrdinalIgnoreCase);

                System.Diagnostics.Debug.WriteLine($"IsAdmin: {isAdmin}");
                System.Diagnostics.Debug.WriteLine($"Final Authentication Result: {isLoggedIn && isAdmin}");

                return isLoggedIn && isAdmin;

                // For testing purposes, uncomment this line to bypass authentication
                // return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"IsAdminAuthenticated error: {ex.Message}");
                return false;
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
                            if (!System.IO.File.Exists(path))
                            {
                                string envPath = Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS");
                                if (!string.IsNullOrEmpty(envPath) && System.IO.File.Exists(envPath))
                                {
                                    path = envPath;
                                }
                                else
                                {
                                    throw new System.IO.FileNotFoundException($"Service account key not found at: {path}");
                                }
                            }

                            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                            db = FirestoreDb.Create("intorannetto");
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine($"Firestore initialization failed: {ex.Message}");
                            throw;
                        }
                    }
                }
            }
        }

        #region User Management Methods

        private async Task LoadUsers()
        {
            try
            {
                var query = db.Collection("users").OrderByDescending("createdAt");

                // Apply filters
                var searchTerm = txtUserSearch.Text.Trim().ToLower();
                var statusFilter = ddlUserStatusFilter.SelectedValue;
                var positionFilter = ddlUserPositionFilter.SelectedValue;

                var snapshot = await query.GetSnapshotAsync();
                var users = new List<UserData>();

                foreach (var document in snapshot.Documents)
                {
                    var userData = ConvertToUserData(document);

                    // Apply search filter
                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        var searchableText = $"{userData.FirstName} {userData.LastName} {userData.Email} {userData.Username}".ToLower();
                        if (!searchableText.Contains(searchTerm))
                            continue;
                    }

                    // Apply status filter
                    if (!string.IsNullOrEmpty(statusFilter) && userData.Status != statusFilter)
                        continue;

                    // Apply position filter
                    if (!string.IsNullOrEmpty(positionFilter) && userData.Position != positionFilter)
                        continue;

                    users.Add(userData);
                }

                if (users.Count > 0)
                {
                    rptUsers.DataSource = users;
                    rptUsers.DataBind();
                    pnlNoUsers.Visible = false;
                }
                else
                {
                    rptUsers.DataSource = null;
                    rptUsers.DataBind();
                    pnlNoUsers.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUsers error: {ex.Message}");
                ShowErrorMessage("Failed to load users. Please try again.");
            }
        }

        private UserData ConvertToUserData(DocumentSnapshot document)
        {
            return new UserData
            {
                Uid = document.Id,
                FirstName = document.GetValue<string>("firstName"),
                LastName = document.GetValue<string>("lastName"),
                Username = document.GetValue<string>("username"),
                Email = document.GetValue<string>("email"),
                Phone = document.ContainsField("phone") ? document.GetValue<string>("phone") : null,
                Gender = document.GetValue<string>("gender"),
                Position = document.GetValue<string>("position"),
                Birthdate = document.ContainsField("birthdate") ? document.GetValue<string>("birthdate") : null,
                Address = document.ContainsField("address") ? document.GetValue<string>("address") : null,
                Status = document.ContainsField("status") ? document.GetValue<string>("status") : "pending",
                RejectionReason = document.ContainsField("rejectionReason") ? document.GetValue<string>("rejectionReason") : null,
                CreatedAt = document.GetValue<Timestamp>("createdAt").ToDateTime(),
                LastUpdated = document.GetValue<Timestamp>("lastUpdated").ToDateTime()
            };
        }

        public string GetStatusClass(string status)
        {
            switch (status?.ToLower())
            {
                case "approved":
                    return "approved";
                case "rejected":
                    return "rejected";
                default:
                    return "";
            }
        }

        protected async void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "Approve")
                {
                    var userId = e.CommandArgument.ToString();
                    await ApproveUser(userId);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"User ItemCommand error: {ex.Message}");
                ShowErrorMessage("Action failed. Please try again.");
            }
        }

        private async Task ApproveUser(string userId)
        {
            try
            {
                // Get user data
                var userDoc = await db.Collection("users").Document(userId).GetSnapshotAsync();
                if (!userDoc.Exists)
                {
                    ShowErrorMessage("User not found.");
                    return;
                }

                var userData = ConvertToUserData(userDoc);

                // Update user status
                var updates = new Dictionary<string, object>
                {
                    {"status", "approved"},
                    {"isActive", true}, // Activate the user account
                    {"approvedAt", Timestamp.GetCurrentTimestamp()},
                    {"lastUpdated", Timestamp.GetCurrentTimestamp()}
                };

                // Remove rejection reason if it exists
                if (userDoc.ContainsField("rejectionReason"))
                {
                    updates.Add("rejectionReason", FieldValue.Delete);
                }

                await db.Collection("users").Document(userId).UpdateAsync(updates);

                // Send approval email
                await SendApprovalEmail(userData);

                ShowSuccessMessage($"User {userData.FirstName} {userData.LastName} has been approved successfully!");

                await LoadUsers();
                await LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ApproveUser error: {ex.Message}");
                ShowErrorMessage($"Failed to approve user: {ex.Message}");
            }
        }

        protected async void btnConfirmReject_Click(object sender, EventArgs e)
        {
            try
            {
                var userId = hiddenUserIdToReject.Value;
                var rejectionReason = txtRejectionReason.Text.Trim();

                if (string.IsNullOrEmpty(rejectionReason))
                {
                    ShowErrorMessage("Please provide a reason for rejection.");
                    return;
                }

                await RejectUser(userId, rejectionReason);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Reject user error: {ex.Message}");
                ShowErrorMessage("Rejection failed. Please try again.");
            }
        }

        private async Task RejectUser(string userId, string rejectionReason)
        {
            try
            {
                // Get user data
                var userDoc = await db.Collection("users").Document(userId).GetSnapshotAsync();
                if (!userDoc.Exists)
                {
                    ShowErrorMessage("User not found.");
                    return;
                }

                var userData = ConvertToUserData(userDoc);

                // Update user status
                var updates = new Dictionary<string, object>
                {
                    {"status", "rejected"},
                    {"rejectionReason", rejectionReason},
                    {"isActive", false}, // Ensure account remains inactive
                    {"rejectedAt", Timestamp.GetCurrentTimestamp()},
                    {"lastUpdated", Timestamp.GetCurrentTimestamp()}
                };

                await db.Collection("users").Document(userId).UpdateAsync(updates);

                // Send rejection email
                await SendRejectionEmail(userData, rejectionReason);

                ShowSuccessMessage($"User {userData.FirstName} {userData.LastName} has been rejected.");

                await LoadUsers();
                await LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"RejectUser error: {ex.Message}");
                ShowErrorMessage($"Failed to reject user: {ex.Message}");
            }
        }

        // User filter event handlers
        protected async void txtUserSearch_TextChanged(object sender, EventArgs e)
        {
            await LoadUsers();
        }

        protected async void ddlUserStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadUsers();
        }

        protected async void ddlUserPositionFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadUsers();
        }

        protected async void btnUserRefresh_Click(object sender, EventArgs e)
        {
            await LoadUsers();
            await LoadStatistics();
        }

        #endregion

        #region Report Management Methods

        private async Task LoadReports()
        {
            try
            {
                // Start with the collection reference
                CollectionReference reportsCollection = db.Collection("reports");
                Query query;

                // Apply sorting - create Query object instead of reassigning to CollectionReference
                var sortBy = ddlReportSortBy.SelectedValue;
                switch (sortBy)
                {
                    case "oldest":
                        query = reportsCollection.OrderBy("reportedAt");
                        break;
                    case "priority":
                        query = reportsCollection.OrderBy("priority").OrderByDescending("reportedAt");
                        break;
                    case "status":
                        query = reportsCollection.OrderBy("status").OrderByDescending("reportedAt");
                        break;
                    default: // newest
                        query = reportsCollection.OrderByDescending("reportedAt");
                        break;
                }

                var snapshot = await query.GetSnapshotAsync();
                var reports = new List<ReportData>();

                foreach (var document in snapshot.Documents)
                {
                    var reportData = ConvertToReportData(document);

                    // Apply filters
                    if (!ReportPassesFilters(reportData))
                        continue;

                    reports.Add(reportData);
                }

                if (reports.Count > 0)
                {
                    rptReports.DataSource = reports;
                    rptReports.DataBind();
                    pnlNoReports.Visible = false;
                }
                else
                {
                    rptReports.DataSource = null;
                    rptReports.DataBind();
                    pnlNoReports.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadReports error: {ex.Message}");
                ShowErrorMessage("Failed to load reports. Please try again.");
            }
        }

        private bool ReportPassesFilters(ReportData report)
        {
            // Search filter
            var searchTerm = txtReportSearch.Text.Trim().ToLower();
            if (!string.IsNullOrEmpty(searchTerm))
            {
                var searchableText = $"{report.ReportedContent} {report.ReporterName} {report.ReportedAuthor} {report.GroupName} {report.ReasonText}".ToLower();
                if (!searchableText.Contains(searchTerm))
                    return false;
            }

            // Status filter
            var statusFilter = ddlReportStatusFilter.SelectedValue;
            if (!string.IsNullOrEmpty(statusFilter) && report.Status != statusFilter)
                return false;

            // Priority filter
            var priorityFilter = ddlReportPriorityFilter.SelectedValue;
            if (!string.IsNullOrEmpty(priorityFilter) && report.Priority != priorityFilter)
                return false;

            // Type filter
            var typeFilter = ddlReportTypeFilter.SelectedValue;
            if (!string.IsNullOrEmpty(typeFilter) && report.ReportedItemType != typeFilter)
                return false;

            return true;
        }

        private ReportData ConvertToReportData(DocumentSnapshot document)
        {
            var reportData = new ReportData
            {
                ReportId = document.Id,
                ReporterId = GetFieldValue(document, "reporterId"),
                ReporterName = GetFieldValue(document, "reporterName"),
                ReportedItemId = GetFieldValue(document, "reportedItemId"),
                ReportedItemType = GetFieldValue(document, "reportedItemType"),
                ReportedContent = GetFieldValue(document, "reportedContent"),
                ReportedAuthor = GetFieldValue(document, "reportedAuthor"),
                ReportedAuthorId = GetFieldValue(document, "reportedAuthorId"),
                GroupId = GetFieldValue(document, "groupId"),
                GroupName = GetFieldValue(document, "groupName"),
                Reason = GetFieldValue(document, "reason"),
                ReasonText = GetFieldValue(document, "reasonText"),
                Details = GetFieldValue(document, "details"),
                Status = GetFieldValue(document, "status", "pending"),
                Priority = GetFieldValue(document, "priority", "low"),
                IsResolved = document.ContainsField("isResolved") ? document.GetValue<bool>("isResolved") : false,
                ReportedAt = document.ContainsField("reportedAt") ? document.GetValue<Timestamp>("reportedAt").ToDateTime() : DateTime.UtcNow,
                ReviewedBy = GetFieldValue(document, "reviewedBy"),
                ReviewedAt = document.ContainsField("reviewedAt") && document.GetValue<Timestamp?>("reviewedAt") != null ?
                             document.GetValue<Timestamp>("reviewedAt").ToDateTime() : (DateTime?)null,
                AdminAction = GetFieldValue(document, "adminAction"),
                AdminNotes = GetFieldValue(document, "adminNotes"),
                ActionTaken = document.ContainsField("actionTaken") ? document.GetValue<bool>("actionTaken") : false,
                ReportCount = document.ContainsField("reportCount") ? document.GetValue<int>("reportCount") : 1,
                ReportedContentLength = document.ContainsField("reportedContentLength") ? document.GetValue<int>("reportedContentLength") : 0,
                ParentPostId = GetFieldValue(document, "parentPostId"),
                OriginalTimestamp = document.ContainsField("originalTimestamp") ? document.GetValue<Timestamp>("originalTimestamp").ToDateTime() : DateTime.UtcNow,
                LastReportedAt = document.ContainsField("lastReportedAt") ? document.GetValue<Timestamp>("lastReportedAt").ToDateTime() : DateTime.UtcNow
            };

            return reportData;
        }

        protected async void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // This method is kept for compatibility but actions are now handled via JavaScript modal
            // The actual processing happens in btnConfirmAction_Click
        }

        protected async void btnConfirmAction_Click(object sender, EventArgs e)
        {
            try
            {
                string reportId = hdnReportId.Value;
                string actionType = hdnActionType.Value;
                string itemType = hdnItemType.Value;
                string itemId = hdnItemId.Value;
                string adminNotes = txtAdminNotes.Text.Trim();

                if (string.IsNullOrEmpty(reportId) || string.IsNullOrEmpty(actionType))
                {
                    ShowErrorMessage("Invalid action data. Please try again.");
                    return;
                }

                // Get current admin user info
                string adminUserId = Session["userId"]?.ToString() ?? "admin";
                string adminUsername = Session["username"]?.ToString() ?? "Administrator";

                await ProcessReportAction(reportId, actionType, itemType, itemId, adminUserId, adminUsername, adminNotes);

                // Clear form
                hdnReportId.Value = "";
                hdnActionType.Value = "";
                hdnItemType.Value = "";
                hdnItemId.Value = "";
                txtAdminNotes.Text = "";

                // Close modal
                ScriptManager.RegisterStartupScript(this, GetType(), "closeActionModal",
                    @"var modal = bootstrap.Modal.getInstance(document.getElementById('actionModal')); 
                      if (modal) modal.hide();", true);

                await LoadReports();
                await LoadStatistics();
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Action failed: " + ex.Message);
                System.Diagnostics.Debug.WriteLine($"btnConfirmAction_Click error: {ex}");
            }
        }

        private async Task ProcessReportAction(string reportId, string actionType, string itemType, string itemId,
                                            string adminUserId, string adminUsername, string adminNotes)
        {
            try
            {
                var reportRef = db.Collection("reports").Document(reportId);
                var reportSnap = await reportRef.GetSnapshotAsync();

                if (!reportSnap.Exists)
                {
                    ShowErrorMessage("Report not found.");
                    return;
                }

                var reportData = reportSnap.ToDictionary();
                string groupId = reportData.GetValueOrDefault("groupId", "").ToString();
                string parentPostId = reportData.GetValueOrDefault("parentPostId", "").ToString();

                bool contentDeleted = false;
                string adminAction = "";

                switch (actionType)
                {
                    case "resolve":
                        adminAction = "Report resolved - Content kept";
                        await UpdateReportStatus(reportRef, "resolved", true, adminUserId, adminUsername, adminAction, adminNotes);
                        ShowSuccessMessage("Report resolved successfully. Content has been kept.");
                        break;

                    case "delete":
                        contentDeleted = await DeleteReportedContent(itemType, itemId, groupId, parentPostId);
                        if (contentDeleted)
                        {
                            adminAction = "Content deleted - Report resolved";
                            await UpdateReportStatus(reportRef, "resolved", true, adminUserId, adminUsername, adminAction, adminNotes);
                            ShowSuccessMessage("Content deleted and report resolved successfully.");
                        }
                        else
                        {
                            ShowErrorMessage("Failed to delete content. Please try again.");
                            return;
                        }
                        break;

                    case "dismiss":
                        adminAction = "Report dismissed - No action required";
                        await UpdateReportStatus(reportRef, "dismissed", true, adminUserId, adminUsername, adminAction, adminNotes);
                        ShowSuccessMessage("Report dismissed successfully.");
                        break;

                    default:
                        ShowErrorMessage("Invalid action type.");
                        return;
                }

                // Log admin action
                await LogAdminAction(reportId, actionType, adminUserId, adminUsername, contentDeleted);

                // Notify relevant parties if needed
                await NotifyReportActionTaken(reportData, adminAction, contentDeleted);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ProcessReportAction error: {ex}");
                throw;
            }
        }

        private async Task<bool> DeleteReportedContent(string itemType, string itemId, string groupId, string parentPostId)
        {
            try
            {
                if (itemType == "post")
                {
                    var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document(itemId);
                    var postSnap = await postRef.GetSnapshotAsync();

                    if (postSnap.Exists)
                    {
                        // Delete post subcollections first
                        await DeleteSubcollection(postRef.Collection("comments"));
                        await DeleteSubcollection(postRef.Collection("attachments"));

                        // Delete the post
                        await postRef.DeleteAsync();
                        return true;
                    }
                }
                else if (itemType == "comment" && !string.IsNullOrEmpty(parentPostId))
                {
                    var commentRef = db.Collection("studyHubs").Document(groupId)
                        .Collection("posts").Document(parentPostId)
                        .Collection("comments").Document(itemId);

                    var commentSnap = await commentRef.GetSnapshotAsync();
                    if (commentSnap.Exists)
                    {
                        await commentRef.DeleteAsync();
                        return true;
                    }
                }

                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"DeleteReportedContent error: {ex}");
                return false;
            }
        }

        private async Task DeleteSubcollection(CollectionReference collectionRef)
        {
            try
            {
                var snapshot = await collectionRef.GetSnapshotAsync();
                foreach (var doc in snapshot.Documents)
                {
                    await doc.Reference.DeleteAsync();
                }
            }
            catch
            {
                // Log error but don't fail the main operation
            }
        }

        private async Task UpdateReportStatus(DocumentReference reportRef, string status, bool isResolved,
                                            string adminUserId, string adminUsername, string adminAction, string adminNotes)
        {
            var updates = new Dictionary<string, object>
            {
                { "status", status },
                { "isResolved", isResolved },
                { "reviewedBy", adminUsername },
                { "reviewedAt", Timestamp.GetCurrentTimestamp() },
                { "adminAction", adminAction },
                { "adminNotes", adminNotes ?? "" },
                { "actionTaken", true },
                { "reviewerId", adminUserId }
            };

            await reportRef.UpdateAsync(updates);
        }

        private async Task LogAdminAction(string reportId, string actionType, string adminUserId, string adminUsername, bool contentDeleted)
        {
            try
            {
                var logRef = db.Collection("adminLogs").Document();
                await logRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", "report_action" },
                    { "reportId", reportId },
                    { "actionType", actionType },
                    { "adminUserId", adminUserId },
                    { "adminUsername", adminUsername },
                    { "contentDeleted", contentDeleted },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "details", $"Admin {adminUsername} took action '{actionType}' on report {reportId}" }
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LogAdminAction error: {ex}");
            }
        }

        private async Task NotifyReportActionTaken(Dictionary<string, object> reportData, string adminAction, bool contentDeleted)
        {
            try
            {
                // Notify the reporter about the action taken
                string reporterId = reportData.GetValueOrDefault("reporterId", "").ToString();
                if (!string.IsNullOrEmpty(reporterId))
                {
                    var notificationRef = db.Collection("users").Document(reporterId)
                        .Collection("notifications").Document();

                    string message = contentDeleted
                        ? "Your report has been reviewed and the content has been removed."
                        : "Your report has been reviewed. Thank you for helping keep our community safe.";

                    await notificationRef.SetAsync(new Dictionary<string, object>
                    {
                        { "type", "report_resolved" },
                        { "message", message },
                        { "isRead", false },
                        { "timestamp", Timestamp.GetCurrentTimestamp() }
                    });
                }

                // Notify the content author if content was deleted
                if (contentDeleted)
                {
                    string authorId = reportData.GetValueOrDefault("reportedAuthorId", "").ToString();
                    if (!string.IsNullOrEmpty(authorId) && authorId != reporterId)
                    {
                        var notificationRef = db.Collection("users").Document(authorId)
                            .Collection("notifications").Document();

                        await notificationRef.SetAsync(new Dictionary<string, object>
                        {
                            { "type", "content_removed" },
                            { "message", "One of your posts/comments was removed following a community report." },
                            { "isRead", false },
                            { "timestamp", Timestamp.GetCurrentTimestamp() }
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"NotifyReportActionTaken error: {ex}");
            }
        }

        // Report filter event handlers
        protected async void txtReportSearch_TextChanged(object sender, EventArgs e)
        {
            await LoadReports();
        }

        protected async void ddlReportStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadReports();
        }

        protected async void ddlReportPriorityFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadReports();
        }

        protected async void ddlReportTypeFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadReports();
        }

        protected async void ddlReportSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadReports();
        }

        protected async void btnReportRefresh_Click(object sender, EventArgs e)
        {
            await LoadReports();
            await LoadStatistics();
        }

        #endregion

        #region Statistics and Common Methods

        private async Task LoadStatistics()
        {
            try
            {
                // Load user statistics
                var userSnapshot = await db.Collection("users").GetSnapshotAsync();
                int pendingUsers = 0, approvedUsers = 0, rejectedUsers = 0, totalUsers = userSnapshot.Count;

                foreach (var document in userSnapshot.Documents)
                {
                    var status = document.ContainsField("status") ? document.GetValue<string>("status") : "pending";
                    switch (status)
                    {
                        case "pending":
                            pendingUsers++;
                            break;
                        case "approved":
                            approvedUsers++;
                            break;
                        case "rejected":
                            rejectedUsers++;
                            break;
                    }
                }

                lblPendingCount.Text = pendingUsers.ToString();
                lblApprovedCount.Text = approvedUsers.ToString();
                lblRejectedCount.Text = rejectedUsers.ToString();
                lblTotalCount.Text = totalUsers.ToString();
                lblNavPending.Text = pendingUsers.ToString();

                // Load report statistics
                var reportSnapshot = await db.Collection("reports").GetSnapshotAsync();
                int pendingReports = 0, highPriorityReports = 0, resolvedReports = 0, totalReports = reportSnapshot.Count;

                foreach (var document in reportSnapshot.Documents)
                {
                    var status = document.ContainsField("status") ? document.GetValue<string>("status") : "pending";
                    var priority = document.ContainsField("priority") ? document.GetValue<string>("priority") : "low";
                    var isResolved = document.ContainsField("isResolved") ? document.GetValue<bool>("isResolved") : false;

                    if (status == "pending")
                        pendingReports++;

                    if (priority == "high")
                        highPriorityReports++;

                    if (isResolved || status == "resolved")
                        resolvedReports++;
                }

                lblPendingReports.Text = pendingReports.ToString();
                lblHighPriorityReports.Text = highPriorityReports.ToString();
                lblResolvedReports.Text = resolvedReports.ToString();
                lblTotalReports.Text = totalReports.ToString();
                lblNavReports.Text = pendingReports.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadStatistics error: {ex.Message}");
            }
        }

        private string GetFieldValue(DocumentSnapshot document, string fieldName, string defaultValue = "")
        {
            return document.ContainsField(fieldName) ? document.GetValue<string>(fieldName) : defaultValue;
        }

        #endregion

        #region Email Methods

        private async Task SendApprovalEmail(UserData userData)
        {
            try
            {
                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName);
                var to = new EmailAddress(userData.Email, $"{userData.FirstName} {userData.LastName}");
                var subject = "🎉 Registration Approved - Welcome!";

                var plainTextContent = $@"
Hello {userData.FirstName}!

Great news! Your registration has been approved by our administrators.

You can now log in to your account using your email and password.

Login Details:
- Email: {userData.Email}
- Username: {userData.Username}

Welcome to our platform! We're excited to have you as part of our community.

If you have any questions, please don't hesitate to contact our support team.

Best regards,
The Admin Team
                ";

                var htmlContent = CreateApprovalEmailTemplate(userData);

                var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
                var response = await client.SendEmailAsync(msg);

                if (!response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Body.ReadAsStringAsync();
                    throw new Exception($"SendGrid API error: {response.StatusCode} - {responseBody}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending approval email: {ex.Message}");
                throw;
            }
        }

        private async Task SendRejectionEmail(UserData userData, string rejectionReason)
        {
            try
            {
                var client = new SendGridClient(SendGridApiKey);
                var from = new EmailAddress(SendGridFromEmail, SendGridFromName);
                var to = new EmailAddress(userData.Email, $"{userData.FirstName} {userData.LastName}");
                var subject = "Registration Status Update";

                var plainTextContent = $@"
Hello {userData.FirstName}!

Thank you for your interest in joining our platform. After careful review, we regret to inform you that your registration application has not been approved at this time.

Reason for rejection:
{rejectionReason}

If you believe this decision was made in error or if you have addressed the concerns mentioned above, you are welcome to submit a new registration application.

For any questions or clarification, please contact our support team.

Thank you for your understanding.

Best regards,
The Admin Team
                ";

                var htmlContent = CreateRejectionEmailTemplate(userData, rejectionReason);

                var msg = MailHelper.CreateSingleEmail(from, to, subject, plainTextContent, htmlContent);
                var response = await client.SendEmailAsync(msg);

                if (!response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Body.ReadAsStringAsync();
                    throw new Exception($"SendGrid API error: {response.StatusCode} - {responseBody}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending rejection email: {ex.Message}");
                throw;
            }
        }

        private string CreateApprovalEmailTemplate(UserData userData)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Registration Approved</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background: linear-gradient(135deg, #1cc88a 0%, #17a673 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .welcome-section {{ text-align: center; margin: 30px 0; }}
        .success-icon {{ font-size: 64px; color: #1cc88a; margin-bottom: 20px; }}
        .login-info {{ 
            background-color: #f8f9fc; 
            border-left: 4px solid #1cc88a; 
            padding: 20px; 
            margin: 25px 0; 
            border-radius: 0 8px 8px 0;
        }}
        .login-info h3 {{ margin-top: 0; color: #1cc88a; }}
        .credentials {{ 
            background-color: #e3f2fd; 
            border-radius: 8px; 
            padding: 15px; 
            margin: 15px 0;
            font-family: 'Courier New', monospace;
        }}
        .footer {{ 
            background-color: #f8f9fc; 
            padding: 20px; 
            text-align: center; 
            border-top: 1px solid #e3e6f0;
            font-size: 14px;
            color: #666;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🎉 Welcome Aboard!</h1>
        </div>
        
        <div class='content'>
            <div class='welcome-section'>
                <div class='success-icon'>✅</div>
                <h2>Congratulations, {userData.FirstName}!</h2>
                <p style='font-size: 18px; color: #666;'>Your registration has been approved by our administrators.</p>
            </div>
            
            <p>We're excited to welcome you to our platform! You can now access all the features and services available to registered users.</p>
            
            <div class='login-info'>
                <h3>🔐 Your Login Information:</h3>
                <div class='credentials'>
                    <strong>Email:</strong> {userData.Email}<br>
                    <strong>Username:</strong> {userData.Username}
                </div>
                <p><strong>Note:</strong> Use the password you created during registration.</p>
            </div>
            
            <p>If you have any questions or need assistance getting started, our support team is here to help.</p>
            
            <p>Welcome to the community!</p>
            
            <p>Best regards,<br><strong>The Admin Team</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>© 2024 Your Company Name. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string CreateRejectionEmailTemplate(UserData userData, string rejectionReason)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Registration Status Update</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }}
        .container {{ max-width: 600px; margin: 0 auto; background-color: white; }}
        .header {{ background: linear-gradient(135deg, #e74a3b 0%, #c73321 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 28px; }}
        .content {{ padding: 40px 30px; }}
        .reason-box {{ 
            background-color: #f8d7da; 
            border: 1px solid #f5c6cb; 
            border-radius: 8px; 
            padding: 20px; 
            margin: 25px 0;
        }}
        .reason-box h3 {{ margin-top: 0; color: #721c24; }}
        .reason-text {{ 
            background-color: white; 
            padding: 15px; 
            border-radius: 6px; 
            border-left: 4px solid #e74a3b;
            font-style: italic;
        }}
        .footer {{ 
            background-color: #f8f9fc; 
            padding: 20px; 
            text-align: center; 
            border-top: 1px solid #e3e6f0;
            font-size: 14px;
            color: #666;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>📝 Registration Status Update</h1>
        </div>
        
        <div class='content'>
            <h2>Hello {userData.FirstName},</h2>
            <p>Thank you for your interest in joining our platform.</p>
            
            <p>After careful review by our administrative team, we regret to inform you that your registration application has not been approved at this time.</p>
            
            <div class='reason-box'>
                <h3>📋 Reason for Rejection:</h3>
                <div class='reason-text'>
                    {rejectionReason}
                </div>
            </div>
            
            <p>If you believe this decision was made in error or if you have questions about the feedback provided, please don't hesitate to contact our support team.</p>
            
            <p>We appreciate your understanding and interest in our platform.</p>
            
            <p>Best regards,<br><strong>The Admin Team</strong></p>
        </div>
        
        <div class='footer'>
            <p>🤖 This is an automated email. Please do not reply to this message.</p>
            <p>© 2024 Your Company Name. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        #endregion

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        private void ShowErrorMessage(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-danger";
            lblMessage.Visible = true;
        }

        private void ShowSuccessMessage(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;
        }
    }

    // Data models
    [Serializable]
    public class UserData
    {
        public string Uid { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Gender { get; set; }
        public string Position { get; set; }
        public string Birthdate { get; set; }
        public string Address { get; set; }
        public string Status { get; set; }
        public string RejectionReason { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime LastUpdated { get; set; }
    }

    [Serializable]
    public class ReportData
    {
        public string ReportId { get; set; }
        public string ReporterId { get; set; }
        public string ReporterName { get; set; }
        public string ReportedItemId { get; set; }
        public string ReportedItemType { get; set; }
        public string ReportedContent { get; set; }
        public string ReportedAuthor { get; set; }
        public string ReportedAuthorId { get; set; }
        public string GroupId { get; set; }
        public string GroupName { get; set; }
        public string Reason { get; set; }
        public string ReasonText { get; set; }
        public string Details { get; set; }
        public string Status { get; set; }
        public string Priority { get; set; }
        public bool IsResolved { get; set; }
        public DateTime ReportedAt { get; set; }
        public string ReviewedBy { get; set; }
        public DateTime? ReviewedAt { get; set; }
        public string AdminAction { get; set; }
        public string AdminNotes { get; set; }
        public bool ActionTaken { get; set; }
        public int ReportCount { get; set; }
        public int ReportedContentLength { get; set; }
        public string ParentPostId { get; set; }
        public DateTime OriginalTimestamp { get; set; }
        public DateTime LastReportedAt { get; set; }
    }
}