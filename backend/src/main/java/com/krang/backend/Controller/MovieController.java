package com.krang.backend.Controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.model.Movie;
import com.krang.backend.repository.MovieRepository;

@RestController
@RequestMapping("/api/admin/movies")
public class MovieController {

    private final MovieRepository movieRepository;
    private final JdbcTemplate jdbcTemplate;

    public MovieController(MovieRepository movieRepository, JdbcTemplate jdbcTemplate) {
        this.movieRepository = movieRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    // 📥 Получить все фильмы (с названием категории, а не ID)
    @GetMapping
    public List<Map<String, Object>> getAllMovies() {
        String sql = """
            SELECT m.id,
                   m.title,
                   c.name AS category,
                   m.thumbnail_url,
                   m.is_hidden
            FROM movies m
            LEFT JOIN categories c ON m.category_id = c.id
        """;

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Map<String, Object> row = new HashMap<>();
            row.put("id", rs.getLong("id"));
            row.put("title", rs.getString("title"));
            row.put("category", rs.getString("category")); // теперь название категории
            row.put("thumbnail_url", rs.getString("thumbnail_url"));
            row.put("is_hidden", rs.getBoolean("is_hidden"));
            return row;
        });
    }

    // 🔒 Скрыть фильм
    @PutMapping("/{id}/hide")
    public ResponseEntity<?> hideMovie(@PathVariable Long id) {
        Optional<Movie> movieOpt = movieRepository.findById(id);
        if (movieOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Movie movie = movieOpt.get();
        movie.setIs_hidden(true);
        movieRepository.save(movie);
        return ResponseEntity.ok(movie);
    }

    // 🔓 Показать фильм
    @PutMapping("/{id}/unhide")
    public ResponseEntity<?> unhideMovie(@PathVariable Long id) {
        Optional<Movie> movieOpt = movieRepository.findById(id);
        if (movieOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Movie movie = movieOpt.get();
        movie.setIs_hidden(false);
        movieRepository.save(movie);
        return ResponseEntity.ok(movie);
    }
}
