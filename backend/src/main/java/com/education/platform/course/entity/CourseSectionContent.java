package com.education.platform.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course_section_content")
public class CourseSectionContent extends BaseEntity {

    private Long courseId;
    private Long chapterId;
    private Long sectionId;
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
