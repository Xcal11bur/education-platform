package com.education.platform.member.vo;

import java.time.LocalDate;
import lombok.Data;

@Data
public class MemberProfileVO {

    private Long id;
    private String mobile;
    private String nickname;
    private String realName;
    private String avatar;
    private Integer gender;
    private LocalDate birthday;
}
