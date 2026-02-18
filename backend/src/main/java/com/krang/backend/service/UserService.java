package com.krang.backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.krang.backend.dto.RegisterRequest;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;

@Service
public class UserService {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // -------------------------
    // REGISTER
    // -------------------------
    @Transactional
    public User register(RegisterRequest req) {

        String username = req.getUsername().trim();
        String email = req.getEmail().trim().toLowerCase();

        log.info("Registration attempt for user: {}", email);

        if (userRepository.existsByUsername(username)) {
            log.warn("Registration failed: username already taken -> {}", username);
            throw new IllegalArgumentException("Username already taken");
        }

        if (userRepository.existsByEmail(email)) {
            log.warn("Registration failed: email already registered -> {}", email);
            throw new IllegalArgumentException("Email already registered");
        }

        String hashed = passwordEncoder.encode(req.getPassword());
        log.debug("Password encoded for user {}", username);

        User user = new User(username, email, hashed);
        user.setRole("USER");
        user.setActive(true);

        User saved = userRepository.save(user);
        log.info("User registered successfully: {}", email);

        return saved;
    }

    // -------------------------
    // CHANGE PASSWORD
    // -------------------------
    @Transactional
    public void changePassword(String username, String oldPassword, String newPassword) {

        log.info("Password change requested for user {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> {
                    log.error("Password change failed: user not found -> {}", username);
                    return new IllegalArgumentException("User not found");
                });

        if (!passwordEncoder.matches(oldPassword, user.getPasswordHash())) {
            log.warn("Password change failed: incorrect old password for {}", username);
            throw new IllegalArgumentException("Old password is incorrect");
        }

        String newHash = passwordEncoder.encode(newPassword);
        user.setPasswordHash(newHash);
        userRepository.save(user);

        log.info("Password updated successfully for {}", username);
    }
}
