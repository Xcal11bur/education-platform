package com.education.platform.course.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CoursePublishStatusUpdateDTO {

    @NotNull(message = "publishStatus must not be null")
    private Integer publishStatus;
}
