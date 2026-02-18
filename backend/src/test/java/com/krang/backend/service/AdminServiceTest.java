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

    @Mock
    UserRepository userRepository;

    @Mock
    PasswordEncoder passwordEncoder;

    @InjectMocks
    AdminService adminService;

    // ----------------------------
    // ТЕСТ: успешное создание админа
    // ----------------------------
    @Test
    void createAdmin_shouldSaveAdmin_whenEmailFree() {

        RegisterRequest req = new RegisterRequest();
        req.setEmail("admin@mail.com");
        req.setUsername("admin");
        req.setPassword("123");

        when(userRepository.existsByEmail("admin@mail.com")).thenReturn(false);
        when(passwordEncoder.encode("123")).thenReturn("encoded");
        when(userRepository.save(any(User.class))).thenAnswer(i -> i.getArgument(0));

        User saved = adminService.createAdmin(req);

        assertThat(saved.getEmail()).isEqualTo("admin@mail.com");
        assertThat(saved.getRole()).isEqualTo("ADMIN");
        assertThat(saved.getPasswordHash()).isEqualTo("encoded");

        verify(userRepository).save(any(User.class));
    }

    // ----------------------------
    // ТЕСТ: email уже занят
    // ----------------------------
    @Test
    void createAdmin_shouldThrow_whenEmailExists() {

        RegisterRequest req = new RegisterRequest();
        req.setEmail("taken@mail.com");

        when(userRepository.existsByEmail("taken@mail.com")).thenReturn(true);

        assertThatThrownBy(() -> adminService.createAdmin(req))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Email already in use");

        verify(userRepository, never()).save(any());
    }

    // ----------------------------
    // ТЕСТ: удаление пользователя найдено
    // ----------------------------
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

    // ----------------------------
    // ТЕСТ: удаление пользователя не найдено
    // ----------------------------
    @Test
    void deleteUserByEmail_shouldReturnFalse_whenUserMissing() {

        when(userRepository.findByEmail("missing@mail.com"))
                .thenReturn(Optional.empty());

        boolean result = adminService.deleteUserByEmail("missing@mail.com");

        assertThat(result).isFalse();
        verify(userRepository, never()).delete(any());
    }
}
