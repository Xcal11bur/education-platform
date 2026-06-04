package com.education.platform.course.vo;

import lombok.Data;

@Data
public class SectionMaterialVO {

    private Long id;
    private Long courseId;
    private String courseTitle;
    private Long chapterId;
    private String chapterTitle;
    private Long sectionId;
    private String sectionTitle;
    private String materialName;
    private Integer materialType;
    private String fileUrl;
    private Long fileSize;
    private Integer downloadLimit;
    private Integer sort;
}
