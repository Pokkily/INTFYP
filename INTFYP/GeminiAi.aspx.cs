using FirebaseAdmin;
using Google.Cloud.Firestore;
using System;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using Newtonsoft.Json.Linq;
using System.Linq;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace INTFYP
{
    public class Message
    {
        public string Role { get; set; }
        public string Text { get; set; }
        public DateTime Timestamp { get; set; } = DateTime.Now;
    }

    public partial class GeminiAi : Page
    {
        private static readonly HttpClient httpClient = new HttpClient();
        private static FirestoreDb db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    InitializeFirestore().GetAwaiter().GetResult();
                    if (Session["ChatHistory"] == null)
                    {
                        Session["ChatHistory"] = new List<Message>();
                        // Add welcome message
                        AddWelcomeMessage();
                    }
                    BindChatHistory();
                }
                catch (Exception ex)
                {
                    LogError($"Page_Load error: {ex.Message}");
                    ShowClientMessage("Error initializing the application. Please refresh the page.", "error");
                }
            }
        }

        private async Task InitializeFirestore()
        {
            try
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto");
                LogError("Firestore initialized successfully");
            }
            catch (Exception ex)
            {
                LogError($"Firestore initialization error: {ex.Message}");
                throw;
            }
        }

        private void AddWelcomeMessage()
        {
            var welcomeMessage = "🎉 Welcome to Gemini AI Assistant!\n\n" +
                               "I have access to your complete Firestore database and can help you with:\n" +
                               "• Finding specific data across all collections\n" +
                               "• Analyzing your quiz results and performance\n" +
                               "• Listing your classes and enrollment details\n" +
                               "• Searching through posts and discussions\n" +
                               "• Exploring scholarships and applications\n" +
                               "• And much more!\n\n" +
                               "Just ask me anything about your data! 🚀";

            var history = (List<Message>)Session["ChatHistory"];
            history.Add(new Message { Role = "model", Text = welcomeMessage });
        }

        protected async void btnSend_Click(object sender, EventArgs e)
        {
            string prompt = txtPrompt.Text.Trim();
            string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
            string username = Session["username"]?.ToString();

            // Input validation with better user feedback
            if (string.IsNullOrEmpty(prompt))
            {
                ShowClientMessage("Please enter a question before sending.", "warning");
                return;
            }

            if (prompt.Length > 500)
            {
                ShowClientMessage("Message is too long. Please keep it under 500 characters.", "error");
                return;
            }

            if (string.IsNullOrEmpty(username))
            {
                ShowClientMessage("You must be logged in to use this feature.", "error");
                return;
            }

            if (string.IsNullOrEmpty(apiKey))
            {
                ShowClientMessage("API key is missing. Please contact administrator.", "error");
                return;
            }

            try
            {
                // Add user message to history
                AddMessage("user", prompt);

                // Check for specific commands
                if (IsClassListRequest(prompt))
                {
                    await HandleClassListRequest(username);
                }
                else if (IsDataSummaryRequest(prompt))
                {
                    await HandleDataSummaryRequest(username);
                }
                else
                {
                    await HandleGeneralRequest(prompt, username, apiKey);
                }

                ShowClientMessage("Response generated successfully!", "success");
            }
            catch (HttpRequestException httpEx)
            {
                AddMessage("model", "🌐 Network error: Please check your internet connection and try again.");
                ShowClientMessage("Network error occurred.", "error");
                LogError($"Network error: {httpEx.Message}");
            }
            catch (TaskCanceledException timeoutEx)
            {
                AddMessage("model", "⏱️ Request timed out: The AI is taking longer than expected. Please try again.");
                ShowClientMessage("Request timed out. Please try again.", "warning");
                LogError($"Timeout error: {timeoutEx.Message}");
            }
            catch (Exception ex)
            {
                AddMessage("model", "❌ An unexpected error occurred. Please try again or contact support.");
                ShowClientMessage("An unexpected error occurred.", "error");
                LogError($"General error: {ex.Message}");
            }

            // Clear the input
            txtPrompt.Text = "";
        }

        private bool IsClassListRequest(string prompt)
        {
            var keywords = new[] { "list all my classes", "list my classes", "show my classes", "my enrolled classes", "what classes am i in" };
            return keywords.Any(keyword => prompt.ToLower().Contains(keyword));
        }

        private bool IsDataSummaryRequest(string prompt)
        {
            var keywords = new[] { "data summary", "overview of my data", "what data do you have", "show me everything", "database summary" };
            return keywords.Any(keyword => prompt.ToLower().Contains(keyword));
        }

        private async Task HandleClassListRequest(string username)
        {
            AddMessage("model", "🔍 Searching for your classes...");
            string classList = await FetchUserClasses(username);
            RemoveLastMessage();
            AddMessage("model", classList);
        }

        private async Task HandleDataSummaryRequest(string username)
        {
            AddMessage("model", "📊 Generating a summary of all your data...");
            string dataSummary = await GenerateDataSummary(username);
            RemoveLastMessage();
            AddMessage("model", dataSummary);
        }

        private async Task HandleGeneralRequest(string prompt, string username, string apiKey)
        {
            // Show processing message for better UX
            AddMessage("model", "🔍 Analyzing your complete Firestore database... This may take a moment.");

            string firestoreData = await FetchAllFirestoreData();

            // Remove the processing message
            RemoveLastMessage();

            // Add analyzing message
            AddMessage("model", "🧠 Processing your request with AI...");

            string combinedPrompt = BuildAIPrompt(prompt, username, firestoreData);

            string url = $"https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key={apiKey}";

            var payload = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new { text = combinedPrompt }
                        }
                    }
                },
                generationConfig = new
                {
                    temperature = 0.7,
                    topK = 40,
                    topP = 0.95,
                    maxOutputTokens = 2048
                }
            };

            var json = Newtonsoft.Json.JsonConvert.SerializeObject(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await httpClient.PostAsync(url, content);
            var responseString = await response.Content.ReadAsStringAsync();

            // Remove processing message
            RemoveLastMessage();

            if (!response.IsSuccessStatusCode)
            {
                AddMessage("model", $"❌ API Error: {responseString}");
                ShowClientMessage("There was an error processing your request.", "error");
                return;
            }

            var jsonResponse = JObject.Parse(responseString);
            var reply = jsonResponse["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.ToString();

            if (string.IsNullOrEmpty(reply))
            {
                AddMessage("model", "❌ No response received from Gemini AI. Please try again.");
                ShowClientMessage("No response received. Please try again.", "warning");
            }
            else
            {
                var formattedReply = FormatAIResponse(reply);
                AddMessage("model", formattedReply);
            }
        }

        private string BuildAIPrompt(string userPrompt, string username, string firestoreData)
        {
            return $@"You are an intelligent assistant helping a user named '{username}' with their personal data analysis. 

CONTEXT: You have access to the user's complete Firestore database with all collections, documents, and fields.

DATABASE STRUCTURE AND DATA:
{firestoreData}

INSTRUCTIONS:
1. Provide helpful, accurate, and personalized responses based on the user's data
2. If asked about specific data, reference the actual values from their database
3. Format responses clearly with proper structure and bullet points when appropriate
4. If you cannot find specific information, explain what data is available instead
5. Be conversational and helpful, like a personal data assistant
6. Use emojis sparingly but appropriately for better readability

USER QUESTION: {userPrompt}

Please provide a comprehensive and helpful response based on the user's actual data.";
        }

        private async Task<string> FetchUserClasses(string username)
        {
            try
            {
                var classroomsRef = db.Collection("classrooms");
                var query = classroomsRef.WhereEqualTo("username", username);
                var snapshot = await query.GetSnapshotAsync();

                if (!snapshot.Documents.Any())
                {
                    // Try alternative field names
                    var altQuery = classroomsRef.WhereEqualTo("userId", username);
                    var altSnapshot = await altQuery.GetSnapshotAsync();

                    if (!altSnapshot.Documents.Any())
                    {
                        return $"No classes found for user '{username}'. You may not be enrolled in any classes yet, or your username might not be linked to any classroom records.";
                    }
                    snapshot = altSnapshot;
                }

                var classList = new List<string>();
                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var data = document.ToDictionary();
                    var classInfo = new List<string>();

                    foreach (var field in data)
                    {
                        classInfo.Add($"{field.Key}: {FormatFieldValue(field.Value)}");
                    }

                    var subcollectionData = await FetchAllSubcollections(document.Reference, 0);

                    classList.Add($"📚 **Classroom {document.Id}**\n" +
                                 $"Details: {string.Join(", ", classInfo)}\n" +
                                 (string.IsNullOrEmpty(subcollectionData.Trim()) ? "" : $"Additional Data:\n{subcollectionData}\n"));
                }

                return $"🎓 **Your Classes ({classList.Count} found):**\n\n{string.Join("\n", classList)}";
            }
            catch (Exception ex)
            {
                LogError($"Error fetching user classes: {ex.Message}");
                return $"❌ Error retrieving your classes: {ex.Message}";
            }
        }

        private async Task<string> GenerateDataSummary(string username)
        {
            try
            {
                var summary = new List<string>();
                var collections = await db.ListRootCollectionsAsync().ToListAsync();

                summary.Add($"📊 **Data Summary for {username}**\n");
                summary.Add($"📁 **Total Collections:** {collections.Count}");
                summary.Add($"📋 **Available Collections:** {string.Join(", ", collections.Select(c => c.Id))}\n");

                foreach (var collection in collections.Take(5)) // Limit to first 5 for summary
                {
                    try
                    {
                        var snapshot = await collection.Limit(1).GetSnapshotAsync();
                        var count = snapshot.Count;

                        // Try to get total count (this is an approximation)
                        var allSnapshot = await collection.GetSnapshotAsync();
                        var totalCount = allSnapshot.Count;

                        summary.Add($"• **{collection.Id}**: {totalCount} documents");
                    }
                    catch (Exception ex)
                    {
                        summary.Add($"• **{collection.Id}**: Unable to access ({ex.Message})");
                    }
                }

                summary.Add("\n💡 **Tip:** Ask me specific questions about any of this data!");

                return string.Join("\n", summary);
            }
            catch (Exception ex)
            {
                LogError($"Error generating data summary: {ex.Message}");
                return $"❌ Error generating data summary: {ex.Message}";
            }
        }

        private async Task<string> FetchAllFirestoreData()
        {
            try
            {
                var dataList = new List<string>();

                // Get all collection references dynamically
                var collections = await db.ListRootCollectionsAsync().ToListAsync();

                dataList.Add($"=== COMPLETE FIRESTORE DATABASE ANALYSIS ===");
                dataList.Add($"Database ID: intorannetto");
                dataList.Add($"Total Root Collections: {collections.Count}");
                dataList.Add($"Collections: {string.Join(", ", collections.Select(c => c.Id))}");
                dataList.Add($"Scan Date: {DateTime.Now:yyyy-MM-dd HH:mm:ss} UTC");
                dataList.Add($"==========================================\n");

                foreach (var collection in collections)
                {
                    dataList.Add($"--- COLLECTION: {collection.Id} ---");

                    try
                    {
                        // Get all documents in this collection
                        QuerySnapshot snapshot = await collection.GetSnapshotAsync();

                        if (!snapshot.Documents.Any())
                        {
                            dataList.Add($"Collection '{collection.Id}': No documents found.\n");
                            continue;
                        }

                        dataList.Add($"Document Count: {snapshot.Documents.Count}");

                        int docIndex = 0;
                        foreach (DocumentSnapshot document in snapshot.Documents)
                        {
                            docIndex++;
                            // Limit to first 50 documents per collection to avoid overwhelming the AI
                            if (docIndex > 50)
                            {
                                dataList.Add($"... and {snapshot.Documents.Count - 50} more documents in '{collection.Id}'\n");
                                break;
                            }

                            // Get all fields from the document
                            var documentData = document.ToDictionary();
                            var fields = documentData.Select(kvp => $"{kvp.Key}: {FormatFieldValue(kvp.Value)}");

                            dataList.Add($"\nDocument ID: {document.Id}");
                            dataList.Add($"Fields: {string.Join(" | ", fields)}");

                            // Fetch subcollections (limit recursion for performance)
                            var subcollectionData = await FetchAllSubcollections(document.Reference, 0);
                            if (!string.IsNullOrEmpty(subcollectionData.Trim()))
                            {
                                dataList.Add($"Subcollections: {subcollectionData}");
                            }
                        }
                        dataList.Add(""); // Empty line for readability
                    }
                    catch (Exception collectionEx)
                    {
                        dataList.Add($"Error accessing collection '{collection.Id}': {collectionEx.Message}\n");
                        LogError($"Collection access error for '{collection.Id}': {collectionEx.Message}");
                    }
                }

                var result = string.Join("\n", dataList);
                LogError($"Firestore data fetch completed. Total length: {result.Length} characters");
                return result;
            }
            catch (Exception ex)
            {
                LogError($"Error fetching complete Firestore data: {ex.Message}");
                return $"Error fetching complete Firestore data: {ex.Message}";
            }
        }

        private async Task<string> FetchAllSubcollections(DocumentReference documentRef, int depth)
        {
            try
            {
                // Prevent infinite recursion and limit depth for performance
                if (depth > 3) return "";

                var subcollectionList = new List<string>();
                string indent = new string(' ', (depth + 1) * 2);

                var subcollections = await documentRef.ListCollectionsAsync().ToListAsync();

                if (!subcollections.Any())
                {
                    return "";
                }

                foreach (var subcollection in subcollections)
                {
                    try
                    {
                        var subSnapshot = await subcollection.Limit(10).GetSnapshotAsync(); // Limit subcollection docs

                        if (!subSnapshot.Documents.Any())
                        {
                            subcollectionList.Add($"{indent}Subcollection '{subcollection.Id}': Empty");
                            continue;
                        }

                        subcollectionList.Add($"{indent}Subcollection '{subcollection.Id}' ({subSnapshot.Documents.Count} docs):");

                        foreach (DocumentSnapshot subDoc in subSnapshot.Documents)
                        {
                            var subDocumentData = subDoc.ToDictionary();
                            var subFields = subDocumentData.Select(kvp => $"{kvp.Key}: {FormatFieldValue(kvp.Value)}");

                            subcollectionList.Add($"{indent}  Doc {subDoc.Id}: {string.Join(" | ", subFields)}");

                            // Recursive call with depth limit
                            if (depth < 2)
                            {
                                var nestedSubcollections = await FetchAllSubcollections(subDoc.Reference, depth + 1);
                                if (!string.IsNullOrEmpty(nestedSubcollections.Trim()))
                                {
                                    subcollectionList.Add(nestedSubcollections);
                                }
                            }
                        }
                    }
                    catch (Exception subEx)
                    {
                        subcollectionList.Add($"{indent}Error accessing subcollection '{subcollection.Id}': {subEx.Message}");
                        LogError($"Subcollection access error: {subEx.Message}");
                    }
                }

                return string.Join("\n", subcollectionList);
            }
            catch (Exception ex)
            {
                LogError($"Error fetching subcollections: {ex.Message}");
                return $"Error fetching subcollections: {ex.Message}";
            }
        }

        private string FormatFieldValue(object value)
        {
            if (value == null)
                return "null";

            if (value is string stringValue)
            {
                // Truncate very long strings
                return stringValue.Length > 100 ? $"'{stringValue.Substring(0, 100)}...'" : $"'{stringValue}'";
            }

            if (value is DateTime dateTime)
                return dateTime.ToString("yyyy-MM-dd HH:mm:ss");

            if (value is Timestamp timestamp)
                return timestamp.ToDateTime().ToString("yyyy-MM-dd HH:mm:ss");

            if (value is System.Collections.IEnumerable enumerable && !(value is string))
            {
                var items = enumerable.Cast<object>().Take(5).Select(FormatFieldValue);
                var itemList = string.Join(", ", items);
                var totalCount = enumerable.Cast<object>().Count();
                return totalCount > 5 ? $"[{itemList}... +{totalCount - 5} more]" : $"[{itemList}]";
            }

            if (value is bool boolValue)
                return boolValue.ToString().ToLower();

            return value.ToString();
        }

        private string FormatAIResponse(string response)
        {
            if (string.IsNullOrEmpty(response))
                return response;

            // Clean up the response formatting
            response = response.Replace("**", "");
            response = response.Replace("##", "");

            // Ensure proper line breaks
            response = response.Replace(". ", ".\n");
            response = response.Replace("? ", "?\n");
            response = response.Replace("! ", "!\n");

            // Fix numbered lists
            for (int i = 1; i <= 10; i++)
            {
                response = response.Replace($"{i}.", $"\n{i}.");
            }

            // Fix bullet points
            response = response.Replace("•", "\n•");
            response = response.Replace("-", "\n-");

            // Remove excessive line breaks
            response = System.Text.RegularExpressions.Regex.Replace(response, @"\n{3,}", "\n\n");

            return response.Trim();
        }

        // Helper method to show client-side messages
        private void ShowClientMessage(string message, string type)
        {
            string script = $"showNotification('{message.Replace("'", "\\'")}', '{type}');";
            ClientScript.RegisterStartupScript(this.GetType(), "notification", script, true);
        }

        // Helper method to log errors
        private void LogError(string error)
        {
            try
            {
                // Log to debug output
                Debug.WriteLine($"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] GeminiAI: {error}");

                // You can also implement file logging or database logging here
                // Example: Write to a log file
                // System.IO.File.AppendAllText(Server.MapPath("~/logs/gemini_errors.log"), 
                //     $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {error}\n");
            }
            catch
            {
                // Ignore logging errors to prevent cascading issues
            }
        }

        // Helper method to remove the last message (for removing processing messages)
        private void RemoveLastMessage()
        {
            var history = (List<Message>)Session["ChatHistory"];
            if (history.Count > 0)
            {
                history.RemoveAt(history.Count - 1);
                BindChatHistory();
            }
        }

        // Enhanced AddMessage with better formatting
        private void AddMessage(string role, string text)
        {
            var history = (List<Message>)Session["ChatHistory"];

            // Add appropriate emoji indicators for system messages
            if (role == "model" && !text.StartsWith("🔍") && !text.StartsWith("❌") &&
                !text.StartsWith("⏱️") && !text.StartsWith("🌐") && !text.StartsWith("🎉") &&
                !text.StartsWith("📊") && !text.StartsWith("🎓") && !text.StartsWith("📚") &&
                !text.StartsWith("🧠"))
            {
                text = "🤖 " + text;
            }

            history.Add(new Message { Role = role, Text = text, Timestamp = DateTime.Now });

            // Keep history manageable (last 50 messages)
            if (history.Count > 50)
            {
                history.RemoveAt(0);
            }

            BindChatHistory();

            // Trigger smooth scroll on client side
            string scrollScript = "setTimeout(scrollToBottom, 100);";
            ClientScript.RegisterStartupScript(this.GetType(), "scroll", scrollScript, true);
        }

        private void BindChatHistory()
        {
            var history = (List<Message>)Session["ChatHistory"];
            lvChat.DataSource = history;
            lvChat.DataBind();
        }

        // Method to clear chat history (you can add a button for this)
        protected void ClearChatHistory()
        {
            Session["ChatHistory"] = new List<Message>();
            AddWelcomeMessage();
            BindChatHistory();
            ShowClientMessage("Chat history cleared!", "success");
        }

        // Method to export chat history (optional feature)
        protected string ExportChatHistory()
        {
            var history = (List<Message>)Session["ChatHistory"];
            var export = new StringBuilder();

            export.AppendLine($"Chat History Export - {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            export.AppendLine("=" + new string('=', 50));

            foreach (var message in history)
            {
                export.AppendLine($"\n[{message.Timestamp:HH:mm:ss}] {(message.Role == "user" ? "YOU" : "AI")}:");
                export.AppendLine(message.Text);
                export.AppendLine(new string('-', 30));
            }

            return export.ToString();
        }
    }
}