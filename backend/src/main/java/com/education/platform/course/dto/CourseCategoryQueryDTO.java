package com.education.platform.course.dto;

import lombok.Data;

@Data
public class CourseCategoryQueryDTO {

    private Long parentId;
    private Integer level;
    private Integer status;
    private String name;
}
