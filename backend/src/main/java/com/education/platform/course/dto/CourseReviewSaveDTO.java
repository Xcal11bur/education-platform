package com.education.platform.course.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CourseReviewSaveDTO {

    @NotNull(message = "courseId must not be null")
    private Long courseId;

    @NotNull(message = "score must not be null")
    @Min(value = 1, message = "score must be at least 1")
    @Max(value = 5, message = "score must be at most 5")
    private Integer score;

    private String content;
    private Integer anonymousFlag;
}
