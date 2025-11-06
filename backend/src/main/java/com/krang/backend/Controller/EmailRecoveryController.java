package com.krang.backend.Controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;
import com.krang.backend.service.SmsService;

@RestController
@RequestMapping("/api/recovery")
public class EmailRecoveryController {

    private final UserRepository userRepository;
    private final SmsService smsService;

    public EmailRecoveryController(UserRepository userRepository, SmsService smsService) {
        this.userRepository = userRepository;
        this.smsService = smsService;
    }

    @PostMapping("/email")
    public ResponseEntity<?> recoverByEmail(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email обязателен"));
        }

        // Найти пользователя по email
        var userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Пользователь с таким email не найден"));
        }

        User user = userOpt.get();
        String phone = user.getPhone();
        if (phone == null || phone.isEmpty()) {
            return ResponseEntity.status(400).body(Map.of("error", "У этого пользователя нет привязанного номера телефона"));
        }

        try {
            smsService.sendVerificationCode(phone);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Ошибка при отправке SMS"));
        }

        // Маскируем номер
        String masked = maskPhone(phone);
        return ResponseEntity.ok(Map.of(
                "message", "Код отправлен на " + masked,
                "maskedPhone", masked
        ));
    }

    private String maskPhone(String phone) {
        if (phone.length() < 6) return phone;
        return phone.substring(0, 2) + "****" + phone.substring(phone.length() - 2);
    }
}
