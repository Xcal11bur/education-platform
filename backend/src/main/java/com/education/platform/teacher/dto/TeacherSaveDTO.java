package com.education.platform.teacher.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TeacherSaveDTO {

    @NotBlank(message = "loginName must not be blank")
    private String loginName;

    @NotBlank(message = "name must not be blank")
    private String name;

    @NotBlank(message = "mobile must not be blank")
    private String mobile;

    private String password;
    private String title;
    private String intro;
    private String avatar;
    private String email;
    private Integer status;
}
