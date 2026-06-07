package com.education.platform.auth.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "app.security")
public class SecurityProperties {

    private String jwtSecret;
    private Long tokenExpireSeconds;
    private Boolean loginCaptchaEnabled = false;
}
