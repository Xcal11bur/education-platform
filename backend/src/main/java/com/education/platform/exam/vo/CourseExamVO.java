package com.education.platform.exam.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CourseExamVO {

    private Long id;
    private Long courseId;
    private String courseTitle;
    private String title;
    private Integer totalScore;
    private Integer passScore;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;
    private Integer durationMinutes;
    private Integer status;
    private Integer questionCount;
}
