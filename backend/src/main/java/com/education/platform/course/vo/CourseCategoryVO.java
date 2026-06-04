package com.education.platform.course.vo;

import java.util.List;
import lombok.Data;

@Data
public class CourseCategoryVO {

    private Long id;
    private Long parentId;
    private String name;
    private Integer level;
    private Integer sort;
    private Integer status;
    private List<CourseCategoryVO> children;
}
