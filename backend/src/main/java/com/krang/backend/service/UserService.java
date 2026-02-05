package com.krang.backend.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.krang.backend.dto.RegisterRequest;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
public User register(RegisterRequest req) {
    String username = req.getUsername().trim();
    String email = req.getEmail().trim().toLowerCase();

    if (userRepository.existsByUsername(username)) {
        throw new IllegalArgumentException("Username already taken");
    }
    if (userRepository.existsByEmail(email)) {
        throw new IllegalArgumentException("Email already registered");
    }

    String hashed = passwordEncoder.encode(req.getPassword());

    User user = new User(username, email, hashed);
    user.setRole("USER");
    user.setActive(true);

    return userRepository.save(user);
}

@Transactional
public void changePassword(String username, String oldPassword, String newPassword) {
    User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    if (!passwordEncoder.matches(oldPassword, user.getPasswordHash())) {
        throw new IllegalArgumentException("Old password is incorrect");
    }

    user.setPasswordHash(passwordEncoder.encode(newPassword));
    userRepository.save(user);
}


}
