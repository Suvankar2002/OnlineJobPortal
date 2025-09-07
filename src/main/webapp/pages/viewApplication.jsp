<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, dao.DBConnection" %>
<%
String userRole = (String) session.getAttribute("role");
String userName = (String) session.getAttribute("name");
Integer employerId = (Integer) session.getAttribute("user_id");

if (userRole == null || !userRole.equals("employer")) {
    response.sendRedirect("login.jsp?msg=Access Denied!");
    return;
} 

String appIdParam = request.getParameter("application_id");
if (appIdParam == null) {
    response.sendRedirect("manageJobs.jsp?msg=Invalid application");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View Application</title>
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
    <h2 class="mb-4">Application Details</h2>
    <%
    
    int appId = Integer.parseInt(appIdParam);
    Connection conn = DBConnection.getConnection();
    PreparedStatement stmt = conn.prepareStatement(
        "SELECT a.application_id, a.cover_letter, a.status, a.resume, u.name, u.email " +
        "FROM applications a JOIN users u ON a.job_seeker_id = u.user_id " +
        "JOIN jobs j ON a.job_id = j.job_id " +
        "WHERE a.application_id = ? AND j.employer_id = ?"
    );
    stmt.setInt(1, appId);
    stmt.setInt(2, employerId);
    ResultSet rs = stmt.executeQuery();

    if (!rs.next()) {
        response.sendRedirect("manageJobs.jsp?msg=Unauthorized access");
        return;
    }

    String name = rs.getString("name");
    String email = rs.getString("email");
    String coverLetter = rs.getString("cover_letter");
    String status = rs.getString("status");
    int applicationId = rs.getInt("application_id");
    
    %>

    <table class="table table-bordered">
        <tr>
            <th>Applicant Name</th>
            <td><%= name %></td>
        </tr>
        <tr>
            <th>Email</th>
            <td><%= email %></td>
        </tr>
        <tr>
            <th>Cover Letter</th>
            <td><%= coverLetter %></td>
        </tr>
        <tr>
            <th>Resume</th>
            <td><a href="../DownloadResumeServlet?application_id=<%= applicationId %>" class="btn btn-outline-primary btn-sm">Download Resume</a></td>
        </tr>
        <tr>
            <th>Current Status</th>
            <td><%= status %></td>
        </tr>
    </table>

    <form method="post" action="../UpdateApplicationStatusServlet" class="mt-4">
        <input type="hidden" name="application_id" value="<%= applicationId %>">
        <div class="mb-3">
            <label for="status" class="form-label">Change Status:</label>
            <select name="status" id="status" class="form-select" required>
                <option value="Pending" <%= "Pending".equals(status) ? "selected" : "" %>>Pending</option>
                <option value="Reviewed" <%= "Reviewed".equals(status) ? "selected" : "" %>>Reviewed</option>
                <option value="Shortlisted" <%= "Shortlisted".equals(status) ? "selected" : "" %>>Shortlisted</option>
                <option value="Hired" <%= "Hired".equals(status) ? "selected" : "" %>>Hired</option>
                <option value="Rejected" <%= "Rejected".equals(status) ? "selected" : "" %>>Rejected</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primary">Update Status</button>
    </form>
</div>


</body>
</html>