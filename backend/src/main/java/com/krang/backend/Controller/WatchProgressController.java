package com.krang.backend.Controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user/watch-progress")
public class WatchProgressController {

    private final JdbcTemplate jdbcTemplate;

    public WatchProgressController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private long getUserId(Authentication auth) {
        if (auth == null) {
            System.out.println("❌ auth == null (no authentication in controller)");
            throw new RuntimeException("Unauthenticated");
        }

        String username = auth.getName();
        System.out.println("✅ getUserId: username=" + username);

        Long id = jdbcTemplate.queryForObject(
                "SELECT id FROM users WHERE username = ?",
                Long.class,
                username
        );

        System.out.println("✅ getUserId: id=" + id);
        if (id == null) throw new RuntimeException("User not found: " + username);
        return id;
    }

    @GetMapping("/{movieId}")
    public ResponseEntity<?> getProgress(@PathVariable Long movieId,
                                         @RequestParam(required = false) Long episodeId,
                                         Authentication authentication) {

        long userId = getUserId(authentication);

        String sql = """
            SELECT current_time_sec
            FROM watch_progress
            WHERE user_id = ? AND movie_id = ?
        """;

        int sec = 0;
        try {
            Integer val = jdbcTemplate.queryForObject(sql, Integer.class, userId, movieId);
            if (val != null) sec = val;
        } catch (EmptyResultDataAccessException ignored) {}

        Map<String, Object> resp = new HashMap<>();
        resp.put("movie_id", movieId);
        resp.put("episode_id", episodeId); // null ок
        resp.put("current_time_sec", sec);

        return ResponseEntity.ok(resp);
    }

    @PostMapping
    public ResponseEntity<?> saveProgress(@RequestBody Map<String, Object> body,
                                          Authentication authentication) {

        long userId = getUserId(authentication);

        Long movieId = ((Number) body.get("movie_id")).longValue();
        Object episodeObj = body.get("episode_id");
        Long episodeId = (episodeObj == null) ? null : ((Number) episodeObj).longValue();
        int current = ((Number) body.get("current_time_sec")).intValue();
        if (current < 0) current = 0;

        String upsert = """
            INSERT INTO watch_progress (user_id, movie_id, episode_id, current_time_sec)
            VALUES (?, ?, ?, ?)
            ON CONFLICT (user_id, movie_id)
            DO UPDATE SET
                episode_id = EXCLUDED.episode_id,
                current_time_sec = EXCLUDED.current_time_sec,
                updated_at = now()
        """;

        jdbcTemplate.update(upsert, userId, movieId, episodeId, current);

        Map<String, Object> resp = new HashMap<>();
        resp.put("ok", true);
        resp.put("movie_id", movieId);
        resp.put("episode_id", episodeId); // null ок
        resp.put("current_time_sec", current);

        return ResponseEntity.ok(resp);
    }
    @GetMapping("/continue-watching")
    public ResponseEntity<?> continueWatching(Authentication auth) {
        long userId = getUserId(auth);

        String sql = """
        SELECT
          m.id as movie_id,
          m.title,
          m.thumbnail_url,
          m.video_url,
          m.duration_seconds,
          wp.current_time_sec,
          wp.updated_at
        FROM watch_progress wp
        JOIN movies m ON m.id = wp.movie_id
        WHERE wp.user_id = ?
          AND wp.current_time_sec > 0
        ORDER BY wp.updated_at DESC
    """;

        return ResponseEntity.ok(jdbcTemplate.queryForList(sql, userId));
    }


}
