package com.krang.backend.Controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

@RestController
@RequestMapping("/api/admin")
public class AdminMovieVideoController {

    private final JdbcTemplate jdbcTemplate;
    private final Cloudinary cloudinary;

    public AdminMovieVideoController(JdbcTemplate jdbcTemplate, Cloudinary cloudinary) {
        this.jdbcTemplate = jdbcTemplate;
        this.cloudinary = cloudinary;
    }

    /**
     * Upload videos for existing movie/series.
     * MOVIE  -> only 1 file allowed, replace existing or insert new.
     * SERIES -> multiple files allowed, insert each as new episode (auto episode_number).
     */
    @PostMapping(
            value = "/movies/{id}/videos",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<?> uploadVideos(
            @PathVariable("id") Long movieId,
            @RequestParam("videos") MultipartFile[] videos,
            @RequestParam(value = "seasonNumber", required = false, defaultValue = "1") Integer seasonNumber
    ) {
        try {
            System.out.println(">>> uploadVideos called, files=" + videos.length + ", movieId=" + movieId);
            if (videos == null || videos.length == 0) {
                return ResponseEntity.badRequest().body(Map.of("error", "No files provided (videos)"));
            }

            // 1) Check movie exists + type
            String type = jdbcTemplate.queryForObject(
                    "SELECT type FROM movies WHERE id = ?",
                    String.class,
                    movieId
            );
            if (type == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "Movie not found: " + movieId));
            }
            String normalizedType = type.trim().toUpperCase(); // "MOVIE" or "SERIES"

            // 2) MOVIE rules: only 1 file
            if ("MOVIE".equals(normalizedType) && videos.length != 1) {
                return ResponseEntity.badRequest().body(Map.of(
                        "error", "For MOVIE you must upload exactly 1 video file"
                ));
            }

            // 3) Upload to Cloudinary and update DB
            List<Map<String, Object>> uploaded = new ArrayList<>();

            if ("MOVIE".equals(normalizedType)) {
                MultipartFile file = videos[0];

                String videoUrl = uploadToCloudinaryVideo(file, movieId);

                // Do we already have an episode row for this movie?
                Long existingEpisodeId = jdbcTemplate.query(
                        "SELECT id FROM episodes WHERE movie_id = ? ORDER BY id LIMIT 1",
                        rs -> rs.next() ? rs.getLong("id") : null,
                        movieId
                );

                if (existingEpisodeId == null) {
                    // Insert new "single episode" for movie (episode 1, season 1)
                    Long newId = jdbcTemplate.queryForObject("""
                        INSERT INTO episodes (movie_id, title, description, episode_number, season_number, duration_seconds, video_url, release_date, created_at, updated_at)
                        VALUES (?, ?, NULL, 1, 1, NULL, ?, NULL, now(), now())
                        RETURNING id
                    """, Long.class,
                            movieId,
                            safeTitleFromFilename(file.getOriginalFilename(), "Movie video"),
                            videoUrl
                    );

                    // Optional: keep movies.video_url in sync (if you use it elsewhere)
                    jdbcTemplate.update("UPDATE movies SET video_url = ?, updated_at = now() WHERE id = ?", videoUrl, movieId);

                    uploaded.add(Map.of("episodeId", newId, "videoUrl", videoUrl, "replaced", false));
                } else {
                    // Replace existing
                    jdbcTemplate.update("""
                        UPDATE episodes
                        SET video_url = ?, updated_at = now()
                        WHERE id = ?
                    """, videoUrl, existingEpisodeId);

                    jdbcTemplate.update("UPDATE movies SET video_url = ?, updated_at = now() WHERE id = ?", videoUrl, movieId);

                    uploaded.add(Map.of("episodeId", existingEpisodeId, "videoUrl", videoUrl, "replaced", true));
                }

            } else if ("SERIES".equals(normalizedType)) {
                // SERIES: allow many; auto episode_number continuation per season
                Integer maxEpisode = jdbcTemplate.queryForObject(
                        "SELECT COALESCE(MAX(episode_number), 0) FROM episodes WHERE movie_id = ? AND season_number = ?",
                        Integer.class,
                        movieId,
                        seasonNumber
                );
                int nextEpisode = (maxEpisode == null ? 1 : maxEpisode + 1);

                for (MultipartFile file : videos) {
                    String videoUrl = uploadToCloudinaryVideo(file, movieId);

                    Long episodeId = jdbcTemplate.queryForObject("""
                        INSERT INTO episodes (movie_id, title, description, episode_number, season_number, duration_seconds, video_url, release_date, created_at, updated_at)
                        VALUES (?, ?, NULL, ?, ?, NULL, ?, NULL, now(), now())
                        RETURNING id
                    """, Long.class,
                            movieId,
                            safeTitleFromFilename(file.getOriginalFilename(), "Episode " + nextEpisode),
                            nextEpisode,
                            seasonNumber,
                            videoUrl
                    );

                    uploaded.add(Map.of(
                            "episodeId", episodeId,
                            "seasonNumber", seasonNumber,
                            "episodeNumber", nextEpisode,
                            "videoUrl", videoUrl
                    ));
                    nextEpisode++;
                }

            } else {
                return ResponseEntity.badRequest().body(Map.of("error", "Unknown type: " + type));
            }

            return ResponseEntity.ok(Map.of(
                    "movieId", movieId,
                    "type", normalizedType,
                    "uploaded", uploaded
            ));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of(
                    "error", "Upload failed: " + e.getMessage()
            ));
        }
    }

private String uploadToCloudinaryVideo(MultipartFile file, Long movieId) throws Exception {
    Map<?, ?> result = cloudinary.uploader().uploadLarge(
            file.getInputStream(),
            ObjectUtils.asMap(
                    "resource_type", "video",
                    "folder", "movies/" + movieId,
                    "chunk_size", 6000000 // 6MB чанки (можно 5-10MB)
            )
    );

    Object secureUrl = result.get("secure_url");
    if (secureUrl == null) throw new RuntimeException("Cloudinary secure_url is null");
    return secureUrl.toString();
}

    private String safeTitleFromFilename(String originalName, String fallback) {
        if (originalName == null || originalName.isBlank()) return fallback;
        // remove extension
        int dot = originalName.lastIndexOf('.');
        String base = (dot > 0) ? originalName.substring(0, dot) : originalName;
        base = base.trim();
        return base.isEmpty() ? fallback : base;
    }
}
