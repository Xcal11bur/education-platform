package com.education.platform.course.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CourseCategorySaveDTO {

    @NotNull(message = "parentId must not be null")
    private Long parentId;

    @NotBlank(message = "name must not be blank")
    private String name;

    @NotNull(message = "level must not be null")
    private Integer level;

    private Integer sort;
    private Integer status;
}
