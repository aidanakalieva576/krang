package com.krang.backend.Controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/public/movies")
public class PublicMovieController {

    private final JdbcTemplate jdbcTemplate;

    public PublicMovieController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
public ResponseEntity<List<Map<String, Object>>> getAllMovies(
        @RequestParam(required = false) String type
) {
    String sql = """
        SELECT m.id, m.title, c.name AS category, m.thumbnail_url
        FROM movies m
        JOIN categories c ON c.id = m.category_id
        WHERE 1=1
    """;

    List<Object> params = new java.util.ArrayList<>();

    if (type != null && !type.isBlank() && !"All".equalsIgnoreCase(type)) {
        sql += " AND UPPER(m.type) = ? ";
        params.add(type.trim().toUpperCase());
    }

    sql += " ORDER BY m.created_at DESC LIMIT 50 ";

    return ResponseEntity.ok(jdbcTemplate.queryForList(sql, params.toArray()));
}


    //  Popular Right Now
    @GetMapping("/popular")
public ResponseEntity<List<Map<String, Object>>> getPopularMovies(
        @RequestParam(required = false) String type
) {
    String sql = """
        SELECT m.id, m.title, c.name AS category, m.thumbnail_url
        FROM movies m
        JOIN categories c ON c.id = m.category_id
        WHERE 1=1
    """;

    List<Object> params = new java.util.ArrayList<>();

    if (type != null && !type.isBlank() && !"All".equalsIgnoreCase(type)) {
        sql += " AND UPPER(m.type) = ? ";
        params.add(type.trim().toUpperCase());
    }

    sql += " ORDER BY m.id DESC LIMIT 10 ";

    List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql, params.toArray());
    return ResponseEntity.ok(movies);
}


    // Watching Right Now
    @GetMapping("/watching-now")
public ResponseEntity<List<Map<String, Object>>> getWatchingNow(
        @RequestParam(required = false) String type
) {
    String sql = """
        SELECT m.id, m.title, c.name AS category, m.thumbnail_url
        FROM movies m
        JOIN categories c ON c.id = m.category_id
        WHERE 1=1
    """;

    List<Object> params = new java.util.ArrayList<>();

    if (type != null && !type.isBlank() && !"All".equalsIgnoreCase(type)) {
        sql += " AND UPPER(m.type) = ? ";
        params.add(type.trim().toUpperCase());
    }

    sql += " ORDER BY random() LIMIT 10 ";

    List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql, params.toArray());
    return ResponseEntity.ok(movies);
}


    // New Releases
   @GetMapping("/new")
public ResponseEntity<List<Map<String, Object>>> getNewMovies(
        @RequestParam(required = false) String type
) {
    String sql = """
        SELECT m.id, m.title, c.name AS category, m.thumbnail_url, m.created_at
        FROM movies m
        JOIN categories c ON c.id = m.category_id
        WHERE m.created_at >= now() - INTERVAL '30 days'
    """;

    List<Object> params = new java.util.ArrayList<>();

    if (type != null && !type.isBlank() && !"All".equalsIgnoreCase(type)) {
        sql += " AND UPPER(m.type) = ? ";
        params.add(type.trim().toUpperCase());
    }

    sql += " ORDER BY m.created_at DESC LIMIT 10 ";

    List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql, params.toArray());
    return ResponseEntity.ok(movies);
}


    //  Coming Soon
    @GetMapping("/coming-soon")
public ResponseEntity<List<Map<String, Object>>> getComingSoonMovies(
        @RequestParam(required = false) String type
) {
    String sql = """
        SELECT m.id, m.title, c.name AS category, m.thumbnail_url
        FROM movies m
        JOIN categories c ON c.id = m.category_id
        LEFT JOIN episodes e ON e.movie_id = m.id
        WHERE e.id IS NULL
    """;

    List<Object> params = new java.util.ArrayList<>();

    if (type != null && !type.isBlank() && !"All".equalsIgnoreCase(type)) {
        sql += " AND UPPER(m.type) = ? ";
        params.add(type.trim().toUpperCase());
    }

    sql += " ORDER BY m.created_at DESC LIMIT 10 ";

    List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql, params.toArray());
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
