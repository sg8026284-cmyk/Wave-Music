package com.app.servlets;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import com.app.db.SpotifyDatabase;
import com.app.db.UserSchema;
import com.app.helpers.DataValidations;
import com.app.services.EmailServices;
import com.app.services.JWTServices;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String fname = request.getParameter("f_name");
        String lname = request.getParameter("l_name");
        String email = request.getParameter("user_email");
        String pwd1 = request.getParameter("pwd_1");
        String pwd2 = request.getParameter("pwd_2");

        if (DataValidations.passwordValidation(pwd1, pwd2) && 
            DataValidations.emailValidation(email) && 
            DataValidations.nameValidation(fname, lname)) {

            UserSchema user = new UserSchema(fname, lname, email, pwd1);

            if (SpotifyDatabase.createUser(user)) {
                int otp = (int) (Math.random() * 900000) + 100000;
                String token = JWTServices.generateJWT(otp);

                EmailServices.sendOTP(email, fname, otp);

                HttpSession session = request.getSession();
                session.setAttribute("sentOTPToken", token);
                session.setAttribute("pendingEmail", email);
                response.sendRedirect("OTPEnterPage.html");
                return;
            }
        }
        response.sendRedirect("RegisterPage.html?error=failed");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        doPost(request, response);
    }
}