package com.education.platform.auth.service;

import com.education.platform.auth.dto.LoginRequest;
import com.education.platform.auth.vo.LoginResponse;
import com.education.platform.auth.vo.UserProfileResponse;

public interface AuthService {

    LoginResponse adminLogin(LoginRequest request);

    LoginResponse teacherLogin(LoginRequest request);

    LoginResponse memberLogin(LoginRequest request);

    UserProfileResponse getCurrentProfile();
}
