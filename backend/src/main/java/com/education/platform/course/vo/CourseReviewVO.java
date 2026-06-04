package com.education.platform.course.vo;

import lombok.Data;

@Data
public class CourseReviewVO {

    private Long id;
    private Long courseId;
    private Long memberId;
    private Integer score;
    private String content;
    private Integer anonymousFlag;
    private Integer status;
}
