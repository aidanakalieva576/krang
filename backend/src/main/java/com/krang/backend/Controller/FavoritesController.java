package com.krang.backend.Controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import com.krang.backend.security.JwtUtil;

@RestController
@RequestMapping("/api/user/favorites")
public class FavoritesController {

    private final JdbcTemplate jdbcTemplate;
    private final JwtUtil jwtUtil;

    public FavoritesController(JdbcTemplate jdbcTemplate, JwtUtil jwtUtil) {
        this.jdbcTemplate = jdbcTemplate;
        this.jwtUtil = jwtUtil;
    }

    private Long getUserIdFromToken(String token) {
        if (token == null || !token.startsWith("Bearer ")) return null;
        String jwt = token.replace("Bearer ", "").trim();

        if (!jwtUtil.validateToken(jwt)) return null;

        String username = jwtUtil.extractUsername(jwt);

        // достаём user_id по username
        return jdbcTemplate.queryForObject(
            "SELECT id FROM users WHERE LOWER(username)=LOWER(?)",
            Long.class,
            username
        );
    }

    private Long getOrCreateFavoritesCollection(Long userId) {
        // пробуем найти
        List<Long> ids = jdbcTemplate.query(
            "SELECT id FROM collections WHERE user_id=? AND name='Favorites' LIMIT 1",
            (rs, rowNum) -> rs.getLong("id"),
            userId
        );

        if (!ids.isEmpty()) return ids.get(0);

        // создаём
        jdbcTemplate.update(
            "INSERT INTO collections(user_id, name, description) VALUES (?, 'Favorites', 'User favorites')",
            userId
        );

        // снова читаем id (быстро и просто)
        return jdbcTemplate.queryForObject(
            "SELECT id FROM collections WHERE user_id=? AND name='Favorites' LIMIT 1",
            Long.class,
            userId
        );
    }

    @PostMapping("/{movieId}")
    public ResponseEntity<?> addToFavorites(
            @RequestHeader(value = "Authorization", required = false) String token,
            @PathVariable Long movieId
    ) {
        Long userId = getUserIdFromToken(token);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));

        // проверим что фильм существует и не скрыт (если хочешь)
        Integer exists = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM movies WHERE id=? AND is_hidden=false",
            Integer.class,
            movieId
        );
        if (exists == null || exists == 0) return ResponseEntity.status(404).body(Map.of("error", "Movie not found"));

        Long collectionId = getOrCreateFavoritesCollection(userId);

        // insert (если уже есть — ничего не делаем)
        jdbcTemplate.update("""
            INSERT INTO collection_items(collection_id, movie_id)
            VALUES (?, ?)
            ON CONFLICT (collection_id, movie_id) DO NOTHING
        """, collectionId, movieId);

        return ResponseEntity.ok(Map.of("message", "Added to favorites"));
    }

    @DeleteMapping("/{movieId}")
    public ResponseEntity<?> removeFromFavorites(
            @RequestHeader(value = "Authorization", required = false) String token,
            @PathVariable Long movieId
    ) {
        Long userId = getUserIdFromToken(token);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));

        Long collectionId = getOrCreateFavoritesCollection(userId);

        int deleted = jdbcTemplate.update(
            "DELETE FROM collection_items WHERE collection_id=? AND movie_id=?",
            collectionId, movieId
        );

        return ResponseEntity.ok(Map.of(
            "message", deleted > 0 ? "Removed from favorites" : "Was not in favorites"
        ));
    }

    @GetMapping
    public ResponseEntity<?> getFavorites(
            @RequestHeader(value = "Authorization", required = false) String token
    ) {
        Long userId = getUserIdFromToken(token);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));

        Long collectionId = getOrCreateFavoritesCollection(userId);

        String sql = """
            SELECT m.id, m.title, c.name AS category, m.thumbnail_url
            FROM collection_items ci
            JOIN movies m ON m.id = ci.movie_id
            LEFT JOIN categories c ON c.id = m.category_id
            WHERE ci.collection_id = ?
              AND m.is_hidden = false
            ORDER BY ci.added_at DESC
        """;

        List<Map<String, Object>> movies = jdbcTemplate.queryForList(sql, collectionId);
        return ResponseEntity.ok(movies);
    }

    @GetMapping("/{movieId}/exists")
    public ResponseEntity<?> isFavorite(
            @RequestHeader(value = "Authorization", required = false) String token,
            @PathVariable Long movieId
    ) {
        Long userId = getUserIdFromToken(token);
        if (userId == null) return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));

        Long collectionId = getOrCreateFavoritesCollection(userId);

        Integer cnt = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM collection_items WHERE collection_id=? AND movie_id=?",
            Integer.class,
            collectionId,
            movieId
        );

        return ResponseEntity.ok(Map.of("favorite", cnt != null && cnt > 0));
    }
}
