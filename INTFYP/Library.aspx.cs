using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.UI.WebControls;
using Google.Cloud.Firestore;

namespace INTFYP
{
    public partial class Library : System.Web.UI.Page
    {
        private static FirestoreDb db;

        protected async void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeFirestore();
                await LoadBooks();
            }
        }

        private void InitializeFirestore()
        {
            string path = Server.MapPath("~/serviceAccountKey.json");
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", path);
            db = FirestoreDb.Create("intorannetto");
        }

        private async Task LoadBooks()
        {
            Query booksQuery = db.Collection("books");
            QuerySnapshot snapshot = await booksQuery.GetSnapshotAsync();

            List<LibraryBook> bookList = new List<LibraryBook>();

            foreach (DocumentSnapshot doc in snapshot.Documents)
            {
                LibraryBook b = doc.ConvertTo<LibraryBook>();
                b.PdfUrl = doc.ContainsField("PdfUrl") ? doc.GetValue<string>("PdfUrl") : null;
                bookList.Add(b);
            }

            Repeater1.DataSource = bookList;
            Repeater1.DataBind();
        }

        [FirestoreData]
        public class LibraryBook
        {
            [FirestoreProperty] public string Title { get; set; }
            [FirestoreProperty] public string Author { get; set; }
            [FirestoreProperty] public string Category { get; set; }
            [FirestoreProperty] public string PdfUrl { get; set; }
        }
    }
}
