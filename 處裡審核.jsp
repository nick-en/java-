<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    request.setCharacterEncoding("UTF-8");
    String[] userIds = request.getParameterValues("user_ids");
    String action = request.getParameter("action");

    if (userIds == null || userIds.length == 0) {
        out.println("<script>alert('請選擇至少一個用戶'); history.back();</script>");
        return;
    }

    String newStatus = "已同意";
    if ("批量拒絕".equals(action)) {
        newStatus = "已拒絕";
    }

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC", "root", "");

        String placeholders = String.join(",", Collections.nCopies(userIds.length, "?"));
        String sql = "UPDATE `新版使用者` SET 審核狀態 = ? WHERE 學號 IN (" + placeholders + ")";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, newStatus);
        for (int i = 0; i < userIds.length; i++) {
            stmt.setString(i + 2, userIds[i]);
        }

        int count = stmt.executeUpdate();
        out.println("<script>alert('成功" + (newStatus.equals("已同意") ? "同意" : "拒絕") + " " + count + " 筆。'); location.href='審核申請.jsp';</script>");
    } catch (Exception e) {
        out.println("<p style='color:red;'>錯誤：" + e.getMessage() + "</p>");
    } finally {
        if (stmt != null) try { stmt.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
