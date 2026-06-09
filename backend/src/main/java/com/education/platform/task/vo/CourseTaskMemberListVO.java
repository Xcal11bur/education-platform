package com.education.platform.task.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CourseTaskMemberListVO {

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
    private Integer allowRetakeCount;
    private Integer questionCount;
    private Boolean completed;
    private Integer latestScore;
    private Integer latestReviewStatus;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime latestSubmittedAt;
    private Integer usedAttempts;
    private Integer remainingAttempts;
    private Boolean canSubmit;
}
