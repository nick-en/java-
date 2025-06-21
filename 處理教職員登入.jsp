<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" contentType="text/html; charset=UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    String account = request.getParameter("account");
    String password = request.getParameter("password");

    if (account == null || account.trim().isEmpty() || password == null || password.trim().isEmpty()) {
%>
    <script>
        alert("❌ 帳號或密碼不可為空！");
        window.location.href = "教職員登入.jsp";
    </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
		
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC", "root", "");

        String sql = "SELECT * FROM `新版使用者` WHERE `學號` = ? AND `身分證` = ? AND (`身分` = '教師' OR `身分` = '職員')";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, account.trim());
        stmt.setString(2, password.trim());

        rs = stmt.executeQuery();

        if (rs.next()) {
            session.setAttribute("account", rs.getString("學號"));
            session.setAttribute("identity", rs.getString("身分"));
            session.setAttribute("name", rs.getString("姓名"));
%>
    <script>
        window.location.href = "教職員首頁.jsp";
    </script>
<%
        } else {
%>
    <script>
        alert("❌ 登入失敗，請檢查學號與身分證是否正確！");
        window.location.href = "教職員登入.jsp";
    </script>
<%
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
