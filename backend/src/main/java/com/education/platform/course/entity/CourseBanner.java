package com.education.platform.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course_banner")
public class CourseBanner extends BaseEntity {

    private Long courseId;
    private String title;
    private String subTitle;
    private Integer sort;
    private Integer status;
}
