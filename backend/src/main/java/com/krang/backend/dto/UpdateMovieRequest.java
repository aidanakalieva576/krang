package com.krang.backend.dto;

public record UpdateMovieRequest(
        String title,
        String description,
        Integer releaseYear,
        String platform,
        String director,
        String type,
        Long categoryId
) {}

