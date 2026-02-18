package com.krang.backend.Controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.dto.AdminProfileResponse;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;

@RestController
@RequestMapping("/api/admin")
public class AdminProfileController {

    private final UserRepository userRepository;

    public AdminProfileController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // GET /api/admin/me
    @GetMapping("/me")
    public ResponseEntity<?> me(Authentication auth) {
        if (auth == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        // Обычно auth.getName() = email/username (зависит как ты кладешь subject в JWT)
        String login = auth.getName();

        User u = userRepository.findByEmail(login)
                .orElseGet(() -> userRepository.findByUsername(login).orElse(null));

        if (u == null) {
            return ResponseEntity.status(404).body(Map.of("error", "User not found for: " + login));
        }

        if (u.getRole() == null || !u.getRole().equalsIgnoreCase("ADMIN")) {
            return ResponseEntity.status(403).body(Map.of("error", "Forbidden"));
        }

        return ResponseEntity.ok(new AdminProfileResponse(
                u.getId(),
                u.getUsername(),
                u.getEmail(),
                u.getRole()
        ));
    }
}
