package com.education.platform.member.dto;

import com.education.platform.common.model.PageQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class MemberQueryDTO extends PageQuery {

    private String mobile;
    private String nickname;
    private Integer status;
}
