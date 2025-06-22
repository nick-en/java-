<%@ page contentType="text/html; charset=UTF-8" language="java" import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ page pageEncoding="UTF-8" %>

<%
    // 顯示錯誤訊息
    try {
        String dbURL = "jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sql = "SELECT 車牌號碼, COUNT(*) AS 違規次數, MAX(DATE(違規時間)) AS 最後違規日期 " +
                     "FROM 違規使用者 " +
                     "GROUP BY 車牌號碼 " +
                     "ORDER BY 最後違規日期 DESC";

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);

        if (rs.isBeforeFirst()) {
%>
        <div class="table-responsive">
            <table class="table table-striped table-bordered align-middle text-center">
                <thead class="table-light">
                    <tr><th>車牌號碼</th><th>違規次數</th><th>最後違規日期</th></tr>
                </thead>
                <tbody>
<%
            while (rs.next()) {
                String 車牌號碼 = rs.getString("車牌號碼");
                int 次數 = rs.getInt("違規次數");
                Date 日期 = rs.getDate("最後違規日期");
                String 日期文字 = new SimpleDateFormat("yyyy/MM/dd").format(日期);
%>
                <tr>
                    <td><%= 車牌號碼 %></td>
                    <td><%= 次數 %></td>
                    <td><%= 日期文字 %></td>
                </tr>
<%
            }
%>
                </tbody>
            </table>
        </div>
<%
        } else {
%>
        <div class="text-success">✅ 目前沒有任何違規使用者。</div>
<%
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
%>
        <div class="alert alert-danger">❗ 錯誤：<%= e.getMessage() %></div>
<%
    }
%>
