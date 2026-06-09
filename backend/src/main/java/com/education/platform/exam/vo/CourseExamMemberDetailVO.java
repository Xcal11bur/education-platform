package com.education.platform.exam.vo;

import com.education.platform.task.vo.TaskQuestionMemberVO;
import com.education.platform.task.vo.TaskSubmissionVO;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;
import java.util.List;
import lombok.Data;

@Data
public class CourseExamMemberDetailVO {

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
    private Integer questionCount;
    private Boolean submitted;
    private Boolean canSubmit;
    private Integer usedAttempts;
    private Integer remainingAttempts;
    private TaskSubmissionVO latestSubmission;
    private List<TaskQuestionMemberVO> questions;
}
