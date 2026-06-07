package com.education.platform.course.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CourseChapterSaveDTO {

    @NotBlank(message = "title must not be blank")
    private String title;
}
