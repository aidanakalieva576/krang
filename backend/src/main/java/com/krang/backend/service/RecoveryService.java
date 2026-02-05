package com.krang.backend.service;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;

@Service
public class RecoveryService {

    private static class Entry {
        String email;
        Instant expiresAt;
        Entry(String email, Instant expiresAt) { this.email = email; this.expiresAt = expiresAt; }
    }

    private final Map<String, Entry> tokenMap = new ConcurrentHashMap<>();

    public String issueToken(String email, int minutesTtl) {
        String token = UUID.randomUUID().toString();
        tokenMap.put(token, new Entry(email, Instant.now().plusSeconds(minutesTtl * 60L)));
        return token;
    }

    public String consumeToken(String token) {
        Entry e = tokenMap.remove(token); // одноразовый
        if (e == null) return null;
        if (Instant.now().isAfter(e.expiresAt)) return null;
        return e.email;
    }
}
