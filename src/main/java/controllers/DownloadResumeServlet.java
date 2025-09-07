package controllers;
import java.io.IOException;
import java.io.OutputStream;
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

@WebServlet("/DownloadResumeServlet")
public class DownloadResumeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer employerId = (Integer) session.getAttribute("user_id");

        // Ensure only employers can download resumes
        if (employerId == null || !"employer".equals(session.getAttribute("role"))) {
            response.sendRedirect("pages/login.jsp?msg=Access Denied!");
            return;
        }

        int applicationId = Integer.parseInt(request.getParameter("application_id"));

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement("SELECT resume FROM applications WHERE application_id = ?");
            stmt.setInt(1, applicationId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                byte[] resumeData = rs.getBytes("resume");
                if (resumeData == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Resume not found");
                    return;
                }

                // Set response headers
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=\"resume.pdf\"");

                // Stream the file to the client
                OutputStream os = response.getOutputStream();
                os.write(resumeData);
                os.flush();
                os.close();
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Resume not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/manageJobs.jsp?msg=Error downloading resume!");
        }
    }
}
