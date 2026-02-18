package com.krang.backend.service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class SmsService {

    private static final Logger log = LoggerFactory.getLogger(SmsService.class);

    // В проде лучше Redis, но для dev норм
    private final Map<String, String> codeMap = new HashMap<>();

    // -------------------------
    // SEND CODE
    // -------------------------
    public void sendVerificationCode(String phone) {

        String code = String.format("%06d", new Random().nextInt(999999));
        codeMap.put(phone, code);

        // логируем только телефон, код — только DEBUG
        log.info("SMS verification code generated for {}", phone);
        log.debug("Verification code for {} is {}", phone, code);

        // имитация SMS
        System.out.println("📲 SMS sent to " + phone + " with code: " + code);
    }

    // -------------------------
    // VERIFY CODE
    // -------------------------
    public boolean verifyCode(String phone, String enteredCode) {

        String realCode = codeMap.get(phone);

        if (realCode == null) {
            log.warn("Verification attempt for {} but no code exists", phone);
            return false;
        }

        if (!realCode.equals(enteredCode)) {
            log.warn("Incorrect SMS code entered for {}", phone);
            return false;
        }

        codeMap.remove(phone);
        log.info("SMS verification successful for {}", phone);

        return true;
    }
}
