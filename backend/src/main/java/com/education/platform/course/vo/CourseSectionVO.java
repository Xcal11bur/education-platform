package com.education.platform.course.vo;

import lombok.Data;

@Data
public class CourseSectionVO {

    private Long id;
    private Long courseId;
    private Long chapterId;
    private String title;
    private Integer isFreeTrial;
    private Integer sort;
}
