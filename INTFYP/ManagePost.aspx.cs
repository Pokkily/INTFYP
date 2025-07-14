// ManagePost.aspx.cs
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
        private static Cloudinary cloudinary;
        private static List<PostItem> postList = new List<PostItem>();

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
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private void InitializeCloudinary()
        {
            var account = new Account(
                ConfigurationManager.AppSettings["CloudinaryCloudName"],
                ConfigurationManager.AppSettings["CloudinaryApiKey"],
                ConfigurationManager.AppSettings["CloudinaryApiSecret"]);
            cloudinary = new Cloudinary(account);
        }

        protected void ddlClassFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(LoadPostsAsync));
        }

        protected void ddlPostTypeFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(LoadPostsAsync));
        }

        private async Task LoadClassDropdownAsync()
        {
            string email = Session["email"]?.ToString();
            if (string.IsNullOrEmpty(email)) return;

            var snapshot = await db.Collection("classrooms")
                                   .WhereEqualTo("createdBy", email.ToLower())
                                   .GetSnapshotAsync();

            ddlClassFilter.Items.Clear();
            ddlClassFilter.Items.Add(new ListItem("-- Select Class --", ""));

            foreach (var doc in snapshot.Documents)
            {
                string name = doc.GetValue<string>("name");
                ddlClassFilter.Items.Add(new ListItem(name, doc.Id));
            }
        }

        private async Task LoadPostsAsync()
        {
            try
            {
                postList.Clear();
                pnlNoPosts.Visible = false;

                if (string.IsNullOrEmpty(ddlClassFilter.SelectedValue)) return;

                string filter = ddlPostTypeFilter.SelectedValue;
                var postsRef = db.Collection("classrooms")
                               .Document(ddlClassFilter.SelectedValue)
                               .Collection("posts");

                Query query = postsRef.OrderByDescending("postedAt");
                if (filter != "all") query = query.WhereEqualTo("postType", filter);

                var snapshot = await query.GetSnapshotAsync();
                pnlNoPosts.Visible = snapshot.Count == 0;

                foreach (var doc in snapshot.Documents)
                {
                    var fileUrls = doc.TryGetValue("fileUrls", out object urls)
                        ? ((List<object>)urls).Select(x => x.ToString()).ToList()
                        : new List<string>();

                    postList.Add(new PostItem
                    {
                        Id = doc.Id,
                        Title = doc.GetValue<string>("title"),
                        Content = doc.GetValue<string>("content"),
                        PostType = doc.GetValue<string>("postType"),
                        FileUrls = fileUrls,
                        IsEditing = false
                    });
                }

                // Proper data binding sequence
                rptPosts.DataSource = postList;
                rptPosts.DataBind();
            }
            catch (Exception ex)
            {
                // Handle error
            }
        }
        protected void rptEditFiles_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                string fileUrl = e.Item.DataItem as string;
                if (string.IsNullOrEmpty(fileUrl)) return;

                var hdnFileUrl = e.Item.FindControl("hdnFileUrl") as HiddenField;
                var lnkRemove = e.Item.FindControl("lnkRemove") as LinkButton;

                if (hdnFileUrl != null) hdnFileUrl.Value = fileUrl;

                RepeaterItem outerItem = e.Item.NamingContainer as RepeaterItem;
                if (outerItem != null)
                {
                    var hfPostId = outerItem.FindControl("hfPostId") as HiddenField;
                    if (hfPostId != null && lnkRemove != null)
                    {
                        lnkRemove.CommandArgument = $"{hfPostId.Value}|{fileUrl}";
                    }
                }
            }
        }

        protected void rptPosts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var post = (PostItem)e.Item.DataItem;

                var rptFiles = (Repeater)e.Item.FindControl("rptFiles");
                if (rptFiles != null && post.FileUrls != null)
                {
                    rptFiles.DataSource = post.FileUrls;
                    rptFiles.DataBind();
                }

                var rptEditFiles = (Repeater)e.Item.FindControl("rptEditFiles");
                if (rptEditFiles != null && post.FileUrls != null)
                {
                    rptEditFiles.DataSource = post.FileUrls;
                    rptEditFiles.DataBind();
                }
            }
        }

        protected async void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string postId = e.CommandArgument.ToString();
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
                    await db.Collection("classrooms").Document(ddlClassFilter.SelectedValue)
                        .Collection("posts").Document(postId).DeleteAsync();
                    postList.Remove(post);
                    break;

                case "Save":
                    TextBox txtTitle = (TextBox)e.Item.FindControl("txtEditTitle");
                    TextBox txtContent = (TextBox)e.Item.FindControl("txtEditContent");
                    FileUpload fileUpload = (FileUpload)e.Item.FindControl("fileUploadEdit");

                    if (fileUpload.HasFiles)
                    {
                        foreach (HttpPostedFile file in fileUpload.PostedFiles)
                        {
                            var uploadParams = new RawUploadParams
                            {
                                File = new FileDescription(file.FileName, file.InputStream),
                                Folder = "class_posts"
                            };
                            var uploadResult = await cloudinary.UploadAsync(uploadParams);
                            post.FileUrls.Add(uploadResult.SecureUrl.ToString());
                        }
                    }

                    var update = new Dictionary<string, object>
                    {
                        {"title", txtTitle.Text.Trim()},
                        {"content", txtContent.Text.Trim()},
                        {"fileUrls", post.FileUrls},
                        {"lastUpdated", Timestamp.GetCurrentTimestamp()}
                    };

                    await db.Collection("classrooms").Document(ddlClassFilter.SelectedValue)
                        .Collection("posts").Document(post.Id).UpdateAsync(update);

                    post.IsEditing = false;
                    break;
            }

            rptPosts.DataSource = postList;
            rptPosts.DataBind();
        }

        public class PostItem
        {
            public string Id { get; set; } = string.Empty;
            public string Title { get; set; } = string.Empty;
            public string Content { get; set; } = string.Empty;
            public string PostType { get; set; } = string.Empty;
            public List<string> FileUrls { get; set; } = new List<string>();
            public bool IsEditing { get; set; }
        }
    }
}
