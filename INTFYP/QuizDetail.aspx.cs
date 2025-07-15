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
        private string QuizCode = "";

        [Serializable]
        public class QuizQuestion
        {
            public string question { get; set; }
            public List<string> options { get; set; }
            public string imageUrl { get; set; }
        }

        private List<QuizQuestion> AllQuestions
        {
            get => Session["QuizQuestions"] as List<QuizQuestion>;
            set => Session["QuizQuestions"] = value;
        }

        private Dictionary<int, string> SelectedAnswers
        {
            get => Session["SelectedAnswers"] as Dictionary<int, string> ?? new Dictionary<int, string>();
            set => Session["SelectedAnswers"] = value;
        }

        private int CurrentQuestionIndex
        {
            get => Session["CurrentQuestionIndex"] != null ? (int)Session["CurrentQuestionIndex"] : 0;
            set => Session["CurrentQuestionIndex"] = value;
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            QuizCode = Request.QueryString["code"];
            if (string.IsNullOrEmpty(QuizCode)) return;

            InitializeFirestore();

            if (!IsPostBack)
            {
                await LoadQuizData(QuizCode);
            }

            DisplayCurrentQuestion();
        }

        private void InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadQuizData(string quizCode)
        {
            try
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
                            question = q.ContainsKey("question") ? q["question"].ToString() : "",
                            options = q.ContainsKey("options") ? (q["options"] as List<object>).ConvertAll(o => o.ToString()) : new List<string>(),
                            imageUrl = q.ContainsKey("imageUrl") ? q["imageUrl"].ToString() : ""
                        });
                    }

                    AllQuestions = parsed;
                    SelectedAnswers = new Dictionary<int, string>();
                    CurrentQuestionIndex = 0;
                }
            }
            catch (Exception ex)
            {
                questionText.InnerText = "Error loading quiz: " + ex.Message;
            }
        }

        // Rest of your methods remain the same...
        private void DisplayCurrentQuestion()
        {
            if (AllQuestions == null || CurrentQuestionIndex >= AllQuestions.Count) return;

            var current = AllQuestions[CurrentQuestionIndex];
            questionText.InnerText = $"Q{CurrentQuestionIndex + 1}. {current.question}";

            rblOptions.Items.Clear();
            foreach (var option in current.options)
            {
                rblOptions.Items.Add(new ListItem(option, option));
            }

            imgQuestionImage.Visible = !string.IsNullOrEmpty(current.imageUrl);
            if (imgQuestionImage.Visible)
                imgQuestionImage.ImageUrl = current.imageUrl;

            btnNext.Visible = (CurrentQuestionIndex < AllQuestions.Count - 1);
            btnSubmit.Visible = (CurrentQuestionIndex == AllQuestions.Count - 1);

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
            Response.Redirect("QuizResult.aspx");
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