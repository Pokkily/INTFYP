using Google.Cloud.Firestore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace YourProjectNamespace
{
    public partial class Login : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
        }

        private void InitializeFirestore()
        {
            if (db == null)
            {
                lock (dbLock)
                {
                    if (db == null)
                    {
                        string path = Server.MapPath("~/serviceAccountKey.json");
                        Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                        db = FirestoreDb.Create("intorannetto");
                    }
                }
            }
        }

        protected async void btnLogin_Click(object sender, EventArgs e)

        {
            lblMessage.Visible = false;

            try
            {
                var input = txtUsernameOrEmail.Text.Trim().ToLower();
                var password = txtPassword.Text;

                if (string.IsNullOrWhiteSpace(input) || string.IsNullOrWhiteSpace(password))
                {
                    ShowError("Please enter both username/email and password.");
                    return;
                }

                QuerySnapshot querySnapshot;
                if (input.Contains("@"))
                {
                    querySnapshot = await db.Collection("users")
                        .WhereEqualTo("email", input)
                        .Limit(1)
                        .GetSnapshotAsync();
                }
                else
                {
                    querySnapshot = await db.Collection("users")
                        .WhereEqualTo("username_lower", input)
                        .Limit(1)
                        .GetSnapshotAsync();
                }

                if (querySnapshot.Count == 0)
                {
                    ShowError("User not found.");
                    return;
                }

                var userDoc = querySnapshot.Documents[0];
                var userData = userDoc.ToDictionary();

                string storedPassword = userData["password"]?.ToString();
                if (storedPassword != password)
                {
                    ShowError("Incorrect password.");
                    return;
                }

                // Optionally update lastLogin
                await db.Collection("users").Document(userDoc.Id).UpdateAsync("lastLogin", Timestamp.GetCurrentTimestamp());

                // Save session info
                Session["userId"] = userDoc.Id;
                Session["username"] = userData["username"];
                Session["email"] = userData["email"];
                Session["position"] = userData["position"];

                ShowSuccess("Login successful! Redirecting...");
                string position = userData["position"]?.ToString()?.ToLower();

                string redirectPage = position == "administrator" ? "admin.aspx" : "mainpage.aspx";

                // Optional: show success first, then redirect
                ShowSuccess("Login successful! Redirecting...");
                ClientScript.RegisterStartupScript(this.GetType(), "redirect",
                    $"setTimeout(function(){{ window.location='{redirectPage}'; }}, 2000);", true);

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Login error: {ex}");
                ShowError("An error occurred while trying to log in. Please try again.");
            }
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-danger";
            lblMessage.Visible = true;
        }

        private void ShowSuccess(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;
        }
    }
}
