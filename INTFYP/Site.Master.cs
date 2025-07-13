using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class Site : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string currentPage = System.IO.Path.GetFileName(Request.Path).ToLower();

                SetActiveMenu(lnkClass, "class.aspx", currentPage);
                SetActiveMenu(lnkStudyHub, "studyhub.aspx", currentPage);
                SetActiveMenu(lnkLibrary, "library.aspx", currentPage);
                SetActiveMenu(lnkQuiz, "quiz.aspx", currentPage);
                SetActiveMenu(lnkLearning, "learning.aspx", currentPage);
                SetActiveMenu(lnkScholarship, "scholarship.aspx", currentPage);
                SetActiveMenu(lnkFeedback, "feedback.aspx", currentPage);
                SetActiveMenu(lnkManage, "createclassroom.aspx", currentPage);

                if (Session["position"]?.ToString() == "teacher")
                {
                    phTeacherMenu.Visible = true;
                }

                if (Session["username"] != null)
                {
                    lblUsername.InnerText = Session["username"].ToString();
                    phUser.Visible = true;
                    phGuestLabel.Visible = false;
                    phLoggedIn.Visible = true;
                    phGuest.Visible = false;
                }
                else
                {
                    phUser.Visible = false;
                    phGuestLabel.Visible = true;
                    phLoggedIn.Visible = false;
                    phGuest.Visible = true;
                }
            }
        }

        private void SetActiveMenu(HyperLink link, string pageName, string currentPage)
        {
            if (currentPage.Equals(pageName, StringComparison.OrdinalIgnoreCase))
            {
                link.CssClass = "menu-link mainpage"; // add 'mainpage' class
            }
            else
            {
                link.CssClass = "menu-link"; // remove active style if not current
            }
        }


        protected string GetPageClass(string page)
        {
            string currentPage = System.IO.Path.GetFileName(Request.Path);
            return string.Equals(currentPage, page, StringComparison.OrdinalIgnoreCase) ? "mainpage" : "";
        }
    }
}
