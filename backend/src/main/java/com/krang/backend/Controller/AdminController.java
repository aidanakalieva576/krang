package com.krang.backend.Controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.dto.RegisterRequest;
import com.krang.backend.model.User;
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

    // 🧑‍💼 Создание нового админа
    @PostMapping("/register")
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

    // 👥 Получение всех обычных пользователей
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



}
