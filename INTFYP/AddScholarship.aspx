<%@ Page Async="true" Title="Add Scholarship" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeFile="AddScholarship.aspx.cs" Inherits="INTFYP.AddScholarship" %>

<asp:Content ID="AddScholarshipContent" ContentPlaceHolderID="TeacherMainContent" runat="server">

    <style>
        .form-section {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            margin-bottom: 24px;
            border: 1px solid #e0e0e0;
        }

        .form-header {
            color: #212121;
            font-weight: 600;
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .form-label {
            font-weight: 500;
            color: #424242;
            font-size: 14px;
            margin-bottom: 6px;
        }

        .form-control {
            border-radius: 4px;
            border: 1px solid #e0e0e0;
            padding: 12px 14px;
            font-size: 15px;
        }

        .form-control:focus {
            border-color: #9e9e9e;
            box-shadow: none;
        }

        .btn {
            border-radius: 4px;
            font-weight: 500;
            font-size: 14px;
            padding: 10px 20px;
        }

        .btn-dark {
            background-color: #212121;
            border-color: #212121;
            color: #ffffff;
        }

        .btn-dark:hover {
            background-color: #000000;
            border-color: #000000;
        }
        
        /* Scholarship List Styles */
        .scholarship-card {
            transition: transform 0.2s ease;
            margin-bottom: 20px;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            overflow: hidden;
        }
        
        .scholarship-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        
        .scholarship-header {
            background-color: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .scholarship-body {
            padding: 20px;
        }
        
        .scholarship-title {
            font-weight: 600;
            font-size: 18px;
            margin-bottom: 10px;
        }
        
        .scholarship-section {
            margin-bottom: 15px;
        }
        
        .section-title {
            font-weight: 500;
            color: #424242;
            margin-bottom: 5px;
            font-size: 14px;
        }
        
        .section-content {
            color: #616161;
            font-size: 14px;
            white-space: pre-line;
        }
        
        .edit-section {
            background-color: #f8f9fa;
            border-radius: 6px;
            padding: 20px;
            margin-top: 15px;
        }
        
        .action-buttons .btn {
            margin-right: 8px;
        }
        
        .no-scholarships {
            text-align: center;
            padding: 40px 20px;
            color: #757575;
        }
    </style>

    <!-- Add Scholarship Form -->
    <div class="form-section">
        <h3 class="form-header">📚 Add New Scholarship</h3>

        <asp:Label ID="lblStatus" runat="server" Text="" ForeColor="Green" />

        <div class="row g-3">
            <div class="col-md-12">
                <label class="form-label">📌 Title</label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="Enter scholarship title" />
            </div>

            <div class="col-md-12">
                <label class="form-label">📄 Requirement</label>
                <asp:TextBox ID="txtRequirement" runat="server" TextMode="MultiLine" Rows="8" CssClass="form-control" placeholder="Enter requirements" />
            </div>

            <div class="col-md-12">
                <label class="form-label">📜 Terms & Conditions</label>
                <asp:TextBox ID="txtTerms" runat="server" TextMode="MultiLine" Rows="8" CssClass="form-control" placeholder="Enter terms & conditions" />
            </div>

            <div class="col-md-12">
                <label class="form-label">🎓 Study Courses</label>
                <asp:TextBox ID="txtCourses" runat="server" TextMode="MultiLine" Rows="6" CssClass="form-control" placeholder="List of eligible study courses" />
            </div>

            <div class="col-md-12">
                <label class="form-label">🔗 Scholarship Link</label>
                <asp:TextBox ID="txtLink" runat="server" CssClass="form-control" placeholder="Paste the scholarship website URL" />
            </div>
        </div>

        <div class="d-flex justify-content-end mt-4">
            <asp:Button ID="btnSubmit" runat="server" Text="Save Scholarship" CssClass="btn btn-dark" OnClick="btnSubmit_Click" />
        </div>
    </div>

    <!-- Scholarship List Section -->
    <div class="form-section">
        <h3 class="form-header">📋 Your Scholarships</h3>
        <asp:Label ID="lblListStatus" runat="server" Text="" ForeColor="Green" />
        
        <asp:Repeater ID="rptScholarships" runat="server" OnItemCommand="rptScholarships_ItemCommand">
            <ItemTemplate>
                <div class="scholarship-card">
                    <div class="scholarship-header">
                        <h4 class="scholarship-title"><%# Eval("Title") %></h4>
                        <button class="btn btn-sm btn-outline-primary" type="button" 
                                data-bs-toggle="collapse" 
                                data-bs-target="#scholarship<%# Container.ItemIndex %>" 
                                aria-expanded="false" 
                                aria-controls="scholarship<%# Container.ItemIndex %>">
                            Manage
                        </button>
                    </div>
                    
                    <div class="scholarship-body">
                        <div class="scholarship-section">
                            <div class="section-title">Requirements:</div>
                            <div class="section-content"><%# Eval("Requirement") %></div>
                        </div>
                        
                        <div class="scholarship-section">
                            <div class="section-title">Eligible Courses:</div>
                            <div class="section-content"><%# Eval("Courses") %></div>
                        </div>
                        
                        <div class="scholarship-section">
                            <div class="section-title">Website:</div>
                            <div class="section-content">
                                <a href='<%# Eval("Link") %>' target="_blank"><%# Eval("Link") %></a>
                            </div>
                        </div>
                        
                        <div class="collapse" id="scholarship<%# Container.ItemIndex %>">
                            <div class="edit-section">
                                <h5>Edit Scholarship</h5>
                                <div class="row g-3">
                                    <div class="col-md-12">
                                        <label class="form-label">Title</label>
                                        <asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control" 
                                                   Text='<%# Eval("Title") %>' />
                                    </div>
                                    
                                    <div class="col-md-12">
                                        <label class="form-label">Requirements</label>
                                        <asp:TextBox ID="txtEditRequirement" runat="server" TextMode="MultiLine" Rows="6" 
                                                   CssClass="form-control" Text='<%# Eval("Requirement") %>' />
                                    </div>
                                    
                                    <div class="col-md-12">
                                        <label class="form-label">Terms & Conditions</label>
                                        <asp:TextBox ID="txtEditTerms" runat="server" TextMode="MultiLine" Rows="6" 
                                                   CssClass="form-control" Text='<%# Eval("Terms") %>' />
                                    </div>
                                    
                                    <div class="col-md-12">
                                        <label class="form-label">Eligible Courses</label>
                                        <asp:TextBox ID="txtEditCourses" runat="server" TextMode="MultiLine" Rows="4" 
                                                   CssClass="form-control" Text='<%# Eval("Courses") %>' />
                                    </div>
                                    
                                    <div class="col-md-12">
                                        <label class="form-label">Website Link</label>
                                        <asp:TextBox ID="txtEditLink" runat="server" CssClass="form-control" 
                                                   Text='<%# Eval("Link") %>' />
                                    </div>
                                </div>
                                
                                <div class="action-buttons mt-3">
                                    <asp:LinkButton ID="btnUpdate" runat="server" 
                                                  CssClass="btn btn-success btn-sm" 
                                                  CommandName="Update" 
                                                  CommandArgument='<%# Eval("Id") %>'
                                                  OnClientClick="return confirm('Update this scholarship?');">
                                        💾 Update
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnDelete" runat="server" 
                                                  CssClass="btn btn-danger btn-sm" 
                                                  CommandName="Delete" 
                                                  CommandArgument='<%# Eval("Id") %>'
                                                  OnClientClick="return confirm('Are you sure you want to delete this scholarship?');">
                                        🗑️ Delete
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
        
        <asp:Panel ID="pnlNoScholarships" runat="server" Visible="false" CssClass="no-scholarships">
            <i class="fas fa-graduation-cap fa-3x mb-3"></i>
            <p>No scholarships found. Add your first scholarship above!</p>
        </asp:Panel>
    </div>
</asp:Content>