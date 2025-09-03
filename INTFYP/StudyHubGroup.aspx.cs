using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text.RegularExpressions;
using System.Net.Mail;
using System.Text;

namespace YourProjectNamespace
{
    public partial class StudyHubGroup : System.Web.UI.Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        protected string currentUsername;
        protected string groupId;
        protected bool isGroupOwner = false;
        protected int currentMemberCount = 0;
        protected int totalCapacity = 0;
        protected int availableSlots = 0;

        private static HashSet<string> editingPostIds = new HashSet<string>();
        private static HashSet<string> editingCommentKeys = new HashSet<string>();

        // Cache for profile images to avoid multiple Firestore calls
        private static Dictionary<string, (string imageUrl, string initials, DateTime cachedAt)> profileCache =
            new Dictionary<string, (string, string, DateTime)>();
        private static readonly TimeSpan CacheExpiry = TimeSpan.FromMinutes(30);

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            db = FirestoreDb.Create("intorannetto");
            currentUserId = Session["userId"].ToString();
            currentUsername = Session["username"].ToString();
            groupId = Request.QueryString["groupId"];

            if (string.IsNullOrEmpty(groupId))
            {
                Response.Redirect("StudyHub.aspx");
                return;
            }

            if (!IsPostBack)
                await LoadGroup();
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            // Add scroll position maintenance script
            string scrollScript = @"
                // Store scroll position before postback
                function storeScrollPosition() {
                    sessionStorage.setItem('scrollPosition', window.pageYOffset || document.documentElement.scrollTop);
                }

                // Restore scroll position after postback
                function restoreScrollPosition() {
                    var scrollPos = sessionStorage.getItem('scrollPosition');
                    if (scrollPos) {
                        window.scrollTo(0, parseInt(scrollPos));
                        sessionStorage.removeItem('scrollPosition');
                    }
                }

                // Store position before any postback
                Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(storeScrollPosition);
                
                // Restore position after partial postback
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(restoreScrollPosition);

                // Also restore on initial page load
                window.addEventListener('load', restoreScrollPosition);

