<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String dbURL = "jdbc:mysql://localhost:3306/user_db?useSSL=false&serverTimezone=UTC";
    String dbUser = "root";
    String dbPassword = "123";

    String username = request.getParameter("username");
    String pwd = request.getParameter("password");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        String sql = "SELECT id, username FROM users WHERE username = ? AND password = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username);
        pstmt.setString(2, pwd);

        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 设置session属性
            session.setAttribute("user", username);
            session.setAttribute("userId", rs.getInt("id"));

            // 更新最后登录时间
            String updateSql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setInt(1, rs.getInt("id"));
                updateStmt.executeUpdate();
            }

            // 重定向到聊天页面
            response.sendRedirect("chat?username=" + java.net.URLEncoder.encode(username, "UTF-8"));
        } else {
%>
<script>
    alert("用户名或密码错误！");
    window.location.href = "login.jsp";
</script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
%>
<script>
    alert("系统错误，请稍后再试！");
    window.location.href = "login.jsp";
</script>
<%
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>