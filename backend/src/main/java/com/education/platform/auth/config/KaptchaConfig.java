package com.education.platform.auth.config;

import com.google.code.kaptcha.impl.DefaultKaptcha;
import com.google.code.kaptcha.util.Config;
import java.util.Properties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class KaptchaConfig {

    @Bean
    public DefaultKaptcha captchaProducer() {
        Properties properties = new Properties();
        properties.setProperty("kaptcha.border", "no");
        properties.setProperty("kaptcha.image.width", "160");
        properties.setProperty("kaptcha.image.height", "52");
        properties.setProperty("kaptcha.textproducer.font.size", "32");
        properties.setProperty("kaptcha.textproducer.char.length", "4");
        properties.setProperty("kaptcha.textproducer.char.space", "4");
        properties.setProperty("kaptcha.textproducer.char.string", "23456789ABCDEFGHJKLMNPQRSTUVWXYZ");
        properties.setProperty("kaptcha.textproducer.font.color", "32,62,110");
        properties.setProperty("kaptcha.noise.color", "160,180,210");
        properties.setProperty("kaptcha.background.clear.from", "245,248,252");
        properties.setProperty("kaptcha.background.clear.to", "255,255,255");

        DefaultKaptcha kaptcha = new DefaultKaptcha();
        kaptcha.setConfig(new Config(properties));
        return kaptcha;
    }
}
