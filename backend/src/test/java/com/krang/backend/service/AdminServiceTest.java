package com.krang.backend.service;

import com.krang.backend.dto.RegisterRequest;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AdminServiceTest {

    @Mock UserRepository userRepository;
    @Mock PasswordEncoder passwordEncoder;

    @InjectMocks AdminService adminService;

    @Test
    void createAdmin_shouldThrow_whenEmailExists() {
        RegisterRequest req = new RegisterRequest();
        req.setEmail("taken@mail.com");
        req.setUsername("any");
        req.setPassword("123");

        when(userRepository.existsByEmail("taken@mail.com")).thenReturn(true);

        assertThatThrownBy(() -> adminService.createAdmin(req))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Email already in use");

        verify(userRepository, never()).save(any());
    }

    @Test
    void deleteUserByEmail_shouldDelete_whenUserExists() {
        User user = new User();
        user.setEmail("user@mail.com");

        when(userRepository.findByEmail("user@mail.com"))
                .thenReturn(Optional.of(user));

        boolean result = adminService.deleteUserByEmail("user@mail.com");

        assertThat(result).isTrue();
        verify(userRepository).delete(user);
    }

    @Test
    void deleteUserByEmail_shouldReturnFalse_whenUserMissing() {
        when(userRepository.findByEmail("missing@mail.com"))
                .thenReturn(Optional.empty());

        boolean result = adminService.deleteUserByEmail("missing@mail.com");

        assertThat(result).isFalse();
        verify(userRepository, never()).delete(any());
    }
}