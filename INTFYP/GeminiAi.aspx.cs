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

namespace INTFYP
{
    public partial class GeminiAi : Page
    {
        private static readonly HttpClient httpClient = new HttpClient();
        private static FirestoreDb db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore().GetAwaiter().GetResult();
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

            if (string.IsNullOrEmpty(prompt) || string.IsNullOrEmpty(apiKey))
            {
                lblResponse.Text = "Missing prompt or API key.";
                return;
            }

            // Fetch data from all Firestore collections
            string firestoreData = await FetchFirestoreData();

            // Combine Firestore data with user prompt
            string combinedPrompt = $"Based on the following data from my Firestore database:\n{firestoreData}\n\nUser prompt: {prompt}";

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
                    lblResponse.Text = $"API Error: {responseString}";
                    return;
                }

                var jsonResponse = JObject.Parse(responseString);
                var reply = jsonResponse["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.ToString();

                lblResponse.Text = reply ?? "No response from Gemini.";
            }
            catch (Exception ex)
            {
                lblResponse.Text = "Error: " + ex.Message;
            }
        }

        private async Task<string> FetchFirestoreData()
        {
            try
            {
                var collectionNames = new List<string> { "users", "classrooms", "posts" }; // add your top-level collections
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
                        dataList.Add($"Collection '{collectionName}' Document {document.Id}: {string.Join(", ", fields)}");
                    }
                }

                return dataList.Any() ? string.Join("\n", dataList) : "No data found.";
            }
            catch (Exception ex)
            {
                return $"Error fetching Firestore data: {ex.Message}";
            }
        }

    }
}