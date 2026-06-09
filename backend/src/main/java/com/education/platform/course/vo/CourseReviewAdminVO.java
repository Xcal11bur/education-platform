package com.education.platform.course.vo;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CourseReviewAdminVO {

    private Long id;
    private Long courseId;
    private String courseTitle;
    private Long memberId;
    private String memberNickname;
    private String memberMobile;
    private Integer score;
    private String content;
    private Integer anonymousFlag;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime reviewedAt;
}
