package com.krang.backend.dto;

public record TopMovieDto(
        Long id,
        String title,
        String thumbnailUrl,
        Long watchSec
) {}
