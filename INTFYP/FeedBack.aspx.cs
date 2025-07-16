using Google.Cloud.Firestore;
using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;

namespace YourProjectNamespace
{
    public partial class Feedback : Page
    {
        private static FirestoreDb db;

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore();
                string userId = Session["userId"] as string;

                if (string.IsNullOrEmpty(userId))
                {
                    lblName.Text = "Not logged in";
                    return;
                }

                await LoadUserDetails(userId);
                await LoadAllFeedbacks();
            }
        }

        private void InitializeFirestore()
        {
            if (db == null)
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto");
            }
        }

        private async Task LoadUserDetails(string userId)
        {
            DocumentReference userRef = db.Collection("users").Document(userId);
            DocumentSnapshot snapshot = await userRef.GetSnapshotAsync();

            if (snapshot.Exists)
            {
                var data = snapshot.ToDictionary();

                lblName.Text = $"{data.GetValueOrDefault("firstName", "")} {data.GetValueOrDefault("lastName", "")}";
                lblUsername.Text = data.GetValueOrDefault("username", "").ToString();
                lblEmail.Text = data.GetValueOrDefault("email", "").ToString();
                lblPhone.Text = data.GetValueOrDefault("phone", "").ToString();
                lblGender.Text = data.GetValueOrDefault("gender", "").ToString();
                lblBirthdate.Text = data.GetValueOrDefault("birthdate", "").ToString();
                lblPosition.Text = data.GetValueOrDefault("position", "").ToString();
                lblAddress.Text = data.GetValueOrDefault("address", "").ToString();
                txtFeedbackUsername.Text = data.GetValueOrDefault("username", "").ToString();
            }
        }

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                string userId = Session["userId"]?.ToString();
                if (string.IsNullOrEmpty(userId))
                {
                    lblMessage.CssClass = "text-danger";
                    lblMessage.Text = "Please login to submit feedback.";
                    return;
                }

                string description = txtDescription.Text.Trim();
                if (string.IsNullOrWhiteSpace(description))
                {
                    lblMessage.CssClass = "text-danger";
                    lblMessage.Text = "Please enter feedback description.";
                    return;
                }

                string mediaUrl = null;
                if (fileUpload.HasFile)
                {
                    string folderPath = Server.MapPath("~/Uploads/");
                    if (!Directory.Exists(folderPath))
                        Directory.CreateDirectory(folderPath);

                    string fileName = Guid.NewGuid().ToString() + Path.GetExtension(fileUpload.FileName);
                    string fullPath = Path.Combine(folderPath, fileName);
                    fileUpload.SaveAs(fullPath);
                    mediaUrl = "Uploads/" + fileName;
                }

                var feedback = new
                {
                    userId,
                    username = Session["username"]?.ToString(),
                    email = Session["email"]?.ToString(),
                    description,
                    mediaUrl,
                    likes = new string[] { },
                    comments = new object[] { },
                    createdAt = Timestamp.GetCurrentTimestamp()
                };

                await db.Collection("feedback").AddAsync(feedback);

                lblMessage.CssClass = "text-success";
                lblMessage.Text = "Feedback submitted successfully!";
                txtDescription.Text = "";

                await LoadAllFeedbacks();
            }
            catch (Exception ex)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Error: " + ex.Message;
            }
        }

        private async Task LoadAllFeedbacks()
        {
            var feedbackHtml = new StringBuilder();
            QuerySnapshot snapshot = await db.Collection("feedback").OrderByDescending("createdAt").GetSnapshotAsync();

            foreach (var doc in snapshot.Documents)
            {
                var data = doc.ToDictionary();
                string username = data["username"]?.ToString();
                string description = data["description"]?.ToString();
                string mediaUrl = data.ContainsKey("mediaUrl") ? data["mediaUrl"]?.ToString() : null;
                string postId = doc.Id;

                feedbackHtml.Append("<div class='card p-3 mb-3 shadow-sm'>");
                feedbackHtml.Append($"<h6><strong>{username}</strong></h6>");
                feedbackHtml.Append($"<p>{description}</p>");
                if (!string.IsNullOrEmpty(mediaUrl))
                {
                    string ext = Path.GetExtension(mediaUrl).ToLower();
                    if (ext == ".mp4" || ext == ".webm")
                        feedbackHtml.Append($"<video controls width='100%' src='{mediaUrl}' class='mb-2'></video>");
                    else
                        feedbackHtml.Append($"<img src='{mediaUrl}' class='img-fluid mb-2' />");
                }

                feedbackHtml.Append("<hr class='my-2' />");
                feedbackHtml.Append("<div class='d-flex align-items-center justify-content-between'>");
                feedbackHtml.Append($"<button class='btn btn-sm btn-outline-primary' disabled>Like</button>");
                feedbackHtml.Append($"<span class='text-muted small'>Comments feature coming soon</span>");
                feedbackHtml.Append("</div>");
                feedbackHtml.Append("</div>");
            }

            feedbackPosts.InnerHtml = feedbackHtml.ToString();
        }
    }

    public static class FirestoreExtensions
    {
        public static object GetValueOrDefault(this System.Collections.Generic.IDictionary<string, object> dict, string key, object defaultValue)
        {
            return dict.ContainsKey(key) ? dict[key] : defaultValue;
        }
    }
}
