package com.education.platform.teacher.vo;

import lombok.Data;

@Data
public class TeacherVO {

    private Long id;
    private String loginName;
    private String name;
    private String title;
    private String intro;
    private String avatar;
    private String mobile;
    private String email;
    private Integer status;
}
