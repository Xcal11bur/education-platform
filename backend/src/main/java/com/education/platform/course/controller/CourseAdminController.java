package com.education.platform.course.controller;

import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.course.vo.CourseDetailVO;
import com.education.platform.course.dto.CoursePublishStatusUpdateDTO;
import com.education.platform.course.dto.CourseQueryDTO;
import com.education.platform.course.dto.CourseSaveDTO;
import com.education.platform.course.service.CourseService;
import com.education.platform.course.vo.CourseVO;
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
@RequestMapping("/api/v1/admin/courses")
@RequiredArgsConstructor
public class CourseAdminController {

    private final CourseService courseService;

    @GetMapping
    public Result<PageResponse<CourseVO>> list(@Valid @ModelAttribute CourseQueryDTO queryDTO) {
        return Result.success(courseService.pageAdminCourses(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<CourseDetailVO> detail(@PathVariable Long id) {
        return Result.success(courseService.getAdminCourseDetail(id));
    }

    @PostMapping
    public Result<Void> save(@Valid @RequestBody CourseSaveDTO request) {
        courseService.createCourse(request);
        return Result.success();
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody CourseSaveDTO request) {
        courseService.updateCourse(id, request);
        return Result.success();
    }

    @PutMapping("/{id}/publish-status")
    public Result<Void> updatePublishStatus(@PathVariable Long id,
                                            @Valid @RequestBody CoursePublishStatusUpdateDTO request) {
        courseService.updatePublishStatus(id, request.getPublishStatus());
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseService.deleteCourse(id);
        return Result.success();
    }
}
