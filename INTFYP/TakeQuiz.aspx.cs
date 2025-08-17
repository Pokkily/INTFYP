using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;
using Newtonsoft.Json;

namespace INTFYP
{
    public partial class TakeQuiz : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        // Quiz properties
        private string currentLanguageId;
        private string currentTopicName;
        private string currentLessonId;
        private List<QuestionData> quizQuestions;
        private Dictionary<int, string> userAnswers;

        // Question data model
        public class QuestionData
        {
            public string Id { get; set; }
            public string Text { get; set; }
            public string Type { get; set; }
            public int Order { get; set; }
            public List<string> Options { get; set; }
            public List<string> ShuffledOptions { get; set; } // NEW: for randomized display
            public string CorrectAnswer { get; set; }
            public string ImagePath { get; set; }
            public string AudioPath { get; set; }
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            // Get parameters from URL
            currentLanguageId = Request.QueryString["languageId"];
            currentTopicName = Request.QueryString["topicName"];
            currentLessonId = Request.QueryString["lessonId"];

            if (string.IsNullOrEmpty(currentLanguageId) || string.IsNullOrEmpty(currentTopicName) || string.IsNullOrEmpty(currentLessonId))
            {
                Response.Redirect("Language.aspx");
                return;
            }

            if (!IsPostBack)
            {
                await InitializeQuiz();
            }
            else
            {
                // Restore quiz state from hidden fields
                RestoreQuizState();
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

        private async System.Threading.Tasks.Task InitializeQuiz()
        {
            try
            {
                // Load lesson and language info
                await LoadLessonInfo();

                // Load questions for this lesson
                await LoadQuizQuestions();

                if (quizQuestions == null || quizQuestions.Count == 0)
                {
                    ShowErrorMessage("No questions found for this lesson. Please check that questions are properly configured in the database.");
                    Response.Redirect($"DisplayQuestion.aspx?languageId={currentLanguageId}");
                    return;
                }

                // NEW: Randomize options for all questions
                RandomizeQuestionOptions();

                // Initialize user answers dictionary
                userAnswers = new Dictionary<int, string>();

                // Set initial question index
                hfCurrentQuestionIndex.Value = "0";
                hfUserAnswers.Value = JsonConvert.SerializeObject(userAnswers);
                hfQuestionData.Value = JsonConvert.SerializeObject(quizQuestions);

                // Display first question
                DisplayCurrentQuestion();

                // Update UI elements
                UpdateQuizProgress();
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error initializing quiz: " + ex.Message);
                System.Diagnostics.Debug.WriteLine($"InitializeQuiz Error: {ex.Message}");
                Response.Redirect($"DisplayQuestion.aspx?languageId={currentLanguageId}");
            }
        }

        // NEW METHOD: Randomize options for all questions
        private void RandomizeQuestionOptions()
        {
            Random random = new Random();

            foreach (var question in quizQuestions)
            {
                if (question.Options != null && question.Options.Count > 0)
                {
                    // Create a copy of the original options and shuffle them
                    question.ShuffledOptions = question.Options.ToList();

                    // Fisher-Yates shuffle algorithm
                    for (int i = question.ShuffledOptions.Count - 1; i > 0; i--)
                    {
                        int j = random.Next(i + 1);
                        string temp = question.ShuffledOptions[i];
                        question.ShuffledOptions[i] = question.ShuffledOptions[j];
                        question.ShuffledOptions[j] = temp;
                    }

                    System.Diagnostics.Debug.WriteLine($"🔀 Question '{question.Text}' options randomized:");
                    System.Diagnostics.Debug.WriteLine($"   Original: [{string.Join(", ", question.Options)}]");
                    System.Diagnostics.Debug.WriteLine($"   Shuffled: [{string.Join(", ", question.ShuffledOptions)}]");
                }
            }
        }

        private async System.Threading.Tasks.Task LoadLessonInfo()
        {
            try
            {
                // Get language info
                DocumentSnapshot languageDoc = await db.Collection("languages").Document(currentLanguageId).GetSnapshotAsync();
                if (languageDoc.Exists)
                {
                    var languageData = languageDoc.ToDictionary();
                    lblLanguageName.Text = languageData.ContainsKey("Name") ? languageData["Name"].ToString() : "Language";
                }

                // Get lesson info
                DocumentSnapshot lessonDoc = await db.Collection("languages")
                    .Document(currentLanguageId)
                    .Collection("topics")
                    .Document(currentTopicName)
                    .Collection("lessons")
                    .Document(currentLessonId)
                    .GetSnapshotAsync();

                if (lessonDoc.Exists)
                {
                    var lessonData = lessonDoc.ToDictionary();
                    string lessonName = lessonData.ContainsKey("name") ? lessonData["name"].ToString() : currentLessonId;

                    lblLessonName.Text = lessonName;
                    lblTopicName.Text = currentTopicName;
                    lblQuizTitle.Text = $"{lessonName} Quiz";
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to load lesson info: {ex.Message}");
            }
        }

        private async System.Threading.Tasks.Task LoadQuizQuestions()
        {
            try
            {
                CollectionReference questionsRef = db.Collection("languages")
                    .Document(currentLanguageId)
                    .Collection("topics")
                    .Document(currentTopicName)
                    .Collection("lessons")
                    .Document(currentLessonId)
                    .Collection("questions");

                QuerySnapshot questionsSnapshot = await questionsRef.OrderBy("order").GetSnapshotAsync();

                quizQuestions = new List<QuestionData>();

                if (questionsSnapshot.Documents.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("❌ No questions found in database!");
                    return;
                }

                System.Diagnostics.Debug.WriteLine($"🔍 Loading {questionsSnapshot.Documents.Count} questions from database...");

                foreach (DocumentSnapshot questionDoc in questionsSnapshot.Documents)
                {
                    var questionData = questionDoc.ToDictionary();

                    System.Diagnostics.Debug.WriteLine($"\n📋 Processing Question ID: {questionDoc.Id}");

                    // Log all fields in this question document
                    System.Diagnostics.Debug.WriteLine("📊 All fields in this question:");
                    foreach (var field in questionData)
                    {
                        System.Diagnostics.Debug.WriteLine($"   {field.Key}: {field.Value} (Type: {field.Value?.GetType().Name})");
                    }

                    // FIXED: Properly extract options from Firestore
                    var options = new List<string>();

                    if (questionData.ContainsKey("options"))
                    {
                        System.Diagnostics.Debug.WriteLine($"✅ Found 'options' field");

                        // Handle different types of options storage
                        var optionsField = questionData["options"];

                        if (optionsField is object[] optionsArray)
                        {
                            System.Diagnostics.Debug.WriteLine($"📝 Options stored as array with {optionsArray.Length} items:");

                            for (int i = 0; i < optionsArray.Length; i++)
                            {
                                string optionText = optionsArray[i]?.ToString()?.Trim() ?? "";
                                if (!string.IsNullOrEmpty(optionText))
                                {
                                    options.Add(optionText);
                                    System.Diagnostics.Debug.WriteLine($"   Option {i + 1}: '{optionText}'");
                                }
                            }
                        }
                        else if (optionsField is List<object> optionsList)
                        {
                            System.Diagnostics.Debug.WriteLine($"📝 Options stored as list with {optionsList.Count} items:");

                            for (int i = 0; i < optionsList.Count; i++)
                            {
                                string optionText = optionsList[i]?.ToString()?.Trim() ?? "";
                                if (!string.IsNullOrEmpty(optionText))
                                {
                                    options.Add(optionText);
                                    System.Diagnostics.Debug.WriteLine($"   Option {i + 1}: '{optionText}'");
                                }
                            }
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine($"❌ Options field exists but unexpected type: {optionsField.GetType().Name}");
                            System.Diagnostics.Debug.WriteLine($"   Value: {optionsField}");
                        }
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ No 'options' field found in question {questionDoc.Id}");
                    }

                    // If we still don't have options, there's a problem with the database
                    if (options.Count == 0)
                    {
                        System.Diagnostics.Debug.WriteLine($"⚠️ WARNING: Question {questionDoc.Id} has no valid options!");
                        System.Diagnostics.Debug.WriteLine($"   This question will be skipped or needs to be fixed in AddQuestion.");

                        // Skip this question rather than add default options
                        continue;
                    }

                    // Get correct answer
                    string correctAnswer = "";
                    if (questionData.ContainsKey("answer"))
                    {
                        correctAnswer = questionData["answer"]?.ToString()?.Trim() ?? "";
                        System.Diagnostics.Debug.WriteLine($"✅ Correct answer: '{correctAnswer}'");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ No answer field found for question {questionDoc.Id}");
                        if (options.Count > 0)
                        {
                            correctAnswer = options[0];
                            System.Diagnostics.Debug.WriteLine($"🔧 Using first option as correct answer: '{correctAnswer}'");
                        }
                    }

                    // Create question object
                    var question = new QuestionData
                    {
                        Id = questionDoc.Id,
                        Text = questionData.ContainsKey("text") ? questionData["text"]?.ToString() ?? "" : $"Question {questionDoc.Id}",
                        Type = questionData.ContainsKey("questionType") ? questionData["questionType"]?.ToString() ?? "text" : "text",
                        Order = questionData.ContainsKey("order") ? Convert.ToInt32(questionData["order"]) : quizQuestions.Count + 1,
                        Options = options, // Original order preserved
                        ShuffledOptions = new List<string>(), // Will be filled by RandomizeQuestionOptions
                        CorrectAnswer = correctAnswer,
                        ImagePath = questionData.ContainsKey("imagePath") ? questionData["imagePath"]?.ToString() ?? "" : "",
                        AudioPath = questionData.ContainsKey("audioPath") ? questionData["audioPath"]?.ToString() ?? "" : ""
                    };

                    quizQuestions.Add(question);
                    System.Diagnostics.Debug.WriteLine($"✅ Question '{question.Text}' added with {options.Count} options");
                    System.Diagnostics.Debug.WriteLine($"   Options: [{string.Join(", ", options)}]");
                    System.Diagnostics.Debug.WriteLine($"   Correct: '{correctAnswer}'");
                }

                if (quizQuestions.Count == 0)
                {
                    throw new Exception("No valid questions could be loaded from the database. Please check your questions in AddQuestion.");
                }

                lblTotalQuestions.Text = quizQuestions.Count.ToString();
                System.Diagnostics.Debug.WriteLine($"\n🎯 Successfully loaded {quizQuestions.Count} questions with actual choices!");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ LoadQuizQuestions Error: {ex.Message}");
                throw new Exception($"Failed to load quiz questions: {ex.Message}");
            }
        }

        private void RestoreQuizState()
        {
            try
            {
                // Restore questions from hidden field
                if (!string.IsNullOrEmpty(hfQuestionData.Value))
                {
                    quizQuestions = JsonConvert.DeserializeObject<List<QuestionData>>(hfQuestionData.Value);
                }

                // Restore user answers from hidden field
                if (!string.IsNullOrEmpty(hfUserAnswers.Value))
                {
                    userAnswers = JsonConvert.DeserializeObject<Dictionary<int, string>>(hfUserAnswers.Value);
                }
                else
                {
                    userAnswers = new Dictionary<int, string>();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error restoring quiz state: " + ex.Message);
                userAnswers = new Dictionary<int, string>();
            }
        }

        private void DisplayCurrentQuestion()
        {
            try
            {
                int currentIndex = GetCurrentQuestionIndex();

                if (quizQuestions == null || currentIndex < 0 || currentIndex >= quizQuestions.Count)
                {
                    ShowErrorMessage("Invalid question index or no questions available.");
                    return;
                }

                var currentQuestion = quizQuestions[currentIndex];

                System.Diagnostics.Debug.WriteLine($"\n📺 Displaying question {currentIndex + 1}:");
                System.Diagnostics.Debug.WriteLine($"   Text: {currentQuestion.Text}");
                System.Diagnostics.Debug.WriteLine($"   Shuffled Options: [{string.Join(", ", currentQuestion.ShuffledOptions ?? new List<string>())}]");
                System.Diagnostics.Debug.WriteLine($"   Correct: {currentQuestion.CorrectAnswer}");

                // Update question display
                lblQuestionNumber.Text = (currentIndex + 1).ToString();
                lblCurrentQuestion.Text = (currentIndex + 1).ToString();
                lblQuestionText.Text = currentQuestion.Text;
                lblQuestionType.Text = currentQuestion.Type.ToUpper();

                // Handle media content
                pnlQuestionMedia.Visible = false;
                imgQuestion.Visible = false;
                audioQuestion.Visible = false;

                if (currentQuestion.Type == "image" && !string.IsNullOrEmpty(currentQuestion.ImagePath))
                {
                    pnlQuestionMedia.Visible = true;
                    imgQuestion.Visible = true;
                    imgQuestion.ImageUrl = currentQuestion.ImagePath;
                }
                else if (currentQuestion.Type == "audio" && !string.IsNullOrEmpty(currentQuestion.AudioPath))
                {
                    pnlQuestionMedia.Visible = true;
                    audioQuestion.Visible = true;
                    audioSource.Src = currentQuestion.AudioPath;
                }

                // UPDATED: Bind SHUFFLED answer options instead of original order
                if (currentQuestion.ShuffledOptions != null && currentQuestion.ShuffledOptions.Count > 0)
                {
                    rptAnswerOptions.DataSource = currentQuestion.ShuffledOptions; // Use shuffled options
                    rptAnswerOptions.DataBind();

                    System.Diagnostics.Debug.WriteLine($"✅ Bound {currentQuestion.ShuffledOptions.Count} SHUFFLED options to UI:");
                    for (int i = 0; i < currentQuestion.ShuffledOptions.Count; i++)
                    {
                        System.Diagnostics.Debug.WriteLine($"   UI Option {i + 1}: '{currentQuestion.ShuffledOptions[i]}'");
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"❌ Question {currentIndex + 1} has no shuffled options!");
                    ShowErrorMessage($"Question {currentIndex + 1} has no answer options. Please check the question data in your database.");
                    return;
                }

                // Update navigation buttons
                UpdateNavigationButtons();

                // Clear selected answer
                hfSelectedAnswer.Value = "";

                // Update progress
                UpdateQuizProgress();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ DisplayCurrentQuestion Error: {ex.Message}");
                ShowErrorMessage("Error displaying question: " + ex.Message);
            }
        }

        private void UpdateNavigationButtons()
        {
            int currentIndex = GetCurrentQuestionIndex();
            bool isLastQuestion = currentIndex >= quizQuestions.Count - 1;

            // Previous button
            btnPrevious.Visible = currentIndex > 0;

            // Next/Submit buttons
            if (isLastQuestion)
            {
                btnNext.Visible = false;
                btnSubmit.Visible = true;
                btnSubmit.Enabled = false; // Will be enabled when answer is selected
            }
            else
            {
                btnNext.Visible = true;
                btnSubmit.Visible = false;
                btnNext.Enabled = false; // Will be enabled when answer is selected
            }
        }

        private void UpdateQuizProgress()
        {
            int currentIndex = GetCurrentQuestionIndex();
            lblCurrentQuestion.Text = (currentIndex + 1).ToString();

            // Progress will be updated via JavaScript
        }

        private int GetCurrentQuestionIndex()
        {
            int index = 0;
            if (!string.IsNullOrEmpty(hfCurrentQuestionIndex.Value))
            {
                int.TryParse(hfCurrentQuestionIndex.Value, out index);
            }
            return index;
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            try
            {
                // Save current answer
                SaveCurrentAnswer();

                // Move to next question
                int currentIndex = GetCurrentQuestionIndex();
                if (currentIndex < quizQuestions.Count - 1)
                {
                    hfCurrentQuestionIndex.Value = (currentIndex + 1).ToString();
                    DisplayCurrentQuestion();
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error moving to next question: " + ex.Message);
                System.Diagnostics.Debug.WriteLine($"❌ btnNext_Click Error: {ex.Message}");
            }
        }

        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            try
            {
                // Save current answer
                SaveCurrentAnswer();

                // Move to previous question
                int currentIndex = GetCurrentQuestionIndex();
                if (currentIndex > 0)
                {
                    hfCurrentQuestionIndex.Value = (currentIndex - 1).ToString();
                    DisplayCurrentQuestion();
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error moving to previous question: " + ex.Message);
                System.Diagnostics.Debug.WriteLine($"❌ btnPrevious_Click Error: {ex.Message}");
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("🎯 Submit button clicked - starting quiz submission");

                // Save final answer
                SaveCurrentAnswer();

                // Calculate score
                int score = CalculateScore();

                // Display results
                DisplayQuizResults(score);
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error submitting quiz: " + ex.Message);
                System.Diagnostics.Debug.WriteLine($"❌ btnSubmit_Click Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"❌ Stack Trace: {ex.StackTrace}");
            }
        }

        private void SaveCurrentAnswer()
        {
            try
            {
                int currentIndex = GetCurrentQuestionIndex();
                string selectedAnswer = hfSelectedAnswer.Value;

                if (!string.IsNullOrEmpty(selectedAnswer))
                {
                    userAnswers[currentIndex] = selectedAnswer;
                    hfUserAnswers.Value = JsonConvert.SerializeObject(userAnswers);
                    System.Diagnostics.Debug.WriteLine($"💾 Saved answer for question {currentIndex + 1}: '{selectedAnswer}'");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"⚠️ No answer selected for question {currentIndex + 1}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error saving answer: " + ex.Message);
            }
        }

        private int CalculateScore()
        {
            if (quizQuestions.Count == 0) return 0;

            int correctAnswers = 0;

            System.Diagnostics.Debug.WriteLine($"\n📊 Calculating Score:");
            for (int i = 0; i < quizQuestions.Count; i++)
            {
                if (userAnswers.ContainsKey(i))
                {
                    string userAnswer = userAnswers[i];
                    string correctAnswer = quizQuestions[i].CorrectAnswer;

                    bool isCorrect = string.Equals(userAnswer.Trim(), correctAnswer.Trim(), StringComparison.OrdinalIgnoreCase);

                    System.Diagnostics.Debug.WriteLine($"Q{i + 1}: User='{userAnswer}' | Correct='{correctAnswer}' | {(isCorrect ? "✅" : "❌")}");

                    if (isCorrect)
                    {
                        correctAnswers++;
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"Q{i + 1}: No answer provided ❌");
                }
            }

            int score = (int)Math.Round(((double)correctAnswers / quizQuestions.Count) * 100);
            System.Diagnostics.Debug.WriteLine($"🎯 Final Score: {correctAnswers}/{quizQuestions.Count} = {score}%");

            return score;
        }

        private void DisplayQuizResults(int score)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"🎊 Displaying quiz results - Score: {score}%");

                // Hide quiz content
                pnlQuizContent.Visible = false;

                // Show results
                pnlQuizComplete.Visible = true;
                lblScore.Text = score.ToString();

                // Set score message based on performance
                string message = GetScoreMessage(score);
                lblScoreMessage.Text = message;

                // Show next lesson button if score is good enough
                if (score >= 70) // 70% pass rate
                {
                    btnNextLesson.Visible = true;
                }

                System.Diagnostics.Debug.WriteLine($"✅ Quiz results displayed successfully!");

                // Save quiz result (optional - you can implement this)
                // await SaveQuizResult(score);
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error displaying results: " + ex.Message);
                System.Diagnostics.Debug.WriteLine($"❌ DisplayQuizResults Error: {ex.Message}");
            }
        }

        private string GetScoreMessage(int score)
        {
            if (score >= 90)
                return "Excellent! You've mastered this lesson! 🌟";
            else if (score >= 80)
                return "Great job! You did very well! 👏";
            else if (score >= 70)
                return "Good work! You passed the lesson! ✅";
            else if (score >= 60)
                return "Not bad! Consider reviewing the material. 📚";
            else
                return "Keep practicing! You'll get better with time. 💪";
        }

        protected void btnRetryQuiz_Click(object sender, EventArgs e)
        {
            // Reset quiz state and restart with new randomization
            Response.Redirect($"TakeQuiz.aspx?languageId={currentLanguageId}&topicName={Server.UrlEncode(currentTopicName)}&lessonId={Server.UrlEncode(currentLessonId)}");
        }

        protected void btnBackToLessons_Click(object sender, EventArgs e)
        {
            Response.Redirect($"DisplayQuestion.aspx?languageId={currentLanguageId}");
        }

        protected void btnNextLesson_Click(object sender, EventArgs e)
        {
            // This would require logic to find the next lesson
            // For now, redirect back to lessons page
            Response.Redirect($"DisplayQuestion.aspx?languageId={currentLanguageId}");
        }

        private void ShowErrorMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                $"alert('{HttpUtility.JavaScriptStringEncode(message)}');", true);
        }

