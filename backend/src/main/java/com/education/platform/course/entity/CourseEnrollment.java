package com.education.platform.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course_enrollment")
public class CourseEnrollment extends BaseEntity {

    private Long courseId;
    private Long memberId;
    private Integer enrollType;
    private String sourceOrderNo;
    private BigDecimal studyProgress;
    private Long lastStudySectionId;
    private Integer status;
    private LocalDateTime expireTime;
}
