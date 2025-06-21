<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    request.setCharacterEncoding("UTF-8");

    if (session.getAttribute("account") == null) {
        response.sendRedirect("teacher_login.jsp");
        return;
    }

    String account = (String) session.getAttribute("account");
    String message = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    List<Map<String, String>> users = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC", 
            "root", ""
        );

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            if (request.getParameter("add") != null) {
                stmt = conn.prepareStatement(
                    "INSERT INTO 新版使用者 (姓名, 學號, 信箱, 科別, 身分) VALUES (?, ?, ?, ?, ?)"
                );
                stmt.setString(1, request.getParameter("name"));
                stmt.setString(2, request.getParameter("student_id"));
                stmt.setString(3, request.getParameter("email"));
                stmt.setString(4, request.getParameter("department"));
                stmt.setString(5, request.getParameter("identity"));
                stmt.executeUpdate();
                response.sendRedirect("巡查名單.jsp");
                return;
            }

            if (request.getParameter("delete") != null) {
                String[] ids = request.getParameter("delete_student_id").split("、");
                String placeholders = String.join(",", Collections.nCopies(ids.length, "?"));
                stmt = conn.prepareStatement("DELETE FROM 新版使用者 WHERE 學號 IN (" + placeholders + ")");
                for (int i = 0; i < ids.length; i++) {
                    stmt.setString(i + 1, ids[i].trim());
                }
                stmt.executeUpdate();
                response.sendRedirect("巡查名單.jsp");
                return;
            }
        }

        stmt = conn.prepareStatement("SELECT * FROM 新版使用者 WHERE 身分 = '巡查人員'");
        rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, String> row = new LinkedHashMap<>();
            ResultSetMetaData meta = rs.getMetaData();
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                String col = meta.getColumnName(i);
                if (!col.equals("學部") && !col.equals("學制") && !col.equals("圖片")) {
                    row.put(col, rs.getString(col));
                }
            }
            users.add(row);
        }

    } catch (Exception e) {
        message = "錯誤：" + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (stmt != null) try { stmt.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <title>巡查名單</title>
    <style>
        body { font-family: Arial; background: #f9f9f9; padding: 30px; }
        h2 { text-align: center; }
        table {
            width: 95%; margin: 30px auto; border-collapse: collapse;
            background: white; box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
        th { background: #007BFF; color: white; }
        tr:nth-child(even) { background: #f2f2f2; }
        .button-container {
            display: flex; justify-content: center; gap: 15px; margin-bottom: 30px;
        }
        .button-container a {
            padding: 12px 25px; border-radius: 8px; font-size: 16px; color: white;
            text-decoration: none;
        }
        .back-button { background: #555; }
        .back-button:hover { background: #333; }
        .add-button { background: #007BFF; }
        .add-button:hover { background: #0056b3; }
        form {
            width: 60%; margin: 20px auto; background: #fff;
            padding: 20px; border-radius: 8px; box-shadow: 0 0 8px rgba(0,0,0,0.1);
        }
        input {
            width: 100%; padding: 10px; margin: 8px 0;
            border: 1px solid #ccc; border-radius: 6px;
        }
        .form-button {
            width: 100%; padding: 12px; background: #dc3545;
            color: white; font-size: 16px; border: none; border-radius: 6px;
        }
        .form-button:hover { background: #a71d2a; }
    </style>
</head>
<body>
    <h2>巡查名單</h2>
    <% if (!message.isEmpty()) { %>
        <p style="color:red; text-align:center;"><%= message %></p>
    <% } %>

    <div class="button-container">
        <a href="新增巡查人員.jsp" class="add-button">新增巡查人員</a>
        <a href="教職員首頁.jsp" class="back-button">返回首頁</a>
    </div>

    <table>
        <tr>
            <% if (!users.isEmpty()) {
                for (String col : users.get(0).keySet()) { %>
                    <th><%= col %></th>
            <% } } %>
        </tr>
        <% for (Map<String, String> row : users) { %>
            <tr>
                <% for (String val : row.values()) { %>
                    <td><%= val %></td>
                <% } %>
            </tr>
        <% } %>
        <% if (users.isEmpty()) { %>
            <tr><td colspan="100%">目前沒有巡查人員資料</td></tr>
        <% } %>
    </table>

    <form method="post" onsubmit="return confirmDelete();">
        <input type="text" name="delete_student_id" id="delete_student_id" placeholder="輸入要刪除的學號，可用「、」分隔多筆" required>
        <button type="submit" name="delete" class="form-button">刪除</button>
    </form>

    <script>
        function confirmDelete() {
            const input = document.getElementById('delete_student_id').value.trim();
            if (!input) return false;
            return confirm(`⚠️ 確定要刪除下列巡查人員？\n\n${input}\n\n此操作無法還原！`);
        }
    </script>
</body>
</html>
