<%@ Page Async="true" Title="Scholarship Management" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="ScholarshipManagement.aspx.cs" Inherits="YourProjectNamespace.ScholarshipManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TeacherMainContent" runat="server">

        <!-- Result Submissions Header -->
        <h4 class="mb-3">Submitted Student Results</h4>

        <!-- Result Cards -->
        <asp:Repeater ID="rptResults" runat="server">
    <ItemTemplate>
        <div class="card mb-3 shadow-sm">
            <div class="row g-0">
                <div class="col-md-4">
                    <img src='<%# Eval("[ResultImageUrl]") %>' class="img-fluid rounded-start" alt="Result Image" style="height:100%; object-fit:cover;">
                </div>
                <div class="col-md-8">
                    <div class="card-body">
                        <h5 class="card-title"><%# Eval("[Username]") %></h5>
                        <p class="card-text mb-1"><strong>Email:</strong> <%# Eval("[Email]") %></p>
                        <asp:Literal ID="litSubjects" runat="server" Text='<%# Eval("[SubjectsHtml]") %>' />
                        <p class="card-text"><strong>Status:</strong> 
                            <span class='<%# Eval("[Status]").ToString() == "Verified" ? "text-success" : Eval("[Status]").ToString() == "Rejected" ? "text-danger" : "text-warning" %>'>
                                <%# Eval("[Status]") %>
                            </span>
                        </p>
                        <div class="mt-2">
                            <asp:Button ID="btnVerify" runat="server" Text="✔ Verify" CommandName="Verify" CommandArgument='<%# Eval("[DocId]") %>' CssClass="btn btn-success btn-sm me-2" OnCommand="ResultCommand" />
                            <asp:Button ID="btnReject" runat="server" Text="✖ Reject" CommandName="Reject" CommandArgument='<%# Eval("[DocId]") %>' CssClass="btn btn-danger btn-sm" OnCommand="ResultCommand" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>
</asp:Content>
