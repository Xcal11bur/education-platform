package com.education.platform.task.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;
import java.util.List;
import lombok.Data;

@Data
public class TaskSubmissionTeacherDetailVO {

    private Long id;
    private Long taskId;
    private String taskTitle;
    private Long courseId;
    private String courseTitle;
    private Long memberId;
    private String memberName;
    private String memberMobile;
    private Integer attemptNo;
    private Integer totalScore;
    private Integer passScore;
    private Integer objectiveScore;
    private Integer subjectiveScore;
    private Integer score;
    private Integer reviewStatus;
    private String reviewComment;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime submittedAt;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime reviewedAt;
    private List<TaskSubmissionQuestionTeacherVO> questions;
}
