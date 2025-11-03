package com.krang.backend.Controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/public/movies")
public class PublicMovieController {

    private final JdbcTemplate jdbcTemplate;

    public PublicMovieController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // ✅ 1. Popular Right Now
    @GetMapping("/popular")
    public ResponseEntity<List<Map<String, Object>>> getPopularMovies() {
        String sql = """
            SELECT m.id, m.title, c.name AS category, m.thumbnail_url
            FROM movies m
            JOIN watch_logs wl ON wl.movie_id = m.id
            JOIN categories c ON c.id = m.category_id
            WHERE wl.watched_at >= now() - INTERVAL '7 days'
            GROUP BY m.id, c.name
            ORDER BY SUM(wl.watch_time_sec) DESC
            LIMIT 10
        """;

        List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql);
        return ResponseEntity.ok(movies);
    }

    // ✅ 2. Watching Right Now (PLAY события за последние 5 минут)
    @GetMapping("/watching-now")
    public ResponseEntity<List<Map<String, Object>>> getWatchingNow() {
        String sql = """
            SELECT DISTINCT m.id, m.title, c.name AS category, m.thumbnail_url
            FROM movies m
            JOIN watch_logs wl ON wl.movie_id = m.id
            JOIN categories c ON c.id = m.category_id
            WHERE wl.event_type = 'PLAY'
              AND wl.watched_at >= now() - INTERVAL '5 minutes'
            LIMIT 10
        """;

        List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql);
        return ResponseEntity.ok(movies);
    }

    // ✅ 3. New Releases (фильмы добавленные за последние 30 дней)
    @GetMapping("/new")
    public ResponseEntity<List<Map<String, Object>>> getNewMovies() {
        String sql = """
            SELECT m.id, m.title, c.name AS category, m.thumbnail_url, m.created_at
            FROM movies m
            JOIN categories c ON c.id = m.category_id
            WHERE m.created_at >= now() - INTERVAL '30 days'
            ORDER BY m.created_at DESC
            LIMIT 10
        """;

        List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql);
        return ResponseEntity.ok(movies);
    }

    // ✅ 4. Coming Soon (фильмы без эпизодов)
    @GetMapping("/coming-soon")
    public ResponseEntity<List<Map<String, Object>>> getComingSoonMovies() {
        String sql = """
            SELECT m.id, m.title, c.name AS category, m.thumbnail_url
            FROM movies m
            JOIN categories c ON c.id = m.category_id
            LEFT JOIN episodes e ON e.movie_id = m.id
            WHERE e.id IS NULL
            ORDER BY m.created_at DESC
            LIMIT 10
        """;

        List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql);
        return ResponseEntity.ok(movies);
    }
}
