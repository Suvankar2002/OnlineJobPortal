package controllers;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.DBConnection;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = hashPassword(request.getParameter("password"));
        String role = request.getParameter("role");
        
        if(!role.equals("job_seeker") && !role.equals("employer")) {
        	response.sendRedirect("pages/register.jsp?msg=Registration Failed!");
        	return;
        }

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement("INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?::user_role)");
            stmt.setString(1, name);
            stmt.setString(2, email);
            stmt.setString(3, password);
            stmt.setString(4, role);
            int rowsInserted = stmt.executeUpdate();

            if (rowsInserted > 0) {
                response.sendRedirect("pages/login.jsp?msg=Registration Successful!");
            } else {
                response.sendRedirect("pages/register.jsp?msg=Registration Failed!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/register.jsp?msg=Error Occurred!");
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
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
}
