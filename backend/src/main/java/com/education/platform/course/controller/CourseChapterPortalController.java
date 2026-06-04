package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.service.CourseChapterService;
import com.education.platform.course.vo.CourseChapterVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/portal/courses")
@RequiredArgsConstructor
public class CourseChapterPortalController {

    private final CourseChapterService courseChapterService;

    @GetMapping("/{courseId}/chapters/tree")
    public Result<List<CourseChapterVO>> tree(@PathVariable Long courseId) {
        return Result.success(courseChapterService.getChapterTree(courseId, true));
    }
}
