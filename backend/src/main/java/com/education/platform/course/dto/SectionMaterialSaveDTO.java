package com.education.platform.course.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SectionMaterialSaveDTO {

    @NotBlank(message = "materialName must not be blank")
    private String materialName;

    @NotNull(message = "materialType must not be null")
    private Integer materialType;

    @NotBlank(message = "fileUrl must not be blank")
    private String fileUrl;

    private Long fileSize;
    private Integer downloadLimit;
    private Integer sort;
}
