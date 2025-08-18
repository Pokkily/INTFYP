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
        private DateTime quizStartTime;

        // Question data model
        public class QuestionData
        {
            public string Id { get; set; }
            public string Text { get; set; }
            public string Type { get; set; }
            public int Order { get; set; }
            public List<string> Options { get; set; }
            public List<string> ShuffledOptions { get; set; }
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
                // Record quiz start time
                quizStartTime = DateTime.Now;
                Session["QuizStartTime"] = quizStartTime;
                System.Diagnostics.Debug.WriteLine($"⏰ Quiz started at: {quizStartTime}");

                await InitializeQuiz();
            }
            else
            {
                // Restore quiz start time
                if (Session["QuizStartTime"] != null)
                {
                    quizStartTime = (DateTime)Session["QuizStartTime"];
                }
                else
                {
                    quizStartTime = DateTime.Now.AddMinutes(-5); // Fallback
                }

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
                        System.Diagnostics.Debug.WriteLine("🔥 Firebase initialized successfully");
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

                // Randomize options for all questions
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

        // Randomize options for all questions
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

                    // Extract options from Firestore
                    var options = new List<string>();

                    if (questionData.ContainsKey("options"))
                    {
                        var optionsField = questionData["options"];

                        if (optionsField is object[] optionsArray)
                        {
                            for (int i = 0; i < optionsArray.Length; i++)
                            {
                                string optionText = optionsArray[i]?.ToString()?.Trim() ?? "";
                                if (!string.IsNullOrEmpty(optionText))
                                {
                                    options.Add(optionText);
                                }
                            }
                        }
                        else if (optionsField is List<object> optionsList)
                        {
                            for (int i = 0; i < optionsList.Count; i++)
                            {
                                string optionText = optionsList[i]?.ToString()?.Trim() ?? "";
                                if (!string.IsNullOrEmpty(optionText))
                                {
                                    options.Add(optionText);
                                }
                            }
                        }
                    }

                    if (options.Count == 0)
                    {
                        System.Diagnostics.Debug.WriteLine($"⚠️ WARNING: Question {questionDoc.Id} has no valid options! Skipping...");
                        continue;
                    }

                    // Get correct answer
                    string correctAnswer = "";
                    if (questionData.ContainsKey("answer"))
                    {
                        correctAnswer = questionData["answer"]?.ToString()?.Trim() ?? "";
                    }
                    else if (options.Count > 0)
                    {
                        correctAnswer = options[0];
                    }

                    // Create question object
                    var question = new QuestionData
                    {
                        Id = questionDoc.Id,
                        Text = questionData.ContainsKey("text") ? questionData["text"]?.ToString() ?? "" : $"Question {questionDoc.Id}",
                        Type = questionData.ContainsKey("questionType") ? questionData["questionType"]?.ToString() ?? "text" : "text",
                        Order = questionData.ContainsKey("order") ? Convert.ToInt32(questionData["order"]) : quizQuestions.Count + 1,
                        Options = options,
                        ShuffledOptions = new List<string>(),
                        CorrectAnswer = correctAnswer,
                        ImagePath = questionData.ContainsKey("imagePath") ? questionData["imagePath"]?.ToString() ?? "" : "",
                        AudioPath = questionData.ContainsKey("audioPath") ? questionData["audioPath"]?.ToString() ?? "" : ""
                    };

                    quizQuestions.Add(question);
                    System.Diagnostics.Debug.WriteLine($"✅ Question '{question.Text}' added with {options.Count} options");
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

                // Bind SHUFFLED answer options
                if (currentQuestion.ShuffledOptions != null && currentQuestion.ShuffledOptions.Count > 0)
                {
                    rptAnswerOptions.DataSource = currentQuestion.ShuffledOptions;
                    rptAnswerOptions.DataBind();
                }
                else
                {
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

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("🎯 Submit button clicked - starting quiz submission");

                // Save final answer
                SaveCurrentAnswer();

                // Calculate score
                int score = CalculateScore();

                // Save to dual storage structure
                await SaveQuizResultToDualStorage(score);

                // Display results after save is complete
                DisplayQuizResults(score);
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error submitting quiz: " + ex.Message);
                System.Diagnostics.Debug.WriteLine($"❌ btnSubmit_Click Error: {ex.Message}");
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

        // Save to simplified dual storage structure
        private async System.Threading.Tasks.Task SaveQuizResultToDualStorage(int score)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("💾 Starting simplified dual storage save...");

                string userId = GetCurrentUserId();
                DateTime completedTime = DateTime.Now;
                DateTime startTime = quizStartTime;
                if (Session["QuizStartTime"] != null)
                {
                    startTime = (DateTime)Session["QuizStartTime"];
                }

                TimeSpan timeSpent = completedTime - startTime;
                int correctAnswers = (int)Math.Round((score / 100.0) * quizQuestions.Count);
                bool isPassed = score >= 70; // 70% passing grade

                // Get attempt number for this lesson
                int attemptNumber = await GetNextAttemptNumber(userId, currentLanguageId, currentTopicName, currentLessonId);

                // Generate unique result ID
                string resultId = $"{userId}_{currentLanguageId}_{currentTopicName}_{currentLessonId}_{attemptNumber}_{DateTime.Now.Ticks}";

                // 1. Save to nested user progress structure
                await SaveToUserProgressStructure(userId, resultId, score, correctAnswers, isPassed, startTime, completedTime, timeSpent, attemptNumber);

                // 2. Save to flat analytics collection (minimal data) - FIXED: Now uses languageResults
                await SaveToLanguageResultsCollection(resultId, userId, score, correctAnswers, isPassed, startTime, completedTime, timeSpent, attemptNumber);

                System.Diagnostics.Debug.WriteLine($"✅ SUCCESS: Quiz result saved to both collections!");
                ShowSuccessMessage($"🎉 Quiz completed with {score}% score! Your result has been saved successfully.");

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ SAVE ERROR: {ex.Message}");
                ShowErrorMessage($"Quiz completed with {score}% score! However, there was an error saving your result: {ex.Message}");
            }
        }

        // Save to nested user progress structure: users/{userId}/progress/{languageId}/topics/{topicName}/lessons/{lessonId}
        private async System.Threading.Tasks.Task SaveToUserProgressStructure(string userId, string resultId, int score,
            int correctAnswers, bool isPassed, DateTime startTime, DateTime completedTime, TimeSpan timeSpent, int attemptNumber)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("📁 Saving to user progress structure...");

                // Create user answers for detailed tracking
                var userAnswersDetailed = new Dictionary<string, object>();
                for (int i = 0; i < quizQuestions.Count; i++)
                {
                    string userAnswer = userAnswers.ContainsKey(i) ? userAnswers[i] : "";
                    string correctAnswer = quizQuestions[i].CorrectAnswer;
                    bool isCorrect = string.Equals(userAnswer.Trim(), correctAnswer.Trim(), StringComparison.OrdinalIgnoreCase);

                    userAnswersDetailed[i.ToString()] = new
                    {
                        selectedAnswer = userAnswer,
                        correctAnswer = correctAnswer,
                        isCorrect = isCorrect
                    };
                }

                // Save attempt data
                var attemptData = new
                {
                    attemptNumber = attemptNumber,
                    score = score,
                    totalQuestions = quizQuestions.Count,
                    correctAnswers = correctAnswers,
                    timeSpentSeconds = (int)timeSpent.TotalSeconds,
                    isPassed = isPassed,
                    completedAt = Timestamp.FromDateTime(completedTime.ToUniversalTime()),
                    userAnswers = userAnswersDetailed
                };

                DocumentReference attemptRef = db.Collection("users")
                    .Document(userId)
                    .Collection("progress")
                    .Document(currentLanguageId)
                    .Collection("topics")
                    .Document(currentTopicName)
                    .Collection("lessons")
                    .Document(currentLessonId)
                    .Collection("attempts")
                    .Document(resultId);

                await attemptRef.SetAsync(attemptData);

                // Update lesson summary
                await UpdateLessonSummary(userId, score, isPassed, attemptNumber, timeSpent);

                // Update topic summary
                await UpdateTopicSummary(userId);

                // Update language summary
                await UpdateLanguageSummary(userId);

                System.Diagnostics.Debug.WriteLine("✅ User progress structure updated successfully!");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ Error saving to user structure: {ex.Message}");
                throw;
            }
        }

        // FIXED: Save to flat analytics collection: languageResults/{resultId} (minimal data only, no userType)
        private async System.Threading.Tasks.Task SaveToLanguageResultsCollection(string resultId, string userId, int score,
            int correctAnswers, bool isPassed, DateTime startTime, DateTime completedTime, TimeSpan timeSpent, int attemptNumber)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("📊 Saving to language results collection...");

                var languageResultData = new
                {
                    userId = userId,
                    languageId = currentLanguageId,
                    languageName = lblLanguageName.Text,
                    topicName = currentTopicName,
                    lessonId = currentLessonId,
                    lessonName = lblLessonName.Text,
                    attemptNumber = attemptNumber,
                    score = score,
                    totalQuestions = quizQuestions.Count,
                    correctAnswers = correctAnswers,
                    timeSpentSeconds = (int)timeSpent.TotalSeconds,
                    isPassed = isPassed,
                    completedAt = Timestamp.FromDateTime(completedTime.ToUniversalTime()),
                    createdAt = Timestamp.GetCurrentTimestamp()
                };

                DocumentReference resultRef = db.Collection("languageResults").Document(resultId);
                await resultRef.SetAsync(languageResultData);

                System.Diagnostics.Debug.WriteLine("✅ Language results collection updated successfully!");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ Error saving to results collection: {ex.Message}");
                throw;
            }
        }

        // Helper method to get next attempt number
        private async System.Threading.Tasks.Task<int> GetNextAttemptNumber(string userId, string languageId, string topicName, string lessonId)
        {
            try
            {
                CollectionReference attemptsRef = db.Collection("users")
                    .Document(userId)
                    .Collection("progress")
                    .Document(languageId)
                    .Collection("topics")
                    .Document(topicName)
                    .Collection("lessons")
                    .Document(lessonId)
                    .Collection("attempts");

                QuerySnapshot snapshot = await attemptsRef.GetSnapshotAsync();
                return snapshot.Documents.Count + 1;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting attempt number: {ex.Message}");
                return 1;
            }
        }

        // Update lesson summary with aggregated data
        private async System.Threading.Tasks.Task UpdateLessonSummary(string userId, int score, bool isPassed, int attemptNumber, TimeSpan timeSpent)
        {
            try
            {
                DocumentReference lessonRef = db.Collection("users")
                    .Document(userId)
                    .Collection("progress")
                    .Document(currentLanguageId)
                    .Collection("topics")
                    .Document(currentTopicName)
                    .Collection("lessons")
                    .Document(currentLessonId);

                // Get existing data
                DocumentSnapshot lessonSnap = await lessonRef.GetSnapshotAsync();

                int totalAttempts = attemptNumber;
                int bestScore = score;
                int latestScore = score;
                double averageScore = score;
                double totalTimeSpent = timeSpent.TotalMinutes;
                bool isCompleted = isPassed;
                string status = isPassed ? "COMPLETED" : "IN_PROGRESS";

                if (lessonSnap.Exists)
                {
                    var existingData = lessonSnap.ToDictionary();

                    if (existingData.ContainsKey("bestScore"))
                    {
                        int existingBestScore = Convert.ToInt32(existingData["bestScore"]);
                        bestScore = Math.Max(score, existingBestScore);
                    }

                    if (existingData.ContainsKey("totalTimeSpent"))
                    {
                        double existingTime = Convert.ToDouble(existingData["totalTimeSpent"]);
                        totalTimeSpent += existingTime;
                    }

                    if (existingData.ContainsKey("averageScore") && existingData.ContainsKey("totalAttempts"))
                    {
                        double existingAverage = Convert.ToDouble(existingData["averageScore"]);
                        int existingAttempts = Convert.ToInt32(existingData["totalAttempts"]);
                        averageScore = ((existingAverage * existingAttempts) + score) / totalAttempts;
                    }
                }

                var lessonSummary = new
                {
                    lessonName = lblLessonName.Text,
                    totalAttempts = totalAttempts,
                    bestScore = bestScore,
                    latestScore = latestScore,
                    averageScore = Math.Round(averageScore, 1),
                    isCompleted = isCompleted,
                    isPassed = isPassed,
                    status = status,
                    totalTimeSpent = Math.Round(totalTimeSpent, 2),
                    lastAttemptDate = Timestamp.GetCurrentTimestamp()
                };

                await lessonRef.SetAsync(lessonSummary, SetOptions.MergeAll);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating lesson summary: {ex.Message}");
            }
        }

        // Update topic summary
        private async System.Threading.Tasks.Task UpdateTopicSummary(string userId)
        {
            try
            {
                DocumentReference topicRef = db.Collection("users")
                    .Document(userId)
                    .Collection("progress")
                    .Document(currentLanguageId)
                    .Collection("topics")
                    .Document(currentTopicName);

                // Get all lessons in this topic
                CollectionReference lessonsRef = topicRef.Collection("lessons");
                QuerySnapshot lessonsSnapshot = await lessonsRef.GetSnapshotAsync();

                int lessonsInTopic = lessonsSnapshot.Documents.Count;
                int completedLessons = 0;
                double totalTopicScore = 0;
                double totalTopicTime = 0;

                foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                {
                    if (lessonDoc.Exists)
                    {
                        var lessonData = lessonDoc.ToDictionary();

                        if (lessonData.ContainsKey("isCompleted") && Convert.ToBoolean(lessonData["isCompleted"]))
                        {
                            completedLessons++;
                        }

                        if (lessonData.ContainsKey("bestScore"))
                        {
                            totalTopicScore += Convert.ToDouble(lessonData["bestScore"]);
                        }

                        if (lessonData.ContainsKey("totalTimeSpent"))
                        {
                            totalTopicTime += Convert.ToDouble(lessonData["totalTimeSpent"]);
                        }
                    }
                }

                var topicSummary = new
                {
                    topicName = currentTopicName,
                    lessonsInTopic = lessonsInTopic,
                    completedLessons = completedLessons,
                    topicProgress = lessonsInTopic > 0 ? Math.Round((double)completedLessons / lessonsInTopic * 100, 1) : 0,
                    averageTopicScore = lessonsInTopic > 0 ? Math.Round(totalTopicScore / lessonsInTopic, 1) : 0,
                    totalTopicTime = Math.Round(totalTopicTime, 2)
                };

                await topicRef.SetAsync(topicSummary, SetOptions.MergeAll);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating topic summary: {ex.Message}");
            }
        }

        // Update language summary
        private async System.Threading.Tasks.Task UpdateLanguageSummary(string userId)
        {
            try
            {
                DocumentReference languageRef = db.Collection("users")
                    .Document(userId)
                    .Collection("progress")
                    .Document(currentLanguageId);

                // Get all topics in this language
                CollectionReference topicsRef = languageRef.Collection("topics");
                QuerySnapshot topicsSnapshot = await topicsRef.GetSnapshotAsync();

                int totalLessonsCompleted = 0;
                double totalTimeSpent = 0;
                double totalScores = 0;
                int totalAttempts = 0;

                foreach (DocumentSnapshot topicDoc in topicsSnapshot.Documents)
                {
                    if (topicDoc.Exists)
                    {
                        var topicData = topicDoc.ToDictionary();

                        if (topicData.ContainsKey("completedLessons"))
                        {
                            totalLessonsCompleted += Convert.ToInt32(topicData["completedLessons"]);
                        }

                        if (topicData.ContainsKey("totalTopicTime"))
                        {
                            totalTimeSpent += Convert.ToDouble(topicData["totalTopicTime"]);
                        }

                        // Get lessons for more detailed stats
                        CollectionReference lessonsRef = topicDoc.Reference.Collection("lessons");
                        QuerySnapshot lessonsSnapshot = await lessonsRef.GetSnapshotAsync();

                        foreach (DocumentSnapshot lessonDoc in lessonsSnapshot.Documents)
                        {
                            if (lessonDoc.Exists)
                            {
                                var lessonData = lessonDoc.ToDictionary();

                                if (lessonData.ContainsKey("totalAttempts"))
                                {
                                    totalAttempts += Convert.ToInt32(lessonData["totalAttempts"]);
                                }

                                if (lessonData.ContainsKey("bestScore"))
                                {
                                    totalScores += Convert.ToDouble(lessonData["bestScore"]);
                                }
                            }
                        }
                    }
                }

                // Calculate current streak (simplified) - FIXED: Now uses languageResults
                int currentStreak = await CalculateUserStreak(userId, currentLanguageId);

                var languageSummary = new
                {
                    languageName = lblLanguageName.Text,
                    totalAttempts = totalAttempts,
                    completedLessons = totalLessonsCompleted,
                    averageScore = totalLessonsCompleted > 0 ? Math.Round(totalScores / totalLessonsCompleted, 1) : 0,
                    totalTimeSpent = Math.Round(totalTimeSpent, 2),
                    currentStreak = currentStreak,
                    lastAttemptDate = Timestamp.GetCurrentTimestamp()
                };

                await languageRef.SetAsync(languageSummary, SetOptions.MergeAll);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating language summary: {ex.Message}");
            }
        }

        // FIXED: Simple streak calculation - now uses languageResults collection
        private async System.Threading.Tasks.Task<int> CalculateUserStreak(string userId, string languageId)
        {
            try
            {
                Query recentQuery = db.Collection("languageResults")
                    .WhereEqualTo("userId", userId)
                    .WhereEqualTo("languageId", languageId)
                    .OrderByDescending("completedAt")
                    .Limit(7);

                QuerySnapshot snapshot = await recentQuery.GetSnapshotAsync();

                if (snapshot.Documents.Count == 0) return 1;

                var attempts = snapshot.Documents
                    .Select(doc => ((Timestamp)doc.ToDictionary()["completedAt"]).ToDateTime().Date)
                    .Distinct()
                    .OrderByDescending(date => date)
                    .ToList();

                int streak = 0;
                DateTime currentDate = DateTime.Today;

                foreach (var attemptDate in attempts)
                {
                    if (attemptDate == currentDate || attemptDate == currentDate.AddDays(-streak - 1))
                    {
                        streak++;
                        currentDate = attemptDate;
                    }
                    else
                    {
                        break;
                    }
                }

                return Math.Max(streak, 1);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error calculating user streak: {ex.Message}");
                return 1;
            }
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
            Response.Redirect($"DisplayQuestion.aspx?languageId={currentLanguageId}");
        }

        // FIXED: Removed userType session tracking
        private string GetCurrentUserId()
        {
            if (Session["UserId"] != null)
                return Session["UserId"].ToString();

            if (Session["DemoUserId"] != null)
                return Session["DemoUserId"].ToString();

            string demoUserId = "DEMO_" + DateTime.Now.Ticks.ToString();
            Session["DemoUserId"] = demoUserId;

            System.Diagnostics.Debug.WriteLine($"🆔 Generated new demo user ID: {demoUserId}");
            return demoUserId;
        }

        private void ShowErrorMessage(string message)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"🚨 ERROR MESSAGE: {message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    $"alert('❌ {HttpUtility.JavaScriptStringEncode(message)}');", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ Failed to show error message: {ex.Message}");
            }
        }

        private void ShowSuccessMessage(string message)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"✅ SUCCESS MESSAGE: {message}");
                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    $"alert('✅ {HttpUtility.JavaScriptStringEncode(message)}');", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ Failed to show success message: {ex.Message}");
            }
        }
    }
}