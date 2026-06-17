package com.education.platform.auth.vo;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class UserProfileResponse {

    private Long userId;
    private String username;
    private String role;
    private String displayName;
    private String avatar;
    private BigDecimal balance;
}
