using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class QuizResult : Page
    {
        public class QuestionResult
        {
            public string QuestionText { get; set; }
            public List<string> Options { get; set; }
            public List<int> SelectedIndexes { get; set; }
            public List<int> CorrectIndexes { get; set; }
            public bool IsCorrect { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["QuizQuestions"] == null || Session["SelectedAnswers"] == null)
                {
                    Response.Redirect("Default.aspx");
                    return;
                }

                CalculateResults();
                BindResults();
            }
        }

        private void CalculateResults()
        {
            var questions = Session["QuizQuestions"] as List<QuizDetail.QuizQuestion>;
            var selectedAnswers = Session["SelectedAnswers"] as Dictionary<int, List<int>>;
            var results = new List<QuestionResult>();

            if (questions == null || selectedAnswers == null) return;

            for (int i = 0; i < questions.Count; i++)
            {
                var question = questions[i];
                selectedAnswers.TryGetValue(i, out List<int> userAnswers);
                userAnswers = userAnswers ?? new List<int>();

                bool isCorrect = false;

                if (question.isMultiSelect)
                {
                    // For multi-select questions, check if all correct answers are selected and no incorrect ones
                    isCorrect = userAnswers.Count == question.correctIndexes.Count &&
                               question.correctIndexes.All(x => userAnswers.Contains(x));
                }
                else if (userAnswers.Count > 0)
                {
                    // For single-select questions
                    isCorrect = question.correctIndexes.Contains(userAnswers[0]);
                }

                results.Add(new QuestionResult
                {
                    QuestionText = question.question,
                    Options = question.options,
                    SelectedIndexes = userAnswers,
                    CorrectIndexes = question.correctIndexes,
                    IsCorrect = isCorrect
                });
            }

            Session["QuizResults"] = results;
        }

        private void BindResults()
        {
            var results = Session["QuizResults"] as List<QuestionResult>;
            if (results != null)
            {
                rptResults.DataSource = results;
                rptResults.DataBind();
            }
        }

        // Public methods for ASPX page to access data
        public int GetCorrectCount()
        {
            var results = Session["QuizResults"] as List<QuestionResult>;
            return results?.Count(r => r.IsCorrect) ?? 0;
        }

        public int GetTotalQuestions()
        {
            var results = Session["QuizResults"] as List<QuestionResult>;
            return results?.Count ?? 0;
        }

        public int GetScorePercentage()
        {
            int total = GetTotalQuestions();
            if (total == 0) return 0;

            return (int)Math.Round((double)GetCorrectCount() / total * 100);
        }

        public string GetSelectedAnswers(List<int> selectedIndexes, List<string> options)
        {
            if (selectedIndexes == null || selectedIndexes.Count == 0)
                return "<span style='color:#d93025; font-style:italic;'>No answer selected</span>";

            var selectedOptions = selectedIndexes
                .Where(i => i >= 0 && i < options.Count)
                .Select(i => $"<span class='answer-option selected-answer'>{options[i]}</span>");

            return string.Join("", selectedOptions);
        }

        public string GetCorrectAnswers(List<int> correctIndexes, List<string> options)
        {
            if (correctIndexes == null || correctIndexes.Count == 0)
                return string.Empty;

            var correctOptions = correctIndexes
                .Where(i => i >= 0 && i < options.Count)
                .Select(i => $"<span class='answer-option correct-answer'>{options[i]}</span>");

            return string.Join("", correctOptions);
        }
    }
}