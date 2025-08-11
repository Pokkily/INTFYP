<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeBehind="GeminiAi.aspx.cs" Inherits="INTFYP.GeminiAi" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Gemini AI with Firestore Integration</title>
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
    </style>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
    <form id="form1" runat="server">
        <div class="container max-w-2xl mx-auto p-6 bg-white rounded-lg shadow-lg">
            <h2 class="text-2xl font-bold text-gray-800 mb-4">Gemini AI - Firestore-Powered Q&A</h2>
            <p class="text-gray-600 mb-4">Ask a question, and Gemini will respond using data from our Firestore database.</p>
            
            <div class="mb-4">
                <label for="txtPrompt" class="block text-gray-700 font-medium mb-2">Your Question</label>
                <asp:TextBox 
                    ID="txtPrompt" 
                    runat="server" 
                    TextMode="MultiLine" 
                    CssClass="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" 
                    Rows="5" 
                    placeholder="Enter your question here (e.g., 'Provide feedback on recent user reports')" 
                    aria-describedby="promptHelp" />
                <p id="promptHelp" class="text-sm text-gray-500 mt-1">Enter a question to get a response based on Firestore data.</p>
            </div>

            <div class="flex items-center">
                <asp:Button 
                    ID="btnSend" 
                    runat="server" 
                    Text="Ask Gemini" 
                    OnClick="btnSend_Click" 
                    CssClass="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition disabled:opacity-50" 
                    OnClientClick="return validateAndShowSpinner();" />
                <div id="loadingSpinner" class="loading-spinner"></div>
            </div>

            <div class="mt-6">
                <asp:Label 
                    ID="lblResponse" 
                    runat="server" 
                    CssClass="block p-4 bg-gray-50 border rounded-lg text-gray-800 whitespace-pre-wrap" 
                    aria-live="polite" />
            </div>
        </div>
    </form>

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

        // Hide spinner on page load or postback completion
        document.addEventListener('DOMContentLoaded', function () {
            document.getElementById('loadingSpinner').style.display = 'none';
        });
    </script>
</body>
</html>