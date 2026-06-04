package com.education.platform.course.vo;

import java.util.List;
import lombok.Data;

@Data
public class CourseChapterVO {

    private Long id;
    private Long courseId;
    private String title;
    private Integer sort;
    private List<CourseSectionVO> sections;
}
