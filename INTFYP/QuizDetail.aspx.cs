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

        // New classes for detailed tracking
        [Serializable]
        public class QuestionAttemptData
        {
            public int QuestionIndex { get; set; }
            public string QuestionText { get; set; }
            public List<string> Options { get; set; } = new List<string>();
            public List<int> UserSelectedIndexes { get; set; } = new List<int>();
            public List<int> CorrectIndexes { get; set; } = new List<int>();
            public bool IsCorrect { get; set; }
            public bool IsMultipleChoice { get; set; }
            public DateTime AnsweredAt { get; set; }
            public int TimeSpentSeconds { get; set; } // Time spent on this question
        }

        [Serializable]
        public class QuizAttemptData
        {
            public string AttemptId { get; set; } = Guid.NewGuid().ToString();
            public string QuizCode { get; set; }
            public string QuizTitle { get; set; }
            public string QuizCreatedBy { get; set; }

            // User Information
            public string UserId { get; set; } // Could be session ID, user login, or anonymous ID
            public string UserName { get; set; } = "Anonymous";
            public string UserEmail { get; set; } = "";
            public string UserIP { get; set; }
            public string UserAgent { get; set; }

            // Timing Information
            public DateTime StartedAt { get; set; }
            public DateTime CompletedAt { get; set; }
            public int TotalTimeSeconds { get; set; }

            // Score Information
            public int TotalQuestions { get; set; }
            public int CorrectAnswers { get; set; }
            public double ScorePercentage { get; set; }
            public string Grade { get; set; } // A, B, C, D, F based on percentage

            // Detailed Question Data
            public List<QuestionAttemptData> QuestionAttempts { get; set; } = new List<QuestionAttemptData>();

            // Additional Analytics
            public Dictionary<string, object> AdditionalData { get; set; } = new Dictionary<string, object>();
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

        private DateTime QuizStartTime
        {
            get => ViewState["QuizStartTime"] as DateTime? ?? DateTime.Now;
            set => ViewState["QuizStartTime"] = value;
        }

        private DateTime CurrentQuestionStartTime
        {
            get => ViewState["CurrentQuestionStartTime"] as DateTime? ?? DateTime.Now;
            set => ViewState["CurrentQuestionStartTime"] = value;
        }

        private List<DateTime> QuestionStartTimes
        {
            get => ViewState["QuestionStartTimes"] as List<DateTime> ?? new List<DateTime>();
            set => ViewState["QuestionStartTimes"] = value;
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
                InitializeTimingData();
                DisplayCurrentQuestion();
            }
        }

        private async Task InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private void InitializeTimingData()
        {
            QuizStartTime = DateTime.Now;
            CurrentQuestionStartTime = DateTime.Now;

            var startTimes = new List<DateTime>();
            for (int i = 0; i < TotalQuestions; i++)
            {
                startTimes.Add(DateTime.Now);
            }
            QuestionStartTimes = startTimes;
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

            // Update question start time
            var questionStartTimes = QuestionStartTimes;
            if (questionStartTimes.Count > CurrentQuestionIndex)
            {
                questionStartTimes[CurrentQuestionIndex] = DateTime.Now;
                QuestionStartTimes = questionStartTimes;
            }
            CurrentQuestionStartTime = DateTime.Now;

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

        private async void CalculateAndShowResults()
        {
            int correctAnswers = 0;
            int totalQuestions = CurrentQuiz.Questions.Count;
            var completedAt = DateTime.Now;
            var totalTimeSeconds = (int)(completedAt - QuizStartTime).TotalSeconds;

            // Create detailed attempt data
            var attemptData = new QuizAttemptData
            {
                QuizCode = CurrentQuiz.QuizCode,
                QuizTitle = CurrentQuiz.Title,
                QuizCreatedBy = CurrentQuiz.CreatedBy,
                UserId = Session.SessionID, // Using session ID as user identifier
                UserName = Session["UserName"]?.ToString() ?? "Anonymous",
                UserEmail = Session["UserEmail"]?.ToString() ?? "",
                UserIP = Request.UserHostAddress,
                UserAgent = Request.UserAgent,
                StartedAt = QuizStartTime,
                CompletedAt = completedAt,
                TotalTimeSeconds = totalTimeSeconds,
                TotalQuestions = totalQuestions
            };

            // Process each question
            for (int i = 0; i < totalQuestions; i++)
            {
                var question = CurrentQuiz.Questions[i];
                var userAnswer = UserAnswers[i];

                // Check if user's answer matches the correct answer exactly
                var correctIndexes = question.CorrectIndexes.OrderBy(x => x).ToList();
                var userIndexes = userAnswer.SelectedIndexes.OrderBy(x => x).ToList();
                bool isCorrect = correctIndexes.SequenceEqual(userIndexes);

                if (isCorrect)
                {
                    correctAnswers++;
                }

                // Calculate time spent on this question
                var questionStartTimes = QuestionStartTimes;
                var timeSpent = 0;
                if (questionStartTimes.Count > i)
                {
                    var nextTime = (i + 1 < questionStartTimes.Count) ? questionStartTimes[i + 1] : completedAt;
                    timeSpent = (int)(nextTime - questionStartTimes[i]).TotalSeconds;
                }

                // Create detailed question attempt data
                var questionAttempt = new QuestionAttemptData
                {
                    QuestionIndex = i,
                    QuestionText = question.Question,
                    Options = question.Options,
                    UserSelectedIndexes = userAnswer.SelectedIndexes,
                    CorrectIndexes = question.CorrectIndexes,
                    IsCorrect = isCorrect,
                    IsMultipleChoice = question.IsMultipleAnswer,
                    AnsweredAt = (questionStartTimes.Count > i) ? questionStartTimes[i] : DateTime.Now,
                    TimeSpentSeconds = Math.Max(timeSpent, 0)
                };

                attemptData.QuestionAttempts.Add(questionAttempt);
            }

            // Calculate final score and grade
            double percentage = totalQuestions > 0 ? Math.Round((double)correctAnswers * 100 / totalQuestions, 2) : 0;
            attemptData.CorrectAnswers = correctAnswers;
            attemptData.ScorePercentage = percentage;
            attemptData.Grade = CalculateGrade(percentage);

            // Add additional analytics data
            attemptData.AdditionalData.Add("AverageTimePerQuestion", totalTimeSeconds > 0 ? totalTimeSeconds / (double)totalQuestions : 0);
            attemptData.AdditionalData.Add("Browser", GetBrowserInfo());
            attemptData.AdditionalData.Add("Device", GetDeviceInfo());
            attemptData.AdditionalData.Add("Timestamp", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

            // Save attempt data to Firestore
            await SaveQuizAttempt(attemptData);

            // Update attempt count in quiz document
            await UpdateQuizStats(CurrentQuiz.QuizCode);

            // Show results on page
            lblScorePercentage.Text = ((int)percentage).ToString();
            lblCorrectAnswers.Text = correctAnswers.ToString();
            lblTotalQuestionsResult.Text = totalQuestions.ToString();

            // Hide quiz content and show results
            pnlQuizHeader.Visible = false;
            pnlQuizContent.Visible = false;
            pnlResults.Visible = true;
        }

        private async Task SaveQuizAttempt(QuizAttemptData attemptData)
        {
            try
            {
                // Convert to dictionary for Firestore
                var attemptDict = new Dictionary<string, object>
                {
                    ["attemptId"] = attemptData.AttemptId,
                    ["quizCode"] = attemptData.QuizCode,
                    ["quizTitle"] = attemptData.QuizTitle,
                    ["quizCreatedBy"] = attemptData.QuizCreatedBy,
                    ["userId"] = attemptData.UserId,
                    ["userName"] = attemptData.UserName,
                    ["userEmail"] = attemptData.UserEmail,
                    ["userIP"] = attemptData.UserIP,
                    ["userAgent"] = attemptData.UserAgent,
                    ["startedAt"] = Timestamp.FromDateTime(attemptData.StartedAt.ToUniversalTime()),
                    ["completedAt"] = Timestamp.FromDateTime(attemptData.CompletedAt.ToUniversalTime()),
                    ["totalTimeSeconds"] = attemptData.TotalTimeSeconds,
                    ["totalQuestions"] = attemptData.TotalQuestions,
                    ["correctAnswers"] = attemptData.CorrectAnswers,
                    ["scorePercentage"] = attemptData.ScorePercentage,
                    ["grade"] = attemptData.Grade,
                    ["questionAttempts"] = attemptData.QuestionAttempts.Select(qa => new Dictionary<string, object>
                    {
                        ["questionIndex"] = qa.QuestionIndex,
                        ["questionText"] = qa.QuestionText,
                        ["options"] = qa.Options,
                        ["userSelectedIndexes"] = qa.UserSelectedIndexes,
                        ["correctIndexes"] = qa.CorrectIndexes,
                        ["isCorrect"] = qa.IsCorrect,
                        ["isMultipleChoice"] = qa.IsMultipleChoice,
                        ["answeredAt"] = Timestamp.FromDateTime(qa.AnsweredAt.ToUniversalTime()),
                        ["timeSpentSeconds"] = qa.TimeSpentSeconds
                    }).ToList(),
                    ["additionalData"] = attemptData.AdditionalData
                };

                // Save to quiz_attempts collection
                await db.Collection("quiz_attempts").Document(attemptData.AttemptId).SetAsync(attemptDict);

                // Also save to a subcollection under the specific quiz for easier querying
                await db.Collection("quizzes")
                        .Document(attemptData.QuizCode)
                        .Collection("attempts")
                        .Document(attemptData.AttemptId)
                        .SetAsync(attemptDict);
            }
            catch (Exception ex)
            {
                // Log error but don't break the user experience
                System.Diagnostics.Debug.WriteLine($"Error saving quiz attempt: {ex.Message}");
            }
        }

        private async Task UpdateQuizStats(string quizCode)
        {
            try
            {
                DocumentReference quizRef = db.Collection("quizzes").Document(quizCode);

                await db.RunTransactionAsync(async transaction =>
                {
                    DocumentSnapshot snapshot = await transaction.GetSnapshotAsync(quizRef);

                    var updates = new Dictionary<string, object>();

                    if (snapshot.ContainsField("totalAttempts"))
                    {
                        int currentAttempts = snapshot.GetValue<int>("totalAttempts");
                        updates["totalAttempts"] = currentAttempts + 1;
                    }
                    else
                    {
                        updates["totalAttempts"] = 1;
                    }

                    updates["lastAttemptAt"] = Timestamp.FromDateTime(DateTime.UtcNow);

                    transaction.Update(quizRef, updates);
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating quiz stats: {ex.Message}");
            }
        }

        private string CalculateGrade(double percentage)
        {
            if (percentage >= 90) return "A";
            if (percentage >= 80) return "B";
            if (percentage >= 70) return "C";
            if (percentage >= 60) return "D";
            return "F";
        }

        private string GetBrowserInfo()
        {
            var userAgent = Request.UserAgent;
            if (userAgent.Contains("Chrome")) return "Chrome";
            if (userAgent.Contains("Firefox")) return "Firefox";
            if (userAgent.Contains("Safari")) return "Safari";
            if (userAgent.Contains("Edge")) return "Edge";
            return "Unknown";
        }

        private string GetDeviceInfo()
        {
            var userAgent = Request.UserAgent;
            if (userAgent.Contains("Mobile")) return "Mobile";
            if (userAgent.Contains("Tablet")) return "Tablet";
            return "Desktop";
        }

        protected void btnTryAgain_Click(object sender, EventArgs e)
        {
            // Reset quiz state
            CurrentQuestionIndex = 0;
            InitializeUserAnswers();
            InitializeTimingData();

            // Show quiz content and hide results
            pnlQuizHeader.Visible = true;
            pnlQuizContent.Visible = true;
            pnlResults.Visible = false;

            DisplayCurrentQuestion();
        }

        protected void btnBackToQuizzes_Click(object sender, EventArgs e)
        {
            Response.Redirect("Quiz.aspx");
        }

        // Method to retrieve quiz attempts for analysis (you can call this from another page)
        public static async Task<List<QuizAttemptData>> GetQuizAttempts(string quizCode, int limit = 100)
        {
            string path = System.Web.HttpContext.Current.Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            var db = FirestoreDb.Create("intorannetto");

            var attempts = new List<QuizAttemptData>();

            try
            {
                Query query = db.Collection("quizzes")
                               .Document(quizCode)
                               .Collection("attempts")
                               .OrderByDescending("completedAt")
                               .Limit(limit);

                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    // Convert Firestore document back to QuizAttemptData object
                    // Implementation depends on your specific needs
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error retrieving quiz attempts: {ex.Message}");
            }

            return attempts;
        }
    }
}