package com.education.platform.auth.config;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Data
@Validated
@ConfigurationProperties(prefix = "app.security")
public class SecurityProperties {

    @NotBlank
    @Size(min = 32, message = "jwtSecret must be at least 32 characters")
    private String jwtSecret;

    @NotNull
    @Positive
    private Long tokenExpireSeconds;

    @NotNull
    private Boolean loginCaptchaEnabled = true;
}
