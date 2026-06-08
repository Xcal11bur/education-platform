package com.education.platform.teacher.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TeacherProfileUpdateDTO {

    @NotBlank(message = "name must not be blank")
    private String name;

    @NotBlank(message = "mobile must not be blank")
    private String mobile;

    private String title;
    private String intro;
    private String avatar;
    private String email;
}
