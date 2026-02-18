package com.krang.backend.dto;

import java.util.List;

public record AdminStatsResponse(
        String range,
        List<TopMovieDto> topMovies,
        List<SeriesPointDto> viewingSeries,
        List<GenreDto> genres
) {}
