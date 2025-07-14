<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PreviewPdf.aspx.cs" Inherits="INTFYP.PreviewPdf" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <title>Preview PDF</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.11.338/pdf.min.js"></script>
    <style>
        canvas { display: block; margin: 20px auto; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h2 style="text-align:center">Preview PDF (First 10 Pages)</h2>
        <div id="pdf-container"></div>

        <script>
            const urlParams = new URLSearchParams(window.location.search);
            const pdfUrl = urlParams.get('url');

            if (!pdfUrl) {
                document.getElementById("pdf-container").innerText = "No PDF URL provided.";
            } else {
                pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.11.338/pdf.worker.min.js';

                const container = document.getElementById('pdf-container');

                fetch(pdfUrl)
                    .then(resp => resp.blob())
                    .then(blob => blob.arrayBuffer())
                    .then(buffer => pdfjsLib.getDocument({ data: buffer }).promise)
                    .then(pdf => {
                        const pageCount = Math.min(pdf.numPages, 10); // Only render up to 10 pages
                        for (let i = 1; i <= pageCount; i++) {
                            pdf.getPage(i).then(page => {
                                const scale = 1.5;
                                const viewport = page.getViewport({ scale: scale });

                                const canvas = document.createElement("canvas");
                                const context = canvas.getContext("2d");
                                canvas.height = viewport.height;
                                canvas.width = viewport.width;
                                container.appendChild(canvas);

                                const renderContext = {
                                    canvasContext: context,
                                    viewport: viewport
                                };
                                page.render(renderContext);
                            });
                        }
                    });
            }
        </script>
    </form>
</body>
</html>
