package com.krang.backend.security;

import java.io.IOException;
import java.util.List;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.krang.backend.repository.UserRepository;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    public JwtAuthenticationFilter(JwtUtil jwtUtil, UserRepository userRepository) {
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
    }

    

    @Override
    
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {
        final String authHeader = request.getHeader("Authorization");
        System.out.println("➡️ Request URI: " + request.getRequestURI() + " | Authorization: " + authHeader);



        // 🔹 Если нет токена — пропускаем дальше
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);
        String username = jwtUtil.extractUsername(token);
        String role = jwtUtil.extractRole(token);
        System.out.println("🔹 Token=" + token + " | username=" + username + " | role=" + role);


        // 🔹 Проверяем, не установлена ли уже аутентификация
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            var user = userRepository.findByUsername(username).orElse(null);

            if (user != null && jwtUtil.validateToken(token)) {
                // ✅ Роль используем напрямую, без префикса ROLE_
                var authorities = List.of(new SimpleGrantedAuthority(role.toUpperCase()));

                // 🔹 Логируем для отладки
                System.out.println("✅ AUTH USER=" + username + " | ROLE=" + role.toUpperCase());

                var authToken = new UsernamePasswordAuthenticationToken(
                        new User(user.getUsername(), user.getPasswordHash(), authorities),
                        null,
                        authorities
                );

                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            } else {
                System.out.println("❌ INVALID TOKEN for user=" + username);
            }
        }

        filterChain.doFilter(request, response);
    }
}
