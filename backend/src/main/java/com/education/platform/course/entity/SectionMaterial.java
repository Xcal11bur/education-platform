package com.education.platform.course.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("section_material")
public class SectionMaterial extends BaseEntity {

    private Long courseId;
    private Long chapterId;
    private Long sectionId;
    private String materialName;
    private Integer materialType;
    private String fileUrl;
    private Long fileSize;
    private Integer downloadLimit;
    private Integer sort;
}
