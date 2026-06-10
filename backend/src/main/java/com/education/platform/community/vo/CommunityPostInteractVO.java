package com.education.platform.community.vo;

import lombok.Data;

@Data
public class CommunityPostInteractVO {

    private Integer commentCount;
    private Integer likeCount;
    private Integer favoriteCount;
    private Boolean liked;
    private Boolean favorited;
}
