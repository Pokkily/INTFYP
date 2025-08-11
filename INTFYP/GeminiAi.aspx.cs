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

namespace INTFYP
{
    public class Message
    {
        public string Role { get; set; }
        public string Text { get; set; }
    }

    public partial class GeminiAi : Page
    {
        private static readonly HttpClient httpClient = new HttpClient();
        private static FirestoreDb db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore().GetAwaiter().GetResult();
                if (Session["ChatHistory"] == null)
                {
                    Session["ChatHistory"] = new List<Message>();
                }
                BindChatHistory();
            }
        }

        private async Task InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        protected async void btnSend_Click(object sender, EventArgs e)
        {
            string prompt = txtPrompt.Text.Trim();
            string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
            string username = Session["username"]?.ToString();

            if (string.IsNullOrEmpty(prompt))
            {
                AddMessage("model", "Please enter a question.");
                return;
            }

            if (string.IsNullOrEmpty(username))
            {
                AddMessage("model", "You must be logged in to use this feature.");
                return;
            }

            if (string.IsNullOrEmpty(apiKey))
            {
                AddMessage("model", "API key is missing.");
                return;
            }

            // Add user message to history
            AddMessage("user", prompt);

            // Check for specific prompt to list classes
            if (prompt.ToLower().Contains("list all my classes") || prompt.ToLower().Contains("list my classes"))
            {
                string classList = await FetchUserClasses(username);
                AddMessage("model", classList);
            }
            else
            {
                // Fetch data from all Firestore collections and subcollections
                string firestoreData = await FetchFirestoreData();

                // Combine Firestore data with user prompt and username context
                string combinedPrompt = $"You are assisting a user with username '{username}'. Based on the following data from my Firestore database (including subcollections):\n{firestoreData}\n\nUser prompt: {prompt}";

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
                    }
                };

                var json = Newtonsoft.Json.JsonConvert.SerializeObject(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                try
                {
                    var response = await httpClient.PostAsync(url, content);
                    var responseString = await response.Content.ReadAsStringAsync();

                    if (!response.IsSuccessStatusCode)
                    {
                        AddMessage("model", $"API Error: {responseString}");
                        return;
                    }

                    var jsonResponse = JObject.Parse(responseString);
                    var reply = jsonResponse["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.ToString();

                    AddMessage("model", reply ?? "No response from Gemini.");
                }
                catch (Exception ex)
                {
                    AddMessage("model", "Error: " + ex.Message);
                }
            }

            // Clear the input
            txtPrompt.Text = "";
        }

        private async Task<string> FetchUserClasses(string username)
        {
            try
            {
                var collectionRef = db.Collection("classrooms");
                Query query = collectionRef.WhereEqualTo("username", username); // Assuming 'username' field links user to classroom
                QuerySnapshot snapshot = await query.GetSnapshotAsync();

                if (!snapshot.Documents.Any())
                {
                    return $"No classes found for user '{username}'.";
                }

                var classList = new List<string>();
                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var fields = document.ToDictionary()
                                         .Select(kvp => $"{kvp.Key}: {kvp.Value}");
                    var subcollectionData = await FetchSubcollections(document.Reference);
                    classList.Add($"Classroom {document.Id}: {string.Join(", ", fields)}\nSubcollections:\n{subcollectionData}");
                }

                return $"Your classes:\n{string.Join("\n", classList)}";
            }
            catch (Exception ex)
            {
                return $"Error fetching your classes: {ex.Message}";
            }
        }

        private async Task<string> FetchFirestoreData()
        {
            try
            {
                var collectionNames = new List<string> { "users", "classrooms", "posts" };
                var dataList = new List<string>();

                foreach (var collectionName in collectionNames)
                {
                    var collectionRef = db.Collection(collectionName);
                    QuerySnapshot snapshot = await collectionRef.Limit(10).GetSnapshotAsync();

                    if (!snapshot.Documents.Any())
                    {
                        dataList.Add($"Collection '{collectionName}': No documents found.");
                        continue;
                    }

                    foreach (DocumentSnapshot document in snapshot.Documents)
                    {
                        var fields = document.ToDictionary()
                                             .Select(kvp => $"{kvp.Key}: {kvp.Value}");
                        var subcollectionData = await FetchSubcollections(document.Reference);
                        dataList.Add($"Collection '{collectionName}' Document {document.Id}: {string.Join(", ", fields)}\nSubcollections:\n{subcollectionData}");
                    }
                }

                return dataList.Any() ? string.Join("\n", dataList) : "No data found.";
            }
            catch (Exception ex)
            {
                return $"Error fetching Firestore data: {ex.Message}";
            }
        }

        private async Task<string> FetchSubcollections(DocumentReference documentRef)
        {
            try
            {
                var subcollectionList = new List<string>();
                var subcollections = await documentRef.ListCollectionsAsync().ToListAsync();

                if (!subcollections.Any())
                {
                    return "  No subcollections found.";
                }

                foreach (var subcollection in subcollections)
                {
                    QuerySnapshot subSnapshot = await subcollection.Limit(10).GetSnapshotAsync();
                    if (!subSnapshot.Documents.Any())
                    {
                        subcollectionList.Add($"  Subcollection '{subcollection.Id}': No documents found.");
                        continue;
                    }

                    foreach (DocumentSnapshot subDoc in subSnapshot.Documents)
                    {
                        var subFields = subDoc.ToDictionary()
                                              .Select(kvp => $"{kvp.Key}: {kvp.Value}");
                        var nestedSubcollections = await FetchSubcollections(subDoc.Reference); // Recursive call for nested subcollections
                        subcollectionList.Add($"  Subcollection '{subcollection.Id}' Document {subDoc.Id}: {string.Join(", ", subFields)}\n{nestedSubcollections}");
                    }
                }

                return string.Join("\n", subcollectionList);
            }
            catch (Exception ex)
            {
                return $"  Error fetching subcollections: {ex.Message}";
            }
        }

        private void AddMessage(string role, string text)
        {
            var history = (List<Message>)Session["ChatHistory"];
            history.Add(new Message { Role = role, Text = text });
            BindChatHistory();
        }

        private void BindChatHistory()
        {
            var history = (List<Message>)Session["ChatHistory"];
            lvChat.DataSource = history;
            lvChat.DataBind();
        }
    }
}