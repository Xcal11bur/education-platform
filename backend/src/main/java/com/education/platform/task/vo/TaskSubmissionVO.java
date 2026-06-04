package com.education.platform.task.vo;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class TaskSubmissionVO {

    private Long id;
    private Long taskId;
    private Long memberId;
    private Integer attemptNo;
    private String answersJson;
    private String attachmentUrl;
    private Integer objectiveScore;
    private Integer subjectiveScore;
    private Integer score;
    private Integer reviewStatus;
    private String reviewComment;
    private LocalDateTime submittedAt;
    private LocalDateTime reviewedAt;
}
