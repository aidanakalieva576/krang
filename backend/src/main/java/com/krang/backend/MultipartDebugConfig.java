package com.krang.backend;

import org.springframework.boot.web.servlet.MultipartConfigFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.unit.DataSize;

import jakarta.servlet.MultipartConfigElement;

@Configuration
public class MultipartDebugConfig {
    static {
        System.out.println("🔥 MultipartDebugConfig LOADED");
    }

    @Bean
    public MultipartConfigElement multipartConfigElement() {
        MultipartConfigFactory factory = new MultipartConfigFactory();

        factory.setMaxFileSize(DataSize.ofGigabytes(5));
        factory.setMaxRequestSize(DataSize.ofGigabytes(5));

        System.out.println("✅ Multipart limits forced: 5GB");

        return factory.createMultipartConfig();
    }
}