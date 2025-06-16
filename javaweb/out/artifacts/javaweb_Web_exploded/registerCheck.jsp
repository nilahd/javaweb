<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String dbURL = "jdbc:mysql://localhost:3306/user_db?useSSL=false&serverTimezone=UTC";
    String dbUser = "root";
    String dbPassword = "123";

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // 检查用户名是否已存在
        String checkSql = "SELECT id FROM users WHERE username = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, username);
        rs = pstmt.executeQuery();

        if (rs.next()) {
%>
<script>
    alert("用户名已存在，请选择其他用户名！");
    window.location.href = "register.jsp";
</script>
<%
} else {
    // 插入新用户
    String insertSql = "INSERT INTO users (username, password, created_at) VALUES (?, ?, CURRENT_TIMESTAMP)";
    pstmt = conn.prepareStatement(insertSql);
    pstmt.setString(1, username);
    pstmt.setString(2, password);

    int rowsInserted = pstmt.executeUpdate();

    if (rowsInserted > 0) {
%>
<script>
    alert("注册成功，请登录！");
    window.location.href = "login.jsp";
</script>
<%
} else {
%>
<script>
    alert("注册失败，请重试！");
    window.location.href = "register.jsp";
</script>
<%
        }
    }
} catch (Exception e) {
    e.printStackTrace();
%>
<script>
    alert("系统错误，请稍后再试！");
    window.location.href = "register.jsp";
</script>
<%
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>