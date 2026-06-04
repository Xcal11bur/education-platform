package com.education.platform.auth.controller;

import com.education.platform.auth.dto.LoginRequest;
import com.education.platform.auth.service.AuthService;
import com.education.platform.auth.vo.LoginResponse;
import com.education.platform.auth.vo.UserProfileResponse;
import com.education.platform.common.result.Result;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/admin/login")
    public Result<LoginResponse> adminLogin(@Valid @RequestBody LoginRequest request) {
        return Result.success(authService.adminLogin(request));
    }

    @PostMapping("/teacher/login")
    public Result<LoginResponse> teacherLogin(@Valid @RequestBody LoginRequest request) {
        return Result.success(authService.teacherLogin(request));
    }

    @PostMapping("/member/login")
    public Result<LoginResponse> memberLogin(@Valid @RequestBody LoginRequest request) {
        return Result.success(authService.memberLogin(request));
    }

    @GetMapping("/profile")
    public Result<UserProfileResponse> profile() {
        return Result.success(authService.getCurrentProfile());
    }
}
