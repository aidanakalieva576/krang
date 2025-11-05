package com.krang.backend.Controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.dto.LoginRequest;
import com.krang.backend.dto.RegisterRequest;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;
import com.krang.backend.security.JwtUtil;
import com.krang.backend.service.UserService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthRestController {

    private final UserService userService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthRestController(UserService userService,
                              UserRepository userRepository,
                              PasswordEncoder passwordEncoder,
                              JwtUtil jwtUtil) {
        this.userService = userService;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    // 🔹 Регистрация пользователя с автоматической генерацией JWT
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest req) {
        try {
            // Проверим, существует ли уже пользователь
            if (userRepository.findByEmail(req.getEmail()).isPresent()) {
                return ResponseEntity.badRequest().body(Map.of("error", "User with this email already exists"));
            }

            // Регистрируем
            User created = userService.register(req);

            // Генерируем JWT токен
            String token = jwtUtil.generateToken(created.getUsername(), created.getRole());


            // Возвращаем пользователя + токен
            return ResponseEntity.status(201).body(
                Map.of(
                    "id", created.getId(),
                    "username", created.getUsername(),
                    "email", created.getEmail(),
                    "role", created.getRole(),
                    "token", token
                )
            );

        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.of("error", ex.getMessage()));
        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "Internal error"));
        }
    }

    // 🔹 Логин с генерацией JWT токена
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        String email = request.getEmail();
        String password = request.getPassword();

        if (email == null || password == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email and password are required"));
        }
        email = email.trim().toLowerCase(); // 👈 добавь это

        var user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            return ResponseEntity.status(404).body(Map.of("error", "User not found"));
        }

        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid password"));
        }

        String token = jwtUtil.generateToken(user.getUsername(), user.getRole());


        return ResponseEntity.ok(
            Map.of(
                "token", token,
                "username", user.getUsername(),
                "email", user.getEmail(),
                "role", user.getRole()
            )
        );
    }
}
