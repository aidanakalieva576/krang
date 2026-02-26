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

        String path = request.getRequestURI();

        // ✅ Пропускаем без токена публичные маршруты
        if (path.startsWith("/api/auth/")
                //|| path.startsWith("/api/admin/register")
                || path.startsWith("/api/recovery/")
                || path.startsWith("/api/phone/")
                || path.startsWith("/swagger-ui/")
                || path.startsWith("/v3/api-docs/")
                || path.startsWith("/api/public/")
                || path.startsWith("/h2-console/")) {
            filterChain.doFilter(request, response);
            return;
        }

        final String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            System.out.println("⛔ No Authorization header or not Bearer format");
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);
        String username = jwtUtil.extractUsername(token);
        String role = jwtUtil.extractRole(token);

        System.out.println("🔹 TOKEN PARSED → username=" + username + ", role=" + role);

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            var user = userRepository.findByUsername(username).orElse(null);

            if (user != null && jwtUtil.validateToken(token)) {
                // нормализуем роль
                var grantedRole = role.toUpperCase();

                if (!grantedRole.startsWith("ROLE_")) {
                    System.out.println("⚙️  Role doesn't start with ROLE_ → adding prefix manually");
                    grantedRole = "ROLE_" + grantedRole;
                }

                var authorities = List.of(new SimpleGrantedAuthority(grantedRole));

                System.out.println("✅ Setting authentication for user=" + username);
                System.out.println("   Granted authorities = " + authorities);

                var authToken = new UsernamePasswordAuthenticationToken(
                        new User(user.getUsername(), user.getPasswordHash(), authorities),
                        null,
                        authorities
                );

                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            } else {
                System.out.println("❌ Token invalid or user not found");
            }
        }

        var contextAuth = SecurityContextHolder.getContext().getAuthentication();
        if (contextAuth != null) {
            System.out.println("🔍 CONTEXT AUTH TYPE: " + contextAuth.getClass().getSimpleName());
            System.out.println("🔍 CONTEXT PRINCIPAL: " + contextAuth.getPrincipal());
            System.out.println("🔍 CONTEXT AUTHORITIES: " + contextAuth.getAuthorities());
        } else {
            System.out.println("⚠️ CONTEXT AUTH IS NULL");
        }

        filterChain.doFilter(request, response);
    }
}
