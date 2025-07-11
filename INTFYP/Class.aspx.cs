using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class Class : Page
    {
        private FirestoreDb db;

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore();
                await LoadInvitedClassesAsync();
            }
        }

        private void InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadInvitedClassesAsync()
        {
            string userEmail = Session["email"]?.ToString()?.ToLower();
            if (string.IsNullOrEmpty(userEmail)) return;

            // Get all invitedStudents docs where email == current user
            QuerySnapshot invitedSnapshots = await db
                .CollectionGroup("invitedStudents")
                .WhereEqualTo("email", userEmail)
                .GetSnapshotAsync();

            var entries = new List<ClassroomEntry>();

            foreach (var inviteDoc in invitedSnapshots.Documents)
            {
                string status = inviteDoc.ContainsField("status")
                    ? inviteDoc.GetValue<string>("status")
                    : "pending";

                // Parent classroom document:
                DocumentReference classRef = inviteDoc.Reference.Parent.Parent;
                DocumentSnapshot classDoc = await classRef.GetSnapshotAsync();

                if (!classDoc.Exists) continue;

                // Read classroom fields:
                string classId = classRef.Id;
                string name = classDoc.GetValue<string>("name");
                string creatorEmail = classDoc.GetValue<string>("createdBy");

                // Fetch creator's full name from users collection:
                string creatorName = creatorEmail;
                QuerySnapshot userSnap = await db
                    .Collection("users")
                    .WhereEqualTo("email", creatorEmail)
                    .GetSnapshotAsync();

                if (userSnap.Count > 0)
                {
                    var userDoc = userSnap.Documents[0];
                    creatorName = $"{userDoc.GetValue<string>("firstName")} {userDoc.GetValue<string>("lastName")}";
                }

                entries.Add(new ClassroomEntry
                {
                    classId = classId,
                    name = name,
                    createdByName = creatorName,
                    status = status
                });
            }

            rptClasses.DataSource = entries;
            rptClasses.DataBind();
        }

        protected async void rptClasses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string classId = e.CommandArgument.ToString();
            string userEmail = Session["email"]?.ToString()?.ToLower();
            if (string.IsNullOrEmpty(classId) || string.IsNullOrEmpty(userEmail)) return;

            DocumentReference inviteRef = db
                .Collection("classrooms")
                .Document(classId)
                .Collection("invitedStudents")
                .Document(userEmail);

            if (e.CommandName == "Join")
            {
                await inviteRef.UpdateAsync("status", "accepted");
                await LoadInvitedClassesAsync();
            }
            else if (e.CommandName == "Enter")
            {
                Response.Redirect($"ClassroomView.aspx?classId={classId}");
            }
        }

        public class ClassroomEntry
        {
            public string classId { get; set; }
            public string name { get; set; }
            public string createdByName { get; set; }
            public string status { get; set; }
        }
    }
}
