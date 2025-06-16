<%--
  Created by IntelliJ IDEA.
  User: Coisini
  Date: 2025/5/20
  Time: 15:36
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="triangle" class="com.example.Triangle" scope="page"/>
<jsp:setProperty name="triangle" property="sideA" param="sideA"/>
<jsp:setProperty name="triangle" property="sideB" param="sideB"/>
<jsp:setProperty name="triangle" property="sideC" param="sideC"/>

<html>
<head>
    <title>三角形判断结果</title>
</head>
<body>
<a>边长为：${triangle.sideA}、${triangle.sideB}、${triangle.sideC} ${triangle.result}</a>
</body>
</html>
