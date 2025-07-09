using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Web;
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
            if (!IsPostBack)
            {
                // Initialize Firestore
                InitializeFirestore();

                // Set default date to today
                txtClassDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                // Initialize session for storing invited students
                if (Session["InvitedStudents"] == null)
                {
                    Session["InvitedStudents"] = new List<Student>();
                }
            }

            // Load invited students from session
            invitedStudents = (List<Student>)Session["InvitedStudents"];
            BindStudentsRepeater();
        }

        private void InitializeFirestore()
        {
            try
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                System.Diagnostics.Debug.WriteLine($"Service account path: {path}");
                System.Diagnostics.Debug.WriteLine($"File exists: {System.IO.File.Exists(path)}");

                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto");
                System.Diagnostics.Debug.WriteLine("Firestore initialized successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Firestore initialization failed: {ex.Message}");
                lblInviteStatus.Text = "System error. Please try again later.";
                lblInviteStatus.CssClass = "text-danger";
            }
        }

        protected async void btnAddStudent_Click(object sender, EventArgs e)
        {
            string email = txtStudentEmail.Text.Trim().ToLower();

            if (string.IsNullOrWhiteSpace(email))
            {
                lblInviteStatus.Text = "Please enter a valid email address";
                lblInviteStatus.CssClass = "text-danger";
                return;
            }

            try
            {
                // Check if student exists in Firestore
                Query query = db.Collection("users")
                    .WhereEqualTo("email", email)
                    .WhereEqualTo("position", "student");

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                if (snapshot.Count == 0)
                {
                    lblInviteStatus.Text = "Student not found or not a valid student account";
                    lblInviteStatus.CssClass = "text-danger";
                    return;
                }

                // Get student details
                DocumentSnapshot document = snapshot.Documents[0];
                string name = document.GetValue<string>("username");
                string studentEmail = document.GetValue<string>("email");

                // Check if already invited
                if (invitedStudents.Exists(s => s.Email == studentEmail))
                {
                    lblInviteStatus.Text = "This student has already been invited";
                    lblInviteStatus.CssClass = "text-warning";
                    return;
                }

                // Add to invited list
                invitedStudents.Add(new Student { Name = name, Email = studentEmail });
                Session["InvitedStudents"] = invitedStudents;

                // Update UI
                BindStudentsRepeater();
                txtStudentEmail.Text = "";
                lblInviteStatus.Text = "Student added successfully";
                lblInviteStatus.CssClass = "text-success";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error adding student: {ex.Message}");
                lblInviteStatus.Text = "Error processing student. Please try again.";
                lblInviteStatus.CssClass = "text-danger";
            }
        }

        protected void rptStudents_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                string emailToRemove = e.CommandArgument.ToString();
                invitedStudents.RemoveAll(s => s.Email == emailToRemove);
                Session["InvitedStudents"] = invitedStudents;
                BindStudentsRepeater();

                lblInviteStatus.Text = "Student removed";
                lblInviteStatus.CssClass = "text-success";
            }
        }

        private void BindStudentsRepeater()
        {
            rptStudents.DataSource = invitedStudents;
            rptStudents.DataBind();
        }

        protected async void btnCreateClass_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid || invitedStudents.Count == 0)
            {
                lblInviteStatus.Text = "Please fill all required fields and add at least one student";
                lblInviteStatus.CssClass = "text-danger";
                return;
            }

            try
            {
                // Get current teacher's email from session
                string teacherEmail = Session["email"]?.ToString() ?? "unknown@teacher.com";

                // Combine time with AM/PM
                string startTime = $"{txtStartTime.Text} {ddlStartAmPm.SelectedValue}";
                string endTime = $"{txtEndTime.Text} {ddlEndAmPm.SelectedValue}";

                // Create classroom document
                DocumentReference classRef = db.Collection("classrooms").Document();
                Dictionary<string, object> classData = new Dictionary<string, object>
                {
                    { "name", txtClassName.Text.Trim() },
                    { "description", txtClassDescription.Text.Trim() },
                    { "date", txtClassDate.Text },
                    { "startTime", startTime },
                    { "endTime", endTime },
                    { "venue", txtVenue.Text.Trim() },
                    { "createdBy", teacherEmail },
                    { "createdAt", DateTime.UtcNow.ToString("o") },
                    { "status", "active" }
                };

                // Save classroom data
                await classRef.SetAsync(classData);

                // Save invited students
                CollectionReference studentsRef = classRef.Collection("invitedStudents");
                foreach (var student in invitedStudents)
                {
                    await studentsRef.Document(student.Email).SetAsync(new
                    {
                        name = student.Name,
                        email = student.Email,
                        joinedAt = FieldValue.ServerTimestamp,
                        status = "pending"
                    });
                }

                // Clear session and redirect
                Session["InvitedStudents"] = null;
                Response.Redirect("ManageClassroom.aspx?success=true");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating classroom: {ex.Message}");
                lblInviteStatus.Text = "Error creating classroom. Please try again.";
                lblInviteStatus.CssClass = "text-danger";
            }
        }
    }

    public class Student
    {
        public string Name { get; set; }
        public string Email { get; set; }
    }
}