using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;

namespace YourProjectNamespace
{
    public partial class ManagePost : System.Web.UI.Page
    {
        private FirestoreDb db;
        private static string selectedClassId;
        private static List<PostItem> postList;

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
            {
                await LoadClassDropdownAsync();
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

        private async Task LoadClassDropdownAsync()
        {
            string userEmail = Session["email"]?.ToString()?.ToLower();
            QuerySnapshot snapshot = await db.Collection("classrooms").WhereEqualTo("createdBy", userEmail).GetSnapshotAsync();

            ddlClassFilter.Items.Clear();
            ddlClassFilter.Items.Add(new ListItem("-- Select Class --", ""));

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                string name = doc.ContainsField("name") ? doc.GetValue<string>("name") : "(Unnamed)";
                ddlClassFilter.Items.Add(new ListItem(name, doc.Id));
            }
        }

        protected async void ddlClassFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            selectedClassId = ddlClassFilter.SelectedValue;
            await LoadPostsAsync();
        }

        private async Task LoadPostsAsync()
        {
            postList = new List<PostItem>();
            if (string.IsNullOrEmpty(selectedClassId)) return;

            var snapshot = await db.Collection("classrooms").Document(selectedClassId).Collection("posts").GetSnapshotAsync();
            foreach (var doc in snapshot.Documents)
            {
                List<string> urls = doc.ContainsField("fileUrls") ? doc.GetValue<List<string>>("fileUrls") : new List<string>();
                List<string> names = doc.ContainsField("fileNames") ? doc.GetValue<List<string>>("fileNames") : new List<string>();

                postList.Add(new PostItem
                {
                    Id = doc.Id,
                    Title = doc.ContainsField("title") ? doc.GetValue<string>("title") : "",
                    Content = doc.ContainsField("content") ? doc.GetValue<string>("content") : "",
                    FileUrls = urls,
                    FileNames = names,
                    IsEditing = false
                });
            }
            BindRepeater();
        }

        private void BindRepeater()
        {
            rptPosts.DataSource = postList;
            rptPosts.DataBind();
        }

        protected async void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string postId = e.CommandArgument.ToString();
            var item = postList.FirstOrDefault(p => p.Id == postId);

            if (e.CommandName == "Edit")
            {
                postList.ForEach(p => p.IsEditing = false);
                if (item != null) item.IsEditing = true;
                BindRepeater();
            }
            else if (e.CommandName == "CancelEdit")
            {
                item.IsEditing = false;
                BindRepeater();
            }
            else if (e.CommandName == "Delete")
            {
                await db.Collection("classrooms").Document(selectedClassId).Collection("posts").Document(postId).DeleteAsync();
                await LoadPostsAsync();
            }
            else if (e.CommandName == "Save")
            {
                var txtTitle = (TextBox)e.Item.FindControl("txtEditTitle");
                var txtContent = (TextBox)e.Item.FindControl("txtEditContent");
                var fileUpload = (FileUpload)e.Item.FindControl("fileUploadEdit");
                var hiddenRemovedFiles = (HiddenField)e.Item.FindControl("hiddenRemovedFiles");

                string newTitle = txtTitle.Text.Trim();
                string newContent = txtContent.Text.Trim();
                List<string> updatedUrls = new List<string>(item.FileUrls);
                List<string> updatedNames = new List<string>(item.FileNames);

                string[] filesToRemove = hiddenRemovedFiles?.Value.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries) ?? new string[0];
                foreach (string filename in filesToRemove)
                {
                    int index = updatedNames.IndexOf(filename);
                    if (index >= 0)
                    {
                        updatedNames.RemoveAt(index);
                        updatedUrls.RemoveAt(index);
                    }
                }

                if (fileUpload.HasFiles)
                {
                    var account = new Account(
                        ConfigurationManager.AppSettings["CloudinaryCloudName"],
                        ConfigurationManager.AppSettings["CloudinaryApiKey"],
                        ConfigurationManager.AppSettings["CloudinaryApiSecret"]);

                    var cloudinary = new Cloudinary(account);

                    foreach (HttpPostedFile uploadedFile in fileUpload.PostedFiles)
                    {
                        var uploadParams = new RawUploadParams
                        {
                            File = new FileDescription(uploadedFile.FileName, uploadedFile.InputStream),
                            Folder = "class_posts"
                        };

                        var uploadResult = cloudinary.Upload(uploadParams);
                        if (uploadResult.SecureUrl != null)
                        {
                            updatedUrls.Add(uploadResult.SecureUrl.ToString());
                            updatedNames.Add(uploadResult.OriginalFilename);
                        }
                    }
                }

                var updatedData = new Dictionary<string, object>
                {
                    { "title", newTitle },
                    { "content", newContent },
                    { "fileUrls", updatedUrls },
                    { "fileNames", updatedNames }
                };

                await db.Collection("classrooms").Document(selectedClassId)
                    .Collection("posts").Document(postId).UpdateAsync(updatedData);

                await LoadPostsAsync();
            }
        }

        public class PostItem
        {
            public string Id { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public List<string> FileUrls { get; set; }
            public List<string> FileNames { get; set; }
            public bool IsEditing { get; set; }
        }
    }
}
