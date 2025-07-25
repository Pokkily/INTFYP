﻿using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI;
using Google.Cloud.Firestore;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Newtonsoft.Json;

namespace YourProjectNamespace
{
    public partial class CreatePost : System.Web.UI.Page
    {
        private FirestoreDb db;

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
            {
                await LoadTeacherClassesAsync();
                UploadedFiles = new List<UploadedFileItem>(); // reset file list
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

        // 🔽 Session-backed uploaded file list
        private List<UploadedFileItem> UploadedFiles
        {
            get
            {
                return (Session["UploadedFiles"] as List<UploadedFileItem>) ?? new List<UploadedFileItem>();
            }
            set
            {
                Session["UploadedFiles"] = value;
            }
        }

        protected async void btnAddFile_Click(object sender, EventArgs e)
        {
            if (!fileUploadAdd.HasFile) return;

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
                    File = new FileDescription(fileUploadAdd.FileName, fileUploadAdd.PostedFile.InputStream),
                    Folder = "class_posts"
                };

                var uploadResult = await cloudinary.UploadAsync(uploadParams);

                var currentList = UploadedFiles;
                currentList.Add(new UploadedFileItem
                {
                    Url = uploadResult.SecureUrl.ToString(),
                    Name = fileUploadAdd.FileName
                });
                UploadedFiles = currentList;

                // Update hidden field and UI
                hfUploadedFiles.Value = JsonConvert.SerializeObject(currentList);
                rptAttachedFiles.DataSource = currentList;
                rptAttachedFiles.DataBind();
                phAttachedFiles.Visible = true;
            }
            catch (Exception ex)
            {
                lblStatus.Text = "File upload failed: " + ex.Message;
                lblStatus.Visible = true;
            }
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

            var fileList = UploadedFiles;
            List<string> fileUrls = new List<string>();
            List<string> fileNames = new List<string>();

            foreach (var file in fileList)
            {
                fileUrls.Add(file.Url);
                fileNames.Add(file.Name);
            }

            // Get class name
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
                { "fileUrls", fileUrls },
                { "fileNames", fileNames },
                { "visibleTo", new List<string>() }
            };

            DocumentReference newPost = await db.Collection("classrooms").Document(classId)
                .Collection("posts").AddAsync(postData);

            lblStatus.Text = $"Post created for <strong>{className}</strong> at <em>{postTime.ToDateTime().ToLocalTime():f}</em>.<br />Post ID: {newPost.Id}";
            lblStatus.Visible = true;

            // Reset UI
            txtPostTitle.Text = "";
            txtPostContent.Text = "";
            ddlPostType.SelectedIndex = 0;
            ddlClasses.SelectedIndex = 0;
            txtScheduleDate.Text = "";
            UploadedFiles = new List<UploadedFileItem>();
            hfUploadedFiles.Value = "";
            phAttachedFiles.Visible = false;
        }

        public class UploadedFileItem
        {
            public string Url { get; set; }
            public string Name { get; set; }
        }

        public class ClassItem
        {
            public string Id { get; set; }
            public string Name { get; set; }
        }
    }
}