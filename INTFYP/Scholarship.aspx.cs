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
                LoadScholarships();
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

                Console.WriteLine("Scholarships loaded: " + scholarshipList.Count);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error loading scholarships: " + ex.Message);
            }
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
