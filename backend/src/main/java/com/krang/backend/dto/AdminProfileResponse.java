package com.krang.backend.dto;

public record AdminProfileResponse(
        Long id,
        String username,
        String email,
        String role
) {}
