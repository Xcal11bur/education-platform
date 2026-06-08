package com.education.platform.member.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class MemberSaveDTO {

    @NotBlank(message = "mobile must not be blank")
    @Pattern(regexp = "^1\\d{10}$", message = "mobile format is invalid")
    private String mobile;

    @NotBlank(message = "nickname must not be blank")
    private String nickname;

    @Size(min = 6, max = 20, message = "password length must be between 6 and 20")
    private String password;

    private String realName;
    private String avatar;
    private Integer gender;
    private java.time.LocalDate birthday;
    private Integer status;
}
