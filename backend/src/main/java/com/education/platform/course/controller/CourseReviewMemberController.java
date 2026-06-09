package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseReviewSaveDTO;
import com.education.platform.course.service.CourseReviewService;
import com.education.platform.course.vo.CourseReviewSummaryVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member/course-reviews")
@RequiredArgsConstructor
public class CourseReviewMemberController {

    private final CourseReviewService courseReviewService;

    @PostMapping
    public Result<Void> create(@Valid @RequestBody CourseReviewSaveDTO request) {
        courseReviewService.submitCurrentMemberReview(request);
        return Result.success();
    }

    @GetMapping("/my-summary")
    public Result<CourseReviewSummaryVO> mySummary(@RequestParam Long courseId) {
        return Result.success(courseReviewService.getCurrentMemberReviewSummary(courseId));
    }
}
