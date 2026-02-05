package com.krang.backend.Controller;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.krang.backend.model.User;
import com.krang.backend.repository.UserRepository;
import com.krang.backend.security.JwtUtil;
import com.krang.backend.service.SmsService;

@RestController
@RequestMapping("/api/phone")
public class PhoneController {

    private static final Logger log = LoggerFactory.getLogger(PhoneController.class);

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SmsService smsService;

    private String norm(String s) { return s == null ? null : s.trim(); }

    private String maskPhone(String phone) {
        if (phone == null) return "null";
        String p = phone.trim();
        if (p.length() >= 5) {
            int keepEnd = Math.min(3, p.length());
            return p.substring(0, Math.min(3, p.length())) + "*****" + p.substring(p.length() - keepEnd);
        }
        return "***";
    }

    @PostMapping("/send-code")
    public ResponseEntity<?> sendVerificationCode(
            @RequestHeader(value = "Authorization", required = false) String token,
            @RequestBody Map<String, String> body
    ) {
        try {
            if (token == null || !token.startsWith("Bearer ")) {
                return ResponseEntity.status(401).body(Map.of("error", "No Authorization header or not Bearer format"));
            }

            String jwt = token.replace("Bearer ", "").trim();
            if (!jwtUtil.validateToken(jwt)) {
                return ResponseEntity.status(401).body(Map.of("error", "Invalid token"));
            }

            String phone = norm(body.get("phone"));
            if (phone == null || phone.isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Phone number is required"));
            }

            if (!phone.matches("^\\+77\\d{9}$")) {
                return ResponseEntity.badRequest().body(Map.of("error", "Invalid phone number format"));
            }

            // (опционально) убедимся, что пользователь существует
            String username = jwtUtil.extractUsername(jwt);
            userRepository.findByUsernameIgnoreCase(username)
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));

            // ✅ отправка + сохранение кода в SmsService
            smsService.sendVerificationCode(phone);
            log.info("[SEND] code sent to phone='{}'", maskPhone(phone));

            return ResponseEntity.ok(Map.of("message", "Verification code sent successfully"));

        } catch (Exception e) {
            log.error("[SEND] ERROR: {}", e.toString(), e);
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(
            @RequestHeader(value = "Authorization", required = false) String token,
            @RequestBody Map<String, String> body
    ) {
        try {
            String phone = norm(body.get("phone"));
            String enteredCode = norm(body.get("code"));

            if (phone == null || phone.isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Phone is empty in verify request"));
            }
            if (enteredCode == null || enteredCode.isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Code is empty"));
            }

            boolean ok = smsService.verifyCode(phone, enteredCode);
            if (!ok) {
                return ResponseEntity.badRequest().body(Map.of("error", "Invalid code or No code sent"));
            }

            // если есть токен и он валиден — можно сохранить phone пользователю
            if (token != null && token.startsWith("Bearer ")) {
                String jwt = token.replace("Bearer ", "").trim();
                if (jwtUtil.validateToken(jwt)) {
                    String username = jwtUtil.extractUsername(jwt);
                    var user = userRepository.findByUsernameIgnoreCase(username)
                            .orElseThrow(() -> new IllegalArgumentException("User not found"));

                    user.setPhone(phone);
                    userRepository.save(user);
                }
            }

            return ResponseEntity.ok(Map.of("message", "Phone verified successfully"));

        } catch (Exception e) {
            log.error("[VERIFY] ERROR: {}", e.toString(), e);
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}
