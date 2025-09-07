package dao;

import java.sql.*;

public class DBConnection {
    private static final String URL = System.getenv("DB_URL");
    private static final String USER = System.getenv("DB_USER");
    private static final String PASSWORD = System.getenv("DB_PASSWORD");
    private static Connection conn;

    public static Connection getConnection() {
        try {
            if (conn == null || conn.isClosed()) {
                Class.forName("org.postgresql.Driver");
                conn = DriverManager.getConnection(URL, USER, PASSWORD);
                System.out.println("Database Connected!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }
}
