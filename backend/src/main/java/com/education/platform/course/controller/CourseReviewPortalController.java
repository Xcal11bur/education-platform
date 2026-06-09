package com.education.platform.course.controller;

import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseReviewQueryDTO;
import com.education.platform.course.service.CourseReviewService;
import com.education.platform.course.vo.CourseReviewPortalVO;
import com.education.platform.course.vo.CourseReviewSummaryVO;
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
public class CourseReviewPortalController {

    private final CourseReviewService courseReviewService;

    @GetMapping("/{courseId}/reviews")
    public Result<PageResponse<CourseReviewPortalVO>> list(@PathVariable Long courseId,
                                                           @Valid @ModelAttribute CourseReviewQueryDTO queryDTO) {
        queryDTO.setCourseId(courseId);
        return Result.success(courseReviewService.pagePortalReviews(queryDTO));
    }

    @GetMapping("/{courseId}/review-summary")
    public Result<CourseReviewSummaryVO> summary(@PathVariable Long courseId) {
        return Result.success(courseReviewService.getPortalReviewSummary(courseId));
    }
}
