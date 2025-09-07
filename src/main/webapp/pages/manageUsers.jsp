<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, dao.DBConnection" %>

<%
    String userRole = (String) session.getAttribute("role");
	String userName = (String) session.getAttribute("name");
    if (userRole == null || !"admin".equals(userRole)) {
        response.sendRedirect("login.jsp?msg=Unauthorized");
        return;
    }

    String userTypeFilter = request.getParameter("type");
    String keyword = request.getParameter("q");

    Connection conn = DBConnection.getConnection();
    StringBuilder query = new StringBuilder("SELECT user_id, name, email, role, status FROM users WHERE role <> 'admin'");

    if (userTypeFilter != null && !userTypeFilter.isEmpty()) {
        query.append(" AND role = ?");
    }
    if (keyword != null && !keyword.isEmpty()) {
        query.append(" AND (name LIKE ? OR email LIKE ?)");
    }

    PreparedStatement stmt = conn.prepareStatement(query.toString());

    int paramIndex = 1;
    if (userTypeFilter != null && !userTypeFilter.isEmpty()) {
        stmt.setString(paramIndex++, userTypeFilter);
    }
    if (keyword != null && !keyword.isEmpty()) {
        stmt.setString(paramIndex++, "%" + keyword + "%");
        stmt.setString(paramIndex++, "%" + keyword + "%");
    }

    ResultSet rs = stmt.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Users</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>
<nav class="navbar navbar-expand-lg bg-body-tertiary">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">Job Portal</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <% if (userRole != null && userRole.equals("job_seeker")) { %>
                    <li class="nav-item"><a class="nav-link" href="../pages/availableJobs.jsp">Available Jobs</a></li>
                    <li class="nav-item"><a class="nav-link" href="../pages/myApplications.jsp">My Applications</a></li>
                <% } else if (userRole != null && userRole.equals("employer")) { %>
                    <li class="nav-item"><a class="nav-link" href="../pages/postEditJob.jsp">Post Job</a></li>
                    <li class="nav-item"><a class="nav-link" href="../pages/manageJobs.jsp">Manage Jobs</a></li>
                <% } else if (userRole != null && userRole.equals("admin")) { %>
                    <li class="nav-item"><a class="nav-link" href="../pages/manageUsers.jsp">Manage Users</a></li>
                <% }%>
            </ul>

            <ul class="navbar-nav">
                <% if (userRole != null && (userRole.equals("job_seeker") || userRole.equals("employer") || userRole.equals("admin"))) { %>
                    <li class="nav-item"><a class="nav-link">Welcome, <%= userName %></a></li>
                    <li class="nav-item"><a class="nav-link btn btn-danger text-black" href="../LogoutServlet">Logout</a></li>
                <% } else { %>
                    <li class="nav-item"><a class="nav-link btn btn-primary text-white" href="../pages/login.jsp">Login</a></li>
                    <li class="nav-item"><a class="nav-link btn btn-success text-white" href="../pages/register.jsp">Register</a></li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<div class="container mt-5">
    <h2>Manage Users</h2>

    <form method="get" class="row g-3 mb-4">
	    <div class="col-md-6">
	            <input type="text" name="q" class="form-control" placeholder="Search by name/email" value="<%= keyword != null ? keyword : "" %>">
        </div>
        <div class="col-md-6">
            <select name="type" class="form-select">
                <option value="">All User Types</option>
                <option value="job_seeker" <%= "job_seeker".equals(userTypeFilter) ? "selected" : "" %>>Job Seeker</option>
                <option value="employer" <%= "employer".equals(userTypeFilter) ? "selected" : "" %>>Employer</option>
            </select>
        </div>
        
        <div class="col-md-4">
            <button type="submit" class="btn btn-primary">Search</button>
        </div>
    </form>

    <table class="table table-borderless table-hover">
        <thead class="table-dark">
            <tr>
                <th>User ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>User Type</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
                int userId = rs.getInt("user_id");
                String name = rs.getString("name");
                String email = rs.getString("email");
                String role = rs.getString("role");
                String status = rs.getString("status");
        %>
            <tr>
                <td><%= userId %></td>
                <td><%= name %></td>
                <td><%= email %></td>
                <td><%= role %></td>
                <td><%= status %></td>
                <td>
                    <form action="../ToggleUserStatusServlet" method="post">
                        <input type="hidden" name="user_id" value="<%= userId %>">
                        <input type="hidden" name="status" value="<%= "active".equals(status) ? "frozen" : "active" %>">
                        <button class="btn btn-sm <%= "active".equals(status) ? "btn-danger" : "btn-success" %>" type="submit">
                            <%= "active".equals(status) ? "Freeze" : "Unfreeze" %>
                        </button>
                    </form>
                </td>
            </tr>
        <%
            }
            rs.close();
            stmt.close();
            conn.close();
        %>
        </tbody>
    </table>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>