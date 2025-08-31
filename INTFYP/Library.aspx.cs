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
                await LoadBookSections();
            }
        }

        private void InitFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async System.Threading.Tasks.Task LoadBookSections()
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

                // Set the state based on whether current user has liked/favorited
                book.IsRecommended = book.RecommendedBy.Contains(CurrentUserId);
                book.IsFavorited = book.FavoritedBy.Contains(CurrentUserId);

                allBooks.Add(book);
            }

            // Check if we have any books
            if (allBooks.Count == 0)
            {
                pnlNoBooks.Visible = true;
                pnlBookSections.Visible = false;
                return;
            }

            pnlNoBooks.Visible = false;
            pnlBookSections.Visible = true;

            // Load Newest Books (15 items) - If you don't have DateAdded, this will be random 15
            var newestBooks = allBooks.OrderByDescending(b => b.DateAdded ?? DateTime.MinValue).Take(15).ToList();
            if (newestBooks.Count == 0) newestBooks = allBooks.Take(15).ToList(); // Fallback if no dates
            RepNewest.DataSource = newestBooks;
            RepNewest.DataBind();

            // Load Most Recommended Books (15 items)
            var mostRecommended = allBooks.OrderByDescending(b => b.Recommendations ?? 0).Take(15).ToList();
            RepMostRecommended.DataSource = mostRecommended;
            RepMostRecommended.DataBind();

            // Load All Books Alphabetically
            var alphabetical = allBooks.OrderBy(b => b.Title ?? "").ToList();
            RepAlphabetical.DataSource = alphabetical;
            RepAlphabetical.DataBind();
        }

        // COMBINED search functionality - now searches across all sections
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

            // If no filters applied, show all sections
            if (string.IsNullOrEmpty(keyword) && string.IsNullOrEmpty(selectedCategory))
            {
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

            // When filtering, show results in a single section, hide others
            if (results.Count == 0)
            {
                pnlNoBooks.Visible = true;
                pnlBookSections.Visible = false;
            }
            else
            {
                pnlNoBooks.Visible = false;
                pnlBookSections.Visible = true;

                // Show filtered results in the "search results" section
                results = results.OrderByDescending(b => b.Recommendations ?? 0).ToList();

                // Hide all sections and show only filtered results
                pnlNewest.Visible = false;
                pnlMostRecommended.Visible = false;
                pnlAlphabetical.Visible = false;
                pnlSearchResults.Visible = true;

                RepSearchResults.DataSource = results;
                RepSearchResults.DataBind();
            }
        }

        protected async void Repeater_ItemCommand(object source, RepeaterCommandEventArgs e)
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
                // If no filters active, load all sections
                await LoadBookSections();
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
            [FirestoreProperty] public DateTime? DateAdded { get; set; } // Add this field to your Firestore documents

            public string DocumentId { get; set; }
            public bool IsRecommended { get; set; }
            public bool IsFavorited { get; set; }
        }
    }
}