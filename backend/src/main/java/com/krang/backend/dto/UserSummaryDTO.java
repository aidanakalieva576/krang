package com.krang.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UserSummaryDTO {
    private String username;
    private String email;
    private Boolean isActive;
    private String avatarUrl;
}
