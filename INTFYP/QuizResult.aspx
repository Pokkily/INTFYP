<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizResult.aspx.cs" Inherits="YourProjectNamespace.QuizResult" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Quiz Results</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        
        .result-container {
            max-width: 800px;
            margin: 2rem auto;
            padding: 1rem;
        }
        
        .result-header {
            text-align: center;
            margin-bottom: 1.5rem;
        }
        
        .result-header h1 {
            color: #333;
            font-weight: 500;
        }
        
        .result-card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 2rem;
        }
        
        .score-summary {
            text-align: center;
            margin-bottom: 2rem;
            padding: 1rem;
            border-radius: 8px;
            background-color: #f8f9fa;
        }
        
        .score-number {
            font-size: 3rem;
            font-weight: 700;
            color: #4285f4;
            margin: 0.5rem 0;
        }
        
        .score-text {
            font-size: 1.2rem;
            color: #666;
        }
        
        .results-list {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }
        
        .result-item {
            padding: 1.5rem;
            margin-bottom: 1rem;
            border-radius: 8px;
            border-left: 4px solid #ddd;
        }
        
        .result-item.correct {
            background-color: #e6f4ea;
            border-left-color: #34a853;
        }
        
        .result-item.incorrect {
            background-color: #fce8e6;
            border-left-color: #d93025;
        }
        
        .result-question {
            font-weight: 500;
            margin-bottom: 0.5rem;
        }
        
        .result-answer {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }
        
        .answer-option {
            padding: 0.3rem 0.6rem;
            border-radius: 4px;
            font-size: 0.9rem;
        }
        
        .selected-answer {
            background-color: #d2e3fc;
            border: 1px solid #bbdefb;
        }
        
        .correct-answer {
            background-color: #c1e5c0;
            border: 1px solid #a8d8a7;
        }
        
        .action-buttons {
            display: flex;
            justify-content: center;
            margin-top: 2rem;
            gap: 1rem;
        }
        
        .btn {
            padding: 0.6rem 1.2rem;
            border: none;
            border-radius: 4px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background-color: #4285f4;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #3367d6;
        }
        
        .btn-secondary {
            background-color: #f1f3f4;
            color: #3c4043;
        }
        
        .btn-secondary:hover {
            background-color: #e8eaed;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="result-container">
            <div class="result-header">
                <h1>Quiz Results</h1>
                <p>Review your performance</p>
            </div>
            
            <div class="result-card">
                <div class="score-summary">
                    <div class="score-number"><%= GetScorePercentage() %>%</div>
                    <div class="score-text">You scored <%= GetCorrectCount() %> out of <%= GetTotalQuestions() %> questions</div>
                </div>
                
                <ul class="results-list">
                    <asp:Repeater ID="rptResults" runat="server">
                        <ItemTemplate>
                            <li class="result-item <%# ((bool)Eval("IsCorrect")) ? "correct" : "incorrect" %>">
                                <div class="result-question">Q<%# Container.ItemIndex + 1 %>. <%# Eval("QuestionText") %></div>
                                
                                <div>Your answer:</div>
                                <div class="result-answer">
                                    <%# GetSelectedAnswers((List<int>)Eval("SelectedIndexes"), (List<string>)Eval("Options")) %>
                                </div>
                                
                                <%# (bool)Eval("IsCorrect") ? "" : "<div>Correct answer:</div>" %>
                                <div class="result-answer">
                                    <%# (bool)Eval("IsCorrect") ? "" : GetCorrectAnswers((List<int>)Eval("CorrectIndexes"), (List<string>)Eval("Options")) %>
                                </div>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
                
                <div class="action-buttons">
                    <a href="Default.aspx" class="btn btn-secondary">Back to Home</a>
                    <a href="#" class="btn btn-primary" onclick="window.print()">Print Results</a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>