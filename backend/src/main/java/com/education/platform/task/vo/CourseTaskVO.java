package com.education.platform.task.vo;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CourseTaskVO {

    private Long id;
    private Long courseId;
    private String title;
    private Integer taskType;
    private String description;
    private Integer totalScore;
    private Integer passScore;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer durationMinutes;
    private Integer allowRetakeCount;
    private Integer status;
}
