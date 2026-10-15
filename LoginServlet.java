package com.app.servlets;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import com.app.db.SpotifyDatabase;
import com.app.db.UserSchema;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("user_email");
        String password = request.getParameter("pwd_1");

        UserSchema loginUserData = SpotifyDatabase.readUser(email);

        if (loginUserData != null && loginUserData.getPassword().equals(password)) {
            HttpSession session = request.getSession();
            session.setAttribute("userName", loginUserData.getFirstName());
            session.setAttribute("userEmail", loginUserData.getEmail());
            response.sendRedirect("home");
        } else {
            response.sendRedirect("LoginPage.html?error=invalid_credentials");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("LoginPage.html");
    }
}