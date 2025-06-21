<%@ page import="java.sql.*, java.util.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");

    String url = "jdbc:mysql://localhost:3306/停車場巡查使用系統?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String dbUser = "root";
    String dbPass = "";

    String[] filterable = {"身分", "學部", "科別", "學制"};
    String[] allFields = {"學號", "身分", "科別", "學制", "姓名", "電話", "信箱", "身分證", "車牌號碼"};

    Map<String, String> filters = new LinkedHashMap<>();
    List<Map<String, String>> dataRows = new ArrayList<>();
    Map<String, List<String>> filterOptions = new HashMap<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, dbUser, dbPass);

        // 處理篩選條件
        List<String> whereClauses = new ArrayList<>();
        for (String field : filterable) {
            String value = request.getParameter(field);
            if (value != null && !value.trim().isEmpty()) {
                filters.put(field, value);
                whereClauses.add("`" + field + "` = ?");
            }
        }

        String whereSql = whereClauses.isEmpty() ? "" : "WHERE " + String.join(" AND ", whereClauses);
        String sql = "SELECT * FROM `新版使用者` " + whereSql;

        PreparedStatement stmt = conn.prepareStatement(sql);
        int index = 1;
        for (String field : filters.keySet()) {
            stmt.setString(index++, filters.get(field));
        }

        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> row = new LinkedHashMap<>();
            for (String field : allFields) {
                row.put(field, rs.getString(field));
            }
            dataRows.add(row);
        }

        // 取得篩選欄位的選項
        for (String field : filterable) {
            List<String> options = new ArrayList<>();
            Statement optStmt = conn.createStatement();
            ResultSet optRs = optStmt.executeQuery("SELECT DISTINCT `" + field + "` FROM `新版使用者` ORDER BY `" + field + "` ASC");
            while (optRs.next()) {
                options.add(optRs.getString(1));
            }
            filterOptions.put(field, options);
            optRs.close();
            optStmt.close();
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>錯誤：" + e.getMessage() + "</p>");
    }
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <title>新版使用者資料查詢</title>
    <style>
        body { font-family: "微軟正黑體", sans-serif; background: #f4f6f9; margin: 0; padding: 30px; }
        h2 { text-align: center; color: #333; }
        table {
            border-collapse: collapse;
            width: 95%;
            margin: 0 auto;
            background-color: #fff;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        th, td {
            padding: 10px 12px;
            text-align: center;
        }
        th {
            background-color: #007bff;
            color: white;
            font-weight: bold;
        }
        tr:nth-child(even) { background-color: #f0f4f8; }
        tr:hover { background-color: #e0ecff; transition: 0.3s; }
        select {
            margin-top: 6px;
            padding: 4px;
            font-size: 14px;
        }
        .no-data {
            text-align: center;
            font-size: 18px;
            color: #888;
        }
        .submit-btn, .back-btn {
            padding: 10px 20px;
            font-size: 14px;
            border: none;
            border-radius: 6px;
            background-color: #007bff;
            color: white;
            transition: background-color 0.3s ease;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            cursor: pointer;
        }
        .submit-btn:hover, .back-btn:hover {
            background-color: #0056b3;
        }
        .button-container {
            width: 100%;
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-top: 30px;
        }
    </style>
</head>
<body>

<h2>📋 已註冊的使用者</h2>

<form method="get" action="">
    <table>
        <tr>
            <% for (String field : allFields) { %>
                <th>
                    <%= field %>
                    <% if (Arrays.asList(filterable).contains(field)) { %>
                        <br>
                        <select name="<%= field %>">
                            <option value="">全部</option>
                            <% for (String option : filterOptions.getOrDefault(field, new ArrayList<>())) { %>
                                <option value="<%= option %>" <%= (option.equals(filters.get(field)) ? "selected" : "") %>>
                                    <%= option %>
                                </option>
                            <% } %>
                        </select>
                    <% } %>
                </th>
            <% } %>
        </tr>
        <% if (!dataRows.isEmpty()) {
            for (Map<String, String> row : dataRows) { %>
                <tr>
                    <% for (String field : allFields) { %>
                        <td><%= row.get(field) == null ? "" : row.get(field) %></td>
                    <% } %>
                </tr>
        <% } } else { %>
            <tr><td colspan="<%= allFields.length %>" class="no-data">查無符合條件的使用者資料。</td></tr>
        <% } %>
    </table>

    <div class="button-container">
        <input class="submit-btn" type="submit" value="重新查詢">
        <button type="button" class="back-btn" onclick="window.history.back();">返回上一頁</button>
    </div>
</form>

</body>
</html>
