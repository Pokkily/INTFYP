using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class QuizDetail : Page
    {
        private FirestoreDb db;
        protected string QuizTitle = "";

        public class QuizQuestion
        {
            public string Question { get; set; }
            public List<string> Options { get; set; }
            public string ImageUrl { get; set; }
        }

        private List<QuizQuestion> AllQuestions
        {
            get => ViewState["AllQuestions"] as List<QuizQuestion> ?? new List<QuizQuestion>();
            set => ViewState["AllQuestions"] = value;
        }

        private Dictionary<int, string> SelectedAnswers
        {
            get => ViewState["SelectedAnswers"] as Dictionary<int, string> ?? new Dictionary<int, string>();
            set => ViewState["SelectedAnswers"] = value;
        }

        private int CurrentQuestionIndex
        {
            get => ViewState["CurrentQuestionIndex"] != null ? (int)ViewState["CurrentQuestionIndex"] : 0;
            set => ViewState["CurrentQuestionIndex"] = value;
        }

        protected async Task Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string quizCode = Request.QueryString["code"];
                if (string.IsNullOrEmpty(quizCode)) return;

                InitializeFirestore();
                await LoadQuizData(quizCode);
                DisplayCurrentQuestion();
            }
        }

        private void InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadQuizData(string quizCode)
        {
            var docRef = db.Collection("quizzes").Document(quizCode);
            var doc = await docRef.GetSnapshotAsync();

            if (doc.Exists)
            {
                QuizTitle = doc.GetValue<string>("title");
                var questions = doc.GetValue<List<Dictionary<string, object>>>("questions");

                var parsed = new List<QuizQuestion>();
                foreach (var q in questions)
                {
                    parsed.Add(new QuizQuestion
                    {
                        Question = q["question"].ToString(),
                        Options = (q["options"] as List<object>).ConvertAll(o => o.ToString()),
                        ImageUrl = q.ContainsKey("imageUrl") ? q["imageUrl"].ToString() : ""
                    });
                }

                AllQuestions = parsed;
                ViewState["SelectedAnswers"] = new Dictionary<int, string>();
                CurrentQuestionIndex = 0;
            }
        }

        private void DisplayCurrentQuestion()
        {
            if (CurrentQuestionIndex >= AllQuestions.Count) return;

            var current = AllQuestions[CurrentQuestionIndex];
            questionText.InnerText = $"Q{CurrentQuestionIndex + 1}. {current.Question}";

            rblOptions.Items.Clear();
            foreach (var option in current.Options)
            {
                rblOptions.Items.Add(new ListItem(option, option));
            }

            imgQuestionImage.Visible = !string.IsNullOrEmpty(current.ImageUrl);
            if (imgQuestionImage.Visible)
                imgQuestionImage.ImageUrl = current.ImageUrl;

            btnNext.Visible = (CurrentQuestionIndex < AllQuestions.Count - 1);
            btnSubmit.Visible = (CurrentQuestionIndex == AllQuestions.Count - 1);

            // Pre-fill answer if previously selected
            if (SelectedAnswers.ContainsKey(CurrentQuestionIndex))
            {
                string prevAnswer = SelectedAnswers[CurrentQuestionIndex];
                var item = rblOptions.Items.FindByValue(prevAnswer);
                if (item != null)
                    item.Selected = true;
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            CurrentQuestionIndex++;
            DisplayCurrentQuestion();
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            Session["UserAnswers"] = SelectedAnswers;
            Response.Redirect("QuizResult.aspx"); // or show a modal, etc.
        }

        private void SaveCurrentAnswer()
        {
            if (rblOptions.SelectedItem != null)
            {
                SelectedAnswers[CurrentQuestionIndex] = rblOptions.SelectedItem.Value;
            }
        }
    }
}
