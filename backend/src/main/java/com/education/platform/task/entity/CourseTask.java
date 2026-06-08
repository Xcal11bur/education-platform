package com.education.platform.task.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import java.time.LocalDateTime;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course_task")
public class CourseTask extends BaseEntity {

    private Long courseId;
    private String title;
    private String description;
    private Integer totalScore;
    private Integer passScore;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer durationMinutes;
    private Integer allowRetakeCount;
    private Integer status;
}
