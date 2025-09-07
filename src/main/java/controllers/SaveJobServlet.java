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

@WebServlet("/SaveJobServlet")
public class SaveJobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer employerId = (Integer) session.getAttribute("user_id");

        // Check if employer is logged in
        if (employerId == null || !"employer".equals(session.getAttribute("role"))) {
            response.sendRedirect("pages/login.jsp?msg=Access Denied! Please log in as an employer.");
            return;
        }

        // Get job details from form
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String salaryStr = request.getParameter("salary");
        String location = request.getParameter("location");
        String experienceStr = request.getParameter("experience");
        String jobType = request.getParameter("job_type");
        
        String jobIdParam = request.getParameter("job_id");

        // Validate input fields (no null or empty values)
        if (title == null || title.isEmpty() || description == null || description.isEmpty() ||
            category == null || category.isEmpty() || salaryStr == null || salaryStr.isEmpty() ||
            location == null || location.isEmpty() || experienceStr == null || experienceStr.isEmpty() ||
            jobType == null || jobType.isEmpty()) {
            
            response.sendRedirect("pages/postEditJob.jsp?msg=All fields are required!");
            return;
        }

        // Convert numeric fields safely
        double salary;
        int experience;
        try {
            salary = Double.parseDouble(salaryStr);
            experience = Integer.parseInt(experienceStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("pages/postEditJob.jsp?msg=Invalid salary or experience value!");
            return;
        }

        // Insert job into database
        try {
            Connection conn = DBConnection.getConnection();
            
            if (jobIdParam != null && !jobIdParam.isEmpty()) {
            	int jobId = Integer.parseInt(jobIdParam);

                PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT job_id FROM jobs WHERE job_id = ? AND employer_id = ?"
                );
                checkStmt.setInt(1, jobId);
                checkStmt.setInt(2, employerId);
                ResultSet rs = checkStmt.executeQuery();

                if (rs.next()) {
                    PreparedStatement updateStmt = conn.prepareStatement(
                        "UPDATE jobs SET title = ?, category = ?, location = ?, job_type = ?, experience = ?, description = ?, salary = ? WHERE job_id = ?"
                    );
                    updateStmt.setString(1, title);
                    updateStmt.setString(2, category);
                    updateStmt.setString(3, location);
                    updateStmt.setString(4, jobType);
                    updateStmt.setInt(5, experience);
                    updateStmt.setString(6, description);
                    updateStmt.setDouble(7, salary);
                    updateStmt.setInt(8, jobId);
                    updateStmt.executeUpdate();

                    response.sendRedirect("pages/manageJobs.jsp?msg=Job updated successfully!");
                } else {
                    response.sendRedirect("pages/manageJobs.jsp?msg=Unauthorized edit attempt!");
                }
            }
            else {
            	// Create new job
            	PreparedStatement stmt = conn.prepareStatement(
                        "INSERT INTO jobs (employer_id, title, description, category, salary, location, experience, job_type) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
                    );
                stmt.setInt(1, employerId);
                stmt.setString(2, title);
                stmt.setString(3, description);
                stmt.setString(4, category);
                stmt.setDouble(5, salary);
                stmt.setString(6, location);
                stmt.setInt(7, experience);
                stmt.setString(8, jobType);
                int rowsInserted = stmt.executeUpdate();

                if (rowsInserted > 0) {
                    response.sendRedirect("pages/manageJobs.jsp?msg=Job posted successfully!");
                } else {
                    response.sendRedirect("pages/postEditJob.jsp?msg=Failed to post job!");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/postEditJob.jsp?msg=Error posting job!");
        }
    }
}
