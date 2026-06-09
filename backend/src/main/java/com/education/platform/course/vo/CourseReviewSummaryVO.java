package com.education.platform.course.vo;

import java.util.Map;
import lombok.Data;

@Data
public class CourseReviewSummaryVO {

    private Double avgScore;
    private Long reviewCount;
    private Map<Integer, Long> scoreDistribution;
    private Boolean canReview;
    private Boolean hasReviewed;
    private Integer myReviewStatus;
}
