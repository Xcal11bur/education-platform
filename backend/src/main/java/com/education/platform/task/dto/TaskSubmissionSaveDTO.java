package com.education.platform.task.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TaskSubmissionSaveDTO {

    @NotBlank(message = "answersJson must not be blank")
    private String answersJson;
    private String attachmentUrl;
}
