using System;
using System.Configuration;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class AddScholarship : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
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

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                // Save scholarship data to Firestore
                DocumentReference docRef = await db.Collection("scholarships").AddAsync(new
                {
                    Title = txtTitle.Text.Trim(),
                    Requirement = txtRequirement.Text.Trim(),
                    Terms = txtTerms.Text.Trim(),
                    Courses = txtCourses.Text.Trim(),
                    Link = txtLink.Text.Trim(),
                    CreatedAt = Timestamp.GetCurrentTimestamp()
                });

                lblStatus.Text = $"✅ Scholarship saved successfully!";
                lblStatus.ForeColor = System.Drawing.Color.Green;

                // Clear form
                txtTitle.Text = "";
                txtRequirement.Text = "";
                txtTerms.Text = "";
                txtCourses.Text = "";
                txtLink.Text = "";
            }
            catch (Exception ex)
            {
                lblStatus.Text = "❌ Error: " + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}
