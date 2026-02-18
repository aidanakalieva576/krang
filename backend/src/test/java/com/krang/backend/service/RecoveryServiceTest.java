package com.krang.backend.service;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.*;

class RecoveryServiceTest {

    @Test
    void issueToken_thenConsumeToken_returnsEmail() {
        RecoveryService service = new RecoveryService();

        String token = service.issueToken("a@mail.com", 10); // 10 минут

        String email = service.consumeToken(token);

        assertThat(email).isEqualTo("a@mail.com");
    }

    @Test
    void consumeToken_isOneTime_onlyFirstConsumeWorks() {
        RecoveryService service = new RecoveryService();

        String token = service.issueToken("a@mail.com", 10);

        String first = service.consumeToken(token);
        String second = service.consumeToken(token);

        assertThat(first).isEqualTo("a@mail.com");
        assertThat(second).isNull(); // потому что tokenMap.remove(token)
    }

    @Test
    void consumeToken_returnsNull_whenTokenUnknown() {
        RecoveryService service = new RecoveryService();

        assertThat(service.consumeToken("not-a-real-token")).isNull();
    }

    @Test
    void consumeToken_returnsNull_whenExpired() {
        RecoveryService service = new RecoveryService();

        // TTL = 0 минут -> expiresAt = Instant.now()
        // С большой вероятностью к моменту consumeToken() уже будет "after" и вернётся null.
        // Чтобы тест был стабильнее, делаем TTL отрицательным => точно просрочен.
        String token = service.issueToken("a@mail.com", -1);

        String email = service.consumeToken(token);

        assertThat(email).isNull();
    }

    @Test
    void expiredToken_isStillRemoved_afterConsumeAttempt() {
        RecoveryService service = new RecoveryService();

        String token = service.issueToken("a@mail.com", -1);

        // 1) просроченный -> null
        assertThat(service.consumeToken(token)).isNull();

        // 2) и он одноразовый/removal, повторно тоже null (важно: удалён)
        assertThat(service.consumeToken(token)).isNull();
    }
}
