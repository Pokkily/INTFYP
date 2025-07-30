using System;
using System.Configuration;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class AddBook : System.Web.UI.Page
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

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                string pdfUrl = "";

                // Check if PDF file is uploaded
                if (filePdf.HasFile)
                {
                    // Initialize Cloudinary
                    var account = new Account(
                        ConfigurationManager.AppSettings["CloudinaryCloudName"],
                        ConfigurationManager.AppSettings["CloudinaryApiKey"],
                        ConfigurationManager.AppSettings["CloudinaryApiSecret"]
                    );

                    var cloudinary = new Cloudinary(account);

                    // Upload PDF to Cloudinary
                    using (var stream = filePdf.PostedFile.InputStream)
                    {
                        var uploadParams = new RawUploadParams
                        {
                            File = new FileDescription(filePdf.FileName, stream),
                            Folder = "book_pdfs"
                        };

                        var uploadResult = cloudinary.Upload(uploadParams);

                        if (uploadResult.SecureUrl != null)
                        {
                            pdfUrl = uploadResult.SecureUrl.ToString();
                        }
                    }
                }

                // Save book metadata + PDF URL to Firestore
                DocumentReference addedDocRef = await db.Collection("books").AddAsync(new
                {
                    Title = txtTitle.Text.Trim(),
                    Author = txtAuthor.Text.Trim(),
                    Category = txtCategory.Text.Trim(),
                    PdfUrl = pdfUrl,
                    CreatedAt = Timestamp.GetCurrentTimestamp()
                });

                lblStatus.Text = $"✅ Book added successfully! (ID: {addedDocRef.Id})";
                lblStatus.ForeColor = System.Drawing.Color.Green;

                // Optional: Clear input fields
                txtTitle.Text = "";
                txtAuthor.Text = "";
                txtCategory.Text = "";
            }
            catch (Exception ex)
            {
                lblStatus.ForeColor = System.Drawing.Color.Red;
                lblStatus.Text = "❌ Error: " + ex.Message;
            }
        }
    }
}
