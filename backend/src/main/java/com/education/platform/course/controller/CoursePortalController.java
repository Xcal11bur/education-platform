package com.education.platform.course.controller;

import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.course.vo.CourseDetailVO;
import com.education.platform.course.dto.CourseQueryDTO;
import com.education.platform.course.service.CourseService;
import com.education.platform.course.vo.CourseVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/portal/courses")
@RequiredArgsConstructor
public class CoursePortalController {

    private final CourseService courseService;

    @GetMapping
    public Result<PageResponse<CourseVO>> list(@Valid @ModelAttribute CourseQueryDTO queryDTO) {
        return Result.success(courseService.pagePortalCourses(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<CourseDetailVO> detail(@PathVariable Long id) {
        return Result.success(courseService.getPortalCourseDetail(id));
    }
}
