<%@ Page Title="Study Hub" Language="C#" MasterPageFile="~/Site.master" Async="true" AutoEventWireup="true" CodeBehind="StudyHub.aspx.cs" Inherits="YourProjectNamespace.StudyHub" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Study Hub
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Study Hub with Modern Design */
        
        .study-hub-page {
            padding: 40px 20px;
            font-family: 'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        .study-hub-page::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 25% 75%, rgba(120, 119, 198, 0.4) 0%, transparent 60%),
                radial-gradient(circle at 75% 25%, rgba(255, 255, 255, 0.15) 0%, transparent 50%),
                radial-gradient(circle at 50% 50%, rgba(120, 119, 198, 0.25) 0%, transparent 70%);
            animation: backgroundFloat 25s ease-in-out infinite;
            z-index: -1;
        }

        @keyframes backgroundFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-15px, -25px) rotate(1deg); }
            50% { transform: translate(25px, -15px) rotate(-1deg); }
            75% { transform: translate(-20px, 15px) rotate(0.5deg); }
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
            margin-bottom: 50px;
            flex-wrap: wrap;
            gap: 25px;
            animation: slideInFromTop 1.2s cubic-bezier(0.23, 1, 0.320, 1);
        }

        @keyframes slideInFromTop {
            from { 
                opacity: 0; 
                transform: translateY(-60px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .page-title {
            font-size: clamp(36px, 6vw, 52px);
            font-weight: 800;
            color: #ffffff;
            text-shadow: 0 6px 12px rgba(0, 0, 0, 0.4);
            position: relative;
            display: inline-block;
            margin: 0;
            letter-spacing: -0.02em;
        }

        .page-title::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 80px;
            height: 5px;
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4, #45b7d1);
            border-radius: 3px;
            animation: expandWidth 1.8s ease-out 0.6s both;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 80px; }
        }

        .header-actions {
            display: flex;
            gap: 18px;
            align-items: center;
        }

        .create-group-btn, .join-group-btn, .my-groups-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 16px 32px;
            border-radius: 30px;
            cursor: pointer;
            font-weight: 700;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            font-size: 16px;
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.35);
            position: relative;
            overflow: hidden;
            backdrop-filter: blur(15px);
            border: 2px solid rgba(255, 255, 255, 0.25);
            letter-spacing: 0.02em;
        }

        .join-group-btn {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.35);
        }

        .my-groups-btn {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.35);
        }

        .create-group-btn::before, .join-group-btn::before, .my-groups-btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.25);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.8s cubic-bezier(0.4, 0, 0.2, 1);
            z-index: 0;
        }

        .create-group-btn:hover::before, .join-group-btn:hover::before, .my-groups-btn:hover::before {
            width: 350px;
            height: 350px;
        }

        .create-group-btn:hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 15px 40px rgba(103, 126, 234, 0.5);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        .join-group-btn:hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 15px 40px rgba(78, 205, 196, 0.5);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
        }

        .my-groups-btn:hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 15px 40px rgba(255, 107, 107, 0.5);
            background: linear-gradient(135deg, #ee5a52 0%, #ff6b6b 100%);
        }

        .filters-section {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(20px);
            border-radius: 25px;
            padding: 30px;
            margin-bottom: 40px;
            border: 2px solid rgba(255, 255, 255, 0.25);
            animation: slideInFromLeft 1.2s cubic-bezier(0.23, 1, 0.320, 1) 0.3s both;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        @keyframes slideInFromLeft {
            from { 
                opacity: 0; 
                transform: translateX(-60px); 
            }
            to { 
                opacity: 1; 
                transform: translateX(0); 
            }
        }

        .filters-title {
            color: white;
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 20px;
            letter-spacing: 0.02em;
        }

        .filter-controls {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            align-items: center;
        }

        .search-box {
            flex: 1;
            min-width: 280px;
            padding: 16px 24px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 30px;
            background: rgba(255, 255, 255, 0.15);
            color: white;
            font-size: 16px;
            font-weight: 500;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
            letter-spacing: 0.01em;
        }

        .search-box:focus {
            outline: none;
            border-color: rgba(255, 255, 255, 0.6);
            background: rgba(255, 255, 255, 0.2);
            box-shadow: 0 0 0 4px rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
        }

        .search-box::placeholder {
            color: rgba(255, 255, 255, 0.8);
            font-weight: 400;
        }

        .filter-dropdown {
            padding: 16px 24px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 30px;
            background: rgba(255, 255, 255, 0.9);
            color: #2c3e50;
            font-weight: 600;
            font-size: 16px;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
            cursor: pointer;
            min-width: 180px;
        }

        .filter-dropdown:focus {
            outline: none;
            border-color: rgba(255, 255, 255, 0.6);
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 0 0 4px rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
        }

        .filter-dropdown:hover {
            background: rgba(255, 255, 255, 0.95);
            border-color: rgba(255, 255, 255, 0.5);
            transform: translateY(-1px);
        }

        .filter-dropdown option {
            background: white;
            color: #2c3e50;
            font-weight: 500;
            padding: 10px;
        }

        .groups-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 35px;
            animation: slideInFromBottom 1.2s cubic-bezier(0.23, 1, 0.320, 1) 0.4s both;
        }

        @keyframes slideInFromBottom {
            from { 
                opacity: 0; 
                transform: translateY(60px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .group-card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(15px);
            border-radius: 25px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.12);
            overflow: hidden;
            transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            border: 2px solid rgba(255, 255, 255, 0.3);
            animation: cardEntrance 1s cubic-bezier(0.23, 1, 0.320, 1) both;
            animation-delay: calc(var(--card-index, 0) * 0.15s);
        }

        @keyframes cardEntrance {
            from { 
                opacity: 0; 
                transform: translateY(60px) rotate(1deg) scale(0.9); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0) rotate(0deg) scale(1); 
            }
        }

        .group-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4, #45b7d1);
            background-size: 500% 100%;
            animation: gradientShift 4s ease infinite;
            z-index: 1;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .group-card:hover {
            transform: translateY(-15px) scale(1.03);
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.2);
            background: rgba(255, 255, 255, 1);
        }

        .group-card:hover .group-image {
            transform: scale(1.15);
        }

        .group-card:hover .group-title {
            color: #667eea;
        }

        .group-image-container {
            width: 100%;
            height: 240px;
            overflow: hidden;
            position: relative;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        }

        .group-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .group-image-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(103, 126, 234, 0.15) 0%, rgba(118, 75, 162, 0.15) 100%);
            opacity: 0;
            transition: opacity 0.5s ease;
        }

        .group-card:hover .group-image-overlay {
            opacity: 1;
        }

        .group-body {
            padding: 30px;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .group-title {
            font-size: 24px;
            font-weight: 800;
            color: #2c3e50;
            margin: 0;
            line-height: 1.3;
            transition: color 0.4s ease;
            letter-spacing: -0.01em;
        }

        .group-meta {
            font-size: 16px;
            color: #6c757d;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0;
        }

        .group-meta::before {
            content: '';
            width: 8px;
            height: 8px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            flex-shrink: 0;
        }

        .group-description {
            font-size: 15px;
            color: #6c757d;
            line-height: 1.6;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            font-weight: 500;
        }

        .group-stats {
            display: flex;
            gap: 25px;
            margin-top: 10px;
            flex-wrap: wrap;
        }

        .stat-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 15px;
            color: #6c757d;
            font-weight: 600;
        }

        .stat-icon {
            font-size: 18px;
            color: #667eea;
        }

        .group-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 15px;
        }

        .tag {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 0.02em;
        }

        .group-footer {
            padding: 25px 30px;
            border-top: 2px solid rgba(236, 240, 241, 0.3);
            background: linear-gradient(135deg, rgba(248, 249, 250, 0.8) 0%, rgba(255, 255, 255, 0.6) 100%);
            display: flex;
            gap: 15px;
        }

        .view-group-btn, .join-group-footer-btn {
            border: none;
            padding: 14px 28px;
            border-radius: 30px;
            cursor: pointer;
            font-weight: 700;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            font-size: 15px;
            position: relative;
            overflow: hidden;
            flex: 1;
            justify-content: center;
            letter-spacing: 0.02em;
        }

        .view-group-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 6px 20px rgba(103, 126, 234, 0.4);
        }

        .join-group-footer-btn {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 6px 20px rgba(78, 205, 196, 0.4);
        }

        .view-group-btn::before, .join-group-footer-btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.25);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.8s ease;
            z-index: 0;
        }

        .view-group-btn:hover::before, .join-group-footer-btn:hover::before {
            width: 350px;
            height: 350px;
        }

        .view-group-btn:hover {
            transform: translateY(-3px) scale(1.05);
            box-shadow: 0 12px 35px rgba(103, 126, 234, 0.5);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            color: white;
            text-decoration: none;
        }

        .join-group-footer-btn:hover {
            transform: translateY(-3px) scale(1.05);
            box-shadow: 0 12px 35px rgba(78, 205, 196, 0.5);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
            color: white;
            text-decoration: none;
        }

        .no-groups {
            text-align: center;
            padding: 100px 50px;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(20px);
            border-radius: 25px;
            border: 2px solid rgba(255, 255, 255, 0.25);
            color: rgba(255, 255, 255, 0.95);
            grid-column: 1 / -1;
            animation: fadeInUp 1.2s cubic-bezier(0.23, 1, 0.320, 1) 0.8s both;
        }

        @keyframes fadeInUp {
            from { 
                opacity: 0; 
                transform: translateY(50px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .no-groups-icon {
            font-size: 80px;
            margin-bottom: 30px;
            opacity: 0.8;
            animation: iconFloat 4s ease-in-out infinite;
        }

        @keyframes iconFloat {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(8deg); }
        }

        .no-groups h3 {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 20px;
            color: rgba(255, 255, 255, 0.95);
            letter-spacing: -0.01em;
        }

        .no-groups p {
            font-size: 20px;
            color: rgba(255, 255, 255, 0.8);
            margin: 0;
            line-height: 1.6;
            font-weight: 500;
        }

        .floating-action-btn {
            position: fixed;
            bottom: 35px;
            right: 35px;
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            font-size: 28px;
            cursor: pointer;
            box-shadow: 0 10px 30px rgba(103, 126, 234, 0.5);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            z-index: 1000;
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.3);
        }

        .floating-action-btn:hover {
            transform: scale(1.15) rotate(90deg);
            box-shadow: 0 15px 45px rgba(103, 126, 234, 0.7);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        @media (max-width: 768px) {
            .study-hub-page {
                padding: 25px 15px;
            }

            .page-header {
                flex-direction: column;
                align-items: stretch;
                text-align: center;
                gap: 20px;
            }

            .header-actions {
                justify-content: center;
                flex-wrap: wrap;
            }

            .create-group-btn, .join-group-btn, .my-groups-btn {
                flex: 1;
                min-width: 170px;
                padding: 14px 20px;
                font-size: 15px;
            }

            .groups-grid {
                grid-template-columns: 1fr;
                gap: 25px;
            }

            .filter-controls {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }

            .search-box {
                min-width: auto;
            }

            .group-footer {
                flex-direction: column;
                gap: 12px;
            }

            .filters-section {
                padding: 25px;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 28px;
            }

            .group-card {
                border-radius: 20px;
            }

            .group-body {
                padding: 25px;
            }

            .group-footer {
                padding: 20px 25px;
            }

            .group-image-container {
                height: 200px;
            }

            .header-actions {
                flex-direction: column;
                gap: 12px;
            }

            .floating-action-btn {
                width: 60px;
                height: 60px;
                font-size: 24px;
                bottom: 25px;
                right: 25px;
            }
        }

        .loading-skeleton {
            background: linear-gradient(90deg, rgba(255,255,255,0.1) 25%, rgba(255,255,255,0.2) 50%, rgba(255,255,255,0.1) 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
        }

        @keyframes loading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }

        .create-group-btn:focus,
        .join-group-btn:focus,
        .my-groups-btn:focus,
        .view-group-btn:focus,
        .join-group-footer-btn:focus {
            outline: 3px solid rgba(255, 255, 255, 0.6);
            outline-offset: 3px;
        }

        .search-box:focus,
        .filter-dropdown:focus {
            outline: 3px solid rgba(255, 255, 255, 0.4);
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
                
                <asp:Panel ID="pnlNoGroups" runat="server" Visible="false" CssClass="no-groups">
                    <div class="no-groups-icon">📚</div>
                    <h3>No Study Groups Found</h3>
                    <p>Be the first to create a study group or adjust your search filters!</p>
                </asp:Panel>
            </div>
        </div>

        <asp:Button ID="btnFloatingCreate" runat="server" Text="➕" CssClass="floating-action-btn" OnClick="btnCreateGroup_Click" ToolTip="Create New Group" />
    </div>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
</asp:Content>