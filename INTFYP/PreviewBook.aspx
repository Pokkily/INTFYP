<%@ Page Title="Book Preview" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="PreviewBook.aspx.cs" Inherits="INTFYP.PreviewBook" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Book Preview
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        
        .library-page {
            padding: 40px 20px;
            font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        .library-page::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(120, 119, 198, 0.2) 0%, transparent 50%);
            animation: backgroundFloat 20s ease-in-out infinite;
            z-index: -1;
        }

        @keyframes backgroundFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            25% { transform: translate(-20px, -20px) rotate(1deg); }
            50% { transform: translate(20px, -10px) rotate(-1deg); }
            75% { transform: translate(-10px, 10px) rotate(0.5deg); }
        }

        .library-container {
            max-width: 1400px;
            margin: 0 auto;
            position: relative;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            animation: slideInFromTop 1s ease-out;
        }

        @keyframes slideInFromTop {
            from { 
                opacity: 0; 
                transform: translateY(-50px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .page-title {
            font-size: clamp(32px, 5vw, 48px);
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 15px;
            text-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            position: relative;
            display: inline-block;
        }

        .page-title::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 4px;
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            border-radius: 2px;
            animation: expandWidth 1.5s ease-out 0.5s both;
        }

        @keyframes expandWidth {
            from { width: 0; }
            to { width: 60px; }
        }

        .page-subtitle {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.8);
            margin: 0;
        }

        .nav-bar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 20px;
            margin-bottom: 30px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            animation: slideInFromLeft 0.8s ease-out 0.2s both;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        @keyframes slideInFromLeft {
            from { 
                opacity: 0; 
                transform: translateX(-50px); 
            }
            to { 
                opacity: 1; 
                transform: translateX(0); 
            }
        }

        .nav-bar::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
            border-radius: 20px 20px 0 0;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        .nav-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .nav-button {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 25px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .nav-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .nav-button:hover::before {
            width: 300px;
            height: 300px;
        }

        .nav-button:hover {
            transform: translateY(-2px);
        }

        .nav-button-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .nav-button-primary:hover {
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        .nav-button-secondary {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .nav-button-secondary:hover {
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
        }

        .nav-button-accent {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
        }

        .nav-button-accent:hover {
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.4);
            background: linear-gradient(135deg, #ee5a52 0%, #ff6b6b 100%);
        }

        .pdf-preview-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 30px;
            border-radius: 25px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.1);
            position: relative;
            overflow: hidden;
            animation: slideInFromBottom 1s ease-out 0.4s both;
            min-height: 600px;
        }

        @keyframes slideInFromBottom {
            from { 
                opacity: 0; 
                transform: translateY(50px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .pdf-preview-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2, #ff6b6b, #4ecdc4);
            background-size: 400% 100%;
            animation: gradientShift 3s ease infinite;
            border-radius: 25px 25px 0 0;
        }

        .pdf-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .pdf-title {
            font-size: 28px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
        }

        .pdf-title::before {
            content: '📖';
            font-size: 32px;
        }

        .pdf-subtitle {
            color: #7f8c8d;
            font-size: 16px;
            margin: 0;
        }

        .pdf-viewer {
            width: 100%;
            min-height: 500px;
            border: 2px solid rgba(103, 126, 234, 0.1);
            border-radius: 15px;
            background: #f8f9fa;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

        .pdf-viewer:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 35px rgba(0, 0, 0, 0.15);
            border-color: #667eea;
        }

        .pdf-viewer iframe,
        .pdf-viewer embed,
        .pdf-viewer object {
            width: 100%;
            height: 600px;
            border: none;
            border-radius: 13px;
        }

        .pdf-loading {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 400px;
            color: #7f8c8d;
        }

        .loading-spinner {
            width: 50px;
            height: 50px;
            border: 4px solid rgba(103, 126, 234, 0.1);
            border-left: 4px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loading-text {
            font-size: 18px;
            font-weight: 500;
            margin-bottom: 10px;
        }

        .loading-subtitle {
            font-size: 14px;
            opacity: 0.7;
        }

        .pdf-error {
            text-align: center;
            padding: 40px;
            color: #e74c3c;
            background: rgba(231, 76, 60, 0.1);
            border-radius: 15px;
            border: 2px solid rgba(231, 76, 60, 0.2);
        }

        .error-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.7;
        }

        .error-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .error-message {
            font-size: 14px;
            opacity: 0.8;
        }

        .pdf-controls {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        .control-button {
            padding: 8px 16px;
            border-radius: 20px;
            border: none;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .control-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .control-button:hover::before {
            width: 200px;
            height: 200px;
        }

        .control-button:hover {
            transform: translateY(-2px);
        }

        .btn-download {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3);
        }

        .btn-download:hover {
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.4);
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
        }

        .btn-fullscreen {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(103, 126, 234, 0.3);
        }

        .btn-fullscreen:hover {
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.4);
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        @media (max-width: 768px) {
            .library-page {
                padding: 20px 15px;
            }

            .pdf-preview-container {
                padding: 20px;
                margin: 0 10px;
            }

            .nav-buttons {
                flex-direction: column;
                align-items: center;
            }

            .nav-button {
                width: 200px;
            }

            .pdf-viewer iframe,
            .pdf-viewer embed,
            .pdf-viewer object {
                height: 400px;
            }

            .pdf-controls {
                flex-direction: column;
                align-items: center;
            }

            .control-button {
                width: 150px;
                justify-content: center;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 28px;
            }

            .pdf-preview-container {
                padding: 15px;
                border-radius: 15px;
            }

            .pdf-title {
                font-size: 24px;
            }

            .pdf-viewer iframe,
            .pdf-viewer embed,
            .pdf-viewer object {
                height: 350px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            * {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
            }
        }

        @media print {
            .nav-bar,
            .pdf-controls,
            .nav-buttons {
                display: none;
            }
            
            .library-page {
                background: none;
                padding: 0;
            }
            
            .pdf-preview-container {
                box-shadow: none;
                border: 1px solid #ccc;
            }
        }
    </style>

    <div class="library-page">
        <div class="library-container">
            <div class="page-header">
                <h2 class="page-title">Book Preview</h2>
                <p class="page-subtitle">Review and Read Your Selected Material</p>
            </div>

            <div class="nav-bar">
                <div class="nav-buttons">
                    <button type="button" class="nav-button nav-button-primary" onclick="history.back();">
                        ← Back to Previous
                    </button>
                    <button type="button" class="nav-button nav-button-secondary" onclick="location.href='Library.aspx';">
                        📚 Library
                    </button>
                    <button type="button" class="nav-button nav-button-accent" onclick="location.href='FavBooks.aspx';">
                        ⭐ Favorites
                    </button>
                </div>
            </div>

            <div class="pdf-preview-container">
                <div class="pdf-header">
                    <h3 class="pdf-title">Document Viewer</h3>
                    <p class="pdf-subtitle">Use the controls below to interact with the document</p>
                </div>

                <div class="pdf-viewer" id="pdfViewer">
                    <asp:Literal ID="litPdfPreview" runat="server" Mode="PassThrough" />
                    
                    <div class="pdf-loading" id="loadingState" style="display: none;">
                        <div class="loading-spinner"></div>
                        <div class="loading-text">Loading Document...</div>
                        <div class="loading-subtitle">Please wait while we prepare your document</div>
                    </div>

                    <div class="pdf-error" id="errorState" style="display: none;">
                        <div class="error-icon">⚠️</div>
                        <div class="error-title">Unable to Load Document</div>
                        <div class="error-message">Please check your internet connection and try again</div>
                    </div>
                </div>

                <div class="pdf-controls">
                    <button type="button" class="control-button btn-download" onclick="downloadPDF();">
                        📥 Download
                    </button>
                    <button type="button" class="control-button btn-fullscreen" onclick="toggleFullscreen();">
                        🔍 Fullscreen
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const pdfViewer = document.getElementById('pdfViewer');
            const loadingState = document.getElementById('loadingState');
            const errorState = document.getElementById('errorState');

            const pdfContent = pdfViewer.querySelector('iframe, embed, object');
            if (pdfContent) {
                pdfContent.onload = function () {
                    loadingState.style.display = 'none';
                };

                pdfContent.onerror = function () {
                    loadingState.style.display = 'none';
                    errorState.style.display = 'block';
                };
            }

            pdfViewer.style.opacity = '0';
            setTimeout(() => {
                pdfViewer.style.transition = 'opacity 0.5s ease';
                pdfViewer.style.opacity = '1';
            }, 100);
        });

        function downloadPDF() {
            const pdfViewer = document.querySelector('#pdfViewer iframe, #pdfViewer embed, #pdfViewer object');
            if (pdfViewer && pdfViewer.src) {
                const link = document.createElement('a');
                link.href = pdfViewer.src;
                link.download = 'document.pdf';
                link.target = '_blank';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            } else {
                alert('Unable to download document. Please try again.');
            }
        }

        function toggleFullscreen() {
            const pdfViewer = document.getElementById('pdfViewer');

            if (!document.fullscreenElement) {
                pdfViewer.requestFullscreen().then(() => {
                    pdfViewer.style.height = '100vh';
                    pdfViewer.style.borderRadius = '0';
                }).catch(err => {
                    console.log('Error attempting to enable fullscreen:', err);
                    alert('Fullscreen not supported by your browser.');
                });
            } else {
                document.exitFullscreen().then(() => {
                    pdfViewer.style.height = '';
                    pdfViewer.style.borderRadius = '15px';
                });
            }
        }

        document.addEventListener('fullscreenchange', function () {
            const pdfViewer = document.getElementById('pdfViewer');
            const fullscreenBtn = document.querySelector('.btn-fullscreen');

            if (document.fullscreenElement) {
                fullscreenBtn.innerHTML = '🔍 Exit Fullscreen';
                pdfViewer.style.height = '100vh';
                pdfViewer.style.borderRadius = '0';
            } else {
                fullscreenBtn.innerHTML = '🔍 Fullscreen';
                pdfViewer.style.height = '';
                pdfViewer.style.borderRadius = '15px';
            }
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'F11' || (e.key === 'f' && e.ctrlKey)) {
                e.preventDefault();
                toggleFullscreen();
            }

            if (e.key === 'd' && e.ctrlKey) {
                e.preventDefault();
                downloadPDF();
            }

            if (e.key === 'Escape' && !document.fullscreenElement) {
                history.back();
            }
        });

        document.querySelectorAll('.nav-button').forEach(button => {
            button.addEventListener('click', function (e) {
                this.style.transform = 'translateY(-2px) scale(0.95)';
                setTimeout(() => {
                    this.style.transform = '';
                }, 150);
            });
        });
    </script>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />

</asp:Content>
