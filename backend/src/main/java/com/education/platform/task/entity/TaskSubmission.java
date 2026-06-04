package com.education.platform.task.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import java.time.LocalDateTime;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("task_submission")
public class TaskSubmission extends BaseEntity {

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
