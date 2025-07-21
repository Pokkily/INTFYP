using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
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

    }
}
