package com.education.platform.task.controller;

import com.education.platform.common.result.Result;
import com.education.platform.task.dto.TaskSubmissionReviewDTO;
import com.education.platform.task.service.TaskSubmissionService;
import com.education.platform.task.vo.TaskSubmissionTeacherDetailVO;
import com.education.platform.task.vo.TaskSubmissionTeacherVO;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/teacher")
@RequiredArgsConstructor
public class TaskSubmissionTeacherController {

    private final TaskSubmissionService taskSubmissionService;

    @GetMapping("/course-tasks/{taskId}/submissions")
    public Result<List<TaskSubmissionTeacherVO>> list(@PathVariable Long taskId) {
        return Result.success(taskSubmissionService.listTeacherTaskSubmissions(taskId));
    }

    @GetMapping("/task-submissions/{submissionId}")
    public Result<TaskSubmissionTeacherDetailVO> detail(@PathVariable Long submissionId) {
        return Result.success(taskSubmissionService.getTeacherTaskSubmissionDetail(submissionId));
    }

    @PutMapping("/task-submissions/{submissionId}/review")
    public Result<Void> review(@PathVariable Long submissionId, @Valid @RequestBody TaskSubmissionReviewDTO request) {
        taskSubmissionService.reviewTeacherTaskSubmission(submissionId, request);
        return Result.success();
    }
}
