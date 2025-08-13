using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Threading.Tasks;
using Google.Cloud.Firestore;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using System.IO;
using System.Linq;
using System.Configuration;

namespace KoreanApp
{
    public partial class AddQuestion : System.Web.UI.Page
    {
        FirestoreDb db;
        Cloudinary cloudinary;
        static readonly object dbLock = new object();
        private string selectedLessonId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeServices();
            if (!IsPostBack)
            {
                LoadLanguages();
                SetupInitialState();
            }
        }

        private void InitializeServices()
        {
            // Initialize Firestore
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

            // Initialize Cloudinary
            Account account = new Account(
                ConfigurationManager.AppSettings["CloudinaryCloudName"],
                ConfigurationManager.AppSettings["CloudinaryApiKey"],
                ConfigurationManager.AppSettings["CloudinaryApiSecret"]
            );
            cloudinary = new Cloudinary(account);
        }

        private async void LoadLanguages()
        {
            try
            {
                CollectionReference languagesRef = db.Collection("languages");
                QuerySnapshot snapshot = await languagesRef.GetSnapshotAsync();

                ddlLanguage.Items.Clear();
                ddlLanguage.Items.Add(new ListItem("Select Language", ""));

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    string documentId = document.Id;
                    string languageName = documentId; // Default fallback

                    // Get the language name from the "Name" field
                    if (document.ContainsField("Name"))
                    {
                        languageName = document.GetValue<string>("Name");
                    }

                    ddlLanguage.Items.Add(new ListItem(languageName, documentId));
                }
            }
            catch (Exception ex)
            {
                ShowMessage($"Error loading languages: {ex.Message}", "alert alert-danger");
            }
        }

        private void SetupInitialState()
        {
            panelTopics.Visible = false;
            panelLessons.Visible = false;
            panelQuestionForm.Visible = false;

            // Set default question type
            rbTextQuestion.Checked = true;
            ToggleQuestionInputs();

            // Reset question form state
            hfEditingQuestionId.Value = "";
            lblFormTitle.Text = "Add New Question";
            btnSaveQuestion.Text = "Save Question";
            btnCancelEdit.Visible = false;

            // Reset lesson form state
            hfEditingLessonId.Value = "";
            lblLessonFormTitle.Text = "Create New Lesson";
            btnSaveLesson.Text = "Create Lesson";
            btnCancelLessonEdit.Visible = false;
            ClearLessonForm();
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = cssClass;
            lblMessage.Visible = true;
        }

        protected async void ddlLanguage_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlLanguage.SelectedValue))
            {
                await LoadTopics(ddlLanguage.SelectedValue);
                panelTopics.Visible = true;
                panelLessons.Visible = false;
                panelQuestionForm.Visible = false;
            }
            else
            {
                panelTopics.Visible = false;
                panelLessons.Visible = false;
                panelQuestionForm.Visible = false;
            }
        }

        private async Task LoadTopics(string language)
        {
            try
            {
                DocumentReference languageRef = db.Collection("languages").Document(language);
                CollectionReference topicsRef = languageRef.Collection("topics");
                QuerySnapshot snapshot = await topicsRef.GetSnapshotAsync();

                ddlTopic.Items.Clear();
                ddlTopic.Items.Add(new ListItem("Select Topic", ""));
                ddlTopic.Items.Add(new ListItem("+ Create New Topic", "NEW_TOPIC"));

                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    string topicName = document.Id;
                    ddlTopic.Items.Add(new ListItem(topicName, topicName));
                }
            }
            catch (Exception ex)
            {
                ShowMessage($"Error loading topics: {ex.Message}", "alert alert-danger");
            }
        }

        protected async void ddlTopic_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlTopic.SelectedValue == "NEW_TOPIC")
            {
                panelNewTopic.Visible = true;
                panelLessons.Visible = false;
                panelQuestionForm.Visible = false;
            }
            else if (!string.IsNullOrEmpty(ddlTopic.SelectedValue))
            {
                panelNewTopic.Visible = false;
                await LoadLessons(ddlLanguage.SelectedValue, ddlTopic.SelectedValue);
                panelLessons.Visible = true;
                panelQuestionForm.Visible = false;
            }
            else
            {
                panelNewTopic.Visible = false;
                panelLessons.Visible = false;
                panelQuestionForm.Visible = false;
            }
        }

        protected async void btnCreateTopic_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtNewTopicName.Text))
            {
                ShowMessage("Please enter a topic name.", "alert alert-warning");
                return;
            }

            try
            {
                string topicName = txtNewTopicName.Text.Trim();
                DocumentReference topicRef = db.Collection("languages")
                    .Document(ddlLanguage.SelectedValue)
                    .Collection("topics")
                    .Document(topicName);

                Dictionary<string, object> topicData = new Dictionary<string, object>
                {
                    { "name", topicName },
                    { "createdAt", Timestamp.GetCurrentTimestamp() },
                    { "createdBy", Session["teacherId"]?.ToString() ?? "unknown" }
                };

                await topicRef.SetAsync(topicData);

                // Refresh topics dropdown
                await LoadTopics(ddlLanguage.SelectedValue);

                // Select the newly created topic
                ddlTopic.SelectedValue = topicName;
                await LoadLessons(ddlLanguage.SelectedValue, topicName);

                panelNewTopic.Visible = false;
                panelLessons.Visible = true;
                txtNewTopicName.Text = "";

                ShowMessage("Topic created successfully!", "alert alert-success");
            }
            catch (Exception ex)
            {
                ShowMessage($"Error creating topic: {ex.Message}", "alert alert-danger");
            }
        }

        // LESSON MANAGEMENT METHODS

        private async Task LoadLessons(string language, string topic)
        {
            try
            {
                DocumentReference topicRef = db.Collection("languages")
                    .Document(language)
                    .Collection("topics")
                    .Document(topic);

                CollectionReference lessonsRef = topicRef.Collection("lessons");
                QuerySnapshot snapshot = await lessonsRef.OrderBy("createdAt").GetSnapshotAsync();

                // Convert documents to a list for the repeater
                var lessonsList = new List<object>();
                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    var createdAt = doc.ContainsField("createdAt") ? doc.GetValue<Timestamp>("createdAt").ToDateTime().ToString("MMM dd, yyyy") : "Unknown";

                    lessonsList.Add(new
                    {
                        Id = doc.Id,
                        Name = doc.ContainsField("name") ? doc.GetValue<string>("name") : doc.Id,
                        Description = doc.ContainsField("description") ? doc.GetValue<string>("description") : "",
                        CreatedAt = createdAt
                    });
                }

                rptExistingLessons.DataSource = lessonsList;
                rptExistingLessons.DataBind();

                lblLessonCount.Text = $"Current Lessons: {snapshot.Count}";

                // Clear any previous lesson selection
                ClearLessonForm();
            }
            catch (Exception ex)
            {
                ShowMessage($"Error loading lessons: {ex.Message}", "alert alert-danger");
            }
        }

        protected async void btnSaveLesson_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtLessonName.Text))
            {
                ShowMessage("Please enter a lesson name.", "alert alert-warning");
                return;
            }

            try
            {
                string lessonName = txtLessonName.Text.Trim();
                string lessonDescription = txtLessonDescription.Text.Trim();

                var lessonData = new Dictionary<string, object>
                {
                    { "name", lessonName },
                    { "createdBy", Session["teacherId"]?.ToString() ?? "unknown" }
                };

                if (!string.IsNullOrWhiteSpace(lessonDescription))
                {
                    lessonData["description"] = lessonDescription;
                }

                CollectionReference lessonsRef = db.Collection("languages")
                    .Document(ddlLanguage.SelectedValue)
                    .Collection("topics")
                    .Document(ddlTopic.SelectedValue)
                    .Collection("lessons");

                if (string.IsNullOrEmpty(hfEditingLessonId.Value))
                {
                    // Creating new lesson
                    lessonData["createdAt"] = Timestamp.GetCurrentTimestamp();

                    DocumentReference lessonRef = lessonsRef.Document(lessonName);
                    await lessonRef.SetAsync(lessonData);

                    ShowMessage("Lesson created successfully!", "alert alert-success");
                }
                else
                {
                    // Updating existing lesson
                    lessonData["updatedAt"] = Timestamp.GetCurrentTimestamp();

                    DocumentReference lessonRef = lessonsRef.Document(hfEditingLessonId.Value);
                    await lessonRef.UpdateAsync(lessonData);

                    CancelLessonEdit();
                    ShowMessage("Lesson updated successfully!", "alert alert-success");
                }

                // Clear form and reload lessons
                ClearLessonForm();
                await LoadLessons(ddlLanguage.SelectedValue, ddlTopic.SelectedValue);
            }
            catch (Exception ex)
            {
                ShowMessage($"Error saving lesson: {ex.Message}", "alert alert-danger");
            }
        }

        protected async void btnSelectLesson_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string lessonId = btn.CommandArgument;

            try
            {
                // Set the selected lesson
                selectedLessonId = lessonId;

                // Show the question form
                panelQuestionForm.Visible = true;
                await LoadExistingQuestions();

                ShowMessage($"Lesson '{lessonId}' selected. You can now add questions.", "alert alert-success");
            }
            catch (Exception ex)
            {
                ShowMessage($"Error selecting lesson: {ex.Message}", "alert alert-danger");
            }
        }

        protected async void btnEditLesson_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string lessonId = btn.CommandArgument;

            try
            {
                await LoadLessonForEdit(lessonId);
            }
            catch (Exception ex)
            {
                ShowMessage($"Error loading lesson for edit: {ex.Message}", "alert alert-danger");
            }
        }

        private async Task LoadLessonForEdit(string lessonId)
        {
            try
            {
                DocumentReference lessonRef = db.Collection("languages")
                    .Document(ddlLanguage.SelectedValue)
                    .Collection("topics")
                    .Document(ddlTopic.SelectedValue)
                    .Collection("lessons")
                    .Document(lessonId);

                DocumentSnapshot lessonDoc = await lessonRef.GetSnapshotAsync();

                if (lessonDoc.Exists)
                {
                    // Set editing mode
                    hfEditingLessonId.Value = lessonId;
                    lblLessonFormTitle.Text = "Edit Lesson";
                    btnSaveLesson.Text = "Update Lesson";
                    btnCancelLessonEdit.Visible = true;

                    // Load lesson data into form
                    txtLessonName.Text = lessonDoc.ContainsField("name") ? lessonDoc.GetValue<string>("name") : lessonId;
                    txtLessonDescription.Text = lessonDoc.ContainsField("description") ? lessonDoc.GetValue<string>("description") : "";

                    ShowMessage("Lesson loaded for editing. Make your changes and click 'Update Lesson'.", "alert alert-info");
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to load lesson: {ex.Message}");
            }
        }

        protected void btnCancelLessonEdit_Click(object sender, EventArgs e)
        {
            CancelLessonEdit();
        }

        private void CancelLessonEdit()
        {
            hfEditingLessonId.Value = "";
            lblLessonFormTitle.Text = "Create New Lesson";
            btnSaveLesson.Text = "Create Lesson";
            btnCancelLessonEdit.Visible = false;
            ClearLessonForm();
            ShowMessage("Lesson edit cancelled.", "alert alert-info");
        }

        private void ClearLessonForm()
        {
            txtLessonName.Text = "";
            txtLessonDescription.Text = "";
        }

        protected async void btnDeleteLesson_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string lessonId = btn.CommandArgument;

            try
            {
                DocumentReference lessonRef = db.Collection("languages")
                    .Document(ddlLanguage.SelectedValue)
                    .Collection("topics")
                    .Document(ddlTopic.SelectedValue)
                    .Collection("lessons")
                    .Document(lessonId);

                // First, delete all questions in this lesson
                CollectionReference questionsRef = lessonRef.Collection("questions");
                QuerySnapshot questionsSnapshot = await questionsRef.GetSnapshotAsync();

                // Delete all questions
                foreach (DocumentSnapshot questionDoc in questionsSnapshot.Documents)
                {
                    await questionDoc.Reference.DeleteAsync();
                }

                // Then delete the lesson itself
                await lessonRef.DeleteAsync();

                // Reload lessons
                await LoadLessons(ddlLanguage.SelectedValue, ddlTopic.SelectedValue);

                // Cancel edit if we're editing the deleted lesson
                if (hfEditingLessonId.Value == lessonId)
                {
                    CancelLessonEdit();
                }

                // Hide question form if this lesson was selected
                if (selectedLessonId == lessonId)
                {
                    panelQuestionForm.Visible = false;
                    selectedLessonId = "";
                }

                ShowMessage("Lesson and all its questions deleted successfully!", "alert alert-success");
            }
            catch (Exception ex)
            {
                ShowMessage($"Error deleting lesson: {ex.Message}", "alert alert-danger");
            }
        }

        // QUESTION MANAGEMENT METHODS

        private async Task LoadExistingQuestions()
        {
            try
            {
                DocumentReference lessonRef = db.Collection("languages")
                    .Document(ddlLanguage.SelectedValue)
                    .Collection("topics")
                    .Document(ddlTopic.SelectedValue)
                    .Collection("lessons")
                    .Document(selectedLessonId);

                CollectionReference questionsRef = lessonRef.Collection("questions");
                QuerySnapshot snapshot = await questionsRef.OrderBy("order").GetSnapshotAsync();

                // Convert documents to a list manually to avoid LINQ compatibility issues
                var questionsList = new List<object>();
                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    questionsList.Add(new
                    {
                        Id = doc.Id,
                        Text = doc.ContainsField("text") ? doc.GetValue<string>("text") : "",
                        Type = doc.ContainsField("questionType") ? doc.GetValue<string>("questionType") : "",
                        Order = doc.ContainsField("order") ? doc.GetValue<int>("order") : 0
                    });
                }

                rptExistingQuestions.DataSource = questionsList;
                rptExistingQuestions.DataBind();

                lblQuestionCount.Text = $"Current Questions: {snapshot.Count}";
            }
            catch (Exception ex)
            {
                ShowMessage($"Error loading questions: {ex.Message}", "alert alert-danger");
            }
        }

        protected void QuestionType_CheckedChanged(object sender, EventArgs e)
        {
            ToggleQuestionInputs();
        }

        private void ToggleQuestionInputs()
        {
            // Reset all panels
            panelImageQuestion.Visible = false;
            panelAudioQuestion.Visible = false;
            panelTextOptions.Visible = false;

            if (rbTextQuestion.Checked)
            {
                panelTextOptions.Visible = true;
            }
            else if (rbImageQuestion.Checked)
            {
                panelImageQuestion.Visible = true;
                panelTextOptions.Visible = true;
            }
            else if (rbAudioQuestion.Checked)
            {
                panelAudioQuestion.Visible = true;
                panelTextOptions.Visible = true;
            }
        }

        private void CancelEdit()
        {
            hfEditingQuestionId.Value = "";
            lblFormTitle.Text = "Add New Question";
            btnSaveQuestion.Text = "Save Question";
            btnCancelEdit.Visible = false;
            ClearQuestionForm();
            ShowMessage("Edit cancelled.", "alert alert-info");
        }

        protected async void btnSaveQuestion_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate inputs
                if (string.IsNullOrWhiteSpace(txtQuestionText.Text))
                {
                    ShowMessage("Please enter question text.", "alert alert-warning");
                    return;
                }

                var questionData = new Dictionary<string, object>
                {
                    { "text", txtQuestionText.Text.Trim() },
                    { "createdBy", Session["teacherId"]?.ToString() ?? "unknown" }
                };

                // Determine question type and handle accordingly
                if (rbTextQuestion.Checked)
                {
                    questionData["questionType"] = "text";
                    questionData["options"] = new[] { txtOption1.Text.Trim(), txtOption2.Text.Trim(), txtOption3.Text.Trim() };
                    questionData["answer"] = txtCorrectAnswer.Text.Trim();
                }
                else if (rbImageQuestion.Checked)
                {
                    questionData["questionType"] = "image";
                    questionData["options"] = new[] { txtOption1.Text.Trim(), txtOption2.Text.Trim(), txtOption3.Text.Trim() };
                    questionData["answer"] = txtCorrectAnswer.Text.Trim();

                    if (fuQuestionImage.HasFile)
                    {
                        string imageUrl = await UploadToCloudinary(fuQuestionImage, "image");
                        questionData["imagePath"] = imageUrl;
                    }
                }
                else if (rbAudioQuestion.Checked)
                {
                    questionData["questionType"] = "audio";
                    questionData["options"] = new[] { txtOption1.Text.Trim(), txtOption2.Text.Trim(), txtOption3.Text.Trim() };
                    questionData["answer"] = txtCorrectAnswer.Text.Trim();

                    if (fuQuestionAudio.HasFile)
                    {
                        string audioUrl = await UploadToCloudinary(fuQuestionAudio, "video");
                        questionData["audioPath"] = audioUrl;
                    }
                }

                CollectionReference questionsRef = db.Collection("languages")
                    .Document(ddlLanguage.SelectedValue)
                    .Collection("topics")
                    .Document(ddlTopic.SelectedValue)
                    .Collection("lessons")
                    .Document(selectedLessonId)
                    .Collection("questions");

                if (string.IsNullOrEmpty(hfEditingQuestionId.Value))
                {
                    // Adding new question
                    questionData["createdAt"] = Timestamp.GetCurrentTimestamp();

                    // Get next question order
                    QuerySnapshot existingQuestions = await questionsRef.GetSnapshotAsync();
                    questionData["order"] = existingQuestions.Count + 1;

                    // Save to Firestore
                    await questionsRef.AddAsync(questionData);

                    ShowMessage("Question saved successfully!", "alert alert-success");
                }
                else
                {
                    // Updating existing question
                    questionData["updatedAt"] = Timestamp.GetCurrentTimestamp();

                    DocumentReference questionRef = questionsRef.Document(hfEditingQuestionId.Value);
                    await questionRef.UpdateAsync(questionData);

                    CancelEdit();
                    ShowMessage("Question updated successfully!", "alert alert-success");
                }

                // Clear form and reload questions
                ClearQuestionForm();
                await LoadExistingQuestions();
            }
            catch (Exception ex)
            {
                ShowMessage($"Error saving question: {ex.Message}", "alert alert-danger");
            }
        }

        private async Task<string> UploadToCloudinary(FileUpload fileUpload, string resourceType)
        {
            try
            {
                using (var stream = new MemoryStream(fileUpload.FileBytes))
                {
                    var uploadParams = new ImageUploadParams()
                    {
                        File = new FileDescription(fileUpload.FileName, stream),
                        Folder = $"language_learning/{ddlLanguage.SelectedValue}/{ddlTopic.SelectedValue}"
                    };

                    var uploadResult = await cloudinary.UploadAsync(uploadParams);
                    return uploadResult.SecureUrl.ToString();
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to upload file: {ex.Message}");
            }
        }

        private void ClearQuestionForm()
        {
            txtQuestionText.Text = "";
            txtOption1.Text = "";
            txtOption2.Text = "";
            txtOption3.Text = "";
            txtCorrectAnswer.Text = "";

            // Reset to default question type
            rbTextQuestion.Checked = true;
            rbImageQuestion.Checked = false;
            rbAudioQuestion.Checked = false;

            ToggleQuestionInputs();

            // Note: FileUpload controls cannot be cleared programmatically for security reasons
        }

        protected async void btnEditQuestion_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string questionId = btn.CommandArgument;

            try
            {
                await LoadQuestionForEdit(questionId);
            }
            catch (Exception ex)
            {
                ShowMessage($"Error loading question for edit: {ex.Message}", "alert alert-danger");
            }
        }

        private async Task LoadQuestionForEdit(string questionId)
        {
            try
            {
                DocumentReference questionRef = db.Collection("languages")
                    .Document(ddlLanguage.SelectedValue)
                    .Collection("topics")
                    .Document(ddlTopic.SelectedValue)
                    .Collection("lessons")
                    .Document(selectedLessonId)
                    .Collection("questions")
                    .Document(questionId);

                DocumentSnapshot questionDoc = await questionRef.GetSnapshotAsync();

                if (questionDoc.Exists)
                {
                    // Set editing mode
                    hfEditingQuestionId.Value = questionId;
                    lblFormTitle.Text = "Edit Question";
                    btnSaveQuestion.Text = "Update Question";
                    btnCancelEdit.Visible = true;

                    // Load question data into form
                    txtQuestionText.Text = questionDoc.GetValue<string>("text");

                    string questionType = questionDoc.GetValue<string>("questionType");

                    // Set question type
                    switch (questionType)
                    {
                        case "text":
                            rbTextQuestion.Checked = true;
                            break;
                        case "image":
                            rbImageQuestion.Checked = true;
                            break;
                        case "audio":
                            rbAudioQuestion.Checked = true;
                            break;
                        default:
                            rbTextQuestion.Checked = true;
                            break;
                    }

                    // Load options and answer for text-based questions
                    if (questionType == "text" || questionType == "image" || questionType == "audio")
                    {
                        var options = questionDoc.GetValue<string[]>("options");
                        if (options != null && options.Length >= 3)
                        {
                            txtOption1.Text = options[0];
                            txtOption2.Text = options[1];
                            txtOption3.Text = options[2];
                        }
                        txtCorrectAnswer.Text = questionDoc.GetValue<string>("answer");
                    }

                    ToggleQuestionInputs();

                    ShowMessage("Question loaded for editing. Make your changes and click 'Update Question'.", "alert alert-info");
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to load question: {ex.Message}");
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            CancelEdit();
        }

        protected async void btnDeleteQuestion_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string questionId = btn.CommandArgument;

            try
            {
                DocumentReference questionRef = db.Collection("languages")
                    .Document(ddlLanguage.SelectedValue)
                    .Collection("topics")
                    .Document(ddlTopic.SelectedValue)
                    .Collection("lessons")
                    .Document(selectedLessonId)
                    .Collection("questions")
                    .Document(questionId);

                await questionRef.DeleteAsync();

                await LoadExistingQuestions();

                // Cancel edit if we're editing the deleted question
                if (hfEditingQuestionId.Value == questionId)
                {
                    CancelEdit();
                }

                ShowMessage("Question deleted successfully!", "alert alert-success");
            }
            catch (Exception ex)
            {
                ShowMessage($"Error deleting question: {ex.Message}", "alert alert-danger");
            }
        }
    }
}