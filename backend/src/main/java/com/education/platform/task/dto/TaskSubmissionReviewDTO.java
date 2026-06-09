package com.education.platform.task.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import lombok.Data;

@Data
public class TaskSubmissionReviewDTO {

    private String reviewComment;

    @NotEmpty(message = "questionScores must not be empty")
    private List<QuestionScoreDTO> questionScores;

    @Data
    public static class QuestionScoreDTO {

        @NotNull(message = "questionId must not be null")
        private Long questionId;

        @NotNull(message = "score must not be null")
        private Integer score;
    }
}
