<%@ Page Title="Gemini AI with Firestore Integration" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Async="true" CodeBehind="GeminiAi.aspx.cs" Inherits="INTFYP.GeminiAi" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Gemini AI with Firestore Integration
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        * {
            font-family: 'Inter', sans-serif;
        }

        .glass-effect {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .gradient-bg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .chat-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.3);
            overflow: hidden;
            height: calc(100vh - 100px);
            display: flex;
            flex-direction: column;
            transition: all 0.3s ease;
        }

        .chat-container:hover {
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
            transform: translateY(-2px);
        }

        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .chat-header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.1), transparent);
            transform: rotate(45deg);
            animation: shimmer 3s infinite;
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
            100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
        }

        .chat-header h2 {
            font-weight: 700;
            font-size: 1.75rem;
            margin: 0;
            position: relative;
            z-index: 1;
        }

        .chat-header p {
            margin: 0.5rem 0 0 0;
            opacity: 0.9;
            font-weight: 400;
            position: relative;
            z-index: 1;
        }

        .chat-history {
            flex: 1;
            overflow-y: auto;
            padding: 2rem;
            background: linear-gradient(to bottom, #f8fafc, #f1f5f9);
            position: relative;
        }

        .chat-history::-webkit-scrollbar {
            width: 6px;
        }

        .chat-history::-webkit-scrollbar-track {
            background: transparent;
        }

        .chat-history::-webkit-scrollbar-thumb {
            background: rgba(0, 0, 0, 0.2);
            border-radius: 3px;
            transition: background 0.3s ease;
        }

        .chat-history::-webkit-scrollbar-thumb:hover {
            background: rgba(0, 0, 0, 0.3);
        }

        .message-container {
            opacity: 0;
            animation: fadeInUp 0.6s ease forwards;
            margin-bottom: 1.5rem;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .user-message {
            display: flex;
            justify-content: flex-end;
            align-items: flex-end;
            gap: 0.75rem;
        }

        .ai-message {
            display: flex;
            justify-content: flex-start;
            align-items: flex-end;
            gap: 0.75rem;
        }

        .message-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
            animation: pulse 2s infinite;
        }

        .user-avatar {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }

        .ai-avatar {
            background: linear-gradient(135deg, #ffecd2, #fcb69f);
            color: #8b4513;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .message-bubble {
            max-width: 75%;
            padding: 1rem 1.25rem;
            border-radius: 18px;
            font-weight: 400;
            line-height: 1.6;
            position: relative;
            word-wrap: break-word;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .message-bubble:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }

        .user-bubble {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-bottom-right-radius: 6px;
        }

        .ai-bubble {
            background: white;
            color: #374151;
            border: 1px solid #e5e7eb;
            border-bottom-left-radius: 6px;
        }

        .typing-indicator {
            display: none;
            align-items: center;
            gap: 0.5rem;
            padding: 1rem;
            background: white;
            border-radius: 18px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            margin-bottom: 1rem;
        }

        .typing-dots {
            display: flex;
            gap: 4px;
        }

        .typing-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #9ca3af;
            animation: typingAnimation 1.4s infinite;
        }

        .typing-dot:nth-child(2) { animation-delay: 0.2s; }
        .typing-dot:nth-child(3) { animation-delay: 0.4s; }

        @keyframes typingAnimation {
            0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
            30% { transform: translateY(-10px); opacity: 1; }
        }

        .input-container {
            background: white;
            padding: 1.5rem 2rem;
            border-top: 1px solid rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: flex-end;
            gap: 1rem;
            position: relative;
        }

        .input-wrapper {
            flex: 1;
            position: relative;
        }

        .input-field {
            width: 100%;
            background: #f8fafc;
            border: 2px solid transparent;
            border-radius: 16px;
            padding: 1rem 1.25rem;
            font-size: 1rem;
            resize: none;
            transition: all 0.3s ease;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.05);
            font-family: 'Inter', sans-serif;
        }

        .input-field:focus {
            outline: none;
            background: white;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            transform: translateY(-1px);
        }

        .send-button {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 16px;
            padding: 1rem 1.5rem;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            min-width: 100px;
            justify-content: center;
        }

        .send-button:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        .send-button:active {
            transform: translateY(0);
        }

        .send-button:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            transform: none;
        }

        .loading-spinner {
            display: none;
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-top: 2px solid white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .status-indicator {
            position: absolute;
            top: 1rem;
            right: 2rem;
            background: rgba(34, 197, 94, 0.9);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 500;
            opacity: 0;
            transform: translateY(-10px);
            transition: all 0.3s ease;
            z-index: 10;
        }

        .status-indicator.show {
            opacity: 1;
            transform: translateY(0);
        }

        .character-count {
            position: absolute;
            bottom: -1.5rem;
            right: 0;
            font-size: 0.75rem;
            color: #6b7280;
            transition: color 0.3s ease;
        }

        .character-count.warning {
            color: #f59e0b;
        }

        .character-count.danger {
            color: #ef4444;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .chat-container {
                height: calc(100vh - 40px);
                margin: 1rem;
                border-radius: 16px;
            }
            
            .chat-history {
                padding: 1rem;
            }
            
            .input-container {
                padding: 1rem;
            }
            
            .message-bubble {
                max-width: 85%;
            }
            
            .chat-header {
                padding: 1.5rem;
            }
            
            .chat-header h2 {
                font-size: 1.5rem;
            }
        }

        /* Animation for new messages */
        .new-message {
            animation: slideInRight 0.5s ease;
        }

        .new-ai-message {
            animation: slideInLeft 0.5s ease;
        }

        @keyframes slideInRight {
            from {
                opacity: 0;
                transform: translateX(50px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes slideInLeft {
            from {
                opacity: 0;
                transform: translateX(-50px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        /* Empty state */
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            text-align: center;
            color: #6b7280;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }
    </style>

    <div class="gradient-bg min-h-screen p-4">
        <div class="max-w-6xl mx-auto">
            <div class="chat-container">
                <header class="chat-header">
                    <h2><i class="fas fa-robot mr-3"></i>Gemini AI Assistant</h2>
                    <p>Powered by your complete Firestore database • Ask anything!</p>
                    <div class="status-indicator" id="statusIndicator">
                        <i class="fas fa-check-circle mr-2"></i>Connected
                    </div>
                </header>
                
                <div id="chatHistory" class="chat-history" runat="server">
                    <asp:ListView ID="lvChat" runat="server">
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <i class="fas fa-comments"></i>
                                <h3 class="text-xl font-semibold mb-2">Start a Conversation</h3>
                                <p>Ask me anything about your data, and I'll help you find the answers!</p>
                            </div>
                        </EmptyDataTemplate>
                        <ItemTemplate>
                            <div class='message-container <%# (string)Eval("Role") == "user" ? "user-message" : "ai-message" %>'>
                                <%# (string)Eval("Role") == "user" ? "" : "<div class='message-avatar ai-avatar'><i class='fas fa-robot'></i></div>" %>
                                <div class='message-bubble <%# (string)Eval("Role") == "user" ? "user-bubble" : "ai-bubble" %>'>
                                    <%# Eval("Text").ToString().Replace("\n", "<br />") %>
                                </div>
                                <%# (string)Eval("Role") == "user" ? "<div class='message-avatar user-avatar'><i class='fas fa-user'></i></div>" : "" %>
                            </div>
                        </ItemTemplate>
                    </asp:ListView>
                    
                    <!-- Typing indicator -->
                    <div id="typingIndicator" class="typing-indicator ai-message">
                        <div class="message-avatar ai-avatar">
                            <i class="fas fa-robot"></i>
                        </div>
                        <div class="typing-dots">
                            <div class="typing-dot"></div>
                            <div class="typing-dot"></div>
                            <div class="typing-dot"></div>
                        </div>
                        <span class="ml-2 text-sm text-gray-500">Gemini is thinking...</span>
                    </div>
                </div>
                
                <div class="input-container">
                    <div class="input-wrapper">
                        <asp:TextBox 
                            ID="txtPrompt" 
                            runat="server" 
                            TextMode="MultiLine" 
                            CssClass="input-field" 
                            Rows="1" 
                            placeholder="Ask me about your data... (e.g., 'Show me all my quiz results' or 'List my enrolled classes')" 
                            onkeydown="handleKeyPress(event)"
                            oninput="handleInput(this)" />
                        <div id="charCount" class="character-count">0/500</div>
                    </div>
                    <asp:Button 
                        ID="btnSend" 
                        runat="server" 
                        Text="Send" 
                        OnClick="btnSend_Click" 
                        CssClass="send-button" 
                        OnClientClick="return handleSend();" />
                </div>
            </div>
        </div>
    </div>

    <script>
        let isProcessing = false;

        function handleInput(textarea) {
            // Auto-resize textarea
            textarea.style.height = 'auto';
            textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px';

            // Character counter
            const charCount = document.getElementById('charCount');
            const length = textarea.value.length;
            charCount.textContent = `${length}/500`;

            if (length > 400) {
                charCount.classList.add('warning');
                charCount.classList.remove('danger');
            } else if (length > 480) {
                charCount.classList.remove('warning');
                charCount.classList.add('danger');
            } else {
                charCount.classList.remove('warning', 'danger');
            }
        }

        function handleKeyPress(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                if (!isProcessing) {
                    handleSend();
                    document.getElementById('<%= btnSend.ClientID %>').click();
                }
            }
        }

        function handleSend() {
            const prompt = document.getElementById('<%= txtPrompt.ClientID %>').value.trim();
            const sendButton = document.getElementById('<%= btnSend.ClientID %>');
            const spinner = sendButton.querySelector('.loading-spinner') || createSpinner();
            const typingIndicator = document.getElementById('typingIndicator');
            
            if (!prompt) {
                showNotification('Please enter a question before sending.', 'warning');
                return false;
            }
            
            if (isProcessing) {
                return false;
            }
            
            isProcessing = true;
            
            // Update button state
            sendButton.disabled = true;
            sendButton.innerHTML = '<div class="loading-spinner"></div>Sending...';
            sendButton.querySelector('.loading-spinner').style.display = 'inline-block';
            
            // Show typing indicator
            typingIndicator.style.display = 'flex';
            
            // Scroll to bottom
            setTimeout(scrollToBottom, 100);
            
            return true;
        }

        function createSpinner() {
            const spinner = document.createElement('div');
            spinner.className = 'loading-spinner';
            return spinner;
        }

        function resetUI() {
            const sendButton = document.getElementById('<%= btnSend.ClientID %>');
            const typingIndicator = document.getElementById('typingIndicator');
            
            isProcessing = false;
            sendButton.disabled = false;
            sendButton.innerHTML = '<i class="fas fa-paper-plane mr-2"></i>Send';
            typingIndicator.style.display = 'none';
            
            // Reset textarea
            const textarea = document.getElementById('<%= txtPrompt.ClientID %>');
            textarea.style.height = 'auto';
            document.getElementById('charCount').textContent = '0/500';
            document.getElementById('charCount').className = 'character-count';
        }

        function scrollToBottom() {
            const chatHistory = document.getElementById('<%= chatHistory.ClientID %>');
            if (chatHistory) {
                chatHistory.scrollTo({
                    top: chatHistory.scrollHeight,
                    behavior: 'smooth'
                });
            }
        }

        function showNotification(message, type = 'success') {
            const notification = document.createElement('div');
            notification.className = `fixed top-4 right-4 p-4 rounded-lg shadow-lg z-50 transition-all duration-300 transform translate-x-full`;
            
            if (type === 'success') {
                notification.classList.add('bg-green-500', 'text-white');
            } else if (type === 'warning') {
                notification.classList.add('bg-yellow-500', 'text-white');
            } else if (type === 'error') {
                notification.classList.add('bg-red-500', 'text-white');
            }
            
            notification.innerHTML = `<i class="fas fa-${type === 'success' ? 'check' : type === 'warning' ? 'exclamation' : 'times'}-circle mr-2"></i>${message}`;
            
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.classList.remove('translate-x-full');
            }, 100);
            
            setTimeout(() => {
                notification.classList.add('translate-x-full');
                setTimeout(() => {
                    document.body.removeChild(notification);
                }, 300);
            }, 3000);
        }

        function showStatus() {
            const statusIndicator = document.getElementById('statusIndicator');
            statusIndicator.classList.add('show');
            setTimeout(() => {
                statusIndicator.classList.remove('show');
            }, 3000);
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            resetUI();
            scrollToBottom();
            showStatus();
            
            // Add smooth scroll behavior
            document.getElementById('<%= chatHistory.ClientID %>').style.scrollBehavior = 'smooth';
            
            // Focus on input
            document.getElementById('<%= txtPrompt.ClientID %>').focus();

            // Add animation class to existing messages
            const messages = document.querySelectorAll('.message-container');
            messages.forEach((message, index) => {
                message.style.animationDelay = `${index * 0.1}s`;
            });
        });

        // Reset UI after postback
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
            resetUI();
            setTimeout(scrollToBottom, 200);
        });
    </script>
</asp:Content>