        // Optional: Save quiz results to Firestore
        private async System.Threading.Tasks.Task SaveQuizResult(int score)
        {
            try
            {
                string userId = GetCurrentUserId(); // Implement this based on your auth system

                var quizResult = new
                {
                    UserId = userId,
                    LanguageId = currentLanguageId,
                    TopicName = currentTopicName,
                    LessonId = currentLessonId,
                    Score = score,
                    TotalQuestions = quizQuestions.Count,
                    CorrectAnswers = (int)Math.Round((score / 100.0) * quizQuestions.Count),
                    CompletedAt = Timestamp.GetCurrentTimestamp(),
                    UserAnswers = userAnswers,
                    TimeSpent = 0, // You can implement time tracking
                    OptionsWereShuffled = true // NEW: Track that options were randomized
                };

                await db.Collection("quizResults").AddAsync(quizResult);
                System.Diagnostics.Debug.WriteLine($"✅ Quiz result saved to Firestore");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error saving quiz result: " + ex.Message);
                // Don't throw - this is optional functionality
            }
        }

        private string GetCurrentUserId()
        {
            // Implement based on your authentication system
            if (Session["UserId"] != null)
                return Session["UserId"].ToString();

            // Generate a demo user ID if none exists
            string demoUserId = "DEMO_" + DateTime.Now.Ticks.ToString();
            Session["UserId"] = demoUserId;
            return demoUserId;
        }

