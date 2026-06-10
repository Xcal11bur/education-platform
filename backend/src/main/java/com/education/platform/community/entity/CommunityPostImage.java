package com.education.platform.community.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("community_post_image")
public class CommunityPostImage extends BaseEntity {

    private Long postId;
    private String imageUrl;
    private Integer sort;
}
