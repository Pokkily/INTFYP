<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeFile="AddBook.aspx.cs" Inherits="INTFYP.AddBook" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Add Book</title>

  <script defer src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app.js"></script>
  <script defer src="https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore.js"></script>

  <script defer>
      document.addEventListener("DOMContentLoaded", () => {
          const firebaseConfig = {
              apiKey: "YOUR_API_KEY",
              authDomain: "your-project-id.firebaseapp.com",
              projectId: "your-project-id",
              storageBucket: "your-project-id.appspot.com",
              messagingSenderId: "1234567890",
              appId: "1:1234567890:web:abcdefg"
          };

          firebase.initializeApp(firebaseConfig);
          const db = firebase.firestore();

          const form = document.getElementById("bookForm");

          form?.addEventListener("submit", async function (e) {
              e.preventDefault();

              const title = document.getElementById("title").value.trim();
              const author = document.getElementById("author").value.trim();
              const category = document.getElementById("category").value.trim();

              try {
                  await db.collection("books").add({ title, author, category });
                  document.getElementById("status").innerText = "✅ Book added successfully!";
                  form.reset();
              } catch (error) {
                  document.getElementById("status").innerText = "❌ Error: " + error.message;
              }
          });
      });
  </script>

  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      background-color: #f5f5f5;
    }
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      background-color: #fff;
      padding: 10px 30px;
      border-bottom: 1px solid #ddd;
    }
    .logo { font-weight: bold; font-size: 24px; }
    nav a {
      margin: 0 10px;
      text-decoration: none;
      color: #333;
    }
    nav a.active {
      font-weight: bold;
      color: #000;
    }
    .auth-buttons button {
      margin-left: 10px;
      padding: 5px 10px;
      cursor: pointer;
    }
    .auth-buttons .register {
      background-color: black;
      color: white;
      border: none;
    }
    main { padding: 20px 40px; }
    .welcome-container {
      width: 100%;
      text-align: center;
      border: 2px solid #333;
      background-color: #cccccc8f;
      padding: 30px 0;
    }
    .welcome h1 { font-size: 36px; margin-bottom: 10px; }
    .welcome p { font-size: 18px; color: #666; }
    .content {
      display: flex;
      margin-top: 30px;
    }
    .sidebar {
      width: 200px;
      margin-right: 30px;
    }
    .categories button,
    .extra button {
      display: block;
      width: 100%;
      margin-bottom: 10px;
      padding: 8px;
      background-color: #e4e4e4;
      border: none;
      cursor: pointer;
    }
    .extra .bookmark { background-color: #d4d4ff; }
    .extra .citation { background-color: #ddd; }
    .main-library { flex: 1; }
    .add-book-form {
      background-color: #fff;
      padding: 100px;
      border: 1px solid #ccc;
      border-radius: 8px;
      max-width: 600px;
    }
    .add-book-form label {
      display: block;
      margin-top: 15px;
    }
    .form-control {
      width: 100%;
      padding: 8px;
      margin-top: 5px;
    }
    .btn {
      margin-top: 20px;
      padding: 10px 20px;
      background-color: black;
      color: white;
      border: none;
      cursor: pointer;
    }
    #status {
      margin-top: 15px;
      font-weight: bold;
    }
  </style>
</head>

<body>
  <form id="form1" runat="server">
    <header>
      <div class="logo">L.</div>
      <nav>
        <a href="#">Class</a>
        <a href="#">StudyHub</a>
        <a href="Library.aspx" class="active">Library</a>
        <a href="#">Quiz</a>
        <a href="#">Learning</a>
        <a href="#">Feedback</a>
      </nav>
      <div class="auth-buttons">
        <asp:Button ID="btnSignIn" runat="server" Text="Sign in" CssClass="signin" />
        <asp:Button ID="btnRegister" runat="server" Text="Register" CssClass="register" />
      </div>
    </header>

    <main>
      <section class="welcome-container">
        <div class="welcome">
          <h1>Add New Book</h1>
          <p>Enter book information to save it to Firebase</p>
        </div>
      </section>

      <section class="content">
        <aside class="sidebar">
          <div class="categories">
            <h3>CATEGORY</h3>
            <button>#Fiction</button>
            <button>#Horror</button>
            <button>#Adventure</button>
            <button>#Fantasy</button>
            <button>#Drama</button>
            <button>#English</button>
            <button>#Article</button>
          </div>
          <div class="extra">
            <button class="bookmark">Your Bookmark</button>
            <button class="citation">Citation Generator</button>
          </div>
        </aside>

        <section class="main-library">
          <div class="add-book-form">
            <h2>Add New Book</h2>

            <asp:Label ID="lblStatus" runat="server" Text="" ForeColor="Green"></asp:Label>

            <asp:Label Text="Title:" runat="server" AssociatedControlID="txtTitle" />
            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" />

            <asp:Label Text="Author:" runat="server" AssociatedControlID="txtAuthor" />
            <asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" />

            <asp:Label Text="Category:" runat="server" AssociatedControlID="txtCategory" />
            <asp:TextBox ID="txtCategory" runat="server" CssClass="form-control" />

            <asp:Label Text="Upload PDF:" runat="server" AssociatedControlID="filePdf" />
            <asp:FileUpload ID="filePdf" runat="server" CssClass="form-control" />

            <asp:Button ID="btnSubmit" runat="server" Text="Add Book" OnClick="btnSubmit_Click" CssClass="btn" />

            <p id="status"></p>
          </div>
        </section>
      </section>
    </main>
  </form>
</body>
</html>