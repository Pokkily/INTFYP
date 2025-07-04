using System;
using System.Web.UI;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class Register : Page
    {
        private static FirestoreDb db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (db == null)
            {
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intoranetto");
            }
        }

        protected async void btnRegister_Click(object sender, EventArgs e)
        {
            string firstName = txtFirstName.Text.Trim();
            string lastName = txtLastName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();
            string gender = ddlGender.SelectedValue;
            string position = ddlPosition.SelectedValue;
            string birthdate = txtBirthdate.Text.Trim();
            string address = txtAddress.Text.Trim();

            lblMessage.CssClass = "message";

            // Validation
            if (password != confirmPassword)
            {
                lblMessage.Text = "Passwords do not match.";
                return;
            }

            Query userQuery = db.Collection("users").WhereEqualTo("username", username);
            QuerySnapshot userSnapshot = await userQuery.GetSnapshotAsync();

            if (userSnapshot.Documents.Count > 0)
            {
                lblMessage.Text = "Username already exists.";
                return;
            }

            try
            {
                DocumentReference docRef = db.Collection("users").Document();
                await docRef.SetAsync(new
                {
                    firstName,
                    lastName,
                    username,
                    phone,
                    email,
                    password, // 🔐 You should hash this for production!
                    gender,
                    position,
                    birthdate,
                    address,
                    createdAt = Timestamp.GetCurrentTimestamp()
                });

                lblMessage.CssClass += " success";
                lblMessage.Text = "Registration successful!";
                ClearForm();
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
            }
        }

        private void ClearForm()
        {
            txtFirstName.Text = "";
            txtLastName.Text = "";
            txtUsername.Text = "";
            txtPhone.Text = "";
            txtEmail.Text = "";
            txtPassword.Text = "";
            txtConfirmPassword.Text = "";
            txtBirthdate.Text = "";
            txtAddress.Text = "";
            ddlGender.SelectedIndex = 0;
            ddlPosition.SelectedIndex = 0;
        }
    }
}
