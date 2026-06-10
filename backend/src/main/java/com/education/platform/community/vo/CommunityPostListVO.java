package com.education.platform.community.vo;

import java.time.LocalDateTime;
import java.util.List;
import lombok.Data;

@Data
public class CommunityPostListVO {

    private Long id;
    private Long authorId;
    private String authorName;
    private String authorAvatar;
    private String title;
    private String content;
    private List<String> images;
    private Integer commentCount;
    private Integer likeCount;
    private Integer favoriteCount;
    private Boolean liked;
    private Boolean favorited;
    private LocalDateTime createdAt;
}
