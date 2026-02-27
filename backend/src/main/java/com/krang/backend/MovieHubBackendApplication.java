package com.krang.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Import;

@Import(MultipartDebugConfig.class)
@SpringBootApplication
public class MovieHubBackendApplication {
  public static void main(String[] args) {
    System.out.println("🚀 STARTING MovieHubBackendApplication");
    SpringApplication.run(MovieHubBackendApplication.class, args);
  }
}