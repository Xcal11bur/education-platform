package com.education.platform.course.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CourseSectionSaveDTO {

    @NotBlank(message = "title must not be blank")
    private String title;

    @NotNull(message = "sectionType must not be null")
    private Integer sectionType;

    private String content;
    private String videoUrl;
    private Integer duration;
    private Integer isFreeTrial;
    private Integer sort;
}
