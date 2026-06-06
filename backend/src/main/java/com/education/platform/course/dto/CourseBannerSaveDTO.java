package com.education.platform.course.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CourseBannerSaveDTO {

    @NotNull(message = "courseId must not be null")
    private Long courseId;

    private String title;
    private String subTitle;
    private Integer sort;
    private Integer status;
}
