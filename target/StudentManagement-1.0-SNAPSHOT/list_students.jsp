<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Student List</title>
        <style>
            .message.success::before {
                content: "✓";
                font-weight: bold;
                color: #28a745;
            }
            .message.error::before {
                content: "✗";
                font-weight: bold;
                color: #dc3545;
            }
            .pagination {
                margin-top: 20px;
                text-align: center;
                padding: 20px;
            }
            .pagination a, .pagination strong {
                display: inline-block;
                padding: 8px 12px;
                margin: 0 4px;
                text-decoration: none;
                border: 1px solid #ddd;
                border-radius: 4px;
                color: #007bff;
                background-color: white;
            }
            .pagination a:hover {
                background-color: #f8f9fa;
            }
            .pagination strong {
                background-color: #007bff;
                color: white;
                border-color: #007bff;
            }
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                background-color: #f5f5f5;
            }
            h1 {
                color: #333;
            }
            .message {
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 500;
                animation: slideIn 0.3s ease-out;
                padding: 12px 15px;
                padding: 10px;
                margin-bottom: 20px;
                border-radius: 5px;
            }
            .success {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }
            .error {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }
            .btn {
                display: inline-block;
                padding: 10px 20px;
                margin-bottom: 20px;
                background-color: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 5px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background-color: white;
            }
            th {
                background-color: #007bff;
                color: white;
                padding: 12px;
                text-align: left;
            }
            td {
                padding: 10px;
                border-bottom: 1px solid #ddd;
            }
            tr:hover {
                background-color: #f8f9fa;
            }
            .action-link {
                color: #007bff;
                text-decoration: none;
                margin-right: 10px;
            }
            .delete-link {
                color: #dc3545;
            }
        </style>
    </head>
    <body>
        <h1>📚 Student Management System</h1>
        <form action="list_students.jsp" method="GET">
            <input type="text" name="keyword" placeholder="Search by name or code...">
            <button type="submit">Search</button>
            <a href="list_students.jsp">Clear</a>
        </form>

        <% if (request.getParameter("message") != null) {%>
        <div class="message success">
            <%= request.getParameter("message")%>
        </div>
        <% } %>

        <% if (request.getParameter("error") != null) {%>
        <div class="message error">
            <%= request.getParameter("error")%>
        </div>
        <% } %>

        <a href="add_student.jsp" class="btn">➕ Add New Student</a>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Student Code</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Major</th>
                    <th>Created At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // Get page number from URL (default = 1)
                    String pageParam = request.getParameter("page");
                    int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;

                    // Records per page
                    int recordsPerPage = 10;

                    // Calculate offset
                    int offset = (currentPage - 1) * recordsPerPage;

                    // Get total records for pagination
                    Connection conn = null;
                    Statement stmt = null;
                    ResultSet rs = null;
                    PreparedStatement pstmt = null;
                    int totalRecords = 0; // You need to implement this
                    int totalPages = 0;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");

                        conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_management",
                                "root",
                                "BakuganFTW123"
                        );

                        String keyword = request.getParameter("keyword");

                        String sql;

                        if (keyword != null && !keyword.trim().isEmpty()) {
                            sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY id ASC";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, "%" + keyword + "%");
                            pstmt.setString(2, "%" + keyword + "%");
                        } else {
                            sql = "SELECT * FROM students ORDER BY id ASC";
                            pstmt = conn.prepareStatement(sql);
                        }
                        rs = pstmt.executeQuery();

                        String countSql = "SELECT COUNT(*) AS total FROM students";
                        PreparedStatement countStmt = conn.prepareStatement(countSql);
                        ResultSet countRs = countStmt.executeQuery();

                        if (countRs.next()) {
                            totalRecords = countRs.getInt("total");
                        }
                        countRs.close();
                        totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
                        if (totalPages < 1) {
                            totalPages = 1;
                        }
                        if (currentPage > totalPages) {
                            currentPage = totalPages;
                        }
                        String limitSql = "SELECT * FROM students ORDER BY id ASC LIMIT ? OFFSET ?";
                        pstmt = conn.prepareStatement(limitSql);
                        pstmt.setInt(1, recordsPerPage);
                        pstmt.setInt(2, offset);

                        rs = pstmt.executeQuery();

                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String studentCode = rs.getString("student_code");
                            String fullName = rs.getString("full_name");
                            String email = rs.getString("email");
                            String major = rs.getString("major");
                            Timestamp createdAt = rs.getTimestamp("created_at");

                %>
                <tr>
                    <td><%= id%></td>
                    <td><%= studentCode%></td>
                    <td><%= fullName%></td>
                    <td><%= email != null ? email : "N/A"%></td>
                    <td><%= major != null ? major : "N/A"%></td>
                    <td><%= createdAt%></td>
                    <td>
                        <a href="edit_student.jsp?id=<%= id%>" class="action-link">✏️ Edit</a>
                        <a href="delete_student.jsp?id=<%= id%>" 
                           class="action-link delete-link"
                           onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                    </td>
                </tr>
                <%
                        }
                    } catch (ClassNotFoundException e) {
                        out.println("<tr><td colspan='7'>Error: JDBC Driver not found!</td></tr>");
                        e.printStackTrace();
                    } catch (SQLException e) {
                        out.println("<tr><td colspan='7'>Database Error: " + e.getMessage() + "</td></tr>");
                        e.printStackTrace();
                    } catch (NumberFormatException e) {
                        out.println("<tr><td colspan='7'>Error: Invalid Page Number!</td></tr>");
                        e.printStackTrace();
                    } finally {
                        try {
                            if (rs != null) {
                                rs.close();
                            }
                            if (stmt != null) {
                                stmt.close();
                            }
                            if (conn != null) {
                                conn.close();
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                %>
            </tbody>
        </table>
        <%if (totalPages > 1) { %>
        <div class="pagination">
            <% if (currentPage > 1) {%>
            <a href="list_students.jsp?page=<%= currentPage - 1%>">Previous</a>
            <% } %>

            <% for (int i = 1; i <= totalPages; i++) { %>
            <% if (i == currentPage) {%>
            <strong><%= i%></strong>
            <% } else {%>
            <a href="list_students.jsp?page=<%= i%>"><%= i%></a>
            <% } %>
            <% } %>

            <% if (currentPage < totalPages) {%>
            <a href="list_students.jsp?page=<%= currentPage + 1%>">Next</a>
            <% }%>
        </div>
        <%}%>
        <script>
            setTimeout(function () {
                var messages = document.querySelectorAll('.message');
                messages.forEach(function (msg) {
                    msg.style.display = 'none';
                });
            }, 3000);
        </script>
    </body>
</html>
