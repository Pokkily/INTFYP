<%@ Page Title="Quiz Detail" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" Async="true" CodeBehind="QuizDetail.aspx.cs" Inherits="YourProjectNamespace.QuizDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            min-height: 100vh;
        }

        .quiz-detail-page {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            position: relative;
        }

        .quiz-detail-page::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="white" opacity="0.1"/><circle cx="75" cy="75" r="1" fill="white" opacity="0.1"/><circle cx="50" cy="10" r="0.5" fill="white" opacity="0.15"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
            pointer-events: none;
            z-index: 1;
        }

        .quiz-header {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            padding: 40px 20px;
            text-align: center;
            margin-bottom: 0;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            position: relative;
            z-index: 2;
        }

        .quiz-title {
            font-size: 32px;
            font-weight: bold;
            margin-bottom: 15px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }

        .quiz-info {
            font-size: 18px;
            opacity: 0.95;
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
        }

        .quiz-image {
            width: 100%;
            max-width: 500px;
            height: 250px;
            object-fit: cover;
            border-radius: 15px;
            margin: 25px auto;
            display: block;
            box-shadow: 0 8px 30px rgba(0,0,0,0.2);
            border: 3px solid rgba(255, 255, 255, 0.3);
        }

        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px 20px;
            width: 100%;
            box-sizing: border-box;
            position: relative;
            z-index: 2;
        }

        .question-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 30px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.1);
            border-left: 5px solid #667eea;
            flex: 1;
        }

        .progress-container {
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            height: 12px;
            margin: 20px 0;
            overflow: hidden;
            box-shadow: inset 0 2px 4px rgba(0,0,0,0.1);
        }

        .progress-bar {
            background: linear-gradient(90deg, #56ab2f, #a8e6cf, #667eea);
            height: 100%;
            border-radius: 15px;
            transition: width 0.5s ease;
            box-shadow: 0 2px 8px rgba(86, 171, 47, 0.3);
        }

        .progress-text {
            text-align: center;
            margin: 15px 0;
            color: white;
            font-size: 16px;
            font-weight: 600;
            text-shadow: 0 1px 2px rgba(0,0,0,0.3);
        }

        .question-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .question-number {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 20px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        .question-type {
            background: linear-gradient(135deg, #56ab2f, #a8e6cf);
            color: white;
            padding: 8px 16px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
            box-shadow: 0 4px 15px rgba(86, 171, 47, 0.3);
        }

        .question-text {
            font-size: 22px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 25px;
            line-height: 1.6;
        }

        .question-image {
            width: 100%;
            max-width: 600px;
            max-height: 400px;
            object-fit: contain;
            border-radius: 15px;
            margin: 25px auto;
            display: block;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            border: 2px solid rgba(102, 126, 234, 0.2);
        }

        .options-container {
            margin-top: 30px;
            display: grid;
            gap: 15px;
        }

        .option-item {
            display: flex;
            align-items: center;
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
            padding: 20px 25px;
            border-radius: 15px;
            cursor: pointer;
            transition: all 0.4s ease;
            border: 3px solid transparent;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            position: relative;
            overflow: hidden;
        }

        .option-item::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.1), transparent);
            transition: left 0.5s ease;
        }

        .option-item:hover::before {
            left: 100%;
        }

        .option-item:hover {
            background: linear-gradient(135deg, #e3f2fd, #bbdefb);
            transform: translateX(10px) scale(1.02);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
        }

        .option-item.selected {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-color: #ffffff;
            transform: translateX(10px) scale(1.02);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
        }

        .option-item.selected .option-text {
            color: white;
            font-weight: 600;
        }

        .option-input {
            margin-right: 20px;
            transform: scale(1.3);
        }

        .option-text {
            font-size: 18px;
            color: #495057;
            flex: 1;
            font-weight: 500;
        }

        .navigation-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 40px;
            padding: 30px 40px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .btn {
            padding: 15px 30px;
            border: none;
            border-radius: 30px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.4s ease;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            text-transform: uppercase;
            letter-spacing: 1px;
            position: relative;
            overflow: hidden;
        }

        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s ease;
        }

        .btn:hover::before {
            left: 100%;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6c757d, #495057);
            color: white;
            box-shadow: 0 6px 20px rgba(108, 117, 125, 0.3);
        }

        .btn-secondary:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(108, 117, 125, 0.4);
        }

        .btn-success {
            background: linear-gradient(135deg, #56ab2f 0%, #a8e6cf 100%);
            color: white;
            font-size: 18px;
            padding: 18px 35px;
            box-shadow: 0 8px 25px rgba(86, 171, 47, 0.3);
        }

        .btn-success:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(86, 171, 47, 0.4);
        }

        .results-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(30px);
            border-radius: 25px;
            padding: 60px 40px;
            text-align: center;
            box-shadow: 0 20px 50px rgba(0,0,0,0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin: 40px 20px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .score-circle {
            width: 200px;
            height: 200px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #56ab2f 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: bold;
            margin: 0 auto 40px;
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.4);
            position: relative;
        }

        .score-circle::before {
            content: '';
            position: absolute;
            inset: 10px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
        }

        .score-circle span {
            position: relative;
            z-index: 1;
        }

        .results-title {
            font-size: 36px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 25px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .results-details {
            font-size: 20px;
            color: #7f8c8d;
            margin-bottom: 40px;
            line-height: 1.6;
        }

        .results-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }

        @media (max-width: 768px) {
            .main-content {
                padding: 20px 15px;
            }
            
            .question-container {
                padding: 25px 20px;
            }
            
            .navigation-container {
                flex-direction: column;
                gap: 20px;
                padding: 25px 20px;
            }

            .quiz-header {
                padding: 30px 20px;
            }

            .quiz-title {
                font-size: 26px;
            }

            .options-container {
                gap: 12px;
            }

            .option-item {
                padding: 15px 20px;
            }

            .results-container {
                padding: 40px 25px;
                margin: 20px 10px;
            }

            .score-circle {
                width: 150px;
                height: 150px;
                font-size: 36px;
            }

            .results-buttons {
                flex-direction: column;
                align-items: center;
            }

            .results-buttons .btn {
                width: 200px;
            }
        }
    </style>

    <div class="quiz-detail-page">
        <!-- Quiz Header -->
        <asp:Panel ID="pnlQuizHeader" runat="server" CssClass="quiz-header">
            <div class="quiz-title">
                <asp:Label ID="lblQuizTitle" runat="server" />
            </div>
            <div class="quiz-info">
                Created by: <asp:Label ID="lblCreatedBy" runat="server" /> | 
                Code: <asp:Label ID="lblQuizCode" runat="server" />
            </div>
            <asp:Image ID="imgQuiz" runat="server" CssClass="quiz-image" Visible="false" />
        </asp:Panel>

        <!-- Quiz Content Panel (includes everything except results) -->
        <asp:Panel ID="pnlQuizContent" runat="server">
            <div class="main-content">
                <!-- Progress Bar -->
                <asp:Panel ID="pnlProgress" runat="server" CssClass="progress-container">
                    <div class="progress-bar" id="progressBar" style="width: 0%"></div>
                </asp:Panel>
                <div class="progress-text">
                    Question <asp:Label ID="lblCurrentQuestion" runat="server" /> of <asp:Label ID="lblTotalQuestions" runat="server" />
                </div>

                <!-- Question Container -->
                <asp:Panel ID="pnlQuestion" runat="server" CssClass="question-container">
                    <div class="question-header">
                        <div class="question-number">
                            <asp:Label ID="lblQuestionNumber" runat="server" />
                        </div>
                        <div class="question-type">
                            <asp:Label ID="lblQuestionType" runat="server" />
                        </div>
                    </div>

                    <div class="question-text">
                        <asp:Label ID="lblQuestion" runat="server" />
                    </div>

                    <asp:Image ID="imgQuestion" runat="server" CssClass="question-image" Visible="false" />

                    <div class="options-container">
                        <asp:Repeater ID="rptOptions" runat="server">
                            <ItemTemplate>
                                <div class="option-item" onclick="selectOption(this, <%# Container.ItemIndex %>, '<%# IsMultipleAnswer ? "checkbox" : "radio" %>')">
                                    <asp:CheckBox ID="chkOption" runat="server" CssClass="option-input" Visible='<%# IsMultipleAnswer %>' />
                                    <asp:RadioButton ID="rdoOption" runat="server" GroupName="options" CssClass="option-input" Visible='<%# !IsMultipleAnswer %>' />
                                    <span class="option-text"><%# Container.DataItem %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <!-- Navigation -->
                <div class="navigation-container">
                    <asp:Button ID="btnPrevious" runat="server" Text="← Previous" CssClass="btn btn-secondary" OnClick="btnPrevious_Click" Visible="false" />
                    <div></div>
                    <asp:Button ID="btnNext" runat="server" Text="Next →" CssClass="btn btn-primary" OnClick="btnNext_Click" />
                    <asp:Button ID="btnFinish" runat="server" Text="Finish Quiz" CssClass="btn btn-success" OnClick="btnFinish_Click" Visible="false" />
                </div>
            </div>
        </asp:Panel>

        <!-- Results Container -->
        <asp:Panel ID="pnlResults" runat="server" CssClass="results-container" Visible="false">
            <div class="score-circle">
                <span><asp:Label ID="lblScorePercentage" runat="server" />%</span>
            </div>
            <div class="results-title">Quiz Completed!</div>
            <div class="results-details">
                You scored <asp:Label ID="lblCorrectAnswers" runat="server" /> out of <asp:Label ID="lblTotalQuestionsResult" runat="server" /> questions correctly.
            </div>
            <div class="results-buttons">
                <asp:Button ID="btnTryAgain" runat="server" Text="Try Again" CssClass="btn btn-primary" OnClick="btnTryAgain_Click" />
                <asp:Button ID="btnBackToQuizzes" runat="server" Text="Back to Quizzes" CssClass="btn btn-secondary" OnClick="btnBackToQuizzes_Click" />
            </div>
        </asp:Panel>
    </div>

    <script type="text/javascript">
        function selectOption(element, index, type) {
            if (type === 'radio') {
                // For single answer questions
                var radio = element.querySelector('input[type="radio"]');
                
                if (radio && radio.checked) {
                    // If clicking on already selected radio, deselect it
                    radio.checked = false;
                    element.classList.remove('selected');
                } else {
                    // Clear all selections first
                    var allOptions = document.querySelectorAll('.option-item');
                    var allRadios = document.querySelectorAll('input[type="radio"][name="' + radio.name + '"]');
                    
                    allOptions.forEach(function(option) {
                        option.classList.remove('selected');
                    });
                    
                    allRadios.forEach(function(r) {
                        r.checked = false;
                    });
                    
                    // Select the clicked option
                    element.classList.add('selected');
                    radio.checked = true;
                }
            } else {
                // For multiple answer questions
                var checkbox = element.querySelector('input[type="checkbox"]');
                
                if (checkbox) {
                    checkbox.checked = !checkbox.checked;
                    
                    if (checkbox.checked) {
                        element.classList.add('selected');
                    } else {
                        element.classList.remove('selected');
                    }
                }
            }
        }

        function restoreSelections() {
            // Restore visual selection state based on checked inputs
            var allOptions = document.querySelectorAll('.option-item');
            
            allOptions.forEach(function(option) {
                var radio = option.querySelector('input[type="radio"]');
                var checkbox = option.querySelector('input[type="checkbox"]');
                
                if ((radio && radio.checked) || (checkbox && checkbox.checked)) {
                    option.classList.add('selected');
                } else {
                    option.classList.remove('selected');
                }
            });
        }

        function updateProgress() {
            var current = parseInt('<%= CurrentQuestionIndex + 1 %>');
            var total = parseInt('<%= TotalQuestions %>');
            var percentage = (current / total) * 100;
            document.getElementById('progressBar').style.width = percentage + '%';
        }

        window.onload = function () {
            updateProgress();
            restoreSelections();
        };
    </script>
</asp:Content>