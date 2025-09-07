<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, dao.DBConnection" %>
<%
    String userRole = (String) session.getAttribute("role");
	String userName = (String) session.getAttribute("name");
	Integer userId = (Integer) session.getAttribute("user_id");
    if (userRole == null || !userRole.equals("job_seeker")) {
        response.sendRedirect("login.jsp?msg=Access Denied!");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Applications</title>
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
	<div class="container">
    <h3 class="mt-4">My Job Applications</h3>

    <table class="table table-borderless table-hover">
        <thead class="table-dark">
        	<tr>
            <th>Job Title</th>
            <th>Company</th>
            <th>Application Status</th>
            <th>Applied Date</th>
            </tr>
        </thead>

        <%
            Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT jobs.title, users.name AS company, applications.status, applications.applied_date " +
                "FROM applications " +
                "JOIN jobs ON applications.job_id = jobs.job_id " +
                "JOIN users ON jobs.employer_id = users.user_id " +
                "WHERE applications.job_seeker_id = ?"
            );
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
        %>
                <tr>
                    <td><%= rs.getString("title") %></td>
                    <td><%= rs.getString("company") %></td>
                    <td><%= rs.getString("status") %></td>
                    <td><%= rs.getDate("applied_date") %></td>
                </tr>
        <%
            }
        %>
    </table>
    </div>
</body>
</html>
