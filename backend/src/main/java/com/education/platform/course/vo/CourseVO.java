package com.education.platform.course.vo;

import java.math.BigDecimal;
import lombok.Data;

@Data
public class CourseVO {

    private Long id;
    private String title;
    private String subTitle;
    private Long teacherId;
    private String teacherName;
    private Long categoryLevel1Id;
    private String categoryLevel1Name;
    private Long categoryLevel2Id;
    private String categoryLevel2Name;
    private String coverUrl;
    private String description;
    private Integer difficulty;
    private BigDecimal price;
    private Integer publishStatus;
    private Integer studyCount;
    private Integer sort;
    private Boolean enrolled;
    private Boolean favorited;
    private BigDecimal studyProgress;
    private Long lastStudySectionId;
}
