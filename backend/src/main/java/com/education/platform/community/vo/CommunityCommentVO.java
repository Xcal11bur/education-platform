package com.education.platform.community.vo;

import java.time.LocalDateTime;
import java.util.List;
import lombok.Data;

@Data
public class CommunityCommentVO {

    private Long id;
    private Long postId;
    private Long memberId;
    private String memberName;
    private String memberAvatar;
    private Long parentId;
    private Long replyToMemberId;
    private String replyToMemberName;
    private String content;
    private Integer replyCount;
    private LocalDateTime createdAt;
    private List<CommunityCommentVO> children;
}
