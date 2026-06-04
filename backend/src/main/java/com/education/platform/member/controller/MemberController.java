package com.education.platform.member.controller;

import com.education.platform.common.result.Result;
import com.education.platform.member.dto.MemberProfileUpdateDTO;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member")
public class MemberController {

    @GetMapping("/profile")
    public Result<String> profile() {
        return Result.success("member profile placeholder");
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@Valid @RequestBody MemberProfileUpdateDTO request) {
        return Result.success();
    }
}
