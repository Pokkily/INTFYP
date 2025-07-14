using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.UI;

namespace YourProjectNamespace
{
    public partial class ClassDetails : System.Web.UI.Page
    {
        private FirestoreDb db;
        private const string ProjectId = "intorannetto";

        protected async void Page_Load(object sender, EventArgs e)
        {
            try
            {
                InitializeFirestore();

                if (!IsPostBack)
                {
                    string classId = Request.QueryString["classId"];
                    if (!string.IsNullOrEmpty(classId))
                    {
                        await LoadClassroomDetailsAsync(classId);
                        await LoadPostsAsync(classId);
                    }
                    else
                    {
                        ShowError("Classroom ID not specified.");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError($"Error initializing: {ex.Message}");
            }
        }

        private void InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create(ProjectId);
        }

        private async Task LoadClassroomDetailsAsync(string classId)
        {
            try
            {
                DocumentReference classRef = db.Collection("classrooms").Document(classId);
                DocumentSnapshot classSnap = await classRef.GetSnapshotAsync();

                if (classSnap.Exists)
                {
                    // Update UI with classroom details if needed
                    string className = classSnap.GetValue<string>("name");
                    string venue = classSnap.GetValue<string>("venue");
                    // You can use these to update page title or other UI elements
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading classroom: {ex.Message}");
            }
        }

        private async Task LoadPostsAsync(string classId)
        {
            try
            {
                CollectionReference postsRef = db.Collection("classrooms")
                    .Document(classId)
                    .Collection("posts");

                // Changed from "postcall" to "postedAt"
                QuerySnapshot postsSnapshot = await postsRef.OrderByDescending("postedAt").GetSnapshotAsync();

                List<PostEntry> posts = new List<PostEntry>();

                foreach (DocumentSnapshot document in postsSnapshot.Documents)
                {
                    if (document.Exists)
                    {
                        Dictionary<string, object> postData = document.ToDictionary();

                        posts.Add(new PostEntry
                        {
                            Id = document.Id,
                            Title = postData.ContainsKey("title") ? postData["title"].ToString() : "No Title",
                            Type = postData.ContainsKey("postType") ? postData["postType"].ToString() : "post",
                            Content = postData.ContainsKey("content") ? postData["content"].ToString() : "",
                            CreatedByName = await GetUserDisplayNameAsync(
                                postData.ContainsKey("createdBy") ? postData["createdBy"].ToString() : ""),
                            // Changed from "postcall" to "postedAt"
                            CreatedAtFormatted = postData.ContainsKey("postedAt") ?
                                ((Timestamp)postData["postedAt"]).ToDateTime().ToLocalTime().ToString("g") : "Unknown date",
                            FileUrls = GetFileUrls(postData)
                        });
                    }
                }

                if (posts.Count > 0)
                {
                    rptPosts.DataSource = posts;
                    rptPosts.DataBind();
                    pnlNoPosts.Visible = false;
                }
                else
                {
                    ShowInfo("No posts found for this classroom.");
                }
            }
            catch (Exception ex)
            {
                ShowError($"Error loading posts: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Post loading error: {ex.ToString()}");
            }
        }

        private List<string> GetFileUrls(Dictionary<string, object> postData)
        {
            var fileUrls = new List<string>();

            // Check both possible field names for files
            if (postData.ContainsKey("fileUrls") && postData["fileUrls"] is List<object> urlsList)
            {
                foreach (var url in urlsList)
                {
                    fileUrls.Add(url.ToString());
                }
            }
            else if (postData.ContainsKey("fileUtils") && postData["fileUtils"] is List<object> utilsList)
            {
                foreach (var url in utilsList)
                {
                    fileUrls.Add(url.ToString());
                }
            }

            return fileUrls;
        }

        private async Task<string> GetUserDisplayNameAsync(string email)
        {
            if (string.IsNullOrEmpty(email)) return "Unknown User";

            try
            {
                QuerySnapshot userSnap = await db.Collection("users")
                    .WhereEqualTo("email_lower", email.ToLower())
                    .Limit(1)
                    .GetSnapshotAsync();

                if (userSnap.Count > 0 && userSnap.Documents[0].Exists)
                {
                    DocumentSnapshot userDoc = userSnap.Documents[0];
                    return $"{userDoc.GetValue<string>("firstName")} {userDoc.GetValue<string>("lastName")}";
                }
                return email;
            }
            catch
            {
                return email;
            }
        }

        private void ShowError(string message)
        {
            pnlNoPosts.Visible = true;
            pnlNoPosts.Controls.Clear();
            pnlNoPosts.Controls.Add(new LiteralControl($"<div class='alert alert-danger'>{message}</div>"));
        }

        private void ShowInfo(string message)
        {
            pnlNoPosts.Visible = true;
            pnlNoPosts.Controls.Clear();
            pnlNoPosts.Controls.Add(new LiteralControl($"<div class='alert alert-info'>{message}</div>"));
        }
    }

    public class PostEntry
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string Type { get; set; }
        public string Content { get; set; }
        public string CreatedByName { get; set; }
        public string CreatedAtFormatted { get; set; }
        public List<string> FileUrls { get; set; } = new List<string>();
    }
}