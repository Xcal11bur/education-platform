package com.education.platform.task.controller;

import com.education.platform.common.result.Result;
import com.education.platform.task.dto.CourseTaskSaveDTO;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/course-tasks")
public class CourseTaskAdminController {

    @GetMapping
    public Result<String> list() {
        return Result.success("course task list placeholder");
    }

    @PostMapping
    public Result<Void> save(@Valid @RequestBody CourseTaskSaveDTO request) {
        return Result.success();
    }
}
