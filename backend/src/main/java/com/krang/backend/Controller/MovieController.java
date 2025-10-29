package com.krang.backend.Controller;

import java.util.List;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.model.Movie;
import com.krang.backend.repository.MovieRepository;

@RestController
@RequestMapping("/api/admin/movies")
@CrossOrigin(origins = "*")
public class MovieController {

    private final MovieRepository movieRepository;

    public MovieController(MovieRepository movieRepository) {
        this.movieRepository = movieRepository;
    }

    // 📥 Получить все фильмы
    @GetMapping
    public List<Movie> getAllMovies() {
        return movieRepository.findAll();
    }

    // 🔒 Скрыть фильм
    @PutMapping("/{id}/hide")
    public ResponseEntity<?> hideMovie(@PathVariable Long id) {
        Optional<Movie> movieOpt = movieRepository.findById(id);
        if (movieOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Movie movie = movieOpt.get();
        movie.setIs_hidden(true);
        movieRepository.save(movie);
        return ResponseEntity.ok(movie);
    }

    // 🔓 Показать (unhide)
    @PutMapping("/{id}/unhide")
    public ResponseEntity<?> unhideMovie(@PathVariable Long id) {
        Optional<Movie> movieOpt = movieRepository.findById(id);
        if (movieOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Movie movie = movieOpt.get();
        movie.setIs_hidden(false);
        movieRepository.save(movie);
        return ResponseEntity.ok(movie);
    }
}
