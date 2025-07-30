using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Google.Cloud.Firestore;

namespace YourNamespace
{
    public partial class Scholarship : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
            {
                LoadStudentResult();
            }
        }

        private void InitializeFirestore()
        {
            if (db == null)
            {
                lock (dbLock)
                {
                    if (db == null)
                    {
                        string path = Server.MapPath("~/serviceAccountKey.json");
                        Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                        db = FirestoreDb.Create("intorannetto");
                    }
                }
            }
        }

        private async void LoadStudentResult()
        {
            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId)) return;

            Query query = db.Collection("results").WhereEqualTo("StudentId", userId);
            QuerySnapshot snapshot = await query.GetSnapshotAsync();

            if (snapshot.Count > 0)
            {
                DocumentSnapshot doc = snapshot.Documents.OrderByDescending(d => d.CreateTime).First();
                Dictionary<string, object> data = doc.ToDictionary();

                lblSubmittedTime.Text = doc.CreateTime?.ToDateTime().ToString("yyyy-MM-dd HH:mm") ?? "-";
                string status = data.ContainsKey("Status") ? data["Status"].ToString() : "Unknown";
                lblStatus.Text = status;

                if (status == "Verified")
                {
                    // Show subject grades only if Verified
                    List<SubjectGrade> subjectGrades = new List<SubjectGrade>();
                    for (int i = 1; i <= 15; i++)
                    {
                        if (data.ContainsKey($"Subject{i}") && data.ContainsKey($"Grade{i}"))
                        {
                            subjectGrades.Add(new SubjectGrade
                            {
                                Subject = data[$"Subject{i}"].ToString(),
                                Grade = data[$"Grade{i}"].ToString()
                            });
                        }
                    }

                    rptSubjects.DataSource = subjectGrades;
                    rptSubjects.DataBind();
                    rptSubjects.Visible = true; // Make sure it's visible
                }
                else
                {
                    rptSubjects.Visible = false; // Hide the subject list for Pending/Rejected
                }
            }
            else
            {
                lblSubmittedTime.Text = "-";
                lblStatus.Text = "No Submission Found";
                rptSubjects.Visible = false; // Hide in case of no data
            }
        }


        public class SubjectGrade
        {
            public string Subject { get; set; }
            public string Grade { get; set; }
        }
    }
}
