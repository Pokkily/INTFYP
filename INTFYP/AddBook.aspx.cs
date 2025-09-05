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

        private static List<object> allBooks = new List<object>();

        protected async void Page_Load(object sender, EventArgs e)
        {
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
            Page.Validate("AddBookGroup");
            if (!Page.IsValid)
            {
                return;
            }

            pnlStatus.Visible = false;

            try
            {
                if (!ValidateForm())
                {
                    return;
                }

                if (!ValidatePdfFile(filePdf))
                {
                    return;
                }

                string pdfUrl = "";

                if (filePdf.HasFile)
                {
                    pdfUrl = await UploadPdfToCloudinary(filePdf);
                }

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

                ClearForm();

                await LoadBooks();
            }
            catch (Exception ex)
            {
                ShowErrorMessage("❌ Error adding material: " + ex.Message);
            }
        }

        private bool ValidateForm()
        {
            if (string.IsNullOrWhiteSpace(txtTitle.Text))
            {
                ShowErrorMessage("❌ Please enter a title.");
                return false;
            }

            if (string.IsNullOrWhiteSpace(txtAuthor.Text))
            {
                ShowErrorMessage("❌ Please enter an author.");
                return false;
            }

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

            string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
            if (fileExtension != ".pdf")
            {
                ShowErrorMessage("❌ Only PDF files are allowed.");
                return false;
            }

            const int maxFileSize = 4 * 1024 * 1024;
            if (fileUpload.PostedFile.ContentLength > maxFileSize)
            {
                ShowErrorMessage("❌ File size exceeds 4 MB limit. Please select a smaller file.");
                return false;
            }

            if (fileUpload.PostedFile.ContentType != "application/pdf")
            {
                ShowErrorMessage("❌ Invalid file type. Please select a valid PDF file.");
                return false;
            }

            return true;
        }

        private bool ValidateEditPdfFile(FileUpload fileUpload)
        {
            if (!fileUpload.HasFile)
            {
                return true;
            }

            string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
            if (fileExtension != ".pdf")
            {
                lblBookStatus.Text = "❌ Only PDF files are allowed.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return false;
            }

            const int maxFileSize = 4 * 1024 * 1024;
            if (fileUpload.PostedFile.ContentLength > maxFileSize)
            {
                lblBookStatus.Text = "❌ File size exceeds 4 MB limit. Please select a smaller file.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return false;
            }

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

                allBooks = books;

                var filteredBooks = FilterBooks(books, txtSearch.Text);

                rptBooks.DataSource = filteredBooks;
                rptBooks.DataBind();

                UpdateBookCountDisplay(filteredBooks, txtSearch.Text);

                foreach (RepeaterItem item in rptBooks.Items)
                {
                    DropDownList ddlEditCategory = (DropDownList)item.FindControl("ddlEditCategory");
                    if (ddlEditCategory != null && item.ItemIndex < filteredBooks.Count)
                    {
                        var bookData = (dynamic)filteredBooks[item.ItemIndex];
                        string categoryValue = bookData.Category;

                        ListItem listItem = ddlEditCategory.Items.FindByValue(categoryValue);
                        if (listItem != null)
                        {
                            ddlEditCategory.SelectedValue = categoryValue;
                        }
                    }
                }

                pnlNoBooks.Visible = filteredBooks.Count == 0;

                if (pnlNoBooks.Visible)
                {
                    Panel pnlNoSearchResults = (Panel)pnlNoBooks.FindControl("pnlNoSearchResults");
                    Panel pnlNoBooksAtAll = (Panel)pnlNoBooks.FindControl("pnlNoBooksAtAll");

                    bool hasSearchTerm = !string.IsNullOrWhiteSpace(txtSearch.Text);
                    pnlNoSearchResults.Visible = hasSearchTerm;
                    pnlNoBooksAtAll.Visible = !hasSearchTerm;
                }

                lblBookStatus.Text = "";
            }
            catch (Exception ex)
            {
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                lblBookStatus.Text = "❌ Error loading books: " + ex.Message;

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
            var filteredBooks = FilterBooks(allBooks, txtSearch.Text);

            rptBooks.DataSource = filteredBooks;
            rptBooks.DataBind();

            UpdateBookCountDisplay(filteredBooks, txtSearch.Text);

            foreach (RepeaterItem item in rptBooks.Items)
            {
                DropDownList ddlEditCategory = (DropDownList)item.FindControl("ddlEditCategory");
                if (ddlEditCategory != null && item.ItemIndex < filteredBooks.Count)
                {
                    var bookData = (dynamic)filteredBooks[item.ItemIndex];
                    string categoryValue = bookData.Category;

                    ListItem listItem = ddlEditCategory.Items.FindByValue(categoryValue);
                    if (listItem != null)
                    {
                        ddlEditCategory.SelectedValue = categoryValue;
                    }
                }
            }

            pnlNoBooks.Visible = filteredBooks.Count == 0;

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

            rptBooks.DataSource = allBooks;
            rptBooks.DataBind();

            UpdateBookCountDisplay(allBooks);

            foreach (RepeaterItem item in rptBooks.Items)
            {
                DropDownList ddlEditCategory = (DropDownList)item.FindControl("ddlEditCategory");
                if (ddlEditCategory != null && item.ItemIndex < allBooks.Count)
                {
                    var bookData = (dynamic)allBooks[item.ItemIndex];
                    string categoryValue = bookData.Category;

                    ListItem listItem = ddlEditCategory.Items.FindByValue(categoryValue);
                    if (listItem != null)
                    {
                        ddlEditCategory.SelectedValue = categoryValue;
                    }
                }
            }

            pnlNoBooks.Visible = allBooks.Count == 0;
 
            if (pnlNoBooks.Visible)
            {
                Panel pnlNoSearchResults = (Panel)pnlNoBooks.FindControl("pnlNoSearchResults");
                Panel pnlNoBooksAtAll = (Panel)pnlNoBooks.FindControl("pnlNoBooksAtAll");

                pnlNoSearchResults.Visible = false;
                pnlNoBooksAtAll.Visible = true;
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
            TextBox txtEditTitle = (TextBox)e.Item.FindControl("txtEditTitle");
            TextBox txtEditAuthor = (TextBox)e.Item.FindControl("txtEditAuthor");
            DropDownList ddlEditCategory = (DropDownList)e.Item.FindControl("ddlEditCategory");
            TextBox txtEditTag = (TextBox)e.Item.FindControl("txtEditTag");
            FileUpload fileEditPdf = (FileUpload)e.Item.FindControl("fileEditPdf");

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

            if (string.IsNullOrEmpty(ddlEditCategory.SelectedValue))
            {
                lblBookStatus.Text = "❌ Please select a category.";
                lblBookStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }

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

            if (fileEditPdf.HasFile)
            {
                string newPdfUrl = await UploadPdfToCloudinary(fileEditPdf);
                updates["PdfUrl"] = newPdfUrl;
            }

            await bookRef.UpdateAsync(updates);

            lblBookStatus.ForeColor = System.Drawing.Color.Green;
            lblBookStatus.Text = "✅ Book updated successfully!";

            await LoadBooks();
        }

        private async System.Threading.Tasks.Task DeleteBook(string bookId)
        {
            DocumentReference bookRef = db.Collection("books").Document(bookId);
            await bookRef.DeleteAsync();

            lblBookStatus.ForeColor = System.Drawing.Color.Green;
            lblBookStatus.Text = "✅ Book deleted successfully!";

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
            ddlCategory.SelectedIndex = 0;
            txtTag.Text = "";
        }
    }
}