<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>

<div class="container">
    <div class="card">
        <h2 class="text-center">Login</h2>
        <% if(request.getParameter("msg") != null) { %>
            <div class="alert alert-danger"><%= request.getParameter("msg") %></div>
        <% } %>
        <form action="../LoginServlet" method="post">
            <div class="mb-3">
                <label>Email:</label>
                <input type="email" name="email" class="form-control" required>
            </div>
            <div class="mb-3">
                <label>Password:</label>
                <input type="password" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-primary w-100">Login</button>
        </form>
        <p class="text-center mt-3">Don't have an account? <a href="register.jsp">Register</a></p>
    </div>
</div>

</body>
</html>
