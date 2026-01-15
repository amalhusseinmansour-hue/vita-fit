<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="VitaFit - تطبيق اللياقة البدنية المتكامل للنساء. تمارين مخصصة، خطط تغذية، ومتجر للمعدات والمكملات الرياضية.">
    <title>VitaFit - لياقتك تبدأ من هنا</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800;900&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-50: #fdf2f8;
            --primary-100: #fce7f3;
            --primary-200: #fbcfe8;
            --primary-300: #f9a8d4;
            --primary-400: #f472b6;
            --primary-500: #ec4899;
            --primary-600: #db2777;
            --primary-700: #be185d;
            --primary-800: #9d174d;
            --primary-900: #831843;
            --rose-gold: #b76e79;
            --soft-pink: #fdf2f8;
            --cream: #fffbf5;
            --gray-50: #fafafa;
            --gray-100: #f5f5f5;
            --gray-200: #e5e5e5;
            --gray-300: #d4d4d4;
            --gray-400: #a3a3a3;
            --gray-500: #737373;
            --gray-600: #525252;
            --gray-700: #404040;
            --gray-800: #262626;
            --gray-900: #171717;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Tajawal', sans-serif;
            background: var(--cream);
            color: var(--gray-700);
            line-height: 1.7;
            overflow-x: hidden;
        }

        /* Decorative Elements */
        .blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(60px);
            opacity: 0.5;
            z-index: 0;
        }

        /* Header */
        .header {
            background: rgba(255,255,255,0.95);
            backdrop-filter: blur(10px);
            padding: 1rem 2rem;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 100;
            border-bottom: 1px solid rgba(236, 72, 153, 0.1);
        }

        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
        }

        .logo-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--primary-400), var(--primary-600));
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 900;
            font-size: 1.3rem;
            box-shadow: 0 4px 15px rgba(236, 72, 153, 0.3);
        }

        .logo-text {
            font-size: 1.6rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--primary-500), var(--primary-700));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-links {
            display: flex;
            gap: 2.5rem;
            list-style: none;
        }

        .nav-links a {
            text-decoration: none;
            color: var(--gray-600);
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
            position: relative;
        }

        .nav-links a::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 0;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, var(--primary-400), var(--primary-600));
            transition: width 0.3s;
        }

        .nav-links a:hover {
            color: var(--primary-600);
        }

        .nav-links a:hover::after {
            width: 100%;
        }

        /* Hero Section */
        .hero {
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 8rem 2rem 4rem;
            background: linear-gradient(180deg, var(--soft-pink) 0%, var(--cream) 100%);
            position: relative;
            overflow: hidden;
        }

        .hero .blob-1 {
            width: 500px;
            height: 500px;
            background: var(--primary-200);
            top: -100px;
            right: -100px;
        }

        .hero .blob-2 {
            width: 400px;
            height: 400px;
            background: var(--primary-100);
            bottom: -50px;
            left: -100px;
        }

        .hero-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
            position: relative;
            z-index: 1;
        }

        .hero-text {
            position: relative;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: white;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.85rem;
            color: var(--primary-600);
            font-weight: 600;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 10px rgba(236, 72, 153, 0.15);
        }

        .hero-text h1 {
            font-size: 3.2rem;
            font-weight: 900;
            line-height: 1.3;
            margin-bottom: 1.5rem;
            color: var(--gray-800);
        }

        .hero-text h1 span {
            background: linear-gradient(135deg, var(--primary-500), var(--primary-700));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-text p {
            font-size: 1.15rem;
            color: var(--gray-500);
            margin-bottom: 2.5rem;
            max-width: 480px;
            line-height: 1.9;
        }

        .hero-buttons {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-500), var(--primary-600));
            color: white;
            padding: 1rem 2.5rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1rem;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            transition: all 0.3s;
            box-shadow: 0 8px 25px rgba(236, 72, 153, 0.35);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(236, 72, 153, 0.45);
        }

        .btn-secondary {
            background: white;
            color: var(--gray-700);
            padding: 1rem 2.5rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1rem;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            transition: all 0.3s;
            border: 2px solid var(--gray-200);
        }

        .btn-secondary:hover {
            border-color: var(--primary-400);
            color: var(--primary-600);
            background: var(--primary-50);
        }

        .hero-image {
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        }

        .phone-mockup {
            width: 280px;
            height: 570px;
            background: linear-gradient(145deg, #1a1a1a, #2d2d2d);
            border-radius: 45px;
            padding: 12px;
            box-shadow: 0 50px 100px rgba(0,0,0,0.15), 0 0 0 1px rgba(255,255,255,0.1) inset;
            position: relative;
            z-index: 2;
        }

        .phone-screen {
            width: 100%;
            height: 100%;
            background: linear-gradient(180deg, var(--primary-400) 0%, var(--primary-600) 50%, var(--primary-700) 100%);
            border-radius: 36px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: white;
            text-align: center;
            padding: 2rem;
            position: relative;
            overflow: hidden;
        }

        .phone-screen::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
            opacity: 0.5;
        }

        .phone-screen .app-logo {
            width: 90px;
            height: 90px;
            background: rgba(255,255,255,0.2);
            border-radius: 25px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 1.5rem;
            backdrop-filter: blur(10px);
            position: relative;
            z-index: 1;
        }

        .phone-screen h3 {
            font-size: 1.8rem;
            font-weight: 800;
            margin-bottom: 0.5rem;
            position: relative;
            z-index: 1;
        }

        .phone-screen p {
            opacity: 0.9;
            font-size: 0.95rem;
            position: relative;
            z-index: 1;
        }

        .floating-card {
            position: absolute;
            background: white;
            padding: 1rem 1.5rem;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 0.75rem;
            z-index: 3;
        }

        .floating-card-1 {
            top: 80px;
            right: -30px;
        }

        .floating-card-2 {
            bottom: 100px;
            left: -40px;
        }

        .floating-card .icon {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, var(--primary-100), var(--primary-200));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
        }

        .floating-card .text h4 {
            font-size: 0.85rem;
            color: var(--gray-800);
            font-weight: 700;
        }

        .floating-card .text p {
            font-size: 0.75rem;
            color: var(--gray-400);
        }

        /* Features Section */
        .features {
            padding: 7rem 2rem;
            background: white;
            position: relative;
        }

        .section-header {
            text-align: center;
            max-width: 600px;
            margin: 0 auto 4rem;
        }

        .section-tag {
            display: inline-block;
            background: var(--primary-100);
            color: var(--primary-600);
            padding: 0.5rem 1.25rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .section-header h2 {
            font-size: 2.5rem;
            font-weight: 900;
            color: var(--gray-800);
            margin-bottom: 1rem;
        }

        .section-header p {
            color: var(--gray-500);
            font-size: 1.1rem;
        }

        .features-grid {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2rem;
        }

        .feature-card {
            background: var(--gray-50);
            padding: 2.5rem;
            border-radius: 25px;
            transition: all 0.4s;
            border: 2px solid transparent;
            position: relative;
            overflow: hidden;
        }

        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-400), var(--primary-600));
            opacity: 0;
            transition: opacity 0.3s;
        }

        .feature-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 25px 50px rgba(236, 72, 153, 0.15);
            border-color: var(--primary-100);
        }

        .feature-card:hover::before {
            opacity: 1;
        }

        .feature-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, var(--primary-100), var(--primary-200));
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 1.5rem;
        }

        .feature-card h3 {
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--gray-800);
            margin-bottom: 0.75rem;
        }

        .feature-card p {
            color: var(--gray-500);
            line-height: 1.8;
            font-size: 0.95rem;
        }

        /* Why Us Section */
        .why-us {
            padding: 7rem 2rem;
            background: linear-gradient(180deg, var(--soft-pink) 0%, white 100%);
        }

        .why-us-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 5rem;
            align-items: center;
        }

        .why-us-image {
            position: relative;
        }

        .why-us-image .main-image {
            width: 100%;
            height: 500px;
            background: linear-gradient(135deg, var(--primary-200), var(--primary-300));
            border-radius: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 8rem;
        }

        .why-us-text h2 {
            font-size: 2.5rem;
            font-weight: 900;
            color: var(--gray-800);
            margin-bottom: 1.5rem;
        }

        .why-us-text h2 span {
            color: var(--primary-600);
        }

        .why-us-text > p {
            color: var(--gray-500);
            font-size: 1.1rem;
            margin-bottom: 2rem;
            line-height: 1.9;
        }

        .why-list {
            list-style: none;
        }

        .why-list li {
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .why-list .check {
            width: 28px;
            height: 28px;
            background: linear-gradient(135deg, var(--primary-500), var(--primary-600));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 0.9rem;
            flex-shrink: 0;
            margin-top: 2px;
        }

        .why-list .text h4 {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 0.25rem;
        }

        .why-list .text p {
            color: var(--gray-500);
            font-size: 0.9rem;
        }

        /* Products Section */
        .products {
            padding: 7rem 2rem;
            background: white;
        }

        .products-grid {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
        }

        .product-card {
            background: var(--gray-50);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.3s;
            border: 2px solid transparent;
        }

        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.08);
            border-color: var(--primary-200);
        }

        .product-image {
            height: 180px;
            background: linear-gradient(135deg, var(--primary-50), var(--primary-100));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 4rem;
            position: relative;
        }

        .product-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: var(--primary-500);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 50px;
            font-size: 0.7rem;
            font-weight: 700;
        }

        .product-info {
            padding: 1.25rem;
        }

        .product-info h3 {
            font-size: 1rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 0.5rem;
        }

        .product-info .category {
            color: var(--primary-500);
            font-size: 0.8rem;
            font-weight: 600;
            margin-bottom: 0.75rem;
        }

        .product-price {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .price-current {
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--gray-800);
        }

        .price-old {
            font-size: 0.85rem;
            color: var(--gray-400);
            text-decoration: line-through;
        }

        /* Download Section */
        .download {
            padding: 7rem 2rem;
            background: linear-gradient(135deg, var(--primary-500), var(--primary-700));
            position: relative;
            overflow: hidden;
        }

        .download::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
        }

        .download-content {
            max-width: 800px;
            margin: 0 auto;
            text-align: center;
            position: relative;
            z-index: 1;
            color: white;
        }

        .download-content h2 {
            font-size: 2.5rem;
            font-weight: 900;
            margin-bottom: 1rem;
        }

        .download-content p {
            font-size: 1.15rem;
            opacity: 0.9;
            margin-bottom: 2.5rem;
            max-width: 500px;
            margin-left: auto;
            margin-right: auto;
        }

        .download-buttons {
            display: flex;
            justify-content: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .store-btn {
            background: white;
            color: var(--gray-800);
            padding: 1rem 2rem;
            border-radius: 15px;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .store-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        }

        .store-btn .icon {
            font-size: 2rem;
        }

        .store-btn .text {
            text-align: right;
        }

        .store-btn .text small {
            display: block;
            font-size: 0.7rem;
            color: var(--gray-500);
        }

        .store-btn .text span {
            font-size: 1.1rem;
            font-weight: 800;
        }

        /* Footer */
        .footer {
            background: var(--gray-900);
            color: white;
            padding: 5rem 2rem 2rem;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 3rem;
        }

        .footer-brand h3 {
            font-size: 1.8rem;
            font-weight: 900;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, var(--primary-400), var(--primary-500));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .footer-brand p {
            color: var(--gray-400);
            line-height: 1.9;
            font-size: 0.95rem;
        }

        .footer-links h4 {
            font-size: 1rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: white;
        }

        .footer-links ul {
            list-style: none;
        }

        .footer-links li {
            margin-bottom: 0.75rem;
        }

        .footer-links a {
            color: var(--gray-400);
            text-decoration: none;
            transition: all 0.3s;
            font-size: 0.9rem;
        }

        .footer-links a:hover {
            color: var(--primary-400);
            padding-right: 5px;
        }

        .social-links {
            display: flex;
            gap: 1rem;
            margin-top: 1.5rem;
        }

        .social-links a {
            width: 40px;
            height: 40px;
            background: var(--gray-800);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray-400);
            text-decoration: none;
            transition: all 0.3s;
        }

        .social-links a:hover {
            background: var(--primary-600);
            color: white;
        }

        .footer-bottom {
            max-width: 1200px;
            margin: 3rem auto 0;
            padding-top: 2rem;
            border-top: 1px solid var(--gray-800);
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: var(--gray-500);
            font-size: 0.9rem;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .features-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .products-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .why-us-content {
                grid-template-columns: 1fr;
            }

            .why-us-image {
                order: -1;
            }
        }

        @media (max-width: 768px) {
            .hero-content {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .hero-text h1 {
                font-size: 2.2rem;
            }

            .hero-text p {
                margin-left: auto;
                margin-right: auto;
            }

            .hero-buttons {
                justify-content: center;
            }

            .hero-image {
                order: -1;
            }

            .phone-mockup {
                width: 240px;
                height: 480px;
            }

            .floating-card {
                display: none;
            }

            .features-grid {
                grid-template-columns: 1fr;
            }

            .products-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .footer-content {
                grid-template-columns: 1fr 1fr;
            }

            .nav-links {
                display: none;
            }

            .footer-bottom {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
        }

        @media (max-width: 480px) {
            .hero-text h1 {
                font-size: 1.8rem;
            }

            .section-header h2 {
                font-size: 1.8rem;
            }

            .products-grid {
                grid-template-columns: 1fr;
            }

            .footer-content {
                grid-template-columns: 1fr;
            }

            .download-buttons {
                flex-direction: column;
                align-items: center;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="header-content">
            <a href="/" class="logo">
                <div class="logo-icon">VF</div>
                <div class="logo-text">VitaFit</div>
            </a>
            <nav>
                <ul class="nav-links">
                    <li><a href="#features">المميزات</a></li>
                    <li><a href="#why-us">لماذا نحن</a></li>
                    <li><a href="#products">المتجر</a></li>
                    <li><a href="#download">التحميل</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>
        <div class="hero-content">
            <div class="hero-text">
                <div class="hero-badge">
                    <span>✨</span>
                    <span>التطبيق الأول للياقة النسائية</span>
                </div>
                <h1>رحلتك نحو <span>القوة والجمال</span> تبدأ هنا</h1>
                <p>تطبيق VitaFit مصمم خصيصاً للمرأة العربية. تمارين منزلية وفي الجيم، خطط تغذية صحية، ومتجر متكامل للمعدات والمكملات الرياضية.</p>
                <div class="hero-buttons">
                    <a href="#download" class="btn-primary">
                        <span>حمّلي التطبيق</span>
                        <span>←</span>
                    </a>
                    <a href="#features" class="btn-secondary">
                        <span>اكتشفي المميزات</span>
                    </a>
                </div>
            </div>
            <div class="hero-image">
                <div class="floating-card floating-card-1">
                    <div class="icon">🏋️‍♀️</div>
                    <div class="text">
                        <h4>+500 تمرين</h4>
                        <p>تمارين متنوعة</p>
                    </div>
                </div>
                <div class="phone-mockup">
                    <div class="phone-screen">
                        <div class="app-logo">💪</div>
                        <h3>VitaFit</h3>
                        <p>لياقتك تبدأ من هنا</p>
                    </div>
                </div>
                <div class="floating-card floating-card-2">
                    <div class="icon">🥗</div>
                    <div class="text">
                        <h4>خطط غذائية</h4>
                        <p>مخصصة لكِ</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features" id="features">
        <div class="section-header">
            <span class="section-tag">المميزات</span>
            <h2>كل ما تحتاجينه في مكان واحد</h2>
            <p>صُمم التطبيق خصيصاً لتلبية احتياجات المرأة الرياضية</p>
        </div>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">🏠</div>
                <h3>تمارين منزلية</h3>
                <p>تمارين فعّالة يمكنك ممارستها في المنزل بدون معدات، مع فيديوهات توضيحية خطوة بخطوة.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🏋️‍♀️</div>
                <h3>برامج الجيم</h3>
                <p>برامج تدريبية احترافية للجيم مصممة للنساء، مع جداول أسبوعية متكاملة.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🥗</div>
                <h3>خطط التغذية</h3>
                <p>وجبات صحية ولذيذة مع حساب السعرات الحرارية، مناسبة لأهدافك سواء تنحيف أو بناء عضلات.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🛍️</div>
                <h3>متجر المعدات</h3>
                <p>تسوقي أحدث المعدات الرياضية من دمبلز، أحزمة مقاومة، ملابس رياضية وأكثر.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">💊</div>
                <h3>المكملات الغذائية</h3>
                <p>أفضل المكملات الغذائية الآمنة للنساء، بروتين، فيتامينات، ومنتجات الطاقة.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">📊</div>
                <h3>تتبع التقدم</h3>
                <p>سجلي قياساتك وتمارينك وتتبعي تقدمك مع رسوم بيانية ملهمة.</p>
            </div>
        </div>
    </section>

    <!-- Why Us Section -->
    <section class="why-us" id="why-us">
        <div class="why-us-content">
            <div class="why-us-image">
                <div class="main-image">🧘‍♀️</div>
            </div>
            <div class="why-us-text">
                <h2>لماذا <span>VitaFit</span>؟</h2>
                <p>نحن نفهم احتياجات المرأة العربية ونقدم لها تجربة رياضية فريدة تناسب أسلوب حياتها.</p>
                <ul class="why-list">
                    <li>
                        <span class="check">✓</span>
                        <div class="text">
                            <h4>مصمم خصيصاً للمرأة</h4>
                            <p>تمارين وبرامج مصممة لتناسب جسم المرأة وأهدافها</p>
                        </div>
                    </li>
                    <li>
                        <span class="check">✓</span>
                        <div class="text">
                            <h4>خصوصية تامة</h4>
                            <p>بيئة آمنة ومحترمة للخصوصية في جميع المحتوى</p>
                        </div>
                    </li>
                    <li>
                        <span class="check">✓</span>
                        <div class="text">
                            <h4>دعم عربي متكامل</h4>
                            <p>واجهة عربية بالكامل مع دعم فني على مدار الساعة</p>
                        </div>
                    </li>
                    <li>
                        <span class="check">✓</span>
                        <div class="text">
                            <h4>مدربات محترفات</h4>
                            <p>فريق من المدربات المعتمدات لمساعدتك في رحلتك</p>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </section>

    <!-- Products Section -->
    <section class="products" id="products">
        <div class="section-header">
            <span class="section-tag">المتجر</span>
            <h2>منتجاتنا المميزة</h2>
            <p>معدات ومكملات رياضية عالية الجودة</p>
        </div>
        <div class="products-grid">
            <div class="product-card">
                <div class="product-image">
                    <span class="product-badge">الأكثر مبيعاً</span>
                    🥤
                </div>
                <div class="product-info">
                    <p class="category">مكملات غذائية</p>
                    <h3>واي بروتين للنساء</h3>
                    <div class="product-price">
                        <span class="price-current">1,350 ج.م</span>
                        <span class="price-old">1,500 ج.م</span>
                    </div>
                </div>
            </div>
            <div class="product-card">
                <div class="product-image">🏃‍♀️</div>
                <div class="product-info">
                    <p class="category">أحزمة مقاومة</p>
                    <h3>طقم أحزمة مقاومة 5 مستويات</h3>
                    <div class="product-price">
                        <span class="price-current">250 ج.م</span>
                    </div>
                </div>
            </div>
            <div class="product-card">
                <div class="product-image">
                    <span class="product-badge">جديد</span>
                    🧘‍♀️
                </div>
                <div class="product-info">
                    <p class="category">معدات يوجا</p>
                    <h3>ماط يوجا مضادة للانزلاق</h3>
                    <div class="product-price">
                        <span class="price-current">180 ج.م</span>
                    </div>
                </div>
            </div>
            <div class="product-card">
                <div class="product-image">🏋️‍♀️</div>
                <div class="product-info">
                    <p class="category">دمبلز</p>
                    <h3>طقم دمبلز مطاطي 2-10 كيلو</h3>
                    <div class="product-price">
                        <span class="price-current">850 ج.م</span>
                        <span class="price-old">1,000 ج.م</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Download Section -->
    <section class="download" id="download">
        <div class="download-content">
            <h2>ابدئي رحلتك اليوم</h2>
            <p>حمّلي التطبيق مجاناً وانضمي لآلاف النساء اللواتي غيّرن حياتهن مع VitaFit</p>
            <div class="download-buttons">
                <a href="#" class="store-btn">
                    <span class="icon">📱</span>
                    <div class="text">
                        <small>تحميل من</small>
                        <span>Google Play</span>
                    </div>
                </a>
                <a href="#" class="store-btn">
                    <span class="icon">⬇️</span>
                    <div class="text">
                        <small>تحميل مباشر</small>
                        <span>ملف APK</span>
                    </div>
                </a>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="footer-content">
            <div class="footer-brand">
                <h3>VitaFit</h3>
                <p>تطبيق اللياقة البدنية المتكامل للمرأة العربية. نساعدك على تحقيق أهدافك الصحية وبناء نمط حياة صحي ومستدام في بيئة آمنة ومحترمة.</p>
                <div class="social-links">
                    <a href="#">📘</a>
                    <a href="#">📸</a>
                    <a href="#">🐦</a>
                    <a href="#">📺</a>
                </div>
            </div>
            <div class="footer-links">
                <h4>التطبيق</h4>
                <ul>
                    <li><a href="#features">المميزات</a></li>
                    <li><a href="#products">المتجر</a></li>
                    <li><a href="#download">تحميل التطبيق</a></li>
                    <li><a href="#">الاشتراكات</a></li>
                </ul>
            </div>
            <div class="footer-links">
                <h4>الدعم</h4>
                <ul>
                    <li><a href="#">الأسئلة الشائعة</a></li>
                    <li><a href="#">اتصلي بنا</a></li>
                    <li><a href="#">سياسة الخصوصية</a></li>
                    <li><a href="#">الشروط والأحكام</a></li>
                </ul>
            </div>
            <div class="footer-links">
                <h4>تواصلي معنا</h4>
                <ul>
                    <li><a href="#">📧 info@vitafit.online</a></li>
                    <li><a href="#">📱 +20 123 456 7890</a></li>
                    <li><a href="#">💬 واتساب</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>© 2024 VitaFit. جميع الحقوق محفوظة</p>
            <p>صُنع بـ 💗 للمرأة العربية</p>
        </div>
    </footer>
</body>
</html>
