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
            try
            {
                InitializeFirestore();

                if (!IsPostBack)
                {
                    await LoadClassesAsync();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in Page_Load: {ex.Message}");
                // Optionally show error to user
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

        private async Task LoadClassesAsync()
        {
            string userEmail = Session["email"]?.ToString()?.ToLower();
            string userPosition = Session["position"]?.ToString()?.ToLower(); // Changed from role to position

            if (string.IsNullOrEmpty(userEmail))
            {
                System.Diagnostics.Debug.WriteLine("User email is empty");
                return;
            }

            var entries = new List<ClassroomEntry>();

            try
            {
                if (userPosition == "teacher")
                {
                    System.Diagnostics.Debug.WriteLine("Loading teacher classes...");

                    QuerySnapshot teacherClasses = await db
                        .Collection("classrooms")
                        .WhereEqualTo("createdBy", userEmail)
                        .GetSnapshotAsync();

                    System.Diagnostics.Debug.WriteLine($"Found {teacherClasses.Count} classes for teacher");

                    foreach (var doc in teacherClasses.Documents)
                    {
                        string classId = doc.Id;
                        string name = doc.GetValue<string>("name");
                        string creatorName = await GetUserFullName(userEmail);

                        entries.Add(new ClassroomEntry
                        {
                            classId = classId,
                            name = name,
                            createdByName = creatorName,
                            origin = "created",
                            status = "created"
                        });
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("Loading student classes...");

                    QuerySnapshot invitedSnapshots = await db
                        .CollectionGroup("invitedStudents")
                        .WhereEqualTo("email", userEmail)
                        .GetSnapshotAsync();

                    System.Diagnostics.Debug.WriteLine($"Found {invitedSnapshots.Count} invitations for student");

                    foreach (var inviteDoc in invitedSnapshots.Documents)
                    {
                        string status = inviteDoc.ContainsField("status")
                            ? inviteDoc.GetValue<string>("status")
                            : "pending";

                        DocumentReference classRef = inviteDoc.Reference.Parent.Parent;
                        DocumentSnapshot classDoc = await classRef.GetSnapshotAsync();
                        if (!classDoc.Exists) continue;

                        string classId = classRef.Id;
                        string name = classDoc.GetValue<string>("name");
                        string creatorEmail = classDoc.GetValue<string>("createdBy");
                        string creatorName = await GetUserFullName(creatorEmail);

                        entries.Add(new ClassroomEntry
                        {
                            classId = classId,
                            name = name,
                            createdByName = creatorName,
                            origin = "invited",
                            status = status
                        });
                    }
                }

                rptClasses.DataSource = entries;
                rptClasses.DataBind();
                pnlNoClasses.Visible = entries.Count == 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in LoadClassesAsync: {ex.Message}");
                pnlNoClasses.Visible = true;
            }
        }

        private async Task<string> GetUserFullName(string email)
        {
            try
            {
                QuerySnapshot userSnap = await db.Collection("users")
                    .WhereEqualTo("email_lower", email.ToLower())
                    .GetSnapshotAsync();

                if (userSnap.Count > 0)
                {
                    var doc = userSnap.Documents[0];
                    return $"{doc.GetValue<string>("firstName")} {doc.GetValue<string>("lastName")}";
                }
                return email;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in GetUserFullName: {ex.Message}");
                return email;
            }
        }

        protected async void rptClasses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                InitializeFirestore();

                string classId = e.CommandArgument.ToString();
                string userEmail = Session["email"]?.ToString()?.ToLower();

                if (string.IsNullOrEmpty(classId) || string.IsNullOrEmpty(userEmail))
                {
                    System.Diagnostics.Debug.WriteLine("Missing classId or userEmail in ItemCommand");
                    return;
                }

                if (e.CommandName == "Join" || e.CommandName == "Decline")
                {
                    DocumentReference inviteRef = db
                        .Collection("classrooms")
                        .Document(classId)
                        .Collection("invitedStudents")
                        .Document(userEmail);

                    string newStatus = e.CommandName == "Join" ? "accepted" : "declined";
                    await inviteRef.UpdateAsync("status", newStatus);
                    await LoadClassesAsync();
                }
                else if (e.CommandName == "Enter" || e.CommandName == "View")
                {
                    Response.Redirect($"ClassroomView.aspx?classId={classId}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in rptClasses_ItemCommand: {ex.Message}");
            }
        }

        public class ClassroomEntry
        {
            public string classId { get; set; }
            public string name { get; set; }
            public string createdByName { get; set; }
            public string origin { get; set; }  // "created" or "invited"
            public string status { get; set; }  // "pending", "accepted", or "created"
        }
    }
}