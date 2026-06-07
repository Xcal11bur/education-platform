package com.education.platform.course.vo;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CourseMaterialVO {

    private Long id;
    private Long courseId;
    private String courseTitle;
    private String materialName;
    private Integer materialType;
    private String fileUrl;
    private Long fileSize;
    private Integer downloadLimit;
    private Integer sort;
    private LocalDateTime createdAt;
}
