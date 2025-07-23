<%@ Page Async="true" Title="Submit Result" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="SubmitResult.aspx.cs" Inherits="INTFYP.SubmitResult" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Submit Result
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <section class="text-center bg-light py-4 border rounded mb-4">
        <div class="container">
            <h1 class="display-5 fw-bold">Submit Exam Results</h1>
            <p class="lead text-muted">Enter your subjects, grades, and upload a copy of your result slip.</p>
        </div>
    </section>

    <div class="container">
        <div class="card p-4">
            <asp:Label ID="lblSuccess" runat="server" CssClass="alert alert-success d-none" />
            <asp:Panel ID="PanelSubjects" runat="server">
                <%-- 15 subject-grade pairs --%>
                <asp:Repeater ID="RepeaterSubjects" runat="server">
                    <ItemTemplate>
                        <div class="mb-3 row">
                            <div class="col-md-6">
                                <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" placeholder='<%# "Subject " + (Container.ItemIndex + 1) %>'></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <asp:TextBox ID="txtGrade" runat="server" CssClass="form-control" placeholder='<%# "Grade " + (Container.ItemIndex + 1) %>'></asp:TextBox>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <!-- Image Upload -->
            <div class="mb-3">
                <asp:FileUpload ID="fileUploadResultImage" runat="server" CssClass="form-control" />
            </div>

            <!-- Submit Button -->
            <div class="text-end">
                <asp:Button ID="btnSubmitResult" runat="server" CssClass="btn btn-primary" Text="Submit Result" OnClick="btnSubmitResult_Click" />
            </div>
        </div>
    </div>
</asp:Content>
