package com.krang.backend.service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;

@Service
public class PhoneVerificationService {

    private final Map<String, String> verificationCodes = new ConcurrentHashMap<>();

    public void saveCode(String username, String code) {
        verificationCodes.put(username, code);
        System.out.println("✅ Saved code for user: " + username + " -> " + code);
    }

    public String getCode(String username) {
        System.out.println("🔍 Getting code for user: " + username);
        return verificationCodes.get(username);
    }

    public void removeCode(String username) {
        verificationCodes.remove(username);
        System.out.println("❌ Removed code for user: " + username);
    }
}
