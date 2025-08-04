using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Collections.Generic;
using Google.Cloud.Firestore;

namespace YourNamespace
{
    public partial class Korean : Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadLessonStatusesAsync();
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

        private async void LoadLessonStatusesAsync()
        {
            InitializeFirestore();

            string userId = Session["userId"]?.ToString();
            if (string.IsNullOrEmpty(userId))
                return;

            // Travel
            await LoadLessonStatus("KoreanTravel1_Results", travelLesson1StatusLiteral);
            await LoadLessonStatus("KoreanTravel2_Results", travelLesson2StatusLiteral);
            await LoadLessonStatus("KoreanTravel3_Results", travelLesson3StatusLiteral);

            // Coffee Shop
            await LoadLessonStatus("KoreanCSL1_Results", lesson1StatusLiteral);
            await LoadLessonStatus("KoreanCSL2_Results", lesson2StatusLiteral);
            await LoadLessonStatus("KoreanCSL3_Results", lesson3StatusLiteral);

            // Market
            await LoadLessonStatus("KoreanMarket1_Results", marketLesson1StatusLiteral);
            await LoadLessonStatus("KoreanMarket2_Results", marketLesson2StatusLiteral);
            await LoadLessonStatus("KoreanMarket3_Results", marketLesson3StatusLiteral);

            // Restaurant
            await LoadLessonStatus("KoreanRestaurant1_Results", restLesson1StatusLiteral);
            await LoadLessonStatus("KoreanRestaurant2_Results", restLesson2StatusLiteral);
            await LoadLessonStatus("KoreanRestaurant3_Results", restLesson3StatusLiteral);
        }


        private async Task LoadLessonStatus(string collectionName, System.Web.UI.WebControls.Literal statusLiteral)
        {
            DocumentReference userDoc = db.Collection("users").Document(Session["userId"].ToString());
            CollectionReference resultCol = userDoc.Collection(collectionName);
            QuerySnapshot snapshot = await resultCol.GetSnapshotAsync();

            double highestScore = 0;
            string highestStatus = null;
            DateTime highestTime = DateTime.MinValue;

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                if (doc.Exists)
                {
                    Dictionary<string, object> data = doc.ToDictionary();

                    if (data.TryGetValue("score", out object scoreObj) && double.TryParse(scoreObj.ToString(), out double score))
                    {
                        if (score > highestScore)
                        {
                            highestScore = score;

                            if (data.TryGetValue("status", out object statusObj))
                                highestStatus = statusObj?.ToString();

                            if (data.TryGetValue("timestamp", out object timeObj) && timeObj is Timestamp ts)
                                highestTime = ts.ToDateTime();
                        }
                    }
                }
            }

            if (!string.IsNullOrEmpty(highestStatus))
            {
                statusLiteral.Text = $"<div style='color: green;'>Progress: {highestStatus} ({highestTime:g})</div>";
            }
            else
            {
                statusLiteral.Text = "<div style='color: red;'>Status: No Progress!</div>";
            }
        }
    }
}