                // Profile navigation function
                function navigateToProfile(userId) {
                    if (userId && userId !== '" + currentUserId + @"') {
                        window.location.href = 'ProfileOthers.aspx?userId=' + userId;
                    } else if (userId === '" + currentUserId + @"') {
                        window.location.href = 'Profile.aspx';
                    }
                }
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "scrollMaintenance", scrollScript, true);
        }

        private async Task LoadGroup()
        {
            try
            {
                DocumentSnapshot groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                if (!groupSnap.Exists)
                {
                    Response.Redirect("StudyHub.aspx");
                    return;
                }

                var group = groupSnap.ToDictionary();
                var members = group.ContainsKey("members") ? (List<object>)group["members"] : new List<object>();
                var membersList = members.Cast<string>().ToList();

                // Check if user is a member
                if (!membersList.Contains(currentUserId))
                {
                    ShowMessage("You are not a member of this group.", "warning");
                    Response.Redirect("StudyHub.aspx");
                    return;
                }

                // Check if user is the group owner
                string hosterId = group.GetValueOrDefault("hosterId", "").ToString();
                isGroupOwner = (hosterId == currentUserId);

                // Get group capacity information
                currentMemberCount = membersList.Count;
                totalCapacity = Convert.ToInt32(group.GetValueOrDefault("capacity", 10));
                availableSlots = Math.Max(0, totalCapacity - currentMemberCount);

                // Update capacity display
                ltCurrentMembers.Text = currentMemberCount.ToString();
                ltTotalCapacity.Text = totalCapacity.ToString();
                ltAvailableSlots.Text = availableSlots.ToString();

                // Show group management panel only for group owner
                pnlGroupManagement.Visible = isGroupOwner;

                // Get group statistics
                int postCount = await GetPostCount();
                string lastActivity = await GetLastActivity();

                ltGroupDetails.Text = $@"
            <h1 class='group-title'>{group["groupName"]}</h1>
            <div class='group-meta'>🧑‍🏫 Hosted by {group["hosterName"]}</div>
            <div class='group-description'>{group.GetValueOrDefault("description", "")}</div>
            <div class='group-stats'>
                <div class='stat-item'>
                    <span class='stat-icon'>👥</span>
                    <span>{currentMemberCount} members</span>
                </div>
                <div class='stat-item'>
                    <span class='stat-icon'>📝</span>
                    <span>{postCount} posts</span>
                </div>
                <div class='stat-item'>
                    <span class='stat-icon'>⏰</span>
                    <span>{lastActivity}</span>
                </div>
            </div>";

                await LoadPosts();

                // Update capacity bar on client side
                string capacityScript = $@"
            document.addEventListener('DOMContentLoaded', function() {{
                updateCapacityBar();
                
                // Enable/disable invite button based on available slots
                const inviteBtn = document.getElementById('{btnSendInvite.ClientID}');
                const bulkInviteBtn = document.getElementById('{btnBulkInvite.ClientID}');
                
                if ({availableSlots} <= 0) {{
                    if (inviteBtn) {{
                        inviteBtn.disabled = true;
                        inviteBtn.textContent = '❌ Group Full';
                    }}
                    if (bulkInviteBtn) {{
                        bulkInviteBtn.disabled = true;
                    }}
                }}
            }});
        ";

                ScriptManager.RegisterStartupScript(this, GetType(), "capacityUpdate", capacityScript, true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading group details: " + ex.Message, "danger");
            }
        }

        
        private string GetTimeUntilExpiry(DateTime expiryDate)
        {
            var timeSpan = expiryDate - DateTime.UtcNow;
            if (timeSpan.TotalDays < 0)
                return "Expired";
            if (timeSpan.TotalDays < 1)
                return "Expires today";
            if (timeSpan.TotalDays < 2)
                return "Expires tomorrow";
            return $"Expires in {(int)timeSpan.TotalDays} days";
        }

        // EMAIL INVITATION METHODS

        protected async void btnSendInvite_Click(object sender, EventArgs e)
        {
            try
            {
                string email = txtInviteEmail.Text.Trim();

                // Validate input
                if (string.IsNullOrEmpty(email))
                {
                    ShowMessage("Please enter an email address.", "warning");
                    return;
                }

                if (!IsValidEmail(email))
                {
                    ShowMessage("Please enter a valid email address.", "warning");
                    return;
                }

                // RECALCULATE CAPACITY IN REAL-TIME
                var capacityInfo = await GetCurrentCapacityInfo();
                if (capacityInfo.availableSlots <= 0)
                {
                    ShowMessage("The group is at full capacity. Cannot send more invitations.", "warning");
                    return;
                }

                // Send the invitation
                bool success = await SendSingleInvitation(email);

                if (success)
                {
                    ShowMessage($"Invitation sent successfully to {email}!", "success");
                    txtInviteEmail.Text = "";

                    // Reload the page to update capacity and pending invitations
                    await LoadGroup();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error sending invitation: " + ex.Message, "danger");
            }
        }

        protected async void btnBulkInvite_Click(object sender, EventArgs e)
        {
            try
            {
                string emailsText = txtBulkInviteEmails.Text.Trim();

                if (string.IsNullOrEmpty(emailsText))
                {
                    ShowMessage("Please enter at least one email address.", "warning");
                    return;
                }

                // Parse emails
                var emails = ParseEmailList(emailsText);

                if (emails.Count == 0)
                {
                    ShowMessage("No valid email addresses found.", "warning");
                    return;
                }

                // RECALCULATE CAPACITY IN REAL-TIME
                var capacityInfo = await GetCurrentCapacityInfo();
                if (capacityInfo.availableSlots <= 0)
                {
                    ShowMessage("The group is at full capacity. Cannot add members.", "warning");
                    return;
                }

                if (emails.Count > capacityInfo.availableSlots)
                {
                    ShowMessage($"You can only add {capacityInfo.availableSlots} more members. Please reduce the number of email addresses.", "warning");
                    return;
                }

                // Add users directly
                var results = await SendBulkInvitations(emails);

                // Display results
                int successCount = results.Count(r => r.Value);
                int failCount = results.Count(r => !r.Value);

                if (successCount > 0 && failCount == 0)
                {
                    ShowMessage($"All {successCount} users added successfully!", "success");
                }
                else if (successCount > 0 && failCount > 0)
                {
                    ShowMessage($"{successCount} users added successfully, {failCount} failed (user not found or already member).", "warning");
                }
                else
                {
                    ShowMessage("Failed to add users. Please check the email addresses and try again.", "danger");
                }

                txtBulkInviteEmails.Text = "";

                // Reload the page to update capacity and member count
                await LoadGroup();
            }
            catch (Exception ex)
            {
                ShowMessage("Error adding members: " + ex.Message, "danger");
            }
        }
        private async Task<(int currentMembers, int totalCapacity, int availableSlots)> GetCurrentCapacityInfo()
        {
            try
            {
                // Get fresh group data
                DocumentSnapshot groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                if (!groupSnap.Exists)
                {
                    return (0, 0, 0);
                }

                var group = groupSnap.ToDictionary();
                var members = group.ContainsKey("members") ? (List<object>)group["members"] : new List<object>();
                var membersList = members.Cast<string>().ToList();

                int currentMembers = membersList.Count;
                int totalCapacity = Convert.ToInt32(group.GetValueOrDefault("capacity", 10));
                int availableSlots = Math.Max(0, totalCapacity - currentMembers);

                System.Diagnostics.Debug.WriteLine($"Capacity Check - Current: {currentMembers}, Total: {totalCapacity}, Available: {availableSlots}");

                return (currentMembers, totalCapacity, availableSlots);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting capacity info: {ex.Message}");
                return (0, 0, 0);
            }
        }

        // Also update the SendSingleInvitation method to use real-time capacity:

        private async Task<bool> SendSingleInvitation(string email)
        {
            try
            {
                // Double-check capacity before processing
                var capacityInfo = await GetCurrentCapacityInfo();
                if (capacityInfo.availableSlots <= 0)
                {
                    ShowMessage("The group is now at full capacity.", "warning");
                    return false;
                }

                // Check if user exists by email
                var usersQuery = db.Collection("users").WhereEqualTo("email", email.ToLower());
                var userSnaps = await usersQuery.GetSnapshotAsync();

                if (userSnaps.Count == 0)
                {
                    ShowMessage($"No user found with email {email}. They need to register first.", "warning");
                    return false;
                }

                string userId = userSnaps.Documents[0].Id;
                var userData = userSnaps.Documents[0].ToDictionary();
                string username = userData.GetValueOrDefault("username", "Unknown").ToString();

                // Check if user is already a member
                var groupRef = db.Collection("studyHubs").Document(groupId);
                var groupSnap = await groupRef.GetSnapshotAsync();

                if (groupSnap.Exists)
                {
                    var groupData = groupSnap.ToDictionary();
                    var members = groupData.ContainsKey("members") ?
                        ((List<object>)groupData["members"]).Cast<string>().ToList() :
                        new List<string>();

                    if (members.Contains(userId))
                    {
                        ShowMessage($"{username} is already a member of this group.", "warning");
                        return false;
                    }

                    // Add user to the group directly
                    members.Add(userId);
                    await groupRef.UpdateAsync("members", members);

                    // Add group to user's groups list
                    var userRef = db.Collection("users").Document(userId);
                    await userRef.UpdateAsync("studyHubs", FieldValue.ArrayUnion(groupId));

                    // Create notification for the added user
                    await CreateNotification(userId, "group_added",
                        $"You have been added to the study group '{groupData.GetValueOrDefault("groupName", "")}' by {currentUsername}");

                    // Log activity
                    await LogGroupActivity("member_added", $"{username} was added to the group by {currentUsername}");

                    ShowMessage($"{username} has been successfully added to the group!", "success");
                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                ShowMessage($"Error adding user with email {email}: {ex.Message}", "danger");
                return false;
            }
        }





        private async Task<Dictionary<string, bool>> SendBulkInvitations(List<string> emails)
        {
            var results = new Dictionary<string, bool>();
            int successCount = 0;

            foreach (string email in emails)
            {
                try
                {
                    if (successCount >= availableSlots)
                    {
                        results[email] = false;
                        ShowMessage($"Reached group capacity. Could not add user with email {email}.", "warning");
                        continue;
                    }

                    bool success = await SendSingleInvitation(email);
                    results[email] = success;

                    if (success)
                    {
                        successCount++;
                    }

                    // Small delay between additions to avoid overwhelming Firestore
                    await Task.Delay(200);
                }
                catch (Exception ex)
                {
                    results[email] = false;
                    System.Diagnostics.Debug.WriteLine($"Error adding user {email}: {ex.Message}");
                }
            }
            return results;
        }

        

        private async Task<bool> SendInvitationEmail(string email, string inviteToken, string inviteId)
        {
            try
            {
                // Get group information
                var groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                if (!groupSnap.Exists)
                    return false;

                var groupData = groupSnap.ToDictionary();
                string groupName = groupData.GetValueOrDefault("groupName", "Study Group").ToString();
                string groupDescription = groupData.GetValueOrDefault("description", "").ToString();
                string subject = groupData.GetValueOrDefault("subject", "General").ToString();

                // Create invitation URL
                string baseUrl = Request.Url.Scheme + "://" + Request.Url.Authority + Request.ApplicationPath.TrimEnd('/');
                string inviteUrl = $"{baseUrl}/JoinGroup.aspx?token={inviteToken}&inviteId={inviteId}";

                // Create email content
                string emailSubject = $"You're invited to join {groupName} on StudyHub";
                string emailBody = CreateInvitationEmailBody(groupName, groupDescription, subject, currentUsername, inviteUrl);

                // Send email using your email service (configure in web.config)
                return await SendEmail(email, emailSubject, emailBody);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending invitation email: {ex.Message}");
                return false;
            }
        }

        private string CreateInvitationEmailBody(string groupName, string description, string subject, string inviterName, string inviteUrl)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Study Group Invitation</title>
    <style>
        body {{ font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; text-align: center; }}
        .content {{ background: #f8f9fa; padding: 30px; border-radius: 10px; margin: 20px 0; }}
        .group-info {{ background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea; }}
        .button {{ display: inline-block; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; text-align: center; margin: 20px 0; }}
        .footer {{ text-align: center; color: #6c757d; font-size: 14px; margin-top: 30px; }}
    </style>
</head>
<body>
    <div class='header'>
        <h1>🎓 You're Invited to Join a Study Group!</h1>
        <p>Someone thinks you'd be a great addition to their study group</p>
    </div>
    
    <div class='content'>
        <p>Hi there!</p>
        
        <p><strong>{inviterName}</strong> has invited you to join their study group on StudyHub.</p>
        
        <div class='group-info'>
            <h3>📚 {groupName}</h3>
            <p><strong>Subject:</strong> {subject}</p>
            {(string.IsNullOrEmpty(description) ? "" : $"<p><strong>Description:</strong> {description}</p>")}
            <p><strong>Invited by:</strong> {inviterName}</p>
        </div>
        
        <p>Join this study group to:</p>
        <ul>
            <li>📖 Collaborate with fellow students</li>
            <li>💡 Share knowledge and resources</li>
            <li>🤝 Get help when you need it</li>
            <li>📈 Improve your learning outcomes</li>
        </ul>
        
        <div style='text-align: center;'>
            <a href='{inviteUrl}' class='button'>🚀 Join Study Group</a>
        </div>
        
        <p><strong>Important:</strong> This invitation will expire in 7 days. Click the button above to accept and join the group.</p>
        
        <p>If you don't have a StudyHub account yet, don't worry! The link above will guide you through creating one.</p>
    </div>
    
    <div class='footer'>
        <p>This invitation was sent via StudyHub. If you didn't expect this invitation, you can safely ignore this email.</p>
        <p>Questions? Contact us at support@studyhub.com</p>
    </div>
</body>
</html>";
        }

        private async Task<bool> SendEmail(string toEmail, string subject, string body)
        {
            try
            {
                // Configure your SMTP settings in web.config
                string smtpServer = ConfigurationManager.AppSettings["SmtpServer"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"];
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"];
                string fromEmail = ConfigurationManager.AppSettings["FromEmail"] ?? smtpUsername;
                string fromName = ConfigurationManager.AppSettings["FromName"] ?? "StudyHub";

                if (string.IsNullOrEmpty(smtpUsername) || string.IsNullOrEmpty(smtpPassword))
                {
                    System.Diagnostics.Debug.WriteLine("SMTP credentials not configured");
                    return false;
                }

                using (var client = new SmtpClient(smtpServer, smtpPort))
                {
                    client.EnableSsl = true;
                    client.Credentials = new System.Net.NetworkCredential(smtpUsername, smtpPassword);

                    var mailMessage = new MailMessage
                    {
                        From = new MailAddress(fromEmail, fromName),
                        Subject = subject,
                        Body = body,
                        IsBodyHtml = true
                    };

                    mailMessage.To.Add(toEmail);

                    await client.SendMailAsync(mailMessage);
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending email: {ex.Message}");
                return false;
            }
        }

        // INVITATION MANAGEMENT METHODS

        protected async void rptPendingInvites_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                string inviteId = e.CommandArgument.ToString();

                switch (e.CommandName)
                {
                    case "ResendInvite":
                        await ResendInvitation(inviteId);
                        break;
                    case "CancelInvite":
                        await CancelInvitation(inviteId);
                        break;
                }

                await LoadGroup(); // Reload to update the display
            }
            catch (Exception ex)
            {
                ShowMessage("Error managing invitation: " + ex.Message, "danger");
            }
        }

        private async Task ResendInvitation(string inviteId)
        {
            try
            {
                var inviteRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("invitations").Document(inviteId);
                var inviteSnap = await inviteRef.GetSnapshotAsync();

                if (!inviteSnap.Exists)
                {
                    ShowMessage("Invitation not found.", "warning");
                    return;
                }

                var inviteData = inviteSnap.ToDictionary();
                string email = inviteData.GetValueOrDefault("email", "").ToString();
                string inviteToken = inviteData.GetValueOrDefault("inviteToken", "").ToString();
                int resendCount = Convert.ToInt32(inviteData.GetValueOrDefault("resendCount", 0));

                // Limit resends to prevent spam
                if (resendCount >= 3)
                {
                    ShowMessage("Maximum resend limit reached for this invitation.", "warning");
                    return;
                }

                // Send email
                bool emailSent = await SendInvitationEmail(email, inviteToken, inviteId);

                if (emailSent)
                {
                    // Update resend count and last sent time
                    await inviteRef.UpdateAsync(new Dictionary<string, object>
                    {
                        { "resendCount", resendCount + 1 },
                        { "lastSentAt", Timestamp.GetCurrentTimestamp() }
                    });

                    ShowMessage($"Invitation resent to {email}!", "success");
                    await LogGroupActivity("invitation_resent", $"{currentUsername} resent invitation to {email}");
                }
                else
                {
                    ShowMessage("Failed to resend invitation. Please try again.", "danger");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error resending invitation: " + ex.Message, "danger");
            }
        }

        private async Task CancelInvitation(string inviteId)
        {
            try
            {
                var inviteRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("invitations").Document(inviteId);
                var inviteSnap = await inviteRef.GetSnapshotAsync();

                if (!inviteSnap.Exists)
                {
                    ShowMessage("Invitation not found.", "warning");
                    return;
                }

                var inviteData = inviteSnap.ToDictionary();
                string email = inviteData.GetValueOrDefault("email", "").ToString();

                // Update invitation status instead of deleting
                await inviteRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "status", "cancelled" },
                    { "cancelledAt", Timestamp.GetCurrentTimestamp() },
                    { "cancelledBy", currentUserId }
                });

                ShowMessage($"Invitation to {email} has been cancelled.", "success");
                await LogGroupActivity("invitation_cancelled", $"{currentUsername} cancelled invitation to {email}");
            }
            catch (Exception ex)
            {
                ShowMessage("Error cancelling invitation: " + ex.Message, "danger");
            }
        }

        // UTILITY METHODS

        private bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            try
            {
                var regex = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                return regex.IsMatch(email);
            }
            catch
            {
                return false;
            }
        }

        private List<string> ParseEmailList(string emailsText)
        {
            var emails = new List<string>();

            if (string.IsNullOrWhiteSpace(emailsText))
                return emails;

            // Split by commas, semicolons, spaces, and new lines
            var separators = new char[] { ',', ';', ' ', '\n', '\r', '\t' };
            var emailArray = emailsText.Split(separators, StringSplitOptions.RemoveEmptyEntries);

            foreach (string email in emailArray)
            {
                string cleanEmail = email.Trim().ToLower();
                if (IsValidEmail(cleanEmail) && !emails.Contains(cleanEmail))
                {
                    emails.Add(cleanEmail);
                }
            }

            return emails;
        }

        // EXISTING METHODS (keeping all existing functionality)

        private async Task<int> GetPostCount()
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

        private async Task<string> GetLastActivity()
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

                        if (timeAgo.TotalDays > 1)
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

        private async Task LoadPosts()
        {
            try
            {
                var posts = new List<dynamic>();
                var postsRef = db.Collection("studyHubs").Document(groupId).Collection("posts");
                var postSnaps = await postsRef.OrderByDescending("timestamp").GetSnapshotAsync();

                foreach (var postDoc in postSnaps.Documents)
                {
                    var p = postDoc.ToDictionary();
                    string postId = postDoc.Id;
                    string postCreatorId = p.GetValueOrDefault("postedBy", "").ToString();
                    string postCreatorName = p.GetValueOrDefault("postedByName", "Unknown").ToString();

                    // Load profile image for post creator
                    var creatorProfile = await LoadUserProfileImageSync(postCreatorId, postCreatorName);

                    // Load comments
                    var comments = await LoadCommentsForPost(postId);

                    // Get engagement data
                    var likes = p.ContainsKey("likes") ? (List<object>)p["likes"] : new List<object>();
                    var saves = p.ContainsKey("saves") ? (List<object>)p["saves"] : new List<object>();
                    var shares = p.ContainsKey("shares") ? (List<object>)p["shares"] : new List<object>();

                    var likesList = likes.Cast<string>().ToList();
                    var savesList = saves.Cast<string>().ToList();
                    var sharesList = shares.Cast<string>().ToList();

                    // Load attachments
                    var attachments = await LoadAttachmentsForPost(postId);

                    posts.Add(new
                    {
                        postId,
                        content = p.GetValueOrDefault("content", "").ToString(),
                        timestamp = p.ContainsKey("timestamp") ?
                            ((Timestamp)p["timestamp"]).ToDateTime().ToString("MMM dd, yyyy 'at' h:mm tt") : "",
                        creatorUsername = postCreatorName,
                        creatorUserId = postCreatorId,
                        creatorProfileImage = creatorProfile.imageUrl,
                        creatorInitials = creatorProfile.initials,
                        hasProfileImage = !string.IsNullOrEmpty(creatorProfile.imageUrl),
                        isOwner = postCreatorId == currentUserId,
                        IsEditingPost = editingPostIds.Contains(postId),
                        comments,
                        commentCount = comments.Count,
                        likeCount = likesList.Count,
                        shareCount = sharesList.Count,
                        isLiked = likesList.Contains(currentUserId),
                        isSaved = savesList.Contains(currentUserId),
                        attachments
                    });
                }

                rptPosts.DataSource = posts;
                rptPosts.DataBind();

                pnlNoPosts.Visible = posts.Count == 0;
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading posts: " + ex.Message, "danger");
            }
        }

        private async Task<List<dynamic>> LoadCommentsForPost(string postId)
        {
            var comments = new List<dynamic>();
            try
            {
                var commentSnaps = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document(postId)
                    .Collection("comments").OrderBy("timestamp").GetSnapshotAsync();

                foreach (var cDoc in commentSnaps.Documents)
                {
                    var c = cDoc.ToDictionary();
                    string commentId = cDoc.Id;
                    string commentKey = postId + "|" + commentId;
                    string commenterId = c.GetValueOrDefault("commenterId", "").ToString();
                    string commenterName = c.GetValueOrDefault("commenterName", "Unknown").ToString();

                    // Load profile image for commenter
                    var commenterProfile = await LoadUserProfileImageSync(commenterId, commenterName);

                    comments.Add(new
                    {
                        postId,
                        commentId,
                        username = commenterName,
                        userId = commenterId,
                        profileImage = commenterProfile.imageUrl,
                        initials = commenterProfile.initials,
                        hasProfileImage = !string.IsNullOrEmpty(commenterProfile.imageUrl),
                        content = c.GetValueOrDefault("text", "").ToString(),
                        timestamp = c.ContainsKey("timestamp") ?
                            ((Timestamp)c["timestamp"]).ToDateTime().ToString("MMM dd 'at' h:mm tt") : "",
                        isOwner = commenterId == currentUserId,
                        IsEditingComment = editingCommentKeys.Contains(commentKey),
                        likes = c.ContainsKey("likes") ? ((List<object>)c["likes"]).Count : 0
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading comments: {ex.Message}");
            }

            return comments;
        }

        private async Task<(string imageUrl, string initials)> LoadUserProfileImageSync(string userId, string username)
        {
            if (string.IsNullOrEmpty(userId))
                return ("", GenerateUserInitials("", "", username));

            try
            {
                // Check cache first
                if (profileCache.ContainsKey(userId))
                {
                    var cached = profileCache[userId];
                    if (DateTime.Now - cached.cachedAt < CacheExpiry)
                    {
                        return (cached.imageUrl, cached.initials);
                    }
                    else
                    {
                        profileCache.Remove(userId);
                    }
                }

                // Load from Firestore
                var userRef = db.Collection("users").Document(userId);
                var userSnap = await userRef.GetSnapshotAsync();

                if (userSnap.Exists)
                {
                    var userData = userSnap.ToDictionary();
                    string profileImageUrl = GetSafeValue(userData, "profileImageUrl");
                    string firstName = GetSafeValue(userData, "firstName");
                    string lastName = GetSafeValue(userData, "lastName");
                    string initials = GenerateUserInitials(firstName, lastName, username);

                    // Cache the result
                    profileCache[userId] = (profileImageUrl, initials, DateTime.Now);

                    return (profileImageUrl, initials);
                }

                return ("", GenerateUserInitials("", "", username));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading profile for {userId}: {ex.Message}");
                return ("", GenerateUserInitials("", "", username));
            }
        }

        private async Task<List<dynamic>> LoadAttachmentsForPost(string postId)
        {
            var attachments = new List<dynamic>();
            try
            {
                var attachmentSnaps = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document(postId)
                    .Collection("attachments").GetSnapshotAsync();

                foreach (var aDoc in attachmentSnaps.Documents)
                {
                    var a = aDoc.ToDictionary();
                    attachments.Add(new
                    {
                        fileName = a.GetValueOrDefault("fileName", "").ToString(),
                        fileUrl = a.GetValueOrDefault("fileUrl", "").ToString(),
                        fileType = a.GetValueOrDefault("fileType", "").ToString(),
                        fileSize = a.GetValueOrDefault("fileSize", 0)
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading attachments: {ex.Message}");
            }

            return attachments;
        }

        // Keep all existing post and comment management methods...
        // [Previous methods like btnPost_Click, HandleFileUploads, rptPosts_ItemCommand, etc. remain the same]

        protected async void btnPost_Click(object sender, EventArgs e)
        {
            try
            {
                string content = txtPostContent.Text.Trim();
                bool hasFiles = fileUpload.HasFiles && fileUpload.PostedFiles.Count > 0;

                // Allow posts with either content OR files (or both)
                if (string.IsNullOrEmpty(content) && !hasFiles)
                {
                    ShowMessage("Please enter some content or attach a file for your post.", "warning");
                    return;
                }

                // Create the post first
                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document();
                string postId = postRef.Id;

                var postData = new Dictionary<string, object>
                {
                    { "content", content ?? "" },
                    { "postedBy", currentUserId },
                    { "postedByName", chkAnonymous.Checked ? "Anonymous" : currentUsername },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "likes", new List<string>() },
                    { "saves", new List<string>() },
                    { "shares", new List<string>() },
                    { "reports", new List<string>() },
                    { "isAnonymous", chkAnonymous.Checked },
                    { "hasAttachments", hasFiles },
                    { "hasReports", false },
                    { "reportCount", 0 }
                };

                await postRef.SetAsync(postData);

                // Handle file attachments AFTER creating the post
                if (hasFiles)
                {
                    bool uploadSuccess = await HandleFileUploads(postId);
                    if (!uploadSuccess)
                    {
                        ShowMessage("Post created but some files failed to upload. Please try again.", "warning");
                    }
                }

                // Create activity log
                await LogGroupActivity("post_created", $"New post created by {(chkAnonymous.Checked ? "Anonymous" : currentUsername)}");

                // Clear form
                txtPostContent.Text = "";
                chkAnonymous.Checked = false;
                fileUpload.Attributes.Clear();

                // Add script to clear file preview on client side
                ScriptManager.RegisterStartupScript(this, GetType(), "clearFiles", "clearFilesAfterPost();", true);

                // Reload posts
                await LoadPosts();

                ShowMessage("Post created successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error creating post: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"Post creation error: {ex}");
            }
        }

        private async Task<bool> HandleFileUploads(string postId)
        {
            bool allUploadsSuccessful = true;

            try
            {
                // Verify Cloudinary configuration exists
                string cloudName = ConfigurationManager.AppSettings["CloudinaryCloudName"];
                string apiKey = ConfigurationManager.AppSettings["CloudinaryApiKey"];
                string apiSecret = ConfigurationManager.AppSettings["CloudinaryApiSecret"];

                if (string.IsNullOrEmpty(cloudName) || string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(apiSecret))
                {
                    ShowMessage("Cloudinary configuration is missing. Please contact administrator.", "danger");
                    return false;
                }

                var account = new Account(cloudName, apiKey, apiSecret);
                var cloudinary = new Cloudinary(account);

                foreach (var file in fileUpload.PostedFiles)
                {
                    if (file != null && file.ContentLength > 0)
                    {
                        try
                        {
                            // Check file size (limit to 10MB)
                            if (file.ContentLength > 10 * 1024 * 1024)
                            {
                                ShowMessage($"File {file.FileName} is too large. Maximum size is 10MB.", "warning");
                                allUploadsSuccessful = false;
                                continue;
                            }

                            string uploadResult = "";
                            string fileType = file.ContentType;

                            // Reset stream position to beginning
                            file.InputStream.Position = 0;

                            if (fileType.StartsWith("image/"))
                            {
                                // Upload image
                                var uploadParams = new ImageUploadParams
                                {
                                    File = new FileDescription(file.FileName, file.InputStream),
                                    Folder = "studyhub_posts",
                                    Transformation = new Transformation().Quality("auto").FetchFormat("auto"),
                                    PublicId = $"post_{postId}_{DateTime.Now.Ticks}_{Path.GetFileNameWithoutExtension(file.FileName)}"
                                };

                                var result = await cloudinary.UploadAsync(uploadParams);

                                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                                {
                                    uploadResult = result.SecureUrl.ToString();
                                }
                                else
                                {
                                    System.Diagnostics.Debug.WriteLine($"Cloudinary upload failed: {result.Error?.Message}");
                                    allUploadsSuccessful = false;
                                    continue;
                                }
                            }
                            else
                            {
                                // Upload other files (documents)
                                var uploadParams = new RawUploadParams
                                {
                                    File = new FileDescription(file.FileName, file.InputStream),
                                    Folder = "studyhub_documents",
                                    PublicId = $"doc_{postId}_{DateTime.Now.Ticks}_{Path.GetFileNameWithoutExtension(file.FileName)}"
                                };

                                var result = await cloudinary.UploadAsync(uploadParams);

                                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                                {
                                    uploadResult = result.SecureUrl.ToString();
                                }
                                else
                                {
                                    System.Diagnostics.Debug.WriteLine($"Cloudinary upload failed: {result.Error?.Message}");
                                    allUploadsSuccessful = false;
                                    continue;
                                }
                            }

                            // Save attachment info to Firestore
                            if (!string.IsNullOrEmpty(uploadResult))
                            {
                                var attachmentRef = db.Collection("studyHubs").Document(groupId)
                                    .Collection("posts").Document(postId)
                                    .Collection("attachments").Document();

                                var attachmentData = new Dictionary<string, object>
                                {
                                    { "fileName", file.FileName },
                                    { "fileUrl", uploadResult },
                                    { "fileType", fileType },
                                    { "fileSize", file.ContentLength },
                                    { "uploadedBy", currentUserId },
                                    { "uploadedAt", Timestamp.GetCurrentTimestamp() }
                                };

                                await attachmentRef.SetAsync(attachmentData);
                                System.Diagnostics.Debug.WriteLine($"Successfully uploaded and saved: {file.FileName}");
                            }
                            else
                            {
                                allUploadsSuccessful = false;
                                ShowMessage($"Failed to upload {file.FileName}", "warning");
                            }
                        }
                        catch (Exception fileEx)
                        {
                            System.Diagnostics.Debug.WriteLine($"Error uploading file {file.FileName}: {fileEx}");
                            ShowMessage($"Error uploading {file.FileName}: {fileEx.Message}", "warning");
                            allUploadsSuccessful = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"General file upload error: {ex}");
                ShowMessage("Error uploading files: " + ex.Message, "danger");
                allUploadsSuccessful = false;
            }

            return allUploadsSuccessful;
        }

        // Keep all existing post interaction methods (rptPosts_ItemCommand, report handling, etc.)
        // [Previous interaction methods remain the same - like, save, share, edit, delete, report, etc.]

        protected async void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                string postId = e.CommandArgument.ToString();
                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document(postId);

                switch (e.CommandName)
                {
                    case "EditPost":
                        editingPostIds.Add(postId);
                        break;

                    case "CancelPost":
                        editingPostIds.Remove(postId);
                        break;

                    case "SavePost":
                        var txtEditPost = (TextBox)e.Item.FindControl("txtEditPost");
                        string newContent = txtEditPost.Text.Trim();

                        if (!string.IsNullOrEmpty(newContent))
                        {
                            await postRef.UpdateAsync(new Dictionary<string, object>
                            {
                                { "content", newContent },
                                { "lastModified", Timestamp.GetCurrentTimestamp() },
                                { "modifiedBy", currentUserId }
                            });
                            editingPostIds.Remove(postId);

                            await LogGroupActivity("post_edited", $"Post edited by {currentUsername}");
                        }
                        break;

                    case "DeletePost":
                        await DeletePost(postRef, postId);
                        break;

                    case "ToggleLike":
                        await HandleToggleLike(postRef);
                        break;

                    case "ToggleSave":
                        await HandleToggleSave(postRef);
                        break;

                    case "InternalShare":
                        await HandleInternalShare(postRef, postId);
                        break;

                    case "ReportPost":
                        await HandleReportPost(postId);
                        break;

                    case "AddComment":
                        await HandleAddComment(e, postId);
                        break;
                }

                await LoadPosts();
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred: " + ex.Message, "danger");
            }
        }

        // Keep all existing report handling methods...
        // [Previous report methods remain the same]

        protected async void btnSubmitReport_Click(object sender, EventArgs e)
        {
            try
            {
                string itemId = hdnReportItemId.Value;
                string itemType = hdnReportItemType.Value;
                string reason = ddlReportReason.SelectedValue;
                string details = txtReportDetails.Text.Trim();

                if (string.IsNullOrEmpty(itemId) || string.IsNullOrEmpty(itemType))
                {
                    ShowMessage("Invalid report data. Please try again.", "danger");
                    return;
                }

                if (string.IsNullOrEmpty(reason))
                {
                    ShowMessage("Please select a reason for reporting.", "warning");
                    return;
                }

                // Create comprehensive report based on type
                if (itemType == "post")
                {
                    await CreatePostReport(itemId, reason, details);
                }
                else if (itemType == "comment")
                {
                    await CreateCommentReport(itemId, reason, details);
                }
                else
                {
                    ShowMessage("Invalid report type.", "danger");
                    return;
                }

                // Clear form
                hdnReportItemId.Value = "";
                hdnReportItemType.Value = "";
                ddlReportReason.SelectedIndex = 0;
                txtReportDetails.Text = "";

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, GetType(), "closeReportModal",
                    @"var modal = bootstrap.Modal.getInstance(document.getElementById('reportModal')); 
                      if (modal) modal.hide();", true);

                ShowMessage("Report submitted successfully. Thank you for helping keep our community safe.", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error submitting report: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"btnSubmitReport_Click error: {ex}");
            }
        }

        private async Task CreatePostReport(string postId, string reason, string details)
        {
            try
            {
                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document(postId);
                var postSnap = await postRef.GetSnapshotAsync();

                if (!postSnap.Exists)
                {
                    ShowMessage("Post not found.", "warning");
                    return;
                }

                var postData = postSnap.ToDictionary();
                string postContent = postData.GetValueOrDefault("content", "").ToString();
                string postAuthor = postData.GetValueOrDefault("postedByName", "").ToString();
                string postAuthorId = postData.GetValueOrDefault("postedBy", "").ToString();
                var postTimestamp = postData.ContainsKey("timestamp") ?
                    ((Timestamp)postData["timestamp"]).ToDateTime() : DateTime.UtcNow;

                // Check if user has already reported this post
                var existingReportQuery = db.Collection("reports")
                    .WhereEqualTo("reporterId", currentUserId)
                    .WhereEqualTo("reportedItemId", postId)
                    .WhereEqualTo("reportedItemType", "post");

                var existingReports = await existingReportQuery.GetSnapshotAsync();
                if (existingReports.Count > 0)
                {
                    ShowMessage("You have already reported this post.", "warning");
                    return;
                }

                // Get group information
                var groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                string groupName = "Unknown Group";
                if (groupSnap.Exists)
                {
                    var groupData = groupSnap.ToDictionary();
                    groupName = groupData.GetValueOrDefault("groupName", "Unknown Group").ToString();
                }

                // Create comprehensive report
                var reportRef = db.Collection("reports").Document();
                var reportData = new Dictionary<string, object>
                {
                    // Report metadata
                    { "reportId", reportRef.Id },
                    { "reporterId", currentUserId },
                    { "reporterName", currentUsername },
                    { "reportedAt", Timestamp.GetCurrentTimestamp() },
                    { "status", "pending" },
                    { "isResolved", false },
                    { "priority", GetReportPriority(reason) },
                    
                    // Reported content details
                    { "reportedItemId", postId },
                    { "reportedItemType", "post" },
                    { "reportedContent", postContent },
                    { "reportedContentLength", postContent.Length },
                    
                    // Author details
                    { "reportedAuthor", postAuthor },
                    { "reportedAuthorId", postAuthorId },
                    
                    // Context information
                    { "groupId", groupId },
                    { "groupName", groupName },
                    { "originalTimestamp", Timestamp.FromDateTime(postTimestamp) },
                    
                    // Report details
                    { "reason", reason },
                    { "reasonText", GetReasonText(reason) },
                    { "details", details ?? "" },
                    { "hasDetails", !string.IsNullOrEmpty(details) },
                    
                    // Admin workflow
                    { "reviewedBy", "" },
                    { "reviewedAt", null },
                    { "adminAction", "" },
                    { "adminNotes", "" },
                    { "actionTaken", false },
                    
                    // Analytics
                    { "reportCount", 1 },
                    { "lastReportedAt", Timestamp.GetCurrentTimestamp() }
                };

                await reportRef.SetAsync(reportData);

                // Update post with report flag (optional - for quick identification)
                await postRef.UpdateAsync(new Dictionary<string, object>
                {
                    { "hasReports", true },
                    { "reportCount", FieldValue.Increment(1) },
                    { "lastReportedAt", Timestamp.GetCurrentTimestamp() }
                });

                // Log activity
                await LogGroupActivity("post_reported", $"{currentUsername} reported a post by {postAuthor}");

                // Create notification for admins
                await CreateAdminNotification("post_report", $"New post report: {GetReasonText(reason)}", reportRef.Id);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CreatePostReport error: {ex}");
                throw;
            }
        }

        private async Task CreateCommentReport(string commentId, string reason, string details)
        {
            try
            {
                // Find the comment across all posts in the group
                var postsSnapshot = await db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").GetSnapshotAsync();

                DocumentSnapshot commentSnap = null;
                string parentPostId = "";

                foreach (var postDoc in postsSnapshot.Documents)
                {
                    var commentRef = postDoc.Reference.Collection("comments").Document(commentId);
                    var tempCommentSnap = await commentRef.GetSnapshotAsync();
                    if (tempCommentSnap.Exists)
                    {
                        commentSnap = tempCommentSnap;
                        parentPostId = postDoc.Id;
                        break;
                    }
                }

                if (commentSnap == null)
                {
                    ShowMessage("Comment not found.", "warning");
                    return;
                }

                var commentData = commentSnap.ToDictionary();
                string commentContent = commentData.GetValueOrDefault("text", "").ToString();
                string commentAuthor = commentData.GetValueOrDefault("commenterName", "").ToString();
                string commentAuthorId = commentData.GetValueOrDefault("commenterId", "").ToString();
                var commentTimestamp = commentData.ContainsKey("timestamp") ?
                    ((Timestamp)commentData["timestamp"]).ToDateTime() : DateTime.UtcNow;

                // Check if user has already reported this comment
                var existingReportQuery = db.Collection("reports")
                    .WhereEqualTo("reporterId", currentUserId)
                    .WhereEqualTo("reportedItemId", commentId)
                    .WhereEqualTo("reportedItemType", "comment");

                var existingReports = await existingReportQuery.GetSnapshotAsync();
                if (existingReports.Count > 0)
                {
                    ShowMessage("You have already reported this comment.", "warning");
                    return;
                }

                // Get group information
                var groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                string groupName = "Unknown Group";
                if (groupSnap.Exists)
                {
                    var groupData = groupSnap.ToDictionary();
                    groupName = groupData.GetValueOrDefault("groupName", "Unknown Group").ToString();
                }

                // Create comprehensive report
                var reportRef = db.Collection("reports").Document();
                var reportData = new Dictionary<string, object>
                {
                    // Report metadata
                    { "reportId", reportRef.Id },
                    { "reporterId", currentUserId },
                    { "reporterName", currentUsername },
                    { "reportedAt", Timestamp.GetCurrentTimestamp() },
                    { "status", "pending" },
                    { "isResolved", false },
                    { "priority", GetReportPriority(reason) },
                    
                    // Reported content details
                    { "reportedItemId", commentId },
                    { "reportedItemType", "comment" },
                    { "reportedContent", commentContent },
                    { "reportedContentLength", commentContent.Length },
                    { "parentPostId", parentPostId },
                    
                    // Author details
                    { "reportedAuthor", commentAuthor },
                    { "reportedAuthorId", commentAuthorId },
                    
                    // Context information
                    { "groupId", groupId },
                    { "groupName", groupName },
                    { "originalTimestamp", Timestamp.FromDateTime(commentTimestamp) },
                    
                    // Report details
                    { "reason", reason },
                    { "reasonText", GetReasonText(reason) },
                    { "details", details ?? "" },
                    { "hasDetails", !string.IsNullOrEmpty(details) },
                    
                    // Admin workflow
                    { "reviewedBy", "" },
                    { "reviewedAt", null },
                    { "adminAction", "" },
                    { "adminNotes", "" },
                    { "actionTaken", false },
                    
                    // Analytics
                    { "reportCount", 1 },
                    { "lastReportedAt", Timestamp.GetCurrentTimestamp() }
                };

                await reportRef.SetAsync(reportData);

                // Update comment with report flag
                await commentSnap.Reference.UpdateAsync(new Dictionary<string, object>
                {
                    { "hasReports", true },
                    { "reportCount", FieldValue.Increment(1) },
                    { "lastReportedAt", Timestamp.GetCurrentTimestamp() }
                });

                // Log activity
                await LogGroupActivity("comment_reported", $"{currentUsername} reported a comment by {commentAuthor}");

                // Create notification for admins
                await CreateAdminNotification("comment_report", $"New comment report: {GetReasonText(reason)}", reportRef.Id);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CreateCommentReport error: {ex}");
                throw;
            }
        }

        // Helper methods for reports
        private string GetReportPriority(string reason)
        {
            switch (reason?.ToLower())
            {
                case "violence":
                case "hate_speech":
                case "harassment":
                    return "high";
                case "inappropriate_content":
                case "false_info":
                    return "medium";
                case "spam":
                case "other":
                default:
                    return "low";
            }
        }

        private string GetReasonText(string reason)
        {
            switch (reason?.ToLower())
            {
                case "inappropriate_content":
                    return "Inappropriate Content";
                case "harassment":
                    return "Harassment or Bullying";
                case "spam":
                    return "Spam";
                case "hate_speech":
                    return "Hate Speech";
                case "violence":
                    return "Violence or Threats";
                case "false_info":
                    return "False Information";
                case "other":
                    return "Other";
                default:
                    return "Unspecified";
            }
        }

        private async Task CreateAdminNotification(string type, string message, string reportId)
        {
            try
            {
                // Get all admin users
                var adminQuery = db.Collection("users")
                    .WhereEqualTo("position", "Administrator")
                    .WhereEqualTo("isActive", true);

                var adminSnapshot = await adminQuery.GetSnapshotAsync();

                foreach (var adminDoc in adminSnapshot.Documents)
                {
                    var notificationRef = db.Collection("users").Document(adminDoc.Id)
                        .Collection("notifications").Document();

                    await notificationRef.SetAsync(new Dictionary<string, object>
                    {
                        { "type", type },
                        { "message", message },
                        { "reportId", reportId },
                        { "fromUserId", currentUserId },
                        { "fromUsername", currentUsername },
                        { "groupId", groupId },
                        { "isRead", false },
                        { "isAdmin", true },
                        { "timestamp", Timestamp.GetCurrentTimestamp() }
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CreateAdminNotification error: {ex}");
                // Don't throw - this is not critical
            }
        }

        // Keep all other existing methods (delete post, toggle like/save, etc.)
        // [Previous methods remain the same...]

        private async Task DeletePost(DocumentReference postRef, string postId)
        {
            try
            {
                // Verify ownership
                var postSnap = await postRef.GetSnapshotAsync();
                if (postSnap.Exists)
                {
                    var postData = postSnap.ToDictionary();
                    if (postData.GetValueOrDefault("postedBy", "").ToString() == currentUserId)
                    {
                        // Delete all subcollections first
                        await DeleteSubcollection(postRef.Collection("comments"));
                        await DeleteSubcollection(postRef.Collection("attachments"));

                        // Delete the post
                        await postRef.DeleteAsync();

                        await LogGroupActivity("post_deleted", $"Post deleted by {currentUsername}");
                        ShowMessage("Post deleted successfully.", "success");
                    }
                    else
                    {
                        ShowMessage("You can only delete your own posts.", "warning");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting post: " + ex.Message, "danger");
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

        private async Task HandleToggleLike(DocumentReference postRef)
        {
            var postSnap = await postRef.GetSnapshotAsync();
            if (!postSnap.Exists) return;

            var postData = postSnap.ToDictionary();
            var likes = postData.ContainsKey("likes") ?
                ((List<object>)postData["likes"]).Cast<string>().ToList() :
                new List<string>();

            bool wasLiked = likes.Contains(currentUserId);

            if (wasLiked)
            {
                likes.Remove(currentUserId);
            }
            else
            {
                likes.Add(currentUserId);

                // Create notification for post owner
                string postOwnerId = postData.GetValueOrDefault("postedBy", "").ToString();
                if (postOwnerId != currentUserId)
                {
                    await CreateNotification(postOwnerId, "like", $"{currentUsername} liked your post");
                }
            }

            await postRef.UpdateAsync("likes", likes);

            // Log activity
            await LogGroupActivity("post_liked", $"{currentUsername} {(wasLiked ? "unliked" : "liked")} a post");
        }

        private async Task HandleToggleSave(DocumentReference postRef)
        {
            var postSnap = await postRef.GetSnapshotAsync();
            if (!postSnap.Exists) return;

            var postData = postSnap.ToDictionary();
            var saves = postData.ContainsKey("saves") ?
                ((List<object>)postData["saves"]).Cast<string>().ToList() :
                new List<string>();

            if (saves.Contains(currentUserId))
            {
                saves.Remove(currentUserId);
                ShowMessage("Post removed from saved items.", "info");
            }
            else
            {
                saves.Add(currentUserId);
                ShowMessage("Post saved successfully!", "success");

                // Save to user's saved posts collection
                await SaveToUserCollection(postRef.Id);
            }

            await postRef.UpdateAsync("saves", saves);
        }

        private async Task SaveToUserCollection(string postId)
        {
            try
            {
                var userSaveRef = db.Collection("users").Document(currentUserId)
                    .Collection("savedPosts").Document(postId);

                await userSaveRef.SetAsync(new Dictionary<string, object>
                {
                    { "postId", postId },
                    { "groupId", groupId },
                    { "savedAt", Timestamp.GetCurrentTimestamp() }
                });
            }
            catch
            {
                // Log error but don't fail
            }
        }

        private async Task HandleInternalShare(DocumentReference postRef, string postId)
        {
            var postSnap = await postRef.GetSnapshotAsync();
            if (!postSnap.Exists) return;

            var postData = postSnap.ToDictionary();
            var shares = postData.ContainsKey("shares") ?
                ((List<object>)postData["shares"]).Cast<string>().ToList() :
                new List<string>();

            if (!shares.Contains(currentUserId))
            {
                shares.Add(currentUserId);
                await postRef.UpdateAsync("shares", shares);

                // Create a share activity
                await CreateShareActivity(postId, postData);

                ShowMessage("Post shared to your timeline!", "success");
            }
            else
            {
                ShowMessage("You have already shared this post.", "info");
            }
        }

        private async Task CreateShareActivity(string postId, Dictionary<string, object> postData)
        {
            try
            {
                var shareRef = db.Collection("users").Document(currentUserId)
                    .Collection("timeline").Document();

                await shareRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", "share" },
                    { "originalPostId", postId },
                    { "originalGroupId", groupId },
                    { "originalContent", postData.GetValueOrDefault("content", "") },
                    { "originalAuthor", postData.GetValueOrDefault("postedByName", "") },
                    { "sharedBy", currentUserId },
                    { "sharedByName", currentUsername },
                    { "sharedAt", Timestamp.GetCurrentTimestamp() }
                });

                await LogGroupActivity("post_shared", $"{currentUsername} shared a post");
            }
            catch
            {
                // Log error but don't fail
            }
        }

        private async Task HandleReportPost(string postId)
        {
            try
            {
                // Get the post details for the report
                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document(postId);
                var postSnap = await postRef.GetSnapshotAsync();

                if (!postSnap.Exists)
                {
                    ShowMessage("Post not found.", "warning");
                    return;
                }

                var postData = postSnap.ToDictionary();

                // Create detailed report
                var reportRef = db.Collection("reports").Document();
                await reportRef.SetAsync(new Dictionary<string, object>
                {
                    { "reporterId", currentUserId },
                    { "reporterName", currentUsername },
                    { "reportedItemId", postId },
                    { "reportedItemType", "post" },
                    { "reportedContent", postData.GetValueOrDefault("content", "").ToString() },
                    { "reportedBy_PostAuthor", postData.GetValueOrDefault("postedByName", "").ToString() },
                    { "reportedBy_PostAuthorId", postData.GetValueOrDefault("postedBy", "").ToString() },
                    { "groupId", groupId },
                    { "groupName", await GetGroupName() },
                    { "reason", "inappropriate_content" }, // Default reason
                    { "status", "pending" },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "isResolved", false },
                    { "reportedAt", DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss UTC") }
                });

                // Log the report action
                await LogGroupActivity("post_reported", $"{currentUsername} reported a post");

                ShowMessage("Post reported successfully. Thank you for helping keep our community safe.", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error submitting report: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"HandleReportPost error: {ex}");
            }
        }

        private async Task<string> GetGroupName()
        {
            try
            {
                var groupSnap = await db.Collection("studyHubs").Document(groupId).GetSnapshotAsync();
                if (groupSnap.Exists)
                {
                    var groupData = groupSnap.ToDictionary();
                    return groupData.GetValueOrDefault("groupName", "Unknown Group").ToString();
                }
                return "Unknown Group";
            }
            catch
            {
                return "Unknown Group";
            }
        }

        private async Task HandleAddComment(RepeaterCommandEventArgs e, string postId)
        {
            var txtNewComment = (TextBox)e.Item.FindControl("txtNewComment");
            var chkAnonymousComment = (CheckBox)e.Item.FindControl("chkAnonymousComment");

            string commentText = txtNewComment.Text.Trim();

            if (!string.IsNullOrEmpty(commentText))
            {
                var commentRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document(postId)
                    .Collection("comments").Document();

                await commentRef.SetAsync(new Dictionary<string, object>
                {
                    { "commenterId", currentUserId },
                    { "commenterName", chkAnonymousComment.Checked ? "Anonymous" : currentUsername },
                    { "text", commentText },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "likes", new List<string>() },
                    { "isAnonymous", chkAnonymousComment.Checked },
                    { "hasReports", false },
                    { "reportCount", 0 }
                });

                // Create notification for post owner
                var postRef = db.Collection("studyHubs").Document(groupId).Collection("posts").Document(postId);
                var postSnap = await postRef.GetSnapshotAsync();
                if (postSnap.Exists)
                {
                    var postData = postSnap.ToDictionary();
                    string postOwnerId = postData.GetValueOrDefault("postedBy", "").ToString();

                    if (postOwnerId != currentUserId)
                    {
                        await CreateNotification(postOwnerId, "comment",
                            $"{(chkAnonymousComment.Checked ? "Someone" : currentUsername)} commented on your post");
                    }
                }

                txtNewComment.Text = "";
                chkAnonymousComment.Checked = false;

                await LogGroupActivity("comment_created", $"New comment by {(chkAnonymousComment.Checked ? "Anonymous" : currentUsername)}");
            }
        }

        protected async void rptComments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                var args = e.CommandArgument.ToString().Split('|');
                string postId = args[0];
                string commentId = args[1];
                string key = postId + "|" + commentId;

                var commentRef = db.Collection("studyHubs").Document(groupId)
                                    .Collection("posts").Document(postId)
                                    .Collection("comments").Document(commentId);

                switch (e.CommandName)
                {
                    case "EditComment":
                        editingCommentKeys.Add(key);
                        break;

                    case "CancelComment":
                        editingCommentKeys.Remove(key);
                        break;

                    case "SaveComment":
                        var txtEditComment = (TextBox)e.Item.FindControl("txtEditComment");
                        string updatedText = txtEditComment.Text.Trim();

                        if (!string.IsNullOrEmpty(updatedText))
                        {
                            await commentRef.UpdateAsync(new Dictionary<string, object>
                            {
                                { "text", updatedText },
                                { "lastModified", Timestamp.GetCurrentTimestamp() },
                                { "modifiedBy", currentUserId }
                            });
                            editingCommentKeys.Remove(key);

                            await LogGroupActivity("comment_edited", $"Comment edited by {currentUsername}");
                        }
                        break;

                    case "DeleteComment":
                        // Verify ownership
                        var commentSnap = await commentRef.GetSnapshotAsync();
                        if (commentSnap.Exists)
                        {
                            var commentData = commentSnap.ToDictionary();
                            if (commentData.GetValueOrDefault("commenterId", "").ToString() == currentUserId)
                            {
                                await commentRef.DeleteAsync();
                                await LogGroupActivity("comment_deleted", $"Comment deleted by {currentUsername}");
                                ShowMessage("Comment deleted successfully.", "success");
                            }
                            else
                            {
                                ShowMessage("You can only delete your own comments.", "warning");
                            }
                        }
                        break;

                    case "ReportComment":
                        await HandleReportComment(postId, commentId);
                        break;
                }

                await LoadPosts();
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"rptComments_ItemCommand error: {ex}");
            }
        }

        private async Task HandleReportComment(string postId, string commentId)
        {
            try
            {
                // Get the comment details for the report
                var commentRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("posts").Document(postId)
                    .Collection("comments").Document(commentId);
                var commentSnap = await commentRef.GetSnapshotAsync();

                if (!commentSnap.Exists)
                {
                    ShowMessage("Comment not found.", "warning");
                    return;
                }

                var commentData = commentSnap.ToDictionary();

                // Create detailed report
                var reportRef = db.Collection("reports").Document();
                await reportRef.SetAsync(new Dictionary<string, object>
                {
                    { "reporterId", currentUserId },
                    { "reporterName", currentUsername },
                    { "reportedItemId", commentId },
                    { "reportedItemType", "comment" },
                    { "reportedContent", commentData.GetValueOrDefault("text", "").ToString() },
                    { "reportedBy_CommentAuthor", commentData.GetValueOrDefault("commenterName", "").ToString() },
                    { "reportedBy_CommentAuthorId", commentData.GetValueOrDefault("commenterId", "").ToString() },
                    { "parentPostId", postId },
                    { "groupId", groupId },
                    { "groupName", await GetGroupName() },
                    { "reason", "inappropriate_content" }, // Default reason
                    { "status", "pending" },
                    { "timestamp", Timestamp.GetCurrentTimestamp() },
                    { "isResolved", false },
                    { "reportedAt", DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss UTC") }
                });

                // Log the report action
                await LogGroupActivity("comment_reported", $"{currentUsername} reported a comment");

                ShowMessage("Comment reported successfully. Thank you for helping keep our community safe.", "success");
            }
            catch (Exception ex)
            {
                ShowMessage("Error submitting report: " + ex.Message, "danger");
                System.Diagnostics.Debug.WriteLine($"HandleReportComment error: {ex}");
            }
        }

        private async Task CreateNotification(string userId, string type, string message)
        {
            try
            {
                var notificationRef = db.Collection("users").Document(userId)
                    .Collection("notifications").Document();

                await notificationRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", type },
                    { "message", message },
                    { "fromUserId", currentUserId },
                    { "fromUsername", currentUsername },
                    { "groupId", groupId },
                    { "isRead", false },
                    { "timestamp", Timestamp.GetCurrentTimestamp() }
                });
            }
            catch
            {
                // Log error but don't fail the main operation
            }
        }

        private async Task LogGroupActivity(string activityType, string description)
        {
            try
            {
                var activityRef = db.Collection("studyHubs").Document(groupId)
                    .Collection("activities").Document();

                await activityRef.SetAsync(new Dictionary<string, object>
                {
                    { "type", activityType },
                    { "description", description },
                    { "userId", currentUserId },
                    { "username", currentUsername },
                    { "timestamp", Timestamp.GetCurrentTimestamp() }
                });
            }
            catch
            {
                // Log error but don't fail the main operation
            }
        }

        // Helper methods
        private string GenerateUserInitials(string firstName, string lastName, string username)
        {
            if (!string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
            {
                return (firstName.Substring(0, 1) + lastName.Substring(0, 1)).ToUpper();
            }
            else if (!string.IsNullOrEmpty(username))
            {
                return username.Length >= 2 ? username.Substring(0, 2).ToUpper() : username.Substring(0, 1).ToUpper();
            }
            return "?";
        }

        private string GetSafeValue(Dictionary<string, object> dictionary, string key, string defaultValue = "")
        {
            if (dictionary == null || !dictionary.ContainsKey(key) || dictionary[key] == null)
            {
                return defaultValue;
            }
            return dictionary[key].ToString();
        }

        private void ShowMessage(string message, string type)
        {
            string alertClass = type == "success" ? "alert-success" :
                               type == "warning" ? "alert-warning" :
                               type == "info" ? "alert-info" :
                               "alert-danger";

            string script = $@"
                showNotification('{message.Replace("'", "\\'")}', '{type}');
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "showMessage", script, true);
        }
    }
}