package com.education.platform.common.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class StatusUpdateDTO {

    @NotNull(message = "status must not be null")
    private Integer status;
}
