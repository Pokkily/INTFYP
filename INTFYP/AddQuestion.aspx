<%@ Page Async="true" Title="Add Question" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeFile="AddQuestion.aspx.cs" Inherits="KoreanApp.AddQuestion" %>

<asp:Content ID="AddQuestionContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <!-- Hidden Fields for Form State -->
    <asp:HiddenField ID="hfEditingQuestionId" runat="server" />
    <asp:HiddenField ID="hfEditingLessonId" runat="server" />
    
    <style>
        .form-section {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            margin-bottom: 24px;
            border: 1px solid #e0e0e0;
        }
        
        .form-header {
            color: #212121;
            font-weight: 600;
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .form-label {
            font-weight: 500;
            color: #424242;
            font-size: 14px;
            margin-bottom: 6px;
        }
        
        .form-control, .form-select {
            border-radius: 4px;
            border: 1px solid #e0e0e0;
            padding: 10px 12px;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: #9e9e9e;
            box-shadow: none;
        }
        
        .btn {
            border-radius: 4px;
            font-weight: 500;
            font-size: 14px;
            padding: 10px 20px;
        }
        
        .btn-dark {
            background-color: #212121;
            border-color: #212121;
            color: #ffffff;
        }
        
        .btn-dark:hover {
            background-color: #000000;
            border-color: #000000;
        }
        
        .btn-success {
            background-color: #28a745;
            border-color: #28a745;
        }
        
        .btn-danger {
            background-color: #dc3545;
            border-color: #dc3545;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            border-color: #6c757d;
        }
        
        .question-type-container {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        
        .question-option {
            margin: 10px 0;
            padding: 15px;
            background: white;
            border-radius: 8px;
            border: 1px solid #e0e0e0;
        }
        
        .existing-question {
            background: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            border-left: 4px solid #28a745;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .question-counter {
            background: #212121;
            color: white;
            padding: 8px 15px;
            border-radius: 20px;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 15px;
        }
        
        .upload-area {
            border: 2px dashed #ccc;
            padding: 20px;
            text-align: center;
            border-radius: 8px;
            margin: 10px 0;
            transition: all 0.3s ease;
        }
        
        .upload-area:hover {
            border-color: #212121;
            background-color: #f8f9ff;
        }
        
        .radio-group {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin: 15px 0;
        }
        
        .radio-item {
            background: white;
            padding: 15px 20px;
            border-radius: 8px;
            border: 2px solid #e0e0e0;
            cursor: pointer;
            transition: all 0.3s ease;
            flex: 1;
            min-width: 200px;
        }
        
        .radio-item:hover {
            border-color: #212121;
            background-color: #f8f9ff;
        }
        
        .radio-item input[type="radio"] {
            margin-right: 10px;
        }
        
        .section-header {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 15px;
            border-left: 4px solid #212121;
        }
        
        @media (max-width: 768px) {
            .radio-group {
                flex-direction: column;
            }
            
            .radio-item {
                min-width: auto;
            }
        }
    </style>

    <!-- Header -->
    <div class="form-section">
        <h1 class="form-header">
            <i class="fas fa-graduation-cap me-3"></i>Teacher Question Builder
        </h1>
        <p class="text-muted mb-0">Create interactive lessons with multiple question types</p>
    </div>

    <!-- Message Display -->
    <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false" />

    <!-- Language Selection -->
    <div class="form-section">
        <h3 class="form-header">
            <i class="fas fa-globe me-2"></i>Step 1: Select Language
        </h3>
        <div class="row">
            <div class="col-md-6">
                <label for="ddlLanguage" class="form-label">Choose Language</label>
                <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="form-select" AutoPostBack="true" 
                    OnSelectedIndexChanged="ddlLanguage_SelectedIndexChanged">
                </asp:DropDownList>
            </div>
        </div>
    </div>

    <!-- Topics Section -->
    <asp:Panel ID="panelTopics" runat="server" Visible="false">
        <div class="form-section">
            <h3 class="form-header">
                <i class="fas fa-folder me-2"></i>Step 2: Select or Create Topic
            </h3>
            <div class="row">
                <div class="col-md-6">
                    <label for="ddlTopic" class="form-label">Choose Topic</label>
                    <asp:DropDownList ID="ddlTopic" runat="server" CssClass="form-select" AutoPostBack="true"
                        OnSelectedIndexChanged="ddlTopic_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
            </div>

            <!-- New Topic Panel -->
            <asp:Panel ID="panelNewTopic" runat="server" Visible="false" CssClass="mt-3">
                <div class="section-header">
                    <h5><i class="fas fa-plus me-2"></i>Create New Topic</h5>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <label for="txtNewTopicName" class="form-label">Topic Name</label>
                        <asp:TextBox ID="txtNewTopicName" runat="server" CssClass="form-control" 
                            placeholder="e.g., Coffee Shop, Travel, Shopping"></asp:TextBox>
                    </div>
                    <div class="col-md-6 d-flex align-items-end">
                        <asp:Button ID="btnCreateTopic" runat="server" Text="Create Topic" 
                            CssClass="btn btn-success" OnClick="btnCreateTopic_Click" />
                    </div>
                </div>
            </asp:Panel>
        </div>
    </asp:Panel>

    <!-- Lessons Section -->
    <asp:Panel ID="panelLessons" runat="server" Visible="false">
        <!-- Existing Lessons Display -->
        <div class="form-section">
            <h3 class="form-header">
                <i class="fas fa-book me-2"></i>Step 3: Existing Lessons
            </h3>
            <asp:Label ID="lblLessonCount" runat="server" CssClass="question-counter" Text="Current Lessons: 0" />
            
            <asp:Repeater ID="rptExistingLessons" runat="server">
                <ItemTemplate>
                    <div class="existing-question">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <strong>Lesson:</strong> <%# Eval("Name") %>
                                <br><small class="text-muted">Created: <%# Eval("CreatedAt") %></small>
                                <%# !string.IsNullOrEmpty(Eval("Description").ToString()) ? "<br><em>" + Eval("Description") + "</em>" : "" %>
                            </div>
                            <div>
                                <asp:Button ID="btnSelectLesson" runat="server" Text="Select" 
                                    CssClass="btn btn-success btn-sm me-2" 
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnClick="btnSelectLesson_Click" />
                                <asp:Button ID="btnEditLesson" runat="server" Text="Edit" 
                                    CssClass="btn btn-secondary btn-sm me-2" 
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnClick="btnEditLesson_Click" />
                                <asp:Button ID="btnDeleteLesson" runat="server" Text="Delete" 
                                    CssClass="btn btn-danger btn-sm" 
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnClick="btnDeleteLesson_Click"
                                    OnClientClick="return confirm('Are you sure you want to delete this lesson and all its questions?');" />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- Add/Edit Lesson Form -->
        <div class="form-section">
            <h3 class="form-header">
                <i class="fas fa-plus me-2"></i><asp:Label ID="lblLessonFormTitle" runat="server" Text="Create New Lesson" />
            </h3>
            
            <div class="row">
                <div class="col-md-6">
                    <label for="txtLessonName" class="form-label">Lesson Name</label>
                    <asp:TextBox ID="txtLessonName" runat="server" CssClass="form-control" 
                        placeholder="e.g., Basic Greetings, Ordering Food"></asp:TextBox>
                </div>
                <div class="col-md-6">
                    <label for="txtLessonDescription" class="form-label">Description (Optional)</label>
                    <asp:TextBox ID="txtLessonDescription" runat="server" CssClass="form-control" 
                        placeholder="Brief description of the lesson"></asp:TextBox>
                </div>
            </div>

            <!-- Save/Cancel Buttons -->
            <div class="d-flex justify-content-end mt-3 gap-2">
                <asp:Button ID="btnCancelLessonEdit" runat="server" Text="Cancel Edit" 
                    CssClass="btn btn-secondary" OnClick="btnCancelLessonEdit_Click" Visible="false" />
                <asp:Button ID="btnSaveLesson" runat="server" Text="Create Lesson" 
                    CssClass="btn btn-success" OnClick="btnSaveLesson_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- Question Form -->
    <asp:Panel ID="panelQuestionForm" runat="server" Visible="false">
        <!-- Existing Questions Display -->
        <div class="form-section">
            <h3 class="form-header">
                <i class="fas fa-list me-2"></i>Existing Questions
            </h3>
            <asp:Label ID="lblQuestionCount" runat="server" CssClass="question-counter" Text="Current Questions: 0" />
            
            <asp:Repeater ID="rptExistingQuestions" runat="server">
                <ItemTemplate>
                    <div class="existing-question">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <strong>Question <%# Eval("Order") %>:</strong> <%# Eval("Text") %>
                                <br><small class="text-muted">Type: <%# Eval("Type") %></small>
                            </div>
                            <div>
                                <asp:Button ID="btnEditQuestion" runat="server" Text="Edit" 
                                    CssClass="btn btn-secondary btn-sm me-2" 
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnClick="btnEditQuestion_Click" />
                                <asp:Button ID="btnDeleteQuestion" runat="server" Text="Delete" 
                                    CssClass="btn btn-danger btn-sm" 
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnClick="btnDeleteQuestion_Click"
                                    OnClientClick="return confirm('Are you sure you want to delete this question?');" />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- Add/Edit Question Form -->
        <div class="form-section">
            <h3 class="form-header">
                <i class="fas fa-plus me-2"></i><asp:Label ID="lblFormTitle" runat="server" Text="Add New Question" />
            </h3>
            
            <!-- Question Text -->
            <div class="row mb-3">
                <div class="col-12">
                    <label for="txtQuestionText" class="form-label">Question Text</label>
                    <asp:TextBox ID="txtQuestionText" runat="server" CssClass="form-control" 
                        placeholder="Enter your question here..." TextMode="MultiLine" Rows="3"></asp:TextBox>
                </div>
            </div>

            <!-- Question Type Selection -->
            <div class="question-type-container">
                <h5>Select Question Type</h5>
                <div class="radio-group">
                    <div class="radio-item">
                        <asp:RadioButton ID="rbTextQuestion" runat="server" GroupName="QuestionType" 
                            Text="Text Question" AutoPostBack="true" OnCheckedChanged="QuestionType_CheckedChanged" />
                        <br><small class="text-muted">Question with text-based multiple choice answers</small>
                    </div>
                    <div class="radio-item">
                        <asp:RadioButton ID="rbImageQuestion" runat="server" GroupName="QuestionType" 
                            Text="Image Question" AutoPostBack="true" OnCheckedChanged="QuestionType_CheckedChanged" />
                        <br><small class="text-muted">Question with an image and text answers</small>
                    </div>
                    <div class="radio-item">
                        <asp:RadioButton ID="rbAudioQuestion" runat="server" GroupName="QuestionType" 
                            Text="Audio Question" AutoPostBack="true" OnCheckedChanged="QuestionType_CheckedChanged" />
                        <br><small class="text-muted">Question with audio and text answers</small>
                    </div>
                </div>
            </div>

            <!-- Image Question Panel -->
            <asp:Panel ID="panelImageQuestion" runat="server" Visible="false">
                <div class="question-option">
                    <h6>Question Image</h6>
                    <div class="upload-area">
                        <i class="fas fa-cloud-upload-alt fa-2x mb-2"></i>
                        <br>
                        <asp:FileUpload ID="fuQuestionImage" runat="server" CssClass="form-control" />
                        <small class="text-muted">Upload an image for this question</small>
                    </div>
                </div>
            </asp:Panel>

            <!-- Audio Question Panel -->
            <asp:Panel ID="panelAudioQuestion" runat="server" Visible="false">
                <div class="question-option">
                    <h6>Question Audio</h6>
                    <div class="upload-area">
                        <i class="fas fa-volume-up fa-2x mb-2"></i>
                        <br>
                        <asp:FileUpload ID="fuQuestionAudio" runat="server" CssClass="form-control" />
                        <small class="text-muted">Upload an audio file for this question</small>
                    </div>
                </div>
            </asp:Panel>

            <!-- Text Options Panel -->
            <asp:Panel ID="panelTextOptions" runat="server" Visible="false">
                <div class="question-option">
                    <h6>Answer Options</h6>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label">Option 1</label>
                            <asp:TextBox ID="txtOption1" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Option 2</label>
                            <asp:TextBox ID="txtOption2" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Option 3</label>
                            <asp:TextBox ID="txtOption3" runat="server" CssClass="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Correct Answer</label>
                            <asp:TextBox ID="txtCorrectAnswer" runat="server" CssClass="form-control" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- Save/Cancel Buttons -->
            <div class="d-flex justify-content-end mt-4 gap-2">
                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel Edit" 
                    CssClass="btn btn-secondary" OnClick="btnCancelEdit_Click" Visible="false" />
                <asp:Button ID="btnSaveQuestion" runat="server" Text="Save Question" 
                    CssClass="btn btn-dark" OnClick="btnSaveQuestion_Click" />
            </div>
        </div>
    </asp:Panel>
</asp:Content>