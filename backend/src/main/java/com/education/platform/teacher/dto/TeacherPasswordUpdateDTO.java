package com.education.platform.teacher.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class TeacherPasswordUpdateDTO {

    @NotBlank(message = "oldPassword must not be blank")
    private String oldPassword;

    @NotBlank(message = "newPassword must not be blank")
    @Size(min = 6, max = 20, message = "password length must be between 6 and 20")
    private String newPassword;

    @NotBlank(message = "confirmPassword must not be blank")
    private String confirmPassword;
}
