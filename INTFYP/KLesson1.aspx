<%@ Page Async="true" Title="Korean Lesson 1" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="KLesson1.aspx.cs" Inherits="KoreanApp.KLesson1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Korean Lesson 1
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-5">
        <!-- Start Screen -->
        <div id="startScreen" runat="server" class="text-center p-5 rounded" style="background-color: black; color: white;">
            <h2 class="mb-4">Ready to Learn Korean?</h2>
            <asp:Button ID="btnStart" runat="server" Text="Start Lesson" CssClass="btn btn-light" OnClick="btnStart_Click" />
        </div>

        <!-- Quiz Panel -->
        <div id="quizPanel" runat="server" visible="false" class="text-center">
            <!-- Media Section -->
            <div class="mb-4">
                <asp:Image ID="imgQuestion" runat="server" CssClass="img-fluid rounded mb-3" Visible="false" />
                <audio id="audioQuestion" runat="server" controls class="mb-3" visible="false">
                    <source id="audioSource" runat="server" src="" type="audio/mp3" />
                    Your browser does not support the audio element.
                </audio>
            </div>

            <!-- Question -->
            <h4 class="mb-3"><asp:Label ID="lblQuestion" runat="server" /></h4>

            <!-- Image Options (for Q1, Q4, Q7) -->
            <div id="imageOptions" runat="server" visible="false" class="d-flex justify-content-center gap-3 mb-3">
                <asp:LinkButton ID="imgOption1" runat="server" OnClick="ImageAnswer_Click">
                    <img id="img1" runat="server" class="img-thumbnail" style="width: 120px;" />
                    <div><asp:Label ID="lblImgText1" runat="server" /></div>
                </asp:LinkButton>
                <asp:LinkButton ID="imgOption2" runat="server" OnClick="ImageAnswer_Click">
                    <img id="img2" runat="server" class="img-thumbnail" style="width: 120px;" />
                    <div><asp:Label ID="lblImgText2" runat="server" /></div>
                </asp:LinkButton>
                <asp:LinkButton ID="imgOption3" runat="server" OnClick="ImageAnswer_Click">
                    <img id="img3" runat="server" class="img-thumbnail" style="width: 120px;" />
                    <div><asp:Label ID="lblImgText3" runat="server" /></div>
                </asp:LinkButton>
            </div>

            <!-- Text Button Options -->
            <div id="textOptions" runat="server" visible="false" class="mb-3">
                <asp:Button ID="btnOption1" runat="server" CssClass="btn btn-outline-primary me-2 mb-2" OnClick="Answer_Click" />
                <asp:Button ID="btnOption2" runat="server" CssClass="btn btn-outline-primary me-2 mb-2" OnClick="Answer_Click" />
                <asp:Button ID="btnOption3" runat="server" CssClass="btn btn-outline-primary mb-2" OnClick="Answer_Click" />
            </div>

            <!-- Feedback -->
            <div class="mt-3">
                <asp:Label ID="lblFeedback" runat="server" CssClass="fw-bold" />
            </div>

            <!-- Next Button -->
            <div class="mt-4">
                <asp:Button ID="btnNext" runat="server" Text="Next Question" CssClass="btn btn-success" OnClick="btnNext_Click" />
            </div>
        </div>
    </div>
    <style>
        .correct-answer {
            background-color: #d4edda !important;
            color: #155724 !important;
            border: 1px solid #c3e6cb;
        }
        .wrong-answer {
            background-color: #f8d7da !important;
            color: #721c24 !important;
            border: 1px solid #f5c6cb;
        }
    </style>
</asp:Content>
