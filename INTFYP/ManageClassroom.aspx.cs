using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class ManageClassroom : System.Web.UI.Page
    {
        private FirestoreDb db;
        private static string editingClassId = null;

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
            if (!IsPostBack)
            {
                await LoadClassrooms();
            }
        }

        private void InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadClassrooms()
        {
            string teacherEmail = Session["email"]?.ToString() ?? "unknown@teacher.com";

            Query query = db.Collection("classrooms").WhereEqualTo("createdBy", teacherEmail);
            QuerySnapshot snapshot = await query.GetSnapshotAsync();

            List<Classroom> allClassrooms = new List<Classroom>();

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                var data = doc.ToDictionary();
                data.TryGetValue("name", out object name);
                data.TryGetValue("description", out object description);
                data.TryGetValue("venue", out object venue);
                data.TryGetValue("weeklyDay", out object weeklyDay);
                data.TryGetValue("startTime", out object startTime);
                data.TryGetValue("endTime", out object endTime);
                data.TryGetValue("status", out object status);
                data.TryGetValue("isArchived", out object isArchived);

                // Default to false if isArchived doesn't exist
                bool archived = isArchived != null && Convert.ToBoolean(isArchived);

                allClassrooms.Add(new Classroom
                {
                    Id = doc.Id,
                    Name = name?.ToString(),
                    Description = description?.ToString(),
                    Venue = venue?.ToString(),
                    WeeklyDay = weeklyDay?.ToString(),
                    StartTime = startTime?.ToString(),
                    EndTime = endTime?.ToString(),
                    Status = status?.ToString(),
                    IsArchived = archived,
                    IsEditing = (doc.Id == editingClassId)
                });
            }

            // Separate active and archived classes
            var activeClassrooms = allClassrooms.Where(c => !c.IsArchived).ToList();
            var archivedClassrooms = allClassrooms.Where(c => c.IsArchived).ToList();

            // Bind active classes
            rptActiveClassrooms.DataSource = activeClassrooms;
            rptActiveClassrooms.DataBind();
            pnlNoActiveClasses.Visible = activeClassrooms.Count == 0;

            // Bind archived classes
            rptArchivedClassrooms.DataSource = archivedClassrooms;
            rptArchivedClassrooms.DataBind();
            pnlNoArchivedClasses.Visible = archivedClassrooms.Count == 0;
        }

        protected void rptClassrooms_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DropDownList ddlDay = (DropDownList)e.Item.FindControl("ddlEditDay");
                if (ddlDay != null)
                {
                    string weeklyDay = DataBinder.Eval(e.Item.DataItem, "WeeklyDay")?.ToString();
                    if (!string.IsNullOrEmpty(weeklyDay))
                    {
                        ddlDay.ClearSelection();
                        ListItem selected = ddlDay.Items.FindByText(weeklyDay);
                        if (selected != null)
                            selected.Selected = true;
                    }
                }
            }
        }

        protected async void rptClassrooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string classId = e.CommandArgument.ToString();

            try
            {
                if (e.CommandName == "Delete")
                {
                    await db.Collection("classrooms").Document(classId).DeleteAsync();
                    editingClassId = null;
                    await LoadClassrooms();
                }
                else if (e.CommandName == "Edit")
                {
                    editingClassId = classId;
                    await LoadClassrooms();
                }
                else if (e.CommandName == "Cancel")
                {
                    editingClassId = null;
                    await LoadClassrooms();
                }
                else if (e.CommandName == "Archive")
                {
                    var update = new Dictionary<string, object>
                    {
                        { "isArchived", true },
                        { "archivedAt", FieldValue.ServerTimestamp }
                    };
                    await db.Collection("classrooms").Document(classId).UpdateAsync(update);
                    editingClassId = null;
                    await LoadClassrooms();
                }
                else if (e.CommandName == "Unarchive")
                {
                    var update = new Dictionary<string, object>
                    {
                        { "isArchived", false },
                        { "restoredAt", FieldValue.ServerTimestamp }
                    };
                    await db.Collection("classrooms").Document(classId).UpdateAsync(update);
                    await LoadClassrooms();
                }
                else if (e.CommandName == "Update")
                {
                    TextBox txtEditName = (TextBox)e.Item.FindControl("txtEditName");
                    TextBox txtEditDescription = (TextBox)e.Item.FindControl("txtEditDescription");
                    TextBox txtEditVenue = (TextBox)e.Item.FindControl("txtEditVenue");
                    TextBox txtEditStart = (TextBox)e.Item.FindControl("txtEditStart");
                    TextBox txtEditEnd = (TextBox)e.Item.FindControl("txtEditEnd");
                    DropDownList ddlEditDay = (DropDownList)e.Item.FindControl("ddlEditDay");

                    var update = new Dictionary<string, object>
                    {
                        { "name", txtEditName.Text.Trim() },
                        { "description", txtEditDescription.Text.Trim() },
                        { "venue", txtEditVenue.Text.Trim() },
                        { "startTime", txtEditStart.Text.Trim() },
                        { "endTime", txtEditEnd.Text.Trim() },
                        { "weeklyDay", ddlEditDay.SelectedValue },
                        { "updatedAt", FieldValue.ServerTimestamp }
                    };

                    await db.Collection("classrooms").Document(classId).UpdateAsync(update);

                    editingClassId = null;
                    await LoadClassrooms();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in rptClassrooms_ItemCommand: {ex.Message}");
                // You might want to show an error message to the user
            }
        }

        protected string FormatTime(object time)
        {
            if (time == null) return "";
            if (DateTime.TryParse(time.ToString(), out DateTime dt))
                return dt.ToString("hh:mm tt");
            return time.ToString();
        }

        public class Classroom
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public string Venue { get; set; }
            public string WeeklyDay { get; set; }
            public string StartTime { get; set; }
            public string EndTime { get; set; }
            public string Status { get; set; }
            public bool IsArchived { get; set; }
            public bool IsEditing { get; set; }
        }
    }
}