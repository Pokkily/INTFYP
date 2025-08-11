using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using Google.Cloud.Firestore;

namespace YourNamespace
{
    public partial class Learning : Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                await LoadTopLessonsAsync();
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

        private async Task LoadTopLessonsAsync()
        {
            InitializeFirestore();
            string userId = Session["userId"]?.ToString();
            if (string.IsNullOrEmpty(userId)) return;

            var lessonNames = new List<string>
            {
                "KoreanTravelLesson1Result","KoreanTravelLesson2Result","KoreanTravelLesson3Result",
                "KoreanCoffeeShopLesson1Result","KoreanCoffeeShopLesson2Result","KoreanCoffeeShopLesson3Result",
                "KoreanMarketLesson1Result","KoreanMarketLesson2Result","KoreanMarketLesson3Result",
                "KoreanRestaurantLesson1Result","KoreanRestaurantLesson2Result","KoreanRestaurantLesson3Result"
            };

            var statsList = new List<LessonStat>();

            foreach (var lesson in lessonNames)
            {
                var attempts = await GetAllAttempts(userId, lesson);
                if (attempts.Count == 0) continue;

                double totalMinutes = attempts.Sum(a => a.DurationSeconds) / 60.0;
                statsList.Add(new LessonStat
                {
                    LessonName = lesson,
                    Attempts = attempts.Count,
                    TotalMinutes = totalMinutes
                });
            }

            var topLessons = statsList
                .OrderByDescending(l => l.TotalMinutes)
                .Take(10)
                .ToList();

            rptTopLessons.DataSource = topLessons;
            rptTopLessons.DataBind();
        }

        private async Task<List<LessonAttempt>> GetAllAttempts(string userId, string lessonName)
        {
            DocumentReference userDoc = db.Collection("users").Document(userId);
            CollectionReference attemptsCol = userDoc
                .Collection("results")
                .Document(lessonName)
                .Collection("attempts");

            QuerySnapshot snapshot = await attemptsCol.OrderBy("timestamp").GetSnapshotAsync();
            var attemptsList = new List<LessonAttempt>();

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                if (!doc.Exists) continue;
                var data = doc.ToDictionary();
                double durationSeconds = data.ContainsKey("durationSeconds") ? Convert.ToDouble(data["durationSeconds"]) : 0;
                attemptsList.Add(new LessonAttempt { DurationSeconds = durationSeconds });
            }

            return attemptsList;
        }

        private class LessonAttempt
        {
            public double DurationSeconds { get; set; }
        }

        private class LessonStat
        {
            public string LessonName { get; set; }
            public int Attempts { get; set; }
            public double TotalMinutes { get; set; }
        }
    }
}
