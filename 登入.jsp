<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>停車場巡查系統 - 登入</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
        }
        h1 {
            margin-top: 30px;
            font-size: 32px;
            color: #333;
        }
        .container {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 50px;
            flex-wrap: wrap;
        }
        .role-box {
            border: 2px solid black;
            padding: 50px;
            font-size: 24px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
            background-color: white;
            text-align: center;
            width: 180px;
            border-radius: 10px;
            box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.2);
        }
        .role-box:hover {
            background-color: #ddd;
            transform: scale(1.05);
        }
        p a {
            display: inline-block;
            margin-top: 20px;
            font-size: 18px;
            color: #007bff;
            text-decoration: none;
        }
        p a:hover {
            text-decoration: underline;
        }
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
                align-items: center;
            }
            .role-box {
                width: 80%;
                max-width: 250px;
            }
        }
    </style>
    <script>
        function goToLogin(role) {
            if (role === '學生') {
                window.location.href = "學生登入.jsp";
            } else if (role === '教職員') {
                window.location.href = "教職員登入.jsp";
            } else if (role === '巡查人員') {
                window.location.href = "巡查人員登入.jsp";
            }
        }
    </script>
</head>
<body>
    <h1>停車場巡查系統</h1>
    <div class="container">
        <div class="role-box" onclick="goToLogin('學生')">學生</div>
        <div class="role-box" onclick="goToLogin('教職員')">教職員</div>
        <div class="role-box" onclick="goToLogin('巡查人員')">巡查人員</div>
    </div>
    <p><a href="註冊.jsp">未註冊者，可點擊此進行註冊</a></p>
</body>
</html>
