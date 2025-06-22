<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="javax.servlet.*" %>
<%
    String account = (String) session.getAttribute("account");
    if (account == null) {
        response.sendRedirect("教職員登入.html");
        return;
    }

    String message = null;
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("add") != null) {
        String name = request.getParameter("name");
        String student_id = request.getParameter("student_id");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String id_number = request.getParameter("id_number");
        String department = request.getParameter("department");
        String identity = "巡查人員";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/你的資料庫", "帳號", "密碼");
            PreparedStatement stmt = conn.prepareStatement("INSERT INTO 新版使用者 (姓名, 學號, 信箱, 電話, 身分證, 科別, 身分) VALUES (?, ?, ?, ?, ?, ?, ?)");
            stmt.setString(1, name);
            stmt.setString(2, student_id);
            stmt.setString(3, email);
            stmt.setString(4, phone);
            stmt.setString(5, id_number);
            stmt.setString(6, department);
            stmt.setString(7, identity);
            stmt.executeUpdate();
            stmt.close();
            conn.close();
            response.sendRedirect("新增巡查人員.jsp?success=1");
            return;
        } catch (Exception e) {
            message = "❌ 新增失敗：" + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>新增巡查人員</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 30px;
            background-color: #f9f9f9;
        }
        h2 {
            text-align: center;
            color: #333;
        }
        .form-container {
            width: 60%;
            margin: 30px auto;
            background-color: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 0 8px rgba(0,0,0,0.1);
        }
        input {
            width: 100%;
            padding: 10px;
            margin: 12px 0;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 16px;
        }
        .form-button {
            width: 100%;
            padding: 12px;
            background-color: #007BFF;
            color: white;
            font-size: 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
        }
        .form-button:hover {
            background-color: #0056b3;
        }
        .back-button {
            display: inline-block;
            margin-top: 15px;
            text-decoration: none;
            color: white;
            background-color: #555;
            padding: 10px 20px;
            border-radius: 6px;
        }
        .back-button:hover {
            background-color: #333;
        }
        .success {
            text-align: center;
            color: green;
            margin-top: 10px;
        }
        .error {
            text-align: center;
            color: red;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <h2>新增巡查人員</h2>

    <% if (request.getParameter("success") != null) { %>
        <div class="success">✅ 成功新增巡查人員！</div>
    <% } else if (message != null) { %>
        <div class="error"><%= message %></div>
    <% } %>

    <div class="form-container">
        <form method="post">
            <input type="text" name="name" placeholder="姓名" required>
            <input type="text" name="student_id" placeholder="學號" required>
            <input type="email" name="email" placeholder="信箱" required>
            <input type="text" name="phone" placeholder="電話" required>
            <input type="text" name="id_number" placeholder="身份證" required>
            <input type="text" name="department" placeholder="科別 / 處室" required>
            <input type="text" value="巡查人員" disabled>
            <input type="hidden" name="identity" value="巡查人員">
            <button type="submit" name="add" class="form-button">新增</button>
        </form>
        <a href="巡查名單.jsp" class="back-button">返回巡查名單</a>
    </div>
</body>
</html>
