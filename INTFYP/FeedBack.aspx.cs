using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;

namespace YourProjectNamespace
{
    public partial class Feedback : System.Web.UI.Page
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
            lblMessage.Visible = true;

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

            string mediaUrl = await UploadFileIfAny();

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

            await db.Collection("feedbacks").AddAsync(feedback);

            lblMessage.CssClass = "text-success";
            lblMessage.Text = "Feedback submitted successfully!";
            txtDescription.Text = "";

            await LoadAllFeedbacks();
        }

        private async Task<string> UploadFileIfAny()
        {
            if (!fileUpload.HasFile) return null;

            var account = new Account(
                System.Configuration.ConfigurationManager.AppSettings["CloudinaryCloudName"],
                System.Configuration.ConfigurationManager.AppSettings["CloudinaryApiKey"],
                System.Configuration.ConfigurationManager.AppSettings["CloudinaryApiSecret"]
            );

            var cloudinary = new Cloudinary(account);

            using (var stream = fileUpload.PostedFile.InputStream)
            {
                string ext = Path.GetExtension(fileUpload.FileName).ToLower();

                if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif")
                {
                    var uploadParams = new ImageUploadParams
                    {
                        File = new FileDescription(fileUpload.FileName, stream),
                        Folder = "feedback_images"
                    };
                    var uploadResult = cloudinary.Upload(uploadParams);
                    return uploadResult.SecureUrl?.ToString();
                }
                else if (ext == ".mp4" || ext == ".mov" || ext == ".avi" || ext == ".webm")
                {
                    var uploadParams = new VideoUploadParams
                    {
                        File = new FileDescription(fileUpload.FileName, stream),
                        Folder = "feedback_videos"
                    };
                    var uploadResult = cloudinary.Upload(uploadParams);
                    return uploadResult.SecureUrl?.ToString();
                }
            }

            return null;
        }

        private async Task LoadAllFeedbacks()
        {
            var feedbacks = new System.Collections.Generic.List<dynamic>();
            QuerySnapshot snapshot = await db.Collection("feedbacks").OrderByDescending("createdAt").GetSnapshotAsync();

            foreach (var doc in snapshot.Documents)
            {
                var data = doc.ToDictionary();
                feedbacks.Add(new
                {
                    PostId = doc.Id,
                    Username = data["username"]?.ToString(),
                    Description = data["description"]?.ToString(),
                    MediaUrl = data.ContainsKey("mediaUrl") ? data["mediaUrl"]?.ToString() : null,
                    Likes = (data["likes"] as System.Collections.Generic.IEnumerable<object>)?.Count() ?? 0
                });
            }

            rptFeedback.DataSource = feedbacks;
            rptFeedback.DataBind();
        }

        public string GetMediaHtml(string url)
        {
            if (string.IsNullOrEmpty(url)) return string.Empty;

            string ext = Path.GetExtension(url).ToLower();
            if (ext == ".mp4" || ext == ".webm")
                return $"<video controls width='100%' src='{url}' class='mb-2'></video>";
            else
                return $"<img src='{url}' class='img-fluid mb-2' />";
        }

        protected void rptFeedback_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Placeholder for Like/Comment functionality.
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
