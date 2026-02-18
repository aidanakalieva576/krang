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
class UserServiceTest {

    @Mock
    UserRepository userRepository;

    @Mock
    PasswordEncoder passwordEncoder;

    @InjectMocks
    UserService userService;

    // -----------------------------
    // register(): успешная регистрация
    // -----------------------------
    @Test
    void register_shouldSaveUser_whenValid() {
        RegisterRequest req = new RegisterRequest();
        req.setUsername("  Shu  ");
        req.setEmail("  SHU@mail.com ");
        req.setPassword("123");

        when(userRepository.existsByUsername("Shu")).thenReturn(false);
        when(userRepository.existsByEmail("shu@mail.com")).thenReturn(false);
        when(passwordEncoder.encode("123")).thenReturn("hashed");
        when(userRepository.save(any(User.class))).thenAnswer(i -> i.getArgument(0));

        User user = userService.register(req);

        assertThat(user.getUsername()).isEqualTo("Shu");
        assertThat(user.getEmail()).isEqualTo("shu@mail.com");
        assertThat(user.getPasswordHash()).isEqualTo("hashed");
        assertThat(user.getRole()).isEqualTo("USER");
        assertThat(user.isActive()).isTrue();

        verify(userRepository).save(any(User.class));
    }

    // -----------------------------
    // register(): username занят
    // -----------------------------
    @Test
    void register_shouldThrow_whenUsernameExists() {
        RegisterRequest req = new RegisterRequest();
        req.setUsername("shu");
        req.setEmail("shu@mail.com");

        when(userRepository.existsByUsername("shu")).thenReturn(true);

        assertThatThrownBy(() -> userService.register(req))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Username already taken");

        verify(userRepository, never()).save(any());
    }

    // -----------------------------
    // register(): email занят
    // -----------------------------
    @Test
    void register_shouldThrow_whenEmailExists() {
        RegisterRequest req = new RegisterRequest();
        req.setUsername("shu");
        req.setEmail("shu@mail.com");

        when(userRepository.existsByUsername("shu")).thenReturn(false);
        when(userRepository.existsByEmail("shu@mail.com")).thenReturn(true);

        assertThatThrownBy(() -> userService.register(req))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Email already registered");

        verify(userRepository, never()).save(any());
    }

    // -----------------------------
    // changePassword(): успешно
    // -----------------------------
    @Test
    void changePassword_shouldUpdate_whenOldPasswordCorrect() {
        User user = new User("shu", "shu@mail.com", "oldHash");

        when(userRepository.findByUsername("shu")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("old", "oldHash")).thenReturn(true);
        when(passwordEncoder.encode("new")).thenReturn("newHash");

        userService.changePassword("shu", "old", "new");

        assertThat(user.getPasswordHash()).isEqualTo("newHash");
        verify(userRepository).save(user);
    }

    // -----------------------------
    // changePassword(): пользователь не найден
    // -----------------------------
    @Test
    void changePassword_shouldThrow_whenUserMissing() {
        when(userRepository.findByUsername("shu")).thenReturn(Optional.empty());

        assertThatThrownBy(() ->
                userService.changePassword("shu", "old", "new"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("User not found");
    }

    // -----------------------------
    // changePassword(): старый пароль неверный
    // -----------------------------
    @Test
    void changePassword_shouldThrow_whenOldPasswordWrong() {
        User user = new User("shu", "shu@mail.com", "oldHash");

        when(userRepository.findByUsername("shu")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrong", "oldHash")).thenReturn(false);

        assertThatThrownBy(() ->
                userService.changePassword("shu", "wrong", "new"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Old password is incorrect");

        verify(userRepository, never()).save(any());
    }
}
