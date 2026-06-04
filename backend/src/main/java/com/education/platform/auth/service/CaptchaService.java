package com.education.platform.auth.service;

import com.education.platform.auth.vo.CaptchaResponse;

public interface CaptchaService {

    CaptchaResponse generateCaptcha();

    void validateCaptcha(String captchaKey, String captchaCode);
}
