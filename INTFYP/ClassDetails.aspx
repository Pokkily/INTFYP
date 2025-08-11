<%@ Page Title="Classroom Details" 
    Language="C#" 
    MasterPageFile="~/Site.master" 
    AutoEventWireup="true" 
    CodeBehind="ClassDetails.aspx.cs" 
    Inherits="YourProjectNamespace.ClassDetails" 
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Classroom Details
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Classroom Details with Design Formula */
        
        .classroom-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        .classroom-page::before {
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

        .classroom-container {
            max-width: 900px;
            margin: 0 auto;
            position: relative;
        }

        .classroom-header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 30px;
            border-radius: 20px;
            margin-bottom: 40px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
            overflow: hidden;
            animation: slideInFromTop 1s ease-out;
        }

        .classroom-header::before {
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

        .classroom-title {
            font-size: clamp(28px, 4vw, 36px);
            font-weight: 700;
            color: #2c3e50;
            margin: 0;
            position: relative;
            display: inline-block;
        }

        .classroom-title::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            width: 60px;
            height: 3px;
            background: linear-gradient(90deg, #667eea, #764ba2);
            border-radius: 2px;
            animation: expandWidth 1.5s ease-out 0.5s both;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 60px; }
        }

        .posts-container {
            animation: slideInFromBottom 1s ease-out 0.3s both;
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

        .post-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 30px;
            margin-bottom: 25px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            animation: cardEntrance 0.8s ease-out both;
            animation-delay: calc(var(--card-index, 0) * 0.1s);
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

        .post-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #667eea, #764ba2);
            background-size: 200% 100%;
            animation: gradientSlide 2s ease infinite;
        }

        @keyframes gradientSlide {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .post-card:hover {
            transform: translateY(-5px) scale(1.01);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
        }

        .post-card:hover .post-title {
            color: #667eea;
        }

        .post-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
            gap: 15px;
            flex-wrap: wrap;
        }

        .post-title {
            font-size: 22px;
            font-weight: 700;
            color: #2c3e50;
            margin: 0;
            line-height: 1.3;
            transition: color 0.3s ease;
            flex: 1;
            min-width: 0;
        }

        .post-type {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            background: rgba(103, 126, 234, 0.1);
            color: #667eea;
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            white-space: nowrap;
            transition: all 0.3s ease;
        }

        .post-type::before {
            content: '📝';
            font-size: 12px;
        }

        .post-type.Assignment::before { content: '📋'; }
        .post-type.Announcement::before { content: '📢'; }
        .post-type.Material::before { content: '📚'; }
        .post-type.Quiz::before { content: '❓'; }

        .post-card:hover .post-type {
            background: rgba(103, 126, 234, 0.15);
            border-color: rgba(103, 126, 234, 0.3);
        }

        .post-meta {
            font-size: 15px;
            color: #7f8c8d;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .post-meta::before {
            content: '';
            width: 6px;
            height: 6px;
            background: #667eea;
            border-radius: 50%;
            flex-shrink: 0;
        }

        .post-author {
            color: #667eea;
            font-weight: 600;
        }

        .post-date {
            color: #95a5a6;
            font-size: 14px;
        }

        .post-content {
            margin: 20px 0;
            white-space: pre-line;
            color: #2c3e50;
            font-size: 16px;
            line-height: 1.6;
            padding: 20px;
            background: rgba(248, 249, 250, 0.5);
            border-radius: 12px;
            border-left: 4px solid #667eea;
        }

        .attachments-section {
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid rgba(236, 240, 241, 0.5);
        }

        .attachments-title {
            font-size: 16px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .attachments-title::before {
            content: '📎';
            font-size: 18px;
        }

        .file-attachment {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            font-size: 14px;
            font-weight: 600;
            margin: 5px 10px 5px 0;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .file-attachment::before {
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

        .file-attachment:hover::before {
            width: 300px;
            height: 300px;
        }

        .file-attachment:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            color: white;
            text-decoration: none;
        }

        .file-attachment i {
            font-size: 16px;
        }

        .no-posts {
            text-align: center;
            padding: 80px 40px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 2px dashed rgba(255, 255, 255, 0.3);
            border-radius: 20px;
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

        .no-posts-icon {
            font-size: 72px;
            margin-bottom: 25px;
            opacity: 0.7;
            animation: iconFloat 3s ease-in-out infinite;
        }

        @keyframes iconFloat {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-15px) rotate(10deg); }
        }

        .no-posts h3 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 15px;
            color: rgba(255, 255, 255, 0.9);
        }

        .no-posts p {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.7);
            margin: 0;
            line-height: 1.5;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .classroom-page {
                padding: 30px 15px;
            }

            .post-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .post-type {
                align-self: flex-start;
            }

            .post-meta {
                flex-direction: column;
                align-items: flex-start;
                gap: 5px;
            }

            .file-attachment {
                display: flex;
                width: 100%;
                justify-content: center;
                margin: 10px 0 5px 0;
            }
        }

        @media (max-width: 480px) {
            .classroom-header,
            .post-card {
                padding: 20px;
                border-radius: 15px;
            }

            .classroom-title {
                font-size: 24px;
            }

            .post-title {
                font-size: 20px;
            }

            .post-content {
                padding: 15px;
                font-size: 15px;
            }
        }

        /* Loading animation for cards */
        .post-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }

        /* Hover effects for better interactivity */
        .post-author:hover {
            color: #764ba2;
            transition: color 0.3s ease;
        }

        /* Focus states for accessibility */
        .file-attachment:focus {
            outline: 3px solid rgba(255, 255, 255, 0.5);
            outline-offset: 2px;
        }

        /* Special animations for different post types */
        .post-type.Assignment {
            background: rgba(255, 107, 107, 0.1);
            color: #ff6b6b;
            border-color: rgba(255, 107, 107, 0.2);
        }

        .post-type.Announcement {
            background: rgba(78, 205, 196, 0.1);
            color: #4ecdc4;
            border-color: rgba(78, 205, 196, 0.2);
        }

        .post-type.Material {
            background: rgba(52, 152, 219, 0.1);
            color: #3498db;
            border-color: rgba(52, 152, 219, 0.2);
        }
    </style>

    <div class="classroom-page">
        <div class="classroom-container">
            <div class="classroom-header">
                <h2 class="classroom-title" runat="server" id="classTitle">📚 Classroom Posts</h2>
            </div>

            <div class="posts-container">
                <asp:Panel ID="pnlNoPosts" runat="server" CssClass="no-posts">
                    <div class="no-posts-icon">📮</div>
                    <h3>No Posts Yet</h3>
                    <p>This classroom doesn't have any posts yet. Check back later for updates and assignments!</p>
                </asp:Panel>

                <asp:Repeater ID="rptPosts" runat="server">
                    <ItemTemplate>
                        <div class="post-card" style="--card-index: <%# Container.ItemIndex %>;">
                            <div class="post-header">
                                <h3 class="post-title"><%# Eval("Title") %></h3>
                                <span class="post-type <%# Eval("Type") %>"><%# Eval("Type") %></span>
                            </div>
                            
                            <div class="post-meta">
                                <span>Posted by <span class="post-author"><%# Eval("CreatedByName") %></span></span>
                                <span class="post-date"><%# Eval("CreatedAtFormatted") %></span>
                            </div>
                            
                            <div class="post-content">
                                <%# Eval("Content") %>
                            </div>
                            
                            <asp:Panel runat="server" CssClass="attachments-section" 
                                       Visible='<%# ((System.Collections.IEnumerable)Eval("FileUrls")).Cast<object>().Any() %>'>
                                <div class="attachments-title">Attachments</div>
                                <asp:Repeater ID="rptFiles" runat="server" DataSource='<%# Eval("FileUrls") %>'>
                                    <ItemTemplate>
                                        <a href="<%# Container.DataItem %>" target="_blank" class="file-attachment">
                                            <i class="fas fa-download"></i>
                                            <span>Download File</span>
                                        </a>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </asp:Panel>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>