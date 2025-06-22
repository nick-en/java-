<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
String 狀態訊息 = (String) session.getAttribute("status_message");
if (狀態訊息 != null) {
    session.removeAttribute("status_message");
}
%>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
  <meta charset="UTF-8">
  <title>車牌違規巡查</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { background-color: #f0f2f5; font-family: "Microsoft JhengHei"; padding-top: 50px; }
    .container { max-width: 1200px; }
    .title { font-weight: bold; margin-bottom: 30px; }
    .table-container { margin-top: 40px; }
    .footer { text-align: center; font-size: 0.9em; color: #888; margin-top: 60px; }
  </style>
</head>
<body>
<div class="container">
  <h2 class="title text-center text-primary">🚗 車牌違規巡查</h2>

  <% if (狀態訊息 != null && !狀態訊息.isEmpty()) { %>
    <div class="alert alert-info text-center"><%= 狀態訊息 %></div>
  <% } %>

  <form action="檢查違規.jsp" method="post" class="card p-4 shadow-sm mb-4" id="form">
    <input type="hidden" name="mode" id="mode" value="insert">
    <input type="hidden" name="record_id" id="record_id" value="">
    <div class="mb-3">
      <label for="plate" class="form-label">請輸入車牌號碼：</label>
      <input type="text" class="form-control" id="plate" name="plate" list="plateList"
             placeholder="例如：ABC-1234" required
             pattern="[A-Z]{3}-\d{4}"
             title="格式需為3碼英文+1個'-'+4碼數字，例如：ABC-1234">
      <datalist id="plateList"></datalist>
    </div>
    <div class="d-grid gap-2 mt-2">
      <button type="submit" class="btn btn-danger w-100" id="submitBtn">🚨 送出檢查</button>
    </div>
  </form>

  <form action="批次判斷.jsp" method="post" enctype="multipart/form-data" class="card p-4 shadow-sm mb-4">
    <div class="mb-3">
      <label for="file" class="form-label">📂 批次上傳車牌（CSV 或 TXT）</label>
      <input type="file" name="file" id="file" accept=".csv,.txt" class="form-control" required>
    </div>
    <button type="submit" class="btn btn-success">📥 上傳並判斷</button>
  </form>

  <div class="row">
    <div class="col-md-6">
      <div class="card p-3 shadow-sm">
        <h5 class="text-secondary mb-3">📋 今日新增違規車輛</h5>
        <div id="today-list">載入中...</div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="card p-3 shadow-sm">
        <h5 class="text-secondary mb-3">📋 全部違規使用者清單</h5>
        <div id="violator-list">載入中...</div>
      </div>
    </div>
  </div>

  <div class="footer">© 2025 車牌違規巡查系統</div>
</div>

<script>
function 載入違規清單() {
  fetch('顯示違規使用者.jsp')
    .then(res => res.text())
    .then(html => document.getElementById('violator-list').innerHTML = html);
}
function 載入今日違規清單() {
  fetch('顯示今日違規.jsp')
    .then(res => res.text())
    .then(html => {
      document.getElementById('today-list').innerHTML = html;

      document.querySelectorAll(".edit-btn").forEach(btn => {
        btn.addEventListener("click", () => {
          const plate = btn.getAttribute("data-plate");
          const id = btn.getAttribute("data-id");
          document.getElementById("plate").value = plate;
          document.getElementById("record_id").value = id;
          document.getElementById("mode").value = "edit";
          document.getElementById("submitBtn").innerText = "✏️ 修改資料";
        });
      });

      document.querySelectorAll(".delete-btn").forEach(btn => {
        btn.addEventListener("click", () => {
          const id = btn.getAttribute("data-id");
          if (!confirm("確定要刪除這筆違規資料嗎？")) return;
          document.getElementById("mode").value = "delete";
          document.getElementById("record_id").value = id;
          document.getElementById("form").submit();
        });
      });
    });
}

// 🔍 車牌輸入自動完成（已修正）
const plateInput = document.getElementById("plate");
plateInput.addEventListener("input", function () {
  this.value = this.value.toUpperCase();
  const keyword = this.value;
  if (!keyword) return;

  fetch('車牌建議.jsp?key=' + encodeURIComponent(keyword))
    .then(res => res.json())
    .then(data => {
      const list = document.getElementById("plateList");
      list.innerHTML = "";
      data.forEach(item => {
        const opt = document.createElement("option");
        opt.value = item;
        list.appendChild(opt);
      });
    });
});

載入違規清單();
載入今日違規清單();

function 刪除資料() {
  const recordId = document.getElementById("record_id").value;
  if (!recordId) {
    alert("⚠️ 請先使用表單選取要刪除的資料");
    return;
  }
  if (!confirm("確定要刪除這筆違規資料嗎？")) return;
  document.getElementById("mode").value = "delete";
  document.getElementById("form").submit();
}

document.getElementById("form").addEventListener("submit", function () {
  setTimeout(() => {
    document.getElementById("plate").value = "";
    document.getElementById("mode").value = "insert";
    document.getElementById("record_id").value = "";
    document.getElementById("submitBtn").innerText = "🚨 送出檢查";
    載入違規清單();
    載入今日違規清單();
  }, 300);
});
</script>
</body>
</html>
