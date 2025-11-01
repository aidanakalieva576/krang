package com.krang.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.krang.backend.model.MovieRating;

public interface MovieRatingRepository extends JpaRepository<MovieRating, Long> {
}
