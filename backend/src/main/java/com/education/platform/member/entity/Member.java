package com.education.platform.member.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("member")
public class Member extends BaseEntity {

    private String mobile;
    private String password;
    private String nickname;
    private String realName;
    private String avatar;
    private Integer gender;
    private LocalDate birthday;
    private Integer status;
    private BigDecimal balance;
}
