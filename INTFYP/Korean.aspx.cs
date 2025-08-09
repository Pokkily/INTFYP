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
            await LoadLessonStatus("KoreanTravelLesson1Result", travelLesson1StatusLiteral);
            await LoadLessonStatus("KoreanTravelLesson2Result", travelLesson2StatusLiteral);
            await LoadLessonStatus("KoreanTravelLesson3Result", travelLesson3StatusLiteral);

            // Coffee Shop
            await LoadLessonStatus("KoreanCoffeeShopLesson1Result", lesson1StatusLiteral);
            await LoadLessonStatus("KoreanCoffeeShopLesson2Result", lesson2StatusLiteral);
            await LoadLessonStatus("KoreanCoffeeShopLesson3Result", lesson3StatusLiteral);

            // Market
            await LoadLessonStatus("KoreanMarketLesson1Result", marketLesson1StatusLiteral);
            await LoadLessonStatus("KoreanMarketLesson2Result", marketLesson2StatusLiteral);
            await LoadLessonStatus("KoreanMarketLesson3Result", marketLesson3StatusLiteral);

            // Restaurant
            await LoadLessonStatus("KoreanRestaurantLesson1Result", restLesson1StatusLiteral);
            await LoadLessonStatus("KoreanRestaurantLesson2Result", restLesson2StatusLiteral);
            await LoadLessonStatus("KoreanRestaurantLesson3Result", restLesson3StatusLiteral);
        }


        private async Task LoadLessonStatus(string lessonName, System.Web.UI.WebControls.Literal statusLiteral)
        {
            DocumentReference userDoc = db.Collection("users").Document(Session["userId"].ToString());

            // Navigate to: users/[userId]/results/[lessonName]/attempts
            CollectionReference attemptsCol = userDoc
                .Collection("results")
                .Document(lessonName)
                .Collection("attempts");

            QuerySnapshot snapshot = await attemptsCol.GetSnapshotAsync();

            double highestScore = -1;
            DateTime earliestTime = DateTime.MaxValue;
            string bestStatus = null;

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                if (!doc.Exists) continue;

                Dictionary<string, object> data = doc.ToDictionary();

                if (data.TryGetValue("score", out object scoreObj) &&
                    double.TryParse(scoreObj.ToString(), out double score) &&
                    data.TryGetValue("timestamp", out object timeObj) && timeObj is Timestamp ts)
                {
                    DateTime thisTime = ts.ToDateTime();

                    if (score > highestScore)
                    {
                        highestScore = score;
                        earliestTime = thisTime;
                        bestStatus = data.ContainsKey("status") ? data["status"]?.ToString() : null;
                    }
                    else if (score == highestScore && thisTime < earliestTime)
                    {
                        earliestTime = thisTime;
                        bestStatus = data.ContainsKey("status") ? data["status"]?.ToString() : null;
                    }
                }
            }

            if (highestScore >= 0 && !string.IsNullOrEmpty(bestStatus))
            {
                statusLiteral.Text = $"<div style='color: green;'>Progress: {bestStatus}<br/>Score: {highestScore}<br/></div>";
            }
            else
            {
                statusLiteral.Text = "<div style='color: red;'>Status: No Progress!</div>";
            }
        }




    }
}
