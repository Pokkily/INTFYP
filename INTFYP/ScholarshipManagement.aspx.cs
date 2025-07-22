using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;

namespace YourProjectNamespace
{
    public partial class ScholarshipManagement : System.Web.UI.Page
    {
        private static FirestoreDb db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore();
                LoadResultCards();
            }
        }

        private void InitializeFirestore()
        {
            if (db == null)
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto");
            }
        }

        private async void LoadResultCards()
        {
            QuerySnapshot snapshot = await db.Collection("results").GetSnapshotAsync();

            List<Dictionary<string, object>> resultList = new List<Dictionary<string, object>>();

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                var data = doc.ToDictionary();
                data["DocId"] = doc.Id; // Needed for commands
                resultList.Add(data);
            }

            rptResults.DataSource = resultList;
            rptResults.DataBind();
        }

        protected async void ResultCommand(object sender, CommandEventArgs e)
        {
            string docId = e.CommandArgument.ToString();
            DocumentReference docRef = db.Collection("results").Document(docId);

            string status = e.CommandName == "Verify" ? "Verified" : "Rejected";

            await docRef.UpdateAsync("Status", status);

            LoadResultCards(); // Refresh the cards
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Your scholarship save logic here
        }
    }
}
