using System;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Web.UI;
using Newtonsoft.Json.Linq;

namespace INTFYP
{
    public partial class GeminiAi : Page
    {
        private static readonly HttpClient httpClient = new HttpClient();

        protected void Page_Load(object sender, EventArgs e) { }

        protected async void btnSend_Click(object sender, EventArgs e)
        {
            string prompt = txtPrompt.Text.Trim();
            string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];

            if (string.IsNullOrEmpty(prompt) || string.IsNullOrEmpty(apiKey))
            {
                lblResponse.Text = "Missing prompt or API key.";
                return;
            }

            string url = $"https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key={apiKey}";

            var payload = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new { text = prompt }
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
    }
}
