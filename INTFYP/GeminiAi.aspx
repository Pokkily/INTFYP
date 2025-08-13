<%@ Page Title="Gemini AI with Firestore Integration" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Async="true" CodeBehind="GeminiAi.aspx.cs" Inherits="INTFYP.GeminiAi" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Gemini AI with Firestore Integration
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .loading-spinner {
            display: none;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            animation: spin 1s linear infinite;
            margin-left: 10px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .chat-container {
            display: flex;
            flex-direction: column;
            height: calc(100vh - 150px); /* Adjust based on header/footer height */
        }
        .chat-history {
            flex: 1;
            overflow-y: auto;
            padding: 1rem;
        }
        .user-message {
            text-align: right;
        }
        .user-message .bubble {
            background-color: #3b82f6;
            color: white;
            border-radius: 1rem 1rem 0 1rem;
            padding: 0.75rem 1rem;
            max-width: 80%;
            margin-left: auto;
            display: inline-block;
        }
        .ai-message {
            text-align: left;
        }
        .ai-message .bubble {
            background-color: #e5e7eb;
            color: #111827;
            border-radius: 1rem 1rem 1rem 0;
            padding: 0.75rem 1rem;
            max-width: 80%;
            margin-right: auto;
            display: inline-block;
        }
        .input-container {
            display: flex;
            align-items: center;
            padding: 1rem;
            background-color: white;
            border-top: 1px solid #d1d5db;
        }
        .input-container textarea {
            flex: 1;
            resize: none;
        }
    </style>

    <div class="chat-container">
        <header class="bg-blue-600 text-white p-4">
            <h2 class="text-2xl font-bold">Gemini AI - Firestore-Powered Q&A</h2>
            <p class="text-sm">Ask a question, and Gemini will respond using data from our Firestore database.</p>
        </header>
        <div id="chatHistory" class="chat-history bg-white" runat="server">
            <asp:ListView ID="lvChat" runat="server">
                <ItemTemplate>
                    <div class='<%# (string)Eval("Role") == "user" ? "user-message mb-4" : "ai-message mb-4" %>'>
                        <div class="bubble">
                            <%# Eval("Text").ToString().Replace("\n", "<br />") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:ListView>
        </div>
        <div class="input-container">
            <asp:TextBox 
                ID="txtPrompt" 
                runat="server" 
                TextMode="MultiLine" 
                CssClass="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" 
                Rows="2" 
                placeholder="Enter your question here (e.g., 'List all my classes')" 
                aria-describedby="promptHelp" />
            <asp:Button 
                ID="btnSend" 
                runat="server" 
                Text="Send" 
                OnClick="btnSend_Click" 
                CssClass="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition disabled:opacity-50 ml-2" 
                OnClientClick="return validateAndShowSpinner();" />
            <div id="loadingSpinner" class="loading-spinner"></div>
        </div>
    </div>

    <script>
        function validateAndShowSpinner() {
            const prompt = document.getElementById('<%= txtPrompt.ClientID %>').value.trim();
            const spinner = document.getElementById('loadingSpinner');
            if (!prompt) {
                alert('Please enter a question before submitting.');
                return false;
            }
            spinner.style.display = 'inline-block';
            return true;
        }

        // Hide spinner on page load or postback completion and scroll to bottom
        document.addEventListener('DOMContentLoaded', function () {
            document.getElementById('loadingSpinner').style.display = 'none';
            const chatHistory = document.getElementById('<%= chatHistory.ClientID %>');
            if (chatHistory) {
                chatHistory.scrollTop = chatHistory.scrollHeight;
            }
        });
    </script>
</asp:Content>