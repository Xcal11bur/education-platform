package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseSectionSaveDTO;
import com.education.platform.course.service.CourseSectionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class CourseSectionAdminController {

    private final CourseSectionService courseSectionService;

    @PostMapping("/chapters/{chapterId}/sections")
    public Result<Void> createSection(@PathVariable Long chapterId, @Valid @RequestBody CourseSectionSaveDTO request) {
        courseSectionService.createSection(chapterId, request);
        return Result.success();
    }

    @PutMapping("/sections/{id}")
    public Result<Void> updateSection(@PathVariable Long id, @Valid @RequestBody CourseSectionSaveDTO request) {
        courseSectionService.updateSection(id, request);
        return Result.success();
    }

    @DeleteMapping("/sections/{id}")
    public Result<Void> deleteSection(@PathVariable Long id) {
        courseSectionService.deleteSection(id);
        return Result.success();
    }
}
