using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class QuizDetail : Page
    {
        private FirestoreDb db;


        [Serializable]
        public class QuizQuestion
        {
            public string question { get; set; }
            public List<string> options { get; set; }
            public string imageUrl { get; set; }
            public List<int> correctIndexes { get; set; }
            public bool isMultiSelect { get; set; }
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string quizCode = Request.QueryString["code"];
                if (string.IsNullOrEmpty(quizCode)) return;

                InitializeFirestore();
                await LoadQuizData(quizCode);
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
                    Session["QuizTitle"] = doc.GetValue<string>("title");
                    var questions = doc.GetValue<List<Dictionary<string, object>>>("questions");

                    var parsed = new List<QuizQuestion>();
                    foreach (var q in questions)
                    {
                        var question = new QuizQuestion
                        {
                            question = q.ContainsKey("question") ? q["question"].ToString() : "",
                            options = q.ContainsKey("options") ? (q["options"] as List<object>).ConvertAll(o => o.ToString()) : new List<string>(),
                            imageUrl = q.ContainsKey("imageUrl") ? q["imageUrl"].ToString() : "",
                            correctIndexes = new List<int>()
                        };

                        // Determine if this is a multi-select question
                        if (q.ContainsKey("correctIndexes"))
                        {
                            question.correctIndexes = (q["correctIndexes"] as List<object>).ConvertAll(o => Convert.ToInt32(o));
                            question.isMultiSelect = question.correctIndexes.Count > 1;
                        }

                        parsed.Add(question);
                    }

                    Session["QuizQuestions"] = parsed;
                    Session["SelectedAnswers"] = new Dictionary<int, List<int>>(); // Stores selected option indexes
                    Session["CurrentQuestionIndex"] = 0;
                }
            }
            catch (Exception ex)
            {
                questionText.InnerText = "Error loading quiz: " + ex.Message;
            }
        }

        // Public methods for ASPX page to access data
        public string GetQuizTitle()
        {
            return Session["QuizTitle"]?.ToString() ?? "Quiz";
        }

        public int GetTotalQuestions()
        {
            var questions = Session["QuizQuestions"] as List<QuizQuestion>;
            return questions?.Count ?? 0;
        }

        public int GetCurrentQuestionNumber()
        {
            int index = Session["CurrentQuestionIndex"] != null ? (int)Session["CurrentQuestionIndex"] : 0;
            return index + 1;
        }

        public int GetProgressWidth()
        {
            var questions = Session["QuizQuestions"] as List<QuizQuestion>;
            if (questions == null || questions.Count == 0)
                return 0;

            int index = Session["CurrentQuestionIndex"] != null ? (int)Session["CurrentQuestionIndex"] : 0;
            return (index + 1) * 100 / questions.Count;
        }

        private void DisplayCurrentQuestion()
        {
            var questions = Session["QuizQuestions"] as List<QuizQuestion>;
            if (questions == null) return;

            int currentIndex = Session["CurrentQuestionIndex"] != null ? (int)Session["CurrentQuestionIndex"] : 0;
            if (currentIndex >= questions.Count) return;

            var current = questions[currentIndex];
            questionText.InnerText = $"Q{currentIndex + 1}. {current.question}";

            cblOptions.Items.Clear();
            foreach (var option in current.options)
            {
                cblOptions.Items.Add(new ListItem(option));
            }

            // Show multi-select notice if applicable
            lblMultiSelectNotice.Visible = current.isMultiSelect;
            if (current.isMultiSelect)
            {
                lblMultiSelectNotice.Text = "(Select all that apply - " + current.correctIndexes.Count + " correct answers)";
            }

            imgQuestionImage.Visible = !string.IsNullOrEmpty(current.imageUrl);
            if (imgQuestionImage.Visible)
                imgQuestionImage.ImageUrl = current.imageUrl;

            btnNext.Visible = (currentIndex < questions.Count - 1);
            btnSubmit.Visible = (currentIndex == questions.Count - 1);

            // Restore selected answers
            var selectedAnswers = Session["SelectedAnswers"] as Dictionary<int, List<int>>;
            if (selectedAnswers != null && selectedAnswers.ContainsKey(currentIndex))
            {
                foreach (int selectedIndex in selectedAnswers[currentIndex])
                {
                    if (selectedIndex >= 0 && selectedIndex < cblOptions.Items.Count)
                    {
                        cblOptions.Items[selectedIndex].Selected = true;
                    }
                }
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            int currentIndex = Session["CurrentQuestionIndex"] != null ? (int)Session["CurrentQuestionIndex"] : 0;
            Session["CurrentQuestionIndex"] = currentIndex + 1;
            DisplayCurrentQuestion();
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();

            // Store the quiz data in session before redirecting
            Session["QuizTitle"] = Session["QuizTitle"];
            Session["QuizQuestions"] = Session["QuizQuestions"];
            Session["SelectedAnswers"] = Session["SelectedAnswers"];

            Response.Redirect("QuizResult.aspx");
        }

        private void SaveCurrentAnswer()
        {
            int currentIndex = (int)Session["CurrentQuestionIndex"];
            var selectedAnswers = Session["SelectedAnswers"] as Dictionary<int, List<int>> ?? new Dictionary<int, List<int>>();

            // Get all selected option indexes
            var selectedIndexes = new List<int>();
            for (int i = 0; i < cblOptions.Items.Count; i++)
            {
                if (cblOptions.Items[i].Selected)
                {
                    selectedIndexes.Add(i);
                }
            }

            selectedAnswers[currentIndex] = selectedIndexes;
            Session["SelectedAnswers"] = selectedAnswers;
        }
    }
}