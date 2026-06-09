package com.education.platform.exam.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import java.time.LocalDateTime;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("exam_submission")
public class ExamSubmission extends BaseEntity {

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
