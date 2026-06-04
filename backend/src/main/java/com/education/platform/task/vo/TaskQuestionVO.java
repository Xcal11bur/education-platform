package com.education.platform.task.vo;

import lombok.Data;

@Data
public class TaskQuestionVO {

    private Long id;
    private Long taskId;
    private Integer questionType;
    private String stem;
    private String optionsJson;
    private String answerJson;
    private String analysis;
    private Integer score;
    private Integer sort;
}
