package com.education.platform.auth.service;

import com.education.platform.auth.config.SecurityProperties;
import com.education.platform.auth.model.LoginUser;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@EnableConfigurationProperties(SecurityProperties.class)
public class TokenService {

    private final SecurityProperties securityProperties;

    public String generateToken(String username, Collection<String> authorities, Map<String, Object> extraClaims) {
        Instant now = Instant.now();
        return Jwts.builder()
                .claims(extraClaims)
                .subject(username)
                .claim("authorities", authorities)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(securityProperties.getTokenExpireSeconds())))
                .signWith(Keys.hmacShaKeyFor(securityProperties.getJwtSecret().getBytes(StandardCharsets.UTF_8)))
                .compact();
    }

    public String parseUsername(String token) {
        return parseAllClaims(token).getSubject();
    }

    public LoginUser parseLoginUser(String token) {
        Claims claims = parseAllClaims(token);
        List<GrantedAuthority> authorities = parseAuthorities(claims);
        Object rawUserId = claims.get("userId");
        Long userId = rawUserId instanceof Number number ? number.longValue() : null;
        return LoginUser.builder()
                .userId(userId)
                .username(claims.getSubject())
                .role(claims.get("role", String.class))
                .displayName(claims.get("displayName", String.class))
                .authorities(authorities)
                .build();
    }

    public List<GrantedAuthority> parseAuthorities(String token) {
        return parseAuthorities(parseAllClaims(token));
    }

    private List<GrantedAuthority> parseAuthorities(Claims claims) {
        Object rawAuthorities = claims.get("authorities");
        if (!(rawAuthorities instanceof List<?> authorityList)) {
            return List.of();
        }
        return authorityList.stream()
                .map(String::valueOf)
                .map(SimpleGrantedAuthority::new)
                .map(GrantedAuthority.class::cast)
                .toList();
    }

    private Claims parseAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(Keys.hmacShaKeyFor(securityProperties.getJwtSecret().getBytes(StandardCharsets.UTF_8)))
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
