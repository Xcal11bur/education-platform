package com.education.platform.task.controller;

import com.education.platform.common.result.Result;
import com.education.platform.task.dto.TaskSubmissionSaveDTO;
import com.education.platform.task.service.TaskSubmissionService;
import com.education.platform.task.vo.CourseTaskMemberDetailVO;
import com.education.platform.task.vo.CourseTaskMemberListVO;
import com.education.platform.task.vo.TaskSubmissionVO;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member")
@RequiredArgsConstructor
public class CourseTaskMemberController {

    private final TaskSubmissionService taskSubmissionService;

    @GetMapping("/courses/{courseId}/tasks")
    public Result<List<CourseTaskMemberListVO>> listCourseTasks(@PathVariable Long courseId) {
        return Result.success(taskSubmissionService.listCurrentMemberCourseTasks(courseId));
    }

    @GetMapping("/course-tasks/{taskId}")
    public Result<CourseTaskMemberDetailVO> detail(@PathVariable Long taskId) {
        return Result.success(taskSubmissionService.getCurrentMemberTaskDetail(taskId));
    }

    @GetMapping("/course-tasks/{taskId}/my-submissions")
    public Result<List<TaskSubmissionVO>> mySubmissions(@PathVariable Long taskId) {
        return Result.success(taskSubmissionService.listCurrentMemberTaskSubmissions(taskId));
    }

    @PostMapping("/course-tasks/{taskId}/submissions")
    public Result<Void> submit(@PathVariable Long taskId, @Valid @RequestBody TaskSubmissionSaveDTO request) {
        taskSubmissionService.submitCurrentMemberTask(taskId, request);
        return Result.success();
    }
}
