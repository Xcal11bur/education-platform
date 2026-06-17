package com.education.platform.member.vo;

import java.time.LocalDate;
import java.math.BigDecimal;
import lombok.Data;

@Data
public class MemberVO {

    private Long id;
    private String mobile;
    private String nickname;
    private String realName;
    private String avatar;
    private Integer gender;
    private LocalDate birthday;
    private Integer status;
    private BigDecimal balance;
}
