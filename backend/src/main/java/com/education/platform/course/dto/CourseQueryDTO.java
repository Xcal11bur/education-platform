package com.education.platform.course.dto;

import com.education.platform.common.model.PageQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class CourseQueryDTO extends PageQuery {

    private String title;
    private Long teacherId;
    private Long categoryLevel2Id;
    private Integer publishStatus;
}
