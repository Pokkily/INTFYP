using System;
using System.Net.Http;
using System.Web.UI;
using Newtonsoft.Json.Linq;
using System.Configuration;
using System.Text; // This is the missing namespace for Encoding

namespace YourNamespace
{
    public partial class GeminiTest : System.Web.UI.Page
    {
        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                string prompt = txtPrompt.Text.Trim();

                if (string.IsNullOrEmpty(prompt))
                {
                    lblError.Text = "Please enter a prompt";
                    lblError.Visible = true;
                    return;
                }

                string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
                string model = "gemini-2.0-flash";

                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("X-goog-api-key", apiKey);

                    var requestData = new
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

                    var jsonContent = new StringContent(
                        Newtonsoft.Json.JsonConvert.SerializeObject(requestData),
                        Encoding.UTF8, // Now properly recognized
                        "application/json");

                    var response = await client.PostAsync(
                        $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent",
                        jsonContent);

                    if (!response.IsSuccessStatusCode)
                    {
                        var errorResponse = await response.Content.ReadAsStringAsync();
                        throw new Exception($"API Error: {response.StatusCode}\n{errorResponse}");
                    }

                    var responseJson = await response.Content.ReadAsStringAsync();
                    dynamic result = JObject.Parse(responseJson);

                    string responseText = result.candidates[0].content.parts[0].text;
                    litResponse.Text = responseText;
                    lblError.Visible = false;
                }
            }
            catch (Exception ex)
            {
                lblError.Text = $"Error: {ex.Message}";
                lblError.Visible = true;
                litResponse.Text = string.Empty;
            }
        }
    }
}