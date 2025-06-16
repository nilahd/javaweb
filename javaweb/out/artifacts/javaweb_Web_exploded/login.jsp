<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>登录</title>
    <link rel="stylesheet" href="static/css/login.css">
</head>
<body>
<div class="login-container">
    <h2>用户登录</h2>
    <form action="login" method="post">
        <div class="form-group">
            <label for="username">用户名：</label>
            <input type="text" id="username" name="username" required>
        </div>
        <div class="form-group">
            <label for="password">密码：</label>
            <input type="password" id="password" name="password" required>
        </div>
        <button type="submit">登录</button>
        <%
            String error = (String)request.getAttribute("error");
            if (error != null) {
        %>
        <div class="error-message"><%= error %></div>
        <%
            }
        %>
    </form>
    <div class="register-link">
        <a href="register.jsp">没有账号？立即注册</a>
    </div>
</div>

<script src="static/js/login.js"></script>
</body>
</html>