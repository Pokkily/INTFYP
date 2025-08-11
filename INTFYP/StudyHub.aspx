<%@ Page Title="Study Hub" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="StudyHub.aspx.cs" Inherits="YourProjectNamespace.StudyHub" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Study Hub
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Study Hub with Design Formula */
        
        .study-hub-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        .study-hub-page::before {
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

        .hub-container {
            max-width: 1400px;
            margin: 0 auto;
            position: relative;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
            flex-wrap: wrap;
            gap: 20px;
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
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            position: relative;
            display: inline-block;
            margin: 0;
        }

        .page-title::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
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

        .create-group-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            font-size: 16px;
            box-shadow: 0 6px 20px rgba(103, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .create-group-btn::before {
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

        .create-group-btn:hover::before {
            width: 300px;
            height: 300px;
        }

        .create-group-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            color: white;
        }

        .create-group-btn:active {
            transform: translateY(0);
            box-shadow: 0 6px 20px rgba(103, 126, 234, 0.3);
        }

        .groups-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: 30px;
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

        .group-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            border: 1px solid rgba(255, 255, 255, 0.2);
            animation: cardEntrance 0.8s ease-out both;
            animation-delay: calc(var(--card-index, 0) * 0.1s);
        }

        @keyframes cardEntrance {
            from { 
                opacity: 0; 
                transform: translateY(50px) rotate(2deg); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0) rotate(0deg); 
            }
        }

        .group-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
            z-index: 1;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .group-card:hover {
            transform: translateY(-12px) scale(1.02);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
        }

        .group-card:hover .group-image {
            transform: scale(1.1);
        }

        .group-card:hover .group-title {
            color: #667eea;
        }

        .group-image-container {
            width: 100%;
            height: 220px;
            overflow: hidden;
            position: relative;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        }

        .group-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .group-image-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(103, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            opacity: 0;
            transition: opacity 0.4s ease;
        }

        .group-card:hover .group-image-overlay {
            opacity: 1;
        }

        .group-body {
            padding: 25px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .group-title {
            font-size: 22px;
            font-weight: 700;
            color: #2c3e50;
            margin: 0;
            line-height: 1.3;
            transition: color 0.3s ease;
        }

        .group-meta {
            font-size: 15px;
            color: #7f8c8d;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 0;
        }

        .group-meta::before {
            content: '';
            width: 6px;
            height: 6px;
            background: #667eea;
            border-radius: 50%;
            flex-shrink: 0;
        }

        .group-stats {
            display: flex;
            gap: 20px;
            margin-top: 8px;
        }

        .stat-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 14px;
            color: #95a5a6;
            font-weight: 500;
        }

        .stat-icon {
            font-size: 16px;
            color: #667eea;
        }

        .group-footer {
            padding: 20px 25px;
            border-top: 1px solid rgba(236, 240, 241, 0.5);
            background: rgba(248, 249, 250, 0.5);
        }

        .view-group-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
            width: 100%;
            justify-content: center;
        }

        .view-group-btn::before {
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

        .view-group-btn:hover::before {
            width: 300px;
            height: 300px;
        }

        .view-group-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            color: white;
            text-decoration: none;
        }

        .view-group-btn:active {
            transform: translateY(0);
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .no-groups {
            text-align: center;
            padding: 80px 40px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: rgba(255, 255, 255, 0.9);
            grid-column: 1 / -1;
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

        .no-groups-icon {
            font-size: 72px;
            margin-bottom: 25px;
            opacity: 0.7;
            animation: iconFloat 3s ease-in-out infinite;
        }

        @keyframes iconFloat {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-15px) rotate(5deg); }
        }

        .no-groups h3 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 15px;
            color: rgba(255, 255, 255, 0.9);
        }

        .no-groups p {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.7);
            margin: 0;
            line-height: 1.5;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .study-hub-page {
                padding: 30px 15px;
            }

            .page-header {
                flex-direction: column;
                align-items: stretch;
                text-align: center;
            }

            .create-group-btn {
                width: 100%;
                justify-content: center;
            }

            .groups-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .group-stats {
                justify-content: center;
                gap: 30px;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 32px;
            }

            .group-card {
                border-radius: 15px;
            }

            .group-body {
                padding: 20px;
            }

            .group-footer {
                padding: 15px 20px;
            }

            .group-image-container {
                height: 180px;
            }
        }

        /* Loading animation for cards */
        .group-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }

        /* Hover effects for interactive elements */
        .group-meta:hover::before {
            animation: pulse 1s ease infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.2); opacity: 0.7; }
        }

        /* Focus states for accessibility */
        .create-group-btn:focus,
        .view-group-btn:focus {
            outline: 3px solid rgba(255, 255, 255, 0.5);
            outline-offset: 2px;
        }
    </style>

    <div class="study-hub-page">
        <div class="hub-container">
            <div class="page-header">
                <h3 class="page-title">🎓 Your Study Groups</h3>
                <asp:Button ID="btnCreateGroup" runat="server" Text="➕ Create Group" CssClass="create-group-btn" OnClick="btnCreateGroup_Click" />
            </div>

            <div class="groups-grid">
                <asp:Repeater ID="rptGroups" runat="server">
                    <ItemTemplate>
                        <div class="group-card" style="--card-index: <%# Container.ItemIndex %>;">
                            <div class="group-image-container">
                                <img src='<%# Eval("groupImage") %>' class="group-image" alt="Group Image" />
                                <div class="group-image-overlay"></div>
                            </div>
                            
                            <div class="group-body">
                                <h5 class="group-title"><%# Eval("groupName") %></h5>
                                
                                <small class="group-meta">
                                    🧑‍🏫 Hosted by <%# Eval("hosterName") %>
                                </small>
                                
                                <div class="group-stats">
                                    <div class="stat-item">
                                        <span class="stat-icon">👥</span>
                                        <span><%# Eval("capacity") %> members</span>
                                    </div>
                                    <div class="stat-item">
                                        <span class="stat-icon">📚</span>
                                        <span>Active</span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="group-footer">
                                <a href='StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>' class="view-group-btn">
                                    🚀 Join Study Session
                                </a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <!-- Show when no groups exist -->
                <asp:Panel ID="pnlNoGroups" runat="server" Visible="false" CssClass="no-groups">
                    <div class="no-groups-icon">📖</div>
                    <h3>No Study Groups Yet</h3>
                    <p>Create your first study group or join existing ones to start collaborating with peers!</p>
                </asp:Panel>
            </div>
        </div>
    </div>

    <!-- Font Awesome for additional icons if needed -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>