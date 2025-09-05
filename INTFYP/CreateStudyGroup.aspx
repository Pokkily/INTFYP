<%@ Page Title="Create Study Group" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="CreateStudyGroup.aspx.cs" Inherits="YourProjectNamespace.CreateStudyGroup" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Create Study Group
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Create Study Group Page Design */
        
        .create-group-page {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
            font-family: 'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
        }

        .create-group-container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 25px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }

        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px;
            color: white;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .page-header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: headerFloat 20s ease-in-out infinite;
        }

        @keyframes headerFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-10px, -10px) rotate(1deg); }
            50% { transform: translate(10px, -5px) rotate(-1deg); }
            75% { transform: translate(-5px, 5px) rotate(0.5deg); }
        }

        .page-title {
            font-size: 36px;
            font-weight: 800;
            margin: 0;
            text-shadow: 0 4px 8px rgba(0,0,0,0.3);
            position: relative;
            z-index: 1;
        }

        .page-subtitle {
            font-size: 18px;
            margin-top: 10px;
            opacity: 0.9;
            position: relative;
            z-index: 1;
        }

        .form-container {
            padding: 40px;
        }

        .form-section {
            margin-bottom: 40px;
        }

        .section-title {
            font-size: 20px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #667eea;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-control {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s ease;
            background: #f8f9fa;
            margin-bottom: 15px;
        }

        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(103, 126, 234, 0.1);
            background: white;
            outline: none;
        }

        .form-label {
            display: block;
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
            font-size: 15px;
        }

        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-col {
            flex: 1;
        }

        .checkbox-group {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-top: 15px;
        }

        .checkbox-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            background: #f8f9fa;
            border-radius: 10px;
            border: 2px solid #e9ecef;
            transition: all 0.3s ease;
            cursor: pointer;
            min-width: 180px;
        }

        .checkbox-item:hover {
            border-color: #667eea;
            background: rgba(103, 126, 234, 0.05);
        }

        .checkbox-item input[type="checkbox"] {
            width: 18px;
            height: 18px;
            accent-color: #667eea;
        }

        .file-upload-section {
            border: 2px dashed #dee2e6;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            background: #f8f9fa;
            transition: all 0.3s ease;
            cursor: pointer;
            margin-top: 15px;
        }

        .file-upload-section:hover {
            border-color: #667eea;
            background: rgba(103, 126, 234, 0.05);
        }

        .file-upload-icon {
            font-size: 48px;
            color: #6c757d;
            margin-bottom: 15px;
        }

        .file-upload-text {
            color: #6c757d;
            font-size: 16px;
        }

        .tags-input-container {
            position: relative;
            margin-top: 15px;
        }

        .tags-display {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 10px;
        }

        .tag-item {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .tag-remove {
            background: rgba(255, 255, 255, 0.3);
            border: none;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            cursor: pointer;
            color: white;
            font-size: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .action-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px solid #f1f3f4;
        }

        .btn-create {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 16px 40px;
            border-radius: 30px;
            font-weight: 700;
            font-size: 18px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            position: relative;
            overflow: hidden;
        }

        .btn-create::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.8s ease;
        }

        .btn-create:hover::before {
            width: 350px;
            height: 350px;
        }

        .btn-create:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(103, 126, 234, 0.5);
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
            border: none;
            padding: 16px 40px;
            border-radius: 30px;
            font-weight: 700;
            font-size: 18px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 8px 25px rgba(108, 117, 125, 0.3);
        }

        .btn-cancel:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(108, 117, 125, 0.4);
        }

        .help-text {
            font-size: 14px;
            color: #6c757d;
            margin-top: 8px;
            line-height: 1.4;
        }

        .character-count {
            font-size: 12px;
            color: #6c757d;
            text-align: right;
            margin-top: 5px;
        }

        @media (max-width: 768px) {
            .create-group-page {
                padding: 20px 15px;
            }

            .form-container {
                padding: 30px 25px;
            }

            .page-header {
                padding: 30px 25px;
            }

            .page-title {
                font-size: 28px;
            }

            .form-row {
                flex-direction: column;
                gap: 0;
            }

            .checkbox-group {
                flex-direction: column;
                gap: 10px;
            }

            .checkbox-item {
                min-width: auto;
            }

            .action-buttons {
                flex-direction: column;
                align-items: center;
            }
        }

        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }

        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }

        .alert-warning {
            color: #856404;
            background-color: #fff3cd;
            border-color: #ffeaa7;
        }
    </style>

    <div class="create-group-page">
        <div class="create-group-container">
            <div class="page-header">
                <h1 class="page-title">🎓 Create New Study Group</h1>
                <p class="page-subtitle">Build a community of learners and achieve your academic goals together</p>
            </div>

            <div class="form-container">
                <!-- Message Panel -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <asp:Literal ID="ltMessage" runat="server" />
                </asp:Panel>

                <!-- Basic Information Section -->
                <div class="form-section">
                    <h3 class="section-title">📝 Basic Information</h3>
                    
                    <label class="form-label" for="<%= txtGroupName.ClientID %>">Group Name *</label>
                    <asp:TextBox ID="txtGroupName" runat="server" CssClass="form-control" 
                        placeholder="Enter a catchy name for your study group" MaxLength="100" />
                    <div class="help-text">Choose a name that clearly represents your group's focus</div>

                    <div class="form-row">
                        <div class="form-col">
                            <label class="form-label" for="<%= ddlSubject.ClientID %>">Subject *</label>
                            <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Select Subject" Value="" />
                                <asp:ListItem Text="Mathematics" Value="Mathematics" />
                                <asp:ListItem Text="Science" Value="Science" />
                                <asp:ListItem Text="Programming" Value="Programming" />
                                <asp:ListItem Text="Languages" Value="Languages" />
                                <asp:ListItem Text="History" Value="History" />
                                <asp:ListItem Text="Business" Value="Business" />
                                <asp:ListItem Text="Arts" Value="Arts" />
                                <asp:ListItem Text="Medicine" Value="Medicine" />
                                <asp:ListItem Text="Engineering" Value="Engineering" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                        </div>
                        <div class="form-col">
                            <label class="form-label" for="<%= txtCapacity.ClientID %>">Group Capacity *</label>
                            <asp:TextBox ID="txtCapacity" runat="server" CssClass="form-control" 
                                placeholder="Max members" TextMode="Number" />
                            <div class="help-text">Maximum 100 members</div>
                        </div>
                    </div>

                    <label class="form-label" for="<%= txtDescription.ClientID %>">Description *</label>
                    <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" CssClass="form-control" 
                        Rows="4" placeholder="Describe what your group will study, goals, and expectations..." 
                        MaxLength="500" />
                    <div class="character-count">0/500 characters</div>
                </div>

                <!-- Group Settings Section -->
                <div class="form-section">
                    <h3 class="section-title">⚙️ Group Settings</h3>
                    
                    <div class="checkbox-group">
                        <div class="checkbox-item">
                            <asp:CheckBox ID="chkPublic" runat="server" />
                            <label for="<%= chkPublic.ClientID %>">🌍 Public Group</label>
                        </div>
                        <div class="checkbox-item">
                            <asp:CheckBox ID="chkRequireApproval" runat="server" />
                            <label for="<%= chkRequireApproval.ClientID %>">✋ Require Approval</label>
                        </div>
                        <div class="checkbox-item">
                            <asp:CheckBox ID="chkAllowInvites" runat="server" />
                            <label for="<%= chkAllowInvites.ClientID %>">📧 Allow Invites</label>
                        </div>
                    </div>
                </div>

                <!-- Study Methods Section -->
                <div class="form-section">
                    <h3 class="section-title">📚 Study Methods</h3>
                    
                    <div class="checkbox-group">
                        <div class="checkbox-item">
                            <asp:CheckBox ID="chkOnlineStudy" runat="server" />
                            <label for="<%= chkOnlineStudy.ClientID %>">💻 Online Sessions</label>
                        </div>
                        <div class="checkbox-item">
                            <asp:CheckBox ID="chkInPersonStudy" runat="server" />
                            <label for="<%= chkInPersonStudy.ClientID %>">🤝 In-Person Meetings</label>
                        </div>
                        <div class="checkbox-item">
                            <asp:CheckBox ID="chkResourceSharing" runat="server" />
                            <label for="<%= chkResourceSharing.ClientID %>">📁 Resource Sharing</label>
                        </div>
                        <div class="checkbox-item">
                            <asp:CheckBox ID="chkPeerTutoring" runat="server" />
                            <label for="<%= chkPeerTutoring.ClientID %>">👥 Peer Tutoring</label>
                        </div>
                    </div>
                </div>

                <!-- Meeting Schedule Section -->
                <div class="form-section">
                    <h3 class="section-title">📅 Meeting Schedule</h3>
                    
                    <div class="form-row">
                        <div class="form-col">
                            <label class="form-label" for="<%= ddlMeetingFrequency.ClientID %>">Meeting Frequency</label>
                            <asp:DropDownList ID="ddlMeetingFrequency" runat="server" CssClass="form-control">
                                <asp:ListItem Text="No Regular Meetings" Value="none" />
                                <asp:ListItem Text="Daily" Value="daily" />
                                <asp:ListItem Text="Weekly" Value="weekly" />
                                <asp:ListItem Text="Bi-weekly" Value="biweekly" />
                                <asp:ListItem Text="Monthly" Value="monthly" />
                                <asp:ListItem Text="As Needed" Value="as_needed" />
                            </asp:DropDownList>
                        </div>
                        <div class="form-col">
                            <label class="form-label" for="<%= txtMeetingTime.ClientID %>">Preferred Meeting Time</label>
                            <asp:TextBox ID="txtMeetingTime" runat="server" CssClass="form-control" 
                                placeholder="e.g., Weekdays 7-9 PM EST" />
                        </div>
                    </div>
                </div>

                <!-- Group Image Section -->
                <div class="form-section">
                    <h3 class="section-title">🖼️ Group Image</h3>
                    
                    <div class="file-upload-section" onclick="document.getElementById('<%= fileGroupImage.ClientID %>').click();">
                        <div class="file-upload-icon">📸</div>
                        <div class="file-upload-text">
                            <strong>Click to upload group image</strong><br>
                            <small>Supports: JPG, PNG, GIF (Max 5MB)</small>
                        </div>
                        <asp:FileUpload ID="fileGroupImage" runat="server" accept="image/*" style="display: none;" />
                    </div>
                </div>

                <!-- Tags Section -->
                <div class="form-section">
                    <h3 class="section-title">🏷️ Tags</h3>
                    
                    <label class="form-label">Add Tags (Optional)</label>
                    <div class="tags-input-container">
                        <input type="text" class="form-control" placeholder="Enter tags separated by commas" 
                               id="tagsInput" onkeyup="updateTags()" />
                        <asp:HiddenField ID="hfTags" runat="server" />
                        <div class="tags-display" id="tagsDisplay"></div>
                    </div>
                    <div class="help-text">Add relevant keywords to help others find your group (max 10 tags)</div>
                </div>

                <!-- Action Buttons -->
                <div class="action-buttons">
                    <asp:Button ID="btnCancel" runat="server" Text="❌ Cancel" CssClass="btn-cancel" OnClick="btnCancel_Click" />
                    <asp:Button ID="btnCreate" runat="server" Text="🚀 Create Group" CssClass="btn-create" OnClick="btnCreate_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        // Character counter for description
        document.addEventListener('DOMContentLoaded', function () {
            const descriptionTextbox = document.getElementById('<%= txtDescription.ClientID %>');
            const charCount = document.querySelector('.character-count');

            if (descriptionTextbox && charCount) {
                descriptionTextbox.addEventListener('input', function () {
                    const count = this.value.length;
                    charCount.textContent = count + '/500 characters';

                    if (count > 450) {
                        charCount.style.color = '#dc3545';
                    } else if (count > 400) {
                        charCount.style.color = '#ffc107';
                    } else {
                        charCount.style.color = '#6c757d';
                    }
                });

                // Initialize counter
                const initialCount = descriptionTextbox.value.length;
                charCount.textContent = initialCount + '/500 characters';
            }
        });

        // Tags functionality
        function updateTags() {
            const input = document.getElementById('tagsInput');
            const hiddenField = document.getElementById('<%= hfTags.ClientID %>');
            const display = document.getElementById('tagsDisplay');
            
            const tags = input.value.split(',').map(tag => tag.trim()).filter(tag => tag.length > 0);
            const uniqueTags = [...new Set(tags)].slice(0, 10); // Max 10 unique tags
            
            hiddenField.value = uniqueTags.join(',');
            
            display.innerHTML = uniqueTags.map(tag => 
                `<span class="tag-item">${tag}<button type="button" class="tag-remove" onclick="removeTag('${tag}')">×</button></span>`
            ).join('');
        }

        function removeTag(tagToRemove) {
            const input = document.getElementById('tagsInput');
            const tags = input.value.split(',').map(tag => tag.trim()).filter(tag => tag !== tagToRemove);
            input.value = tags.join(', ');
            updateTags();
        }

        // Form validation
        function validateForm() {
            let isValid = true;
            const errors = [];

            const groupName = document.getElementById('<%= txtGroupName.ClientID %>').value.trim();
            if (!groupName) {
                errors.push('Group name is required');
                isValid = false;
            }

            const subject = document.getElementById('<%= ddlSubject.ClientID %>').value;
            if (!subject) {
                errors.push('Please select a subject');
                isValid = false;
            }

            const capacity = document.getElementById('<%= txtCapacity.ClientID %>').value;
            if (!capacity || capacity < 2 || capacity > 100) {
                errors.push('Capacity must be between 2 and 100');
                isValid = false;
            }

            const description = document.getElementById('<%= txtDescription.ClientID %>').value.trim();
            if (!description || description.length < 10) {
                errors.push('Description must be at least 10 characters');
                isValid = false;
            }

            if (!isValid) {
                alert('Please fix the following errors:\n' + errors.join('\n'));
            }

            return isValid;
        }

        // Auto-save draft functionality
        function saveDraft() {
            const draft = {
                groupName: document.getElementById('<%= txtGroupName.ClientID %>').value,
                subject: document.getElementById('<%= ddlSubject.ClientID %>').value,
                capacity: document.getElementById('<%= txtCapacity.ClientID %>').value,
                description: document.getElementById('<%= txtDescription.ClientID %>').value,
                tags: document.getElementById('<%= hfTags.ClientID %>').value
            };
            
            localStorage.setItem('studyGroupDraft', JSON.stringify(draft));
        }

        function loadDraft() {
            const savedDraft = localStorage.getItem('studyGroupDraft');
            if (savedDraft) {
                const draft = JSON.parse(savedDraft);
                document.getElementById('<%= txtGroupName.ClientID %>').value = draft.groupName || '';
                document.getElementById('<%= ddlSubject.ClientID %>').value = draft.subject || '';
                document.getElementById('<%= txtCapacity.ClientID %>').value = draft.capacity || '';
                document.getElementById('<%= txtDescription.ClientID %>').value = draft.description || '';
                document.getElementById('<%= hfTags.ClientID %>').value = draft.tags || '';
                
                if (draft.tags) {
                    document.getElementById('tagsInput').value = draft.tags.split(',').join(', ');
                    updateTags();
                }
            }
        }

        // Load draft on page load
        document.addEventListener('DOMContentLoaded', function() {
            loadDraft();
            
            // Auto-save every 30 seconds
            setInterval(saveDraft, 30000);
            
            // Save on input changes
            document.querySelectorAll('input, select, textarea').forEach(element => {
                element.addEventListener('change', saveDraft);
            });
        });

        // Attach validation to create button
        document.addEventListener('DOMContentLoaded', function() {
            const createBtn = document.getElementById('<%= btnCreate.ClientID %>');
            if (createBtn) {
                createBtn.addEventListener('click', function (e) {
                    if (!validateForm()) {
                        e.preventDefault();
                        return false;
                    }
                });
            }
        });
    </script>
</asp:Content>