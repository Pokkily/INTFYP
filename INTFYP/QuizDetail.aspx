<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="QuizDetail.aspx.cs" Inherits="YourProjectNamespace.QuizDetail" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Quiz - <%= GetQuizTitle() %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4361ee;
            --secondary-color: #3f37c9;
            --success-color: #4cc9f0;
            --danger-color: #f72585;
            --light-color: #f8f9fa;
            --dark-color: #212529;
            --border-radius: 8px;
            --box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Roboto', sans-serif;
        }
        
        body {
            background-color: #f5f7fa;
            color: var(--dark-color);
            line-height: 1.6;
        }
        
        .quiz-container {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            padding: 2rem;
        }
        
        .quiz-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .quiz-header h1 {
            color: var(--primary-color);
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .quiz-progress {
            width: 100%;
            background-color: #e9ecef;
            border-radius: var(--border-radius);
            height: 10px;
            margin-bottom: 1.5rem;
            overflow: hidden;
        }
        
        .quiz-progress-bar {
            height: 100%;
            background-color: var(--primary-color);
            width: <%= GetProgressWidth() %>%;
            transition: width 0.3s ease;
        }
        
        .quiz-card {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            max-width: 800px;
            width: 100%;
            margin: 0 auto;
            padding: 2rem;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }
        
        .question-container {
            margin-bottom: 2rem;
            flex-grow: 1;
        }
        
        .question-text {
            font-size: 1.25rem;
            font-weight: 500;
            margin-bottom: 1.5rem;
            color: var(--dark-color);
        }
        
        .question-image {
            max-width: 100%;
            max-height: 300px;
            margin: 0 auto 1.5rem;
            display: block;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
        }
        
        .options-container {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
        }
        
        .option-item {
            display: flex;
            align-items: center;
            padding: 1rem;
            background-color: var(--light-color);
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: all 0.2s ease;
            border: 1px solid #dee2e6;
        }
        
        .option-item:hover {
            background-color: #e9ecef;
            transform: translateY(-2px);
        }
        
        .option-item input[type="radio"] {
            margin-right: 1rem;
            transform: scale(1.2);
        }
        
        .quiz-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 2rem;
            padding-top: 1.5rem;
            border-top: 1px solid #dee2e6;
        }
        
        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: var(--border-radius);
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 1rem;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-primary:hover {
            background-color: var(--secondary-color);
            transform: translateY(-2px);
        }
        
        .btn-success {
            background-color: var(--success-color);
            color: white;
        }
        
        .btn-success:hover {
            background-color: #3aa8d4;
            transform: translateY(-2px);
        }
        
        .question-counter {
            color: #6c757d;
            font-weight: 500;
        }
        
        @media (max-width: 768px) {
            .quiz-container {
                padding: 1rem;
            }
            
            .quiz-card {
                padding: 1.5rem;
            }
            
            .question-text {
                font-size: 1.1rem;
            }
            
            .btn {
                padding: 0.6rem 1.2rem;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="quiz-container">
            <div class="quiz-header">
                <h1><%= GetQuizTitle() %></h1>
            </div>
            
            <div class="quiz-card">
                <div class="quiz-progress">
                    <div class="quiz-progress-bar"></div>
                </div>
                
                <div class="question-container">
                    <div id="questionText" runat="server" class="question-text"></div>
                    
                    <asp:Image ID="imgQuestionImage" runat="server" CssClass="question-image" Visible="false" />
                    
                    <div class="options-container">
                        <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="options-list">
                        </asp:RadioButtonList>
                    </div>
                </div>
                
                <div class="quiz-footer">
                    <span class="question-counter">
                        Question <span><%= GetCurrentQuestionNumber() %></span> of <span><%= GetTotalQuestions() %></span>
                    </span>
                    
                    <div class="button-group">
                        <asp:Button ID="btnNext" runat="server" Text="Next Question" CssClass="btn btn-primary" OnClick="btnNext_Click" />
                        <asp:Button ID="btnSubmit" runat="server" Text="Submit Quiz" CssClass="btn btn-success" Visible="false" OnClick="btnSubmit_Click" />
                    </div>
                </div>
            </div>
        </div>
    </form>
    
    <script>
        // Add client-side interactivity for better UX
        document.addEventListener('DOMContentLoaded', function () {
            // Style radio buttons as cards
            const options = document.querySelectorAll('.options-list label');
            options.forEach(option => {
                option.parentElement.classList.add('option-item');
            });

            // Prevent form submission when pressing enter
            document.getElementById('form1').addEventListener('keypress', function (e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                }
            });
        });
    </script>
</body>
</html>