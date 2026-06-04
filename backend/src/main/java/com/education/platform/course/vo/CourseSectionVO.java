package com.education.platform.course.vo;

import lombok.Data;

@Data
public class CourseSectionVO {

    private Long id;
    private Long courseId;
    private Long chapterId;
    private String title;
    private Integer sectionType;
    private String content;
    private String videoUrl;
    private Integer duration;
    private Integer isFreeTrial;
    private Integer sort;
}
