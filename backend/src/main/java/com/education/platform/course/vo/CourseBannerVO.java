package com.education.platform.course.vo;

import lombok.Data;

@Data
public class CourseBannerVO {

    private Long id;
    private Long courseId;
    private String title;
    private String subTitle;
    private Integer sort;
    private Integer status;
    private String courseTitle;
    private String courseSubTitle;
    private String coverUrl;
    private String teacherName;
    private Integer studyCount;
}
