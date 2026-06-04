package com.education.platform.course.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Data;

@Data
public class CourseSaveDTO {

    @NotBlank(message = "title must not be blank")
    private String title;

    private String subTitle;

    @NotNull(message = "teacherId must not be null")
    private Long teacherId;

    @NotNull(message = "categoryLevel1Id must not be null")
    private Long categoryLevel1Id;

    @NotNull(message = "categoryLevel2Id must not be null")
    private Long categoryLevel2Id;

    private String coverUrl;
    private String description;
    private Integer difficulty;
    private BigDecimal price;
    private Integer publishStatus;
    private Integer sort;
}
