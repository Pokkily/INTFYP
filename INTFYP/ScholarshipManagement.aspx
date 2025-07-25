﻿<%@ Page Async="true" Title="Scholarship Management" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="ScholarshipManagement.aspx.cs" Inherits="YourProjectNamespace.ScholarshipManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TeacherMainContent" runat="server">

    <h4 class="mb-3">Submitted Student Results</h4>

    <!-- Result Cards -->
    <asp:Repeater ID="rptResults" runat="server">
        <ItemTemplate>
            <div class="card mb-3 shadow-sm">
                <div class="row g-0">
                    <div class="col-md-4">
                        <!-- Clickable image triggers modal -->
                        <img src='<%# Eval("[ResultImageUrl]") %>' 
                             class="img-fluid rounded-start zoom-effect" 
                             alt="Result Image" 
                             style="cursor:pointer; height:100%; object-fit:cover;" 
                             data-bs-toggle="modal" 
                             data-bs-target='<%# "#imageModal" + Eval("[DocId]") %>' />
                    </div>
                    <div class="col-md-8">
                        <div class="card-body">
                            <h5 class="card-title"><%# Eval("[Username]") %></h5>
                            <p class="card-text mb-1"><strong>Email:</strong> <%# Eval("[Email]") %></p>
                            <asp:Literal ID="litSubjects" runat="server" Text='<%# Eval("[SubjectsHtml]") %>' />
                            <p class="card-text">
                                <strong>Status:</strong> 
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

            <!-- Modal for enlarged image -->
            <div class="modal fade" id='<%# "imageModal" + Eval("[DocId]") %>' tabindex="-1" aria-labelledby="modalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Full Result Image</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body text-center">
                            <img src='<%# Eval("[ResultImageUrl]") %>' class="img-fluid" style="max-height:80vh;" />
                        </div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <style>
        .zoom-effect {
            transition: transform 0.3s ease;
        }

        .zoom-effect:hover {
            transform: scale(1.03);
        }
    </style>
</asp:Content>
