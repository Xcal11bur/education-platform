package com.education.platform.task.controller;

import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.task.dto.CourseTaskQueryDTO;
import com.education.platform.task.dto.CourseTaskSaveDTO;
import com.education.platform.task.service.CourseTaskService;
import com.education.platform.task.vo.CourseTaskVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/teacher/course-tasks")
@RequiredArgsConstructor
public class CourseTaskTeacherController {

    private final CourseTaskService courseTaskService;

    @GetMapping
    public Result<PageResponse<CourseTaskVO>> list(@Valid @ModelAttribute CourseTaskQueryDTO queryDTO) {
        return Result.success(courseTaskService.pageTeacherTasks(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<CourseTaskVO> detail(@PathVariable Long id) {
        return Result.success(courseTaskService.getTeacherTaskDetail(id));
    }

    @PostMapping
    public Result<Void> create(@Valid @RequestBody CourseTaskSaveDTO request) {
        courseTaskService.createTeacherTask(request);
        return Result.success();
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody CourseTaskSaveDTO request) {
        courseTaskService.updateTeacherTask(id, request);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseTaskService.deleteTeacherTask(id);
        return Result.success();
    }
}
