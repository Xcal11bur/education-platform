package com.education.platform.course.vo;

import lombok.Data;

@Data
public class CourseSectionContentVO {

    private Long id;
    private Long courseId;
    private String courseTitle;
    private Long chapterId;
    private String chapterTitle;
    private Long sectionId;
    private String sectionTitle;
    private String title;
    private String contentType;
    private String contentHtml;
    private String contentJson;
    private String fileUrl;
    private String objectKey;
    private String fileName;
    private String mimeType;
    private Long fileSize;
    private Integer duration;
    private Integer sort;
    private Integer status;
}
