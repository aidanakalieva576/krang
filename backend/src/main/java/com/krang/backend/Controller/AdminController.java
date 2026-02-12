package com.krang.backend.Controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.krang.backend.dto.RegisterRequest;
import com.krang.backend.model.Category;
import com.krang.backend.model.Movie;
import com.krang.backend.model.MovieRating;
import com.krang.backend.model.User;
import com.krang.backend.repository.CategoryRepository;
import com.krang.backend.repository.MovieRatingRepository;
import com.krang.backend.repository.MovieRepository;
import com.krang.backend.repository.UserRepository;
import com.krang.backend.service.AdminService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final MovieRepository movieRepository;
    private final MovieRatingRepository movieRatingRepository;
    private final Cloudinary cloudinary;


    @PostMapping("/register")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> registerAdmin(@Valid @RequestBody RegisterRequest req) {
        User created = adminService.createAdmin(req);

        return ResponseEntity.status(201).body(
                Map.of(
                        "id", created.getId(),
                        "username", created.getUsername(),
                        "email", created.getEmail(),
                        "role", created.getRole()
                )
        );
    }


    @GetMapping("/users")
    public ResponseEntity<List<Map<String, Object>>> getAllUsers() {
        List<Map<String, Object>> users = userRepository.findByRole("USER").stream()
                .map(user -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("username", user.getUsername());
                    map.put("email", user.getEmail());
                    map.put("is_active", user.isActive());
                    map.put("avatar_url", user.getAvatarUrl());
                    return map;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(users);
    }


    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteUserByEmail(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (email == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
        }

        boolean deleted = adminService.deleteUserByEmail(email);

        if (deleted) {
            return ResponseEntity.ok(Map.of(
                    "message", "User with email " + email + " deleted successfully"
            ));
        } else {
            return ResponseEntity.status(404).body(Map.of(
                    "error", "User with email " + email + " not found"
            ));
        }
    }


    @PostMapping("/add_movie")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> addMovie(
            @RequestParam("title") String title,
            @RequestParam("description") String description,
            @RequestParam("release_year") int releaseYear,
            @RequestParam("type") String type,
            @RequestParam("category_id") Long categoryId,
            @RequestParam("platform") String platform,
            @RequestParam("director") String director,
            @RequestParam("rating") int rating,
            @RequestParam("image") MultipartFile image,
            Authentication authentication
    ) {
        try {
            //  Cloudinary
            Map uploadResult = cloudinary.uploader().upload(image.getBytes(), ObjectUtils.emptyMap());
            String imageUrl = uploadResult.get("secure_url").toString();

            // Получаем  админа
            String username = authentication.getName();
            Optional<User> userOpt = userRepository.findByUsername(username);
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "User not found"));
            }
            User user = userOpt.get();


            Optional<Category> categoryOpt = categoryRepository.findById(categoryId);
            if (categoryOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", "Invalid category ID"));
            }


            Movie movie = new Movie();
            movie.setTitle(title);
            movie.setDescription(description);
            movie.setReleaseYear(releaseYear);
            movie.setType(type.toUpperCase());
            movie.setCategory(categoryOpt.get());
            movie.setThumbnailUrl(imageUrl);
            movie.setDirector(director);
            movie.setPlatform(platform);
            movie.setCreatedBy(user);
            movie.setHidden(false);
            movie.setUpdatedAt(java.time.Instant.now());

            movieRepository.save(movie);


            if (rating >= 1 && rating <= 10) {
                MovieRating movieRating = new MovieRating();
                movieRating.setMovie(movie);
                movieRating.setUser(user);
                movieRating.setRating((short) rating); // ← Приводим int → short
                movieRatingRepository.save(movieRating);
            }


            return ResponseEntity.ok(Map.of(
                    "message", "Movie added successfully",
                    "movie_id", movie.getId(),
                    "thumbnail_url", imageUrl
            ));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }
}
