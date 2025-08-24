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

        public string CurrentUserId => Session["userId"]?.ToString();

        protected async void Page_Load(object sender, EventArgs e)
        {
            InitFirestore();

            if (!IsPostBack)
            {
                await LoadBooks();
            }
        }

        private void InitFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async System.Threading.Tasks.Task LoadBooks()
        {
            System.Diagnostics.Debug.WriteLine("Session userId: " + Session["userId"]);

            QuerySnapshot snapshot = await db.Collection("books").GetSnapshotAsync();
            List<LibraryBook> bookList = new List<LibraryBook>();

            foreach (var doc in snapshot.Documents)
            {
                var book = doc.ConvertTo<LibraryBook>();

                if (book.RecommendedBy == null) book.RecommendedBy = new List<string>();
                if (book.FavoritedBy == null) book.FavoritedBy = new List<string>();
                if (book.Recommendations == null) book.Recommendations = 0;

                book.DocumentId = doc.Id;

                // Set the state based on whether current user has liked/favorited
                book.IsRecommended = book.RecommendedBy.Contains(CurrentUserId);
                book.IsFavorited = book.FavoritedBy.Contains(CurrentUserId);

                bookList.Add(book);
            }

            bookList = bookList.OrderByDescending(b => b.Recommendations).ToList();

            // Show "No Books" panel if no books found
            if (bookList.Count == 0)
            {
                pnlNoBooks.Visible = true;
                Repeater1.DataSource = null;
            }
            else
            {
                pnlNoBooks.Visible = false;
                Repeater1.DataSource = bookList;
            }

            Repeater1.DataBind();
        }

        // COMBINED search functionality - searches by title, author, category, AND tag in ONE search bar
        protected async void txtBookSearch_TextChanged(object sender, EventArgs e)
        {
            await ApplyFilters();
        }

        // Category filter functionality
        protected async void ddlCategoryFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            await ApplyFilters();
        }

        // Combined method to apply both search and category filter
        private async System.Threading.Tasks.Task ApplyFilters()
        {
            string keyword = txtBookSearch.Text.ToLower().Trim();
            string selectedCategory = ddlCategoryFilter.SelectedValue;

            QuerySnapshot snapshot = await db.Collection("books").GetSnapshotAsync();
            List<LibraryBook> results = new List<LibraryBook>();

            foreach (var doc in snapshot.Documents)
            {
                var book = doc.ConvertTo<LibraryBook>();
                book.DocumentId = doc.Id;

                if (book.RecommendedBy == null) book.RecommendedBy = new List<string>();
                if (book.FavoritedBy == null) book.FavoritedBy = new List<string>();
                if (book.Recommendations == null) book.Recommendations = 0;

                // Set the state based on whether current user has liked/favorited
                book.IsRecommended = book.RecommendedBy.Contains(CurrentUserId);
                book.IsFavorited = book.FavoritedBy.Contains(CurrentUserId);

                bool matchesSearch = true;
                bool matchesCategory = true;

                // Apply search filter (if search term exists)
                if (!string.IsNullOrEmpty(keyword))
                {
                    matchesSearch =
                        (book.Title?.ToLower().Contains(keyword) ?? false) ||
                        (book.Author?.ToLower().Contains(keyword) ?? false) ||
                        (book.Category?.ToLower().Contains(keyword) ?? false) ||
                        (book.Tag?.ToLower().Contains(keyword) ?? false);
                }

                // Apply category filter (if category is selected)
                if (!string.IsNullOrEmpty(selectedCategory))
                {
                    matchesCategory = string.Equals(book.Category, selectedCategory, StringComparison.OrdinalIgnoreCase);
                }

                // Book must match both search and category filters
                if (matchesSearch && matchesCategory)
                {
                    results.Add(book);
                }
            }

            // Order by recommendations (most recommended first)
            results = results.OrderByDescending(b => b.Recommendations ?? 0).ToList();

            // Show appropriate content based on results
            if (results.Count == 0)
            {
                pnlNoBooks.Visible = true;
                Repeater1.DataSource = null;
            }
            else
            {
                pnlNoBooks.Visible = false;
                Repeater1.DataSource = results;
            }

            Repeater1.DataBind();
        }

        protected async void Repeater1_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("Session userId: " + Session["userId"]);

            if (string.IsNullOrEmpty(CurrentUserId)) return;

            string bookId = e.CommandArgument.ToString();
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

            // Reload based on current filter state
            if (!string.IsNullOrEmpty(txtBookSearch.Text.Trim()) || !string.IsNullOrEmpty(ddlCategoryFilter.SelectedValue))
            {
                // If there are active filters, reapply them
                await ApplyFilters();
            }
            else
            {
                // If no filters active, load all books
                await LoadBooks();
            }
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

            public string DocumentId { get; set; }
            public bool IsRecommended { get; set; }
            public bool IsFavorited { get; set; }
        }
    }
}