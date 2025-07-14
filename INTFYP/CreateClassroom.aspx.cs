using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class CreateClassroom : System.Web.UI.Page
    {
        private FirestoreDb db;
        private List<Student> invitedStudents = new List<Student>();

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
            {
                if (Session["InvitedStudents"] == null)
                    Session["InvitedStudents"] = new List<Student>();

                ddlDayOfWeek.SelectedIndex = 0;
            }

            invitedStudents = (List<Student>)Session["InvitedStudents"];
            BindStudentsRepeater();
        }

        private void InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        protected async void btnAddStudent_Click(object sender, EventArgs e)
        {
            string email = txtStudentEmail.Text.Trim().ToLower();

            if (string.IsNullOrWhiteSpace(email))
            {
                lblInviteStatus.Text = "Please enter a valid email address.";
                lblInviteStatus.CssClass = "text-danger fade";
                return;
            }

            var snapshot = await db.Collection("users").WhereEqualTo("email", email).GetSnapshotAsync();
            if (snapshot.Count == 0)
            {
                lblInviteStatus.Text = "Student not found.";
                lblInviteStatus.CssClass = "text-danger fade";
                return;
            }

            var doc = snapshot.Documents[0];
            string name = doc.GetValue<string>("firstName") + " " + doc.GetValue<string>("lastName");

            if (invitedStudents.Exists(s => s.Email == email))
            {
                lblInviteStatus.Text = "Student already invited.";
                lblInviteStatus.CssClass = "text-warning fade";
                return;
            }

            invitedStudents.Add(new Student { Name = name, Email = email });
            Session["InvitedStudents"] = invitedStudents;
            BindStudentsRepeater();

            lblInviteStatus.Text = "Student added!";
            lblInviteStatus.CssClass = "text-success fade";
            txtStudentEmail.Text = "";
        }

        protected void rptStudents_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                string email = e.CommandArgument.ToString();
                invitedStudents.RemoveAll(s => s.Email == email);
                Session["InvitedStudents"] = invitedStudents;
                BindStudentsRepeater();

                lblInviteStatus.Text = "Student removed.";
                lblInviteStatus.CssClass = "text-success fade";
            }
        }

        private void BindStudentsRepeater()
        {
            rptStudents.DataSource = invitedStudents;
            rptStudents.DataBind();
        }

        protected async void btnCreateClass_Click(object sender, EventArgs e)
        {
            string name = txtClassName.Text.Trim();
            string description = txtClassDescription.Text.Trim();
            string venue = txtVenue.Text.Trim();
            string startTime = txtStartTime.Text + " " + ddlStartAmPm.SelectedValue;
            string endTime = txtEndTime.Text + " " + ddlEndAmPm.SelectedValue;
            string teacherEmail = Session["email"]?.ToString() ?? "unknown@teacher.com";
            string weeklyDay = ddlDayOfWeek.SelectedValue;

            if (string.IsNullOrEmpty(name) || invitedStudents.Count == 0)
            {
                lblInviteStatus.Text = "Please enter all required fields and invite at least one student.";
                lblInviteStatus.CssClass = "text-danger fade";
                return;
            }

            var classRef = db.Collection("classrooms").Document();
            var data = new Dictionary<string, object>
            {
                { "name", name },
                { "description", description },
                { "venue", venue },
                { "startTime", startTime },
                { "endTime", endTime },
                { "weeklyDay", weeklyDay },
                { "createdBy", teacherEmail },
                { "createdAt", Timestamp.GetCurrentTimestamp() },
                { "status", "active" }
            };

            await classRef.SetAsync(data);

            foreach (var student in invitedStudents)
            {
                await classRef.Collection("invitedStudents").Document(student.Email).SetAsync(new
                {
                    name = student.Name,
                    email = student.Email,
                    joinedAt = FieldValue.ServerTimestamp,
                    status = "pending"
                });
            }

            lblPreview.Text = $"✅ Class <strong>{name}</strong> created!<br />Weekly on <b>{weeklyDay}</b>, {startTime}–{endTime}<br />📍 {venue}<br />Students: {invitedStudents.Count}";
            pnlPreview.Visible = true;

            Session["InvitedStudents"] = null;
            invitedStudents.Clear();
            BindStudentsRepeater();

            txtClassName.Text = txtClassDescription.Text = txtVenue.Text = "";
        }

        public class Student
        {
            public string Name { get; set; }
            public string Email { get; set; }
        }
    }
}
