package com.education.platform.member.dto;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;
import lombok.Data;

@Data
public class MemberProfileUpdateDTO {

    @NotBlank(message = "nickname must not be blank")
    private String nickname;

    private String realName;
    private String avatar;
    private Integer gender;
    private LocalDate birthday;
}
