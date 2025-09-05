using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class AddScholarship : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
            if (!IsPostBack)
            {
                await LoadScholarships();
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

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
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

                txtTitle.Text = "";
                txtRequirement.Text = "";
                txtTerms.Text = "";
                txtCourses.Text = "";
                txtLink.Text = "";

                await LoadScholarships();
            }
            catch (Exception ex)
            {
                lblStatus.Text = "❌ Error: " + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }

        private async System.Threading.Tasks.Task LoadScholarships()
        {
            try
            {
                Query scholarshipsQuery = db.Collection("scholarships").OrderByDescending("CreatedAt");
                QuerySnapshot snapshot = await scholarshipsQuery.GetSnapshotAsync();

                var scholarships = new List<object>();
                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var data = document.ToDictionary();
                    scholarships.Add(new
                    {
                        Id = document.Id,
                        Title = data.ContainsKey("Title") ? data["Title"].ToString() : "",
                        Requirement = data.ContainsKey("Requirement") ? data["Requirement"].ToString() : "",
                        Terms = data.ContainsKey("Terms") ? data["Terms"].ToString() : "",
                        Courses = data.ContainsKey("Courses") ? data["Courses"].ToString() : "",
                        Link = data.ContainsKey("Link") ? data["Link"].ToString() : ""
                    });
                }

                rptScholarships.DataSource = scholarships;
                rptScholarships.DataBind();

                pnlNoScholarships.Visible = scholarships.Count == 0;
            }
            catch (Exception ex)
            {
                lblListStatus.ForeColor = System.Drawing.Color.Red;
                lblListStatus.Text = "❌ Error loading scholarships: " + ex.Message;
            }
        }

        protected async void rptScholarships_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string scholarshipId = e.CommandArgument.ToString();

            try
            {
                if (e.CommandName == "Update")
                {
                    await UpdateScholarship(e, scholarshipId);
                }
                else if (e.CommandName == "Delete")
                {
                    await DeleteScholarship(scholarshipId);
                }
            }
            catch (Exception ex)
            {
                lblListStatus.ForeColor = System.Drawing.Color.Red;
                lblListStatus.Text = "❌ Error: " + ex.Message;
            }
        }

        private async System.Threading.Tasks.Task UpdateScholarship(RepeaterCommandEventArgs e, string scholarshipId)
        {
            TextBox txtEditTitle = (TextBox)e.Item.FindControl("txtEditTitle");
            TextBox txtEditRequirement = (TextBox)e.Item.FindControl("txtEditRequirement");
            TextBox txtEditTerms = (TextBox)e.Item.FindControl("txtEditTerms");
            TextBox txtEditCourses = (TextBox)e.Item.FindControl("txtEditCourses");
            TextBox txtEditLink = (TextBox)e.Item.FindControl("txtEditLink");

            DocumentReference scholarshipRef = db.Collection("scholarships").Document(scholarshipId);
            var updates = new Dictionary<string, object>
            {
                { "Title", txtEditTitle.Text.Trim() },
                { "Requirement", txtEditRequirement.Text.Trim() },
                { "Terms", txtEditTerms.Text.Trim() },
                { "Courses", txtEditCourses.Text.Trim() },
                { "Link", txtEditLink.Text.Trim() },
                { "UpdatedAt", Timestamp.GetCurrentTimestamp() }
            };

            await scholarshipRef.UpdateAsync(updates);

            lblListStatus.ForeColor = System.Drawing.Color.Green;
            lblListStatus.Text = "✅ Scholarship updated successfully!";

            await LoadScholarships();
        }

        private async System.Threading.Tasks.Task DeleteScholarship(string scholarshipId)
        {
            DocumentReference scholarshipRef = db.Collection("scholarships").Document(scholarshipId);
            await scholarshipRef.DeleteAsync();

            lblListStatus.ForeColor = System.Drawing.Color.Green;
            lblListStatus.Text = "✅ Scholarship deleted successfully!";

            await LoadScholarships();
        }
    }
}