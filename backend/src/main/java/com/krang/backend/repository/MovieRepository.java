package com.krang.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.krang.backend.model.Movie;

public interface MovieRepository extends JpaRepository<Movie, Long> {
}
