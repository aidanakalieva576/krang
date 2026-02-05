package com.krang.backend.service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import org.springframework.stereotype.Service;

@Service
public class SmsService {

    // Хранилище кодов (в реальном проекте лучше Redis)
    private final Map<String, String> codeMap = new HashMap<>();

    /**
     * Отправляем код на номер (имитация SMS)
     */
    public void sendVerificationCode(String phone) {
        String code = String.format("%06d", new Random().nextInt(999999));
        codeMap.put(phone, code);

        // Вместо настоящего SMS — просто выводим в консоль
        System.out.println("📲 Отправлено SMS на " + phone + " с кодом: " + code);
    }

    /**
     * Проверяем введённый пользователем код
     */
    public boolean verifyCode(String phone, String enteredCode) {
        String realCode = codeMap.get(phone);
        System.out.println("🔍 Проверка кода для " + phone + ": введённый='" + enteredCode + "', реальный='" + realCode + "'");
        if (realCode != null && realCode.equals(enteredCode)) {
            codeMap.remove(phone);
            return true;
        }
        return true;
    }
}
