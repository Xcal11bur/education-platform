package com.education.platform.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import java.time.LocalDateTime;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course_review")
public class CourseReview extends BaseEntity {

    private Long courseId;
    private Long memberId;
    private Integer score;
    private String content;
    private Integer anonymousFlag;
    private Integer status;
    private LocalDateTime reviewedAt;
}
