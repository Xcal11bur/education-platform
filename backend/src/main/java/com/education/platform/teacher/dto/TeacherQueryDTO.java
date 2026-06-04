package com.education.platform.teacher.dto;

import com.education.platform.common.model.PageQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class TeacherQueryDTO extends PageQuery {

    private String name;
    private String mobile;
    private Integer status;
}
