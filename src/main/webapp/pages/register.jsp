<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="card">
        <h2 class="text-center">Register</h2>
        <% if(request.getParameter("msg") != null) { %>
            <div class="alert alert-danger"><%= request.getParameter("msg") %></div>
        <% } %>
        <form action="../RegisterServlet" method="post">
            <div class="mb-3">
                <label>Name:</label>
                <input type="text" name="name" class="form-control" required>
            </div>
            <div class="mb-3">
                <label>Email:</label>
                <input type="email" name="email" class="form-control" required>
            </div>
            <div class="mb-3">
                <label>Password:</label>
                <input type="password" name="password" class="form-control" required>
            </div>
            <div class="mb-3">
                <label>Role:</label>
                <select name="role" class="form-control">
                    <option value="job_seeker">Job Seeker</option>
                    <option value="employer">Employer</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary w-100">Register</button>
        </form>
        <p class="text-center mt-3">Already have an account? <a href="login.jsp">Login</a></p>
    </div>
</div>

</body>
</html>
