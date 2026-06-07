package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.service.CourseEnrollmentService;
import com.education.platform.course.service.CourseService;
import com.education.platform.course.vo.CourseVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member/courses")
@RequiredArgsConstructor
public class MemberCourseController {

    private final CourseService courseService;
    private final CourseEnrollmentService courseEnrollmentService;

    @GetMapping
    public Result<List<CourseVO>> list() {
        return Result.success(courseService.listCurrentMemberCourses());
    }

    @PostMapping("/{courseId}/enroll")
    public Result<Boolean> enroll(@PathVariable Long courseId) {
        return Result.success(courseEnrollmentService.enrollCurrentMember(courseId));
    }

    @DeleteMapping("/{courseId}/enroll")
    public Result<Boolean> unenroll(@PathVariable Long courseId) {
        return Result.success(courseEnrollmentService.unenrollCurrentMember(courseId));
    }
}
