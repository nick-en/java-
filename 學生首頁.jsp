<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" contentType="text/html; charset=UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");

    if (session == null || session.getAttribute("account") == null || session.getAttribute("identity") == null || !"學生".equals(session.getAttribute("identity"))) {
        response.sendRedirect("student_login.jsp");
        return;
    }

    String account = (String) session.getAttribute("account");
    String name = "", dept = "", program = "", email = "";

    if (request.getParameter("logout") != null) {
        session.invalidate();
        response.sendRedirect("student_login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC", "root", "");

        String sql = "SELECT * FROM `新版使用者` WHERE 學號 = ? AND 身分 = '學生'";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, account);
        rs = stmt.executeQuery();

        if (rs.next()) {
            name = rs.getString("姓名");
            dept = rs.getString("科別");
            program = rs.getString("學制");
            email = rs.getString("信箱");
        }
    } catch (Exception e) {
%>
    <p style="color:red">資料庫錯誤：<%= e.getMessage() %></p>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>學生首頁</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; }
        .container { margin-top: 50px; }
        button, a.button-link {
            padding: 10px 20px;
            margin-top: 20px;
            font-size: 16px;
            cursor: pointer;
            text-decoration: none;
            border: none;
            border-radius: 5px;
            display: inline-block;
        }
        .logout {
            background-color: red;
            color: white;
        }
        .logout:hover {
            background-color: darkred;
        }
        .action-button {
            background-color: #007BFF;
            color: white;
        }
        .action-button:hover {
            background-color: #0056b3;
        }
        .button-group {
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>歡迎, <%= name %>！</h2>
        <p>學號：<%= account %></p>
        <p>科別：<%= dept %></p>
        <p>學制：<%= program %></p>
        <p>信箱：<%= email %></p>

        <!-- 新增功能按鈕 -->
        <div>
            <form action="車牌違規巡查.jsp" method="get" style="display:inline;">
                <button type="submit" class="action-button">查看違規紀錄</button>
            </form>
            <form action="查看進出場時間.jsp" method="get" style="display:inline;">
                <button type="submit" class="action-button">查看進出場時間</button>
            </form>
            <!-- ✅ 新增「登出」按鈕 -->
            <form action="學生登入.jsp" method="get" style="display:inline;">
                <button type="submit" class="action-button">登出</button>
            </form>
        </div>
    </div>
</body>
</html>
