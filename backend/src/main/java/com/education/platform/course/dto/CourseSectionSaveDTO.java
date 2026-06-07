package com.education.platform.course.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CourseSectionSaveDTO {

    @NotBlank(message = "title must not be blank")
    private String title;

    private Integer isFreeTrial;
    private Integer sort;
}
