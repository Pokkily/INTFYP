// Add this in a new file called QuizModels.cs
using System;
using System.Collections.Generic;

namespace YourProjectNamespace
{
    [Serializable]
    public class QuizQuestion
    {
        public string Question { get; set; }
        public List<string> Options { get; set; }
        public string ImageUrl { get; set; }
        public List<int> CorrectIndexes { get; set; }
        public bool IsMultiSelect { get; set; }
    }

    [Serializable]
    public class QuestionResult
    {
        public string QuestionText { get; set; }
        public List<string> Options { get; set; }
        public List<int> SelectedIndexes { get; set; }
        public List<int> CorrectIndexes { get; set; }
        public bool IsCorrect { get; set; }
    }
}