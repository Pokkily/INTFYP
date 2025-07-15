<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="QuizDetail.aspx.cs" Inherits="YourProjectNamespace.QuizDetail" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Quiz - <%= GetQuizTitle() %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        
        .quiz-container {
            max-width: 800px;
            margin: 2rem auto;
            padding: 1rem;
        }
        
        .quiz-header {
            text-align: center;
            margin-bottom: 1.5rem;
        }
        
        .quiz-header h1 {
            color: #333;
            font-weight: 500;
        }
        
        .quiz-card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 2rem;
        }
        
        .quiz-progress {
            height: 6px;
            background-color: #e0e0e0;
            border-radius: 3px;
            margin-bottom: 2rem;
        }
        
        .quiz-progress-bar {
            height: 100%;
            background-color: #4285f4;
            border-radius: 3px;
            width: <%= GetProgressWidth() %>%;
            transition: width 0.3s ease;
        }
        
        .question-container {
            margin-bottom: 2rem;
        }
        
        .question-text {
            font-size: 1.2rem;
            font-weight: 500;
            margin-bottom: 1.5rem;
            color: #333;
        }
        
        .question-image {
            max-width: 100%;
            height: auto;
            margin-bottom: 1.5rem;
            border-radius: 4px;
            display: block;
        }
        
        .options-container {
            margin-top: 1.5rem;
        }
        
        .options-list {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }
        
        .option-item {
            padding: 0.8rem 1rem;
            margin-bottom: 0.8rem;
            border: 1px solid #ddd;
            border-radius: 4px;
            background-color: #f9f9f9;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .option-item:hover {
            background-color: #f0f0f0;
            border-color: #ccc;
        }
        
        .option-item.selected {
            background-color: #e3f2fd;
            border-color: #bbdefb;
        }
        
        .quiz-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 2rem;
        }
        
        .question-counter {
            color: #666;
            font-size: 0.9rem;
        }
        
        .question-counter span {
            font-weight: 500;
            color: #333;
        }
        
        .button-group {
            display: flex;
            gap: 1rem;
        }
        
        .btn {
            padding: 0.6rem 1.2rem;
            border: none;
            border-radius: 4px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        
        .btn-primary {
            background-color: #4285f4;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #3367d6;
        }
        
        .btn-success {
            background-color: #34a853;
            color: white;
        }
        
        .btn-success:hover {
            background-color: #2d9249;
        }
        
        .submit-notice {
            margin-top: 1rem;
            color: #666;
            font-style: italic;
            font-size: 0.9rem;
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
                        <asp:CheckBoxList ID="cblOptions" runat="server" CssClass="options-list">
                        </asp:CheckBoxList>
                    </div>
                    
                    <asp:Label ID="lblMultiSelectNotice" runat="server" CssClass="submit-notice" Visible="false"></asp:Label>
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
        document.addEventListener('DOMContentLoaded', function () {
            // Style checkboxes as cards
            const options = document.querySelectorAll('.options-list label');
            options.forEach(option => {
                const wrapper = document.createElement('div');
                wrapper.className = 'option-item';
                option.parentNode.insertBefore(wrapper, option);
                wrapper.appendChild(option);

                // Add click handler to select the checkbox when clicking anywhere on the option
                wrapper.addEventListener('click', function (e) {
                    if (e.target.tagName !== 'INPUT') {
                        const checkbox = this.querySelector('input[type="checkbox"]');
                        checkbox.checked = !checkbox.checked;

                        // Trigger change event
                        const event = new Event('change');
                        checkbox.dispatchEvent(event);
                    }
                });
            });

            // Highlight selected options
            document.querySelectorAll('.options-list input[type="checkbox"]').forEach(checkbox => {
                checkbox.addEventListener('change', function () {
                    const optionItem = this.closest('.option-item');
                    if (this.checked) {
                        optionItem.classList.add('selected');
                    } else {
                        optionItem.classList.remove('selected');
                    }
                });
            });

            // Initialize selected state
            document.querySelectorAll('.options-list input[type="checkbox"]:checked').forEach(checkbox => {
                checkbox.closest('.option-item').classList.add('selected');
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