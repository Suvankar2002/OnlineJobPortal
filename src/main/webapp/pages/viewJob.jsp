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
    int jobId = Integer.parseInt(request.getParameter("job_id"));
%>
<!DOCTYPE html>
<html>
<head>
    <title>Apply for Job</title>
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
    <%
    	Connection conn = DBConnection.getConnection();
   		PreparedStatement jobStmt = conn.prepareStatement("SELECT * FROM jobs WHERE job_id = ?");
   	    jobStmt.setInt(1, jobId);
   	    ResultSet jobRs = jobStmt.executeQuery();
   	    jobRs.next();
    %>

    <div class="container mt-5">
        <h2><%= jobRs.getString("title") %></h2>
        <p><strong>Category:</strong> <%= jobRs.getString("category") %></p>
        <p><strong>Salary:</strong> <%= jobRs.getDouble("salary") %></p>
        <p><strong>Location:</strong> <%= jobRs.getString("location") %></p>
        <p><strong>Job Type:</strong> <%= jobRs.getString("job_type") %></p>
        <p><strong>Experience Required:</strong> <%= jobRs.getInt("experience") %> years</p>
        <p><strong>Description:</strong></p>
        <p><%= jobRs.getString("description") %></p>

        <% if ("job_seeker".equals(userRole)) { %>
            <hr>
            <h4>Apply for this Job</h4>
            <form action="../ApplyJobServlet" method="post" enctype="multipart/form-data">
            	<input type="hidden" name="job_id" value="<%= jobId %>">
                <div class="mb-3">
                    <label class="form-label">Cover Letter</label>
                    <textarea name="cover_letter" class="form-control" rows="5" required></textarea>
                </div>
                <div class="mb-3">
                    <label class="form-label">Resume</label>
                    <input type="file" name="resume" class="form-control" accept=".pdf,.doc,.docx" required>
                </div>
                <button type="submit" class="btn btn-primary">Submit Application</button>
            </form>
        <% } %>
    </div>
</body>
</html>
