package com.education.platform.community.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("community_post")
public class CommunityPost extends BaseEntity {

    private Long memberId;
    private String title;
    private String content;
    private Integer status;
    private Integer commentCount;
    private Integer likeCount;
    private Integer favoriteCount;
    private Integer viewCount;
}
