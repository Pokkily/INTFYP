<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CitationGenerator.aspx.cs" Inherits="CitationGenerator" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Citation Generator</title>
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

    .citation-generator {
      flex: 1;
      background-color: white;
      padding: 25px;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }

    .form-group {
      margin-bottom: 20px;
    }

    .form-group label {
      display: block;
      margin-bottom: 8px;
      font-weight: bold;
    }

    .form-group input,
    .form-group select,
    .form-group textarea {
      width: 100%;
      padding: 10px;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 16px;
    }

    .form-group textarea {
      min-height: 120px;
      font-family: monospace;
    }

    .style-buttons {
      display: flex;
      gap: 10px;
      margin-bottom: 20px;
    }

    .style-buttons button {
      flex: 1;
      padding: 10px;
      background-color: #f0f0f0;
      border: 1px solid #ddd;
      cursor: pointer;
    }

    .style-buttons button.active {
      background-color: #2c3e50;
      color: white;
    }

    .action-buttons {
      display: flex;
      gap: 10px;
      margin-top: 20px;
    }

    .action-buttons button {
      padding: 12px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 16px;
    }

    .generate-btn {
      background-color: #2c3e50;
      color: white;
    }

    .copy-btn {
      background-color: #3498db;
      color: white;
    }

    .success-message {
      color: #27ae60;
      margin-top: 10px;
      display: none;
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
        <a href="Library.aspx">Library</a>
        <a href="#" class="active">Citation Generator</a>
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
          <h1>Citation Generator</h1>
          <p>Create perfect citations in multiple styles</p>
        </div>
      </section>

      <section class="content">
        <aside class="sidebar">
          <div class="categories">
            <h3>QUICK LINKS</h3>
            <button type="button" onclick="location.href='Library.aspx';">Back to Library</button>
            <button type="button" onclick="location.href='AddBook.aspx';">Add Books</button>
          </div>
          <div class="extra">
            <button class="bookmark">Your Bookmarks</button>
            <button class="citation">Saved Citations</button>
          </div>
        </aside>

        <section class="citation-generator">
          <div class="form-group">
            <label for="sourceType">Source Type</label>
            <select id="sourceType" class="form-control">
              <option value="book">Book</option>
              <option value="website">Website/Webpage</option>
              <option value="journal">Journal Article</option>
              <option value="newspaper">Newspaper Article</option>
              <option value="thesis">Thesis/Dissertation</option>
            </select>
          </div>

          <div id="citationFields">

            <div class="form-group">
              <label for="author">Author(s)</label>
              <input type="text" id="author" placeholder="Lastname, F., Lastname, F., & Lastname, F.">
            </div>
            <div class="form-group">
              <label for="title">Title</label>
              <input type="text" id="title" placeholder="Title of the work">
            </div>
            <div class="form-group">
              <label for="year">Year</label>
              <input type="text" id="year" placeholder="YYYY">
            </div>
            <div class="form-group">
              <label for="publisher">Publisher</label>
              <input type="text" id="publisher" placeholder="Publisher name">
            </div>
          </div>

          <div class="form-group">
            <label>Citation Style</label>
            <div class="style-buttons">
              <button type="button" data-style="apa" class="active">APA</button>
              <button type="button" data-style="mla">MLA</button>
              <button type="button" data-style="chicago">Chicago</button>
              <button type="button" data-style="harvard">Harvard</button>
            </div>
            <select id="citationStyle" style="display: none;">
              <option value="apa">APA</option>
              <option value="mla">MLA</option>
              <option value="chicago">Chicago</option>
              <option value="harvard">Harvard</option>
            </select>
          </div>

          <div class="action-buttons">
            <button id="generateCitation" type="button" class="generate-btn">Generate Citation</button>
            <button id="copyCitation" type="button" class="copy-btn">Copy to Clipboard</button>
          </div>
          <div id="copySuccess" class="success-message">Citation copied to clipboard!</div>

          <div class="form-group">
            <label for="citationOutput">Generated Citation</label>
            <textarea id="citationOutput" readonly></textarea>
          </div>
        </section>
      </section>
    </main>
  </form>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script>
      $(document).ready(function () {
          // Field templates for different source types
          const fieldTemplates = {
              book: `
          <div class="form-group">
            <label for="author">Author(s)</label>
            <input type="text" id="author" placeholder="Lastname, F., Lastname, F., & Lastname, F.">
          </div>
          <div class="form-group">
            <label for="title">Book Title</label>
            <input type="text" id="title" placeholder="Title of the book">
          </div>
          <div class="form-group">
            <label for="year">Publication Year</label>
            <input type="text" id="year" placeholder="YYYY">
          </div>
          <div class="form-group">
            <label for="publisher">Publisher</label>
            <input type="text" id="publisher" placeholder="Publisher name">
          </div>
          <div class="form-group">
            <label for="edition">Edition (if any)</label>
            <input type="text" id="edition" placeholder="e.g., 2nd ed.">
          </div>
        `,
              website: `
          <div class="form-group">
            <label for="author">Author(s) or Organization</label>
            <input type="text" id="author" placeholder="Lastname, F. or Organization Name">
          </div>
          <div class="form-group">
            <label for="title">Page/Article Title</label>
            <input type="text" id="title" placeholder="Title of the webpage">
          </div>
          <div class="form-group">
            <label for="website">Website Name</label>
            <input type="text" id="website" placeholder="Name of the website">
          </div>
          <div class="form-group">
            <label for="date">Publication Date</label>
            <input type="text" id="date" placeholder="YYYY, Month DD or n.d.">
          </div>
          <div class="form-group">
            <label for="url">URL</label>
            <input type="text" id="url" placeholder="https://www.example.com">
          </div>
        `,
              journal: `
          <div class="form-group">
            <label for="author">Author(s)</label>
            <input type="text" id="author" placeholder="Lastname, F., Lastname, F., & Lastname, F.">
          </div>
          <div class="form-group">
            <label for="title">Article Title</label>
            <input type="text" id="title" placeholder="Title of the article">
          </div>
          <div class="form-group">
            <label for="journal">Journal Name</label>
            <input type="text" id="journal" placeholder="Journal title">
          </div>
          <div class="form-group">
            <label for="year">Year</label>
            <input type="text" id="year" placeholder="YYYY">
          </div>
          <div class="form-group">
            <label for="volume">Volume Number</label>
            <input type="text" id="volume" placeholder="Volume number">
          </div>
          <div class="form-group">
            <label for="issue">Issue Number</label>
            <input type="text" id="issue" placeholder="(Issue number)">
          </div>
          <div class="form-group">
            <label for="pages">Page Range</label>
            <input type="text" id="pages" placeholder="pp. xxx-xxx">
          </div>
        `
          };

          // Initialize with book fields
          $('#citationFields').html(fieldTemplates.book);

          // Change fields when source type changes
          $('#sourceType').change(function () {
              const sourceType = $(this).val();
              $('#citationFields').html(fieldTemplates[sourceType] || '');
          });

          // Style toggle buttons
          $('.style-buttons button').click(function () {
              $('.style-buttons button').removeClass('active');
              $(this).addClass('active');
              $('#citationStyle').val($(this).data('style'));
          });

          // Generate citation
          $('#generateCitation').click(function () {
              const style = $('#citationStyle').val();
              const sourceType = $('#sourceType').val();
              let citation = '';

              // Get field values
              const getValue = (id) => $(`#${id}`).val()?.trim() || '[Not specified]';

              // Generate citation based on type and style
              switch (sourceType) {
                  case 'book':
                      const author = getValue('author');
                      const bookTitle = getValue('title');
                      const year = getValue('year');
                      const publisher = getValue('publisher');
                      const edition = getValue('edition');

                      if (style === 'apa') {
                          citation = `${author}. (${year}). ${edition ? `${edition} ` : ''}<em>${bookTitle}</em>. ${publisher}.`;
                      } else if (style === 'mla') {
                          citation = `${author}. <em>${bookTitle}</em>. ${edition ? `${edition}, ` : ''}${publisher}, ${year}.`;
                      } else if (style === 'chicago') {
                          citation = `${author}. ${year}. <em>${bookTitle}</em>. ${edition ? `${edition}. ` : ''}${publisher}.`;
                      } else if (style === 'harvard') {
                          citation = `${author} (${year}) ${edition ? `${edition} ` : ''}<em>${bookTitle}</em>. ${publisher}.`;
                      }
                      break;

                  case 'website':
                      const webAuthor = getValue('author');
                      const pageTitle = getValue('title');
                      const siteName = getValue('website');
                      const pubDate = getValue('date');
                      const url = getValue('url');

                      if (style === 'apa') {
                          citation = `${webAuthor}. (${pubDate}). ${pageTitle}. <em>${siteName}</em>. ${url}`;
                      } else if (style === 'mla') {
                          citation = `${webAuthor}. "${pageTitle}." <em>${siteName}</em>, ${pubDate}, ${url}.`;
                      } else if (style === 'chicago') {
                          citation = `${webAuthor}. "${pageTitle}." <em>${siteName}</em>. ${pubDate}. ${url}.`;
                      } else if (style === 'harvard') {
                          citation = `${webAuthor} (${pubDate}) '${pageTitle}'. <em>${siteName}</em>. Available at: ${url} (Accessed: ${new Date().toLocaleDateString('en-GB')}).`;
                      }
                      break;

                  case 'journal':
                      // Journal article citation logic
                      break;
              }

              $('#citationOutput').val(citation);
          });

          // Copy to clipboard
          $('#copyCitation').click(function () {
              const citationText = $('#citationOutput').val();
              if (citationText) {
                  navigator.clipboard.writeText(citationText).then(function () {
                      $('#copySuccess').fadeIn().delay(2000).fadeOut();
                  });
              }
          });
      });
  </script>
</body>
</html>