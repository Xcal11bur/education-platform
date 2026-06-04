package com.education.platform.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import java.math.BigDecimal;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course")
public class Course extends BaseEntity {

    private String title;
    private String subTitle;
    private Long teacherId;
    private Long categoryLevel1Id;
    private Long categoryLevel2Id;
    private String coverUrl;
    private String description;
    private Integer difficulty;
    private BigDecimal price;
    private Integer publishStatus;
    private Integer studyCount;
    private Integer sort;
}
