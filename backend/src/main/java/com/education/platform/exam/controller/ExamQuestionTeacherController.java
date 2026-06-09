package com.education.platform.exam.controller;

import com.education.platform.common.result.Result;
import com.education.platform.exam.service.ExamQuestionService;
import com.education.platform.task.dto.TaskQuestionSaveDTO;
import com.education.platform.task.vo.TaskQuestionVO;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/teacher")
@RequiredArgsConstructor
public class ExamQuestionTeacherController {

    private final ExamQuestionService examQuestionService;

    @GetMapping("/course-exams/{examId}/questions")
    public Result<List<TaskQuestionVO>> list(@PathVariable Long examId) {
        return Result.success(examQuestionService.listTeacherQuestions(examId));
    }

    @PostMapping("/course-exams/{examId}/questions")
    public Result<Void> create(@PathVariable Long examId, @Valid @RequestBody TaskQuestionSaveDTO request) {
        examQuestionService.createTeacherQuestion(examId, request);
        return Result.success();
    }

    @PutMapping("/exam-questions/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody TaskQuestionSaveDTO request) {
        examQuestionService.updateTeacherQuestion(id, request);
        return Result.success();
    }

    @DeleteMapping("/exam-questions/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        examQuestionService.deleteTeacherQuestion(id);
        return Result.success();
    }
}
