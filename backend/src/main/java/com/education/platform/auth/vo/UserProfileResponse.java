package com.education.platform.auth.vo;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserProfileResponse {

    private Long userId;
    private String username;
    private String role;
    private String displayName;
    private String avatar;
}
