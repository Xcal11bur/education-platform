package com.education.platform.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class MemberRegisterRequest {

    @NotBlank(message = "mobile must not be blank")
    @Pattern(regexp = "^1\\d{10}$", message = "mobile format is invalid")
    private String mobile;

    @NotBlank(message = "nickname must not be blank")
    @Size(max = 50, message = "nickname length must not exceed 50")
    private String nickname;

    @Size(max = 50, message = "realName length must not exceed 50")
    private String realName;

    @NotBlank(message = "password must not be blank")
    @Size(min = 6, max = 20, message = "password length must be between 6 and 20")
    private String password;

    @NotBlank(message = "confirmPassword must not be blank")
    private String confirmPassword;

    @NotBlank(message = "captchaKey must not be blank")
    private String captchaKey;

    @NotBlank(message = "captchaCode must not be blank")
    private String captchaCode;
}
