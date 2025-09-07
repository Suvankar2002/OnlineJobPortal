package utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Properties;

import dao.DBConnection;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailUtil {
	private static final String SMTP_HOST = "smtp.gmail.com"; // Change as needed
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_FROM = System.getenv("MAIL_USER");;
    private static final String EMAIL_PASSWORD = System.getenv("MAIL_PASSWORD");;

    public static void sendEmail(String recipientEmail, String subject, String body) {
    	Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
            }
        });

        Connection conn = DBConnection.getConnection();
        PreparedStatement logStmt = null;

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_FROM));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject(subject);
            message.setText(body);
            Transport.send(message);

            try {
                logStmt = conn.prepareStatement(
                "INSERT INTO mail_logs (recipient, subject, body, status) VALUES (?, ?, ?, ?)"
                );
                logStmt.setString(1, recipientEmail);
                logStmt.setString(2, subject);
                logStmt.setString(3, body);
                logStmt.setString(4, "SENT");
                logStmt.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (MessagingException e) {
            try {
                logStmt = conn.prepareStatement(
                "INSERT INTO mail_logs (recipient, subject, body, status, error_message) VALUES (?, ?, ?, ?, ?)"
                );
                logStmt.setString(1, recipientEmail);
                logStmt.setString(2, subject);
                logStmt.setString(3, body);
                logStmt.setString(4, "FAILED");
                logStmt.setString(5, e.getMessage());
                logStmt.executeUpdate();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}
