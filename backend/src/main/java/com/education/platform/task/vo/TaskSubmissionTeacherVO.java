package com.education.platform.task.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class TaskSubmissionTeacherVO {

    private Long id;
    private Long taskId;
    private String taskTitle;
    private Long memberId;
    private String memberName;
    private String memberMobile;
    private Integer attemptNo;
    private Integer objectiveScore;
    private Integer subjectiveScore;
    private Integer score;
    private Integer reviewStatus;
    private String reviewComment;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime submittedAt;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime reviewedAt;
}