        // Method to get user's quiz history
        public async System.Threading.Tasks.Task<List<object>> GetUserQuizHistory(string userId)
        {
            try
            {
                Query quizResultsQuery = db.Collection("quizResults")
                    .WhereEqualTo("UserId", userId)
                    .OrderByDescending("CompletedAt");

                QuerySnapshot snapshot = await quizResultsQuery.GetSnapshotAsync();

                var results = new List<object>();
                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    var data = doc.ToDictionary();
                    results.Add(new
                    {
                        Id = doc.Id,
                        LanguageId = data.ContainsKey("LanguageId") ? data["LanguageId"].ToString() : "",
                        TopicName = data.ContainsKey("TopicName") ? data["TopicName"].ToString() : "",
                        LessonId = data.ContainsKey("LessonId") ? data["LessonId"].ToString() : "",
                        Score = data.ContainsKey("Score") ? Convert.ToInt32(data["Score"]) : 0,
                        CompletedAt = data.ContainsKey("CompletedAt") ? data["CompletedAt"] : Timestamp.GetCurrentTimestamp(),
                        OptionsWereShuffled = data.ContainsKey("OptionsWereShuffled") ? Convert.ToBoolean(data["OptionsWereShuffled"]) : false
                    });
                }

                return results;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting quiz history: " + ex.Message);
                return new List<object>();
            }
        }

