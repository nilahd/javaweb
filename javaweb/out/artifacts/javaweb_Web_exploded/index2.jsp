<%--
  Created by IntelliJ IDEA.
  User: Coisini
  Date: 2025/4/25
  Time: 11:32
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>计算结果</title>
</head>
<body>
<%
    String num1Str = request.getParameter("num1");
    String num2Str = request.getParameter("num2");
    double num1 = 0;
    double num2 = 0;
    try {
        num1 = Double.parseDouble(num1Str);
        num2 = Double.parseDouble(num2Str);
    } catch (NumberFormatException e) {
        e.printStackTrace();
    }
    double result = num1 + num2;
%>
<form>
    <%= num1 %> + <%= num2 %> =
    <input type="text" value="<%= result %>" readonly />
</form>
</body>
</html>
