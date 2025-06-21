<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" contentType="text/html; charset=UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");

    if (session == null || session.getAttribute("account") == null || session.getAttribute("identity") == null || (!"教師".equals(session.getAttribute("identity")) && !"職員".equals(session.getAttribute("identity")))) {
        response.sendRedirect("staffLogin.jsp");
        return;
    }

    String account = (String) session.getAttribute("account");
    String name = "", dept = "", email = "", plate = "";

    if (request.getParameter("logout") != null) {
        session.invalidate();
        response.sendRedirect("staffLogin.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC", "root", "");

        String sql = "SELECT * FROM 新版使用者 WHERE 學號 = ? AND (身分 = '教師' OR 身分 = '職員')";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, account);
        rs = stmt.executeQuery();

        if (rs.next()) {
            name = rs.getString("姓名");
            dept = rs.getString("科別");
            email = rs.getString("信箱");
            plate = rs.getString("車牌號碼");
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
    <title>教職員首頁</title>
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
        <p>職員編號：<%= account %></p>
        <p>科別 / 處室：<%= dept %></p>
        <p>信箱：<%= email %></p>
		<p>車牌號碼：<%= plate %></p>

        <!-- 新增按鈕區 -->
        <div class="button-group">
            <a href="車牌違規巡查.jsp" class="button-link action-button">查看違規紀錄</a>
            <a href="查看進出場時間.jsp" class="button-link action-button">查看進出場時間</a>
            <%
                if (dept != null && dept.trim().equals("總務處")) {
            %>
                <a href="巡查名單.jsp" class="button-link action-button">巡查名單</a>
                <a href="insertuser.jsp" class="button-link action-button">查看已註冊使用者</a>
                <a href="審核.jsp" class="button-link action-button">審核</a>
				<a href="教職員登入.jsp" class="button-link action-button">登出</a>
            <%
                }
            %>
        </div>
    </div>
</body>
</html>
