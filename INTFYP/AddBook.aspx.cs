using System;
using System.Configuration;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class AddBook : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private static readonly object dbLock = new object();

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitializeFirestore();
            if (!IsPostBack)
            {
                await LoadBooks();
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

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate category selection
                if (string.IsNullOrEmpty(ddlCategory.SelectedValue))
                {
                    lblStatus.Text = "❌ Please select a category.";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    pnlStatus.Visible = true;
                    return;
                }

                string pdfUrl = "";

                // Check if PDF file is uploaded
                if (filePdf.HasFile)
                {
                    pdfUrl = await UploadPdfToCloudinary(filePdf);
                }

                // Save book metadata + PDF URL to Firestore
                DocumentReference addedDocRef = await db.Collection("books").AddAsync(new
                {
                    Title = txtTitle.Text.Trim(),
                    Author = txtAuthor.Text.Trim(),
                    Category = ddlCategory.SelectedValue,
                    Tag = txtTag.Text.Trim(),
                    PdfUrl = pdfUrl,
                    CreatedAt = Timestamp.GetCurrentTimestamp()
                });

                lblStatus.Text = $"✅ Book added successfully! (ID: {addedDocRef.Id})";
                lblStatus.ForeColor = System.Drawing.Color.Green;
                pnlStatus.Visible = true;

                // Clear input fields
                txtTitle.Text = "";
                txtAuthor.Text = "";
                ddlCategory.SelectedIndex = 0; // Reset to first item (-- Select Category --)
                txtTag.Text = "";

                // Reload books
                await LoadBooks();
            }
            catch (Exception ex)
            {
                lblStatus.ForeColor = System.Drawing.Color.Red;
                lblStatus.Text = "❌ Error: " + ex.Message;
                pnlStatus.Visible = true;
            }
        }

        private async System.Threading.Tasks.Task<string> UploadPdfToCloudinary(FileUpload fileUpload)
        {
            var account = new Account(
                ConfigurationManager.AppSettings["CloudinaryCloudName"],
                ConfigurationManager.AppSettings["CloudinaryApiKey"],
                ConfigurationManager.AppSettings["CloudinaryApiSecret"]
            );
            var cloudinary = new Cloudinary(account);

            using (var stream = fileUpload.PostedFile.InputStream)
            {
                var uploadParams = new RawUploadParams
                {
                    File = new FileDescription(fileUpload.FileName, stream),
                    Folder = "book_pdfs"
                };
                var uploadResult = await cloudinary.UploadAsync(uploadParams);

                return uploadResult.SecureUrl?.ToString() ?? "";
            }
        }

        private async System.Threading.Tasks.Task LoadBooks()
        {
            try
            {
                Query booksQuery = db.Collection("books").OrderByDescending("CreatedAt");
                QuerySnapshot snapshot = await booksQuery.GetSnapshotAsync();

                var books = new List<object>();
                foreach (DocumentSnapshot document in snapshot.Documents)
                {
                    var data = document.ToDictionary();
                    books.Add(new
                    {
                        Id = document.Id,
                        Title = data.ContainsKey("Title") ? data["Title"].ToString() : "",
                        Author = data.ContainsKey("Author") ? data["Author"].ToString() : "",
                        Category = data.ContainsKey("Category") ? data["Category"].ToString() : "",
                        Tag = data.ContainsKey("Tag") ? data["Tag"].ToString() : "",
                        PdfUrl = data.ContainsKey("PdfUrl") ? data["PdfUrl"].ToString() : ""
                    });
                }

                rptBooks.DataSource = books;
                rptBooks.DataBind();

                // Set the selected values for edit dropdowns after databinding
                foreach (RepeaterItem item in rptBooks.Items)
                {
                    DropDownList ddlEditCategory = (DropDownList)item.FindControl("ddlEditCategory");
                    if (ddlEditCategory != null)
                    {
                        var bookData = (dynamic)books[item.ItemIndex];
                        string categoryValue = bookData.Category;

                        // Set the selected value
                        ListItem listItem = ddlEditCategory.Items.FindByValue(categoryValue);
                        if (listItem != null)
                        {
                            ddlEditCategory.SelectedValue = categoryValue;
                        }
                    }
                }

                pnlNoBooks.Visible = books.Count == 0;
            }
            catch (Exception ex)
            {
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                lblBookStatus.Text = "❌ Error loading books: " + ex.Message;
            }
        }

        protected async void rptBooks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string bookId = e.CommandArgument.ToString();

            try
            {
                if (e.CommandName == "Update")
                {
                    await UpdateBook(e, bookId);
                }
                else if (e.CommandName == "Delete")
                {
                    await DeleteBook(bookId);
                }
            }
            catch (Exception ex)
            {
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                lblBookStatus.Text = "❌ Error: " + ex.Message;
            }
        }

        private async System.Threading.Tasks.Task UpdateBook(RepeaterCommandEventArgs e, string bookId)
        {
            // Find controls in the repeater item
            TextBox txtEditTitle = (TextBox)e.Item.FindControl("txtEditTitle");
            TextBox txtEditAuthor = (TextBox)e.Item.FindControl("txtEditAuthor");
            DropDownList ddlEditCategory = (DropDownList)e.Item.FindControl("ddlEditCategory");
            TextBox txtEditTag = (TextBox)e.Item.FindControl("txtEditTag");
            FileUpload fileEditPdf = (FileUpload)e.Item.FindControl("fileEditPdf");

            // Validate category selection
            if (string.IsNullOrEmpty(ddlEditCategory.SelectedValue))
            {
                lblBookStatus.Text = "❌ Please select a category.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }

            DocumentReference bookRef = db.Collection("books").Document(bookId);
            var updates = new Dictionary<string, object>
            {
                { "Title", txtEditTitle.Text.Trim() },
                { "Author", txtEditAuthor.Text.Trim() },
                { "Category", ddlEditCategory.SelectedValue },
                { "Tag", txtEditTag.Text.Trim() },
                { "UpdatedAt", Timestamp.GetCurrentTimestamp() }
            };

            // If new PDF is uploaded, update PDF URL
            if (fileEditPdf.HasFile)
            {
                string newPdfUrl = await UploadPdfToCloudinary(fileEditPdf);
                updates["PdfUrl"] = newPdfUrl;
            }

            await bookRef.UpdateAsync(updates);

            lblBookStatus.ForeColor = System.Drawing.Color.Green;
            lblBookStatus.Text = "✅ Book updated successfully!";

            // Reload books
            await LoadBooks();
        }

        private async System.Threading.Tasks.Task DeleteBook(string bookId)
        {
            DocumentReference bookRef = db.Collection("books").Document(bookId);
            await bookRef.DeleteAsync();

            lblBookStatus.ForeColor = System.Drawing.Color.Green;
            lblBookStatus.Text = "✅ Book deleted successfully!";

            // Reload books
            await LoadBooks();
        }
    }
}