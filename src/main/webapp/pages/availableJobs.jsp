<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, dao.DBConnection" %>
<%
    String userRole = (String) session.getAttribute("role");
	String userName = (String) session.getAttribute("name");
    if (userRole == null ||  (!userRole.equals("job_seeker") && !userRole.equals("employer") && !userRole.equals("admin"))) {
        response.sendRedirect("login.jsp?msg=Access Denied!");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Available Jobs</title>
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
    <h2 class="mb-4">Available Jobs</h2>

    <form method="get" class="row g-3 mb-4">
        <div class="col-md-12">
            <input type="text" name="search" class="form-control" placeholder="Search by title/location/company" value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
        </div>
        <div class="col-md-6">
            <select class="form-select" name="category">
                <option value="">All Categories</option>
                <option value="IT" <%= "IT".equals(request.getParameter("category")) ? "selected" : "" %>>IT</option>
                <option value="Finance" <%= "Finance".equals(request.getParameter("category")) ? "selected" : "" %>>Finance</option>
                <option value="Marketing" <%= "Marketing".equals(request.getParameter("category")) ? "selected" : "" %>>Marketing</option>
            </select>
        </div>
        <div class="col-md-6">
            <select class="form-select" name="experience">
                <option value="">All Experience Levels</option>
                <option value="0" <%= "0".equals(request.getParameter("experience")) ? "selected" : "" %>>0-1 years</option>
                <option value="2" <%= "2".equals(request.getParameter("experience")) ? "selected" : "" %>>2-4 years</option>
                <option value="5" <%= "5".equals(request.getParameter("experience")) ? "selected" : "" %>>5+ years</option>
            </select>
        </div>
        <div class="col-md-6">
		    <select class="form-select" name="job_type">
		        <option value="">All Job Types</option>
		        <option value="Full-time" <%= "Full-time".equals(request.getParameter("job_type")) ? "selected" : "" %>>Full-time</option>
		        <option value="Part-time" <%= "Part-time".equals(request.getParameter("job_type")) ? "selected" : "" %>>Part-time</option>
		        <option value="Remote" <%= "Remote".equals(request.getParameter("job_type")) ? "selected" : "" %>>Remote</option>
		        <option value="Internship" <%= "Internship".equals(request.getParameter("job_type")) ? "selected" : "" %>>Internship</option>
		    </select>
		</div>
        <div class="col-md-3">
            <input type="submit" class="btn btn-primary w-100" value="Search">
        </div>
    </form>

    <table class="table table-borderless table-hover">
        <thead class="table-dark">
            <tr>
                <th>Title</th>
                <th>Company</th>
                <th>Salary</th>
                <th>Category</th>
                <th>Location</th>
                <th>Experience</th>
                <th>Job Type</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        <%
            Connection conn = DBConnection.getConnection();
            String search = request.getParameter("search");
            String category = request.getParameter("category");
            String expFilter = request.getParameter("experience");
            String jobType = request.getParameter("job_type");

            StringBuilder query = new StringBuilder("SELECT * FROM jobs JOIN users ON jobs.employer_id = users.user_id  WHERE 1=1");

            if (search != null && !search.isEmpty()) {
                query.append(" AND (title LIKE ? OR location LIKE ? OR name LIKE ?)");
            }
            if (category != null && !category.isEmpty()) {
                query.append(" AND category = ?");
            }
            if (expFilter != null && !expFilter.isEmpty()) {
                if ("0".equals(expFilter)) {
                    query.append(" AND experience <= 1");
                } else if ("2".equals(expFilter)) {
                    query.append(" AND experience BETWEEN 2 AND 4");
                } else if ("5".equals(expFilter)) {
                    query.append(" AND experience >= 5");
                }
            }
            if (jobType != null && !jobType.isEmpty()) {
                query.append(" AND job_type = ?");
            }
            query.append(" ORDER BY posted_date DESC");

            PreparedStatement stmt = conn.prepareStatement(query.toString());
            int paramIndex = 1;

            if (search != null && !search.isEmpty()) {
                String like = "%" + search + "%";
                stmt.setString(paramIndex++, like);
                stmt.setString(paramIndex++, like);
                stmt.setString(paramIndex++, like);
            }
            if (category != null && !category.isEmpty()) {
                stmt.setString(paramIndex++, category);
            }
            if (jobType != null && !jobType.isEmpty()) {
                stmt.setString(paramIndex++, jobType);
            }


            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
        %>
            <tr>
                <td><%= rs.getString("title") %></td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("salary") %></td>
                <td><%= rs.getString("category") %></td>
                <td><%= rs.getString("location") %></td>
                <td><%= rs.getInt("experience") %> years</td>
                <td><%= rs.getString("job_type") %></td>
                <td>
                    <a href="viewJob.jsp?job_id=<%= rs.getInt("job_id") %>" class="btn btn-sm btn-outline-primary">
                        <%= userRole.equals("job_seeker") ? "View/Apply" : "View" %>
                    </a>
                </td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
</div>

</body>
</html>
