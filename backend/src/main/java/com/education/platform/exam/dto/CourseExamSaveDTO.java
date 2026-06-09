package com.education.platform.exam.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CourseExamSaveDTO {

    @NotNull(message = "courseId must not be null")
    private Long courseId;

    @NotBlank(message = "title must not be blank")
    private String title;

    private Integer totalScore;
    private Integer passScore;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;
    private Integer durationMinutes;
    private Integer allowRetakeCount;
    private Integer status;
}
