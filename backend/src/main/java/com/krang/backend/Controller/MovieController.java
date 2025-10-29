package com.krang.backend.Controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.dto.CreateMovieRequest;
import com.krang.backend.model.Movie;
import com.krang.backend.repository.MovieRepository;

import io.swagger.v3.oas.annotations.parameters.RequestBody;

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

    @PostMapping
public ResponseEntity<?> createMovie(@RequestBody CreateMovieRequest request) {
    try {
        // 🔹 1. Найти или создать категорию
        String categoryName = request.getCategory().trim();

        String sqlFindCategory = "SELECT id FROM categories WHERE LOWER(name) = LOWER(?)";
        Long categoryId = null;

        try {
            categoryId = jdbcTemplate.queryForObject(sqlFindCategory, Long.class, categoryName);
        } catch (Exception e) {
            // категории нет — создаём новую
            String sqlInsertCategory = "INSERT INTO categories (name) VALUES (?) RETURNING id";
            categoryId = jdbcTemplate.queryForObject(sqlInsertCategory, Long.class, categoryName);
            System.out.println("🆕 Created new category: " + categoryName + " (id=" + categoryId + ")");
        }

        // 🔹 2. Вставляем фильм с этим category_id
        String sqlInsertMovie = """
            INSERT INTO movies (
                title, description, release_year, type, category_id,
                thumbnail_url, video_url, trailer_url, is_hidden
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, false)
            RETURNING id
        """;

        Long movieId = jdbcTemplate.queryForObject(sqlInsertMovie, Long.class,
            request.getTitle(),
            request.getDescription(),
            request.getReleaseYear(),
            request.getType(),
            categoryId,
            request.getThumbnailUrl(),
            request.getVideoUrl(),
            request.getTrailerUrl()
        );

        // 🔹 3. Возвращаем успешный ответ
        HashMap<String, Object> response = new HashMap<>();
        response.put("id", movieId);
        response.put("category_id", categoryId);
        response.put("message", "✅ Movie created successfully!");

        return ResponseEntity.ok(response);

    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.internalServerError()
                .body("❌ Error creating movie: " + e.getMessage());
    }
}



}
