<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>用户注册</title>
    <link rel="stylesheet" href="static/css/register.css">
</head>
<body>
<div class="register-container">
    <h2>用户注册</h2>
    <form action="registerCheck.jsp" method="post">
        <div class="form-group">
            <label for="username">用户名：</label>
            <input type="text" id="username" name="username" required>
        </div>
        <div class="form-group">
            <label for="password">密码：</label>
            <input type="password" id="password" name="password" required>
        </div>
        <button type="submit">注册</button>
    </form>
    <div class="login-link">
        <a href="login.jsp">已有账号？去登录</a>
    </div>
</div>

<script src="static/js/register.js"></script>
</body>
</html>