package com.education.platform.member.controller;

import com.education.platform.common.result.Result;
import com.education.platform.infrastructure.storage.OssUploadService;
import com.education.platform.infrastructure.storage.UploadResult;
import com.education.platform.member.dto.MemberMobileUpdateDTO;
import com.education.platform.member.dto.MemberPasswordUpdateDTO;
import com.education.platform.member.dto.MemberProfileUpdateDTO;
import com.education.platform.member.service.MemberService;
import com.education.platform.member.vo.MemberProfileVO;
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
@RequestMapping("/api/v1/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;
    private final OssUploadService ossUploadService;

    @GetMapping("/profile")
    public Result<MemberProfileVO> profile() {
        return Result.success(memberService.getCurrentProfile());
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@Valid @RequestBody MemberProfileUpdateDTO request) {
        memberService.updateCurrentProfile(request);
        return Result.success();
    }

    @PutMapping("/profile/mobile")
    public Result<Void> updateMobile(@Valid @RequestBody MemberMobileUpdateDTO request) {
        memberService.updateCurrentMobile(request);
        return Result.success();
    }

    @PutMapping("/profile/password")
    public Result<Void> updatePassword(@Valid @RequestBody MemberPasswordUpdateDTO request) {
        memberService.updateCurrentPassword(request);
        return Result.success();
    }

    @PostMapping("/uploads/avatar")
    public Result<UploadResult> uploadAvatar(@RequestParam("file") MultipartFile file) {
        return Result.success(ossUploadService.uploadMemberAvatar(file));
    }
}
