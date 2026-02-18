package com.krang.backend.service;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.*;

class PhoneVerificationServiceTest {

    @Test
    void saveCode_thenGetCode_returnsSameCode() {
        PhoneVerificationService service = new PhoneVerificationService();

        service.saveCode("shu", "123456");

        assertThat(service.getCode("shu")).isEqualTo("123456");
    }

    @Test
    void getCode_returnsNull_whenNoCodeSaved() {
        PhoneVerificationService service = new PhoneVerificationService();

        assertThat(service.getCode("unknown")).isNull();
    }

    @Test
    void removeCode_deletesCode() {
        PhoneVerificationService service = new PhoneVerificationService();

        service.saveCode("shu", "9999");
        service.removeCode("shu");

        assertThat(service.getCode("shu")).isNull();
    }

    @Test
    void saveCode_overwritesOldCode_forSameUser() {
        PhoneVerificationService service = new PhoneVerificationService();

        service.saveCode("shu", "1111");
        service.saveCode("shu", "2222");

        assertThat(service.getCode("shu")).isEqualTo("2222");
    }

    @Test
    void removeCode_forMissingUser_doesNotThrow() {
        PhoneVerificationService service = new PhoneVerificationService();

        assertThatNoException().isThrownBy(() -> service.removeCode("missing"));
    }
}
