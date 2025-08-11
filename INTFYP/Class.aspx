<%@ Page Title="My Classes"
    Language="C#"
    MasterPageFile="~/Site.master"
    AutoEventWireup="true"
    CodeBehind="Class.aspx.cs"
    Inherits="YourProjectNamespace.Class"
    Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Classes
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Enhanced Classes Page with Design Formula */
        
        .classes-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements */
        .classes-page::before {
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

        .classes-container {
            max-width: 900px;
            margin: 0 auto;
            position: relative;
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
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 60px; }
        }

        .classes-list {
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

        .class-card {
            display: flex;
            align-items: center;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 25px;
            margin-bottom: 20px;
            border-radius: 20px;
            gap: 20px;
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
                transform: translateX(-50px) rotate(-2deg); 
            }
            to { 
                opacity: 1; 
                transform: translateX(0) rotate(0deg); 
            }
        }

        .class-card::before {
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

        .class-card:hover {
            transform: translateY(-8px) translateX(5px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 1);
        }

        .class-card:hover .class-image {
            transform: scale(1.1) rotate(5deg);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.3);
        }

        .class-image {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.2);
        }

        .class-image::before {
            content: '📚';
            font-size: 40px;
            opacity: 0.9;
            animation: iconFloat 3s ease-in-out infinite;
        }

        @keyframes iconFloat {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-5px) rotate(5deg); }
        }

        .class-details {
            flex-grow: 1;
            min-width: 0;
        }

        .class-details h5 {
            margin: 0 0 10px 0;
            font-size: 22px;
            font-weight: 700;
            color: #2c3e50;
            line-height: 1.3;
            transition: color 0.3s ease;
        }

        .class-card:hover .class-details h5 {
            color: #667eea;
        }

        .class-meta {
            font-size: 15px;
            color: #7f8c8d;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 8px;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 15px;
            font-size: 13px;
            font-weight: 600;
            margin-top: 8px;
        }

        .status-created {
            background: rgba(103, 126, 234, 0.1);
            color: #667eea;
            border: 1px solid rgba(103, 126, 234, 0.2);
        }

        .status-invited {
            background: rgba(255, 107, 107, 0.1);
            color: #ff6b6b;
            border: 1px solid rgba(255, 107, 107, 0.2);
        }

        .status-accepted {
            background: rgba(78, 205, 196, 0.1);
            color: #4ecdc4;
            border: 1px solid rgba(78, 205, 196, 0.2);
        }

        .class-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 12px 20px;
            border-radius: 25px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            min-width: 100px;
            justify-content: center;
        }

        .btn::before {
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

        .btn:hover::before {
            width: 300px;
            height: 300px;
        }

        .btn:hover {
            transform: translateY(-2px);
        }

        .btn:active {
            transform: translateY(0);
        }

        .btn-join {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .btn-join:hover {
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        .btn-enter {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .btn-enter:hover {
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
        }

        .btn-decline {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
        }

        .btn-decline:hover {
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.4);
            background: linear-gradient(135deg, #ee5a52 0%, #ff6b6b 100%);
        }

        .btn-view {
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            border: 2px solid rgba(103, 126, 234, 0.3);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        .btn-view:hover {
            background: rgba(103, 126, 234, 0.1);
            border-color: #667eea;
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.2);
        }

        .no-classes {
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

        .no-classes-icon {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.7;
            animation: iconBounce 2s ease-in-out infinite;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .no-classes h3 {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 10px;
            color: rgba(255, 255, 255, 0.9);
        }

        .no-classes p {
            font-size: 16px;
            color: rgba(255, 255, 255, 0.7);
            margin: 0;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .classes-page {
                padding: 30px 15px;
            }

            .class-card {
                flex-direction: column;
                text-align: center;
                padding: 20px;
            }

            .class-image {
                width: 80px;
                height: 80px;
            }

            .class-actions {
                justify-content: center;
                width: 100%;
            }

            .btn {
                min-width: 120px;
            }
        }

        @media (max-width: 480px) {
            .class-card {
                margin-bottom: 15px;
                border-radius: 15px;
            }

            .class-actions {
                flex-direction: column;
                gap: 10px;
            }

            .btn {
                width: 100%;
            }

            .page-title {
                font-size: 32px;
            }
        }

        /* Loading states */
        .class-card.loading {
            opacity: 0;
            animation: cardLoad 0.6s ease-out forwards;
        }

        @keyframes cardLoad {
            to { opacity: 1; }
        }

        /* Pulse effect for pending actions */
        .status-invited .class-card::before {
            animation: gradientShift 1.5s ease infinite, pulse 2s ease infinite;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(255, 107, 107, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(255, 107, 107, 0); }
            100% { box-shadow: 0 0 0 0 rgba(255, 107, 107, 0); }
        }
    </style>

    <div class="classes-page">
        <div class="classes-container">
            <div class="page-header">
                <h2 class="page-title">Your Classes</h2>
            </div>

            <asp:Panel ID="pnlNoClasses" runat="server" Visible="false" CssClass="no-classes">
                <div class="no-classes-icon">🎓</div>
                <h3>No Classes Yet</h3>
                <p>You don't have any classes yet. Create one or wait for an invitation!</p>
            </asp:Panel>

            <div class="classes-list">
                <asp:Repeater ID="rptClasses" runat="server" OnItemCommand="rptClasses_ItemCommand">
                    <ItemTemplate>
                        <div class="class-card" style="--card-index: <%# Container.ItemIndex %>;">
                            <div class="class-image"></div>
                            
                            <div class="class-details">
                                <h5><%# Eval("name") %></h5>
                                
                                <div class="class-meta">
                                    <%# Eval("origin").ToString() == "created" 
                                            ? "🧑‍🏫 Created By You" 
                                            : $"📩 Invited by {Eval("createdByName")}" %>
                                </div>
                                
                                <div class="status-badge <%# "status-" + (Eval("origin").ToString() == "created" ? "created" : 
                                    (Eval("status").ToString() == "pending" ? "invited" : "accepted")) %>">
                                    <%# Eval("origin").ToString() == "created" ? "👨‍🏫 Owner" : 
                                        (Eval("status").ToString() == "pending" ? "⏳ Pending" : "✅ Joined") %>
                                </div>
                            </div>

                            <div class="class-actions">
                                <asp:Panel runat="server" Visible='<%# Eval("origin").ToString() == "invited" && Eval("status").ToString() == "pending" %>'>
                                    <asp:Button ID="btnJoin" runat="server" Text="✅ Join"
                                                CommandName="Join"
                                                CommandArgument='<%# Eval("classId") %>'
                                                CssClass="btn btn-join" />
                                    <asp:Button ID="btnDecline" runat="server" Text="❌ Decline"
                                                CommandName="Decline"
                                                CommandArgument='<%# Eval("classId") %>'
                                                CssClass="btn btn-decline" />
                                </asp:Panel>

                                <asp:Panel runat="server" Visible='<%# Eval("origin").ToString() == "invited" && Eval("status").ToString() == "accepted" %>'>
                                    <asp:Button ID="btnEnter" runat="server" Text="🚀 Enter"
                                                CommandName="Enter"
                                                CommandArgument='<%# Eval("classId") %>'
                                                CssClass="btn btn-enter" />
                                </asp:Panel>

                                <asp:Panel runat="server" Visible='<%# Eval("origin").ToString() == "created" %>'>
                                    <asp:Button ID="btnView" runat="server" Text="👁️ View"
                                                CommandName="View"
                                                CommandArgument='<%# Eval("classId") %>'
                                                CssClass="btn btn-view" />
                                </asp:Panel>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- Font Awesome for additional icons if needed -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>