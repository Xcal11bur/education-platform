package com.education.platform.community.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("community_comment")
public class CommunityComment extends BaseEntity {

    private Long postId;
    private Long memberId;
    private Long parentId;
    private Long replyToMemberId;
    private String content;
    private Integer status;
}
