package com.education.platform.teacher.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("teacher")
public class Teacher extends BaseEntity {

    private String loginName;
    private String password;
    private String name;
    private String title;
    private String intro;
    private String avatar;
    private String mobile;
    private String email;
    private Integer status;
}
