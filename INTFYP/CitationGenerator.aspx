<%@ Page Title="Citation Generator" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CitationGenerator.aspx.cs" Inherits="CitationGenerator" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Citation Generator
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
            max-width: 1200px;
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

        .form-container {
            max-width: 700px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 40px;
            border-radius: 25px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.1);
            position: relative;
            overflow: hidden;
            animation: slideInFromBottom 1s ease-out 0.4s both;
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

        .form-container::before {
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

        .form-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .form-title {
            font-size: 28px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .form-title::before {
            content: '📝';
            font-size: 32px;
        }

        .form-subtitle {
            color: #7f8c8d;
            font-size: 16px;
        }

        .form-group {
            margin-bottom: 25px;
            animation: fadeInUp 0.8s ease-out both;
            animation-delay: calc(var(--group-index, 0) * 0.1s + 0.6s);
        }

        @keyframes fadeInUp {
            from { 
                opacity: 0; 
                transform: translateY(20px); 
            }
            to { 
                opacity: 1; 
                transform: translateY(0); 
            }
        }

        .form-group label {
            font-weight: 600;
            margin-bottom: 10px;
            display: block;
            color: #2c3e50;
            font-size: 14px;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid rgba(103, 126, 234, 0.1);
            border-radius: 15px;
            font-size: 14px;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(5px);
        }

        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(103, 126, 234, 0.1);
            background: rgba(255, 255, 255, 1);
            transform: translateY(-2px);
        }

        .form-group textarea {
            min-height: 120px;
            font-family: 'Courier New', monospace;
            resize: vertical;
        }

        .style-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 12px;
            margin-bottom: 25px;
        }

        .style-button {
            padding: 12px 16px;
            background: rgba(255, 255, 255, 0.8);
            border: 2px solid rgba(103, 126, 234, 0.2);
            cursor: pointer;
            border-radius: 15px;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            color: #2c3e50;
        }

        .style-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(103, 126, 234, 0.1);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.6s ease;
        }

        .style-button:hover::before {
            width: 300px;
            height: 300px;
        }

        .style-button:hover {
            transform: translateY(-2px);
            border-color: #667eea;
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.2);
        }

        .style-button.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: #667eea;
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.3);
        }

        .style-button.active:hover {
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            box-shadow: 0 12px 30px rgba(103, 126, 234, 0.4);
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }

        .action-button {
            flex: 1;
            padding: 15px 25px;
            border: none;
            border-radius: 20px;
            font-size: 16px;
            font-weight: 600;
            color: white;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .action-button::before {
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

        .action-button:hover::before {
            width: 400px;
            height: 400px;
        }

        .action-button:hover {
            transform: translateY(-3px);
        }

        .generate-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            box-shadow: 0 8px 25px rgba(103, 126, 234, 0.3);
        }

        .generate-btn:hover {
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
            box-shadow: 0 12px 35px rgba(103, 126, 234, 0.4);
        }

        .copy-btn {
            background: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
            box-shadow: 0 8px 25px rgba(78, 205, 196, 0.3);
        }

        .copy-btn:hover {
            background: linear-gradient(135deg, #44a08d 0%, #4ecdc4 100%);
            box-shadow: 0 12px 35px rgba(78, 205, 196, 0.4);
        }

        .success-message {
            background: linear-gradient(135deg, #2ecc71 0%, #27ae60 100%);
            color: white;
            padding: 12px 20px;
            border-radius: 15px;
            margin-top: 15px;
            text-align: center;
            font-weight: 600;
            display: none;
            animation: successPulse 0.6s ease-out;
            box-shadow: 0 8px 25px rgba(46, 204, 113, 0.3);
        }

        @keyframes successPulse {
            0% { 
                opacity: 0; 
                transform: scale(0.8) translateY(20px); 
            }
            100% { 
                opacity: 1; 
                transform: scale(1) translateY(0); 
            }
        }

        @media (max-width: 768px) {
            .library-page {
                padding: 20px 15px;
            }

            .form-container {
                padding: 25px;
                margin: 0 10px;
            }

            .nav-buttons {
                flex-direction: column;
                align-items: center;
            }

            .nav-button {
                width: 200px;
            }

            .action-buttons {
                flex-direction: column;
            }

            .style-buttons {
                grid-template-columns: 1fr 1fr;
            }
        }

        @media (max-width: 480px) {
            .page-title {
                font-size: 28px;
            }

            .form-container {
                padding: 20px;
                border-radius: 15px;
            }

            .style-buttons {
                grid-template-columns: 1fr;
            }

            .form-title {
                font-size: 24px;
            }
        }

        #citationStyle {
            display: none !important;
        }
    </style>

    <div class="library-page">
        <div class="library-container">
            <div class="page-header">
                <h2 class="page-title">Citation Generator</h2>
                <p class="page-subtitle">Create perfect citations in multiple styles</p>
            </div>

            <div class="nav-bar">
                <div class="nav-buttons">
                    <button type="button" class="nav-button nav-button-primary" onclick="location.href='Library.aspx';">
                        📚 Back to Library
                    </button>
                    <button type="button" class="nav-button nav-button-secondary" onclick="location.href='FavBooks.aspx';">
                        ⭐ Favorite Books
                    </button>
                </div>
            </div>

            <div class="form-container">
                <div class="form-header">
                    <h3 class="form-title">Generate Citation</h3>
                    <p class="form-subtitle">Fill in the book details below</p>
                </div>

                <div id="citationFields">
                    <div class="form-group" style="--group-index: 0;">
                        <label for="author">Author(s)</label>
                        <input type="text" id="author" placeholder="Lastname, F.">
                    </div>
                    <div class="form-group" style="--group-index: 1;">
                        <label for="title">Title</label>
                        <input type="text" id="title" placeholder="Book title">
                    </div>
                    <div class="form-group" style="--group-index: 2;">
                        <label for="year">Year</label>
                        <input type="text" id="year" placeholder="YYYY">
                    </div>
                    <div class="form-group" style="--group-index: 3;">
                        <label for="publisher">Publisher</label>
                        <input type="text" id="publisher" placeholder="Publisher name">
                    </div>
                </div>

                <div class="form-group" style="--group-index: 4;">
                    <label>Citation Style</label>
                    <div class="style-buttons">
                        <button type="button" data-style="apa" class="style-button active">APA</button>
                        <button type="button" data-style="mla" class="style-button">MLA</button>
                        <button type="button" data-style="chicago" class="style-button">Chicago</button>
                        <button type="button" data-style="harvard" class="style-button">Harvard</button>
                    </div>
                    <select id="citationStyle">
                        <option value="apa">APA</option>
                        <option value="mla">MLA</option>
                        <option value="chicago">Chicago</option>
                        <option value="harvard">Harvard</option>
                    </select>
                </div>

                <div class="action-buttons">
                    <button id="generateCitation" type="button" class="action-button generate-btn">✨ Generate Citation</button>
                    <button id="copyCitation" type="button" class="action-button copy-btn">📋 Copy Citation</button>
                </div>

                <div id="copySuccess" class="success-message">✅ Citation copied to clipboard!</div>

                <div class="form-group" style="--group-index: 5;">
                    <label for="citationOutput">Generated Citation</label>
                    <textarea id="citationOutput" readonly placeholder="Your citation will appear here..."></textarea>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            $('.style-button').click(function () {
                $('.style-button').removeClass('active');
                $(this).addClass('active');
                $('#citationStyle').val($(this).data('style'));
            });

            $('#generateCitation').click(function () {
                const style = $('#citationStyle').val();
                const getValue = (id) => $(`#${id}`).val()?.trim() || '[Not specified]';

                const author = getValue('author');
                const title = getValue('title');
                const year = getValue('year');
                const publisher = getValue('publisher');

                let citation = '';
                if (style === 'apa') citation = `${author}. (${year}). *${title}*. ${publisher}.`;
                if (style === 'mla') citation = `${author}. *${title}*. ${publisher}, ${year}.`;
                if (style === 'chicago') citation = `${author}. ${year}. *${title}*. ${publisher}.`;
                if (style === 'harvard') citation = `${author} (${year}) *${title}*. ${publisher}.`;

                $('#citationOutput').val(citation);

                $('#citationOutput').css('transform', 'scale(0.98)');
                setTimeout(() => {
                    $('#citationOutput').css('transform', 'scale(1)');
                }, 200);
            });

            $('#copyCitation').click(function () {
                const citationText = $('#citationOutput').val();
                if (citationText && citationText !== 'Your citation will appear here...') {
                    navigator.clipboard.writeText(citationText).then(() => {
                        $('#copySuccess').fadeIn().delay(3000).fadeOut();
                    });
                } else {
                    alert('Please generate a citation first!');
                }
            });

            $('input, textarea').on('focus', function () {
                $(this).parent().css('transform', 'translateY(-2px)');
            }).on('blur', function () {
                $(this).parent().css('transform', 'translateY(0)');
            });
        });
    </script>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>