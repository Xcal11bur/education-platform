package com.education.platform.task.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TaskQuestionSaveDTO {

    @NotNull(message = "questionType must not be null")
    private Integer questionType;

    @NotBlank(message = "stem must not be blank")
    private String stem;

    private String optionsJson;
    private String answerJson;
    private String analysis;
    @NotNull(message = "score must not be null")
    private Integer score;
    private Integer sort;
}
