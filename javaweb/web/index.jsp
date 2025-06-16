<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.model.ChatMessage" %>
<html>
<head>
    <title>Chatbot</title>
    <link rel="stylesheet" href="static/css/index.css">
</head>
<body>
<%
    String username = (String)request.getAttribute("username");
    if (username == null) {
        username = request.getParameter("username");
    }
    if (username == null) {
        username = (String)session.getAttribute("user");
    }
%>

<div class="chat-container">
    <a href="logout" class="logout-btn">退出登录</a>

    <div class="chat-header">
        <h2>Chatbot - 欢迎, <%= username %></h2>
    </div>

    <div id="chatBox">
        <%
            List<ChatMessage> chatHistory = (List<ChatMessage>) request.getAttribute("chatHistory");
            if (chatHistory != null) {
                for (ChatMessage msg : chatHistory) {
                    boolean isUser = msg.isUser();
        %>
        <div class="message-container <%= isUser ? "user" : "bot" %>">
            <div class="avatar">
                <%= isUser ? msg.getUsername().substring(0,1).toUpperCase() : "AI" %>
            </div>
            <div class="message-content">
                <div class="message-header">
                    <span class="sender-name"><%= msg.getUsername() %></span>
                    <span class="timestamp"><%= msg.getFormattedTime() != null ? msg.getFormattedTime() : "" %></span>
                </div>
                <div class="message-text"><%= msg.getContent() %></div>
            </div>
        </div>
        <%
                }
            }
        %>
    </div>

    <form action="chat" method="post" class="input-container">
        <input type="hidden" name="username" value="<%= username %>" />
        <input type="text" name="question" id="userInput" placeholder="请输入您的问题..." required />
        <button type="submit" id="sendBtn">发送</button>
    </form>
</div>

<script src="static/js/index.js"></script>
</body>
</html>