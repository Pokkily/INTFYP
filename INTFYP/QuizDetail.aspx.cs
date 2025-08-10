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
        public class QuizQuestionData
        {
            public string Question { get; set; }
            public List<string> Options { get; set; } = new List<string>();
            public List<int> CorrectIndexes { get; set; } = new List<int>();
            public string ImageUrl { get; set; } = "";
            public bool IsMultipleAnswer => CorrectIndexes.Count > 1;
        }

        [Serializable]
        public class QuizData
        {
            public string QuizCode { get; set; }
            public string Title { get; set; }
            public string CreatedBy { get; set; }
            public string QuizImageUrl { get; set; }
            public List<QuizQuestionData> Questions { get; set; } = new List<QuizQuestionData>();
        }

        [Serializable]
        public class UserAnswer
        {
            public List<int> SelectedIndexes { get; set; } = new List<int>();
        }

        // Properties to maintain state
        private QuizData CurrentQuiz
        {
            get => ViewState["CurrentQuiz"] as QuizData;
            set => ViewState["CurrentQuiz"] = value;
        }

        public int CurrentQuestionIndex
        {
            get => ViewState["CurrentQuestionIndex"] as int? ?? 0;
            set => ViewState["CurrentQuestionIndex"] = value;
        }

        private List<UserAnswer> UserAnswers
        {
            get => ViewState["UserAnswers"] as List<UserAnswer> ?? new List<UserAnswer>();
            set => ViewState["UserAnswers"] = value;
        }

        public int TotalQuestions => CurrentQuiz?.Questions?.Count ?? 0;
        public bool IsMultipleAnswer => CurrentQuiz?.Questions?[CurrentQuestionIndex]?.IsMultipleAnswer ?? false;

        protected async void Page_Load(object sender, EventArgs e)
        {
            await InitializeFirestore();

            if (!IsPostBack)
            {
                string quizCode = Request.QueryString["code"];
                if (string.IsNullOrEmpty(quizCode))
                {
                    Response.Redirect("Quiz.aspx");
                    return;
                }

                await LoadQuiz(quizCode);
                InitializeUserAnswers();
                DisplayCurrentQuestion();
            }
        }

        private async Task InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadQuiz(string quizCode)
        {
            try
            {
                DocumentReference docRef = db.Collection("quizzes").Document(quizCode);
                DocumentSnapshot doc = await docRef.GetSnapshotAsync();

                if (!doc.Exists)
                {
                    Response.Redirect("Quiz.aspx");
                    return;
                }

                var quiz = new QuizData
                {
                    QuizCode = quizCode,
                    Title = doc.ContainsField("title") ? doc.GetValue<string>("title") : "Quiz",
                    CreatedBy = doc.ContainsField("createdBy") ? doc.GetValue<string>("createdBy") : "Unknown",
                    QuizImageUrl = doc.ContainsField("quizImageUrl") ? doc.GetValue<string>("quizImageUrl") : ""
                };

                if (doc.ContainsField("questions"))
                {
                    var questionsData = doc.GetValue<List<Dictionary<string, object>>>("questions");
                    foreach (var questionData in questionsData)
                    {
                        var question = new QuizQuestionData
                        {
                            Question = questionData.ContainsKey("question") ? questionData["question"].ToString() : "",
                            ImageUrl = questionData.ContainsKey("imageUrl") ? questionData["imageUrl"].ToString() : ""
                        };

                        if (questionData.ContainsKey("options"))
                        {
                            var options = questionData["options"] as List<object>;
                            question.Options = options?.Select(o => o.ToString()).ToList() ?? new List<string>();
                        }

                        if (questionData.ContainsKey("correctIndexes"))
                        {
                            var correctIndexes = questionData["correctIndexes"] as List<object>;
                            question.CorrectIndexes = correctIndexes?.Select(idx => Convert.ToInt32(idx)).ToList() ?? new List<int>();
                        }

                        quiz.Questions.Add(question);
                    }
                }

                CurrentQuiz = quiz;

                // Set quiz header information
                lblQuizTitle.Text = quiz.Title;
                lblCreatedBy.Text = quiz.CreatedBy;
                lblQuizCode.Text = quiz.QuizCode;

                if (!string.IsNullOrEmpty(quiz.QuizImageUrl))
                {
                    imgQuiz.ImageUrl = quiz.QuizImageUrl;
                    imgQuiz.Visible = true;
                }

                lblTotalQuestions.Text = quiz.Questions.Count.ToString();
            }
            catch (Exception ex)
            {
                Response.Redirect("Quiz.aspx");
            }
        }

        private void InitializeUserAnswers()
        {
            var answers = new List<UserAnswer>();
            for (int i = 0; i < TotalQuestions; i++)
            {
                answers.Add(new UserAnswer());
            }
            UserAnswers = answers;
        }

        private void DisplayCurrentQuestion()
        {
            if (CurrentQuiz?.Questions == null || CurrentQuestionIndex >= CurrentQuiz.Questions.Count)
                return;

            var currentQuestion = CurrentQuiz.Questions[CurrentQuestionIndex];

            // Update question information
            lblCurrentQuestion.Text = (CurrentQuestionIndex + 1).ToString();
            lblQuestionNumber.Text = (CurrentQuestionIndex + 1).ToString();
            lblQuestion.Text = currentQuestion.Question;
            lblQuestionType.Text = currentQuestion.IsMultipleAnswer ? "Multiple Answer" : "Single Answer";

            // Show question image if available
            if (!string.IsNullOrEmpty(currentQuestion.ImageUrl))
            {
                imgQuestion.ImageUrl = currentQuestion.ImageUrl;
                imgQuestion.Visible = true;
            }
            else
            {
                imgQuestion.Visible = false;
            }

            // Bind options
            rptOptions.DataSource = currentQuestion.Options;
            rptOptions.DataBind();

            // Restore user's previous answers
            RestorePreviousAnswers();

            // Update navigation buttons
            UpdateNavigationButtons();
        }

        private void RestorePreviousAnswers()
        {
            if (UserAnswers.Count <= CurrentQuestionIndex) return;

            var userAnswer = UserAnswers[CurrentQuestionIndex];
            var currentQuestion = CurrentQuiz.Questions[CurrentQuestionIndex];

            foreach (RepeaterItem item in rptOptions.Items)
            {
                int optionIndex = item.ItemIndex;
                bool isSelected = userAnswer.SelectedIndexes.Contains(optionIndex);

                if (currentQuestion.IsMultipleAnswer)
                {
                    var checkbox = (CheckBox)item.FindControl("chkOption");
                    if (checkbox != null)
                        checkbox.Checked = isSelected;
                }
                else
                {
                    var radio = (RadioButton)item.FindControl("rdoOption");
                    if (radio != null)
                        radio.Checked = isSelected;
                }
            }

            // Add JavaScript to restore visual state after postback
            ClientScript.RegisterStartupScript(this.GetType(), "RestoreSelections",
                "restoreSelections();", true);
        }

        private void SaveCurrentAnswers()
        {
            if (UserAnswers.Count <= CurrentQuestionIndex) return;

            var currentQuestion = CurrentQuiz.Questions[CurrentQuestionIndex];
            var selectedIndexes = new List<int>();

            foreach (RepeaterItem item in rptOptions.Items)
            {
                int optionIndex = item.ItemIndex;

                if (currentQuestion.IsMultipleAnswer)
                {
                    var checkbox = (CheckBox)item.FindControl("chkOption");
                    if (checkbox != null && checkbox.Checked)
                        selectedIndexes.Add(optionIndex);
                }
                else
                {
                    var radio = (RadioButton)item.FindControl("rdoOption");
                    if (radio != null && radio.Checked)
                        selectedIndexes.Add(optionIndex);
                }
            }

            UserAnswers[CurrentQuestionIndex].SelectedIndexes = selectedIndexes;
        }

        private void UpdateNavigationButtons()
        {
            btnPrevious.Visible = CurrentQuestionIndex > 0;

            bool isLastQuestion = CurrentQuestionIndex >= TotalQuestions - 1;
            btnNext.Visible = !isLastQuestion;
            btnFinish.Visible = isLastQuestion;
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswers();

            if (CurrentQuestionIndex < TotalQuestions - 1)
            {
                CurrentQuestionIndex++;
                DisplayCurrentQuestion();
            }
        }

        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswers();

            if (CurrentQuestionIndex > 0)
            {
                CurrentQuestionIndex--;
                DisplayCurrentQuestion();
            }
        }

        protected void btnFinish_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswers();
            CalculateAndShowResults();
        }

        private void CalculateAndShowResults()
        {
            int correctAnswers = 0;
            int totalQuestions = CurrentQuiz.Questions.Count;

            for (int i = 0; i < totalQuestions; i++)
            {
                var question = CurrentQuiz.Questions[i];
                var userAnswer = UserAnswers[i];

                // Check if user's answer matches the correct answer exactly
                var correctIndexes = question.CorrectIndexes.OrderBy(x => x).ToList();
                var userIndexes = userAnswer.SelectedIndexes.OrderBy(x => x).ToList();

                if (correctIndexes.SequenceEqual(userIndexes))
                {
                    correctAnswers++;
                }
            }

            // Calculate percentage
            int percentage = totalQuestions > 0 ? (correctAnswers * 100) / totalQuestions : 0;

            // Show results
            lblScorePercentage.Text = percentage.ToString();
            lblCorrectAnswers.Text = correctAnswers.ToString();
            lblTotalQuestionsResult.Text = totalQuestions.ToString();

            // Hide quiz content and show results
            pnlQuizHeader.Visible = false;
            pnlProgress.Visible = false;
            pnlQuestion.Visible = false;
            pnlResults.Visible = true;
        }

        protected void btnTryAgain_Click(object sender, EventArgs e)
        {
            // Reset quiz state
            CurrentQuestionIndex = 0;
            InitializeUserAnswers();

            // Show quiz content and hide results
            pnlQuizHeader.Visible = true;
            pnlProgress.Visible = true;
            pnlQuestion.Visible = true;
            pnlResults.Visible = false;

            DisplayCurrentQuestion();
        }

        protected void btnBackToQuizzes_Click(object sender, EventArgs e)
        {
            Response.Redirect("Quiz.aspx");
        }
    }
}