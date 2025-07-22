using System;
using System.Web.UI;

namespace YourProjectNamespace
{
    public partial class Scholarship : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // You can preload user info here using Session["username"], etc.
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // Just a sample message; later you can save this to Firestore
            lblMessage.Text = "Scholarship application submitted successfully!";
        }

        protected void btnSubmitResult_Click(object sender, EventArgs e)
        {
            Response.Redirect("SubmitResult.aspx");
        }

    }
}
