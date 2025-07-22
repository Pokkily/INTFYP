using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI.WebControls;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class SubmitResult : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();

            if (!IsPostBack)
            {
                List<int> itemCount = new List<int>();
                for (int i = 0; i < 15; i++) itemCount.Add(i);
                RepeaterSubjects.DataSource = itemCount;
                RepeaterSubjects.DataBind();
            }
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

        protected async void btnSubmitResult_Click(object sender, EventArgs e)
        {
            string userId = Session["userId"] as string;
            if (string.IsNullOrEmpty(userId))
            {
                Response.Write("<script>alert('Upload successful!');</script>");
                return;
            }

            Dictionary<string, object> resultData = new Dictionary<string, object>();

            // Gather subject-grade inputs
            int subjectIndex = 1;
            foreach (RepeaterItem item in RepeaterSubjects.Items)
            {
                TextBox txtSubject = item.FindControl("txtSubject") as TextBox;
                TextBox txtGrade = item.FindControl("txtGrade") as TextBox;

                if (txtSubject != null && txtGrade != null &&
                    !string.IsNullOrWhiteSpace(txtSubject.Text) && !string.IsNullOrWhiteSpace(txtGrade.Text))
                {
                    resultData[$"Subject{subjectIndex}"] = txtSubject.Text;
                    resultData[$"Grade{subjectIndex}"] = txtGrade.Text;
                    subjectIndex++;
                }
            }

            // Upload result image to Cloudinary
            string imageUrl = null;
            if (fileUploadResultImage.HasFile)
            {
                var account = new Account(
                    ConfigurationManager.AppSettings["CloudinaryCloudName"],
                    ConfigurationManager.AppSettings["CloudinaryApiKey"],
                    ConfigurationManager.AppSettings["CloudinaryApiSecret"]
                );

                Cloudinary cloudinary = new Cloudinary(account);
                var uploadParams = new ImageUploadParams()
                {
                    File = new FileDescription(fileUploadResultImage.PostedFile.FileName, fileUploadResultImage.PostedFile.InputStream),
                    Folder = "student_results"
                };

                var uploadResult = cloudinary.Upload(uploadParams);
                imageUrl = uploadResult.SecureUrl.ToString();
                resultData["ResultImageUrl"] = imageUrl;
            }

            resultData["Timestamp"] = Timestamp.GetCurrentTimestamp();

            resultData["StudentId"] = userId;
            resultData["Username"] = Session["username"] as string;
            resultData["Email"] = Session["email"] as string;
            resultData["Position"] = Session["position"] as string; // 
            resultData["Status"] = "Pending";
            resultData["Timestamp"] = Timestamp.GetCurrentTimestamp();

            DocumentReference docRef = db.Collection("results").Document();
            await docRef.SetAsync(resultData);


            lblSuccess.Text = "✅ Result submitted successfully!";
            lblSuccess.CssClass = "alert alert-success d-block"; // Show the success message

        }
    }
}
