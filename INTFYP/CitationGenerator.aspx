<%@ Page Title="Citation Generator" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CitationGenerator.aspx.cs" Inherits="CitationGenerator" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Citation Generator
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

  <section class="text-center bg-light py-4 border rounded mb-4">
    <div class="container">
      <h1 class="display-5 fw-bold">Citation Generator</h1>
      <p class="lead text-muted">Create perfect citations in multiple styles</p>
    </div>
  </section>

  <style>
    .form-container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #fff;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0,0,0,0.05);
    }
    .form-group {
      margin-bottom: 20px;
    }
    .form-group label {
      font-weight: bold;
      margin-bottom: 8px;
      display: block;
    }
    .form-group input,
    .form-group textarea {
      width: 100%;
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 5px;
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
      border: 1px solid #ccc;
      cursor: pointer;
      border-radius: 4px;
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
      flex: 1;
      padding: 12px;
      border: none;
      border-radius: 5px;
      font-size: 16px;
      color: white;
    }
    .generate-btn {
      background-color: #2c3e50;
    }
    .copy-btn {
      background-color: #3498db;
    }
    .success-message {
      color: #27ae60;
      margin-top: 10px;
      display: none;
    }
  </style>

  <div class="form-container">
    <div id="citationFields">
      <!-- Book input fields shown by default -->
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
      <button id="generateCitation" type="button" class="generate-btn">Generate</button>
      <button id="copyCitation" type="button" class="copy-btn">Copy</button>
    </div>
    <div id="copySuccess" class="success-message">Citation copied!</div>

    <div class="form-group mt-4">
      <label for="citationOutput">Citation</label>
      <textarea id="citationOutput" readonly></textarea>
    </div>
  </div>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script>
      $(document).ready(function () {
          $('.style-buttons button').click(function () {
              $('.style-buttons button').removeClass('active');
              $(this).addClass('active');
              $('#citationStyle').val($(this).data('style'));
          });

          $('#generateCitation').click(function () {
              const style = $('#citationStyle').val();
              const getValue = (id) => $(`#${id}`).val()?.trim() || '[Not specified]';

              const author = getValue('author');
              const title = getValue('title');
              const year = getValue('year');
              const publisher = getValue('publisher');

              let citation = '';
              if (style === 'apa') citation = `${author}. (${year}). *${title}*. ${publisher}.`;
              if (style === 'mla') citation = `${author}. *${title}*. ${publisher}, ${year}.`;
              if (style === 'chicago') citation = `${author}. ${year}. *${title}*. ${publisher}.`;
              if (style === 'harvard') citation = `${author} (${year}) *${title}*. ${publisher}.`;

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
