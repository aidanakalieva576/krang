package com.krang.backend.Controller;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;
import com.krang.backend.security.JwtUtil;

@RestController
@RequestMapping("/api/phone")
public class PhoneController {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserRepository userRepository;

    // Временное хранилище кодов (пока без Redis)
    private final Map<String, String> phoneCodeMap = new HashMap<>();

    @PostMapping("/send-code")
    public ResponseEntity<?> sendVerificationCode(
            @RequestHeader("Authorization") String token,
            @RequestBody Map<String, String> body
    ) {
        try {
            // 1️⃣ Проверяем токен
            if (token == null || !token.startsWith("Bearer ")) {
                return ResponseEntity.status(401).body(Map.of("error", "No Authorization header or not Bearer format"));
            }

            String jwt = token.replace("Bearer ", "");
            String username = jwtUtil.extractUsername(jwt);

            if (!jwtUtil.validateToken(jwt)) {
                return ResponseEntity.status(401).body(Map.of("error", "Invalid token"));
            }

            // 2️⃣ Проверяем телефон
            String phone = body.get("phone");
            if (phone == null || phone.isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Phone number is required"));
            }

            // Пример простейшей валидации для Казахстана (+77...)
            if (!phone.matches("^\\+77\\d{9}$")) {
                return ResponseEntity.badRequest().body(Map.of("error", "Invalid phone number format"));
            }

            // 3️⃣ Находим пользователя
            User user = userRepository.findByUsernameIgnoreCase(username)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));

            // 4️⃣ Генерируем код
            String code = String.format("%06d", new Random().nextInt(999999));
            phoneCodeMap.put(user.getUsername(), code);

            // ⚠️ 5️⃣ Отправляем SMS (пока просто печатаем в консоль)
            System.out.println("📲 SMS to " + phone + " — code: " + code);

            // 👉 здесь позже можно подключить Twilio, SMS.ru или любой другой сервис

            return ResponseEntity.ok(Map.of(
                    "message", "Verification code sent successfully",
                    "phone", phone
            ));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // ✅ Проверка кода
    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(
            @RequestHeader("Authorization") String token,
            @RequestBody Map<String, String> body
    ) {
        try {
            String jwt = token.replace("Bearer ", "");
            String username = jwtUtil.extractUsername(jwt);
            String enteredCode = body.get("code");

            String actualCode = phoneCodeMap.get(username);

            if (actualCode == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "No code sent for this user"));
            }

            if (!actualCode.equals(enteredCode)) {
                return ResponseEntity.badRequest().body(Map.of("error", "Invalid code"));
            }

            // Можно теперь обновить пользователя, сохранив телефон
            String phone = body.get("phone");
            User user = userRepository.findByUsernameIgnoreCase(username)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));

            user.setPhone(phone);
            userRepository.save(user);

            // Удаляем из памяти код
            phoneCodeMap.remove(username);

            return ResponseEntity.ok(Map.of("message", "Phone verified successfully"));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}
