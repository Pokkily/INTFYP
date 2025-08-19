<%@ Page Title="Study Hub" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="StudyHub.aspx.cs" Inherits="YourProjectNamespace.StudyHub" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Study Hub
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Study Hub with Advanced Design */
        
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

        .header-actions {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .create-group-btn, .join-group-btn, .my-groups-btn {
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

        .join-group-btn {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            box-shadow: 0 6px 20px rgba(78, 205, 196, 0.3);
        }

        .my-groups-btn {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
            box-shadow: 0 6px 20px rgba(255, 107, 107, 0.3);
        }

        .create-group-btn::before, .join-group-btn::before, .my-groups-btn::before {
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

        .create-group-btn:hover::before, .join-group-btn:hover::before, .my-groups-btn:hover::before {
            width: 300px;
            height: 300px;
        }

        .create-group-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        .join-group-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
        }

        .my-groups-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(255, 107, 107, 0.4);
            background: linear-gradient(135deg, #ee5a52 0%, #ff6b6b 100%);
        }

        .filters-section {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 25px;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            animation: slideInFromLeft 1s ease-out 0.2s both;
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

        .filters-title {
            color: white;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .filter-controls {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: center;
        }

        .search-box {
            flex: 1;
            min-width: 250px;
            padding: 12px 20px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 25px;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            font-size: 14px;
            backdrop-filter: blur(5px);
        }

        .search-box::placeholder {
            color: rgba(255, 255, 255, 0.7);
        }

        .filter-dropdown {
            padding: 12px 20px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 25px;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            backdrop-filter: blur(5px);
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

        .group-description {
            font-size: 14px;
            color: #95a5a6;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
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

        .group-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }

        .tag {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 4px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 500;
        }

        .group-footer {
            padding: 20px 25px;
            border-top: 1px solid rgba(236, 240, 241, 0.5);
            background: rgba(248, 249, 250, 0.5);
            display: flex;
            gap: 10px;
        }

        .view-group-btn, .join-group-footer-btn {
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
            position: relative;
            overflow: hidden;
            flex: 1;
            justify-content: center;
        }

        .view-group-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .join-group-footer-btn {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .view-group-btn::before, .join-group-footer-btn::before {
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

        .view-group-btn:hover::before, .join-group-footer-btn:hover::before {
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

        .join-group-footer-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
            color: white;
            text-decoration: none;
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

        .floating-action-btn {
            position: fixed;
            bottom: 30px;
            right: 30px;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            font-size: 24px;
            cursor: pointer;
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            transition: all 0.3s ease;
            z-index: 1000;
        }

        .floating-action-btn:hover {
            transform: scale(1.1);
            box-shadow: 0 12px 35px rgba(103, 126, 234, 0.6);
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

            .header-actions {
                justify-content: center;
                flex-wrap: wrap;
            }

            .create-group-btn, .join-group-btn, .my-groups-btn {
                flex: 1;
                min-width: 160px;
            }

            .groups-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .filter-controls {
                flex-direction: column;
                align-items: stretch;
            }

            .search-box {
                min-width: auto;
            }

            .group-footer {
                flex-direction: column;
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

            .header-actions {
                flex-direction: column;
                gap: 10px;
            }
        }

        /* Loading states */
        .loading-skeleton {
            background: linear-gradient(90deg, rgba(255,255,255,0.1) 25%, rgba(255,255,255,0.2) 50%, rgba(255,255,255,0.1) 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
        }

        @keyframes loading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }

        /* Accessibility improvements */
        .create-group-btn:focus,
        .join-group-btn:focus,
        .my-groups-btn:focus,
        .view-group-btn:focus,
        .join-group-footer-btn:focus {
            outline: 3px solid rgba(255, 255, 255, 0.5);
            outline-offset: 2px;
        }
    </style>

    <div class="study-hub-page">
        <div class="hub-container">
            <div class="page-header">
                <h3 class="page-title">🎓 StudyHub Community</h3>
                <div class="header-actions">
                    <asp:Button ID="btnCreateGroup" runat="server" Text="➕ Create Group" CssClass="create-group-btn" OnClick="btnCreateGroup_Click" />
                    <asp:Button ID="btnJoinGroup" runat="server" Text="🔍 Discover Groups" CssClass="join-group-btn" OnClick="btnJoinGroup_Click" />
                    <asp:Button ID="btnMyGroups" runat="server" Text="📚 My Groups" CssClass="my-groups-btn" OnClick="btnMyGroups_Click" />
                </div>
            </div>

            <!-- Enhanced Filters Section -->
            <div class="filters-section">
                <div class="filters-title">🔍 Find Your Perfect Study Group</div>
                <div class="filter-controls">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box" placeholder="Search groups by name, subject, or topic..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" />
                    <asp:DropDownList ID="ddlSubject" runat="server" CssClass="filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlSubject_SelectedIndexChanged">
                        <asp:ListItem Value="">All Subjects</asp:ListItem>
                        <asp:ListItem Value="Mathematics">Mathematics</asp:ListItem>
                        <asp:ListItem Value="Science">Science</asp:ListItem>
                        <asp:ListItem Value="Programming">Programming</asp:ListItem>
                        <asp:ListItem Value="Languages">Languages</asp:ListItem>
                        <asp:ListItem Value="History">History</asp:ListItem>
                        <asp:ListItem Value="Business">Business</asp:ListItem>
                        <asp:ListItem Value="Other">Other</asp:ListItem>
                    </asp:DropDownList>
                    <asp:DropDownList ID="ddlSortBy" runat="server" CssClass="filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                        <asp:ListItem Value="newest">Newest First</asp:ListItem>
                        <asp:ListItem Value="oldest">Oldest First</asp:ListItem>
                        <asp:ListItem Value="popular">Most Popular</asp:ListItem>
                        <asp:ListItem Value="alphabetical">A-Z</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="groups-grid">
                <asp:Repeater ID="rptGroups" runat="server" OnItemCommand="rptGroups_ItemCommand">
                    <ItemTemplate>
                        <div class="group-card" style="--card-index: <%# Container.ItemIndex %>;">
                            <div class="group-image-container">
                                <img src='<%# Eval("groupImage") %>' class="group-image" alt="Group Image" onerror="this.src='Images/default-group.jpg'" />
                                <div class="group-image-overlay"></div>
                            </div>
                            
                            <div class="group-body">
                                <h5 class="group-title"><%# Eval("groupName") %></h5>
                                
                                <small class="group-meta">
                                    🧑‍🏫 Hosted by <%# Eval("hosterName") %>
                                </small>

                                <div class="group-description">
                                    <%# Eval("description") %>
                                </div>
                                
                                <div class="group-stats">
                                    <div class="stat-item">
                                        <span class="stat-icon">👥</span>
                                        <span><%# Eval("memberCount") %>/<%# Eval("capacity") %></span>
                                    </div>
                                    <div class="stat-item">
                                        <span class="stat-icon">📝</span>
                                        <span><%# Eval("postCount") %> posts</span>
                                    </div>
                                    <div class="stat-item">
                                        <span class="stat-icon">⏰</span>
                                        <span><%# Eval("lastActivity") %></span>
                                    </div>
                                </div>

                                <div class="group-tags">
                                    <%# !string.IsNullOrEmpty(Eval("subject").ToString()) ? "<span class='tag'>" + Eval("subject") + "</span>" : "" %>
                                    <%# (bool)Eval("isActive") ? "<span class='tag'>🟢 Active</span>" : "<span class='tag'>⚪ Inactive</span>" %>
                                </div>
                            </div>
                            
                            <div class="group-footer">
                                <a href='StudyHubGroup.aspx?groupId=<%# Eval("groupId") %>' class="view-group-btn">
                                    🚀 View Group
                                </a>
                                <asp:LinkButton ID="btnJoinGroupFooter" runat="server" 
                                    CommandName="JoinGroup" 
                                    CommandArgument='<%# Eval("groupId") %>' 
                                    CssClass="join-group-footer-btn"
                                    Visible='<%# !(bool)Eval("isMember") %>'>
                                    ➕ Join Group
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <!-- Show when no groups exist -->
                <asp:Panel ID="pnlNoGroups" runat="server" Visible="false" CssClass="no-groups">
                    <div class="no-groups-icon">📚</div>
                    <h3>No Study Groups Found</h3>
                    <p>Be the first to create a study group or adjust your search filters!</p>
                </asp:Panel>
            </div>
        </div>

        <!-- Floating Action Button -->
        <asp:Button ID="btnFloatingCreate" runat="server" Text="➕" CssClass="floating-action-btn" OnClick="btnCreateGroup_Click" ToolTip="Create New Group" />
    </div>

    <!-- Font Awesome for additional icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
</asp:Content>