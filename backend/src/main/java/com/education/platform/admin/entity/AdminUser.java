package com.education.platform.admin.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import java.time.LocalDateTime;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("admin_user")
public class AdminUser extends BaseEntity {

    private String username;
    private String password;
    private String realName;
    private String mobile;
    private String email;
    private Integer status;
    private LocalDateTime lastLoginAt;
}
