package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseChapterSaveDTO;
import com.education.platform.course.service.CourseChapterService;
import com.education.platform.course.vo.CourseChapterVO;
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
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class CourseChapterAdminController {

    private final CourseChapterService courseChapterService;

    @PostMapping("/courses/{courseId}/chapters")
    public Result<Void> createChapter(@PathVariable Long courseId, @Valid @RequestBody CourseChapterSaveDTO request) {
        courseChapterService.createChapter(courseId, request);
        return Result.success();
    }

    @PutMapping("/chapters/{id}")
    public Result<Void> updateChapter(@PathVariable Long id, @Valid @RequestBody CourseChapterSaveDTO request) {
        courseChapterService.updateChapter(id, request);
        return Result.success();
    }

    @DeleteMapping("/chapters/{id}")
    public Result<Void> deleteChapter(@PathVariable Long id) {
        courseChapterService.deleteChapter(id);
        return Result.success();
    }

    @GetMapping("/courses/{courseId}/chapters/tree")
    public Result<List<CourseChapterVO>> tree(@PathVariable Long courseId) {
        return Result.success(courseChapterService.getChapterTree(courseId, false));
    }
}
