package com.education.platform.course.controller;

import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CoursePublishStatusUpdateDTO;
import com.education.platform.course.dto.CourseQueryDTO;
import com.education.platform.course.dto.CourseSaveDTO;
import com.education.platform.course.service.CourseService;
import com.education.platform.course.vo.CourseDetailVO;
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
@RequestMapping("/api/v1/teacher/courses")
@RequiredArgsConstructor
public class CourseTeacherController {

    private final CourseService courseService;

    @GetMapping
    public Result<PageResponse<CourseVO>> list(@Valid @ModelAttribute CourseQueryDTO queryDTO) {
        return Result.success(courseService.pageTeacherCourses(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<CourseDetailVO> detail(@PathVariable Long id) {
        return Result.success(courseService.getTeacherCourseDetail(id));
    }

    @PostMapping
    public Result<Void> create(@Valid @RequestBody CourseSaveDTO request) {
        courseService.createTeacherCourse(request);
        return Result.success();
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody CourseSaveDTO request) {
        courseService.updateTeacherCourse(id, request);
        return Result.success();
    }

    @PutMapping("/{id}/publish-status")
    public Result<Void> updatePublishStatus(@PathVariable Long id,
                                            @Valid @RequestBody CoursePublishStatusUpdateDTO request) {
        courseService.updateTeacherPublishStatus(id, request.getPublishStatus());
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseService.deleteTeacherCourse(id);
        return Result.success();
    }
}
