<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AddFeedback.aspx.cs" Inherits="INTFYP.AddFeedback" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Social Feedback</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
    <style>
        /* Consistent Header */
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            background-color: #f5f5f5;
        }
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: #fff;
            padding: 10px 30px;
            border-bottom: 1px solid #ddd;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .logo { font-weight: bold; font-size: 24px; }
        nav a { margin: 0 10px; text-decoration: none; color: #333; }
        nav a.active { font-weight: bold; color: #000; border-bottom: 2px solid black; }
        .auth-buttons button { margin-left: 10px; padding: 5px 15px; cursor: pointer; border-radius: 4px; }
        .auth-buttons .register { background-color: black; color: white; border: none; }

        /* Social Feed Styles */
        .social-container {
            max-width: 600px;
            margin: 30px auto;
        }
        .post-box {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            padding: 15px;
        }
        .post-input {
            display: flex;
            margin-bottom: 15px;
        }
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #ddd;
            margin-right: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
        }
        .post-form {
            flex: 1;
        }
        .post-form textarea {
            width: 100%;
            border: none;
            resize: none;
            min-height: 80px;
            padding: 10px;
            font-size: 14px;
            border-bottom: 1px solid #eee;
        }
        .post-actions {
            display: flex;
            justify-content: space-between;
            margin-top: 10px;
        }
        .attachment-options {
            display: flex;
            align-items: center;
        }
        .attachment-options label {
            margin-right: 15px;
            cursor: pointer;
            color: #555;
            font-size: 14px;
            display: flex;
            align-items: center;
        }
        .attachment-options i {
            margin-right: 5px;
        }
        .btn-post {
            background-color: #1a73e8;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .btn-post:hover {
            background-color: #0d5bba;
        }
        .preview-image {
            max-width: 100%;
            max-height: 300px;
            border-radius: 4px;
            margin-top: 10px;
            display: none;
        }
        .status-message {
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
            display: none;
        }
        .success { 
            background-color: #e6f7ee; 
            color: #0a5; 
            display: block !important;
        }
        .error { 
            background-color: #ffebee; 
            color: #c00; 
            display: block !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <header>
            <div class="logo">L.</div>
            <nav>
                <a href="Library.aspx">Library</a>
                <a href="#" class="active">Feedback</a>
                <a href="#">StudyHub</a>
                <a href="#">Quiz</a>
            </nav>
            <div class="auth-buttons">
                <asp:Button ID="btnSignIn" runat="server" Text="Sign in" CssClass="signin" />
                <asp:Button ID="btnRegister" runat="server" Text="Register" CssClass="register" />
            </div>
        </header>

        <main class="social-container">
            <div class="post-box">
                <h2>Create Post</h2>
                <div class="post-input">
                    <div class="user-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="post-form">
                        <asp:TextBox ID="txtPostContent" runat="server" TextMode="MultiLine" 
                            placeholder="What's on your mind?" CssClass="post-content"></asp:TextBox>
                        <asp:Image ID="imgPreview" runat="server" CssClass="preview-image" />
                    </div>
                </div>
                <div class="post-actions">
                    <div class="attachment-options">
                        <label for="fileImage">
                            <i class="fas fa-image"></i> Photo
                            <asp:FileUpload ID="fileImage" runat="server" Style="display: none;" onchange="previewFile()" />
                        </label>
                        <label><i class="fas fa-smile"></i> Feeling</label>
                        <label><i class="fas fa-tag"></i> Tag</label>
                    </div>
                    <asp:Button ID="btnPost" runat="server" Text="Post" CssClass="btn-post" OnClick="btnPost_Click" />
                </div>
                <asp:Label ID="lblStatus" runat="server" CssClass="status-message"></asp:Label>
            </div>
        </main>
    </form>

    <script>
        function previewFile() {
            var preview = document.getElementById('<%= imgPreview.ClientID %>');
            var file = document.getElementById('<%= fileImage.ClientID %>').files[0];
            var reader = new FileReader();

            reader.onloadend = function () {
                preview.src = reader.result;
                preview.style.display = "block";
            }

            if (file) {
                reader.readAsDataURL(file);
            } else {
                preview.style.display = "none";
            }
        }
    </script>
</body>
</html>