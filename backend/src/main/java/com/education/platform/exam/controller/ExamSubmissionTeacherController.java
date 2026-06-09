package com.education.platform.exam.controller;

import com.education.platform.common.result.Result;
import com.education.platform.exam.service.ExamSubmissionService;
import com.education.platform.task.dto.TaskSubmissionReviewDTO;
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
public class ExamSubmissionTeacherController {

    private final ExamSubmissionService examSubmissionService;

    @GetMapping("/course-exams/{examId}/submissions")
    public Result<List<TaskSubmissionTeacherVO>> list(@PathVariable Long examId) {
        return Result.success(examSubmissionService.listTeacherExamSubmissions(examId));
    }

    @GetMapping("/exam-submissions/{submissionId}")
    public Result<TaskSubmissionTeacherDetailVO> detail(@PathVariable Long submissionId) {
        return Result.success(examSubmissionService.getTeacherExamSubmissionDetail(submissionId));
    }

    @PutMapping("/exam-submissions/{submissionId}/review")
    public Result<Void> review(@PathVariable Long submissionId, @Valid @RequestBody TaskSubmissionReviewDTO request) {
        examSubmissionService.reviewTeacherExamSubmission(submissionId, request);
        return Result.success();
    }
}
