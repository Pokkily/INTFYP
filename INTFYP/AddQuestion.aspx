<%@ Page Async="true" Title="Add Question" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeFile="AddQuestion.aspx.cs" Inherits="KoreanApp.AddQuestion" %>

<asp:Content ID="AddQuestionContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <asp:HiddenField ID="hfEditingQuestionId" runat="server" />
    <asp:HiddenField ID="hfEditingLessonId" runat="server" />
    
    <style>
        .add-question-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
        }

        .questions-container {
            max-width: 1400px;
            margin: 0 auto;
            position: relative;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            animation: slideInFromTop 1s ease-out;
        }

        .page-title {
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 15px;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }

        .page-subtitle {
            color: rgba(255,255,255,0.8);
            font-size: 16px;
            margin-bottom: 0;
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            margin-bottom: 25px;
            overflow: hidden;
            animation: slideInFromBottom 0.8s ease-out;
        }

        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            font-weight: 700;
            font-size: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-body {
            padding: 25px;
        }

        .form-label {
            font-weight: 600;
            color: #2c3e50;
            font-size: 14px;
            margin-bottom: 8px;
            display: block;
        }

        .form-control, .form-select {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 14px;
            transition: all 0.3s ease;
            width: 100%;
        }

        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.3);
            outline: none;
            transform: scale(1.02);
        }

        .primary-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 24px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
        }

        .primary-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            color: white;
            text-decoration: none;
        }

        .success-button {
            background: linear-gradient(45deg, #56ab2f, #a8e6cf);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 14px;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .success-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(86, 171, 47, 0.3);
            color: white;
        }

        .secondary-button {
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            border: 1px solid rgba(103, 126, 234, 0.3);
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .secondary-button:hover {
            background: #667eea;
            color: white;
            transform: scale(1.05);
            text-decoration: none;
        }

        .danger-button {
            background: linear-gradient(45deg, #ff6b6b, #ee5a52);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .danger-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 107, 107, 0.3);
            color: white;
        }

        .question-type-container {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            backdrop-filter: blur(5px);
            padding: 25px;
            border-radius: 15px;
            margin: 20px 0;
            border: 1px solid rgba(255,255,255,0.2);
        }

        .radio-group {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }

        .radio-item {
            background: rgba(255, 255, 255, 0.9);
            padding: 20px;
            border-radius: 15px;
            border: 2px solid rgba(103, 126, 234, 0.2);
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .radio-item:hover {
            border-color: #667eea;
            background: rgba(255, 255, 255, 1);
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.2);
        }

        .radio-item input[type="radio"] {
            margin-right: 12px;
            transform: scale(1.2);
        }

        .radio-item:before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
            transition: left 0.5s;
        }

        .radio-item:hover:before {
            left: 100%;
        }

        .question-option {
            background: rgba(255, 255, 255, 0.9);
            padding: 20px;
            border-radius: 15px;
            margin: 15px 0;
            border: 1px solid rgba(103, 126, 234, 0.2);
            transition: all 0.3s ease;
        }

        .question-option:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
        }

        .upload-area {
            border: 2px dashed rgba(103, 126, 234, 0.3);
            padding: 30px;
            text-align: center;
            border-radius: 15px;
            margin: 15px 0;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.5);
        }

        .upload-area:hover {
            border-color: #667eea;
            background: rgba(103, 126, 234, 0.05);
            transform: scale(1.02);
        }

        .upload-area i {
            color: #667eea;
            margin-bottom: 10px;
        }

        .existing-item {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 15px;
            border-left: 4px solid #56ab2f;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            animation: slideInFromLeft 0.6s ease-out;
        }

        .existing-item:hover {
            transform: translateX(5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .counter-badge {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .section-header {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            backdrop-filter: blur(5px);
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 20px;
            border-left: 4px solid #667eea;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            position: relative;
        }

        .alert-message {
            background: rgba(86, 171, 47, 0.1);
            border: 1px solid rgba(86, 171, 47, 0.3);
            color: #2d5016;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            animation: slideInFromTop 0.5s ease-out;
        }

        .alert-danger {
            background: rgba(255, 107, 107, 0.1);
            border-color: rgba(255, 107, 107, 0.3);
            color: #721c24;
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

        @keyframes slideInFromLeft {
            from {
                opacity: 0;
                transform: translateX(-50px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @media (max-width: 768px) {
            .radio-group {
                grid-template-columns: 1fr;
                gap: 10px;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .existing-item {
                padding: 15px;
            }
        }

        .mb-0 { margin-bottom: 0; }
        .mb-1 { margin-bottom: 5px; }
        .mb-2 { margin-bottom: 10px; }
        .mb-3 { margin-bottom: 15px; }
        .mb-4 { margin-bottom: 20px; }
        .mt-3 { margin-top: 15px; }
        .mt-4 { margin-top: 20px; }
        .d-flex { display: flex; }
        .justify-content-end { justify-content: flex-end; }
        .justify-content-between { justify-content: space-between; }
        .align-items-center { align-items: center; }
        .align-items-start { align-items: flex-start; }
        .text-center { text-align: center; }
        .gap-2 { gap: 10px; }
        .me-2 { margin-right: 10px; }
    </style>

    <div class="add-question-page">
        <div class="questions-container">
            <div class="page-header">
                <h2 class="page-title">🎓 Interactive Question Builder</h2>
                <p class="page-subtitle">Create engaging lessons with multimedia questions</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert-message" Visible="false" />

            <div class="glass-card">
                <div class="card-header">
                    <i class="fas fa-globe"></i>
                    Step 1: Select Language
                </div>
                <div class="card-body">
                    <div class="form-group">
                        <label for="ddlLanguage" class="form-label">
                            <i class="fas fa-language me-1"></i>
                            Choose Language
                        </label>
                        <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="form-select" AutoPostBack="true" 
                            OnSelectedIndexChanged="ddlLanguage_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>

            <asp:Panel ID="panelTopics" runat="server" Visible="false">
                <div class="glass-card">
                    <div class="card-header">
                        <i class="fas fa-folder"></i>
                        Step 2: Select or Create Topic
                    </div>
                    <div class="card-body">
                        <div class="form-group mb-4">
                            <label for="ddlTopic" class="form-label">
                                <i class="fas fa-tags me-1"></i>
                                Choose Topic
                            </label>
                            <asp:DropDownList ID="ddlTopic" runat="server" CssClass="form-select" AutoPostBack="true"
                                OnSelectedIndexChanged="ddlTopic_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>

                        <asp:Panel ID="panelNewTopic" runat="server" Visible="false">
                            <div class="section-header">
                                <h5 class="mb-2">
                                    <i class="fas fa-plus-circle me-2"></i>
                                    Create New Topic
                                </h5>
                            </div>
                            <div class="form-grid">
                                <div class="form-group">
                                    <label for="txtNewTopicName" class="form-label">Topic Name</label>
                                    <asp:TextBox ID="txtNewTopicName" runat="server" CssClass="form-control" 
                                        placeholder="e.g., Coffee Shop, Travel, Shopping"></asp:TextBox>
                                </div>
                                <div class="form-group d-flex align-items-end">
                                    <asp:Button ID="btnCreateTopic" runat="server" Text="✨ Create Topic" 
                                        CssClass="success-button" OnClick="btnCreateTopic_Click" />
                                </div>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="panelLessons" runat="server" Visible="false">
                <div class="glass-card">
                    <div class="card-header">
                        <i class="fas fa-book"></i>
                        Step 3: Existing Lessons
                    </div>
                    <div class="card-body">
                        <asp:Label ID="lblLessonCount" runat="server" CssClass="counter-badge" Text="Current Lessons: 0" />
                        
                        <asp:Repeater ID="rptExistingLessons" runat="server">
                            <ItemTemplate>
                                <div class="existing-item">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <strong><%# Eval("Name") %></strong>
                                            <br><small style="color: #7f8c8d;">Created: <%# Eval("CreatedAt") %></small>
                                            <%# !string.IsNullOrEmpty(Eval("Description").ToString()) ? "<br><em style='color: #95a5a6;'>" + Eval("Description") + "</em>" : "" %>
                                        </div>
                                        <div class="d-flex gap-2">
                                            <asp:Button ID="btnSelectLesson" runat="server" Text="📝 Select" 
                                                CssClass="success-button" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                OnClick="btnSelectLesson_Click" />
                                            <asp:Button ID="btnEditLesson" runat="server" Text="✏️ Edit" 
                                                CssClass="secondary-button" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                OnClick="btnEditLesson_Click" />
                                            <asp:Button ID="btnDeleteLesson" runat="server" Text="🗑️ Delete" 
                                                CssClass="danger-button" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                OnClick="btnDeleteLesson_Click"
                                                OnClientClick="return confirm('Are you sure you want to delete this lesson and all its questions?');" />
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="glass-card">
                    <div class="card-header">
                        <i class="fas fa-plus-circle"></i>
                        <asp:Label ID="lblLessonFormTitle" runat="server" Text="Create New Lesson" />
                    </div>
                    <div class="card-body">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="txtLessonName" class="form-label">
                                    <i class="fas fa-book-open me-1"></i>
                                    Lesson Name
                                </label>
                                <asp:TextBox ID="txtLessonName" runat="server" CssClass="form-control" 
                                    placeholder="e.g., Basic Greetings, Ordering Food"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label for="txtLessonDescription" class="form-label">
                                    <i class="fas fa-align-left me-1"></i>
                                    Description (Optional)
                                </label>
                                <asp:TextBox ID="txtLessonDescription" runat="server" CssClass="form-control" 
                                    placeholder="Brief description of the lesson"></asp:TextBox>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end mt-3 gap-2">
                            <asp:Button ID="btnCancelLessonEdit" runat="server" Text="❌ Cancel Edit" 
                                CssClass="secondary-button" OnClick="btnCancelLessonEdit_Click" Visible="false" />
                            <asp:Button ID="btnSaveLesson" runat="server" Text="✨ Create Lesson" 
                                CssClass="success-button" OnClick="btnSaveLesson_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="panelQuestionForm" runat="server" Visible="false">
                <div class="glass-card">
                    <div class="card-header">
                        <i class="fas fa-list-ul"></i>
                        Existing Questions
                    </div>
                    <div class="card-body">
                        <asp:Label ID="lblQuestionCount" runat="server" CssClass="counter-badge" Text="Current Questions: 0" />
                        
                        <asp:Repeater ID="rptExistingQuestions" runat="server">
                            <ItemTemplate>
                                <div class="existing-item">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <strong>Question <%# Eval("Order") %>:</strong> <%# Eval("Text") %>
                                            <br><small style="color: #7f8c8d;">Type: <%# Eval("Type") %></small>
                                        </div>
                                        <div class="d-flex gap-2">
                                            <asp:Button ID="btnEditQuestion" runat="server" Text="✏️ Edit" 
                                                CssClass="secondary-button" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                OnClick="btnEditQuestion_Click" />
                                            <asp:Button ID="btnDeleteQuestion" runat="server" Text="🗑️ Delete" 
                                                CssClass="danger-button" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                OnClick="btnDeleteQuestion_Click"
                                                OnClientClick="return confirm('Are you sure you want to delete this question?');" />
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="glass-card">
                    <div class="card-header">
                        <i class="fas fa-question-circle"></i>
                        <asp:Label ID="lblFormTitle" runat="server" Text="Add New Question" />
                    </div>
                    <div class="card-body">
                        <div class="form-group mb-4">
                            <label for="txtQuestionText" class="form-label">
                                <i class="fas fa-comment-alt me-1"></i>
                                Question Text
                            </label>
                            <asp:TextBox ID="txtQuestionText" runat="server" CssClass="form-control" 
                                placeholder="Enter your question here..." TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </div>

                        <div class="question-type-container">
                            <h5 class="mb-3">
                                <i class="fas fa-cogs me-2"></i>
                                Select Question Type
                            </h5>
                            <div class="radio-group">
                                <div class="radio-item">
                                    <asp:RadioButton ID="rbTextQuestion" runat="server" GroupName="QuestionType" 
                                        Text="📝 Text Question" AutoPostBack="true" OnCheckedChanged="QuestionType_CheckedChanged" />
                                    <br><small style="color: #7f8c8d;">Question with text-based multiple choice answers</small>
                                </div>
                                <div class="radio-item">
                                    <asp:RadioButton ID="rbImageQuestion" runat="server" GroupName="QuestionType" 
                                        Text="🖼️ Image Question" AutoPostBack="true" OnCheckedChanged="QuestionType_CheckedChanged" />
                                    <br><small style="color: #7f8c8d;">Question with an image and text answers</small>
                                </div>
                                <div class="radio-item">
                                    <asp:RadioButton ID="rbAudioQuestion" runat="server" GroupName="QuestionType" 
                                        Text="🎵 Audio Question" AutoPostBack="true" OnCheckedChanged="QuestionType_CheckedChanged" />
                                    <br><small style="color: #7f8c8d;">Question with audio and text answers</small>
                                </div>
                            </div>
                        </div>

                        <asp:Panel ID="panelImageQuestion" runat="server" Visible="false">
                            <div class="question-option">
                                <h6 class="mb-3">
                                    <i class="fas fa-image me-1"></i>
                                    Question Image
                                </h6>
                                <div class="upload-area">
                                    <i class="fas fa-cloud-upload-alt fa-2x mb-2"></i>
                                    <br>
                                    <asp:FileUpload ID="fuQuestionImage" runat="server" CssClass="form-control" />
                                    <small style="color: #7f8c8d;">Upload an image for this question</small>
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="panelAudioQuestion" runat="server" Visible="false">
                            <div class="question-option">
                                <h6 class="mb-3">
                                    <i class="fas fa-volume-up me-1"></i>
                                    Question Audio
                                </h6>
                                <div class="upload-area">
                                    <i class="fas fa-microphone fa-2x mb-2"></i>
                                    <br>
                                    <asp:FileUpload ID="fuQuestionAudio" runat="server" CssClass="form-control" />
                                    <small style="color: #7f8c8d;">Upload an audio file for this question</small>
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="panelTextOptions" runat="server" Visible="false">
                            <div class="question-option">
                                <h6 class="mb-3">
                                    <i class="fas fa-list-ol me-1"></i>
                                    Answer Options
                                </h6>
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label class="form-label">Option 1</label>
                                        <asp:TextBox ID="txtOption1" runat="server" CssClass="form-control" 
                                                   placeholder="First answer option" />
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Option 2</label>
                                        <asp:TextBox ID="txtOption2" runat="server" CssClass="form-control" 
                                                   placeholder="Second answer option" />
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Option 3</label>
                                        <asp:TextBox ID="txtOption3" runat="server" CssClass="form-control" 
                                                   placeholder="Third answer option" />
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">
                                            <i class="fas fa-check-circle me-1"></i>
                                            Correct Answer
                                        </label>
                                        <asp:TextBox ID="txtCorrectAnswer" runat="server" CssClass="form-control" 
                                                   placeholder="Enter the correct answer" />
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>

                        <div class="d-flex justify-content-end mt-4 gap-2">
                            <asp:Button ID="btnCancelEdit" runat="server" Text="❌ Cancel Edit" 
                                CssClass="secondary-button" OnClick="btnCancelEdit_Click" Visible="false" />
                            <asp:Button ID="btnSaveQuestion" runat="server" Text="💾 Save Question" 
                                CssClass="primary-button" OnClick="btnSaveQuestion_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            setTimeout(function () {
                var alert = document.querySelector('.alert-message');
                if (alert) {
                    alert.style.opacity = '0';
                    alert.style.transform = 'translateY(-20px)';
                    alert.style.transition = 'all 0.5s ease';
                    setTimeout(function () {
                        alert.style.display = 'none';
                    }, 500);
                }
            }, 5000);

            const radioItems = document.querySelectorAll('.radio-item');
            radioItems.forEach(item => {
                item.addEventListener('click', function() {
                    radioItems.forEach(r => r.classList.remove('active'));
                    this.classList.add('active');
                    
                    const radio = this.querySelector('input[type="radio"]');
                    if (radio) radio.checked = true;
                });
            });

            const existingItems = document.querySelectorAll('.existing-item');
            existingItems.forEach((item, index) => {
                item.style.animationDelay = `${index * 0.1}s`;
            });

            const inputs = document.querySelectorAll('.form-control, .form-select');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.style.transform = 'scale(1.02)';
                });

                input.addEventListener('blur', function () {
                    this.style.transform = 'scale(1)';
                });
            });

            const uploadAreas = document.querySelectorAll('.upload-area');
            uploadAreas.forEach(area => {
                area.addEventListener('dragover', function(e) {
                    e.preventDefault();
                    this.style.backgroundColor = 'rgba(103, 126, 234, 0.1)';
                    this.style.transform = 'scale(1.02)';
                });

                area.addEventListener('dragleave', function(e) {
                    this.style.backgroundColor = 'rgba(255, 255, 255, 0.5)';
                    this.style.transform = 'scale(1)';
                });

                area.addEventListener('drop', function(e) {
                    e.preventDefault();
                    this.style.backgroundColor = 'rgba(255, 255, 255, 0.5)';
                    this.style.transform = 'scale(1)';
                });
            });
        });
    </script>
</asp:Content>