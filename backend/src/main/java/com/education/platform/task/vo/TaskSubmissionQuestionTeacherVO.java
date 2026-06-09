package com.education.platform.task.vo;

import lombok.Data;

@Data
public class TaskSubmissionQuestionTeacherVO {

    private Long questionId;
    private Integer questionType;
    private String stem;
    private String optionsJson;
    private String answerJson;
    private String analysis;
    private Integer score;
    private Integer sort;
    private String memberAnswerJson;
    private Integer earnedScore;
}
