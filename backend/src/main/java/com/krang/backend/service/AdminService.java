package com.krang.backend.service;
import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.krang.backend.dto.RegisterRequest;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;

@Service
public class AdminService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User createAdmin(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }

        User admin = new User();
        admin.setUsername(req.getUsername());
        admin.setEmail(req.getEmail());
        admin.setPasswordHash(passwordEncoder.encode(req.getPassword()));
        admin.setRole("ADMIN");

        return userRepository.save(admin);
    }
    public boolean deleteUserByEmail(String email) {
    Optional<User> userOpt = userRepository.findByEmail(email);

    if (userOpt.isPresent()) {
        userRepository.delete(userOpt.get());
        return true;
    }

    return false;
}
}
