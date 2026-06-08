package com.education.platform.task.dto;

import com.education.platform.common.model.PageQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class CourseTaskQueryDTO extends PageQuery {

    private Long courseId;
    private String title;
    private Integer status;
}
