package controllers;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import dao.DBConnection;
import utils.EmailUtil;

@WebServlet("/ApplyJobServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 10) // 10MB max file size
public class ApplyJobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer jobSeekerId = (Integer) session.getAttribute("user_id");

        if (jobSeekerId == null) {
            response.sendRedirect("pages/login.jsp?msg=Please log in first!");
            return;
        }

        int jobId = Integer.parseInt(request.getParameter("job_id"));
        String coverLetter = request.getParameter("cover_letter");

        // Get uploaded resume file
        Part filePart = request.getPart("resume");
        InputStream inputStream = filePart.getInputStream(); // Convert file to InputStream

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO applications (job_id, job_seeker_id, resume, cover_letter) VALUES (?, ?, ?, ?)"
            );
            stmt.setInt(1, jobId);
            stmt.setInt(2, jobSeekerId);
            stmt.setBinaryStream(3, inputStream, (int) filePart.getSize());
            stmt.setString(4, coverLetter);
            stmt.executeUpdate();
            
            // Fetch employer email from jobs table
            PreparedStatement jobStmt = conn.prepareStatement(
                "SELECT users.email, jobs.title FROM jobs " +
                "JOIN users ON jobs.employer_id = users.user_id " +
                "WHERE jobs.job_id = ?"
            );
            jobStmt.setInt(1, jobId);
            ResultSet jobRs = jobStmt.executeQuery();
            if (jobRs.next()) {
                String employerEmail = jobRs.getString("email");
                String title = jobRs.getString("title"); // Fetch job title

                // Send email notification
                String subject = "New Job Application Received";
                String body = "A new candidate has applied for your job: " + title + "\nCheck the portal for details.";
                EmailUtil.sendEmail(employerEmail, subject, body);
            }

            response.sendRedirect("pages/myApplications.jsp?msg=Application Submitted!");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/viewJob.jsp?job_id=" + jobId + "&msg=Error submitting application!");
        }
    }
}