        // NEW: Method to get quiz statistics
        public async System.Threading.Tasks.Task<object> GetQuizStatistics(string languageId, string topicName, string lessonId)
        {
            try
            {
                Query statsQuery = db.Collection("quizResults")
                    .WhereEqualTo("LanguageId", languageId)
                    .WhereEqualTo("TopicName", topicName)
                    .WhereEqualTo("LessonId", lessonId);

                QuerySnapshot snapshot = await statsQuery.GetSnapshotAsync();

                var scores = new List<int>();
                var shuffledCount = 0;

                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    var data = doc.ToDictionary();
                    if (data.ContainsKey("Score"))
                    {
                        scores.Add(Convert.ToInt32(data["Score"]));
                    }
                    if (data.ContainsKey("OptionsWereShuffled") && Convert.ToBoolean(data["OptionsWereShuffled"]))
                    {
                        shuffledCount++;
                    }
                }

                return new
                {
                    TotalAttempts = scores.Count,
                    AverageScore = scores.Count > 0 ? scores.Average() : 0,
                    HighestScore = scores.Count > 0 ? scores.Max() : 0,
                    LowestScore = scores.Count > 0 ? scores.Min() : 0,
                    PassRate = scores.Count > 0 ? (scores.Count(s => s >= 70) * 100.0 / scores.Count) : 0,
                    ShuffledOptionsCount = shuffledCount
                };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting quiz statistics: " + ex.Message);
                return new
                {
                    TotalAttempts = 0,
                    AverageScore = 0,
                    HighestScore = 0,
                    LowestScore = 0,
                    PassRate = 0,
                    ShuffledOptionsCount = 0
                };
            }
        }
    }
}