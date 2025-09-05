using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using System.IO;

namespace YourProjectNamespace
{
    public partial class CreateQuiz : System.Web.UI.Page
    {
        private FirestoreDb db;

        [Serializable]
        public class QuizQuestion
        {
            public string Question { get; set; }
            public List<string> Options { get; set; } = new List<string> { "", "", "", "" };
            public List<bool> IsCorrect { get; set; } = new List<bool> { false, false, false, false };
        }

        private List<QuizQuestion> QuestionList
        {
            get => ViewState["QuestionList"] as List<QuizQuestion> ?? new List<QuizQuestion>();
            set => ViewState["QuestionList"] = value;
        }

        // Store quiz image URL in ViewState to persist across postbacks
        private string QuizImageUrl
        {
            get => ViewState["QuizImageUrl"] as string ?? "";
            set => ViewState["QuizImageUrl"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
            {
                QuestionList.Add(new QuizQuestion()); // first question
                BindRepeater();
            }
            else
            {
                // Restore quiz image preview on postback
                if (!string.IsNullOrEmpty(QuizImageUrl))
                {
                    imgQuizPreview.ImageUrl = QuizImageUrl;
                    imgQuizPreview.Visible = true;
                    lblUploadSuccess.Text = "✓ Quiz image uploaded successfully";
                    lblUploadSuccess.Visible = true;
                }
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

        private void BindRepeater()
        {
            rptQuestions.DataSource = QuestionList;
            rptQuestions.DataBind();
        }

        // Quiz image upload handler
        protected void btnUploadQuizImage_Click(object sender, EventArgs e)
        {
            if (!fileQuizImage.HasFile)
            {
                lblImageError.Text = "Please select an image first.";
                lblImageError.Visible = true;
                lblUploadSuccess.Visible = false;
                return;
            }

            try
            {
                var account = new Account(
                    ConfigurationManager.AppSettings["CloudinaryCloudName"],
                    ConfigurationManager.AppSettings["CloudinaryApiKey"],
                    ConfigurationManager.AppSettings["CloudinaryApiSecret"]
                );
                var cloudinary = new Cloudinary(account);

                using (var stream = fileQuizImage.PostedFile.InputStream)
                {
                    var uploadParams = new ImageUploadParams()
                    {
                        File = new FileDescription(fileQuizImage.FileName, stream)
                    };

                    var uploadResult = cloudinary.Upload(uploadParams);
                    QuizImageUrl = uploadResult.SecureUrl.ToString();

                    // Show preview and success message
                    imgQuizPreview.ImageUrl = QuizImageUrl;
                    imgQuizPreview.Visible = true;
                    lblImageError.Visible = false;
                    lblUploadSuccess.Text = "✓ Quiz image uploaded successfully";
                    lblUploadSuccess.Visible = true;
                }
            }
            catch (Exception ex)
            {
                lblImageError.Text = "Image upload failed: " + ex.Message;
                lblImageError.Visible = true;
                lblUploadSuccess.Visible = false;
                QuizImageUrl = ""; // Clear on error
            }
        }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            SaveRepeaterToState();
            QuestionList.Add(new QuizQuestion());
            BindRepeater();
        }

        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            SaveRepeaterToState();

            string quizTitle = txtQuizTitle.Text.Trim();
            string teacherEmail = Session["email"]?.ToString()?.ToLower();

            if (string.IsNullOrEmpty(quizTitle) || string.IsNullOrEmpty(teacherEmail))
            {
                lblImageError.Text = "Please enter a quiz title.";
                lblImageError.Visible = true;
                return;
            }

            // Check if quiz image was uploaded
            if (string.IsNullOrEmpty(QuizImageUrl))
            {
                lblImageError.Text = "Please upload a quiz image first.";
                lblImageError.Visible = true;
                return;
            }

            // Validate that we have at least one question with content
            if (QuestionList.Count == 0 || string.IsNullOrEmpty(QuestionList[0].Question.Trim()))
            {
                lblImageError.Text = "Please add at least one question.";
                lblImageError.Visible = true;
                return;
            }

            try
            {
                string quizCode = GenerateQuizCode();

                List<Dictionary<string, object>> formattedQuestions = new List<Dictionary<string, object>>();
                foreach (var q in QuestionList)
                {
                    // Skip empty questions
                    if (string.IsNullOrEmpty(q.Question.Trim())) continue;

                    formattedQuestions.Add(new Dictionary<string, object>
                    {
                        { "question", q.Question },
                        { "options", q.Options },
                        { "correctIndexes", GetCorrectIndexes(q.IsCorrect) }
                    });
                }

                var quizDoc = new Dictionary<string, object>
                {
                    { "quizCode", quizCode },
                    { "title", quizTitle },
                    { "createdBy", teacherEmail },
                    { "createdAt", Timestamp.GetCurrentTimestamp() },
                    { "quizImageUrl", QuizImageUrl }, // Use stored image URL
                    { "questions", formattedQuestions }
                };

                db.Collection("quizzes").Document(quizCode).SetAsync(quizDoc).GetAwaiter().GetResult();

                // Clear ViewState
                ViewState["QuestionList"] = null;
                ViewState["QuizImageUrl"] = null;

                Response.Redirect("QuizAnalytics.aspx");
            }
            catch (Exception ex)
            {
                lblImageError.Text = "Error creating quiz: " + ex.Message;
                lblImageError.Visible = true;
            }
        }

        private void SaveRepeaterToState()
        {
            var updatedList = new List<QuizQuestion>();

            foreach (RepeaterItem item in rptQuestions.Items)
            {
                var q = new QuizQuestion();

                var txtQuestion = (TextBox)item.FindControl("txtQuestion");
                q.Question = txtQuestion?.Text.Trim() ?? "";

                for (int i = 0; i < 4; i++)
                {
                    var opt = (TextBox)item.FindControl($"opt{i}");
                    var chk = (CheckBox)item.FindControl($"chk{i}");

                    q.Options[i] = opt?.Text.Trim() ?? "";
                    q.IsCorrect[i] = chk?.Checked ?? false;
                }

                updatedList.Add(q);
            }

            QuestionList = updatedList;
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            // No special handling needed since we removed question images
        }

        protected void rptQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                int indexToRemove = Convert.ToInt32(e.CommandArgument);
                SaveRepeaterToState(); // Save current inputs
                var list = QuestionList;

                if (indexToRemove >= 0 && indexToRemove < list.Count)
                {
                    list.RemoveAt(indexToRemove);
                    QuestionList = list;
                    BindRepeater(); // Refresh UI
                }
            }
        }

        private List<int> GetCorrectIndexes(List<bool> flags)
        {
            var indexes = new List<int>();
            for (int i = 0; i < flags.Count; i++)
            {
                if (flags[i]) indexes.Add(i);
            }
            return indexes;
        }

        private string GenerateQuizCode()
        {
            return new Random().Next(100000, 999999).ToString();
        }
    }
}