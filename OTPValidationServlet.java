package com.app.servlets;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import com.app.db.SpotifyDatabase;
import com.app.services.JWTServices;

@WebServlet("/OTPValidationServlet")
public class OTPValidationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String enteredOTP = request.getParameter("enteredOTP");
        HttpSession session = request.getSession();

        String token = (String) session.getAttribute("sentOTPToken");
        String email = (String) session.getAttribute("pendingEmail");
        String validOTP = JWTServices.verifyJWT(token);

        if (validOTP != null && validOTP.equals(enteredOTP != null ? enteredOTP.trim() : "")) {
            SpotifyDatabase.verifyUser(email);
            session.removeAttribute("sentOTPToken");
            session.removeAttribute("pendingEmail");
            response.sendRedirect("LoginPage.html");
        } else {
            response.sendRedirect("OTPEnterPage.html?error=invalid_otp");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        doPost(request, response);
    }
}