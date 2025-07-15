<%@ Page Title="Citation Generator" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CitationGenerator.aspx.cs" Inherits="CitationGenerator" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

  <style>
    /* Move styles here instead of <head> */
    body {
      font-family: Arial, sans-serif;
      background-color: #f5f5f5;
    }
    .welcome-container {
      width: 100%;
      text-align: center;
      border: 2px solid #333;
      background-color: #cccccc8f;
      padding: 30px 0;
      margin-bottom: 30px;
    }
    .welcome h1 { font-size: 36px; margin-bottom: 10px; }
    .welcome p { font-size: 18px; color: #666; }
    .citation-generator {
      background-color: white;
      padding: 25px;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      max-width: 800px;
      margin: auto;
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
  </style>

  <section class="welcome-container">
    <div class="welcome">
      <h1>Citation Generator</h1>
      <p>Create perfect citations in multiple styles</p>
    </div>
  </section>

  <div class="citation-generator">
    <div class="form-group">
      <label for="sourceType">Source Type</label>
      <select id="sourceType">
        <option value="book">Book</option>
        <option value="website">Website/Webpage</option>
        <option value="journal">Journal Article</option>
      </select>
    </div>

    <div id="citationFields">
      <!-- Dynamic input fields injected by JS -->
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
  </div>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script>
      $(document).ready(function () {
          const fieldTemplates = {
              book: `
          <div class="form-group">
            <label for="author">Author(s)</label>
            <input type="text" id="author" placeholder="Lastname, F.">
          </div>
          <div class="form-group">
            <label for="title">Title</label>
            <input type="text" id="title" placeholder="Book title">
          </div>
          <div class="form-group">
            <label for="year">Year</label>
            <input type="text" id="year" placeholder="YYYY">
          </div>
          <div class="form-group">
            <label for="publisher">Publisher</label>
            <input type="text" id="publisher" placeholder="Publisher name">
          </div>
        `,
              website: `
          <div class="form-group">
            <label for="author">Author(s)</label>
            <input type="text" id="author" placeholder="Author or Organization">
          </div>
          <div class="form-group">
            <label for="title">Title</label>
            <input type="text" id="title" placeholder="Page title">
          </div>
          <div class="form-group">
            <label for="website">Website</label>
            <input type="text" id="website" placeholder="Website name">
          </div>
          <div class="form-group">
            <label for="date">Date</label>
            <input type="text" id="date" placeholder="YYYY-MM-DD or n.d.">
          </div>
          <div class="form-group">
            <label for="url">URL</label>
            <input type="text" id="url" placeholder="https://example.com">
          </div>
        `
          };

          $('#citationFields').html(fieldTemplates.book);

          $('#sourceType').change(function () {
              const type = $(this).val();
              $('#citationFields').html(fieldTemplates[type] || '');
          });

          $('.style-buttons button').click(function () {
              $('.style-buttons button').removeClass('active');
              $(this).addClass('active');
              $('#citationStyle').val($(this).data('style'));
          });

          $('#generateCitation').click(function () {
              const style = $('#citationStyle').val();
              const type = $('#sourceType').val();

              const getValue = (id) => $(`#${id}`).val()?.trim() || '[Not specified]';
              let citation = '';

              if (type === 'book') {
                  const a = getValue('author'), t = getValue('title'), y = getValue('year'), p = getValue('publisher');
                  if (style === 'apa') citation = `${a}. (${y}). *${t}*. ${p}.`;
                  if (style === 'mla') citation = `${a}. *${t}*. ${p}, ${y}.`;
                  if (style === 'chicago') citation = `${a}. ${y}. *${t}*. ${p}.`;
                  if (style === 'harvard') citation = `${a} (${y}) *${t}*. ${p}.`;
              }

              if (type === 'website') {
                  const a = getValue('author'), t = getValue('title'), w = getValue('website'), d = getValue('date'), u = getValue('url');
                  if (style === 'apa') citation = `${a}. (${d}). ${t}. *${w}*. ${u}`;
                  if (style === 'mla') citation = `${a}. "${t}." *${w}*, ${d}, ${u}.`;
                  if (style === 'chicago') citation = `${a}. "${t}." *${w}*. ${d}. ${u}.`;
                  if (style === 'harvard') citation = `${a} (${d}) '${t}'. *${w}*. Available at: ${u} (Accessed: ${new Date().toLocaleDateString('en-GB')}).`;
              }

              $('#citationOutput').val(citation);
          });

          $('#copyCitation').click(function () {
              const citationText = $('#citationOutput').val();
              if (citationText) {
                  navigator.clipboard.writeText(citationText).then(() => {
                      $('#copySuccess').fadeIn().delay(2000).fadeOut();
                  });
              }
          });
      });
  </script>

</asp:Content>
