using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using Google.Cloud.Firestore;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace YourProjectNamespace
{
    public partial class Site : MasterPage
    {
        private FirestoreDb db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    string currentPage = System.IO.Path.GetFileName(Request.Path).ToLower();

                    // Set active menu items
                    SetActiveMenu(lnkClass, "class.aspx", currentPage);
                    SetActiveMenu(lnkStudyHub, "studyhub.aspx", currentPage);
                    SetActiveMenu(lnkChatRoom, "chatroom.aspx", currentPage);
                    SetActiveMenu(lnkLibrary, "library.aspx", currentPage);
                    SetActiveMenu(lnkQuiz, "quiz.aspx", currentPage);
                    SetActiveMenu(lnkLearning, "language.aspx", currentPage);
                    SetActiveMenu(lnkScholarship, "scholarship.aspx", currentPage);
                    SetActiveMenu(lnkFeedback, "feedback.aspx", currentPage);
                    SetActiveMenu(lnkChatbot, "geminiai.aspx", currentPage);
                    SetActiveMenu(lnkManage, "createclassroom.aspx", currentPage);

                    // Setup profile section with synchronous profile image loading
                    SetupUserProfileWithImageSync();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Site Master Page_Load error: {ex}");
                    // Fallback to basic setup
                    SetupBasicProfile();
                }
            }
        }

        private void SetupUserProfileWithImageSync()
        {
            try
            {
                // Check if user is logged in
                if (Session["username"] != null && Session["userId"] != null)
                {
                    string username = Session["username"].ToString();
                    string userId = Session["userId"].ToString();
                    string userPosition = Session["position"]?.ToString() ?? "Student";

                    // Show logged in user section
                    lblUsername.InnerText = username;
                    phUser.Visible = true;
                    phGuestLabel.Visible = false;
                    phLoggedIn.Visible = true;
                    phGuest.Visible = false;

                    // Set role-specific styling and features
                    SetupRoleBasedFeaturesSync(userPosition.ToLower());

                    // Enable profile link
                    lnkProfile.NavigateUrl = "Profile.aspx";

                    // Load profile image synchronously using Task.Run
                    try
                    {
                        var profileData = Task.Run(async () => await LoadProfileImageDataSync(userId, username)).Result;

                        if (profileData.hasImage && !string.IsNullOrEmpty(profileData.imageUrl))
                        {
                            // Set the profile image directly
                            imgProfileHeader.ImageUrl = profileData.imageUrl;
                            imgProfileHeader.Style["display"] = "block";
                            divProfileIcon.Style["display"] = "none";

                            System.Diagnostics.Debug.WriteLine($"Profile image set: {profileData.imageUrl}");

                            // Add client-side error handling
                            RegisterImageErrorHandling(profileData.initials);
                        }
                        else
                        {
                            // No image available, use initials
                            SetDefaultProfileIcon(username, "", "");
                            if (!string.IsNullOrEmpty(profileData.initials))
                            {
                                divProfileIcon.InnerText = profileData.initials;
                            }
                            System.Diagnostics.Debug.WriteLine($"No image found, using initials: {profileData.initials}");
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error loading profile image: {ex}");
                        SetDefaultProfileIcon(username);
                    }
                }
                else
                {
                    // Guest user
                    SetupGuestProfile();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SetupUserProfileWithImageSync error: {ex}");
                SetupGuestProfile();
            }
        }

        private async Task<(bool hasImage, string imageUrl, string initials)> LoadProfileImageDataSync(string userId, string username)
        {
            try
            {
                // Initialize Firestore
                db = FirestoreDb.Create("intorannetto");

                var userRef = db.Collection("users").Document(userId);
                var userSnap = await userRef.GetSnapshotAsync();

                if (userSnap.Exists)
                {
                    var userData = userSnap.ToDictionary();
                    if (userData != null)
                    {
                        string profileImageUrl = GetSafeValue(userData, "profileImageUrl");
                        string firstName = GetSafeValue(userData, "firstName");
                        string lastName = GetSafeValue(userData, "lastName");
                        string initials = GenerateUserInitials(firstName, lastName, username);

                        System.Diagnostics.Debug.WriteLine($"Firestore data - Image URL: {profileImageUrl}, Initials: {initials}");

                        return (
                            hasImage: !string.IsNullOrEmpty(profileImageUrl),
                            imageUrl: profileImageUrl,
                            initials: initials
                        );
                    }
                }

                System.Diagnostics.Debug.WriteLine("User document not found or empty");
                return (false, "", GenerateUserInitials("", "", username));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadProfileImageDataSync error: {ex}");
                return (false, "", GenerateUserInitials("", "", username));
            }
        }

        private void RegisterImageErrorHandling(string fallbackInitials)
        {
            string errorHandlingScript = $@"
                document.addEventListener('DOMContentLoaded', function() {{
                    var profileImg = document.getElementById('{imgProfileHeader.ClientID}');
                    var profileIcon = document.getElementById('{divProfileIcon.ClientID}');
                    
                    console.log('Setting up profile image error handling');
                    
                    if (profileImg) {{
                        profileImg.onerror = function() {{
                            console.log('Profile image failed to load, showing fallback initials');
                            this.style.display = 'none';
                            if (profileIcon) {{
                                profileIcon.textContent = '{fallbackInitials}';
                                profileIcon.style.display = 'flex';
                            }}
                        }};
                        
                        profileImg.onload = function() {{
                            console.log('Profile image loaded successfully');
                            if (profileIcon) {{
                                profileIcon.style.display = 'none';
                            }}
                        }};
                        
                        // Check if image is already loaded (cached)
                        if (profileImg.complete) {{
                            if (profileImg.naturalWidth > 0) {{
                                console.log('Profile image already loaded from cache');
                                if (profileIcon) {{
                                    profileIcon.style.display = 'none';
                                }}
                            }} else {{
                                console.log('Profile image failed to load from cache');
                                profileImg.style.display = 'none';
                                if (profileIcon) {{
                                    profileIcon.textContent = '{fallbackInitials}';
                                    profileIcon.style.display = 'flex';
                                }}
                            }}
                        }}
                    }}
                }});
            ";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "profileImageErrorHandling", errorHandlingScript, true);
        }

        private void SetDefaultProfileIcon(string username, string firstName = "", string lastName = "")
        {
            string initials = GenerateUserInitials(firstName, lastName, username);

            divProfileIcon.InnerText = initials;
            divProfileIcon.Attributes["class"] = "profile-icon";
            imgProfileHeader.Style["display"] = "none";
            divProfileIcon.Style["display"] = "flex";

            System.Diagnostics.Debug.WriteLine($"Set default profile icon with initials: {initials}");
        }

        private void SetupGuestProfile()
        {
            phUser.Visible = false;
            phGuestLabel.Visible = true;
            phLoggedIn.Visible = false;
            phGuest.Visible = true;

            // Setup guest profile icon
            divProfileIcon.InnerText = "?";
            divProfileIcon.Attributes["class"] = "profile-icon guest-profile-icon";
            imgProfileHeader.Style["display"] = "none";
            divProfileIcon.Style["display"] = "flex";

            // Set guest profile link to login page
            lnkProfile.NavigateUrl = "Login.aspx";
        }

        // Keep the WebMethod for backward compatibility, but it's not actively used now
        [System.Web.Services.WebMethod]
        public static string LoadUserProfileImageAsync()
        {
            try
            {
                var context = HttpContext.Current;
                if (context?.Session?["userId"] == null)
                {
                    return Newtonsoft.Json.JsonConvert.SerializeObject(new { success = false });
                }

                string userId = context.Session["userId"].ToString();
                string username = context.Session["username"]?.ToString() ?? "";

                // Run async operation in a synchronous context
                var task = LoadUserProfileImageDataAsync(userId, username);
                var result = task.GetAwaiter().GetResult();

                return Newtonsoft.Json.JsonConvert.SerializeObject(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserProfileImageAsync error: {ex}");
                return Newtonsoft.Json.JsonConvert.SerializeObject(new { success = false });
            }
        }

        private static async Task<object> LoadUserProfileImageDataAsync(string userId, string username)
        {
            try
            {
                var db = FirestoreDb.Create("intorannetto");
                var userRef = db.Collection("users").Document(userId);
                var userSnap = await userRef.GetSnapshotAsync();

                if (userSnap.Exists)
                {
                    var userData = userSnap.ToDictionary();

                    string profileImageUrl = GetSafeValueStatic(userData, "profileImageUrl");
                    string firstName = GetSafeValueStatic(userData, "firstName");
                    string lastName = GetSafeValueStatic(userData, "lastName");

                    return new
                    {
                        hasImage = !string.IsNullOrEmpty(profileImageUrl),
                        imageUrl = profileImageUrl,
                        initials = GenerateUserInitialsStatic(firstName, lastName, username)
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"LoadUserProfileImageDataAsync error: {ex}");
            }

            return new
            {
                hasImage = false,
                imageUrl = "",
                initials = GenerateUserInitialsStatic("", "", username)
            };
        }

        private void SetupBasicProfile()
        {
            if (Session["username"] != null)
            {
                lblUsername.InnerText = Session["username"].ToString();
                phUser.Visible = true;
                phGuestLabel.Visible = false;
                phLoggedIn.Visible = true;
                phGuest.Visible = false;

                string userPosition = Session["position"]?.ToString() ?? "Student";
                SetupRoleBasedFeaturesSync(userPosition.ToLower());

                // Set default profile icon
                SetDefaultProfileIcon(Session["username"].ToString());
            }
            else
            {
                SetupGuestProfile();
            }
        }

        private void SetupRoleBasedFeaturesSync(string userPosition)
        {
            switch (userPosition)
            {
                case "teacher":
                    SetupTeacherFeaturesSync();
                    break;
                case "admin":
                    SetupAdminFeatures();
                    break;
                case "student":
                default:
                    SetupStudentFeatures();
                    break;
            }
        }

        private void SetupTeacherFeaturesSync()
        {
            // Show teacher-specific menu items
            phTeacherMenu.Visible = true;

            // Add teacher role styling to username
            lblUsername.Attributes["class"] = "title username teacher";

            // Add role badge
            divRoleBadge.InnerText = "Teacher";
            divRoleBadge.Attributes["class"] = "role-badge teacher";
            divRoleBadge.Style["display"] = "block";
        }

        private void SetupAdminFeatures()
        {
            // Show admin-specific menu items
            phAdminMenu.Visible = true;

            // Add admin role styling
            lblUsername.Attributes["class"] = "title username admin";

            // Add role badge
            divRoleBadge.InnerText = "Admin";
            divRoleBadge.Attributes["class"] = "role-badge admin";
            divRoleBadge.Style["display"] = "block";
        }

        private void SetupStudentFeatures()
        {
            // Standard student features
            lblUsername.Attributes["class"] = "title username student";

            // Add role badge
            divRoleBadge.InnerText = "Student";
            divRoleBadge.Attributes["class"] = "role-badge student";
            divRoleBadge.Style["display"] = "block";
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

                // Clear any authentication cookies if using Forms Authentication
                if (Request.Cookies[FormsAuthentication.FormsCookieName] != null)
                {
                    HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
                    authCookie.Expires = DateTime.Now.AddYears(-1);
                    Response.Cookies.Add(authCookie);
                }

                // Clear any other custom cookies
                foreach (string cookieName in Request.Cookies.AllKeys)
                {
                    if (cookieName.StartsWith("YourApp_"))
                    {
                        HttpCookie cookie = new HttpCookie(cookieName, "");
                        cookie.Expires = DateTime.Now.AddYears(-1);
                        Response.Cookies.Add(cookie);
                    }
                }

                // Sign out from Forms Authentication
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
                System.Diagnostics.Debug.WriteLine($"Logout error: {ex.Message}");
                Response.Redirect("Login.aspx", true);
            }
        }

        private string GenerateUserInitials(string firstName, string lastName, string username)
        {
            if (!string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
            {
                return (firstName.Substring(0, 1) + lastName.Substring(0, 1)).ToUpper();
            }
            else if (!string.IsNullOrEmpty(username))
            {
                return username.Length >= 2 ? username.Substring(0, 2).ToUpper() : username.Substring(0, 1).ToUpper();
            }
            return "?";
        }

        private static string GenerateUserInitialsStatic(string firstName, string lastName, string username)
        {
            if (!string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
            {
                return (firstName.Substring(0, 1) + lastName.Substring(0, 1)).ToUpper();
            }
            else if (!string.IsNullOrEmpty(username))
            {
                return username.Length >= 2 ? username.Substring(0, 2).ToUpper() : username.Substring(0, 1).ToUpper();
            }
            return "?";
        }

        // Helper method for safe dictionary access
        private string GetSafeValue(Dictionary<string, object> dictionary, string key, string defaultValue = "")
        {
            if (dictionary == null || !dictionary.ContainsKey(key) || dictionary[key] == null)
            {
                return defaultValue;
            }
            return dictionary[key].ToString();
        }

        private static string GetSafeValueStatic(Dictionary<string, object> dictionary, string key, string defaultValue = "")
        {
            if (dictionary == null || !dictionary.ContainsKey(key) || dictionary[key] == null)
            {
                return defaultValue;
            }
            return dictionary[key].ToString();
        }

        // Static helper methods
        public static void LogoutUser()
        {
            HttpContext context = HttpContext.Current;

            if (context != null)
            {
                context.Session.Clear();
                context.Session.Abandon();
                FormsAuthentication.SignOut();

                if (context.Request.Cookies[FormsAuthentication.FormsCookieName] != null)
                {
                    HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
                    authCookie.Expires = DateTime.Now.AddYears(-1);
                    context.Response.Cookies.Add(authCookie);
                }

                context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                context.Response.Cache.SetExpires(DateTime.UtcNow.AddHours(-1));
                context.Response.Cache.SetNoStore();
            }
        }

        public static bool IsUserAuthenticated()
        {
            HttpContext context = HttpContext.Current;
            return context != null &&
                   context.Session != null &&
                   context.Session["username"] != null &&
                   !string.IsNullOrEmpty(context.Session["username"].ToString());
        }

        public static string GetCurrentUsername()
        {
            HttpContext context = HttpContext.Current;
            if (context != null && context.Session != null && context.Session["username"] != null)
            {
                return context.Session["username"].ToString();
            }
            return string.Empty;
        }

        public static string GetCurrentUserPosition()
        {
            HttpContext context = HttpContext.Current;
            if (context != null && context.Session != null && context.Session["position"] != null)
            {
                return context.Session["position"].ToString();
            }
            return "Student";
        }

        public static string GetCurrentUserId()
        {
            HttpContext context = HttpContext.Current;
            if (context != null && context.Session != null && context.Session["userId"] != null)
            {
                return context.Session["userId"].ToString();
            }
            return string.Empty;
        }

        public static void UpdateUserProfileImageInSession(string imageUrl)
        {
            HttpContext context = HttpContext.Current;
            if (context?.Session != null)
            {
                context.Session["profileImageUrl"] = imageUrl;
            }
        }
    }
}