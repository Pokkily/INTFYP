using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class Library : System.Web.UI.Page
    {
        private static FirestoreDb db;
        private string currentUserEmail;
        private string currentUserName;

        public string CurrentUserId => Session["userId"]?.ToString();

        protected async void Page_Load(object sender, EventArgs e)
        {
            currentUserEmail = Session["email"]?.ToString();
            currentUserName = Session["username"]?.ToString() ?? "Anonymous";

            if (string.IsNullOrEmpty(currentUserEmail) || string.IsNullOrEmpty(CurrentUserId))
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            InitFirestore();

            if (!IsPostBack)
            {
                await LoadBookSections();
            }
        }

        private void InitFirestore()
        {
            try
            {
                string path = Server.MapPath("~/serviceAccountKey.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
                db = FirestoreDb.Create("intorannetto");
            }
            catch (Exception ex)
            {
                ShowMessage("Error initializing database: " + ex.Message, "text-danger");
            }
        }

        private async System.Threading.Tasks.Task LoadBookSections()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("Session userId: " + Session["userId"]);

                QuerySnapshot snapshot = await db.Collection("books").GetSnapshotAsync();
                List<LibraryBook> allBooks = new List<LibraryBook>();

                foreach (var doc in snapshot.Documents)
                {
                    var book = doc.ConvertTo<LibraryBook>();

                    if (book.RecommendedBy == null) book.RecommendedBy = new List<string>();
                    if (book.FavoritedBy == null) book.FavoritedBy = new List<string>();
                    if (book.Recommendations == null) book.Recommendations = 0;

                    book.DocumentId = doc.Id;

                    book.IsRecommended = book.RecommendedBy.Contains(CurrentUserId);
                    book.IsFavorited = book.FavoritedBy.Contains(CurrentUserId);

                    allBooks.Add(book);

                    System.Diagnostics.Debug.WriteLine($"Book: {book.Title}, CreatedAt: {book.CreatedAt}, DateAdded: {book.DateAdded}, GetCreationDate: {book.GetCreationDate()}");
                }

                if (allBooks.Count == 0)
                {
                    pnlNoBooks.Visible = true;
                    pnlBookSections.Visible = false;
                    return;
                }

                pnlNoBooks.Visible = false;
                pnlBookSections.Visible = true;

                var newestBooks = allBooks
                    .Where(b => b.GetCreationDate() != DateTime.MinValue)
                    .OrderByDescending(b => b.GetCreationDate())
                    .Take(15)
                    .ToList();

                if (newestBooks.Count == 0)
                {
                    newestBooks = allBooks.Take(15).ToList();
                    System.Diagnostics.Debug.WriteLine("No books with valid dates found, using fallback");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"Found {newestBooks.Count} newest books with valid dates");
                    foreach (var book in newestBooks.Take(5))
                    {
                        System.Diagnostics.Debug.WriteLine($"Newest: {book.Title} - {book.GetCreationDate()}");
                    }
                }

                RepNewest.DataSource = newestBooks;
                RepNewest.DataBind();

                var mostRecommended = allBooks.OrderByDescending(b => b.Recommendations ?? 0).Take(15).ToList();
                RepMostRecommended.DataSource = mostRecommended;
                RepMostRecommended.DataBind();

                var alphabetical = allBooks.OrderBy(b => b.Title ?? "").ToList();
                RepAlphabetical.DataSource = alphabetical;
                RepAlphabetical.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading books: " + ex.Message, "text-danger");
            }
        }

        protected async void txtBookSearch_TextChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentUserId))
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            await ApplyFilters();
        }

        protected async void ddlCategoryFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentUserId))
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            await ApplyFilters();
        }

        private async System.Threading.Tasks.Task ApplyFilters()
        {
            try
            {
                string keyword = txtBookSearch.Text.ToLower().Trim();
                string selectedCategory = ddlCategoryFilter.SelectedValue;

                if (string.IsNullOrEmpty(keyword) && string.IsNullOrEmpty(selectedCategory))
                {
                    pnlNewest.Visible = true;
                    pnlMostRecommended.Visible = true;
                    pnlAlphabetical.Visible = true;
                    pnlSearchResults.Visible = false;

                    await LoadBookSections();
                    return;
                }

                QuerySnapshot snapshot = await db.Collection("books").GetSnapshotAsync();
                List<LibraryBook> results = new List<LibraryBook>();

                foreach (var doc in snapshot.Documents)
                {
                    var book = doc.ConvertTo<LibraryBook>();
                    book.DocumentId = doc.Id;

                    if (book.RecommendedBy == null) book.RecommendedBy = new List<string>();
                    if (book.FavoritedBy == null) book.FavoritedBy = new List<string>();
                    if (book.Recommendations == null) book.Recommendations = 0;

                    book.IsRecommended = book.RecommendedBy.Contains(CurrentUserId);
                    book.IsFavorited = book.FavoritedBy.Contains(CurrentUserId);

                    bool matchesSearch = true;
                    bool matchesCategory = true;

                    if (!string.IsNullOrEmpty(keyword))
                    {
                        matchesSearch =
                            (book.Title?.ToLower().Contains(keyword) ?? false) ||
                            (book.Author?.ToLower().Contains(keyword) ?? false) ||
                            (book.Category?.ToLower().Contains(keyword) ?? false) ||
                            (book.Tag?.ToLower().Contains(keyword) ?? false);
                    }

                    if (!string.IsNullOrEmpty(selectedCategory))
                    {
                        matchesCategory = string.Equals(book.Category, selectedCategory, StringComparison.OrdinalIgnoreCase);
                    }

                    if (matchesSearch && matchesCategory)
                    {
                        results.Add(book);
                    }
                }

                if (results.Count == 0)
                {
                    pnlNoBooks.Visible = true;
                    pnlBookSections.Visible = false;
                }
                else
                {
                    pnlNoBooks.Visible = false;
                    pnlBookSections.Visible = true;

                    results = results.OrderByDescending(b => b.Recommendations ?? 0).ToList();

                    pnlNewest.Visible = false;
                    pnlMostRecommended.Visible = false;
                    pnlAlphabetical.Visible = false;
                    pnlSearchResults.Visible = true;

                    RepSearchResults.DataSource = results;
                    RepSearchResults.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error applying filters: " + ex.Message, "text-danger");
            }
        }

        protected async void Repeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentUserId))
            {
                ShowMessage("Please log in to interact with books.", "text-warning");
                return;
            }

            System.Diagnostics.Debug.WriteLine("Session userId: " + Session["userId"]);

            string bookId = e.CommandArgument.ToString();

            try
            {
                DocumentReference bookRef = db.Collection("books").Document(bookId);
                DocumentReference userRef = db.Collection("users").Document(CurrentUserId);

                DocumentSnapshot bookSnap = await bookRef.GetSnapshotAsync();
                DocumentSnapshot userSnap = await userRef.GetSnapshotAsync();

                if (!bookSnap.Exists) return;

                var bookData = bookSnap.ToDictionary();
                var bookUpdates = new Dictionary<string, object>();

                if (e.CommandName == "Favorite")
                {
                    var favoritedBy = bookData.ContainsKey("FavoritedBy")
                        ? ((List<object>)bookData["FavoritedBy"]).Select(x => x.ToString()).ToList()
                        : new List<string>();

                    bool isFavorited = favoritedBy.Contains(CurrentUserId);

                    if (isFavorited)
                    {
                        favoritedBy.Remove(CurrentUserId);
                    }
                    else
                    {
                        favoritedBy.Add(CurrentUserId);
                    }

                    bookUpdates["FavoritedBy"] = favoritedBy;
                    await bookRef.UpdateAsync(bookUpdates);
                }
                else if (e.CommandName == "Recommend")
                {
                    var recommendedBy = bookData.ContainsKey("RecommendedBy")
                        ? ((List<object>)bookData["RecommendedBy"]).Select(x => x.ToString()).ToList()
                        : new List<string>();

                    int recommendations = bookData.ContainsKey("Recommendations")
                        ? Convert.ToInt32(bookData["Recommendations"])
                        : 0;

                    bool isRecommended = recommendedBy.Contains(CurrentUserId);

                    if (isRecommended)
                    {
                        recommendedBy.Remove(CurrentUserId);
                        recommendations = Math.Max(0, recommendations - 1);
                    }
                    else
                    {
                        recommendedBy.Add(CurrentUserId);
                        recommendations += 1;
                    }

                    bookUpdates["RecommendedBy"] = recommendedBy;
                    bookUpdates["Recommendations"] = recommendations;
                    await bookRef.UpdateAsync(bookUpdates);
                }

                if (!string.IsNullOrEmpty(txtBookSearch.Text.Trim()) || !string.IsNullOrEmpty(ddlCategoryFilter.SelectedValue))
                {
                    await ApplyFilters();
                }
                else
                {
                    await LoadBookSections();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating book: " + ex.Message, "text-danger");
            }
        }

        private void ShowMessage(string message, string cssClass)
        {
            System.Diagnostics.Debug.WriteLine($"Message: {message} ({cssClass})");
        }

        [FirestoreData]
        public class LibraryBook
        {
            [FirestoreProperty] public string Title { get; set; }
            [FirestoreProperty] public string Author { get; set; }
            [FirestoreProperty] public string Category { get; set; }
            [FirestoreProperty] public string Tag { get; set; }
            [FirestoreProperty] public int? Recommendations { get; set; }
            [FirestoreProperty] public List<string> RecommendedBy { get; set; }
            [FirestoreProperty] public List<string> FavoritedBy { get; set; }
            [FirestoreProperty] public string PdfUrl { get; set; }
            [FirestoreProperty] public DateTime? DateAdded { get; set; }
            [FirestoreProperty] public Timestamp? CreatedAt { get; set; }

            public DateTime GetCreationDate()
            {
                if (CreatedAt.HasValue)
                    return CreatedAt.Value.ToDateTime();

                if (DateAdded.HasValue)
                    return DateAdded.Value;

                return DateTime.MinValue;
            }

            public string DocumentId { get; set; }
            public bool IsRecommended { get; set; }
            public bool IsFavorited { get; set; }
        }
    }
}