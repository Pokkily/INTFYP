using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class CreateQuiz : System.Web.UI.Page
    {
        private FirestoreDb db;
        private List<QuestionData> Questions
        {
            get { return ViewState["Questions"] as List<QuestionData> ?? new List<QuestionData>(); }
            set { ViewState["Questions"] = value; }
        }

        protected void Page_Init(object sender, EventArgs e)
        {
            InitializeFirestore();
            if (!IsPostBack)
            {
                Questions = new List<QuestionData>();
                ResetInputForm();
            }
        }

        private void InitializeFirestore()
        {
            if (db == null)
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto");
            }
        }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            // Validate inputs
            if (string.IsNullOrWhiteSpace(txtQuestion.Text))
            {
                ShowError("Question text is required");
                return;
            }

            // Collect options
            var options = new List<string> { txtOption1.Text, txtOption2.Text, txtOption3.Text, txtOption4.Text };
            options.RemoveAll(string.IsNullOrWhiteSpace);

            if (options.Count < 2)
            {
                ShowError("At least 2 options are required");
                return;
            }

            // Get correct answers
            var correctIndexes = new List<int>();
            if (chkOption1.Checked) correctIndexes.Add(0);
            if (chkOption2.Checked) correctIndexes.Add(1);
            if (chkOption3.Checked) correctIndexes.Add(2);
            if (chkOption4.Checked) correctIndexes.Add(3);

            if (correctIndexes.Count == 0)
            {
                ShowError("At least one correct answer is required");
                return;
            }

            // Handle image upload
            string imageUrl = null;
            if (fileUpload.HasFile)
            {
                try
                {
                    imageUrl = UploadToCloudinary(fileUpload);
                }
                catch (Exception ex)
                {
                    ShowError($"Error uploading image: {ex.Message}");
                    return;
                }
            }

            // Add to questions list
            Questions.Add(new QuestionData
            {
                QuestionText = txtQuestion.Text,
                Options = options,
                CorrectOptions = correctIndexes,
                ImageUrl = imageUrl
            });

            // Update preview
            UpdateQuestionPreview();
            ResetInputForm();
        }

        private void UpdateQuestionPreview()
        {
            pnlQuestionPreview.Controls.Clear();

            for (int i = 0; i < Questions.Count; i++)
            {
                var question = Questions[i];
                var panel = new Panel { CssClass = "question-preview" };

                panel.Controls.Add(new Literal { Text = $"<h5>Question {i + 1}</h5>" });
                panel.Controls.Add(new Literal { Text = $"<p>{question.QuestionText}</p>" });

                if (!string.IsNullOrEmpty(question.ImageUrl))
                {
                    panel.Controls.Add(new Literal { Text = $"<img src='{question.ImageUrl}' class='question-image' />" });
                }

                panel.Controls.Add(new Literal { Text = "<ul>" });
                for (int j = 0; j < question.Options.Count; j++)
                {
                    var cssClass = question.CorrectOptions.Contains(j) ? "correct-option" : "";
                    panel.Controls.Add(new Literal
                    {
                        Text = $"<li class='{cssClass}'>{question.Options[j]}</li>"
                    });
                }
                panel.Controls.Add(new Literal { Text = "</ul>" });

                // Add edit/remove buttons if needed
                pnlQuestionPreview.Controls.Add(panel);
            }
        }

        private void ResetInputForm()
        {
            txtQuestion.Text = "";
            txtOption1.Text = "";
            txtOption2.Text = "";
            txtOption3.Text = "";
            txtOption4.Text = "";
            chkOption1.Checked = false;
            chkOption2.Checked = false;
            chkOption3.Checked = false;
            chkOption4.Checked = false;
            fileUpload.Dispose();
        }

        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            if (Questions.Count == 0)
            {
                ShowError("Please add at least one question");
                return;
            }

            string quizTitle = txtQuizTitle.Text.Trim();
            string teacherEmail = Session["email"]?.ToString()?.ToLower();

            if (string.IsNullOrEmpty(quizTitle) || string.IsNullOrEmpty(teacherEmail))
            {
                ShowError("Quiz title and teacher email are required");
                return;
            }

            var firestoreQuestions = new List<Dictionary<string, object>>();
            foreach (var question in Questions)
            {
                firestoreQuestions.Add(new Dictionary<string, object>
                {
                    { "question", question.QuestionText },
                    { "options", question.Options },
                    { "correctIndexes", question.CorrectOptions },
                    { "imageUrl", question.ImageUrl }
                });
            }

            string quizCode = GenerateQuizCode();

            var quizDoc = new Dictionary<string, object>
            {
                { "quizCode", quizCode },
                { "title", quizTitle },
                { "createdBy", teacherEmail },
                { "createdAt", Timestamp.GetCurrentTimestamp() },
                { "questions", firestoreQuestions }
            };

            db.Collection("quizzes").Document(quizCode).SetAsync(quizDoc).GetAwaiter().GetResult();
            Questions.Clear();
            Response.Redirect("ManagePost.aspx");
        }

        private string UploadToCloudinary(FileUpload fileUpload)
        {
            var account = new Account(
                ConfigurationManager.AppSettings["CloudinaryCloudName"],
                ConfigurationManager.AppSettings["CloudinaryApiKey"],
                ConfigurationManager.AppSettings["CloudinaryApiSecret"]
            );
            var cloudinary = new Cloudinary(account);

            using (var stream = fileUpload.PostedFile.InputStream)
            {
                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(fileUpload.FileName, stream)
                };
                var uploadResult = cloudinary.Upload(uploadParams);
                return uploadResult.SecureUrl.ToString();
            }
        }

        private string GenerateQuizCode()
        {
            Random rand = new Random();
            return rand.Next(100000, 999999).ToString();
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
        }
    }

    public class QuestionData
    {
        public string QuestionText { get; set; }
        public List<string> Options { get; set; }
        public List<int> CorrectOptions { get; set; }
        public string ImageUrl { get; set; }
    }
}