using System;
using System.Configuration;
using System.Collections.Generic;
using System.IO;
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

        // Store all books for search functionality
        private static List<object> allBooks = new List<object>();

        protected async void Page_Load(object sender, EventArgs e)
        {
            // Check if request was too large - UPDATED FOR 4MB
            if (Request.ContentLength > (4 * 1024 * 1024))
            {
                ShowErrorMessage("❌ File size exceeds 4 MB limit. Please select a smaller file.");
                return;
            }

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

        // Helper method to update the book count display
        private void UpdateBookCountDisplay(List<object> books, string searchTerm = "")
        {
            int count = books.Count;
            string countText;

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                if (count == 0)
                {
                    countText = "No books found";
                }
                else if (count == 1)
                {
                    countText = "1 book found";
                }
                else
                {
                    countText = $"{count} books found";
                }
            }
            else
            {
                if (count == 0)
                {
                    countText = "No books";
                }
                else if (count == 1)
                {
                    countText = "1 book";
                }
                else
                {
                    countText = $"{count} books";
                }
            }

            lblBookCount.Text = countText;
        }

        protected async void btnSubmit_Click(object sender, EventArgs e)
        {
            // Only validate if the validation group passes
            Page.Validate("AddBookGroup");
            if (!Page.IsValid)
            {
                return;
            }

            // Hide previous messages
            pnlStatus.Visible = false;

            try
            {
                // Validate form inputs
                if (!ValidateForm())
                {
                    return;
                }

                // Validate PDF file
                if (!ValidatePdfFile(filePdf))
                {
                    return;
                }

                string pdfUrl = "";

                // Upload PDF file to Cloudinary
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

                ShowSuccessMessage($"✅ Learning material added successfully! (ID: {addedDocRef.Id})");

                // Clear input fields
                ClearForm();

                // Reload books
                await LoadBooks();
            }
            catch (Exception ex)
            {
                ShowErrorMessage("❌ Error adding material: " + ex.Message);
            }
        }

        private bool ValidateForm()
        {
            // Check if title is empty
            if (string.IsNullOrWhiteSpace(txtTitle.Text))
            {
                ShowErrorMessage("❌ Please enter a title.");
                return false;
            }

            // Check if author is empty
            if (string.IsNullOrWhiteSpace(txtAuthor.Text))
            {
                ShowErrorMessage("❌ Please enter an author.");
                return false;
            }

            // Validate category selection
            if (string.IsNullOrEmpty(ddlCategory.SelectedValue))
            {
                ShowErrorMessage("❌ Please select a category.");
                return false;
            }

            return true;
        }

        private bool ValidatePdfFile(FileUpload fileUpload)
        {
            if (!fileUpload.HasFile)
            {
                ShowErrorMessage("❌ Please select a PDF file.");
                return false;
            }

            // Check file extension
            string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
            if (fileExtension != ".pdf")
            {
                ShowErrorMessage("❌ Only PDF files are allowed.");
                return false;
            }

            // Check file size (4 MB limit) - UPDATED FOR 4MB
            const int maxFileSize = 4 * 1024 * 1024; // 4 MB in bytes
            if (fileUpload.PostedFile.ContentLength > maxFileSize)
            {
                ShowErrorMessage("❌ File size exceeds 4 MB limit. Please select a smaller file.");
                return false;
            }

            // Check MIME type for additional security
            if (fileUpload.PostedFile.ContentType != "application/pdf")
            {
                ShowErrorMessage("❌ Invalid file type. Please select a valid PDF file.");
                return false;
            }

            return true;
        }

        private bool ValidateEditPdfFile(FileUpload fileUpload)
        {
            // For edit, PDF file is optional
            if (!fileUpload.HasFile)
            {
                return true; // No file selected is OK for edit
            }

            // Check file extension
            string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
            if (fileExtension != ".pdf")
            {
                lblBookStatus.Text = "❌ Only PDF files are allowed.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return false;
            }

            // Check file size (4 MB limit) - UPDATED FOR 4MB
            const int maxFileSize = 4 * 1024 * 1024; // 4 MB in bytes
            if (fileUpload.PostedFile.ContentLength > maxFileSize)
            {
                lblBookStatus.Text = "❌ File size exceeds 4 MB limit. Please select a smaller file.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return false;
            }

            // Check MIME type for additional security
            if (fileUpload.PostedFile.ContentType != "application/pdf")
            {
                lblBookStatus.Text = "❌ Invalid file type. Please select a valid PDF file.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return false;
            }

            return true;
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

                if (uploadResult.Error != null)
                {
                    throw new Exception($"Cloudinary upload error: {uploadResult.Error.Message}");
                }

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

                // Store all books for search functionality
                allBooks = books;

                // Apply search filter if there's a search term
                var filteredBooks = FilterBooks(books, txtSearch.Text);

                rptBooks.DataSource = filteredBooks;
                rptBooks.DataBind();

                // Update book count display
                UpdateBookCountDisplay(filteredBooks, txtSearch.Text);

                // Set the selected values for edit dropdowns after databinding
                foreach (RepeaterItem item in rptBooks.Items)
                {
                    DropDownList ddlEditCategory = (DropDownList)item.FindControl("ddlEditCategory");
                    if (ddlEditCategory != null && item.ItemIndex < filteredBooks.Count)
                    {
                        var bookData = (dynamic)filteredBooks[item.ItemIndex];
                        string categoryValue = bookData.Category;

                        // Set the selected value
                        ListItem listItem = ddlEditCategory.Items.FindByValue(categoryValue);
                        if (listItem != null)
                        {
                            ddlEditCategory.SelectedValue = categoryValue;
                        }
                    }
                }

                pnlNoBooks.Visible = filteredBooks.Count == 0;

                // Show appropriate message based on whether we're searching or not
                if (pnlNoBooks.Visible)
                {
                    Panel pnlNoSearchResults = (Panel)pnlNoBooks.FindControl("pnlNoSearchResults");
                    Panel pnlNoBooksAtAll = (Panel)pnlNoBooks.FindControl("pnlNoBooksAtAll");

                    bool hasSearchTerm = !string.IsNullOrWhiteSpace(txtSearch.Text);
                    pnlNoSearchResults.Visible = hasSearchTerm;
                    pnlNoBooksAtAll.Visible = !hasSearchTerm;
                }

                // Clear any previous book status messages
                lblBookStatus.Text = "";
            }
            catch (Exception ex)
            {
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                lblBookStatus.Text = "❌ Error loading books: " + ex.Message;

                // Show 0 books if there's an error
                UpdateBookCountDisplay(new List<object>());
            }
        }

        private List<object> FilterBooks(List<object> books, string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
            {
                return books;
            }

            searchTerm = searchTerm.ToLower();
            var filteredBooks = new List<object>();

            foreach (var book in books)
            {
                var bookData = (dynamic)book;
                string title = bookData.Title?.ToString()?.ToLower() ?? "";
                string author = bookData.Author?.ToString()?.ToLower() ?? "";
                string category = bookData.Category?.ToString()?.ToLower() ?? "";
                string tag = bookData.Tag?.ToString()?.ToLower() ?? "";

                if (title.Contains(searchTerm) ||
                    author.Contains(searchTerm) ||
                    category.Contains(searchTerm) ||
                    tag.Contains(searchTerm))
                {
                    filteredBooks.Add(book);
                }
            }

            return filteredBooks;
        }

        protected async void txtSearch_TextChanged(object sender, EventArgs e)
        {
            // Filter and display books based on search term
            var filteredBooks = FilterBooks(allBooks, txtSearch.Text);

            rptBooks.DataSource = filteredBooks;
            rptBooks.DataBind();

            // Update book count display with search term
            UpdateBookCountDisplay(filteredBooks, txtSearch.Text);

            // Set the selected values for edit dropdowns after databinding
            foreach (RepeaterItem item in rptBooks.Items)
            {
                DropDownList ddlEditCategory = (DropDownList)item.FindControl("ddlEditCategory");
                if (ddlEditCategory != null && item.ItemIndex < filteredBooks.Count)
                {
                    var bookData = (dynamic)filteredBooks[item.ItemIndex];
                    string categoryValue = bookData.Category;

                    // Set the selected value
                    ListItem listItem = ddlEditCategory.Items.FindByValue(categoryValue);
                    if (listItem != null)
                    {
                        ddlEditCategory.SelectedValue = categoryValue;
                    }
                }
            }

            pnlNoBooks.Visible = filteredBooks.Count == 0;

            // Show appropriate message based on whether we're searching or not
            if (pnlNoBooks.Visible)
            {
                Panel pnlNoSearchResults = (Panel)pnlNoBooks.FindControl("pnlNoSearchResults");
                Panel pnlNoBooksAtAll = (Panel)pnlNoBooks.FindControl("pnlNoBooksAtAll");

                bool hasSearchTerm = !string.IsNullOrWhiteSpace(txtSearch.Text);
                pnlNoSearchResults.Visible = hasSearchTerm;
                pnlNoBooksAtAll.Visible = !hasSearchTerm;
            }
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";

            // Display all books
            rptBooks.DataSource = allBooks;
            rptBooks.DataBind();

            // Update book count display (no search term)
            UpdateBookCountDisplay(allBooks);

            // Set the selected values for edit dropdowns after databinding
            foreach (RepeaterItem item in rptBooks.Items)
            {
                DropDownList ddlEditCategory = (DropDownList)item.FindControl("ddlEditCategory");
                if (ddlEditCategory != null && item.ItemIndex < allBooks.Count)
                {
                    var bookData = (dynamic)allBooks[item.ItemIndex];
                    string categoryValue = bookData.Category;

                    // Set the selected value
                    ListItem listItem = ddlEditCategory.Items.FindByValue(categoryValue);
                    if (listItem != null)
                    {
                        ddlEditCategory.SelectedValue = categoryValue;
                    }
                }
            }

            pnlNoBooks.Visible = allBooks.Count == 0;

            // Show appropriate message 
            if (pnlNoBooks.Visible)
            {
                Panel pnlNoSearchResults = (Panel)pnlNoBooks.FindControl("pnlNoSearchResults");
                Panel pnlNoBooksAtAll = (Panel)pnlNoBooks.FindControl("pnlNoBooksAtAll");

                pnlNoSearchResults.Visible = false; // No search term now
                pnlNoBooksAtAll.Visible = true; // Show general message
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

            // Validate required fields
            if (string.IsNullOrWhiteSpace(txtEditTitle.Text))
            {
                lblBookStatus.Text = "❌ Please enter a title.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }

            if (string.IsNullOrWhiteSpace(txtEditAuthor.Text))
            {
                lblBookStatus.Text = "❌ Please enter an author.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // Validate category selection
            if (string.IsNullOrEmpty(ddlEditCategory.SelectedValue))
            {
                lblBookStatus.Text = "❌ Please select a category.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // Validate PDF file if uploaded
            if (!ValidateEditPdfFile(fileEditPdf))
            {
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

        private void ShowSuccessMessage(string message)
        {
            lblStatus.Text = message;
            lblStatus.ForeColor = System.Drawing.Color.Green;
            pnlStatus.Visible = true;
        }

        private void ShowErrorMessage(string message)
        {
            lblStatus.Text = message;
            lblStatus.ForeColor = System.Drawing.Color.Red;
            pnlStatus.Visible = true;
        }

        private void ClearForm()
        {
            txtTitle.Text = "";
            txtAuthor.Text = "";
            ddlCategory.SelectedIndex = 0; // Reset to first item (-- Select Category --)
            txtTag.Text = "";
            // Note: We don't clear the file upload control as it's automatically cleared after postback
        }
    }
}