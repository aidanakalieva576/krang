package com.krang.backend.Controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.apache.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.dto.CreateMovieRequest;
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
        movie.setHidden(true);
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
        movie.setHidden(false);
        movieRepository.save(movie);
        return ResponseEntity.ok(movie);
    }

   @PostMapping
public ResponseEntity<?> createMovie(@RequestBody CreateMovieRequest request) {
    try {
        // 🔹 Проверяем, что categoryId передан
        if (request.getCategoryId() == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Category ID is required"));
        }

        Long categoryId = request.getCategoryId();

        // 🔹 Проверяем, что категория существует
        String sqlFindCategory = "SELECT COUNT(*) FROM categories WHERE id = ?";
        Integer exists = jdbcTemplate.queryForObject(sqlFindCategory, Integer.class, categoryId);
        if (exists == null || exists == 0) {
            return ResponseEntity.status(HttpStatus.SC_BAD_REQUEST)
                    .body(Map.of("error", "Category with id " + categoryId + " not found"));
        }

        // 🔹 Добавляем фильм
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

        // 🔹 Ответ
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

// 🔹 Получить информацию о конкретном фильме
    @GetMapping("/{id}")
    public ResponseEntity<?> getMovieById(@PathVariable Long id) {
        Optional<Movie> optionalMovie = movieRepository.findById(id);
        if (optionalMovie.isEmpty()) {
            return ResponseEntity.status(HttpStatus.SC_NOT_FOUND)
                    .body(Map.of("error", "Movie not found"));
        }

        Movie movie = optionalMovie.get();

        Map<String, Object> movieData = new HashMap<>();
        movieData.put("id", movie.getId());
        movieData.put("title", movie.getTitle());
        movieData.put("description", movie.getDescription());
        movieData.put("releaseYear", movie.getReleaseYear());
        movieData.put("type", movie.getType());
        movieData.put("platform", movie.getPlatform());
        movieData.put("director", movie.getDirector());
        movieData.put("thumbnailUrl", movie.getThumbnailUrl());
        movieData.put("videoUrl", movie.getVideoUrl());
        movieData.put("trailerUrl", movie.getTrailerUrl());
        movieData.put("category", movie.getCategory() != null ? movie.getCategory().getName() : null);
        movieData.put("durationSeconds", movie.getDurationSeconds());
        movieData.put("isHidden", movie.isHidden());
        movieData.put("createdAt", movie.getCreatedAt());
        movieData.put("updatedAt", movie.getUpdatedAt());

        return ResponseEntity.ok(movieData);
    }




}
