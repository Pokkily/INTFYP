using System;

namespace YourProjectNamespace
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Optional logic here
        }

        protected string GetPageClass(string page)
        {
            string currentPage = System.IO.Path.GetFileName(Request.Path);
            return string.Equals(currentPage, page, StringComparison.OrdinalIgnoreCase) ? "mainpage" : "";
        }
    }
}
