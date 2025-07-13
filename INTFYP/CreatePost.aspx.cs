using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI;
using Google.Cloud.Firestore;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;

namespace YourProjectNamespace
{
    public partial class CreatePost : System.Web.UI.Page
    {
        private FirestoreDb db;

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
                await LoadTeacherClassesAsync();
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

        private async System.Threading.Tasks.Task LoadTeacherClassesAsync()
        {
            string email = Session["email"]?.ToString()?.ToLower();
            if (string.IsNullOrEmpty(email)) return;

            QuerySnapshot snapshot = await db.Collection("classrooms")
                .WhereEqualTo("createdBy", email)
                .GetSnapshotAsync();

            var classList = new List<ClassItem>();
            foreach (var doc in snapshot.Documents)
            {
                string name = doc.ContainsField("name") ? doc.GetValue<string>("name") : "(Unnamed)";
                classList.Add(new ClassItem
                {
                    Id = doc.Id,
                    Name = name
                });
            }

            ddlClasses.DataSource = classList;
            ddlClasses.DataTextField = "Name";
            ddlClasses.DataValueField = "Id";
            ddlClasses.DataBind();
        }

        protected async void btnSubmitPost_Click(object sender, EventArgs e)
        {
            string classId = ddlClasses.SelectedValue;
            string title = txtPostTitle.Text.Trim();
            string content = txtPostContent.Text.Trim();
            string type = ddlPostType.SelectedValue;
            string scheduleInput = txtScheduleDate.Text.Trim();
            string userEmail = Session["email"]?.ToString()?.ToLower();

            if (string.IsNullOrEmpty(classId) || string.IsNullOrEmpty(content))
            {
                lblStatus.Text = "Please fill in all required fields.";
                lblStatus.Visible = true;
                return;
            }

            string fileUrl = null;
            string fileName = null;

            if (FileUpload1.HasFile)
            {
                try
                {
                    var account = new Account(
                        ConfigurationManager.AppSettings["CloudinaryCloudName"],
                        ConfigurationManager.AppSettings["CloudinaryApiKey"],
                        ConfigurationManager.AppSettings["CloudinaryApiSecret"]
                    );

                    var cloudinary = new Cloudinary(account);

                    var uploadParams = new RawUploadParams
                    {
                        File = new FileDescription(FileUpload1.FileName, FileUpload1.PostedFile.InputStream),
                        Folder = "class_posts"
                    };

                    var uploadResult = cloudinary.Upload(uploadParams);
                    fileUrl = uploadResult.SecureUrl.ToString();
                    fileName = uploadResult.OriginalFilename;
                }
                catch (Exception ex)
                {
                    lblStatus.Text = "File upload failed: " + ex.Message;
                    lblStatus.Visible = true;
                    return;
                }
            }

            // Retrieve class name
            string className = "(Unknown)";
            DocumentSnapshot classDoc = await db.Collection("classrooms").Document(classId).GetSnapshotAsync();
            if (classDoc.Exists && classDoc.ContainsField("name"))
                className = classDoc.GetValue<string>("name");

            Timestamp postTime = Timestamp.GetCurrentTimestamp();
            if (DateTime.TryParse(scheduleInput, out DateTime scheduledDate))
                postTime = Timestamp.FromDateTime(scheduledDate.ToUniversalTime());

            var postData = new Dictionary<string, object>
            {
                { "title", title },
                { "content", content },
                { "postType", type },
                { "postedAt", postTime },
                { "createdBy", userEmail },
                { "classId", classId },
                { "className", className },
                { "fileUrl", fileUrl },
                { "fileName", fileName },
                { "visibleTo", new List<string>() }
            };

            DocumentReference newPost = await db.Collection("classrooms").Document(classId)
                .Collection("posts").AddAsync(postData);

            // Success feedback
            lblStatus.Text = $"Post created for <strong>{className}</strong> at <em>{postTime.ToDateTime().ToLocalTime():f}</em>.<br />Post ID: {newPost.Id}";
            lblStatus.Visible = true;

            // Clear fields
            txtPostTitle.Text = "";
            txtPostContent.Text = "";
            ddlPostType.SelectedIndex = 0;
            ddlClasses.SelectedIndex = 0;
            txtScheduleDate.Text = "";
        }

        public class ClassItem
        {
            public string Id { get; set; }
            public string Name { get; set; }
        }
    }
}
