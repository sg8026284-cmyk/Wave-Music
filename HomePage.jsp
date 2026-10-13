<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.app.db.SongSchema" %>
<%@ page import="com.app.db.SpotifyDatabase" %>
<%! 
    // Helper function to safely escape quotes and special characters
    public String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;");
    }
%>
<%
    String name = String.valueOf(session.getAttribute("userName"));
    String email = String.valueOf(session.getAttribute("userEmail"));
    
    // Auth validation
    if (name == null || email == null || name.equals("null") || email.equals("null")) {
        response.sendRedirect("LoginPage.html");
        return;
    }
    
    String initial = (!name.trim().isEmpty() && !name.equals("null")) 
                     ? name.trim().substring(0, 1).toUpperCase() 
                     : "U";

    // 1. Fetch songs forwarded from HomeServlet
    List<SongSchema> songs = (List<SongSchema>) request.getAttribute("songs");
    
    // 2. Direct database fallback
    if (songs == null || songs.isEmpty()) {
        songs = SpotifyDatabase.getSongs();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Him – Web Player</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Circular+Std:wght@400;500;700;900&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="HomePage.css">
</head>
<body>

    <div class="app-shell">
        <!-- Sidebar Navigation -->
        <aside class="sidebar">
            <div class="sidebar-section">
                <div class="brand-header">
                    <div class="brand-symbol">H</div>
                    <span class="brand-title">Him</span>
                </div>
                <ul class="nav-list">
                    <li class="nav-item active">
                        <a href="home">
                            <svg viewBox="0 0 24 24"><path d="M12.5 3.247a1 1 0 0 0-1 0L4 7.577V20h4.5v-6a1 1 0 0 1 1-1h5a1 1 0 0 1 1 1v6H20V7.577l-7.5-4.33zm-2-1.732a3 3 0 0 1 3 0l7.5 4.33A2 2 0 0 1 22 7.577V21a1 1 0 0 1-1 1h-6.5a1 1 0 0 1-1-1v-5h-3v5a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V7.577a2 2 0 0 1 1-1.732l7.5-4.33z"/></svg>
                            Home
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#">
                            <svg viewBox="0 0 24 24"><path d="M10.533 1.278a9.255 9.255 0 1 0 5.864 16.326l4.673 4.674a1 1 0 0 0 1.414-1.414l-4.674-4.673a9.255 9.255 0 0 0-7.277-14.913zm0 2a7.255 7.255 0 1 1 0 14.51 7.255 7.255 0 0 1 0-14.51z"/></svg>
                            Search
                        </a>
                    </li>
                </ul>
            </div>

            <div class="sidebar-section library-section">
                <div class="library-head">
                    <span>
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M14.5 2.134a1 1 0 0 1 1 0l6 3.464a1 1 0 0 1 .5.866V21a1 1 0 0 1-1 1h-6a1 1 0 0 1-1-1V3a1 1 0 0 1 .5-.866zM16 4.732V20h4V7.041l-4-2.309zM3 22a1 1 0 0 1-1-1V3a1 1 0 0 1 .5-.866l6-3.464a1 1 0 0 1 1 0L15.5 2.134a1 1 0 0 1 .5.866V21a1 1 0 0 1-1 1H3zm6-17.268L4 7.041V20h5V4.732z"/></svg>
                        Your Library
                    </span>
                    <span style="font-size: 18px; cursor: pointer;">+</span>
                </div>
                <div class="playlist-scroll">
                    <a href="#" class="playlist-row">
                        <img src="https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=100&auto=format&fit=crop&q=60" class="playlist-thumb">
                        <div class="playlist-meta">
                            <h5>My Playlist</h5>
                            <p>Stored • <%= (songs != null) ? songs.size() : 0 %> tracks</p>
                        </div>
                    </a>
                </div>
            </div>
        </aside>

        <!-- Main Workspace -->
        <main class="workspace">
            <div class="hero-banner">
                <header class="top-glass-bar">
                    <div class="search-container">
                        <svg class="search-icon" viewBox="0 0 24 24"><path d="M10.533 1.278a9.255 9.255 0 1 0 5.864 16.326l4.673 4.674a1 1 0 0 0 1.414-1.414l-4.674-4.673a9.255 9.255 0 0 0-7.277-14.913zm0 2a7.255 7.255 0 1 1 0 14.51 7.255 7.255 0 0 1 0-14.51z"/></svg>
                        <input type="text" id="searchInput" placeholder="Filter songs or artists..." onkeyup="filterSongs()">
                    </div>

                    <a href="LoginPage.html" style="text-decoration: none;">
                        <div class="profile-btn" title="Logout: <%= email %>">
                            <div class="avatar-circle"><%= initial %></div>
                            <span><%= name %></span>
                        </div>
                    </a>
                </header>

                <div class="hero-details">
                    <span class="hero-tag">Active Playback</span>
                    <h1 class="hero-title">Welcome back, <%= name %></h1>

                </div>
            </div>

            <div class="page-content">
                <!-- Quick Selection Tiles (Top 3) -->
                <div class="quick-grid">
                    <% 
                    if (songs != null && !songs.isEmpty()) {
                        int quickCount = Math.min(songs.size(), 3);
                        for (int i = 0; i < quickCount; i++) {
                            SongSchema q = songs.get(i);
                    %>
                        <div class="quick-card" 
                             data-title="<%= escapeHtml(q.getSongName()) %>"
                             data-artist="<%= escapeHtml(q.getSingerName()) %>"
                             data-photo="<%= escapeHtml(q.getSongPhoto()) %>"
                             data-url="<%= escapeHtml(q.getPlaybackURL()) %>"
                             onclick="handleCardClick(this)">
                            <img src="<%= escapeHtml(q.getSongPhoto()) %>" class="quick-img">
                            <span><%= escapeHtml(q.getSongName()) %></span>
                            <div class="quick-play">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="#000"><path d="M8 5v14l11-7z"/></svg>
                            </div>
                        </div>
                    <% 
                        }
                    } 
                    %>
                </div>

                <div class="shelf-row">
                    <h2 class="shelf-title">Popular Tracks</h2>
                </div>

                <!-- Main Songs Grid -->
                <div class="card-grid" id="songGrid">
                    <% 
                    if (songs != null && !songs.isEmpty()) {
                        for (SongSchema song : songs) { 
                    %>
                        <div class="card song-item" 
                             data-title="<%= escapeHtml(song.getSongName()) %>"
                             data-artist="<%= escapeHtml(song.getSingerName()) %>"
                             data-photo="<%= escapeHtml(song.getSongPhoto()) %>"
                             data-url="<%= escapeHtml(song.getPlaybackURL()) %>"
                             onclick="handleCardClick(this)">
                            <div class="card-art-box">
                                <img src="<%= escapeHtml(song.getSongPhoto()) %>" alt="<%= escapeHtml(song.getSongName()) %>">
                                <div class="floating-play-btn">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="#000"><path d="M8 5v14l11-7z"/></svg>
                                </div>
                            </div>
                            <h4 class="track-title" title="<%= escapeHtml(song.getSongName()) %>"><%= escapeHtml(song.getSongName()) %></h4>
                            <p class="track-artist"><%= escapeHtml(song.getSingerName()) %></p>
                        </div>
                    <% 
                        } 
                    } else { 
                    %>
                        <p style="color: #b3b3b3;">No songs found. Visit <code>/home</code> to load tracks automatically.</p>
                    <% } %>
                </div>
            </div>
        </main>
    </div>

    <!-- Sticky Audio Control Player -->
    <footer class="player-bar">
        <audio id="globalAudio" preload="auto"></audio>

        <div class="now-playing">
            <img id="playerAlbumArt" src="https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=120&auto=format&fit=crop&q=80" class="track-img">
            <div class="track-meta">
                <h5 id="playerSongTitle">Select a track</h5>
                <p id="playerArtistName">Ready to play</p>
            </div>
            <button class="ctrl-icon" style="margin-left: 10px; color: var(--brand-green);">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
            </button>
        </div>

        <div class="playback-controls">
            <div class="transport-btns">
                <button class="ctrl-icon" onclick="seekRelative(-5)">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/></svg>
                </button>
                <button class="play-main-btn" id="playPauseBtn" onclick="togglePlayPause()">
                    <svg id="playIcon" width="18" height="18" viewBox="0 0 24 24" fill="#000"><path d="M8 5v14l11-7z"/></svg>
                </button>
                <button class="ctrl-icon" onclick="seekRelative(5)">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg>
                </button>
            </div>
            <div class="scrubber-line">
                <span id="currentTime">0:00</span>
                <div class="bar-bg" id="progressBarContainer" onclick="seekTrack(event)">
                    <div class="bar-fill" id="progressBarFill" style="width: 0%;"></div>
                </div>
                <span id="totalDuration">0:00</span>
            </div>
        </div>

        <div class="utility-box">
            <button class="ctrl-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/></svg>
            </button>
            <div class="vol-bg" onclick="setVolume(event)">
                <div class="vol-fill" id="volBarFill" style="width: 80%;"></div>
            </div>
        </div>
    </footer>

    <!-- Safe Audio Engine & Filter -->
    <script>
        const audio = document.getElementById('globalAudio');
        const playIcon = document.getElementById('playIcon');
        const songTitle = document.getElementById('playerSongTitle');
        const artistName = document.getElementById('playerArtistName');
        const albumArt = document.getElementById('playerAlbumArt');
        const currentTimeElem = document.getElementById('currentTime');
        const totalDurationElem = document.getElementById('totalDuration');
        const progressFill = document.getElementById('progressBarFill');

        // Safely reads HTML attributes without JavaScript string literal parse errors
        function handleCardClick(cardElem) {
            const title = cardElem.getAttribute('data-title');
            const artist = cardElem.getAttribute('data-artist');
            const photo = cardElem.getAttribute('data-photo');
            const url = cardElem.getAttribute('data-url');

            playTrack(title, artist, photo, url);
        }

        function playTrack(title, artist, photo, streamUrl) {
            if (!streamUrl || streamUrl.trim() === "" || streamUrl === "null") {
                console.error("Audio URL not found for track:", title);
                return;
            }

            // Update UI metadata
            songTitle.innerText = title;
            artistName.innerText = artist;
            if (photo && photo.trim() !== "") {
                albumArt.src = photo;
            }

            // Assign source and load fresh buffer
            audio.pause();
            audio.src = streamUrl;
            audio.load();

            const promise = audio.play();
            if (promise !== undefined) {
                promise.then(() => {
                    updatePlayButton(true);
                }).catch(err => {
                    // Suppress normal fast-click abort interruptions
                    if (err.name !== "AbortError") {
                        console.error("Playback error:", err);
                        updatePlayButton(false);
                    }
                });
            }
        }

        function togglePlayPause() {
            if (!audio.src) return;

            if (audio.paused) {
                audio.play().then(() => {
                    updatePlayButton(true);
                }).catch(e => console.error(e));
            } else {
                audio.pause();
                updatePlayButton(false);
            }
        }

        function updatePlayButton(isPlaying) {
            if (isPlaying) {
                playIcon.innerHTML = '<path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>'; // Pause Icon
            } else {
                playIcon.innerHTML = '<path d="M8 5v14l11-7z"/>'; // Play Icon
            }
        }

        audio.ontimeupdate = function() {
            if (audio.duration && !isNaN(audio.duration)) {
                const percent = (audio.currentTime / audio.duration) * 100;
                progressFill.style.width = percent + '%';
                currentTimeElem.innerText = formatTime(audio.currentTime);
                totalDurationElem.innerText = formatTime(audio.duration);
            }
        };

        audio.onended = function() {
            updatePlayButton(false);
            progressFill.style.width = '0%';
        };

        function seekTrack(e) {
            const container = document.getElementById('progressBarContainer');
            const rect = container.getBoundingClientRect();
            if (audio.duration && !isNaN(audio.duration)) {
                audio.currentTime = ((e.clientX - rect.left) / rect.width) * audio.duration;
            }
        }

        function seekRelative(seconds) {
            if (audio.duration && !isNaN(audio.duration)) {
                audio.currentTime = Math.min(Math.max(audio.currentTime + seconds, 0), audio.duration);
            }
        }

        function setVolume(e) {
            const bar = e.currentTarget;
            const rect = bar.getBoundingClientRect();
            const fraction = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
            audio.volume = fraction;
            document.getElementById('volBarFill').style.width = (fraction * 100) + '%';
        }

        function formatTime(secs) {
            if (isNaN(secs)) return '0:00';
            const m = Math.floor(secs / 60);
            const s = Math.floor(secs % 60);
            return m + ':' + (s < 10 ? '0' : '') + s;
        }

        function filterSongs() {
            const val = document.getElementById('searchInput').value.toLowerCase();
            document.querySelectorAll('.song-item').forEach(c => {
                const t = c.querySelector('.track-title').innerText.toLowerCase();
                const a = c.querySelector('.track-artist').innerText.toLowerCase();
                c.style.display = (t.includes(val) || a.includes(val)) ? 'flex' : 'none';
            });
        }
    </script>
</body>
</html>