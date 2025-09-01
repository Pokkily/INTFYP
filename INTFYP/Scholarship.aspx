<%@ Page Async="true" Title="Scholarship Application" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Scholarship.aspx.cs" Inherits="YourNamespace.Scholarship" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Scholarship Application
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Scholarship Page with Library Design Formula - WORKING TOGGLE VERSION */
        
        .scholarship-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        .scholarship-page::before {
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
            pointer-events: none;
        }

        @keyframes backgroundFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-20px, -20px) rotate(1deg); }
            50% { transform: translate(20px, -10px) rotate(-1deg); }
            75% { transform: translate(-10px, 10px) rotate(0.5deg); }
        }

        .scholarship-container {
            max-width: 1000px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
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
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 15px;
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
            pointer-events: none;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 60px; }
        }

        .page-subtitle {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.8);
            margin: 0 0 25px 0;
        }

        /* UPDATED: Scholarship App Button - Matching Submit Feedback Button Design */
        .scholarship-app-button {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%) !important;
            color: white !important;
            padding: 15px 30px !important;
            border-radius: 25px !important;
            font-weight: 600 !important;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3) !important;
            border: none !important;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            position: relative !important;
            overflow: hidden !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 12px !important;
            font-size: 16px !important;
            text-decoration: none !important;
            animation: slideInFromTop 1s ease-out 0.3s both;
        }

        .scholarship-app-button::before {
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

        .scholarship-app-button:hover::before {
            width: 300px;
            height: 300px;
        }

        .scholarship-app-button:hover {
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%) !important;
            transform: translateY(-2px) !important;
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4) !important;
            color: white !important;
            text-decoration: none !important;
        }

        .scholarship-app-button:active {
            transform: translateY(0) !important;
        }

        .scholarship-app-button .icon {
            font-size: 18px;
        }

        /* Clicked animation for visual feedback */
        .scholarship-app-button.clicked {
            animation: buttonPulse 0.6s ease-out !important;
        }

        @keyframes buttonPulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }

        /* Scholarship Cards */
        .scholarship-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            animation: cardEntrance 0.8s ease-out both;
            animation-delay: calc(var(--card-index, 0) * 0.15s);
            margin-bottom: 25px;
            z-index: 2;
        }

        @keyframes cardEntrance {
            from { 
                opacity: 0; 
                transform: translateY(30px) rotate(1deg);
            }
            to { 
                opacity: 1; 
                transform: translateY(0) rotate(0deg); 
            }
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
            transform: translateY(-5px) scale(1.01);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
        }

        .card-header {
            background: transparent;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            border-radius: 20px 20px 0 0;
            padding: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            position: relative;
            z-index: 3;
        }

        .scholarship-title {
            font-size: 22px;
            font-weight: 700;
            color: #2c3e50;
            margin: 0;
            word-wrap: break-word;
            overflow-wrap: break-word;
            flex: 1;
            min-width: 250px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .scholarship-title::before {
            content: '🎓';
            font-size: 24px;
            flex-shrink: 0;
        }

        /* WORKING TOGGLE BUTTON */
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

        /* ACTIVE STATE for opened details */
        .toggle-button.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
            color: white !important;
            border-color: transparent !important;
        }

        .card-body {
            padding: 0;
            border-radius: 0 0 20px 20px;
            position: relative;
            z-index: 2;
        }

        /* CUSTOM COLLAPSE IMPLEMENTATION */
        .scholarship-details {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease-in-out, padding 0.4s ease-in-out;
            padding: 0 25px;
        }

        .scholarship-details.show {
            max-height: 2000px; /* Large enough to accommodate content */
            padding: 25px;
        }

        .info-section {
            margin-bottom: 20px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 15px;
            border: 1px solid rgba(0, 0, 0, 0.05);
            transition: all 0.2s ease;
        }

        .info-section:hover {
            background: rgba(255, 255, 255, 0.8);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .info-section:last-child {
            margin-bottom: 0;
        }

        .section-title {
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .section-title.requirements::before {
            content: '📋';
        }

        .section-title.terms::before {
            content: '📜';
        }

        .section-title.courses::before {
            content: '📚';
        }

        .section-content {
            color: #555;
            line-height: 1.6;
        }

        .section-content p {
            margin-bottom: 8px;
        }

        .section-content p:last-child {
            margin-bottom: 0;
        }

        /* Apply Button */
        .apply-button {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 15px 25px;
            border-radius: 25px;
            border: none;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s ease;
            position: relative;
            overflow: hidden;
            width: 100%;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 6px 20px rgba(103, 126, 234, 0.3);
            z-index: 5;
            min-height: 50px;
        }

        .apply-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.3s ease;
            pointer-events: none;
        }

        .apply-button:hover::before {
            width: 200px;
            height: 200px;
        }

        .apply-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            color: white;
            text-decoration: none;
        }

        .apply-button:active {
            transform: translateY(0);
        }

        .apply-button::after {
            content: '🚀';
            margin-left: 5px;
        }

        /* No Scholarships Message */
        .no-scholarships {
            text-align: center;
            padding: 60px 40px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: rgba(255, 255, 255, 0.9);
            animation: fadeInUp 1s ease-out 0.6s both;
        }

        @keyframes fadeInUp {
            from { 
                opacity: 0; 
                transform: translateY(40px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .no-scholarships-icon {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.7;
            animation: iconBounce 2s ease-in-out infinite;
            pointer-events: none;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .no-scholarships h3 {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 10px;
            color: rgba(255, 255, 255, 0.9);
        }

        .no-scholarships p {
            font-size: 16px;
            color: rgba(255, 255, 255, 0.7);
            margin: 0;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .scholarship-page {
                padding: 20px 15px;
            }

            .scholarship-app-button {
                padding: 12px 24px;
                font-size: 14px;
                margin-bottom: 10px;
            }

            .card-header {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }

            .scholarship-title {
                min-width: unset;
                text-align: center;
            }

            .toggle-button {
                width: 100%;
                text-align: center;
                min-height: 45px;
            }

            .scholarship-details.show {
                padding: 20px;
            }

            .info-section {
                padding: 15px;
            }

            .apply-button {
                min-height: 55px;
                font-size: 18px;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 28px;
            }

            .scholarship-app-button {
                padding: 10px 20px;
                font-size: 13px;
                gap: 8px;
            }

            .scholarship-card {
                margin-bottom: 20px;
                border-radius: 15px;
            }

            .card-header {
                padding: 20px;
            }

            .scholarship-details.show {
                padding: 15px;
            }

            .info-section {
                padding: 12px;
                margin-bottom: 15px;
            }

            .toggle-button {
                min-height: 50px;
                font-size: 16px;
            }
        }

        /* Enhanced text formatting */
        .section-content ul {
            padding-left: 20px;
            margin-bottom: 10px;
        }

        .section-content li {
            margin-bottom: 5px;
        }

        .section-content strong {
            color: #2c3e50;
        }

        /* Button click effects */
        .toggle-button.clicked,
        .apply-button.clicked {
            animation: buttonPulse 0.2s ease-out;
        }

        .toggle-button:focus,
        .apply-button:focus,
        .scholarship-app-button:focus {
            outline: 2px solid #667eea;
            outline-offset: 2px;
        }
    </style>

    <div class="scholarship-page">
        <div class="scholarship-container">
            <div class="page-header">
                <h2 class="page-title">Scholarship Application</h2>
                <p class="page-subtitle">Review your submitted results and apply for available scholarships</p>
                
                <!-- UPDATED: Scholarship Application Button with Teal Design -->
                <a href="scholarshipApp.aspx" class="scholarship-app-button" onclick="handleScholarshipAppClick(event)">
                    <span class="icon">📝</span>
                    <span>Apply School Scholarship</span>
                </a>
            </div>

            <div class="row">
                <div class="col-12">
                    <asp:Repeater ID="rptScholarships" runat="server">
                        <ItemTemplate>
                            <div class="scholarship-card" style="--card-index: <%# Container.ItemIndex %>;">
                                <div class="card-header">
                                    <h5 class="scholarship-title"><%# Eval("Title") %></h5>
                                    <button class="toggle-button" type="button" 
                                            onclick="toggleDetails(this, 'details-<%# Container.ItemIndex %>')">
                                        View Details
                                    </button>
                                </div>
                                <div class="card-body">
                                    <div class="scholarship-details" id="details-<%# Container.ItemIndex %>">
                                        <div class="info-section">
                                            <div class="section-title requirements">Requirements</div>
                                            <div class="section-content">
                                                <asp:Literal ID="litRequirement" runat="server" Text='<%# Eval("Requirement").ToString().Replace("\n", "<br/>") %>' />
                                            </div>
                                        </div>

                                        <div class="info-section">
                                            <div class="section-title terms">Terms & Conditions</div>
                                            <div class="section-content">
                                                <asp:Literal ID="litTerms" runat="server" Text='<%# Eval("Terms").ToString().Replace("\n", "<br/>") %>' />
                                            </div>
                                        </div>

                                        <div class="info-section">
                                            <div class="section-title courses">Available Courses</div>
                                            <div class="section-content">
                                                <asp:Literal ID="litCourses" runat="server" Text='<%# Eval("Courses").ToString().Replace("\n", "<br/>") %>' />
                                            </div>
                                        </div>

                                        <div class="d-grid mt-4">
                                            <a href='<%# Eval("Link") %>' target="_blank" class="apply-button" onclick="handleApplyClick(event)">
                                                Apply for This Scholarship
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <!-- No Scholarships Message (if needed) -->
                    <asp:Panel ID="pnlNoScholarships" runat="server" Visible="false" CssClass="no-scholarships">
                        <div class="no-scholarships-icon">🎓</div>
                        <h3>No Scholarships Available</h3>
                        <p>Check back later for new scholarship opportunities!</p>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <!-- Include Required Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>

    <!-- WORKING JAVASCRIPT - NO BOOTSTRAP CONFLICTS -->
    <script type="text/javascript">
        $(document).ready(function () {
            console.log('Enhanced Scholarship page loaded - WORKING TOGGLE VERSION with teal button');

            // Hover effects for cards
            $('.scholarship-card').hover(
                function () {
                    $(this).css({
                        'transform': 'translateY(-5px) scale(1.01)',
                        'box-shadow': '0 15px 35px rgba(0, 0, 0, 0.15)',
                        'background': 'rgba(255, 255, 255, 1)'
                    });
                },
                function () {
                    $(this).css({
                        'transform': '',
                        'box-shadow': '0 10px 30px rgba(0, 0, 0, 0.1)',
                        'background': 'rgba(255, 255, 255, 0.95)'
                    });
                }
            );

            // Add entrance animation delay
            $('.scholarship-card').each(function (index) {
                $(this).css('animation-delay', (index * 0.15) + 's');
            });
        });

        // SIMPLE WORKING TOGGLE FUNCTION
        function toggleDetails(button, detailsId) {
            console.log('Toggle clicked for:', detailsId);

            // Add visual feedback
            $(button).addClass('clicked');
            setTimeout(() => {
                $(button).removeClass('clicked');
            }, 200);

            // Get the details element
            const detailsElement = document.getElementById(detailsId);

            // Check if currently open
            if (detailsElement.classList.contains('show')) {
                // Close it
                detailsElement.classList.remove('show');
                button.textContent = 'View Details';
                button.classList.remove('active');
                console.log('Closing details');
            } else {
                // Open it
                detailsElement.classList.add('show');
                button.textContent = 'Hide Details';
                button.classList.add('active');
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

        function handleApplyClick(event) {
            console.log('Apply button clicked successfully!');
            // Add visual feedback
            $(event.target).addClass('clicked');
            setTimeout(() => {
                $(event.target).removeClass('clicked');
            }, 200);
        }

        // UPDATED: Enhanced Scholarship App Button Click with Animation
        function handleScholarshipAppClick(event) {
            console.log('Scholarship App button clicked successfully!');

            // Add clicked class for animation (matching feedback button behavior)
            const button = event.target.closest('.scholarship-app-button');
            button.classList.add('clicked');

            // Remove clicked animation class after animation completes
            setTimeout(() => {
                button.classList.remove('clicked');
            }, 600);
        }

        // Function for smooth animations on page load
        function pageLoad() {
            console.log('Scholarship PageLoad fired');

            // Re-initialize any JavaScript if needed after postback
            setTimeout(function () {
                $('.scholarship-card').each(function (index) {
                    $(this).css('animation-delay', (index * 0.15) + 's');
                });
            }, 100);
        }
    </script>

    <!-- Font Awesome for additional icons if needed -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>