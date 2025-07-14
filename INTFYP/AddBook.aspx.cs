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
                // Validate required fields
                if (string.IsNullOrWhiteSpace(txtTitle.Text) ||
                    string.IsNullOrWhiteSpace(txtAuthor.Text) ||
                    string.IsNullOrWhiteSpace(txtCategory.Text))
                {
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    lblStatus.Text = "❌ Please fill in all required fields";
                    return;
                }

                string pdfUrl = "";

                // Check if PDF file is uploaded and valid
                if (filePdf.HasFile && filePdf.PostedFile != null)
                {
                    // Validate file type
                    if (!filePdf.PostedFile.FileName.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase))
                    {
                        lblStatus.ForeColor = System.Drawing.Color.Red;
                        lblStatus.Text = "❌ Only PDF files are allowed";
                        return;
                    }

                    // Initialize Cloudinary
                    var account = new Account(
                        ConfigurationManager.AppSettings["CloudinaryCloudName"],
                        ConfigurationManager.AppSettings["CloudinaryApiKey"],
                        ConfigurationManager.AppSettings["CloudinaryApiSecret"]
                    );

                    var cloudinary = new Cloudinary(account);

                    // Upload PDF to Cloudinary
                    try
                    {
                        using (var stream = filePdf.PostedFile.InputStream)
                        {
                            var uploadParams = new RawUploadParams
                            {
                                File = new FileDescription(filePdf.FileName, stream),
                                Folder = "book_pdfs",
                                ResourceType = ResourceType.Raw // Explicitly set for PDFs
                            };

                            var uploadResult = await cloudinary.UploadAsync(uploadParams);

                            if (uploadResult.Error != null)
                            {
                                throw new Exception(uploadResult.Error.Message);
                            }

                            if (uploadResult.SecureUrl != null)
                            {
                                pdfUrl = uploadResult.SecureUrl.ToString();
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        lblStatus.ForeColor = System.Drawing.Color.Red;
                        lblStatus.Text = "❌ Error uploading PDF: " + ex.Message;
                        return;
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

                // Clear input fields
                txtTitle.Text = "";
                txtAuthor.Text = "";
                txtCategory.Text = "";
                filePdf.Attributes.Clear(); // Clear file upload
            }
            catch (Exception ex)
            {
                lblStatus.ForeColor = System.Drawing.Color.Red;
                lblStatus.Text = "❌ Error: " + ex.Message;
            }
        }
    }
}