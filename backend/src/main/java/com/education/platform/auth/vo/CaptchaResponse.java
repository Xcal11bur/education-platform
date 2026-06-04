package com.education.platform.auth.vo;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CaptchaResponse {

    private String captchaKey;
    private String imageBase64;
    private Long expiresIn;
}
