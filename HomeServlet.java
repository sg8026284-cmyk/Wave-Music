package com.app.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import com.app.db.SongSchema;
import com.app.db.SpotifyDatabase;
import com.app.helpers.JSONMusicDemo;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Session validation
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("LoginPage.html");
            return;
        }

        // 2. Fetch songs from MongoDB
        List<SongSchema> songs = SpotifyDatabase.getSongs();

        // 3. Fallback: if database is empty, seed from iTunes API automatically
        if (songs == null || songs.isEmpty()) {
            List<SongSchema> freshSongs = JSONMusicDemo.getSongs("Arijit Singh");
            if (freshSongs != null && !freshSongs.isEmpty()) {
                SpotifyDatabase.saveSongs(freshSongs);
                songs = SpotifyDatabase.getSongs();
            }
        }

        // 4. Forward to JSP
        request.setAttribute("songs", songs);
        request.getRequestDispatcher("HomePage.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}