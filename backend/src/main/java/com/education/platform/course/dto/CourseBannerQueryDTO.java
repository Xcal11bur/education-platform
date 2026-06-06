package com.education.platform.course.dto;

import com.education.platform.common.model.PageQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class CourseBannerQueryDTO extends PageQuery {

    private Long courseId;
    private Integer status;
}
