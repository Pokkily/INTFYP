using System;
using System.Web;

namespace INTFYP
{
    public partial class PreviewBook : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string pdfUrl = Request.QueryString["pdfUrl"];

                if (!string.IsNullOrWhiteSpace(pdfUrl))
                {
                    string safeUrl = HttpUtility.HtmlEncode(pdfUrl);
                    litPdfPreview.Text = $"<iframe src='{safeUrl}' width='100%' height='700px' frameborder='0'></iframe>";
                }
                else
                {
                    litPdfPreview.Text = "<p class='text-danger'>No PDF URL provided.</p>";
                }
            }
        }
    }
}
