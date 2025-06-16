<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>结果显示页面</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 20px;
        }

        h2 {
            text-align: center;
            color: #333;
        }

        table {
            width: 60%;
            border-collapse: collapse;
            margin: 20px auto;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        th, td {
            padding: 15px;
            text-align: center;
            border: 1px solid #ddd;
        }

        tr:hover {
            background-color: #f1f1f1;
        }

        a {
            display: block;
            text-align: center;
            margin-top: 30px;
            color: #007BFF;
            text-decoration: none;
            font-size: 16px;
        }

        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<h2>计算结果如下：</h2>

<table>
    <tr>
        <td>${operand1}</td>
        <td>${operation}</td>
        <td>${operand2}</td>
        <td>${result}</td>
    </tr>
</table>

<a href="index.jsp">返回重新计算</a>

</body>
</html>