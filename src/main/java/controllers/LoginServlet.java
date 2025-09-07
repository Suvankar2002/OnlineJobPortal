package controllers;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.DBConnection;
import java.security.MessageDigest;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = hashPassword(request.getParameter("password"));

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE email = ? AND password = ?");
            stmt.setString(1, email);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
            	String status = rs.getString("status");

                if ("frozen".equalsIgnoreCase(status)) {
                    response.sendRedirect("pages/login.jsp?msg=Your account has been frozen. Contact admin.");
                    return;
                }
            	
            	HttpSession session = request.getSession();
                session.setAttribute("user_id", rs.getInt("user_id"));
                session.setAttribute("role", rs.getString("role"));
                session.setAttribute("name", rs.getString("name"));

                // Redirect based on role
                String role = rs.getString("role");
                if ("job_seeker".equals(role)) {
                    response.sendRedirect("pages/availableJobs.jsp");
                } else if ("employer".equals(role)) {
                    response.sendRedirect("pages/manageJobs.jsp");
                } else if ("admin".equals(role)) {
                    response.sendRedirect("pages/manageUsers.jsp");
                } else {
                    response.sendRedirect("pages/login.jsp?msg=Invalid User Role!");
                }
            } else {
                response.sendRedirect("pages/login.jsp?msg=Invalid Email or Password!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/login.jsp?msg=Error Occurred!");
        }
    }

    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
}
