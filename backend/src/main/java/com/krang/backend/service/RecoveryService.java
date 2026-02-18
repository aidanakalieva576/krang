package com.krang.backend.service;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class RecoveryService {

    private static final Logger log = LoggerFactory.getLogger(RecoveryService.class);

    private static class Entry {
        String email;
        Instant expiresAt;
        Entry(String email, Instant expiresAt) {
            this.email = email;
            this.expiresAt = expiresAt;
        }
    }

    private final Map<String, Entry> tokenMap = new ConcurrentHashMap<>();

    // -------------------------
    // ISSUE TOKEN
    // -------------------------
    public String issueToken(String email, int minutesTtl) {

        String token = UUID.randomUUID().toString();
        Instant expires = Instant.now().plusSeconds(minutesTtl * 60L);

        tokenMap.put(token, new Entry(email, expires));

        log.info("Recovery token issued for {}", email);
        log.debug("Token expires at {} for {}", expires, email);

        return token;
    }

    // -------------------------
    // CONSUME TOKEN
    // -------------------------
    public String consumeToken(String token) {

        Entry e = tokenMap.remove(token);

        if (e == null) {
            log.warn("Attempt to use invalid or already used recovery token");
            return null;
        }

        if (Instant.now().isAfter(e.expiresAt)) {
            log.warn("Expired recovery token used for {}", e.email);
            return null;
        }

        log.info("Recovery token consumed successfully for {}", e.email);
        return e.email;
    }
}
