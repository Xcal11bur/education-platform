package com.education.platform.course.vo;

import lombok.Data;

@Data
public class CourseBannerPortalVO {

    private Long id;
    private Long courseId;
    private String title;
    private String subTitle;
    private String coverUrl;
    private String teacherName;
    private String categoryLevel1Name;
    private String categoryLevel2Name;
    private Integer studyCount;
}
