<%@ Page Async="true" Title="Take Quiz" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="TakeQuiz.aspx.cs" Inherits="INTFYP.TakeQuiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Take Quiz
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Quiz Page with Library Design System */
        
        .quiz-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        .quiz-page::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(120, 119, 198, 0.2) 0%, transparent 50%);
            animation: backgroundFloat 20s ease-in-out infinite;
            z-index: -1;
        }

        @keyframes backgroundFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-20px, -20px) rotate(1deg); }
            50% { transform: translate(20px, -10px) rotate(-1deg); }
            75% { transform: translate(-10px, 10px) rotate(0.5deg); }
        }

        .quiz-container {
            max-width: 900px;
            margin: 0 auto;
            position: relative;
        }

        .page-header {
            text-align: center;
            margin-bottom: 30px;
            animation: slideInFromTop 1s ease-out;
        }

        @keyframes slideInFromTop {
            from { 
                opacity: 0; 
                transform: translateY(-50px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .page-title {
            font-size: clamp(24px, 4vw, 36px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 10px;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            position: relative;
            display: inline-block;
        }

        .page-title::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 4px;
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            border-radius: 2px;
            animation: expandWidth 1.5s ease-out 0.5s both;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 60px; }
        }

        .lesson-info-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 20px;
            margin-bottom: 25px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            animation: slideInFromTop 0.8s ease-out 0.2s both;
            text-align: center;
        }

        .lesson-title {
            font-size: 20px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 5px;
        }

        .lesson-details {
            color: #7f8c8d;
            font-size: 14px;
            margin-bottom: 15px;
        }

        .progress-container {
            background: rgba(255, 255, 255, 0.3);
            border-radius: 20px;
            height: 8px;
            overflow: hidden;
            margin: 15px 0;
            position: relative;
        }

        .progress-bar {
            background: linear-gradient(90deg, #667eea, #764ba2);
            height: 100%;
            border-radius: 20px;
            transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .progress-bar::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: shimmer 2s infinite;
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        .question-counter {
            color: #667eea;
            font-weight: 600;
            font-size: 14px;
            margin-top: 10px;
        }

        /* Quiz Card */
        .quiz-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            animation: slideInFromBottom 0.8s ease-out 0.4s both;
            position: relative;
            overflow: hidden;
        }

        @keyframes slideInFromBottom {
            from { 
                opacity: 0; 
                transform: translateY(50px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .quiz-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .question-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .question-number {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 20px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: 700;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            flex-shrink: 0;
        }

        .question-type-badge {
            background: rgba(78, 205, 196, 0.1);
            color: #4ecdc4;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            border: 1px solid rgba(78, 205, 196, 0.2);
            flex-shrink: 0;
        }

        .question-text {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 25px;
            line-height: 1.5;
            text-align: center;
        }

        .question-media {
            text-align: center;
            margin-bottom: 25px;
        }

        .question-image {
            max-width: 100%;
            max-height: 300px;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
            object-fit: cover;
        }

        .question-audio {
            width: 100%;
            max-width: 400px;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }

        .answer-options {
            display: grid;
            gap: 15px;
            margin-bottom: 30px;
        }

        .answer-option {
            background: rgba(255, 255, 255, 0.9);
            border: 2px solid rgba(103, 126, 234, 0.2);
            border-radius: 15px;
            padding: 18px 20px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            font-size: 16px;
            font-weight: 500;
            color: #2c3e50;
            min-height: 60px;
            display: flex;
            align-items: center;
            text-align: left;
        }

        .answer-option:hover {
            border-color: #667eea;
            background: rgba(103, 126, 234, 0.1);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.2);
        }

        .answer-option.selected {
            border-color: #667eea;
            background: linear-gradient(135deg, rgba(103, 126, 234, 0.2), rgba(118, 75, 162, 0.2));
            color: #667eea;
            font-weight: 600;
        }

        .answer-option.correct {
            border-color: #28a745;
            background: linear-gradient(135deg, rgba(40, 167, 69, 0.2), rgba(32, 201, 151, 0.2));
            color: #28a745;
        }

        .answer-option.incorrect {
            border-color: #dc3545;
            background: linear-gradient(135deg, rgba(220, 53, 69, 0.2), rgba(255, 107, 107, 0.2));
            color: #dc3545;
        }

        .answer-option::before {
            content: '';
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            width: 20px;
            height: 20px;
            border: 2px solid #ddd;
            border-radius: 50%;
            background: white;
            transition: all 0.3s ease;
        }

        .answer-option.selected::before {
            border-color: #667eea;
            background: #667eea;
            box-shadow: inset 0 0 0 3px white;
        }

        .answer-option.correct::before {
            border-color: #28a745;
            background: #28a745;
            content: '✓';
            color: white;
            font-weight: bold;
            font-size: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .answer-option.incorrect::before {
            border-color: #dc3545;
            background: #dc3545;
            content: '✗';
            color: white;
            font-weight: bold;
            font-size: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .option-text {
            margin-left: 35px;
            flex: 1;
        }

        .quiz-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        .action-btn {
            padding: 12px 25px;
            border-radius: 25px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            min-width: 120px;
        }

        .action-btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .action-btn:hover::before {
            width: 300px;
            height: 300px;
        }

        .action-btn:hover {
            transform: translateY(-2px);
        }

        .action-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }

        .action-btn:disabled:hover {
            transform: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .btn-primary:hover {
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .btn-secondary:hover {
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
        }

        .btn-outline {
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            border: 2px solid rgba(103, 126, 234, 0.3);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        .btn-outline:hover {
            background: rgba(103, 126, 234, 0.1);
            border-color: #667eea;
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.2);
        }

        /* Quiz Complete Card */
        .quiz-complete-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
            text-align: center;
            animation: zoomIn 0.8s ease-out;
        }

        @keyframes zoomIn {
            from { 
                opacity: 0; 
                transform: scale(0.8); 
            }
            to { 
                opacity: 1; 
                transform: scale(1); 
            }
        }

        .completion-icon {
            font-size: 64px;
            margin-bottom: 20px;
            animation: bounce 2s infinite;
        }

        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            60% { transform: translateY(-5px); }
        }

        .score-display {
            font-size: 48px;
            font-weight: 700;
            background: linear-gradient(45deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin: 20px 0;
        }

        .score-message {
            font-size: 18px;
            color: #2c3e50;
            margin-bottom: 30px;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .quiz-page {
                padding: 20px 15px;
            }

            .quiz-card {
                padding: 20px;
            }

            .question-header {
                justify-content: center;
                text-align: center;
            }

            .quiz-actions {
                justify-content: center;
            }

            .action-btn {
                min-width: 100px;
                padding: 10px 20px;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 24px;
            }

            .answer-options {
                gap: 10px;
            }

            .answer-option {
                padding: 15px;
                font-size: 14px;
            }

            .option-text {
                margin-left: 30px;
            }
        }

        /* Loading states */
        .quiz-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }
    </style>

    <div class="quiz-page">
        <div class="quiz-container">
            <div class="page-header">
                <h2 class="page-title">
                    <asp:Label ID="lblQuizTitle" runat="server" Text="Quiz Time!" />
                </h2>
            </div>

            <!-- Lesson Info Card -->
            <div class="lesson-info-card">
                <div class="lesson-title">
                    <asp:Label ID="lblLessonName" runat="server" Text="Lesson Name" />
                </div>
                <div class="lesson-details">
                    <asp:Label ID="lblTopicName" runat="server" Text="Topic" /> • 
                    <asp:Label ID="lblLanguageName" runat="server" Text="Language" />
                </div>
                
                <div class="progress-container">
                    <div class="progress-bar" id="progressBar" style="width: 0%"></div>
                </div>
                
                <div class="question-counter">
                    Question <asp:Label ID="lblCurrentQuestion" runat="server" Text="1" /> of 
                    <asp:Label ID="lblTotalQuestions" runat="server" Text="10" />
                </div>
            </div>

            <!-- Quiz Content -->
            <asp:Panel ID="pnlQuizContent" runat="server" Visible="true">
                <div class="quiz-card">
                    <div class="question-header">
                        <div class="question-number">
                            Question <asp:Label ID="lblQuestionNumber" runat="server" Text="1" />
                        </div>
                        <div class="question-type-badge">
                            <asp:Label ID="lblQuestionType" runat="server" Text="Text" />
                        </div>
                    </div>

                    <div class="question-text">
                        <asp:Label ID="lblQuestionText" runat="server" Text="Question will appear here..." />
                    </div>

                    <!-- Media Panel -->
                    <asp:Panel ID="pnlQuestionMedia" runat="server" CssClass="question-media" Visible="false">
                        <asp:Image ID="imgQuestion" runat="server" CssClass="question-image" Visible="false" />
                        
                        <audio id="audioQuestion" runat="server" controls class="question-audio" visible="false">
                            <source id="audioSource" runat="server" type="audio/mpeg">
                            Your browser does not support the audio element.
                        </audio>
                    </asp:Panel>

                    <!-- Answer Options -->
                    <div class="answer-options" id="answerContainer">
                        <asp:Repeater ID="rptAnswerOptions" runat="server">
                            <ItemTemplate>
                                <div class="answer-option" onclick="selectAnswer(this, '<%# HttpUtility.HtmlEncode(Container.DataItem.ToString()) %>')">
                                    <div class="option-text"><%# HttpUtility.HtmlEncode(Container.DataItem.ToString()) %></div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <!-- Quiz Actions -->
                    <div class="quiz-actions">
                        <asp:Button ID="btnPrevious" runat="server" Text="⬅️ Previous" 
                            CssClass="action-btn btn-outline" OnClick="btnPrevious_Click" Visible="false" />
                        
                        <div style="flex: 1;"></div>
                        
                        <asp:Button ID="btnNext" runat="server" Text="Next ➡️" 
                            CssClass="action-btn btn-primary" OnClick="btnNext_Click" Enabled="false" />
                        <asp:Button ID="btnSubmit" runat="server" Text="🎯 Submit Quiz" 
                            CssClass="action-btn btn-secondary" OnClick="btnSubmit_Click" Visible="false" Enabled="false" />
                    </div>
                </div>
            </asp:Panel>

            <!-- Quiz Complete Panel -->
            <asp:Panel ID="pnlQuizComplete" runat="server" Visible="false">
                <div class="quiz-complete-card">
                    <div class="completion-icon">🎉</div>
                    <h3 style="color: #2c3e50; margin-bottom: 20px;">Quiz Complete!</h3>
                    
                    <div class="score-display">
                        <asp:Label ID="lblScore" runat="server" Text="0" />%
                    </div>
                    
                    <div class="score-message">
                        <asp:Label ID="lblScoreMessage" runat="server" Text="Great job!" />
                    </div>
                    
                    <div class="quiz-actions">
                        <asp:Button ID="btnRetryQuiz" runat="server" Text="🔄 Try Again" 
                            CssClass="action-btn btn-outline" OnClick="btnRetryQuiz_Click" />
                        <asp:Button ID="btnBackToLessons" runat="server" Text="📚 Back to Lessons" 
                            CssClass="action-btn btn-primary" OnClick="btnBackToLessons_Click" />
                        <asp:Button ID="btnNextLesson" runat="server" Text="Next Lesson ➡️" 
                            CssClass="action-btn btn-secondary" OnClick="btnNextLesson_Click" Visible="false" />
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <!-- Hidden Fields for State Management -->
    <asp:HiddenField ID="hfCurrentQuestionIndex" runat="server" Value="0" />
    <asp:HiddenField ID="hfSelectedAnswer" runat="server" />
    <asp:HiddenField ID="hfUserAnswers" runat="server" />
    <asp:HiddenField ID="hfQuestionData" runat="server" />

    <script>
        let selectedAnswerElement = null;

        function selectAnswer(element, answerText) {
            console.log('🖱️ Answer selected:', answerText);

            // Remove previous selection
            if (selectedAnswerElement) {
                selectedAnswerElement.classList.remove('selected');
            }

            // Select new answer
            element.classList.add('selected');
            selectedAnswerElement = element;

            // Store selected answer
            const hiddenField = document.getElementById('<%= hfSelectedAnswer.ClientID %>');
            if (hiddenField) {
                hiddenField.value = answerText;
                console.log('💾 Answer stored in hidden field:', answerText);
            } else {
                console.log('❌ Hidden field not found!');
            }

            // Enable next/submit buttons
            const nextBtn = document.getElementById('<%= btnNext.ClientID %>');
            const submitBtn = document.getElementById('<%= btnSubmit.ClientID %>');

            if (nextBtn && nextBtn.style.display !== 'none') {
                nextBtn.disabled = false;
                nextBtn.style.opacity = '1';
                console.log('✅ Next button enabled');
            }

            if (submitBtn && submitBtn.style.display !== 'none') {
                submitBtn.disabled = false;
                submitBtn.style.opacity = '1';
                console.log('✅ Submit button enabled');
            }
        }

        function updateProgress() {
            try {
                const currentElement = document.getElementById('<%= lblCurrentQuestion.ClientID %>');
                const totalElement = document.getElementById('<%= lblTotalQuestions.ClientID %>');
                
                if (currentElement && totalElement) {
                    const current = parseInt(currentElement.innerText);
                    const total = parseInt(totalElement.innerText);
                    const percentage = ((current - 1) / total) * 100;
                    
                    const progressBar = document.getElementById('progressBar');
                    if (progressBar) {
                        progressBar.style.width = percentage + '%';
                        console.log('📊 Progress updated:', percentage + '%');
                    }
                }
            } catch (e) {
                console.log('❌ Error updating progress:', e);
            }
        }

        // Enhanced form submission handling
        function handleFormSubmission() {
            const selectedAnswer = document.getElementById('<%= hfSelectedAnswer.ClientID %>').value;
            
            if (!selectedAnswer) {
                alert('Please select an answer before proceeding.');
                return false;
            }
            
            console.log('📤 Form submitting with answer:', selectedAnswer);
            return true;
        }

        // Update progress on page load
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🚀 Page loaded, initializing...');
            
            updateProgress();
            
            // Debug: Check if answer options are loaded
            const options = document.querySelectorAll('.answer-option');
            console.log('Found ' + options.length + ' answer options');
            
            if (options.length === 0) {
                console.log('❌ No answer options found! Check Repeater binding.');
            }
            
            // Add smooth transitions to answer options
            options.forEach((option, index) => {
                option.style.animationDelay = (index * 0.1) + 's';
                option.style.animation = 'slideInFromBottom 0.6s ease-out both';
                
                const optionText = option.querySelector('.option-text');
                if (optionText) {
                    console.log('Option ' + (index + 1) + ': ' + optionText.innerText);
                }
                
                // Add click event listener as backup
                option.addEventListener('click', function() {
                    const textElement = this.querySelector('.option-text');
                    if (textElement) {
                        selectAnswer(this, textElement.innerText);
                    }
                });
            });
            
            // Check if the answer container exists
            const container = document.getElementById('answerContainer');
            if (container) {
                console.log('✅ Answer container found');
                console.log('Container content preview:', container.innerHTML.substring(0, 200) + '...');
            } else {
                console.log('❌ Answer container NOT found!');
            }
            
            // Debug button states
            const nextBtn = document.getElementById('<%= btnNext.ClientID %>');
            const submitBtn = document.getElementById('<%= btnSubmit.ClientID %>');
            
            console.log('Next button:', nextBtn ? 'Found' : 'Not found');
            console.log('Submit button:', submitBtn ? 'Found' : 'Not found');
            
            if (nextBtn) {
                console.log('Next button visible:', nextBtn.style.display !== 'none');
                console.log('Next button enabled:', !nextBtn.disabled);
            }
            
            if (submitBtn) {
                console.log('Submit button visible:', submitBtn.style.display !== 'none');
                console.log('Submit button enabled:', !submitBtn.disabled);
            }
            
            // Add form submission handlers
            if (nextBtn) {
                nextBtn.addEventListener('click', function(e) {
                    if (!handleFormSubmission()) {
                        e.preventDefault();
                        return false;
                    }
                });
            }
            
            if (submitBtn) {
                submitBtn.addEventListener('click', function(e) {
                    console.log('🎯 Submit button clicked');
                    if (!handleFormSubmission()) {
                        e.preventDefault();
                        return false;
                    }
                    
                    // Add confirmation for final submission
                    if (!confirm('Are you sure you want to submit your quiz? You cannot change your answers after submission.')) {
                        e.preventDefault();
                        return false;
                    }
                    
                    console.log('✅ Quiz submission confirmed');
                });
            }
        });

        // Keyboard navigation
        document.addEventListener('keydown', function(e) {
            const options = document.querySelectorAll('.answer-option');
            
            // Number keys 1-4 for option selection
            if (e.key >= '1' && e.key <= '4') {
                const index = parseInt(e.key) - 1;
                if (options[index]) {
                    const answerText = options[index].querySelector('.option-text').innerText;
                    selectAnswer(options[index], answerText);
                }
            }
            
            // Enter key for submission
            if (e.key === 'Enter') {
                const nextBtn = document.getElementById('<%= btnNext.ClientID %>');
                const submitBtn = document.getElementById('<%= btnSubmit.ClientID %>');
                
                if (nextBtn && !nextBtn.disabled && nextBtn.style.display !== 'none') {
                    nextBtn.click();
                } else if (submitBtn && !submitBtn.disabled && submitBtn.style.display !== 'none') {
                    submitBtn.click();
                }
            }
            
            // Arrow keys for option navigation
            if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
                e.preventDefault();
                
                let currentIndex = -1;
                if (selectedAnswerElement) {
                    currentIndex = Array.from(options).indexOf(selectedAnswerElement);
                }
                
                if (e.key === 'ArrowDown') {
                    currentIndex = (currentIndex + 1) % options.length;
                } else {
                    currentIndex = currentIndex <= 0 ? options.length - 1 : currentIndex - 1;
                }
                
                if (options[currentIndex]) {
                    const answerText = options[currentIndex].querySelector('.option-text').innerText;
                    selectAnswer(options[currentIndex], answerText);
                }
            }
        });

        // Add visual feedback for button states
        function updateButtonVisualStates() {
            const nextBtn = document.getElementById('<%= btnNext.ClientID %>');
            const submitBtn = document.getElementById('<%= btnSubmit.ClientID %>');

            if (nextBtn) {
                if (nextBtn.disabled) {
                    nextBtn.style.opacity = '0.5';
                    nextBtn.style.cursor = 'not-allowed';
                } else {
                    nextBtn.style.opacity = '1';
                    nextBtn.style.cursor = 'pointer';
                }
            }

            if (submitBtn) {
                if (submitBtn.disabled) {
                    submitBtn.style.opacity = '0.5';
                    submitBtn.style.cursor = 'not-allowed';
                } else {
                    submitBtn.style.opacity = '1';
                    submitBtn.style.cursor = 'pointer';
                }
            }
        }

        // Call this periodically to ensure button states are correct
        setInterval(updateButtonVisualStates, 500);

        // Debug function to check quiz state
        function debugQuizState() {
            console.log('🔍 Current Quiz State:');
            console.log('Selected Answer:', document.getElementById('<%= hfSelectedAnswer.ClientID %>').value);
            console.log('Current Question Index:', document.getElementById('<%= hfCurrentQuestionIndex.ClientID %>').value);
            console.log('User Answers:', document.getElementById('<%= hfUserAnswers.ClientID %>').value);

            const options = document.querySelectorAll('.answer-option');
            console.log('Available Options:');
            options.forEach((option, index) => {
                const text = option.querySelector('.option-text').innerText;
                const isSelected = option.classList.contains('selected');
                console.log(`  ${index + 1}. "${text}" ${isSelected ? '(SELECTED)' : ''}`);
            });
        }

        // Make debug function available globally for testing
        window.debugQuizState = debugQuizState;

        console.log('🎯 Quiz JavaScript loaded successfully! Type debugQuizState() in console to check state.');
    </script>

    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>