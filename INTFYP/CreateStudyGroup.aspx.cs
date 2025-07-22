using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using System.Web.Configuration;
using System.Web.UI;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using static Google.Rpc.Context.AttributeContext.Types;

namespace YourProjectNamespace
{
    public partial class CreateStudyGroup : System.Web.UI.Page
    {
        private FirestoreDb db;
        protected string currentUserId;
        protected string currentUsername;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null || Session["username"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            currentUserId = Session["userId"].ToString();
            currentUsername = Session["username"].ToString();
            db = FirestoreDb.Create("intorannetto");
        }

        protected async void btnCreate_Click(object sender, EventArgs e)
        {
            string name = txtGroupName.Text.Trim();
            string capacity = txtCapacity.Text.Trim();
            string desc = txtDescription.Text.Trim();
            string imageUrl = "";

            if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(capacity))
            {
                lblMessage.Text = "Please fill in all required fields.";
                lblMessage.CssClass = "text-danger";
                return;
            }

            // ✅ Upload to Cloudinary if image selected
            if (fileGroupImage.HasFile)
            {
                try
                {
                    var account = new Account(
                        WebConfigurationManager.AppSettings["CloudinaryCloudName"],
                        WebConfigurationManager.AppSettings["CloudinaryApiKey"],
                        WebConfigurationManager.AppSettings["CloudinaryApiSecret"]
                    );
                    var cloudinary = new Cloudinary(account);

                    using (Stream fileStream = fileGroupImage.PostedFile.InputStream)
                    {
                        var uploadParams = new ImageUploadParams()
                        {
                            File = new FileDescription(fileGroupImage.FileName, fileStream),
                            Folder = "studyhub_groups"
                        };
                        var uploadResult = await cloudinary.UploadAsync(uploadParams);
                        imageUrl = uploadResult.SecureUrl.ToString();
                    }
                }
                catch (Exception ex)
                {
                    lblMessage.Text = "Image upload failed: " + ex.Message;
                    lblMessage.CssClass = "text-danger";
                    return;
                }
            }

            DocumentReference docRef = db.Collection("studyHubs").Document();
            Dictionary<string, object> data = new Dictionary<string, object>
            {
                { "groupName", name },
                { "capacity", capacity },
                { "description", desc },
                { "hosterId", currentUserId },
                { "hosterName", currentUsername },
                { "members", new List<string> { currentUserId } },
                { "createdAt", Timestamp.GetCurrentTimestamp() },
                { "groupImage", imageUrl }
            };

            await docRef.SetAsync(data);

            lblMessage.Text = "Study group created successfully!";
            lblMessage.CssClass = "text-success";
        }
    }
}
