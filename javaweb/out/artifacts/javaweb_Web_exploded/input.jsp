<%--
  Created by IntelliJ IDEA.
  User: Coisini
  Date: 2025/5/20
  Time: 15:36
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>三角形判断 - 输入</title>
</head>
<body>
<h2>请输入三角形的三个边长：</h2>
<form action="result.jsp" method="post">
    边长 A: <input type="text" name="sideA"><br><br>
    边长 B: <input type="text" name="sideB"><br><br>
    边长 C: <input type="text" name="sideC"><br><br>
    <input type="submit" value="判断是否构成三角形">
</form>
</body>
</html>
