package com.education.platform.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course_category")
public class CourseCategory extends BaseEntity {

    private Long parentId;
    private String name;
    private Integer level;
    private Integer sort;
    private Integer status;
}
