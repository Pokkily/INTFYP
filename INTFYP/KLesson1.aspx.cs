using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

namespace KoreanApp
{
    public partial class KLesson1 : System.Web.UI.Page
    {
        class Question
        {
            public string Text { get; set; }
            public string[] Options { get; set; }
            public string Answer { get; set; }
            public string ImagePath { get; set; }
            public string AudioPath { get; set; }
            public bool IsImageOption { get; set; }
        }

        static List<Question> questions = new List<Question>
        {
            new Question { Text = "Which one is Coffee?", Options = new[] { "커피", "차", "주스" }, Answer = "커피", IsImageOption = true },
            new Question { Text = "Which one is this sound?", Options = new[] { "커피", "차", "주스" }, Answer = "커피", AudioPath = "/LanguageLearning/KLesson1/audio/Coffee.mp3" },
            new Question { Text = "Which Korean word is this image?", Options = new[] { "커피", "차", "주스" }, Answer = "커피", ImagePath = "/LanguageLearning/KLesson1/image/Coffee.png" },

            new Question { Text = "Which one is Tea?", Options = new[] { "커피", "차", "주스" }, Answer = "차", IsImageOption = true },
            new Question { Text = "Which one is this sound?", Options = new[] { "커피", "차", "주스" }, Answer = "차", AudioPath = "/LanguageLearning/KLesson1/audio/Tea.mp3" },
            new Question { Text = "Which Korean word is this image?", Options = new[] { "커피", "차", "주스" }, Answer = "차", ImagePath = "/LanguageLearning/KLesson1/image/Tea.png" },

            new Question { Text = "Which one is Juice?", Options = new[] { "커피", "차", "주스" }, Answer = "주스", IsImageOption = true },
            new Question { Text = "Which one is this sound?", Options = new[] { "커피", "차", "주스" }, Answer = "주스", AudioPath = "/LanguageLearning/KLesson1/audio/Juice.mp3" },
            new Question { Text = "Which Korean word is this image?", Options = new[] { "커피", "차", "주스" }, Answer = "주스", ImagePath = "/LanguageLearning/KLesson1/image/Juice.png" }
        };

        int currentQuestionIndex
        {
            get => ViewState["CurrentQuestionIndex"] != null ? (int)ViewState["CurrentQuestionIndex"] : 0;
            set => ViewState["CurrentQuestionIndex"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                quizPanel.Visible = false;
            }
        }

        protected void btnStart_Click(object sender, EventArgs e)
        {
            startScreen.Visible = false;
            quizPanel.Visible = true;
            currentQuestionIndex = 0;
            ShowQuestion();
        }

        private void ShowQuestion()
        {
            var q = questions[currentQuestionIndex];
            lblQuestion.Text = q.Text;
            lblFeedback.Text = "";

            // Media
            imgQuestion.Visible = !string.IsNullOrEmpty(q.ImagePath);
            imgQuestion.ImageUrl = q.ImagePath ?? "";

            audioQuestion.Visible = !string.IsNullOrEmpty(q.AudioPath);
            audioSource.Src = q.AudioPath ?? "";

            // Show image options
            if (q.IsImageOption)
            {
                imageOptions.Visible = true;
                textOptions.Visible = false;

                string[] imageFiles = { "coffee.png", "tea.png", "juice.png" };
                string[] words = { "커피", "차", "주스" };

                img1.Src = "/LanguageLearning/KLesson1/image/" + imageFiles[0];
                lblImgText1.Text = words[0];
                imgOption1.CommandArgument = words[0];

                img2.Src = "/LanguageLearning/KLesson1/image/" + imageFiles[1];
                lblImgText2.Text = words[1];
                imgOption2.CommandArgument = words[1];

                img3.Src = "/LanguageLearning/KLesson1/image/" + imageFiles[2];
                lblImgText3.Text = words[2];
                imgOption3.CommandArgument = words[2];
            }
            else
            {
                imageOptions.Visible = false;
                textOptions.Visible = true;

                btnOption1.Text = q.Options[0];
                btnOption2.Text = q.Options[1];
                btnOption3.Text = q.Options[2];

                btnOption1.CommandArgument = q.Options[0];
                btnOption2.CommandArgument = q.Options[1];
                btnOption3.CommandArgument = q.Options[2];
            }
        }

        protected void Answer_Click(object sender, EventArgs e)
        {
            var btn = (Button)sender;
            EvaluateAnswer(btn.CommandArgument);
        }

        protected void ImageAnswer_Click(object sender, EventArgs e)
        {
            var btn = (LinkButton)sender;
            EvaluateAnswer(btn.CommandArgument);
        }

        private void EvaluateAnswer(string selected)
        {
            var q = questions[currentQuestionIndex];
            lblFeedback.Text = selected == q.Answer ? "Correct!" : $"Wrong! Correct answer: {q.Answer}";
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            currentQuestionIndex++;
            if (currentQuestionIndex >= questions.Count)
            {
                lblQuestion.Text = "Lesson Complete!";
                imageOptions.Visible = textOptions.Visible = false;
                imgQuestion.Visible = audioQuestion.Visible = false;
                btnNext.Visible = false;
            }
            else
            {
                ShowQuestion();
            }
        }
    }
}
