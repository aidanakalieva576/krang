package com.krang.backend.Controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/public/movies")
public class PublicMovieController {

    private final JdbcTemplate jdbcTemplate;

    public PublicMovieController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    //  Popular Right Now
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

    // Watching Right Now
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

    // New Releases
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

    //  Coming Soon
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

    @GetMapping("/{id}")
public ResponseEntity<Map<String, Object>> getMovieDetails(@PathVariable Long id) {
    String sql = """
        SELECT 
            m.id,
            m.title,
            m.description,
            m.release_year,
            m.director,
            m.platform,
            m.duration_seconds,
            m.thumbnail_url,
            m.video_url,
            m.trailer_url,
            c.name AS category
        FROM movies m
        LEFT JOIN categories c ON c.id = m.category_id
        WHERE m.id = ?
    """;

    try {
        Map<String, Object> movie = jdbcTemplate.queryForMap(sql, id);
        return ResponseEntity.ok(movie);
    } catch (Exception e) {
        System.err.println("❌ Error fetching movie details: " + e.getMessage());
        return ResponseEntity.status(404).body(Map.of("error", "Movie not found"));
    }
}



// 🎬 Просмотр фильма или сериала
@GetMapping("/{id}/watch")
public ResponseEntity<?> getWatchData(@PathVariable Long id) {
    try {

        String movieSql = """
            SELECT 
                m.id, 
                m.title, 
                m.type, 
                m.video_url,
                c.name AS category
            FROM movies m
            LEFT JOIN categories c ON c.id = m.category_id
            WHERE m.id = ?
        """;

        Map<String, Object> movie = jdbcTemplate.queryForMap(movieSql, id);
        String type = (String) movie.get("type");


        if ("SERIES".equalsIgnoreCase(type)) {
            String episodesSql = """
                SELECT 
                    e.id,
                    e.title,
                    e.season_number,
                    e.episode_number,
                    e.video_url,
                    e.duration_seconds
                FROM episodes e
                WHERE e.movie_id = ?
                ORDER BY e.season_number, e.episode_number
            """;

            List<Map<String, Object>> episodes = jdbcTemplate.queryForList(episodesSql, id);
            return ResponseEntity.ok(Map.of(
                "id", movie.get("id"),
                "title", movie.get("title"),
                "type", type,
                "category", movie.get("category"),
                "episodes", episodes
            ));
        }

        return ResponseEntity.ok(Map.of(
            "id", movie.get("id"),
            "title", movie.get("title"),
            "type", type,
            "category", movie.get("category"),
            "video_url", movie.get("video_url")
        ));

    } catch (Exception e) {
        System.err.println("❌ Error loading watch data: " + e.getMessage());
        return ResponseEntity.status(404).body(Map.of("error", "Movie not found or no video available"));
    }
}




}
