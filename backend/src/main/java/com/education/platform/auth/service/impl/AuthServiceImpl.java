package com.education.platform.auth.service.impl;

import com.education.platform.admin.entity.AdminUser;
import com.education.platform.admin.service.AdminUserService;
import com.education.platform.auth.config.SecurityProperties;
import com.education.platform.auth.dto.MemberRegisterRequest;
import com.education.platform.auth.dto.LoginRequest;
import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.service.AuthService;
import com.education.platform.auth.service.CaptchaService;
import com.education.platform.auth.service.TokenService;
import com.education.platform.auth.vo.CaptchaResponse;
import com.education.platform.auth.vo.LoginResponse;
import com.education.platform.auth.vo.UserProfileResponse;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.enums.StatusEnum;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.member.entity.Member;
import com.education.platform.member.service.MemberService;
import com.education.platform.teacher.entity.Teacher;
import com.education.platform.teacher.service.TeacherService;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private static final String ROLE_ADMIN = "ADMIN";
    private static final String ROLE_TEACHER = "TEACHER";
    private static final String ROLE_MEMBER = "MEMBER";

    private final TokenService tokenService;
    private final CaptchaService captchaService;
    private final SecurityProperties securityProperties;
    private final PasswordEncoder passwordEncoder;
    private final AdminUserService adminUserService;
    private final TeacherService teacherService;
    private final MemberService memberService;

    @Override
    public CaptchaResponse getCaptcha() {
        return captchaService.generateCaptcha();
    }

    @Override
    public LoginResponse adminLogin(LoginRequest request) {
        validateLoginCaptcha(request.getCaptchaKey(), request.getCaptchaCode());
        AdminUser adminUser = adminUserService.findByUsername(request.getUsername())
                .orElseThrow(() -> new BusinessException(ResultCode.UNAUTHORIZED.getCode(), "username or password is incorrect"));
        validatePasswordAndStatus(request.getPassword(), adminUser.getPassword(), adminUser.getStatus());
        return buildResponse(adminUser.getId(), adminUser.getUsername(), ROLE_ADMIN, adminUser.getRealName());
    }

    @Override
    public LoginResponse teacherLogin(LoginRequest request) {
        validateLoginCaptcha(request.getCaptchaKey(), request.getCaptchaCode());
        Teacher teacher = teacherService.findByLoginName(request.getUsername())
                .orElseThrow(() -> new BusinessException(ResultCode.UNAUTHORIZED.getCode(), "username or password is incorrect"));
        validatePasswordAndStatus(request.getPassword(), teacher.getPassword(), teacher.getStatus());
        return buildResponse(teacher.getId(), teacher.getLoginName(), ROLE_TEACHER, teacher.getName());
    }

    @Override
    public LoginResponse memberLogin(LoginRequest request) {
        validateLoginCaptcha(request.getCaptchaKey(), request.getCaptchaCode());
        Member member = memberService.findByMobile(request.getUsername())
                .orElseThrow(() -> new BusinessException(ResultCode.UNAUTHORIZED.getCode(), "username or password is incorrect"));
        validatePasswordAndStatus(request.getPassword(), member.getPassword(), member.getStatus());
        return buildResponse(member.getId(), member.getMobile(), ROLE_MEMBER, member.getNickname());
    }

    @Override
    public void memberRegister(MemberRegisterRequest request) {
        captchaService.validateCaptcha(request.getCaptchaKey(), request.getCaptchaCode());
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "password confirmation does not match");
        }
        if (memberService.findByMobile(request.getMobile()).isPresent()) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "mobile already exists");
        }

        Member member = new Member();
        member.setMobile(request.getMobile());
        member.setPassword(passwordEncoder.encode(request.getPassword()));
        member.setNickname(request.getNickname());
        member.setRealName(request.getRealName());
        member.setStatus(StatusEnum.ENABLED.getCode());
        memberService.save(member);
    }

    @Override
    public UserProfileResponse getCurrentProfile() {
        LoginUser loginUser = SecurityUtils.getLoginUser()
                .orElseThrow(() -> new BusinessException(ResultCode.UNAUTHORIZED));
        if (ROLE_MEMBER.equals(loginUser.getRole()) && loginUser.getUserId() != null) {
            Member member = memberService.getById(loginUser.getUserId());
            if (member != null) {
                return UserProfileResponse.builder()
                        .userId(member.getId())
                        .username(member.getMobile())
                        .role(ROLE_MEMBER)
                        .displayName(member.getNickname())
                        .avatar(member.getAvatar())
                        .balance(member.getBalance())
                        .build();
            }
        }
        if (ROLE_TEACHER.equals(loginUser.getRole()) && loginUser.getUserId() != null) {
            Teacher teacher = teacherService.getById(loginUser.getUserId());
            if (teacher != null) {
                return UserProfileResponse.builder()
                        .userId(teacher.getId())
                        .username(teacher.getLoginName())
                        .role(ROLE_TEACHER)
                        .displayName(teacher.getName())
                        .avatar(teacher.getAvatar())
                        .build();
            }
        }
        return UserProfileResponse.builder()
                .userId(loginUser.getUserId())
                .username(loginUser.getUsername())
                .role(loginUser.getRole())
                .displayName(loginUser.getDisplayName())
                .build();
    }

    private void validateLoginCaptcha(String captchaKey, String captchaCode) {
        if (!Boolean.TRUE.equals(securityProperties.getLoginCaptchaEnabled())) {
            return;
        }
        captchaService.validateCaptcha(captchaKey, captchaCode);
    }

    private LoginResponse buildResponse(Long userId, String username, String role, String displayName) {
        String token = tokenService.generateToken(
                username,
                java.util.List.of("ROLE_" + role),
                Map.of(
                        "userId", userId,
                        "role", role,
                        "displayName", displayName
                )
        );
        return LoginResponse.builder()
                .userId(userId)
                .token(token)
                .expiresIn(securityProperties.getTokenExpireSeconds())
                .role(role)
                .username(username)
                .displayName(displayName)
                .build();
    }

    private void validatePasswordAndStatus(String rawPassword, String encodedPassword, Integer status) {
        if (!passwordEncoder.matches(rawPassword, encodedPassword)) {
            throw new BusinessException(ResultCode.UNAUTHORIZED.getCode(), "username or password is incorrect");
        }
        if (status == null || status.equals(StatusEnum.DISABLED.getCode())) {
            throw new BusinessException(ResultCode.FORBIDDEN.getCode(), "account is disabled");
        }
    }
}
