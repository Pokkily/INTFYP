using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;

namespace YourProjectNamespace
{
    public partial class TeacherSite : System.Web.UI.MasterPage
    {
        public class TeacherNavItem
        {
            public string Text { get; set; }
            public string Description { get; set; }
            public string Link { get; set; }
            public string IsActive { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindTeacherNavigation();
            }
        }

        private void BindTeacherNavigation()
        {
            var navItems = new List<TeacherNavItem>
            {
                new TeacherNavItem {
                    Text = "Create Classroom",
                    Description = "Create a new class",
                    Link = "CreateClassroom.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Manage Classroom",
                    Description = "Modify classroom",
                    Link = "ManageClassroom.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Create New Post",
                    Description = "Make new announcement",
                    Link = "CreatePost.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Manage Post",
                    Description = "Modify announcement",
                    Link = "ManagePost.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Create New Quiz",
                    Description = "Publish new quizzes",
                    Link = "CreateQuiz.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "View Quiz Result",
                    Description = "Check result",
                    Link = "~/ViewQuizResult.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Assignment Grouping",
                    Description = "Automated grouping",
                    Link = "~/AssignmentGrouping.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Student Materials",
                    Description = "Library Materials",
                    Link = "AddBook.aspx",
                    IsActive = ""
                },               
                new TeacherNavItem {
                    Text = "Scholarship Post",
                    Description = "All Your Support",
                    Link = "AddScholarship.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Lesson Adding",
                    Description = "All Language You need",
                    Link = "AddLanguage.aspx",
                    IsActive = ""
                },                
                new TeacherNavItem {
                    Text = "Question",
                    Description = "All Language You need",
                    Link = "AddQuestion.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Scholarship",
                    Description = "All Scholarship You need",
                    Link = "ScholarshipManagement.aspx",
                    IsActive = ""
                },
                new TeacherNavItem {
                    Text = "Language Report",
                    Description = "All Report You need",
                    Link = "LanguageReports.aspx",
                    IsActive = ""
                }

            };

            // Set active item
            string currentPage = System.IO.Path.GetFileName(Request.Path).ToLower();
            foreach (var item in navItems)
            {
                string page = System.IO.Path.GetFileName(item.Link).ToLower();
                if (currentPage == page)
                {
                    item.IsActive = "active";
                    break;
                }
            }

            rptTeacherNav.DataSource = navItems;
            rptTeacherNav.DataBind();
        }
    }
}