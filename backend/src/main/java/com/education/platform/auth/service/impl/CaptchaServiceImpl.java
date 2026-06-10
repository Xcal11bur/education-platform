package com.education.platform.auth.service.impl;

import com.education.platform.auth.service.CaptchaService;
import com.education.platform.auth.vo.CaptchaResponse;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.google.code.kaptcha.Producer;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import javax.imageio.ImageIO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class CaptchaServiceImpl implements CaptchaService {

    private static final long CAPTCHA_EXPIRE_SECONDS = 120L;

    private final Producer captchaProducer;
    private final ConcurrentHashMap<String, CaptchaEntry> captchaStore = new ConcurrentHashMap<>();

    @Override
    public CaptchaResponse generateCaptcha() {
        clearExpiredCaptchas();
        String text = captchaProducer.createText();
        BufferedImage image = captchaProducer.createImage(text);
        String captchaKey = UUID.randomUUID().toString();
        long expireAt = Instant.now().plusSeconds(CAPTCHA_EXPIRE_SECONDS).getEpochSecond();
        captchaStore.put(captchaKey, new CaptchaEntry(text.toLowerCase(), expireAt));
        return CaptchaResponse.builder()
                .captchaKey(captchaKey)
                .imageBase64(toBase64(image))
                .expiresIn(CAPTCHA_EXPIRE_SECONDS)
                .build();
    }

    @Override
    public void validateCaptcha(String captchaKey, String captchaCode) {
        clearExpiredCaptchas();
        if (!StringUtils.hasText(captchaKey) || !StringUtils.hasText(captchaCode)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "captcha is required");
        }
        CaptchaEntry entry = captchaStore.remove(captchaKey);
        if (entry == null || entry.expireAt() < Instant.now().getEpochSecond()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "captcha has expired");
        }
        if (!entry.text().equals(captchaCode.trim().toLowerCase())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "captcha is incorrect");
        }
    }

    private void clearExpiredCaptchas() {
        long now = Instant.now().getEpochSecond();
        captchaStore.entrySet().removeIf(entry -> entry.getValue().expireAt() < now);
    }

    private String toBase64(BufferedImage image) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            ImageIO.write(image, "jpg", outputStream);
            return "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(outputStream.toByteArray());
        } catch (IOException ex) {
            throw new BusinessException(ResultCode.INTERNAL_ERROR.getCode(), "failed to generate captcha");
        }
    }

    private record CaptchaEntry(String text, long expireAt) {
    }
}
