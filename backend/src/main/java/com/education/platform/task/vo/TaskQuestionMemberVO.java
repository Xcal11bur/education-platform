package com.education.platform.task.vo;

import lombok.Data;

@Data
public class TaskQuestionMemberVO {

    private Long id;
    private Integer questionType;
    private String stem;
    private String optionsJson;
    private Integer score;
    private Integer sort;
    private String myAnswerJson;
    private Integer earnedScore;
    private String analysis;
}
