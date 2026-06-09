package com.education.platform.course.service;

import com.education.platform.common.model.PageResponse;
import com.education.platform.course.dto.CourseReviewQueryDTO;
import com.education.platform.course.dto.CourseReviewSaveDTO;
import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.course.entity.CourseReview;
import com.education.platform.course.vo.CourseReviewAdminVO;
import com.education.platform.course.vo.CourseReviewPortalVO;
import com.education.platform.course.vo.CourseReviewSummaryVO;

public interface CourseReviewService extends IService<CourseReview> {

    void submitCurrentMemberReview(CourseReviewSaveDTO request);

    void deleteCurrentMemberReview(Long courseId);

    PageResponse<CourseReviewAdminVO> pageAdminReviews(CourseReviewQueryDTO queryDTO);

    void updateReviewStatus(Long id, Integer status);

    void deleteReview(Long id);

    PageResponse<CourseReviewPortalVO> pagePortalReviews(CourseReviewQueryDTO queryDTO);

    CourseReviewSummaryVO getPortalReviewSummary(Long courseId);

    CourseReviewSummaryVO getCurrentMemberReviewSummary(Long courseId);

    String getPortalReviewAvatarUrl(Long reviewId);
}
