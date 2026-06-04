package com.education.platform.task.controller;

import com.education.platform.common.result.Result;
import com.education.platform.task.dto.TaskSubmissionSaveDTO;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member/course-tasks")
public class CourseTaskMemberController {

    @PostMapping("/{taskId}/submissions")
    public Result<Void> submit(@PathVariable Long taskId, @RequestBody TaskSubmissionSaveDTO request) {
        return Result.success();
    }
}
