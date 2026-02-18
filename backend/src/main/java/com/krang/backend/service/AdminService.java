package com.krang.backend.service;

import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.krang.backend.dto.RegisterRequest;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;

@Service
public class AdminService {

    private static final Logger log = LoggerFactory.getLogger(AdminService.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // -------------------------
    // CREATE ADMIN
    // -------------------------
    public User createAdmin(RegisterRequest req) {

        String email = req.getEmail().trim().toLowerCase();
        String username = req.getUsername().trim();

        log.info("Attempt to create admin account for {}", email);

        if (userRepository.existsByEmail(email)) {
            log.warn("Admin creation failed: email already in use -> {}", email);
            throw new IllegalArgumentException("Email already in use");
        }

        String hash = passwordEncoder.encode(req.getPassword());
        log.debug("Password encoded for admin {}", username);

        User admin = new User();
        admin.setUsername(username);
        admin.setEmail(email);
        admin.setPasswordHash(hash);
        admin.setRole("ADMIN");

        User saved = userRepository.save(admin);

        log.info("Admin account created successfully: {}", email);
        return saved;
    }

    // -------------------------
    // DELETE USER
    // -------------------------
    public boolean deleteUserByEmail(String email) {

        log.info("Admin requested deletion of user {}", email);

        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isPresent()) {
            userRepository.delete(userOpt.get());
            log.info("User deleted successfully: {}", email);
            return true;
        }

        log.warn("Deletion failed: user not found -> {}", email);
        return false;
    }
}
