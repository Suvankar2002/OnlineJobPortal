<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, dao.DBConnection" %>
<%
    String userRole = (String) session.getAttribute("role");
	String userName = (String) session.getAttribute("name");
    if (userRole == null || !userRole.equals("employer")) {
        response.sendRedirect("login.jsp?msg=Access Denied!");
        return;
    }
    int jobId = Integer.parseInt(request.getParameter("job_id"));
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Applicants</title>
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
<div class="container mt-4">
    <h2 class="mb-4">Applicants for Job: <%= request.getParameter("job_title") %></h2>

    <table class="table table-borderless table-hover">
    <thead class="table-dark">
        <tr>
            <th>Applicant Name</th>
            <th>Resume</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
     </thead>

        <%
            Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT applications.application_id, users.name AS applicant_name, applications.cover_letter, applications.status " +
                "FROM applications " +
                "JOIN users ON applications.job_seeker_id = users.user_id " +
                "WHERE applications.job_id = ?"
            );
            stmt.setInt(1, jobId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
        %>
                <tr>
                    <td><%= rs.getString("applicant_name") %></td>
                    <td><a href="../DownloadResumeServlet?application_id=<%= rs.getInt("application_id") %>" class="btn btn-sm btn-outline-primary">Resume</a></td>
                    <td><%= rs.getString("status") %></td>
                    <td><a href="viewApplication.jsp?application_id=<%= rs.getInt("application_id") %>" class="btn btn-sm btn-outline-success">Edit</a></td>
                </tr>
        <%
            }
        %>
    </table>
 </div>
 <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
