using System;
using System.Configuration;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class AddFeedback : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();
        private Cloudinary cloudinary;

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
            InitializeCloudinary();
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

        private void InitializeCloudinary()
        {
            var account = new Account(
                ConfigurationManager.AppSettings["CloudinaryCloudName"],
                ConfigurationManager.AppSettings["CloudinaryApiKey"],
                ConfigurationManager.AppSettings["CloudinaryApiSecret"]
            );
            cloudinary = new Cloudinary(account);
        }

        protected async void btnPost_Click(object sender, EventArgs e)
        {
            try
            {
                string content = txtPostContent.Text.Trim();
                string imageUrl = string.Empty;

                // Validate content
                if (string.IsNullOrWhiteSpace(content))
                {
                    ShowStatus("Please enter some content for your post", false);
                    return;
                }

                // Upload image if exists
                if (fileImage.HasFile)
                {
                    var uploadParams = new ImageUploadParams()
                    {
                        File = new FileDescription(fileImage.FileName, fileImage.PostedFile.InputStream),
                        Folder = "feedback_posts",
                        Transformation = new Transformation().Width(800).Height(600).Crop("limit")
                    };

                    var uploadResult = await cloudinary.UploadAsync(uploadParams);
                    imageUrl = uploadResult.SecureUrl.ToString();
                }

                // Save to Firestore
                DocumentReference docRef = await db.Collection("social_posts").AddAsync(new
                {
                    Content = content,
                    ImageUrl = imageUrl,
                    Author = User.Identity.IsAuthenticated ? User.Identity.Name : "Anonymous",
                    Likes = 0,
                    Comments = new object[0],
                    Timestamp = Timestamp.GetCurrentTimestamp(),
                    CreatedAt = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
                });

                ShowStatus("Your post has been shared successfully!", true);

                // Clear form
                txtPostContent.Text = "";
                imgPreview.ImageUrl = "";
                imgPreview.Visible = false;
            }
            catch (Exception ex)
            {
                ShowStatus($"Error posting: {ex.Message}", false);
            }
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            lblStatus.CssClass = isSuccess ? "status-message success" : "status-message error";
        }
    }
}