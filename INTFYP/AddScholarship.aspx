<%@ Page Async="true" Title="Add Scholarship" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeFile="AddScholarship.aspx.cs" Inherits="INTFYP.AddScholarship" %>

<asp:Content ID="AddScholarshipContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        /* Modern Design System Implementation */
        .add-scholarship-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
        }

        .scholarships-container {
            max-width: 1200px;
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

        .form-control {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 14px;
            transition: all 0.3s ease;
            width: 100%;
            resize: vertical;
        }

        .form-control:focus {
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
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .success-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(86, 171, 47, 0.3);
            color: white;
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

        /* Scholarship Card Styles with Collapsible Design */
        .scholarship-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.3s ease;
            margin-bottom: 20px;
            animation: slideInFromLeft 0.6s ease-out;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
            position: relative;
        }

        .scholarship-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
            pointer-events: none;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .scholarship-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
        }

        .scholarship-header {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .scholarship-title {
            font-weight: 600;
            font-size: 20px;
            color: #2c3e50;
            margin-bottom: 0;
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1;
        }

        /* Toggle Button (similar to Scholarship page) */
        .toggle-button {
            padding: 10px 18px;
            border-radius: 20px;
            border: 2px solid #667eea;
            background: rgba(103, 126, 234, 0.1);
            color: #667eea;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s ease;
            position: relative;
            overflow: hidden;
            flex-shrink: 0;
            z-index: 10;
            min-width: 120px;
            text-align: center;
        }

        .toggle-button:hover {
            background: rgba(103, 126, 234, 0.2);
            transform: translateY(-1px);
            border-color: #764ba2;
        }

        .toggle-button:active {
            transform: translateY(0);
        }

        .toggle-button.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
            color: white !important;
            border-color: transparent !important;
        }

        /* Custom Collapse Implementation */
        .scholarship-details {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease-in-out, padding 0.4s ease-in-out;
            padding: 0 20px;
        }

        .scholarship-details.show {
            max-height: 2000px;
            padding: 20px;
        }

        .scholarship-section {
            margin-bottom: 20px;
            padding: 15px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 10px;
            border-left: 4px solid #667eea;
            transition: all 0.2s ease;
        }

        .scholarship-section:hover {
            background: rgba(255, 255, 255, 0.8);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .section-title {
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 8px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .section-content {
            color: #555;
            font-size: 14px;
            white-space: pre-line;
            line-height: 1.5;
        }

        .section-content a {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }

        .section-content a:hover {
            text-decoration: underline;
        }

        /* Edit Section */
        .edit-section {
            background: linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.05));
            backdrop-filter: blur(5px);
            border-radius: 15px;
            padding: 20px;
            margin-top: 15px;
            border: 1px solid rgba(255,255,255,0.1);
        }

        .edit-section h5 {
            color: #2c3e50;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            flex-wrap: wrap;
        }

        /* Form Grid */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            position: relative;
        }

        /* Status Messages */
        .status-message {
            background: rgba(86, 171, 47, 0.1);
            border: 1px solid rgba(86, 171, 47, 0.3);
            color: #2d5016;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            animation: slideInFromTop 0.5s ease-out;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* No Data State */
        .no-scholarships {
            text-align: center;
            padding: 60px 20px;
            color: #7f8c8d;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            backdrop-filter: blur(5px);
        }

        .no-scholarships i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        /* Icon Styles */
        .icon-requirement { color: #ff6b6b; }
        .icon-terms { color: #4ecdc4; }
        .icon-courses { color: #45b7d1; }
        .icon-link { color: #96ceb4; }

        /* Summary Preview (shown when collapsed) */
        .scholarship-preview {
            padding: 15px 20px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 10px;
            margin: 15px 20px;
            font-size: 14px;
            color: #666;
            font-style: italic;
        }

        /* Animations */
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

        /* Button Effects */
        .toggle-button.clicked {
            animation: buttonPulse 0.2s ease-out;
        }

        @keyframes buttonPulse {
            0% { transform: scale(1); }
            50% { transform: scale(0.95); }
            100% { transform: scale(1); }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .scholarship-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .form-grid {
                gap: 15px;
            }

            .toggle-button {
                width: 100%;
                min-height: 45px;
            }

            .scholarship-details.show {
                padding: 15px;
            }
        }

        /* Utility Classes */
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
        .text-center { text-align: center; }
        .gap-2 { gap: 10px; }
    </style>

    <div class="add-scholarship-page">
        <div class="scholarships-container">
            <div class="page-header">
                <h2 class="page-title">🎓 Scholarship Manager</h2>
                <p class="page-subtitle">Create and manage scholarship opportunities for students</p>
            </div>

            <!-- Status Message -->
            <asp:Panel ID="pnlStatus" runat="server" Visible="false">
                <div class="status-message">
                    <i class="fas fa-check-circle"></i>
                    <asp:Label ID="lblStatus" runat="server" Text="" />
                </div>
            </asp:Panel>

            <!-- Add Scholarship Form -->
            <div class="glass-card">
                <div class="card-header">
                    <i class="fas fa-plus-circle"></i>
                    Add New Scholarship Opportunity
                </div>
                <div class="card-body">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-graduation-cap me-1"></i>
                                Scholarship Title
                            </label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" 
                                       placeholder="e.g., International Excellence Scholarship 2024" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-clipboard-check me-1 icon-requirement"></i>
                                Requirements
                            </label>
                            <asp:TextBox ID="txtRequirement" runat="server" TextMode="MultiLine" Rows="8" 
                                       CssClass="form-control" 
                                       placeholder="Enter detailed scholarship requirements...

Example:
• Minimum GPA of 3.5
• Full-time enrollment
• Demonstrate financial need
• Submit essay and recommendation letters" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-file-contract me-1 icon-terms"></i>
                                Terms & Conditions
                            </label>
                            <asp:TextBox ID="txtTerms" runat="server" TextMode="MultiLine" Rows="8" 
                                       CssClass="form-control" 
                                       placeholder="Enter terms and conditions...

Example:
• Scholarship amount: $5,000 per year
• Renewable for up to 4 years
• Must maintain 3.0 GPA
• Cannot be combined with other merit scholarships" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-book me-1 icon-courses"></i>
                                Eligible Study Courses
                            </label>
                            <asp:TextBox ID="txtCourses" runat="server" TextMode="MultiLine" Rows="6" 
                                       CssClass="form-control" 
                                       placeholder="List eligible study courses and programs...

Example:
• Computer Science
• Engineering (all majors)
• Business Administration
• Data Science
• Information Technology" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-external-link-alt me-1 icon-link"></i>
                                Scholarship Website URL
                            </label>
                            <asp:TextBox ID="txtLink" runat="server" CssClass="form-control" 
                                       placeholder="https://university.edu/scholarships/international-excellence" />
                        </div>
                    </div>

                    <div class="d-flex justify-content-end mt-4">
                        <asp:Button ID="btnSubmit" runat="server" Text="✨ Save Scholarship" 
                                  CssClass="primary-button" OnClick="btnSubmit_Click" />
                    </div>
                </div>
            </div>

            <!-- Scholarship List Section with Collapsible Cards -->
            <div class="glass-card">
                <div class="card-header">
                    <i class="fas fa-list-ul"></i>
                    Scholarship Added
                </div>
                <div class="card-body">
                    <asp:Label ID="lblListStatus" runat="server" Text="" />
                    
                    <asp:Repeater ID="rptScholarships" runat="server" OnItemCommand="rptScholarships_ItemCommand">
                        <ItemTemplate>
                            <div class="scholarship-card" style="--card-index: <%# Container.ItemIndex %>;">
                                <div class="scholarship-header">
                                    <h4 class="scholarship-title">
                                        <i class="fas fa-award"></i>
                                        <%# Eval("Title") %>
                                    </h4>
                                    <button class="toggle-button" type="button" 
                                            onclick="toggleScholarshipDetails(this, 'scholarship-details-<%# Container.ItemIndex %>')">
                                        View Details
                                    </button>
                                </div>
                                
                                <!-- Preview when collapsed -->
                                <div class="scholarship-preview">
                                    Click "View Details" to see requirements, terms, eligible courses, and management options
                                </div>
                                
                                <!-- Collapsible Details -->
                                <div class="scholarship-details" id="scholarship-details-<%# Container.ItemIndex %>">
                                    <div class="scholarship-section">
                                        <div class="section-title">
                                            <i class="fas fa-clipboard-check icon-requirement"></i>
                                            Requirements
                                        </div>
                                        <div class="section-content"><%# Eval("Requirement") %></div>
                                    </div>
                                    
                                    <div class="scholarship-section">
                                        <div class="section-title">
                                            <i class="fas fa-file-contract icon-terms"></i>
                                            Terms & Conditions
                                        </div>
                                        <div class="section-content"><%# Eval("Terms") %></div>
                                    </div>
                                    
                                    <div class="scholarship-section">
                                        <div class="section-title">
                                            <i class="fas fa-book icon-courses"></i>
                                            Eligible Courses
                                        </div>
                                        <div class="section-content"><%# Eval("Courses") %></div>
                                    </div>
                                    
                                    <div class="scholarship-section">
                                        <div class="section-title">
                                            <i class="fas fa-external-link-alt icon-link"></i>
                                            Application Portal
                                        </div>
                                        <div class="section-content">
                                            <a href='<%# Eval("Link") %>' target="_blank"><%# Eval("Link") %></a>
                                        </div>
                                    </div>
                                    
                                    <!-- Management Section -->
                                    <div class="edit-section">
                                        <h5>
                                            <i class="fas fa-edit"></i>
                                            Edit Scholarship Details
                                        </h5>
                                        <div class="form-grid">
                                            <div class="form-group">
                                                <label class="form-label">Title</label>
                                                <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" 
                                                           Text='<%# Eval("Title") %>' />
                                            </div>
                                            
                                            <div class="form-group">
                                                <label class="form-label">Requirements</label>
                                                <asp:TextBox ID="txtEditRequirement" runat="server" TextMode="MultiLine" Rows="6" 
                                                           CssClass="form-control" Text='<%# Eval("Requirement") %>' />
                                            </div>
                                            
                                            <div class="form-group">
                                                <label class="form-label">Terms & Conditions</label>
                                                <asp:TextBox ID="txtEditTerms" runat="server" TextMode="MultiLine" Rows="6" 
                                                           CssClass="form-control" Text='<%# Eval("Terms") %>' />
                                            </div>
                                            
                                            <div class="form-group">
                                                <label class="form-label">Eligible Courses</label>
                                                <asp:TextBox ID="txtEditCourses" runat="server" TextMode="MultiLine" Rows="4" 
                                                           CssClass="form-control" Text='<%# Eval("Courses") %>' />
                                            </div>
                                            
                                            <div class="form-group">
                                                <label class="form-label">Website Link</label>
                                                <asp:TextBox ID="txtEditLink" runat="server" CssClass="form-control" 
                                                           Text='<%# Eval("Link") %>' />
                                            </div>
                                        </div>
                                        
                                        <div class="action-buttons">
                                            <asp:LinkButton ID="btnUpdate" runat="server" 
                                                          CssClass="success-button" 
                                                          CommandName="Update" 
                                                          CommandArgument='<%# Eval("Id") %>'
                                                          OnClientClick="return confirm('Update this scholarship?');">
                                                <i class="fas fa-save"></i> Update
                                            </asp:LinkButton>
                                            
                                            <asp:LinkButton ID="btnDelete" runat="server" 
                                                          CssClass="danger-button" 
                                                          CommandName="Delete" 
                                                          CommandArgument='<%# Eval("Id") %>'
                                                          OnClientClick="return confirm('Are you sure you want to delete this scholarship?');">
                                                <i class="fas fa-trash"></i> Delete
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoScholarships" runat="server" Visible="false" CssClass="no-scholarships">
                        <i class="fas fa-graduation-cap"></i>
                        <h4>No Scholarship Opportunities Found</h4>
                        <p>Create your first scholarship opportunity using the form above!</p>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Modern JavaScript enhancements with collapsible functionality
        document.addEventListener('DOMContentLoaded', function () {
            // Auto-hide status messages
            setTimeout(function () {
                var statusPanel = document.querySelector('.status-message');
                if (statusPanel) {
                    statusPanel.style.opacity = '0';
                    statusPanel.style.transform = 'translateY(-20px)';
                    statusPanel.style.transition = 'all 0.5s ease';
                    setTimeout(function () {
                        statusPanel.style.display = 'none';
                    }, 500);
                }
            }, 5000);

            // Enhanced hover effects for scholarship cards
            const cards = document.querySelectorAll('.scholarship-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;

                card.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-5px)';
                    this.style.boxShadow = '0 15px 35px rgba(0, 0, 0, 0.15)';
                });

                card.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0)';
                    this.style.boxShadow = '0 5px 20px rgba(0, 0, 0, 0.1)';
                });
            });

            // Form input focus effects
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.style.transform = 'scale(1.02)';
                    this.style.borderColor = '#667eea';
                    this.style.boxShadow = '0 0 0 3px rgba(103, 126, 234, 0.3)';
                });

                input.addEventListener('blur', function () {
                    this.style.transform = 'scale(1)';
                });
            });

            // Auto-resize textareas
            const textareas = document.querySelectorAll('textarea');
            textareas.forEach(textarea => {
                textarea.addEventListener('input', function () {
                    this.style.height = 'auto';
                    this.style.height = this.scrollHeight + 'px';
                });
            });

            // Add smooth scrolling
            document.documentElement.style.scrollBehavior = 'smooth';
        });

        // Toggle function for scholarship details (similar to Scholarship page)
        function toggleScholarshipDetails(button, detailsId) {
            console.log('Toggle clicked for:', detailsId);

            // Add visual feedback
            button.classList.add('clicked');
            setTimeout(() => {
                button.classList.remove('clicked');
            }, 200);

            // Get the details element
            const detailsElement = document.getElementById(detailsId);
            const previewElement = button.closest('.scholarship-card').querySelector('.scholarship-preview');

            // Check if currently open
            if (detailsElement.classList.contains('show')) {
                // Close it
                detailsElement.classList.remove('show');
                button.textContent = 'View Details';
                button.classList.remove('active');
                previewElement.style.display = 'block';
                console.log('Closing details');
            } else {
                // Open it
                detailsElement.classList.add('show');
                button.textContent = 'Hide Details';
                button.classList.add('active');
                previewElement.style.display = 'none';
                console.log('Opening details');

                // Smooth scroll to the card
                setTimeout(() => {
                    const card = button.closest('.scholarship-card');
                    card.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start',
                        inline: 'nearest'
                    });
                }, 400);
            }
        }
    </script>
</asp:Content>