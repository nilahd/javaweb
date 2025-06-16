package com.servlets;

import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.model.ChatMessage;
import com.util.DBUtil;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {
    private static final String API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";
    private static final String API_KEY = "sk-27827af9a7904362b15b58d86e7b0ef1";
    private static final Logger logger = Logger.getLogger(ChatServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String username = req.getParameter("username");
        if (username == null) {
            username = (String)req.getSession().getAttribute("user");
        }

        if (username == null || username.trim().isEmpty()) {
            res.sendRedirect("login.jsp");
            return;
        }

        req.setAttribute("username", username);
        List<ChatMessage> chatHistory = getChatHistory(username);
        req.setAttribute("chatHistory", chatHistory);
        req.getRequestDispatcher("/index.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        if (username == null) {
            username = (String)req.getSession().getAttribute("user");
        }

        if (username == null || username.trim().isEmpty()) {
            res.sendRedirect("login.jsp");
            return;
        }

        req.setAttribute("username", username);
        String question = req.getParameter("question");

        if (question == null || question.trim().isEmpty()) {
            req.setAttribute("error", "请输入有效的问题内容。");
            req.getRequestDispatcher("/index.jsp").forward(req, res);
            return;
        }

        try {
            logger.info("开始处理用户 " + username + " 的问题: " + question);

            // 获取或创建对话
            int conversationId = getOrCreateConversation(username);
            logger.info("获取到对话ID: " + conversationId);

            // 保存用户问题
            saveMessage(conversationId, "user", question, username);
            logger.info("保存用户问题成功");

            // 获取AI回答
            String answer = getAIResponse(question);
            logger.info("获取AI回答成功: " + answer);

            // 保存AI回答
            saveMessage(conversationId, "ai", answer, "AI");
            logger.info("保存AI回答成功");

            // 获取更新后的聊天历史
            List<ChatMessage> chatHistory = getChatHistory(username);
            req.setAttribute("chatHistory", chatHistory);
            logger.info("获取聊天历史成功，共 " + chatHistory.size() + " 条记录");

        } catch (Exception e) {
            logger.severe("处理请求时发生错误: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "处理请求时发生错误，请重试。");
        }

        req.getRequestDispatcher("/index.jsp").forward(req, res);
    }

    private int getOrCreateConversation(String username) {
        String sql = "SELECT c.id FROM conversations c " +
                "JOIN users u ON c.user_id = u.id " +
                "WHERE u.username = ? " +
                "ORDER BY c.created_at DESC LIMIT 1";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("id");
            }

            // 如果没有现有对话，创建新对话
            String insertSql = "INSERT INTO conversations (user_id) " +
                    "SELECT id FROM users WHERE username = ?";
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                insertStmt.setString(1, username);
                int affectedRows = insertStmt.executeUpdate();

                if (affectedRows == 0) {
                    throw new SQLException("创建对话失败，没有插入任何行");
                }

                ResultSet generatedKeys = insertStmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("创建对话失败，没有获取到生成的ID");
                }
            }
        } catch (SQLException e) {
            logger.severe("获取或创建对话失败: " + e.getMessage());
            throw new RuntimeException("获取或创建对话失败", e);
        }
    }

    private void saveMessage(int conversationId, String senderType, String content, String username) {
        String sql = "INSERT INTO messages (conversation_id, sender_type, content, timestamp) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, conversationId);
            pstmt.setString(2, senderType);
            pstmt.setString(3, content);
            // 使用当前时间，并确保时区正确
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Shanghai"));
            pstmt.setTimestamp(4, Timestamp.valueOf(now));

            int affectedRows = pstmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("保存消息失败，没有插入任何行");
            }

        } catch (SQLException e) {
            logger.severe("保存消息失败: " + e.getMessage());
            throw new RuntimeException("保存消息失败", e);
        }
    }

    private List<ChatMessage> getChatHistory(String username) {
        List<ChatMessage> history = new ArrayList<>();
        String sql = "SELECT m.*, " +
                "CASE WHEN m.sender_type = 'user' THEN u.username ELSE 'AI' END as display_name " +
                "FROM messages m " +
                "JOIN conversations c ON m.conversation_id = c.id " +
                "JOIN users u ON c.user_id = u.id " +
                "WHERE u.username = ? " +
                "ORDER BY m.timestamp ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                ChatMessage msg = new ChatMessage();
                msg.setId(rs.getInt("id"));
                msg.setConversationId(rs.getInt("conversation_id"));
                msg.setSenderType(rs.getString("sender_type"));
                msg.setContent(rs.getString("content"));
                // 从数据库读取时间戳并转换为本地时间
                Timestamp timestamp = rs.getTimestamp("timestamp");
                if (timestamp != null) {
                    msg.setTimestamp(timestamp.toLocalDateTime());
                }
                msg.setUsername(rs.getString("display_name"));
                history.add(msg);
            }
        } catch (SQLException e) {
            logger.severe("获取聊天历史失败: " + e.getMessage());
            throw new RuntimeException("获取聊天历史失败", e);
        }

        return history;
    }

    private String getAIResponse(String question) throws IOException {
        // 构造请求体
        JSONObject userMessage = new JSONObject();
        userMessage.put("role", "user");
        userMessage.put("content", question);

        JSONArray messages = new JSONArray();
        messages.add(userMessage);

        JSONObject requestBody = new JSONObject();
        requestBody.put("model", "qwen-plus");
        requestBody.put("messages", messages);

        String jsonBody = requestBody.toJSONString();

        // 发送请求
        HttpURLConnection conn = (HttpURLConnection) new URL(API_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization", "Bearer " + API_KEY);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        int responseCode = conn.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_OK) {
            throw new IOException("API请求失败，响应码：" + responseCode);
        }

        // 读取响应
        StringBuilder response = new StringBuilder();
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
        }

        // 解析JSON
        JSONObject jsonResponse = JSONObject.parseObject(response.toString());
        JSONArray choices = jsonResponse.getJSONArray("choices");

        if (choices != null && !choices.isEmpty()) {
            return choices.getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content");
        } else {
            throw new IOException("无法获取AI回答");
        }
    }
}