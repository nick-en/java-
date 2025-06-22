<%@ page contentType="text/html; charset=UTF-8" language="java" import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ page pageEncoding="UTF-8" %>

<%
    try {
        // 資料庫連線資訊
        String dbURL = "jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sql = "SELECT * FROM 違規使用者 WHERE DATE(違規時間) = CURDATE() ORDER BY 違規時間 DESC";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);

        if (rs.isBeforeFirst()) {
%>
        <table class="table table-bordered table-sm">
            <thead class="table-light">
                <tr>
                    <th>車牌號碼</th>
                    <th>違規次數</th>
                    <th>違規時間</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
<%
            while (rs.next()) {
                String plate = rs.getString("車牌號碼");
                int times = rs.getInt("違規次數");
                Timestamp time = rs.getTimestamp("違規時間");
                int id = rs.getInt("編號");
                String formattedDate = new SimpleDateFormat("yyyy/MM/dd").format(time);
%>
                <tr>
                    <td><%= plate %></td>
                    <td><%= times %></td>
                    <td><%= formattedDate %></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary edit-btn" data-id="<%= id %>" data-plate="<%= plate %>">✏️</button>
                        <button class="btn btn-sm btn-outline-danger delete-btn" data-id="<%= id %>">🗑️</button>
                    </td>
                </tr>
<%
            }
%>
            </tbody>
        </table>
<%
        } else {
%>
        <div class="text-muted">✅ 今日尚未新增違規資料</div>
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
