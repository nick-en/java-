<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    String message = "";

    List<Map<String, String>> userList = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC", "root", "");

        String sql = "SELECT * FROM 帳戶註冊";
        stmt = conn.prepareStatement(sql);
        rs = stmt.executeQuery();

        ResultSetMetaData meta = rs.getMetaData();
        while (rs.next()) {
            Map<String, String> row = new LinkedHashMap<>();
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                String col = meta.getColumnName(i);
                row.put(col, rs.getString(col) != null ? rs.getString(col) : "無");
            }
            userList.add(row);
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
    <title>審核申請</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; text-align: center; }
        .container { width: 90%; margin: auto; padding: 20px; background: white; box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.2); border-radius: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 10px; text-align: center; border-bottom: 1px solid #ddd; }
        th { background-color: #f4f4f4; }
        button { padding: 8px 12px; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; }
        .approve { background: green; color: white; }
        .reject { background: red; color: white; margin-left: 5px; }
        .batch-actions { margin-top: 20px; }
        .back-button { margin-top: 20px; background-color: #555; color: white; padding: 10px 15px; border-radius: 5px; border: none; cursor: pointer; }
    </style>
    <script>
        let selectedUsers = [];

        function toggleSelection(userId) {
            if (selectedUsers.includes(userId)) {
                selectedUsers = selectedUsers.filter(id => id !== userId);
            } else {
                selectedUsers.push(userId);
            }
        }

        function approveUsers() {
            if (selectedUsers.length === 0) {
                alert("請選擇至少一個用戶！");
                return;
            }
            alert("✅ 已同意使用者：\n" + selectedUsers.join("\n"));
        }

        function rejectUsers() {
            if (selectedUsers.length === 0) {
                alert("請選擇至少一個用戶！");
                return;
            }
            let reasons = selectedUsers.map(userId => prompt(`請輸入 ${userId} 的拒絕原因（可留空）：`) || "");
            alert("❌ 已拒絕使用者：\n" + selectedUsers.map((id, i) => id + (reasons[i] ? "（原因：" + reasons[i] + "）" : "")).join("\n"));
        }
    </script>
</head>
<body>
    <div class="container">
        <h2>審核申請</h2>
        <% if (!message.isEmpty()) { %>
            <p style="color:red;"><%= message %></p>
        <% } %>
        <table>
            <thead>
                <tr>
                    <th>選擇</th>
                    <th>學號 / 職員編號</th>
                    <th>身分</th>
                    <th>學部</th>
                    <th>科別 / 處室</th>
                    <th>學制</th>
                    <th>姓名</th>
                    <th>電話</th>
                    <th>信箱</th>
                    <th>身分證</th>
                    <th>車牌號碼</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, String> user : userList) { %>
                    <tr>
                        <td><input type="checkbox" onchange="toggleSelection('<%= user.get("學號") %>')"></td>
                        <td><%= user.get("學號") %></td>
                        <td><%= user.get("身分") %></td>
                        <td><%= user.get("學部") %></td>
                        <td><%= user.get("科別") %></td>
                        <td><%= user.get("學制") %></td>
                        <td><%= user.get("姓名") %></td>
                        <td><%= user.get("電話") %></td>
                        <td><%= user.get("信箱") %></td>
                        <td><%= user.get("身分證") %></td>
                        <td><%= user.get("車牌號碼") %></td>
                       
                        <td>
                            <button class="approve" onclick="alert('✅ 同意使用者：<%= user.get("學號") %>')">同意</button>
                            <button class="reject" onclick="let r = prompt('請輸入拒絕理由（可留空）：'); alert('❌ 拒絕使用者：<%= user.get("學號") %>\n原因：' + (r || '無'))">拒絕</button>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
        <div class="batch-actions">
            <button class="approve" onclick="approveUsers()">批量同意</button>
            <button class="reject" onclick="rejectUsers()">批量拒絕</button>
        </div>
        <div>
            <button class="back-button" onclick="history.back()">返回</button>
        </div>
    </div>
</body>
</html>
