package com.education.platform.task.controller;

import com.education.platform.common.result.Result;
import com.education.platform.task.dto.TaskQuestionSaveDTO;
import com.education.platform.task.service.TaskQuestionService;
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
public class TaskQuestionTeacherController {

    private final TaskQuestionService taskQuestionService;

    @GetMapping("/course-tasks/{taskId}/questions")
    public Result<List<TaskQuestionVO>> list(@PathVariable Long taskId) {
        return Result.success(taskQuestionService.listTeacherQuestions(taskId));
    }

    @PostMapping("/course-tasks/{taskId}/questions")
    public Result<Void> create(@PathVariable Long taskId, @Valid @RequestBody TaskQuestionSaveDTO request) {
        taskQuestionService.createTeacherQuestion(taskId, request);
        return Result.success();
    }

    @PutMapping("/task-questions/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody TaskQuestionSaveDTO request) {
        taskQuestionService.updateTeacherQuestion(id, request);
        return Result.success();
    }

    @DeleteMapping("/task-questions/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        taskQuestionService.deleteTeacherQuestion(id);
        return Result.success();
    }
}
