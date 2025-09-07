<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, dao.DBConnection" %>
<%
	String userRole = (String) session.getAttribute("role");
	String userName = (String) session.getAttribute("name");
	Integer userId = (Integer) session.getAttribute("user_id");
	
	if (userRole == null || !userRole.equals("employer")) {
	    response.sendRedirect("login.jsp?msg=Access Denied!");
	    return;
	}
	
	boolean isEdit = false;
	int jobId = 0;
	String title = "", category = "", location = "", type = "", description = "";
	int experience = 0;
	double salary = 0;
	
	if (request.getParameter("job_id") != null) {
	    isEdit = true;
	    jobId = Integer.parseInt(request.getParameter("job_id"));
	
	    Connection conn = DBConnection.getConnection();
	    PreparedStatement stmt = conn.prepareStatement("SELECT * FROM jobs WHERE job_id = ? AND employer_id = ?");
	    stmt.setInt(1, jobId);
	    stmt.setInt(2, userId);
	    ResultSet rs = stmt.executeQuery();
	
	    if (rs.next()) {
	        title = rs.getString("title");
	        category = rs.getString("category");
	        location = rs.getString("location");
	        type = rs.getString("job_type");
	        description = rs.getString("description");
	        experience = rs.getInt("experience");
	        salary = rs.getDouble("salary");
	    } else {
	        response.sendRedirect("manageJobs.jsp?msg=Unauthorized Access");
	        return;
	    }
	}
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= isEdit ? "Edit Job" : "Post New Job" %></title>
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
    <h2><%= isEdit ? "Edit Job" : "Post a New Job" %></h2>

    <form method="post" action="../SaveJobServlet">
        <% if (isEdit) { %>
            <input type="hidden" name="job_id" value="<%= jobId %>">
        <% } %>

        <div class="mb-3">
            <label class="form-label">Title</label>
            <input type="text" name="title" class="form-control" value="<%= title %>" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Category</label>
            <input type="text" name="category" class="form-control" value="<%= category %>" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Location</label>
            <input type="text" name="location" class="form-control" value="<%= location %>" required>
        </div>
        
        <div class="mb-3">
		  <label for="salary" class="form-label">Salary (in ₹):</label>
		  <input type="number" name="salary" class="form-control"value="<%= salary %>" required>
		</div>

        <div class="mb-3">
            <label class="form-label">Job Type</label>
            <select name="job_type" class="form-select" required>
                <option value="Full-Time" <%= "Full-Time".equals(type) ? "selected" : "" %>>Full-Time</option>
                <option value="Part-Time" <%= "Part-Time".equals(type) ? "selected" : "" %>>Part-Time</option>
                <option value="Remote" <%= "Remote".equals(type) ? "selected" : "" %>>Remote</option>
                <option value="Internship" <%= "Internship".equals(type) ? "selected" : "" %>>Internship</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Experience Required (years)</label>
            <input type="number" name="experience" class="form-control" min="0" value="<%= experience %>" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Description</label>
            <textarea name="description" class="form-control" rows="5" required><%= description %></textarea>
        </div>

        <button type="submit" class="btn btn-success"><%= isEdit ? "Update Job" : "Post Job" %></button>
    </form>
</div>
</body>
</html>
