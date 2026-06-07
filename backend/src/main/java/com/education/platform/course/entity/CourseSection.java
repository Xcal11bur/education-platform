package com.education.platform.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course_section")
public class CourseSection extends BaseEntity {

    private Long courseId;
    private Long chapterId;
    private String title;
    private Integer isFreeTrial;
    private Integer sort;
}
