<%@ Page Title="Create Classroom" Language="C#" MasterPageFile="~/TeacherSite.master" 
    AutoEventWireup="true" CodeBehind="CreateClassroom.aspx.cs" 
    Inherits="YourProjectNamespace.CreateClassroom" Async="true" %>


<asp:Content ID="ClassroomContent" ContentPlaceHolderID="TeacherMainContent" runat="server">
    <style>
        .form-section {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .student-list {
            max-height: 200px;
            overflow-y: auto;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            margin-top: 10px;
        }
        .student-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px;
            border-bottom: 1px solid #eee;
        }
        .time-input-group {
            display: flex;
            gap: 10px;
        }
        .time-input-group select {
            width: 80px;
        }
    </style>

    <div class="form-section">
        <h3 class="mb-4">📝 Create a New Classroom</h3>
        
        <div class="row g-3">
            <!-- Class Information -->
            <div class="col-md-6">
                <label class="form-label">Name of Class:</label>
                <asp:TextBox ID="txtClassName" runat="server" CssClass="form-control" 
                    placeholder="e.g., Data Science 101" required="true" />
            </div>
            
            <div class="col-md-6">
                <label class="form-label">Description:</label>
                <asp:TextBox ID="txtClassDescription" runat="server" CssClass="form-control" 
                    placeholder="Short description of the class" TextMode="MultiLine" Rows="2" />
            </div>
            
            <!-- Schedule -->
            <div class="col-md-6">
                <label class="form-label">Class Date:</label>
                <asp:TextBox ID="txtClassDate" runat="server" TextMode="Date" 
                    CssClass="form-control" required="true" />
            </div>
            
            <div class="col-md-3">
                <label class="form-label">Start Time:</label>
                <div class="time-input-group">
                    <asp:TextBox ID="txtStartTime" runat="server" TextMode="Time" 
                        CssClass="form-control" required="true" />
                    <asp:DropDownList ID="ddlStartAmPm" runat="server" CssClass="form-control">
                        <asp:ListItem Text="AM" Value="AM" />
                        <asp:ListItem Text="PM" Value="PM" />
                    </asp:DropDownList>
                </div>
            </div>
            
            <div class="col-md-3">
                <label class="form-label">End Time:</label>
                <div class="time-input-group">
                    <asp:TextBox ID="txtEndTime" runat="server" TextMode="Time" 
                        CssClass="form-control" required="true" />
                    <asp:DropDownList ID="ddlEndAmPm" runat="server" CssClass="form-control">
                        <asp:ListItem Text="AM" Value="AM" />
                        <asp:ListItem Text="PM" Value="PM" />
                    </asp:DropDownList>
                </div>
            </div>
            
            <!-- Venue -->
            <div class="col-md-6">
                <label class="form-label">Venue:</label>
                <asp:TextBox ID="txtVenue" runat="server" CssClass="form-control" 
                    placeholder="e.g., Lab B" required="true" />
            </div>
            
            <!-- Student Invitation -->
            <div class="col-md-6">
                <label class="form-label">Invite Students:</label>
                <div class="input-group mb-3">
                    <asp:TextBox ID="txtStudentEmail" runat="server" CssClass="form-control" 
                        placeholder="student@example.com" TextMode="Email" />
                    <asp:Button ID="btnAddStudent" runat="server" Text="Add" 
                        CssClass="btn btn-outline-primary" OnClick="btnAddStudent_Click" />
                </div>
                <asp:Label ID="lblInviteStatus" runat="server" CssClass="text-muted small" />
                
                <div class="student-list">
                    <asp:Repeater ID="rptStudents" runat="server" OnItemCommand="rptStudents_ItemCommand">
                        <ItemTemplate>
                            <div class="student-item">
                                <span>
                                    <strong><%# Eval("Name") %></strong> (<%# Eval("Email") %>)
                                </span>
                                <asp:LinkButton ID="btnRemove" runat="server" CommandName="Remove" 
                                    CommandArgument='<%# Eval("Email") %>' CssClass="text-danger"
                                    Text="✕" ToolTip="Remove student" />
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Label ID="lblEmpty" runat="server" Visible='<%# rptStudents.Items.Count == 0 %>'
                                Text="No students added yet" CssClass="text-muted" />
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
        
        <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
            <asp:Button ID="btnCreateClass" runat="server" Text="Create Classroom" 
                CssClass="btn btn-primary px-4" OnClick="btnCreateClass_Click" />
        </div>
    </div>
</asp:Content>