package com.krang.backend.dto;

import lombok.Data;

@Data
public class UserEditRequest {
    private String username;
    private String email;
    private String avatarUrl;
}
