package com.education.platform;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = {
        "app.security.jwt-secret=test-jwt-secret-for-context-loads-123456"
})
class EducationPlatformApplicationTests {

    @Test
    void contextLoads() {
    }
}
