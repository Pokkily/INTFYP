<%@ Page Title="Chat Room" Language="C#" MasterPageFile="~/Site.master" 
    AutoEventWireup="true" CodeBehind="ChatRoom.aspx.cs" 
    Inherits="YourProjectNamespace.ChatRoom" Async="true" %>

<asp:Content ID="ChatContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Modern Design System Implementation - Following Library Style */
        .chat-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animated background elements - From Library */
        .chat-page::before {
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

        .chat-container {
            display: flex;
            max-width: 1400px;
            margin: 0 auto;
            gap: 20px;
            position: relative;
            height: calc(100vh - 160px);
        }

        .page-header {
            text-align: center;
            margin-bottom: 30px;
            animation: slideInFromTop 1s ease-out;
        }

        .page-title {
            font-size: clamp(28px, 4vw, 42px);
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
            overflow: hidden;
            animation: slideInFromBottom 0.8s ease-out;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
        }

        .glass-card::before {
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

        .glass-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .sidebar {
            width: 380px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
        }

        .sidebar-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }

        .sidebar-header h3 {
            margin: 0 0 10px 0;
            font-weight: 600;
        }

        .sidebar-tabs {
            display: flex;
            background: rgba(248, 249, 250, 0.9);
            backdrop-filter: blur(5px);
            border-bottom: 1px solid rgba(233, 236, 239, 0.8);
        }

        .tab-btn {
            flex: 1;
            padding: 12px 16px;
            background: none;
            border: none;
            cursor: pointer;
            font-weight: 500;
            font-size: 14px;
            color: #6c757d;
            transition: all 0.3s ease;
            outline: none;
        }

        .tab-btn.active {
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            border-bottom: 2px solid #667eea;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
        }

        .tab-btn:hover:not(.active) {
            background: rgba(233, 236, 239, 0.7);
            color: #495057;
            transform: translateY(-1px);
        }

        .tab-content {
            display: none;
            flex: 1;
            flex-direction: column;
            overflow: hidden;
        }

        .tab-content.active {
            display: flex;
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
            box-sizing: border-box;
        }

        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.3);
            outline: none;
            transform: scale(1.02);
        }

        .primary-button {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            padding: 12px 24px;
            border-radius: 25px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: none;
            cursor: pointer;
            font-size: 14px;
            position: relative;
            overflow: hidden;
        }

        .primary-button::before {
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

        .primary-button:hover::before {
            width: 300px;
            height: 300px;
        }

        .primary-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
        }

        .secondary-button {
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            border: 1px solid rgba(103, 126, 234, 0.3);
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .secondary-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(103, 126, 234, 0.1);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .secondary-button:hover::before {
            width: 200px;
            height: 200px;
        }

        .secondary-button:hover {
            background: #667eea;
            color: white;
            transform: scale(1.05);
        }

        .success-button {
            background: linear-gradient(45deg, #56ab2f, #a8e6cf);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .success-button::before {
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

        .success-button:hover::before {
            width: 200px;
            height: 200px;
        }

        .success-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(86, 171, 47, 0.4);
        }

        .danger-button {
            background: linear-gradient(45deg, #ff6b6b, #ee5a52);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 12px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .danger-button::before {
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

        .danger-button:hover::before {
            width: 200px;
            height: 200px;
        }

        .danger-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.4);
        }

        .room-item {
            padding: 15px 20px;
            border-bottom: 1px solid rgba(241, 243, 244, 0.8);
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            justify-content: space-between;
            align-items: center;
            backdrop-filter: blur(5px);
            position: relative;
            overflow: hidden;
            animation: cardEntrance 0.8s ease-out both;
            animation-delay: calc(var(--room-index, 0) * 0.1s);
        }

        @keyframes cardEntrance {
            from { 
                opacity: 0; 
                transform: translateX(-30px) rotate(-1deg); 
            }
            to { 
                opacity: 1; 
                transform: translateX(0) rotate(0deg); 
            }
        }

        .room-item::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(102, 126, 234, 0.1);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
            z-index: -1;
        }

        .room-item:hover::before {
            width: 400px;
            height: 400px;
        }

        .room-item:hover {
            background: rgba(248, 249, 250, 0.8);
            transform: translateX(5px) translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }

        .room-item.active {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            border-left: 4px solid #667eea;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.2);
        }

        .room-info h4 {
            margin: 0 0 5px 0;
            font-size: 16px;
            font-weight: 600;
            color: #2c3e50;
        }

        .room-info p {
            margin: 0;
            font-size: 12px;
            color: #7f8c8d;
        }

        .room-status {
            font-size: 11px;
            padding: 4px 8px;
            border-radius: 15px;
            font-weight: 500;
        }

        .room-status.joined {
            background: linear-gradient(45deg, #56ab2f, #a8e6cf);
            color: white;
        }

        .room-status.private {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
        }

        .room-count {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            border-radius: 15px;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .main-chat {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 20px 20px 0 0;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        .chat-title {
            margin: 0;
            font-size: 20px;
            font-weight: 600;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .chat-members {
            font-size: 14px;
            opacity: 0.9;
        }

        .manage-btn, .leave-btn {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            backdrop-filter: blur(5px);
        }

        .manage-btn:hover, .leave-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.05);
        }

        .messages-container {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: linear-gradient(135deg, rgba(248, 249, 250, 0.9) 0%, rgba(255, 255, 255, 0.9) 100%);
            backdrop-filter: blur(10px);
            border-radius: 0 0 20px 20px;
            scroll-behavior: smooth;
        }

        .messages-container::-webkit-scrollbar {
            width: 8px;
        }

        .messages-container::-webkit-scrollbar-track {
            background: rgba(241, 243, 244, 0.5);
            border-radius: 10px;
        }

        .messages-container::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 10px;
        }

        .message {
            margin-bottom: 20px;
            display: flex;
            gap: 12px;
            max-width: 100%;
            animation: messageSlideIn 0.3s ease-out;
            position: relative;
        }

        .message.own {
            flex-direction: row-reverse;
        }

        /* NEW: Deleted message styling */
        .message.deleted {
            opacity: 0.6;
        }

        .message.deleted .message-content {
            background: rgba(241, 243, 244, 0.8) !important;
            color: #7f8c8d !important;
            font-style: italic;
        }

        .message-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 14px;
            flex-shrink: 0;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        .message.own .message-avatar {
            background: linear-gradient(135deg, #56ab2f, #a8e6cf);
        }

        .message-content {
            max-width: 70%;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 15px 20px;
            border-radius: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            word-wrap: break-word;
            overflow-wrap: break-word;
            position: relative;
        }

        .message.own .message-content {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }

        /* NEW: Message actions (delete button) */
        .message-actions {
            position: absolute;
            top: 8px;
            right: 8px;
            opacity: 0;
            transition: all 0.3s ease;
            display: flex;
            gap: 4px;
        }

        .message:hover .message-actions {
            opacity: 1;
        }

        .message-delete-btn {
            background: rgba(255, 107, 107, 0.9);
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            cursor: pointer;
            font-size: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
        }

        .message-delete-btn:hover {
            background: rgba(255, 107, 107, 1);
            transform: scale(1.1);
            box-shadow: 0 4px 12px rgba(255, 107, 107, 0.5);
        }

        /* For own messages in dark background */
        .message.own .message-delete-btn {
            background: rgba(0, 0, 0, 0.3);
        }

        .message.own .message-delete-btn:hover {
            background: rgba(255, 107, 107, 0.9);
        }

        .message-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;
            padding-right: 30px; /* Space for delete button */
        }

        .message-sender {
            font-weight: 600;
            font-size: 13px;
        }

        .message-time {
            font-size: 11px;
            opacity: 0.7;
        }

        .message-text {
            font-size: 14px;
            line-height: 1.5;
            word-wrap: break-word;
        }

        /* File message styles */
        .message-file {
            margin-top: 10px;
            padding: 12px;
            background: rgba(248, 249, 250, 0.5);
            border-radius: 10px;
            border: 1px solid rgba(233, 236, 239, 0.8);
        }

        .message.own .message-file {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.3);
        }

        .file-preview {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .file-icon {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            font-size: 18px;
        }

        .file-icon.pdf {
            background: linear-gradient(45deg, #ff6b6b, #ee5a52);
            color: white;
        }

        .file-icon.image {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
        }

        .file-info {
            flex: 1;
        }

        .file-name {
            font-weight: 500;
            font-size: 13px;
            margin-bottom: 2px;
        }

        .file-size {
            font-size: 11px;
            opacity: 0.7;
        }

        .file-image {
            max-width: 200px;
            max-height: 150px;
            border-radius: 8px;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .file-image:hover {
            transform: scale(1.05);
        }

        .message-input-area {
            padding: 20px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-top: 1px solid rgba(233, 236, 239, 0.8);
            border-radius: 0 0 20px 20px;
        }

        .input-group {
            display: flex;
            gap: 12px;
            align-items: flex-end;
        }

        .message-input {
            flex: 1;
            padding: 15px 20px;
            border: 1px solid rgba(103, 126, 234, 0.2);
            border-radius: 25px;
            font-size: 14px;
            resize: none;
            min-height: 20px;
            max-height: 100px;
            overflow-y: auto;
            box-sizing: border-box;
            font-family: inherit;
            background: rgba(255, 255, 255, 0.9);
            transition: all 0.3s ease;
        }

        .message-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.3);
            transform: scale(1.02);
        }

        .file-upload-btn {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            border: none;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            font-weight: bold;
            position: relative;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
            overflow: hidden;
        }

        .file-upload-btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .file-upload-btn:hover::before {
            width: 200px;
            height: 200px;
        }

        .file-upload-btn:hover {
            transform: scale(1.1) rotate(3deg);
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
        }

        .send-btn {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-size: 18px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
        }

        .send-btn::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .send-btn:hover::before {
            width: 200px;
            height: 200px;
        }

        .send-btn:hover {
            transform: scale(1.1) rotate(-3deg);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }

        .empty-state {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            color: #7f8c8d;
            text-align: center;
            padding: 60px 20px;
            background: linear-gradient(135deg, rgba(248, 249, 250, 0.9) 0%, rgba(255, 255, 255, 0.9) 100%);
            border-radius: 20px;
            backdrop-filter: blur(10px);
        }

        .empty-state h3 {
            font-size: 24px;
            margin-bottom: 15px;
            color: #2c3e50;
        }

        .status-message {
            padding: 12px 16px;
            margin: 8px 0;
            border-radius: 10px;
            font-size: 13px;
            display: none;
            backdrop-filter: blur(5px);
            animation: statusSlideIn 0.5s ease-out;
        }

        .status-message.show {
            display: block;
        }

        .text-success { 
            background: rgba(86, 171, 47, 0.1);
            color: #2d5016;
            border: 1px solid rgba(86, 171, 47, 0.3);
        }

        .text-danger { 
            background: rgba(255, 107, 107, 0.1);
            color: #721c24; 
            border: 1px solid rgba(255, 107, 107, 0.3);
        }

        .text-warning { 
            background: rgba(255, 193, 7, 0.1);
            color: #856404; 
            border: 1px solid rgba(255, 193, 7, 0.3);
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(5px);
        }

        .modal-content {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            margin: 5% auto;
            padding: 0;
            border: 1px solid rgba(255, 255, 255, 0.2);
            width: 90%;
            max-width: 600px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            animation: modalSlideIn 0.3s ease-out;
        }

        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 20px 20px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            margin: 0;
            font-weight: 600;
        }

        .close {
            color: white;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .close:hover {
            opacity: 0.7;
            transform: scale(1.1);
        }

        .modal-body {
            padding: 25px;
        }

        .member-list {
            max-height: 400px;
            overflow-y: auto;
        }

        .member-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid rgba(233, 236, 239, 0.8);
            transition: all 0.3s ease;
        }

        .member-item:hover {
            background: rgba(248, 249, 250, 0.8);
            transform: translateX(5px);
        }

        .member-item:last-child {
            border-bottom: none;
        }

        .member-details {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .member-role {
            background: rgba(233, 236, 239, 0.8);
            color: #495057;
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: 500;
        }

        .member-role.admin {
            background: linear-gradient(45deg, #56ab2f, #a8e6cf);
            color: white;
        }

        .loading-members {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
        }

        .loading-spinner {
            display: inline-block;
            width: 40px;
            height: 40px;
            border: 3px solid rgba(103, 126, 234, 0.3);
            border-top: 3px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 15px;
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

        @keyframes messageSlideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes statusSlideIn {
            from {
                opacity: 0;
                transform: translateX(20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-50px) scale(0.9);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .chat-container {
                flex-direction: column;
                height: auto;
                gap: 15px;
            }
            
            .sidebar {
                width: 100%;
                max-height: 300px;
            }
            
            .main-chat {
                min-height: 500px;
            }
            
            .message-content {
                max-width: 85%;
            }

            .modal-content {
                width: 95%;
                margin: 10% auto;
            }
        }

        /* Utility Classes */
        .form-group { margin-bottom: 15px; }
        .search-section { padding: 15px 20px; border-bottom: 1px solid rgba(233, 236, 239, 0.8); background: rgba(248, 249, 250, 0.9); }
        .create-room-section { padding: 20px; border-bottom: 1px solid rgba(233, 236, 239, 0.8); }
        .start-chat-section { padding: 20px; border-bottom: 1px solid rgba(233, 236, 239, 0.8); }
        .rooms-list { flex: 1; overflow-y: auto; padding: 0; }
        .search-input { width: 100%; padding: 10px 12px 10px 35px; border: 1px solid rgba(103, 126, 234, 0.2); border-radius: 25px; font-size: 13px; box-sizing: border-box; background: rgba(255, 255, 255, 0.9); }
        .search-box { position: relative; }
        .search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #667eea; }
        .user-search-result { padding: 12px 15px; border: 1px solid rgba(233, 236, 239, 0.8); border-radius: 10px; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center; background: rgba(255, 255, 255, 0.5); }
        .user-info { display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; border-radius: 50%; background: linear-gradient(135deg, #667eea, #764ba2); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 12px; }
        .room-controls { display: flex; gap: 10px; align-items: center; }
    </style>

    <div class="chat-page">
        <div class="page-header">
            <h2 class="page-title">💬 Chat Rooms</h2>
            <p class="page-subtitle">Connect and communicate with your community</p>
        </div>

        <div class="chat-container">
            <!-- Enhanced Sidebar -->
            <div class="sidebar glass-card">
                <div class="sidebar-header">
                    <h3>Chat Rooms</h3>
                    <p>Create rooms and chat with others</p>
                    <div style="margin-top: 15px; display: flex; gap: 10px; justify-content: center;">
                        <span class="room-count">My Rooms: <asp:Label ID="lblMyRoomCount" runat="server" Text="0" /></span>
                        <span class="room-count">Private Chats: <asp:Label ID="lblPrivateChatCount" runat="server" Text="0" /></span>
                    </div>
                </div>

                <!-- Sidebar Tabs -->
                <div class="sidebar-tabs">
                    <button type="button" class="tab-btn active" data-tab="my-rooms">My Rooms</button>
                    <button type="button" class="tab-btn" data-tab="private-chat">Private Chat</button>
                    <button type="button" class="tab-btn" data-tab="create-room">Create</button>
                </div>

                <!-- My Rooms Tab -->
                <div class="tab-content active" id="my-rooms-tab">
                    <!-- Search My Rooms -->
                    <div class="search-section">
                        <div class="search-box">
                            <asp:TextBox ID="txtSearchMyRooms" runat="server" CssClass="search-input" 
                                       placeholder="Search my rooms..." />
                            <span class="search-icon">🔍</span>
                        </div>
                    </div>

                    <!-- My Rooms List -->
                    <div class="rooms-list" id="myRoomsList">
                        <asp:Repeater ID="rptMyRooms" runat="server">
                            <ItemTemplate>
                                <div class="room-item" data-room-id='<%# Eval("Id") %>' data-room-name='<%# Eval("Name") %>' data-room-type="my">
                                    <div class="room-info">
                                        <h4><%# Eval("Name") %></h4>
                                        <p><%# Eval("MemberCount") %> members • <%# Eval("LastActivity") %></p>
                                    </div>
                                    <div class="room-actions">
                                        <span class="room-status joined">Group</span>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:Panel ID="pnlNoMyRooms" runat="server" style="padding: 40px 20px; text-align: center; color: #7f8c8d;">
                            <h4>No Rooms Yet</h4>
                            <p>Create a room or start private chats to get started!</p>
                        </asp:Panel>
                    </div>
                </div>

                <!-- Private Chat Tab -->
                <div class="tab-content" id="private-chat-tab">
                    <!-- Start New Chat Section -->
                    <div class="start-chat-section">
                        <h4 style="margin: 0 0 15px 0; color: #2c3e50; font-size: 16px;">Start New Private Chat</h4>
                        
                        <div class="form-group">
                            <label class="form-label">Search by Email</label>
                            <div style="display: flex; gap: 8px;">
                                <asp:TextBox ID="txtUserSearch" runat="server" CssClass="form-control" 
                                           placeholder="Enter email address" style="flex: 1;" />
                                <asp:Button ID="btnSearchUser" runat="server" Text="Search" 
                                          CssClass="primary-button" OnClick="btnSearchUser_Click" />
                            </div>
                        </div>

                        <!-- User Search Results -->
                        <asp:Panel ID="pnlUserSearchResults" runat="server" Visible="false">
                            <asp:Repeater ID="rptUserSearchResults" runat="server" OnItemCommand="rptUserSearchResults_ItemCommand">
                                <ItemTemplate>
                                    <div class="user-search-result">
                                        <div class="user-info">
                                            <div class="user-avatar">
                                                <%# GetInitials(Eval("Name").ToString()) %>
                                            </div>
                                            <div>
                                                <div style="font-weight: 500;"><%# Eval("Name") %></div>
                                                <div style="font-size: 12px; color: #7f8c8d;"><%# Eval("Email") %></div>
                                            </div>
                                        </div>
                                        <asp:Button runat="server" Text="Chat" CommandName="StartChat" 
                                                  CommandArgument='<%# Eval("Email") %>' 
                                                  CssClass="success-button" />
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                        
                        <asp:Label ID="lblSearchStatus" runat="server" CssClass="status-message" />
                    </div>

                    <!-- Private Chats List -->
                    <div class="rooms-list" id="privateChatsList">
                        <asp:Repeater ID="rptPrivateChats" runat="server">
                            <ItemTemplate>
                                <div class="room-item" data-room-id='<%# Eval("Id") %>' data-room-name='<%# Eval("Name") %>' data-room-type="private">
                                    <div class="room-info">
                                        <h4><%# Eval("Name") %></h4>
                                        <p><%# Eval("LastActivity") %></p>
                                    </div>
                                    <div class="room-actions">
                                        <span class="room-status private">Private</span>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:Panel ID="pnlNoPrivateChats" runat="server" style="padding: 40px 20px; text-align: center; color: #7f8c8d;">
                            <h4>No Private Chats</h4>
                            <p>Search for users and start chatting!</p>
                        </asp:Panel>
                    </div>
                </div>

                <!-- Create Room Tab -->
                <div class="tab-content" id="create-room-tab">
                    <div class="create-room-section">
                        <h4 style="margin: 0 0 15px 0; color: #2c3e50; font-size: 16px;">Create New Room</h4>
                        
                        <div class="form-group">
                            <label class="form-label">Room Name</label>
                            <asp:TextBox ID="txtRoomName" runat="server" CssClass="form-control" placeholder="Enter room name" />
                        </div>

                        <asp:Button ID="btnCreateRoom" runat="server" Text="✨ Create Room" 
                                  CssClass="primary-button" OnClick="btnCreateRoom_Click" style="width: 100%;" />
                        
                        <asp:Label ID="lblCreateStatus" runat="server" CssClass="status-message" />
                    </div>
                </div>
            </div>

            <!-- Main Chat Area -->
            <div class="main-chat glass-card">
                <!-- No Room Selected State -->
                <asp:Panel ID="pnlNoRoom" runat="server" CssClass="empty-state" Visible="true">
                    <h3>Welcome to Chat Rooms</h3>
                    <p>Select a room from the sidebar to start chatting, or create/start new chats</p>
                    <div style="margin-top: 20px; color: #2c3e50;">
                        <p><strong>Getting Started:</strong></p>
                        <p>• Start private chats with other users by searching their email</p>
                        <p>• Create group rooms and invite others</p>
                        <p>• Share files and images in your conversations</p>
                        <p>• Switch between multiple conversations</p>
                    </div>
                </asp:Panel>

                <!-- Chat Interface -->
                <asp:Panel ID="pnlChatInterface" runat="server" Visible="false" style="display: flex; flex-direction: column; height: 100%;">
                    <!-- Chat Header -->
                    <div class="chat-header">
                        <div>
                            <h2 class="chat-title">
                                <asp:Label ID="lblCurrentRoom" runat="server" />
                            </h2>
                            <div class="chat-members">
                                <asp:Label ID="lblMemberCount" runat="server" />
                            </div>
                        </div>
                        <div class="room-controls">
                            <!-- Management button -->
                            <asp:Panel ID="pnlManageButton" runat="server" Visible="false">
                                <button type="button" class="manage-btn" onclick="showManageModal(); return false;">
                                    <i class="fas fa-cog"></i> Manage
                                </button>
                            </asp:Panel>
                            
                            <!-- Leave button (hidden for private chats) -->
                            <asp:Button ID="btnLeaveRoom" runat="server" Text="Leave Chat" 
                                      CssClass="leave-btn" OnClick="btnLeaveRoom_Click" 
                                      OnClientClick="return confirm('Are you sure you want to leave this chat?');" 
                                      Visible="false" />
                        </div>
                    </div>

                    <!-- Messages Container -->
                    <div class="messages-container" id="messagesContainer">
                        <asp:Repeater ID="rptMessages" runat="server">
                            <ItemTemplate>
                                <div class="message <%# GetMessageClass(Eval("SenderId").ToString(), Eval("Type").ToString()) %> <%# Eval("IsDeleted").ToString().ToLower() == "true" ? "deleted" : "" %>">
                                    <div class="message-avatar">
                                        <%# GetInitials(Eval("SenderName").ToString()) %>
                                    </div>
                                    <div class="message-content">
                                        <!-- NEW: Message actions (delete button) for own messages only -->
                                        <%# Eval("SenderId").ToString() == GetCurrentUserEmail() && Eval("IsDeleted").ToString().ToLower() != "true" ? 
                                            "<div class=\"message-actions\">" +
                                            "<button type=\"button\" class=\"message-delete-btn\" onclick=\"deleteMessage('" + Eval("Id") + "'); return false;\" title=\"Delete message\">×</button>" +
                                            "</div>" : "" %>
                                        
                                        <div class="message-header">
                                            <span class="message-sender"><%# Eval("SenderName") %></span>
                                            <span class="message-time"><%# Eval("FormattedTime") %></span>
                                        </div>
                                        
                                        <!-- Text Content -->
                                        <%# Eval("IsDeleted").ToString().ToLower() == "true" ? 
                                            "<div class='message-text'>This message was deleted</div>" : 
                                            (!string.IsNullOrEmpty(Eval("Content").ToString()) ? "<div class='message-text'>" + Eval("Content") + "</div>" : "") %>
                                        
                                        <!-- File Content (only show if not deleted) -->
                                        <%# Eval("IsDeleted").ToString().ToLower() != "true" && !string.IsNullOrEmpty(Eval("FileUrl").ToString()) ? 
                                            GetFileContent(Eval("FileUrl").ToString(), Eval("FileName").ToString(), Eval("FileType").ToString()) : "" %>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <!-- Message Input -->
                    <div class="message-input-area">
                        <div class="input-group">
                            <asp:TextBox ID="txtMessage" runat="server" CssClass="message-input" 
                                       placeholder="Type your message..." TextMode="MultiLine" Rows="1" />
                            
                            <!-- File Upload Button with + icon -->
                            <div class="file-upload-btn" title="Attach file">
                                +
                                <asp:FileUpload ID="fileUpload" runat="server" accept=".pdf,.png,.jpg,.jpeg,.gif" 
                                              onchange="handleFileSelect(this)" style="position: absolute; width: 100%; height: 100%; opacity: 0; cursor: pointer;" />
                            </div>
                            
                            <asp:Button ID="btnSend" runat="server" CssClass="send-btn" Text="➤" OnClick="btnSend_Click" />
                        </div>
                        
                        <!-- File Upload Status -->
                        <div id="fileUploadStatus" style="margin-top: 10px; display: none;">
                            <div style="background: rgba(255, 255, 255, 0.9); padding: 10px; border-radius: 10px; border: 1px solid rgba(103, 126, 234, 0.2);">
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div style="flex: 1;">
                                        <div id="fileName" style="font-weight: 500; font-size: 13px;"></div>
                                        <div id="fileSize" style="font-size: 11px; color: #7f8c8d;"></div>
                                    </div>
                                    <button type="button" onclick="clearFileUpload()" style="background: #ff6b6b; color: white; border: none; border-radius: 50%; width: 24px; height: 24px; cursor: pointer;">×</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>

        <!-- Room Management Modal -->
        <div id="manageModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Manage Room</h3>
                    <span class="close" onclick="closeManageModal()">&times;</span>
                </div>
                <div class="modal-body">
                    <!-- Invite Section -->
                    <div style="margin-bottom: 25px;">
                        <h4>Invite Members</h4>
                        <div class="form-group">
                            <label class="form-label">Email Address</label>
                            <div style="display: flex; gap: 8px;">
                                <asp:TextBox ID="txtInviteEmail" runat="server" CssClass="form-control" 
                                           placeholder="Enter email address" style="flex: 1;" />
                                <asp:Button ID="btnInviteUser" runat="server" Text="Invite" 
                                          CssClass="success-button" OnClick="btnInviteUser_Click" />
                            </div>
                        </div>
                        <asp:Label ID="lblInviteStatus" runat="server" CssClass="status-message" />
                    </div>

                    <!-- Members List -->
                    <div>
                        <h4>Current Members</h4>
                        <div id="membersLoadingDiv" class="loading-members">
                            <div class="loading-spinner"></div>
                            <p>Loading members...</p>
                        </div>
                        <div class="member-list" id="membersList" style="display: none;">
                            <asp:Repeater ID="rptMembers" runat="server" OnItemCommand="rptMembers_ItemCommand">
                                <ItemTemplate>
                                    <div class="member-item">
                                        <div class="member-details">
                                            <div class="user-avatar">
                                                <%# GetInitials(Eval("Name").ToString()) %>
                                            </div>
                                            <div>
                                                <div style="font-weight: 500;"><%# Eval("Name") %></div>
                                                <div style="font-size: 12px; color: #7f8c8d;"><%# Eval("Email") %></div>
                                            </div>
                                            <span class="member-role <%# Eval("Role") %>"><%# Eval("Role") %></span>
                                        </div>
                                        <div>
                                            <asp:Button runat="server" Text="Remove" CommandName="KickMember" 
                                                      CommandArgument='<%# Eval("Email") %>' 
                                                      CssClass="danger-button" 
                                                      Visible='<%# Eval("CanRemove") %>'
                                                      OnClientClick="return confirm('Remove this member?');" />
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden fields -->
    <asp:HiddenField ID="hfCurrentRoomId" runat="server" />
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="my-rooms" />
    <asp:HiddenField ID="hfCurrentRoomType" runat="server" />
    <asp:HiddenField ID="hfIsOwner" runat="server" />

    <script type="text/javascript">
        let currentActiveTab = 'my-rooms';
        let isTabSwitching = false;
        let membersLoaded = false;
        let selectedFile = null;

        // Modal Management
        function showManageModal() {
            console.log('Opening manage modal...');
            document.getElementById('manageModal').style.display = 'block';
            
            membersLoaded = false;
            document.getElementById('membersLoadingDiv').style.display = 'block';
            document.getElementById('membersList').style.display = 'none';
            
            console.log('Automatically loading members...');
            membersLoaded = true;
            __doPostBack('LoadMembers', '');
            
            return false;
        }

        function closeManageModal() {
            document.getElementById('manageModal').style.display = 'none';
        }

        function showMembersList() {
            document.getElementById('membersLoadingDiv').style.display = 'none';
            document.getElementById('membersList').style.display = 'block';
            document.getElementById('manageModal').style.display = 'block';
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('manageModal');
            if (event.target == modal) {
                closeManageModal();
            }
        }

        // NEW: Message deletion function
        function deleteMessage(messageId) {
            if (confirm('Are you sure you want to delete this message?')) {
                console.log('Deleting message:', messageId);
                __doPostBack('DeleteMessage', messageId);
            }
            return false;
        }

        // File upload functions
        function handleFileSelect(input) {
            const file = input.files[0];
            if (!file) return;

            // Validate file type
            const allowedTypes = ['application/pdf', 'image/png', 'image/jpeg', 'image/gif', 'image/jpg'];
            if (!allowedTypes.includes(file.type)) {
                alert('Only PDF and image files (PNG, JPG, JPEG, GIF) are allowed.');
                input.value = '';
                return;
            }

            // Validate file size (4MB limit)
            const maxSize = 4 * 1024 * 1024; // 4MB
            if (file.size > maxSize) {
                alert('File size exceeds 4MB limit. Please select a smaller file.');
                input.value = '';
                return;
            }

            selectedFile = file;
            showFileUploadStatus(file);
        }

        function showFileUploadStatus(file) {
            const statusDiv = document.getElementById('fileUploadStatus');
            const fileName = document.getElementById('fileName');
            const fileSize = document.getElementById('fileSize');

            fileName.textContent = file.name;
            fileSize.textContent = formatFileSize(file.size);
            statusDiv.style.display = 'block';
        }

        function clearFileUpload() {
            const fileInput = document.getElementById('<%= fileUpload.ClientID %>');
            fileInput.value = '';
            selectedFile = null;
            document.getElementById('fileUploadStatus').style.display = 'none';
        }

        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        // Tab switching
        function switchTab(tabName) {
            if (isTabSwitching) return false;
            isTabSwitching = true;

            console.log('Switching to tab:', tabName);
            currentActiveTab = tabName;

            const hfActiveTab = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hfActiveTab) {
                hfActiveTab.value = tabName;
            }

            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });

            const targetBtn = document.querySelector(`[data-tab="${tabName}"]`);
            if (targetBtn) {
                targetBtn.classList.add('active');
            }

            const targetContent = document.getElementById(tabName + '-tab');
            if (targetContent) {
                targetContent.classList.add('active');
            }

            if (tabName === 'private-chat') {
                setTimeout(() => {
                    loadPrivateChatsIfNeeded();
                }, 100);
            }

            setTimeout(() => {
                isTabSwitching = false;
            }, 300);

            return false;
        }

        function loadPrivateChatsIfNeeded() {
            const privateChatsList = document.getElementById('privateChatsList');
            if (!privateChatsList) return;

            const hasContent = privateChatsList.querySelectorAll('.room-item').length > 0;
            const isEmptyStateVisible = document.getElementById('<%= pnlNoPrivateChats.ClientID %>') &&
                document.getElementById('<%= pnlNoPrivateChats.ClientID %>').style.display !== 'none';

            if (!hasContent && !isEmptyStateVisible && !window.privateChatsLoaded) {
                console.log('Loading private chats...');
                window.privateChatsLoaded = true;
                __doPostBack('LoadPrivateChats', '');
            }
        }

        function selectRoom(roomId, roomName, roomType) {
            console.log('Selecting room:', roomId, roomName, roomType);
            
            const hfCurrentRoomId = document.getElementById('<%= hfCurrentRoomId.ClientID %>');
            if (hfCurrentRoomId) {
                hfCurrentRoomId.value = roomId;
            }
            
            document.querySelectorAll('.room-item').forEach(item => {
                item.classList.remove('active');
            });
            
            const selectedRoom = document.querySelector(`[data-room-id="${roomId}"]`);
            if (selectedRoom) {
                selectedRoom.classList.add('active');
            }
            
            __doPostBack('LoadRoom', roomId);
        }

        function filterRooms() {
            const searchInput = document.getElementById('<%= txtSearchMyRooms.ClientID %>');
            if (!searchInput) return;
            
            const filter = searchInput.value.toLowerCase();
            const rooms = document.querySelectorAll('#myRoomsList .room-item');

            rooms.forEach(room => {
                const roomNameEl = room.querySelector('h4');
                const roomDescEl = room.querySelector('p');
                
                if (roomNameEl && roomDescEl) {
                    const roomName = roomNameEl.textContent.toLowerCase();
                    const roomDesc = roomDescEl.textContent.toLowerCase();

                    if (roomName.includes(filter) || roomDesc.includes(filter)) {
                        room.style.display = 'flex';
                    } else {
                        room.style.display = 'none';
                    }
                }
            });
        }

        function scrollToBottom(force = false) {
            const container = document.getElementById('messagesContainer');
            if (container) {
                const isNearBottom = force || 
                    (container.scrollHeight - container.scrollTop - container.clientHeight < 100);
                
                if (isNearBottom) {
                    container.scrollTop = container.scrollHeight;
                }
            }
        }

        function setupMessageInput() {
            const messageInput = document.getElementById('<%= txtMessage.ClientID %>');
            const sendBtn = document.getElementById('<%= btnSend.ClientID %>');

            if (messageInput) {
                messageInput.addEventListener('input', function () {
                    this.style.height = 'auto';
                    const newHeight = Math.min(this.scrollHeight, 100);
                    this.style.height = newHeight + 'px';
                });

                messageInput.addEventListener('keydown', function (e) {
                    if (e.key === 'Enter' && !e.shiftKey) {
                        e.preventDefault();
                        if (sendBtn && (this.value.trim() || selectedFile)) {
                            sendBtn.click();
                        }
                    }
                });

                messageInput.addEventListener('focus', function () {
                    setTimeout(() => {
                        scrollToBottom(true);
                        this.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                    }, 100);
                });
            }
        }

        function restoreTabState() {
            const hfActiveTab = document.getElementById('<%= hfActiveTab.ClientID %>');
            const activeTab = hfActiveTab ? hfActiveTab.value : 'my-rooms';
            
            console.log('Restoring tab state:', activeTab);
            currentActiveTab = activeTab;

            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

            const targetBtn = document.querySelector(`[data-tab="${activeTab}"]`);
            if (targetBtn) targetBtn.classList.add('active');
            
            const targetTab = document.getElementById(activeTab + '-tab');
            if (targetTab) targetTab.classList.add('active');
        }

        function clearStatusMessages() {
            setTimeout(function () {
                const statusMessages = document.querySelectorAll('.status-message.show');
                statusMessages.forEach(msg => {
                    if (msg.textContent.trim()) {
                        msg.style.transition = 'opacity 0.5s';
                        msg.style.opacity = '0';
                        setTimeout(() => {
                            msg.textContent = '';
                            msg.classList.remove('show');
                            msg.style.opacity = '1';
                        }, 500);
                    }
                });
            }, 5000);
        }

        function setupEventHandlers() {
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    const tabName = this.getAttribute('data-tab');
                    if (tabName && tabName !== currentActiveTab) {
                        switchTab(tabName);
                    }
                    return false;
                });
            });

            document.addEventListener('click', function(e) {
                const roomItem = e.target.closest('.room-item');
                if (roomItem && !isTabSwitching) {
                    const roomId = roomItem.getAttribute('data-room-id');
                    const roomName = roomItem.getAttribute('data-room-name');
                    const roomType = roomItem.getAttribute('data-room-type');
                    
                    if (roomId) {
                        selectRoom(roomId, roomName, roomType);
                    }
                }
            });

            const searchInput = document.getElementById('<%= txtSearchMyRooms.ClientID %>');
            if (searchInput) {
                searchInput.addEventListener('input', filterRooms);
                searchInput.addEventListener('keyup', filterRooms);
            }
        }

        // Main initialization
        document.addEventListener('DOMContentLoaded', function () {
            console.log('Chat page loaded, initializing...');

            setupEventHandlers();
            setupMessageInput();
            setTimeout(restoreTabState, 100);

            if (!window.privateChatsLoaded) {
                setTimeout(() => {
                    window.privateChatsLoaded = true;
                    if (typeof __doPostBack === 'function') {
                        __doPostBack('LoadPrivateChats', '');
                    }
                }, 1000);
            }

            clearStatusMessages();

            setTimeout(() => {
                const messageInput = document.getElementById('<%= txtMessage.ClientID %>');
                const chatInterface = document.getElementById('<%= pnlChatInterface.ClientID %>');

                if (messageInput && chatInterface &&
                    chatInterface.style.display !== 'none' &&
                    window.getComputedStyle(chatInterface).display !== 'none') {
                    messageInput.focus();
                    scrollToBottom(true);
                }
            }, 1200);
        });

        window.addEventListener('resize', function () {
            setTimeout(() => {
                scrollToBottom(false);
            }, 100);
        });

        window.addEventListener('beforeunload', function () {
            const container = document.getElementById('messagesContainer');
            if (container) {
                sessionStorage.setItem('chatScrollPos', container.scrollTop);
            }
        });

        function restoreScrollPosition() {
            const container = document.getElementById('messagesContainer');
            if (container) {
                const savedPos = sessionStorage.getItem('chatScrollPos');
                if (savedPos) {
                    container.scrollTop = parseInt(savedPos);
                    sessionStorage.removeItem('chatScrollPos');
                } else {
                    setTimeout(() => scrollToBottom(true), 200);
                }
            }
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', restoreScrollPosition);
        } else {
            restoreScrollPosition();
        }
    </script>
</asp:Content>