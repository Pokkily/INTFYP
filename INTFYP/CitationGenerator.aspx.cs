using System;


public partial class CitationGenerator : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
        }
    }

    protected string GenerateCitation(string style, string sourceType)
    {
        switch (sourceType.ToLower())
        {
            case "book":
                return GenerateBookCitation(style);
            case "website":
                return GenerateWebsiteCitation(style);
            default:
                return "Citation style not implemented yet.";
        }
    }

    private string GenerateBookCitation(string style)
    {
        string author = Request.Form["author"] ?? "Unknown Author";
        string title = Request.Form["title"] ?? "Untitled";
        string year = Request.Form["year"] ?? "n.d.";
        string publisher = Request.Form["publisher"] ?? "Unknown Publisher";

        switch (style.ToLower())
        {
            case "apa":
                return $"{author}. ({year}). <em>{title}</em>. {publisher}.";
            case "mla":
                return $"{author}. <em>{title}</em>. {publisher}, {year}.";
            case "chicago":
                return $"{author}. {year}. <em>{title}</em>. {publisher}.";
            default:
                return "Citation style not recognized.";
        }
    }

    private string GenerateWebsiteCitation(string style)
    {
        string author = Request.Form["author"] ?? "Unknown Author";
        string title = Request.Form["title"] ?? "Untitled";
        string website = Request.Form["website"] ?? "Unknown Website";
        string date = Request.Form["date"] ?? "n.d.";
        string url = Request.Form["url"] ?? "#";

        switch (style.ToLower())
        {
            case "apa":
                return $"{author}. ({date}). {title}. <em>{website}</em>. {url}";
            case "mla":
                return $"{author}. \"{title}.\" <em>{website}</em>, {date}, {url}.";
            case "chicago":
                return $"{author}. \"{title}.\" <em>{website}</em>. {date}. {url}.";
            default:
                return "Citation style not recognized.";
        }
    }
}