package com.education.platform.teacher.controller;

import com.education.platform.common.result.Result;
import com.education.platform.infrastructure.storage.OssUploadService;
import com.education.platform.infrastructure.storage.UploadResult;
import com.education.platform.teacher.dto.TeacherPasswordUpdateDTO;
import com.education.platform.teacher.dto.TeacherProfileUpdateDTO;
import com.education.platform.teacher.service.TeacherService;
import com.education.platform.teacher.vo.TeacherProfileVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/teacher")
@RequiredArgsConstructor
public class TeacherController {

    private final TeacherService teacherService;
    private final OssUploadService ossUploadService;

    @GetMapping("/profile")
    public Result<TeacherProfileVO> profile() {
        return Result.success(teacherService.getCurrentProfile());
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@Valid @RequestBody TeacherProfileUpdateDTO request) {
        teacherService.updateCurrentProfile(request);
        return Result.success();
    }

    @PutMapping("/profile/password")
    public Result<Void> updatePassword(@Valid @RequestBody TeacherPasswordUpdateDTO request) {
        teacherService.updateCurrentPassword(request);
        return Result.success();
    }

    @PostMapping("/uploads/avatar")
    public Result<UploadResult> uploadAvatar(@RequestParam("file") MultipartFile file) {
        return Result.success(ossUploadService.uploadTeacherAvatar(file));
    }
}
