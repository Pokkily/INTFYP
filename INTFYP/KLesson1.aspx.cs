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
            new Question { Text = "Which Korean word is this image?", Options = new[] { "커피", "차", "주스" }, Answer = "커피", ImagePath = "/LanguageLearning/KLesson1/image/coffee.png" },

            new Question { Text = "Which one is Tea?", Options = new[] { "커피", "차", "주스" }, Answer = "차", IsImageOption = true },
            new Question { Text = "Which one is this sound?", Options = new[] { "커피", "차", "주스" }, Answer = "차", AudioPath = "/LanguageLearning/KLesson1/audio/Tea.mp3" },
            new Question { Text = "Which Korean word is this image?", Options = new[] { "커피", "차", "주스" }, Answer = "차", ImagePath = "/LanguageLearning/KLesson1/image/tea.png" },

            new Question { Text = "Which one is Juice?", Options = new[] { "커피", "차", "주스" }, Answer = "주스", IsImageOption = true },
            new Question { Text = "Which one is this sound?", Options = new[] { "커피", "차", "주스" }, Answer = "주스", AudioPath = "/LanguageLearning/KLesson1/audio/Juice.mp3" },
            new Question { Text = "Which Korean word is this image?", Options = new[] { "커피", "차", "주스" }, Answer = "주스", ImagePath = "/LanguageLearning/KLesson1/image/juice.png" }
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

            // Media visibility
            imgQuestion.Visible = !string.IsNullOrEmpty(q.ImagePath);
            imgQuestion.ImageUrl = q.ImagePath ?? "";

            audioQuestion.Visible = !string.IsNullOrEmpty(q.AudioPath);
            audioSource.Src = q.AudioPath ?? "";

            // Shuffle options
            string[] shuffled = ShuffleArray((string[])q.Options.Clone());

            if (q.IsImageOption)
            {
                imageOptions.Visible = true;
                textOptions.Visible = false;

                Dictionary<string, string> wordToImage = new Dictionary<string, string>
                {
                    { "커피", "coffee.png" },
                    { "차", "tea.png" },
                    { "주스", "juice.png" }
                };

                // Set shuffled image buttons
                img1.Src = "/LanguageLearning/KLesson1/image/" + wordToImage[shuffled[0]];
                lblImgText1.Text = shuffled[0];
                imgOption1.CommandArgument = shuffled[0];

                img2.Src = "/LanguageLearning/KLesson1/image/" + wordToImage[shuffled[1]];
                lblImgText2.Text = shuffled[1];
                imgOption2.CommandArgument = shuffled[1];

                img3.Src = "/LanguageLearning/KLesson1/image/" + wordToImage[shuffled[2]];
                lblImgText3.Text = shuffled[2];
                imgOption3.CommandArgument = shuffled[2];
            }
            else
            {
                imageOptions.Visible = false;
                textOptions.Visible = true;

                btnOption1.Text = shuffled[0];
                btnOption2.Text = shuffled[1];
                btnOption3.Text = shuffled[2];

                btnOption1.CommandArgument = shuffled[0];
                btnOption2.CommandArgument = shuffled[1];
                btnOption3.CommandArgument = shuffled[2];
            }

            // RESET state for text buttons
            btnOption1.Enabled = true;
            btnOption2.Enabled = true;
            btnOption3.Enabled = true;

            btnOption1.CssClass = "btn btn-outline-primary me-2 mb-2";
            btnOption2.CssClass = "btn btn-outline-primary me-2 mb-2";
            btnOption3.CssClass = "btn btn-outline-primary me-2 mb-2";

            // RESET state for image option buttons
            imgOption1.Enabled = true;
            imgOption2.Enabled = true;
            imgOption3.Enabled = true;

            imgOption1.CssClass = "";
            imgOption2.CssClass = "";
            imgOption3.CssClass = "";


            btnNext.Visible = false;
        }

        private string[] ShuffleArray(string[] array)
        {
            Random rng = new Random();
            for (int i = array.Length - 1; i > 0; i--)
            {
                int j = rng.Next(i + 1);
                string temp = array[i];
                array[i] = array[j];
                array[j] = temp;
            }
            return array;
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
            bool isCorrect = selected == q.Answer;

            lblFeedback.Text = isCorrect ? "✅ Correct!" : $"❌ Wrong! Correct answer: {q.Answer}";
            btnNext.Visible = true;

            if (q.IsImageOption)
            {
                // Disable image options
                imgOption1.Enabled = imgOption2.Enabled = imgOption3.Enabled = false;

                // Highlight correct/incorrect
                if (imgOption1.CommandArgument == selected)
                    imgOption1.CssClass += (isCorrect ? " correct-answer" : " wrong-answer");
                if (imgOption2.CommandArgument == selected)
                    imgOption2.CssClass += (isCorrect ? " correct-answer" : " wrong-answer");
                if (imgOption3.CommandArgument == selected)
                    imgOption3.CssClass += (isCorrect ? " correct-answer" : " wrong-answer");
            }
            else
            {
                // Disable text options
                btnOption1.Enabled = btnOption2.Enabled = btnOption3.Enabled = false;

                // Highlight buttons
                if (btnOption1.CommandArgument == selected)
                    btnOption1.CssClass += (isCorrect ? " correct-answer" : " wrong-answer");
                if (btnOption2.CommandArgument == selected)
                    btnOption2.CssClass += (isCorrect ? " correct-answer" : " wrong-answer");
                if (btnOption3.CommandArgument == selected)
                    btnOption3.CssClass += (isCorrect ? " correct-answer" : " wrong-answer");
            }
        }


        protected void btnNext_Click(object sender, EventArgs e)
        {
            currentQuestionIndex++;
            if (currentQuestionIndex >= questions.Count)
            {
                lblQuestion.Text = "🎉 Lesson Complete!";
                imageOptions.Visible = textOptions.Visible = false;
                imgQuestion.Visible = audioQuestion.Visible = false;
                btnNext.Visible = false;

                // Add client-side script to redirect after 2.5 seconds (2500 ms)
                string script = "<script>setTimeout(function() { window.location.href = 'Korean.aspx'; }, 2500);</script>";
                ClientScript.RegisterStartupScript(this.GetType(), "RedirectAfterDelay", script);
            }
            else
            {
                ShowQuestion();
            }
        }
    }
}
