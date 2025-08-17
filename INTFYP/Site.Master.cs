using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;

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
                SetActiveMenu(lnkLearning, "language.aspx", currentPage);
                SetActiveMenu(lnkScholarship, "scholarship.aspx", currentPage);
                SetActiveMenu(lnkFeedback, "feedback.aspx", currentPage);
                SetActiveMenu(lnkManage, "createclassroom.aspx", currentPage);
                SetActiveMenu(lnkChatbot, "chatbot.aspx", currentPage);

                // Show teacher menu if user is a teacher
                if (Session["position"]?.ToString() == "Teacher")
                {
                    phTeacherMenu.Visible = true;
                }

                // Check if user is logged in
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
                link.CssClass = "menu-link mainpage";
            }
            else
            {
                link.CssClass = "menu-link";
            }
        }

        protected string GetPageClass(string page)
        {
            string currentPage = System.IO.Path.GetFileName(Request.Path);
            return string.Equals(currentPage, page, StringComparison.OrdinalIgnoreCase) ? "mainpage" : "";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                // Clear all session variables
                Session.Clear();
                
                // Remove the session cookie
                Session.Abandon();
                
                // Clear any authentication cookies if you're using Forms Authentication
                if (Request.Cookies[FormsAuthentication.FormsCookieName] != null)
                {
                    HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
                    authCookie.Expires = DateTime.Now.AddYears(-1);
                    Response.Cookies.Add(authCookie);
                }
                
                // Clear any other custom cookies if needed
                foreach (string cookieName in Request.Cookies.AllKeys)
                {
                    if (cookieName.StartsWith("YourApp_")) // Replace with your app's cookie prefix if any
                    {
                        HttpCookie cookie = new HttpCookie(cookieName, "");
                        cookie.Expires = DateTime.Now.AddYears(-1);
                        Response.Cookies.Add(cookie);
                    }
                }

                // Sign out from Forms Authentication (if you're using it)
                FormsAuthentication.SignOut();
                
                // Add cache control headers to prevent back button issues
                Response.Cache.SetCacheability(HttpCacheability.NoCache);
                Response.Cache.SetExpires(DateTime.UtcNow.AddHours(-1));
                Response.Cache.SetNoStore();
                
                // Redirect to login page
                Response.Redirect("Login.aspx", true);
            }
            catch (Exception ex)
            {
                // Log the error (you might want to implement proper logging)
                System.Diagnostics.Debug.WriteLine($"Logout error: {ex.Message}");
                
                // Even if there's an error, still try to redirect to login
                Response.Redirect("Login.aspx", true);
            }
        }

        /// <summary>
        /// Alternative logout method that can be called from other pages
        /// </summary>
        public static void LogoutUser()
        {
            HttpContext context = HttpContext.Current;
            
            if (context != null)
            {
                // Clear session
                context.Session.Clear();
                context.Session.Abandon();
                
                // Clear authentication
                FormsAuthentication.SignOut();
                
                // Clear cookies
                if (context.Request.Cookies[FormsAuthentication.FormsCookieName] != null)
                {
                    HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
                    authCookie.Expires = DateTime.Now.AddYears(-1);
                    context.Response.Cookies.Add(authCookie);
                }
                
                // Add cache control headers
                context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                context.Response.Cache.SetExpires(DateTime.UtcNow.AddHours(-1));
                context.Response.Cache.SetNoStore();
            }
        }

        /// <summary>
        /// Check if user is authenticated (helper method)
        /// </summary>
        /// <returns></returns>
        public static bool IsUserAuthenticated()
        {
            HttpContext context = HttpContext.Current;
            return context != null && 
                   context.Session != null && 
                   context.Session["username"] != null && 
                   !string.IsNullOrEmpty(context.Session["username"].ToString());
        }

        /// <summary>
        /// Get current username (helper method)
        /// </summary>
        /// <returns></returns>
        public static string GetCurrentUsername()
        {
            HttpContext context = HttpContext.Current;
            if (context != null && context.Session != null && context.Session["username"] != null)
            {
                return context.Session["username"].ToString();
            }
            return string.Empty;
        }

        /// <summary>
        /// Get current user position (helper method)
        /// </summary>
        /// <returns></returns>
        public static string GetCurrentUserPosition()
        {
            HttpContext context = HttpContext.Current;
            if (context != null && context.Session != null && context.Session["position"] != null)
            {
                return context.Session["position"].ToString();
            }
            return "Student"; // Default to Student
        }
    }
}