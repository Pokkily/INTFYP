<%@ Page Title="About Us - Advanced Intranet Educational Platform" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="INTFYP._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .main-content {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            background-color: #f8f9fa;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .hero-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
            padding: 60px 20px;
            margin-bottom: 40px;
            border-radius: 10px;
        }
        
        .hero-section h1 {
            font-size: 2.8em;
            margin-bottom: 20px;
            font-weight: 300;
        }
        
        .hero-section p {
            font-size: 1.2em;
            opacity: 0.9;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .section {
            background: white;
            margin-bottom: 30px;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .section h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 2em;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }
        
        .team-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 30px;
        }
        
        .team-member {
            text-align: center;
            padding: 30px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            transition: transform 0.3s ease;
        }
        
        .team-member:hover {
            transform: translateY(-5px);
            border-color: #667eea;
        }
        
        .team-member h3 {
            color: #667eea;
            margin-bottom: 10px;
        }
        
        .modules-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .module-card {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
            transition: all 0.3s ease;
        }
        
        .module-card:hover {
            background: #e3f2fd;
            transform: translateX(5px);
        }
        
        .module-card h4 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .tech-stack {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 20px;
        }
        
        .tech-badge {
            background: #667eea;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 500;
        }
        
        .mission-vision {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 30px;
        }
        
        .mission, .vision {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            text-align: center;
        }
        
        .vision {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
    </style>

    <div class="main-content">
        <div class="container">
        <div class="hero-section">
            <h1>Advanced Intranet Educational Platform</h1>
            <p>Revolutionizing education through comprehensive digital solutions that enhance communication, learning, and collaboration within educational institutions.</p>
        </div>
        
        <div class="section">
            <h2>About Our Project</h2>
            <p>The Advanced Intranet Educational Platform represents a comprehensive solution designed to address the critical challenges facing modern educational institutions. Our platform integrates multiple essential functionalities into a unified system, streamlining educational processes and enhancing user experiences for students, educators, and administrators alike.</p>
            
            <p>Born from extensive research and user feedback analysis, our platform tackles key issues including inefficient classroom management, fragmented resource access, limited interactive learning opportunities, and complex administrative processes. Through innovative design and cutting-edge technology, we've created a centralized hub that transforms how educational communities interact and learn.</p>
        </div>
        
        <div class="section">
            <h2>Our Development Team</h2>
            <div class="team-grid">
                <div class="team-member">
                    <h3>Foo Tek Sian</h3>
                    <p><strong>ID:</strong> 23WMR10617</p>
                    <p><strong>Focus Areas:</strong></p>
                    <ul style="text-align: left;">
                        <li>Classroom Management System</li>
                        <li>AI Chatbot Integration</li>
                        <li>Gamified Quiz Module</li>
                        <li>Study Hub Development</li>
                        <li>Automated Assignment Grouping</li>
                    </ul>
                </div>
                
                <div class="team-member">
                    <h3>Tan Fu Yang</h3>
                    <p><strong>ID:</strong> 23WMR11316</p>
                    <p><strong>Focus Areas:</strong></p>
                    <ul style="text-align: left;">
                        <li>Feedback Management System</li>
                        <li>E-Library Development</li>
                        <li>Language Learning Module</li>
                        <li>Scholarship Finder System</li>
                    </ul>
                </div>
            </div>
            
            <p style="margin-top: 30px; text-align: center;"><strong>Supervisor:</strong> Ms. Pua Bee Lian<br>
            <strong>Institution:</strong> Faculty of Computing and Information Technology<br>
            Tunku Abdul Rahman University of Management and Technology</p>
        </div>
        
        <div class="section">
            <h2>Platform Modules</h2>
            <div class="modules-grid">
                <div class="module-card">
                    <h4>Classroom Management</h4>
                    <p>Comprehensive tools for creating classes, managing assignments, posting announcements, and tracking student progress with real-time updates.</p>
                </div>
                
                <div class="module-card">
                    <h4>Feedback Management</h4>
                    <p>Structured system for collecting, prioritizing, and responding to feedback from students and staff with voting mechanisms and resolution tracking.</p>
                </div>
                
                <div class="module-card">
                    <h4>E-Library System</h4>
                    <p>Digital repository with advanced search capabilities, citation generation, bookmarking features, and personalized content recommendations.</p>
                </div>
                
                <div class="module-card">
                    <h4>Language Learning</h4>
                    <p>Interactive language courses with gamified elements, multimedia content, progress tracking, and AI-powered pronunciation coaching.</p>
                </div>
                
                <div class="module-card">
                    <h4>Scholarship Finder</h4>
                    <p>Intelligent matching system that connects students with relevant scholarships based on their profiles, with automated deadline reminders.</p>
                </div>
                
                <div class="module-card">
                    <h4>AI Chatbot</h4>
                    <p>Smart assistant providing instant responses to common queries, with escalation capabilities for complex issues requiring human intervention.</p>
                </div>
                
                <div class="module-card">
                    <h4>Study Hub</h4>
                    <p>Collaborative learning environment where students can form study groups, share resources, and engage in peer-to-peer learning activities.</p>
                </div>
                
                <div class="module-card">
                    <h4>Automated Grouping</h4>
                    <p>Intelligent assignment group creation using customizable rules and algorithms to ensure balanced and effective team formations.</p>
                </div>
            </div>
        </div>
        
        <div class="section">
            <h2>Technology Stack</h2>
            <p>Built using modern, reliable technologies to ensure scalability, performance, and maintainability:</p>
            <div class="tech-stack">
                <span class="tech-badge">ASP.NET Core</span>
                <span class="tech-badge">C#</span>
                <span class="tech-badge">JavaScript</span>
                <span class="tech-badge">HTML5</span>
                <span class="tech-badge">CSS3</span>
                <span class="tech-badge">Firestore</span>
            </div>
        </div>
        
        <div class="section">
            <h2>Mission & Vision</h2>
            <div class="mission-vision">
                <div class="mission">
                    <h3>Our Mission</h3>
                    <p>To create an integrated, user-friendly educational platform that streamlines administrative processes, enhances student engagement, and fosters collaborative learning environments while reducing institutional operational costs.</p>
                </div>
                
                <div class="vision">
                    <h3>Our Vision</h3>
                    <p>To revolutionize educational technology by providing institutions with comprehensive digital solutions that bridge communication gaps, democratize access to resources, and empower both educators and students to achieve their full potential.</p>
                </div>
            </div>
        </div>
        
        <div class="section">
            <h2>Key Achievements</h2>
            <ul>
                <li><strong>Comprehensive User Research:</strong> Conducted extensive surveys with 30+ respondents to identify key pain points and user needs</li>
                <li><strong>Integrated Solution:</strong> Successfully designed a unified platform combining 8 major functional modules</li>
                <li><strong>User-Centric Design:</strong> Developed intuitive interfaces based on direct user feedback and usability testing</li>
                <li><strong>Scalable Architecture:</strong> Implemented robust database design with proper normalization (3NF) for optimal performance</li>
                <li><strong>Innovation in Education:</strong> Introduced gamification elements and AI-powered assistance to enhance learning experiences</li>
                <li><strong>Academic Excellence:</strong> Completed comprehensive documentation including feasibility studies, system design, and implementation planning</li>
            </ul>
        </div>
        
        <div class="section">
            <h2>Contact Information</h2>
            <p>For more information about our Advanced Intranet Educational Platform project, please contact:</p>
            <p><strong>Academic Year:</strong> 2024/2025<br>
            <strong>Program:</strong> Bachelor of Information Technology (Honours) in Software System Development<br>
            <strong>Department:</strong> Information and Communication Technology<br>
            <strong>Faculty:</strong> Computing and Information Technology<br>
            <strong>University:</strong> Tunku Abdul Rahman University of Management and Technology, Kuala Lumpur</p>
        </div>
        </div>
    </div>
</asp:Content>