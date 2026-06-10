package com.education.platform.community.dto;

import com.education.platform.common.model.PageQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class CommunityPostQueryDTO extends PageQuery {

    private String keyword;
    private String sortMode;
}
