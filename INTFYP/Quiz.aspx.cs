using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class Quiz : Page
    {
        private FirestoreDb db;

        protected async void Page_Load(object sender, EventArgs e)
        {
            await InitializeFirestore();

            if (!IsPostBack)
            {
                await LoadAllQuizzes();
            }
        }


        private async Task InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadAllQuizzes()
        {
            try
            {
                Query query = db.Collection("quizzes");
                QuerySnapshot snapshot = await query.GetSnapshotAsync();
                DisplayQuizzes(snapshot);
            }
            catch (Exception ex)
            {
                pnlNoResults.Visible = true;
            }
        }

        private void DisplayQuizzes(QuerySnapshot snapshot)
        {
            var quizzes = new List<QuizData>();

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                quizzes.Add(CreateQuizData(doc));
            }

            rptQuizzes.DataSource = quizzes;
            rptQuizzes.DataBind();
            pnlNoResults.Visible = quizzes.Count == 0;
        }

        private QuizData CreateQuizData(DocumentSnapshot doc)
        {
            var quiz = new QuizData
            {
                QuizCode = doc.Id,
                Title = doc.ContainsField("title") ? doc.GetValue<string>("title") : "(No Title)",
                CreatedBy = doc.ContainsField("createdBy") ? doc.GetValue<string>("createdBy") : "Unknown",
                QuizImageUrl = doc.ContainsField("quizImageUrl") ? doc.GetValue<string>("quizImageUrl") : ""
            };

            if (doc.ContainsField("createdAt"))
            {
                var timestamp = doc.GetValue<Timestamp>("createdAt");
                quiz.CreatedAtString = timestamp.ToDateTime().ToString("dd MMMM yyyy");
            }
            else
            {
                quiz.CreatedAtString = "Unknown Date";
            }

            return quiz;
        }


        protected async void txtSearchTitle_TextChanged(object sender, EventArgs e)
        {
            string searchTerm = txtSearchTitle.Text.Trim();
            await SearchQuizzes(searchTerm, isCodeSearch: false);
        }

        protected async void txtSearchCode_TextChanged(object sender, EventArgs e)
        {
            string code = txtSearchCode.Text.Trim();
            await SearchQuizzes(code, isCodeSearch: true);
        }

        private async Task SearchQuizzes(string searchTerm, bool isCodeSearch)
        {
            try
            {
                Query query;
                if (isCodeSearch)
                {
                    if (string.IsNullOrEmpty(searchTerm))
                    {
                        await LoadAllQuizzes();
                        return;
                    }
                    // Search by exact quiz code (document ID)
                    DocumentReference docRef = db.Collection("quizzes").Document(searchTerm);
                    DocumentSnapshot doc = await docRef.GetSnapshotAsync();

                    if (doc.Exists)
                    {
                        rptQuizzes.DataSource = new List<QuizData> { CreateQuizData(doc) };
                        pnlNoResults.Visible = false;
                    }
                    else
                    {
                        rptQuizzes.DataSource = null;
                        pnlNoResults.Visible = true;
                    }
                    rptQuizzes.DataBind();
                }
                else
                {
                    if (string.IsNullOrEmpty(searchTerm))
                    {
                        await LoadAllQuizzes();
                        return;
                    }
                    // Search by title containing the term (case insensitive)
                    query = db.Collection("quizzes")
                             .WhereGreaterThanOrEqualTo("title", searchTerm)
                             .WhereLessThanOrEqualTo("title", searchTerm + "\uf8ff");

                    QuerySnapshot snapshot = await query.GetSnapshotAsync();
                    DisplayQuizzes(snapshot);
                }
            }
            catch (Exception ex)
            {
                pnlNoResults.Visible = true;
            }
        }

        protected void rptQuizzes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Play")
            {
                string quizCode = e.CommandArgument.ToString();
                Response.Redirect($"QuizDetail.aspx?code={quizCode}");
            }
        }
    }

    public class QuizData
    {
        public string QuizCode { get; set; }
        public string Title { get; set; }
        public string CreatedBy { get; set; }
        public string CreatedAtString { get; set; }
        public string QuizImageUrl { get; set; }
    }

}