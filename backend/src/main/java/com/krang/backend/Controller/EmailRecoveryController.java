package com.krang.backend.Controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.dto.ResetPasswordDto;
import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;
import com.krang.backend.security.JwtUtil;
import com.krang.backend.service.RecoveryService;
import com.krang.backend.service.SmsService;



@RestController
@RequestMapping("/api/recovery")
public class EmailRecoveryController {

    private final UserRepository userRepository;
    private final SmsService smsService;
    private final RecoveryService recoveryService;
private final PasswordEncoder passwordEncoder; // если нужен ниже
private final JwtUtil jwtUtil;


    public EmailRecoveryController(UserRepository userRepository, SmsService smsService, RecoveryService recoveryService, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.smsService = smsService;
        this.recoveryService = recoveryService;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
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
                "maskedPhone", masked,
                "phone", phone
        ));
    }

    private String maskPhone(String phone) {
        if (phone.length() < 6) return phone;
        return phone.substring(0, 2) + "****" + phone.substring(phone.length() - 2);
    }

    @PostMapping("/verify")
public ResponseEntity<?> verifyRecoveryCode(@RequestBody Map<String, String> body) {
    String email = body.get("email");
    String code = body.get("code");

    if (email == null || email.trim().isEmpty()) {
        return ResponseEntity.badRequest().body(Map.of("error", "Email обязателен"));
    }
    if (code == null || code.trim().isEmpty()) {
        return ResponseEntity.badRequest().body(Map.of("error", "Code обязателен"));
    }

    var userOpt = userRepository.findByEmail(email.trim());
    if (userOpt.isEmpty()) {
        return ResponseEntity.status(404).body(Map.of("error", "Пользователь не найден"));
    }

    User user = userOpt.get();
    String phone = user.getPhone();

    if (phone == null || phone.trim().isEmpty()) {
        return ResponseEntity.status(400).body(Map.of("error", "У пользователя нет телефона"));
    }

    boolean ok = smsService.verifyCode(phone.trim(), code.trim());

    if (!ok) {
        return ResponseEntity.badRequest()
                .body(Map.of("error", "Wrong code or No code sent"));
    }
    String recoveryToken = recoveryService.issueToken(email.trim(), 10);

    return ResponseEntity.ok(Map.of("message", "Код подтверждён", "recoveryToken", recoveryToken));
    
}
@PostMapping("/reset-password")
public ResponseEntity<?> resetPassword(@RequestBody com.krang.backend.dto.ResetPasswordDto body) {

    String email = body.email;
    String code = body.code;
    String newPassword = body.newPassword;

    if (email == null || email.trim().isEmpty()) {
        return ResponseEntity.badRequest().body(Map.of("error", "Email обязателен"));
    }
    if (code == null || code.trim().isEmpty()) {
        return ResponseEntity.badRequest().body(Map.of("error", "Code обязателен"));
    }
    if (newPassword == null || newPassword.trim().length() < 8) {
        return ResponseEntity.badRequest().body(Map.of("error", "Пароль должен быть минимум 8 символов"));
    }

    var userOpt = userRepository.findByEmail(email.trim());
    if (userOpt.isEmpty()) {
        return ResponseEntity.status(404).body(Map.of("error", "Пользователь не найден"));
    }

    User user = userOpt.get();
    String phone = user.getPhone();
    if (phone == null || phone.trim().isEmpty()) {
        return ResponseEntity.status(400).body(Map.of("error", "У пользователя нет телефона"));
    }

    // // ✅ Проверяем код там же, где он сохранялся (SmsService)
    // boolean ok = smsService.verifyCode(phone.trim(), code.trim());
    // if (!ok) {
    //     return ResponseEntity.badRequest().body(Map.of("error", "Wrong code or No code sent"));
    // }

    // ✅ Хешируем и сохраняем новый пароль
    String hashed = passwordEncoder.encode(newPassword.trim());
    user.setPasswordHash(hashed); // <-- если поле у тебя называется иначе, поменяй на свой setter
    userRepository.save(user);

    return ResponseEntity.ok(Map.of("message", "Пароль успешно изменён"));
}


}
