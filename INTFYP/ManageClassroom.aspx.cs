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
        private string teacherEmail;

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
            teacherEmail = Session["email"]?.ToString() ?? "unknown@teacher.com";

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

        protected async Task LoadClassrooms(string searchTerm = "", string filter = "all")
        {
            Query query = db.Collection("classrooms")
                           .WhereEqualTo("createdBy", teacherEmail);

            if (filter != "all")
            {
                query = query.WhereEqualTo("status", filter);
            }

            var snapshot = await query.GetSnapshotAsync();
            var filteredDocs = new List<DocumentSnapshot>();

            if (!string.IsNullOrEmpty(searchTerm))
            {
                foreach (var doc in snapshot.Documents)
                {
                    if (doc.GetValue<string>("name").ToLower().Contains(searchTerm.ToLower()) ||
                       doc.GetValue<string>("description").ToLower().Contains(searchTerm.ToLower()) ||
                       doc.GetValue<string>("venue").ToLower().Contains(searchTerm.ToLower()))
                    {
                        filteredDocs.Add(doc);
                    }
                }
            }
            else
            {
                filteredDocs = snapshot.Documents.ToList();
            }

            if (filteredDocs.Count == 0)
            {
                pnlEmptyState.Visible = true;
                pnlClassrooms.Visible = false;
                return;
            }

            pnlEmptyState.Visible = false;
            pnlClassrooms.Visible = true;
            pnlClassrooms.Controls.Clear();

            foreach (var doc in filteredDocs)
            {
                var classroom = doc.ToDictionary();
                AddClassroomCard(doc.Id, classroom);
            }
        }

        private void AddClassroomCard(string classroomId, Dictionary<string, object> classroom)
        {
            Panel card = new Panel { CssClass = "classroom-card" };

            // Classroom title
            Literal title = new Literal
            {
                Text = $"<div class='classroom-title'>{classroom["name"]}</div>"
            };
            card.Controls.Add(title);

            // Classroom metadata
            Literal meta = new Literal
            {
                Text = $@"<div class='classroom-meta'>
                            <span class='student-count'>{GetStudentCount(classroomId).Result} students</span>
                            Every {classroom["weeklyDay"]} | {classroom["startTime"]} - {classroom["endTime"]}
                          </div>"
            };
            card.Controls.Add(meta);

            // Classroom description
            if (!string.IsNullOrEmpty(classroom["description"]?.ToString()))
            {
                Literal description = new Literal
                {
                    Text = $"<div class='classroom-description'>{classroom["description"]}</div>"
                };
                card.Controls.Add(description);
            }

            // Action buttons
            Panel actionButtons = new Panel { CssClass = "action-buttons" };

            Button btnView = new Button
            {
                Text = "View",
                CssClass = "btn btn-view",
                PostBackUrl = $"ClassroomDetails.aspx?id={classroomId}"
            };
            actionButtons.Controls.Add(btnView);

            Button btnEdit = new Button
            {
                Text = "Edit",
                CssClass = "btn btn-edit",
                CommandArgument = classroomId
            };
            btnEdit.Click += BtnEdit_Click;
            actionButtons.Controls.Add(btnEdit);

            Button btnDelete = new Button
            {
                Text = "Delete",
                CssClass = "btn btn-delete",
                CommandArgument = classroomId
            };
            btnDelete.Click += BtnDelete_Click;
            actionButtons.Controls.Add(btnDelete);

            card.Controls.Add(actionButtons);
            pnlClassrooms.Controls.Add(card);
        }

        private async Task<int> GetStudentCount(string classroomId)
        {
            var snapshot = await db.Collection("classrooms")
                                 .Document(classroomId)
                                 .Collection("students")
                                 .GetSnapshotAsync();
            return snapshot.Count;
        }

        protected async void BtnEdit_Click(object sender, EventArgs e)
        {
            string classroomId = ((Button)sender).CommandArgument;
            var doc = await db.Collection("classrooms").Document(classroomId).GetSnapshotAsync();

            if (doc.Exists)
            {
                var classroom = doc.ToDictionary();
                txtEditClassName.Text = classroom["name"].ToString();
                txtEditDescription.Text = classroom["description"].ToString();
                ddlEditDayOfWeek.SelectedValue = classroom["weeklyDay"].ToString();
                txtEditVenue.Text = classroom["venue"].ToString();

                var startTimeParts = classroom["startTime"].ToString().Split(' ');
                txtEditStartTime.Text = startTimeParts[0];

                var endTimeParts = classroom["endTime"].ToString().Split(' ');
                txtEditEndTime.Text = endTimeParts[0];

                ddlEditStatus.SelectedValue = classroom["status"].ToString();
                hdnEditClassroomId.Value = classroomId;

                ScriptManager.RegisterStartupScript(this, GetType(), "ShowEditModal",
                    "$('#editClassroomModal').modal('show');", true);
            }
        }

        protected async void BtnDelete_Click(object sender, EventArgs e)
        {
            string classroomId = ((Button)sender).CommandArgument;
            hdnDeleteClassroomId.Value = classroomId;

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowDeleteModal",
                "$('#deleteConfirmationModal').modal('show');", true);
        }

        protected async void btnSaveChanges_Click(object sender, EventArgs e)
        {
            string classroomId = hdnEditClassroomId.Value;
            var classroomRef = db.Collection("classrooms").Document(classroomId);

            string startTimeAmPm = txtEditStartTime.Text.Contains("PM") ? "PM" : "AM";
            string endTimeAmPm = txtEditEndTime.Text.Contains("PM") ? "PM" : "AM";

            await classroomRef.UpdateAsync(new Dictionary<string, object>
            {
                { "name", txtEditClassName.Text },
                { "description", txtEditDescription.Text },
                { "weeklyDay", ddlEditDayOfWeek.SelectedValue },
                { "venue", txtEditVenue.Text },
                { "startTime", $"{txtEditStartTime.Text} {startTimeAmPm}" },
                { "endTime", $"{txtEditEndTime.Text} {endTimeAmPm}" },
                { "status", ddlEditStatus.SelectedValue },
                { "updatedAt", Timestamp.GetCurrentTimestamp() }
            });

            ScriptManager.RegisterStartupScript(this, GetType(), "HideEditModal",
                "$('#editClassroomModal').modal('hide');", true);
            await LoadClassrooms();
        }

        protected async void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            string classroomId = hdnDeleteClassroomId.Value;

            // First delete all students in this classroom
            var studentsSnapshot = await db.Collection("classrooms")
                                         .Document(classroomId)
                                         .Collection("students")
                                         .GetSnapshotAsync();

            var batch = db.StartBatch();
            foreach (var studentDoc in studentsSnapshot.Documents)
            {
                batch.Delete(studentDoc.Reference);
            }
            await batch.CommitAsync();

            // Then delete the classroom itself
            await db.Collection("classrooms").Document(classroomId).DeleteAsync();

            ScriptManager.RegisterStartupScript(this, GetType(), "HideDeleteModal",
                "$('#deleteConfirmationModal').modal('hide');", true);
            await LoadClassrooms();
        }

        protected async void btnSearch_Click(object sender, EventArgs e)
        {
            await LoadClassrooms(txtSearch.Text.Trim(), ddlFilter.SelectedValue);
        }

        protected async void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await LoadClassrooms(txtSearch.Text.Trim(), ddlFilter.SelectedValue);
        }
    }
}