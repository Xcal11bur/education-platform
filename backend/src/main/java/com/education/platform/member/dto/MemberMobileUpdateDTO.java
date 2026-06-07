package com.education.platform.member.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class MemberMobileUpdateDTO {

    @NotBlank(message = "mobile must not be blank")
    @Pattern(regexp = "^1\\d{10}$", message = "mobile format is invalid")
    private String mobile;
}
