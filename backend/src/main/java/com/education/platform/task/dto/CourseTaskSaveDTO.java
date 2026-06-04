package com.education.platform.task.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CourseTaskSaveDTO {

    @NotNull(message = "courseId must not be null")
    private Long courseId;

    @NotBlank(message = "title must not be blank")
    private String title;

    @NotNull(message = "taskType must not be null")
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
