package com.education.platform.course.controller;

import com.education.platform.common.dto.StatusUpdateDTO;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseReviewQueryDTO;
import com.education.platform.course.service.CourseReviewService;
import com.education.platform.course.vo.CourseReviewAdminVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/course-reviews")
@RequiredArgsConstructor
public class CourseReviewAdminController {

    private final CourseReviewService courseReviewService;

    @GetMapping
    public Result<PageResponse<CourseReviewAdminVO>> list(@Valid @ModelAttribute CourseReviewQueryDTO queryDTO) {
        return Result.success(courseReviewService.pageAdminReviews(queryDTO));
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @Valid @RequestBody StatusUpdateDTO request) {
        courseReviewService.updateReviewStatus(id, request.getStatus());
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseReviewService.deleteReview(id);
        return Result.success();
    }
}
