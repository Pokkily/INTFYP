using Google.Cloud.Firestore;
using System;
using System.Web.UI;

namespace INTFYP
{
    public partial class AddBook : Page
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
                DocumentReference addedDocRef = await db.Collection("books").AddAsync(new 
                {
                    Title = txtTitle.Text.Trim(),
                    Author = txtAuthor.Text.Trim(),
                    Category = txtCategory.Text.Trim(),
                    CreatedAt = Timestamp.GetCurrentTimestamp()
                });

                lblStatus.Text = $"✅ Book added successfully! (ID: {addedDocRef.Id})";
                lblStatus.ForeColor = System.Drawing.Color.Green;
            }
            catch (Exception ex)
            {
                lblStatus.ForeColor = System.Drawing.Color.Red;
                lblStatus.Text = "❌ Error: " + ex.Message;
            }
        }
    }

    [FirestoreData]
    public class NewBook
    {
        [FirestoreProperty] public string Title { get; set; }
        [FirestoreProperty] public string Author { get; set; }
        [FirestoreProperty] public string Category { get; set; }
        [FirestoreProperty] public Timestamp CreatedAt { get; set; }
    }
}
