package com.education.platform.member.controller;

import com.education.platform.common.dto.StatusUpdateDTO;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.member.dto.MemberQueryDTO;
import com.education.platform.member.dto.MemberSaveDTO;
import com.education.platform.member.service.MemberService;
import com.education.platform.member.vo.MemberVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/members")
@RequiredArgsConstructor
public class MemberAdminController {

    private final MemberService memberService;

    @GetMapping
    public Result<PageResponse<MemberVO>> list(@Valid @ModelAttribute MemberQueryDTO queryDTO) {
        return Result.success(memberService.pageMembers(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<MemberVO> detail(@PathVariable Long id) {
        return Result.success(memberService.getMemberDetail(id));
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody MemberSaveDTO request) {
        memberService.updateMember(id, request);
        return Result.success();
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @Valid @RequestBody StatusUpdateDTO request) {
        memberService.updateMemberStatus(id, request.getStatus());
        return Result.success();
    }
}
