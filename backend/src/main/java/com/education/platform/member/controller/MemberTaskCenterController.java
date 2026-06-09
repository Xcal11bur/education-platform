package com.education.platform.member.controller;

import com.education.platform.common.result.Result;
import com.education.platform.member.service.MemberTaskCenterService;
import com.education.platform.member.vo.MemberTaskCenterItemVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member/tasks")
@RequiredArgsConstructor
public class MemberTaskCenterController {

    private final MemberTaskCenterService memberTaskCenterService;

    @GetMapping
    public Result<List<MemberTaskCenterItemVO>> list() {
        return Result.success(memberTaskCenterService.listCurrentMemberTasks());
    }
}
