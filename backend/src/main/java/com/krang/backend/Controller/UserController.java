package com.krang.backend.Controller;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.dto.ChangePasswordRequest;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;
import com.krang.backend.security.JwtUtil;
import com.krang.backend.service.UserService;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/users")

public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private UserService userService; // ✅ добавь это

    // =====================================================
    // 🔹 1. Получить профиль текущего пользователя
    // =====================================================
    @GetMapping("/me")
    public ResponseEntity<?> getMyProfile(@AuthenticationPrincipal UserDetails userDetails) {
        var user = userRepository.findByUsername(userDetails.getUsername()).orElse(null);
        if (user == null) {
            return ResponseEntity.status(404).body(Map.of("error", "User not found"));
        }

        Map<String, Object> data = new java.util.HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("email", user.getEmail());
        data.put("avatar", user.getAvatarUrl()); // даже если null — не вылетит
        data.put("role", user.getRole());

        return ResponseEntity.ok(data);
    }


    // =====================================================
    // 🔹 2. Обновить данные пользователя (email, username, пароль, аватар)
    // =====================================================

@PutMapping("/edit")
public ResponseEntity<?> editProfile(
        @RequestHeader("Authorization") String token,
        @RequestBody Map<String, String> updates
) {
    try {
        System.out.println("🔹 TOKEN = " + token);
        String jwt = token.replace("Bearer ", "");
        String username = jwtUtil.extractUsername(jwt);
        System.out.println("🔹 Extracted username from JWT = " + username);
        System.out.println("🔹 Token valid? " + jwtUtil.validateToken(jwt));

        User user = userRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        boolean updated = false;

        // --- Изменение email ---
        if (updates.containsKey("email")) {
            String newEmail = updates.get("email").trim().toLowerCase();
            if (!newEmail.isEmpty() && !newEmail.equals(user.getEmail())) {
                if (userRepository.existsByEmail(newEmail)) {
                    return ResponseEntity.badRequest()
                            .body(Map.of("error", "Email is already taken"));
                }
                user.setEmail(newEmail);
                updated = true;
            }
        }

        // --- Изменение username ---
        if (updates.containsKey("username")) {
            String newUsername = updates.get("username").trim();
            if (!newUsername.isEmpty() && !newUsername.equals(user.getUsername())) {
                if (userRepository.existsByUsername(newUsername)) {
                    return ResponseEntity.badRequest()
                            .body(Map.of("error", "Username is already taken"));
                }
                user.setUsername(newUsername);
                updated = true;
            }
        }

        // --- Изменение avatarUrl ---
        if (updates.containsKey("avatarUrl")) {
            String newAvatar = updates.get("avatarUrl").trim();
            if (!newAvatar.isEmpty() && !newAvatar.equals(user.getAvatarUrl())) {
                user.setAvatarUrl(newAvatar);
                updated = true;
            }
        }

        if (updated) {
            user.setUpdatedAt(Instant.now());
            userRepository.save(user);
        }

        // --- генерируем новый токен (если нужно) ---
        // Убедись, что метод jwtUtil.generateToken существует с такой сигнатурой.
        String newToken = jwtUtil.generateToken(user.getUsername(), user.getRole());

        // --- Формируем ответ безопасно (HashMap допускает null значения) ---
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Profile updated successfully");
        response.put("token", newToken);
        response.put("username", user.getUsername());
        response.put("email", user.getEmail());
        response.put("avatarUrl", user.getAvatarUrl());

        return ResponseEntity.ok(response);

    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
    } catch (Exception e) {
        e.printStackTrace();
        return ResponseEntity.status(500).body(Map.of("error", "Internal server error"));
    }
}



    // =====================================================
    // 🔹 3. Удалить аккаунт
    // =====================================================
    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteAccount(@RequestHeader("Authorization") String token) {
        try {
            String jwt = token.replace("Bearer ", "");
            String username = jwtUtil.extractUsername(jwt);

            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));

            userRepository.delete(user);
            return ResponseEntity.ok(Map.of("message", "Account deleted successfully"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(401).body(Map.of("error", "Invalid or expired token"));
        }
    }



    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request,
                                            HttpServletRequest httpRequest) {
        try {
            String authHeader = httpRequest.getHeader("Authorization");
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(401).body(Map.of("error", "Missing token"));
            }

            String token = authHeader.substring(7);
            if (!jwtUtil.validateToken(token)) {
                return ResponseEntity.status(401).body(Map.of("error", "Invalid or expired token"));
            }

            String username = jwtUtil.extractUsername(token);
            userService.changePassword(username, request.getOldPassword(), request.getNewPassword());

            return ResponseEntity.ok(Map.of("message", "Password changed successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
