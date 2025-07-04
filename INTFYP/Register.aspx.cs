using Google.Cloud.Firestore;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace YourProjectNamespace
{
    public partial class Register : System.Web.UI.Page
    {
        private static FirestoreDb db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (db == null)
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto"); // <-- replace with your project ID
            }
        }

        protected async void btnRegister_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";

            var firstName = txtFirstName.Text.Trim();
            var lastName = txtLastName.Text.Trim();
            var username = txtUsername.Text.Trim();
            var email = txtEmail.Text.Trim();
            var password = txtPassword.Text;
            var phone = txtPhone.Text.Trim();
            var gender = ddlGender.SelectedValue;
            var position = ddlPosition.SelectedValue;
            var birthdate = txtBirthdate.Text;
            var address = txtAddress.Text.Trim();

            if (string.IsNullOrWhiteSpace(firstName) || string.IsNullOrWhiteSpace(username) ||
                string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                lblMessage.Text = "Please fill in all required fields.";
                return;
            }

            // Check for existing username/email
            CollectionReference usersRef = db.Collection("users");

            var usernameSnapshot = await usersRef.WhereEqualTo("username", username).GetSnapshotAsync();
            if (usernameSnapshot.Any())
            {
                lblMessage.Text = "Username already exists.";
                return;
            }

            var emailSnapshot = await usersRef.WhereEqualTo("email", email).GetSnapshotAsync();
            if (emailSnapshot.Any())
            {
                lblMessage.Text = "Email already registered.";
                return;
            }

            // Save new user
            DocumentReference docRef = usersRef.Document();
            var userData = new
            {
                uid = docRef.Id,
                firstName,
                lastName,
                username,
                email,
                password,
                phone,
                gender,
                position,
                birthdate,
                address,
                createdAt = Timestamp.GetCurrentTimestamp()
            };

            await docRef.SetAsync(userData);
            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Text = "Account registered successfully!";
        }
    }
}
