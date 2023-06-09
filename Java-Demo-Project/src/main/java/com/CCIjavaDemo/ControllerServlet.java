package com.CCIjavaDemo;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/")
public class ControllerServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private TextDAO db;   

    public ControllerServlet() {
        super();
        db = new TextDAO();
    }

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setAttribute("current_text", db.getCurrentText());
		RequestDispatcher dispatcher = request.getRequestDispatcher("/Index.jsp");
		dispatcher.forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String item = request.getParameter("item");
		if(db.updateText(item)) System.out.println("Text Updated");
		doGet(request, response);
	}
}
