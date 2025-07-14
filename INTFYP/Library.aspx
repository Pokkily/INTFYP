<%@ Page Async="true" Language="C#" AutoEventWireup="true" CodeBehind="Library.aspx.cs" Inherits="INTFYP.Library" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Library</title>
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

    .logo {
      font-weight: bold;
      font-size: 24px;
    }

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

    main {
      padding: 20px 40px;
    }

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

    .extra .bookmark {
      background-color: #d4d4ff;
    }

    .extra .citation {
      background-color: #ddd;
    }

    .main-library {
      flex: 1;
    }

    .search-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .search-bar input {
      padding: 8px;
      width: 200px;
    }

    .book-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 20px;
      margin-top: 20px;
    }

    .book {
      background-color: #ccc;
      padding: 15px;
      border-radius: 8px;
    }

    .book span {
      display: block;
      margin-top: 5px;
      font-size: 12px;
      color: #333;
    }

    .welcome-container {
      width: 100%;
      text-align: center;
      border: 2px solid #333;
      background-color: #cccccc8f;
      padding: 30px 0;
    }

    .welcome h1 {
      font-size: 36px;
      margin-bottom: 10px;
    }

    .welcome p {
      font-size: 18px;
      color: #666;
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
        <a href="#">Scholarship</a>
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
          <h1>Welcome to Library</h1>
          <p>All Materials You Need</p>
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
            <button class="citation" type="button" onclick="location.href='AddBook.aspx';">Add Books</button>
          </div>
        </aside>

        <section class="main-library">
          <div class="search-bar">
            <h2>Recommend</h2>
            <input type="text" placeholder="Search..." />
          </div>

           <asp:Repeater ID="Repeater1" runat="server">
                <HeaderTemplate><div class="book-grid"></HeaderTemplate>
                <ItemTemplate>
                    <div class="book">
                        <h3><%# Eval("Title") %></h3>
                        <p><%# Eval("Author") %></p>
                        <span>#<%# Eval("Category") %></span>

                        <%-- PDF Preview Link --%>
                        <asp:HyperLink 
                            ID="lnkPreview" 
                            runat="server" 
                            NavigateUrl='<%# Eval("PdfUrl") != null ? "PreviewPdf.aspx?url=" + HttpUtility.UrlEncode(Eval("PdfUrl").ToString()) : "#" %>' 
                            Text="📖 Preview PDF" 
                            Target="_blank"
                            Visible='<%# Eval("PdfUrl") != null %>' 
                        />
                    </div>
                </ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>
        </section>
      </section>
    </main>
  </form>
</body>
</html>
