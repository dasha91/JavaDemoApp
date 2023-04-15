package com.CCIjavaDemo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class TextDAO {

	private String jdbcURL = "jdbc:mysql://localhost:3306/demo";
	private String jdbcUsername = "root";
	private String jdbcPassword = "";
	private Connection jdbcConnection;
	
	public void connect() {
		try {
			if (jdbcConnection == null || jdbcConnection.isClosed()) {
				Class.forName("com.mysql.jdbc.Driver");
				jdbcConnection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
				System.out.println("MySQL Connection Established");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void disconnect() {
		try {
			if (jdbcConnection != null && !jdbcConnection.isClosed()) {
				jdbcConnection.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public String getCurrentText() {
		connect();
		String text = null;
		try {
			Statement statement = jdbcConnection.createStatement();
			ResultSet result = statement.executeQuery("Select * FROM text");
			while (result.next()) {
				text = result.getString("text");
			}
			result.close();
			statement.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		disconnect();
		return text;
	}
	
	public boolean updateText(String newText) {
		connect(); 
		String sql = "UPDATE text SET text = ?";
		boolean rowUpdated = false;
		try {
			PreparedStatement statement = jdbcConnection.prepareStatement(sql);
			statement.setString(1, newText);
			rowUpdated = statement.executeUpdate() > 0;
			statement.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		disconnect();
		return rowUpdated;
	}
}