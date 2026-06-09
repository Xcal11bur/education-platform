package com.education.platform.exam.dto;

import com.education.platform.common.model.PageQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class CourseExamQueryDTO extends PageQuery {

    private Long courseId;
    private String title;
    private Integer status;
}
