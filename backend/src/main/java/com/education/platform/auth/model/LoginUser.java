package com.education.platform.auth.model;

import java.io.Serial;
import java.io.Serializable;
import java.util.Collection;
import lombok.Builder;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;

@Getter
@Builder
public class LoginUser implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private final Long userId;
    private final String username;
    private final String role;
    private final String displayName;
    private final Collection<? extends GrantedAuthority> authorities;
}
