using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.UI;

namespace YourProjectNamespace
{
    public partial class StudyHub : Page
    {
        private FirestoreDb db;
        protected string currentUserId;

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (Session["userId"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            currentUserId = Session["userId"].ToString();
            db = FirestoreDb.Create("intorannetto");

            if (!IsPostBack)
                await LoadJoinedGroups();
        }

        protected async Task LoadJoinedGroups()
        {
            Query groupQuery = db.Collection("studyHubs").WhereArrayContains("members", currentUserId);
            QuerySnapshot groupSnapshot = await groupQuery.GetSnapshotAsync();

            var groups = new List<dynamic>();
            foreach (DocumentSnapshot doc in groupSnapshot.Documents)
            {
                var data = doc.ToDictionary();
                groups.Add(new
                {
                    groupId = doc.Id,
                    groupName = data.ContainsKey("groupName") ? data["groupName"].ToString() : "",
                    hosterName = data.ContainsKey("hosterName") ? data["hosterName"].ToString() : "",
                    capacity = data.ContainsKey("capacity") ? data["capacity"].ToString() : "N/A",
                    groupImage = data.ContainsKey("groupImage") ? data["groupImage"].ToString() : "Images/default-group.jpg"
                });
            }

            rptGroups.DataSource = groups;
            rptGroups.DataBind();
        }


        protected void btnCreateGroup_Click(object sender, EventArgs e)
        {
            Response.Redirect("CreateStudyGroup.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
