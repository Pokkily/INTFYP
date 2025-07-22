using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;
using static INTFYP.Library;

namespace INTFYP
{
    public partial class FavBooks : Page
    {
        private FirestoreDb db;
        protected string CurrentUserId => Session["userId"] as string;

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

        private async Task LoadBooks()
        {
            QuerySnapshot snapshot = await db.Collection("books").GetSnapshotAsync();
            List<LibraryBook> bookList = new List<LibraryBook>();

            foreach (var doc in snapshot.Documents)
            {
                var book = doc.ConvertTo<LibraryBook>();

                if (book.RecommendedBy == null) book.RecommendedBy = new List<string>();
                if (book.FavoritedBy == null) book.FavoritedBy = new List<string>();
                if (book.Recommendations == null) book.Recommendations = 0;

                book.DocumentId = doc.Id;
                book.IsRecommended = book.RecommendedBy.Contains(CurrentUserId);
                book.IsFavorited = book.FavoritedBy.Contains(CurrentUserId);

                if (book.IsFavorited)
                {
                    bookList.Add(book);
                }
            }

            bookList = bookList.OrderByDescending(b => b.Recommendations).ToList();
            Repeater1.DataSource = bookList;
            Repeater1.DataBind();
        }

        protected async void txtCategorySearch_TextChanged(object sender, EventArgs e)
        {
            string category = txtCategorySearch.Text.ToLower();
            QuerySnapshot snapshot = await db.Collection("books").GetSnapshotAsync();
            List<LibraryBook> filteredBooks = new List<LibraryBook>();

            foreach (var doc in snapshot.Documents)
            {
                var book = doc.ConvertTo<LibraryBook>();
                if (book.RecommendedBy == null) book.RecommendedBy = new List<string>();
                if (book.FavoritedBy == null) book.FavoritedBy = new List<string>();

                book.DocumentId = doc.Id;
                book.IsRecommended = book.RecommendedBy.Contains(CurrentUserId);
                book.IsFavorited = book.FavoritedBy.Contains(CurrentUserId);

                if (book.IsFavorited && book.Category.ToLower().Contains(category))
                {
                    filteredBooks.Add(book);
                }
            }

            filteredBooks = filteredBooks.OrderByDescending(b => b.Recommendations).ToList();
            Repeater1.DataSource = filteredBooks;
            Repeater1.DataBind();
        }

        protected async void txtBookSearch_TextChanged(object sender, EventArgs e)
        {
            string keyword = txtBookSearch.Text.ToLower();
            QuerySnapshot snapshot = await db.Collection("books").GetSnapshotAsync();

            var results = snapshot.Documents
                .Select(doc =>
                {
                    var book = doc.ConvertTo<LibraryBook>();
                    book.DocumentId = doc.Id;

                    if (book.RecommendedBy == null) book.RecommendedBy = new List<string>();
                    if (book.FavoritedBy == null) book.FavoritedBy = new List<string>();
                    if (book.Recommendations == null) book.Recommendations = 0;

                    book.IsRecommended = book.RecommendedBy.Contains(CurrentUserId);
                    book.IsFavorited = book.FavoritedBy.Contains(CurrentUserId);

                    return book;
                })
                .Where(b =>
                    b.IsFavorited && (
                    (b.Title?.ToLower().Contains(keyword) ?? false) ||
                    (b.Author?.ToLower().Contains(keyword) ?? false)))
                .OrderByDescending(b => b.Recommendations ?? 0)
                .ToList();

            Repeater1.DataSource = results;
            Repeater1.DataBind();
        }

        protected async void Repeater1_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentUserId)) return;

            string bookId = e.CommandArgument.ToString();
            DocumentReference bookRef = db.Collection("books").Document(bookId);

            DocumentSnapshot bookSnap = await bookRef.GetSnapshotAsync();
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
                    favoritedBy.Remove(CurrentUserId);
                else
                    favoritedBy.Add(CurrentUserId);

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

            await LoadBooks(); // refresh data after update
        }


    }
}
