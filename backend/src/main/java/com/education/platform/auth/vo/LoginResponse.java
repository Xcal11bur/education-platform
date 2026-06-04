package com.education.platform.auth.vo;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LoginResponse {

    private Long userId;
    private String token;
    private Long expiresIn;
    private String role;
    private String username;
    private String displayName;
}
