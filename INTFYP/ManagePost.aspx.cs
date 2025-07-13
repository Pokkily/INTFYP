using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
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
        private static Cloudinary cloudinary;
        private string selectedClassId = string.Empty;
        private string postTypeFilter = "all";
        private List<PostItem> postList = new List<PostItem>();

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
            InitializeCloudinary();

            if (!IsPostBack)
            {
                await LoadClassDropdownAsync();
                await LoadPostsAsync();
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

        private void InitializeCloudinary()
        {
            if (cloudinary == null)
            {
                var account = new Account(
                    ConfigurationManager.AppSettings["CloudinaryCloudName"],
                    ConfigurationManager.AppSettings["CloudinaryApiKey"],
                    ConfigurationManager.AppSettings["CloudinaryApiSecret"]);

                cloudinary = new Cloudinary(account);
            }
        }

        private async Task LoadClassDropdownAsync()
        {
            string email = Session["email"]?.ToString();
            if (string.IsNullOrEmpty(email)) return;

            QuerySnapshot snapshot = await db.Collection("classrooms")
                .WhereEqualTo("createdBy", email.ToLower())
                .GetSnapshotAsync();

            ddlClassFilter.Items.Clear();
            ddlClassFilter.Items.Add(new ListItem("-- Select Class --", ""));

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                string name = doc.ContainsField("name") ? doc.GetValue<string>("name") : "Unnamed Class";
                ddlClassFilter.Items.Add(new ListItem(name, doc.Id));
            }
        }

        protected async void ddlClassFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            selectedClassId = ddlClassFilter.SelectedValue;
            await LoadPostsAsync();
        }

        protected async void ddlPostTypeFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            postTypeFilter = ddlPostTypeFilter.SelectedValue;
            await LoadPostsAsync();
        }

        private async Task LoadPostsAsync()
        {
            postList.Clear();
            if (string.IsNullOrEmpty(ddlClassFilter.SelectedValue)) return;

            selectedClassId = ddlClassFilter.SelectedValue;
            postTypeFilter = ddlPostTypeFilter.SelectedValue;

            CollectionReference postCollection = db.Collection("classrooms")
                                                   .Document(selectedClassId)
                                                   .Collection("posts");

            Query query = postCollection.OrderByDescending("postedAt");
            if (postTypeFilter != "all")
                query = query.WhereEqualTo("postType", postTypeFilter);

            QuerySnapshot snapshot = await query.GetSnapshotAsync();

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                PostItem post = new PostItem
                {
                    Id = doc.Id,
                    Title = doc.GetValue<string>("title"),
                    Content = doc.GetValue<string>("content"),
                    PostType = doc.GetValue<string>("postType"),
                    FileUrl = doc.ContainsField("fileUrl") ? doc.GetValue<string>("fileUrl") : null,
                    FileName = doc.ContainsField("fileName") ? doc.GetValue<string>("fileName") : null,
                    IsEditing = false
                };
                postList.Add(post);
            }

            rptPosts.DataSource = postList;
            rptPosts.DataBind();
        }

        protected async void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string postId = e.CommandArgument.ToString().Split('|')[0];
            PostItem post = postList.FirstOrDefault(p => p.Id == postId);
            if (post == null) return;

            switch (e.CommandName)
            {
                case "Edit":
                    postList.ForEach(p => p.IsEditing = false);
                    post.IsEditing = true;
                    break;

                case "CancelEdit":
                    post.IsEditing = false;
                    break;

                case "Delete":
                    await db.Collection("classrooms").Document(selectedClassId)
                              .Collection("posts").Document(postId).DeleteAsync();
                    break;

                case "Save":
                    await SavePostAsync(e, post);
                    break;

                case "RemoveFile":
                    post.FileUrl = null;
                    post.FileName = null;
                    await db.Collection("classrooms").Document(selectedClassId)
                              .Collection("posts").Document(post.Id)
                              .UpdateAsync(new Dictionary<string, object>
                    {
                        { "fileUrl", FieldValue.Delete },
                        { "fileName", FieldValue.Delete }
                    });
                    post.IsEditing = true;
                    break;
            }

            rptPosts.DataSource = postList;
            rptPosts.DataBind();
        }

        private async Task SavePostAsync(RepeaterCommandEventArgs e, PostItem post)
        {
            TextBox txtTitle = (TextBox)e.Item.FindControl("txtEditTitle");
            TextBox txtContent = (TextBox)e.Item.FindControl("txtEditContent");
            FileUpload fileUpload = (FileUpload)e.Item.FindControl("fileUploadEdit");

            if (fileUpload.HasFile)
            {
                RawUploadParams uploadParams = new RawUploadParams
                {
                    File = new FileDescription(fileUpload.FileName, fileUpload.PostedFile.InputStream),
                    Folder = "class_posts"
                };

                RawUploadResult uploadResult = await cloudinary.UploadAsync(uploadParams);
                if (uploadResult.SecureUrl != null)
                {
                    post.FileUrl = uploadResult.SecureUrl.ToString();
                    post.FileName = fileUpload.FileName;
                }
            }

            Dictionary<string, object> updates = new Dictionary<string, object>
            {
                { "title", txtTitle.Text.Trim() },
                { "content", txtContent.Text.Trim() },
                { "fileUrl", post.FileUrl ?? FieldValue.Delete },
                { "fileName", post.FileName ?? FieldValue.Delete },
                { "lastUpdated", Timestamp.GetCurrentTimestamp() }
            };

            await db.Collection("classrooms").Document(selectedClassId)
                    .Collection("posts").Document(post.Id).UpdateAsync(updates);

            post.IsEditing = false;
        }

        public class PostItem
        {
            public string Id { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public string PostType { get; set; }
            public string FileUrl { get; set; }
            public string FileName { get; set; }
            public bool IsEditing { get; set; }
        }
    }
}
