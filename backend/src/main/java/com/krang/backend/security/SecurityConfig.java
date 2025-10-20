package com.krang.backend.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.cors.CorsConfiguration;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    private static final Logger log = LoggerFactory.getLogger(SecurityConfig.class);

    private final JwtAuthenticationFilter jwtAuthFilter;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        log.info("✅ SecurityConfig initialized — admin/register should be public");

        return http
            // 🔹 Отключаем CSRF, включаем CORS
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(request -> {
                var corsConfig = new CorsConfiguration();
                corsConfig.addAllowedOriginPattern("*");
                corsConfig.addAllowedMethod("*");
                corsConfig.addAllowedHeader("*");
                corsConfig.setAllowCredentials(true);
                return corsConfig;
            }))

            // 🔹 Настраиваем разрешения
            .authorizeHttpRequests(auth -> auth
                // 👇 Сначала разрешаем полностью открытые пути
                .requestMatchers(
                    "/api/auth/**",
                    "/api/admin/register", // 👈 теперь точно открыт
                    "/swagger-ui/**",
                    "/v3/api-docs/**"
                ).permitAll()

                // 👇 потом ограничиваем всё остальное /api/admin/**
                .requestMatchers("/api/admin/**").hasRole("ADMIN")

                // 👇 все остальные запросы — только с токеном
                .anyRequest().authenticated()
            )

            // 🔹 Без сессий
            .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

            // 🔹 Добавляем JWT фильтр
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)

            // 🔹 Отключаем ограничения для Swagger (iframe и т.п.)
            .headers(headers -> headers.frameOptions().disable())

            .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
