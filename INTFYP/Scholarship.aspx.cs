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
                LoadScholarships(); // Load scholarships from Firestore
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
                    rptSubjects.Visible = true;
                }
                else
                {
                    rptSubjects.Visible = false;
                }
            }
            else
            {
                lblSubmittedTime.Text = "-";
                lblStatus.Text = "No Submission Found";
                rptSubjects.Visible = false;
            }
        }

        private async void LoadScholarships()
        {
            try
            {
                CollectionReference scholarshipsRef = db.Collection("scholarships");
                QuerySnapshot snapshot = await scholarshipsRef.GetSnapshotAsync();

                List<ScholarshipItem> scholarshipList = new List<ScholarshipItem>();

                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    Dictionary<string, object> data = doc.ToDictionary();

                    scholarshipList.Add(new ScholarshipItem
                    {
                        Title = data.ContainsKey("Title") ? data["Title"].ToString() : "",
                        Requirement = data.ContainsKey("Requirement") ? data["Requirement"].ToString() : "",
                        Terms = data.ContainsKey("Terms") ? data["Terms"].ToString() : "",
                        Courses = data.ContainsKey("Courses") ? data["Courses"].ToString() : "",
                        Link = data.ContainsKey("Link") ? data["Link"].ToString() : "#"
                    });
                }

                rptScholarships.DataSource = scholarshipList;
                rptScholarships.DataBind();

                // Debug
                Console.WriteLine("Scholarships loaded: " + scholarshipList.Count);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error loading scholarships: " + ex.Message);
            }
        }


        public class SubjectGrade
        {
            public string Subject { get; set; }
            public string Grade { get; set; }
        }

        public class ScholarshipItem
        {
            public string Title { get; set; }
            public string Requirement { get; set; }
            public string Terms { get; set; }
            public string Courses { get; set; }
            public string Link { get; set; }
        }
    }
}
