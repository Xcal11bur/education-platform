package com.education.platform.exam.controller;

import com.education.platform.common.result.Result;
import com.education.platform.exam.service.ExamSubmissionService;
import com.education.platform.exam.vo.CourseExamMemberDetailVO;
import com.education.platform.exam.vo.CourseExamMemberListVO;
import com.education.platform.task.dto.TaskSubmissionSaveDTO;
import com.education.platform.task.vo.TaskSubmissionVO;
import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member")
@RequiredArgsConstructor
public class CourseExamMemberController {

    private final ExamSubmissionService examSubmissionService;

    @GetMapping("/courses/{courseId}/exams")
    public Result<List<CourseExamMemberListVO>> listCourseExams(@PathVariable Long courseId) {
        return Result.success(examSubmissionService.listCurrentMemberCourseExams(courseId));
    }

    @GetMapping("/course-exams/{examId}")
    public Result<CourseExamMemberDetailVO> detail(
            @PathVariable Long examId,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startedAt
    ) {
        return Result.success(examSubmissionService.getCurrentMemberExamDetail(examId, startedAt));
    }

    @GetMapping("/course-exams/{examId}/my-submissions")
    public Result<List<TaskSubmissionVO>> mySubmissions(@PathVariable Long examId) {
        return Result.success(examSubmissionService.listCurrentMemberExamSubmissions(examId));
    }

    @PostMapping("/course-exams/{examId}/submissions")
    public Result<Void> submit(@PathVariable Long examId, @Valid @RequestBody TaskSubmissionSaveDTO request) {
        examSubmissionService.submitCurrentMemberExam(examId, request);
        return Result.success();
    }
}
