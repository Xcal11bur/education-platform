package com.education.platform.common.enums;

import lombok.Getter;

@Getter
public enum StatusEnum {
    DISABLED(0),
    ENABLED(1);

    private final int code;

    StatusEnum(int code) {
        this.code = code;
    }
}
