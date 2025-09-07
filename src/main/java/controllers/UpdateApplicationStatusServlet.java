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
import utils.EmailUtil;
import dao.DBConnection;

@WebServlet("/UpdateApplicationStatusServlet")
public class UpdateApplicationStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int applicationId = Integer.parseInt(request.getParameter("application_id"));
        String status = request.getParameter("status");

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                "UPDATE applications SET status = ?::application_status WHERE application_id = ?"
            );
            stmt.setString(1, status);
            stmt.setInt(2, applicationId);
            stmt.executeUpdate();
            
            // Fetch employer email from jobs table
            PreparedStatement jobStmt = conn.prepareStatement(
                "SELECT users.name, users.email, jobs.title FROM ((applications " +
                "JOIN users ON applications.job_seeker_id = users.user_id )" +
                "JOIN jobs ON jobs.job_id = applications.job_id)" +
                "WHERE applications.application_id = ? and applications.status = ?::application_status"
            );
            jobStmt.setInt(1, applicationId);
            jobStmt.setString(2, status);
            ResultSet jobRs = jobStmt.executeQuery();
            if (jobRs.next()) {
                String jobSeekerEmail = jobRs.getString("email");
                String jobSeekerName = jobRs.getString("name");
                String title = jobRs.getString("title"); // Fetch job title

                // Send email notification
                String subject = "Application status changed";
                String body = "Hi " + jobSeekerName +",\n" + 
                				"Your Applications status changed to " + status +
                				" for job " + title  + ".";
                EmailUtil.sendEmail(jobSeekerEmail, subject, body);
            }

            response.sendRedirect("pages/viewApplication.jsp?application_id=" + applicationId + "&msg=Status Updated!");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/viewApplication.jsp?application_id=" + applicationId + "&msg=Error updating status!");
        }
    }
}
