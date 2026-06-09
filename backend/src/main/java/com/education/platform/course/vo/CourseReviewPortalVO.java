package com.education.platform.course.vo;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CourseReviewPortalVO {

    private Long id;
    private Integer score;
    private String content;
    private String memberDisplayName;
    private String memberAvatar;
    private String avatar;
    private String memberAvatarProxy;
    private LocalDateTime createdAt;
}
