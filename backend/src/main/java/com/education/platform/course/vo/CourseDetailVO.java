package com.education.platform.course.vo;

import java.math.BigDecimal;
import java.util.List;
import lombok.Data;

@Data
public class CourseDetailVO {

    private Long id;
    private String title;
    private String subTitle;
    private String coverUrl;
    private String description;
    private Integer difficulty;
    private BigDecimal price;
    private Integer publishStatus;
    private Integer studyCount;
    private Integer sort;
    private Long teacherId;
    private Long categoryLevel1Id;
    private Long categoryLevel2Id;
    private CourseTeacherVO teacher;
    private CourseCategoryVO categoryLevel1;
    private CourseCategoryVO categoryLevel2;
    private List<CourseChapterVO> chapters;
    private Boolean enrolled;
    private Boolean favorited;
    private BigDecimal studyProgress;
    private Long lastStudySectionId;
}
