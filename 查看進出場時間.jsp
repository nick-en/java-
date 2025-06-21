<%@ page import="java.sql.*, javax.servlet.*, javax.servlet.http.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    request.setCharacterEncoding("UTF-8");

    if (session == null || session.getAttribute("account") == null || session.getAttribute("identity") == null) {
        response.sendRedirect("教職員登入.html");
        return;
    }

    String account = (String) session.getAttribute("account");
    String identity = (String) session.getAttribute("identity");

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>查看進出場時間</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; }
        table { margin: 20px auto; border-collapse: collapse; width: 60%; }
        th, td { border: 1px solid #ccc; padding: 10px; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .back-button { margin-top: 20px; padding: 10px 20px; background-color: #4CAF50; color: white; border: none; border-radius: 5px; cursor: pointer; }
        .back-button:hover { background-color: #45a049; }
    </style>
</head>
<body>
    <h2>出場時間紀錄</h2>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
            "root", ""
        );

        String sql = "SELECT parking_entries.exit_time " +
                     "FROM parking_entries " +
                     "INNER JOIN `新版使用者` ON parking_entries.license_plate = `新版使用者`.車牌號碼 " +
                     "WHERE `新版使用者`.學號 = ? AND `新版使用者`.身分 = ? " +
                     "ORDER BY parking_entries.exit_time DESC";

        stmt = conn.prepareStatement(sql);
        stmt.setString(1, account);
        stmt.setString(2, identity);
        rs = stmt.executeQuery();

        if (!rs.isBeforeFirst()) {
%>
        <p>目前沒有出場紀錄。</p>
<%
        } else {
%>
        <table>
            <thead>
                <tr>
                    <th>出場時間</th>
                </tr>
            </thead>
            <tbody>
<%
            while (rs.next()) {
%>
                <tr>
                    <td><%= rs.getString("exit_time") %></td>
                </tr>
<%
            } // while
%>
            </tbody>
        </table>
<%
        } // else
    } catch (Exception e) {
%>
    <p style="color:red;">錯誤：<%= e.getMessage() %></p>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
    <form action="<%= ("學生".equals(identity)) ? "學生首頁.jsp" : "教職員首頁.jsp" %>" method="get">
        <button type="submit" class="back-button">返回首頁</button>
    </form>
</body>
</html>
