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
            public string ImageUrl { get; set; } = "";
        }



        private List<QuizQuestion> QuestionList
        {
            get => ViewState["QuestionList"] as List<QuizQuestion> ?? new List<QuizQuestion>();
            set => ViewState["QuestionList"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
            {
                QuestionList.Add(new QuizQuestion()); // first question
                BindRepeater();
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
            if (string.IsNullOrEmpty(quizTitle) || string.IsNullOrEmpty(teacherEmail)) return;

            string quizCode = GenerateQuizCode();

            List<Dictionary<string, object>> formattedQuestions = new List<Dictionary<string, object>>();
            foreach (var q in QuestionList)
            {
                formattedQuestions.Add(new Dictionary<string, object>
    {
        { "question", q.Question },
        { "options", q.Options },
        { "correctIndexes", GetCorrectIndexes(q.IsCorrect) },
        { "imageUrl", q.ImageUrl } // ✅ Include it here
    });
            }


            var quizDoc = new Dictionary<string, object>
            {
                { "quizCode", quizCode },
                { "title", quizTitle },
                { "createdBy", teacherEmail },
                { "createdAt", Timestamp.GetCurrentTimestamp() },
                { "questions", formattedQuestions }
            };

            db.Collection("quizzes").Document(quizCode).SetAsync(quizDoc).GetAwaiter().GetResult();
            ViewState["QuestionList"] = null;

            Response.Redirect("ManagePost.aspx");
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

                // 📸 Handle optional image upload
                var fileUpload = (FileUpload)item.FindControl("fileUpload");
                if (fileUpload != null && fileUpload.HasFile)
                {
                    var account = new Account(
                        ConfigurationManager.AppSettings["CloudinaryCloudName"],
                        ConfigurationManager.AppSettings["CloudinaryApiKey"],
                        ConfigurationManager.AppSettings["CloudinaryApiSecret"]
                    );
                    var cloudinary = new Cloudinary(account);

                    using (var stream = fileUpload.PostedFile.InputStream)
                    {
                        var uploadParams = new ImageUploadParams()
                        {
                            File = new FileDescription(fileUpload.FileName, stream)
                        };

                        var uploadResult = cloudinary.Upload(uploadParams);
                        q.ImageUrl = uploadResult.SecureUrl.ToString();
                    }
                }

                updatedList.Add(q);
            }

            QuestionList = updatedList;
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
