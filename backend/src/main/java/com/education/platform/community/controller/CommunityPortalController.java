package com.education.platform.community.controller;

import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.community.dto.CommunityCommentQueryDTO;
import com.education.platform.community.dto.CommunityPostQueryDTO;
import com.education.platform.community.service.CommunityService;
import com.education.platform.community.vo.CommunityCommentVO;
import com.education.platform.community.vo.CommunityPostDetailVO;
import com.education.platform.community.vo.CommunityPostListVO;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/portal/community/posts")
@RequiredArgsConstructor
public class CommunityPortalController {

    private final CommunityService communityService;

    @GetMapping
    public Result<PageResponse<CommunityPostListVO>> pagePosts(@Validated CommunityPostQueryDTO queryDTO) {
        return Result.success(communityService.pagePortalPosts(queryDTO));
    }

    @GetMapping("/{postId}")
    public Result<CommunityPostDetailVO> getPostDetail(@PathVariable Long postId) {
        return Result.success(communityService.getPortalPostDetail(postId));
    }

    @GetMapping("/{postId}/comments")
    public Result<PageResponse<CommunityCommentVO>> pageComments(@PathVariable Long postId,
                                                                 @Validated CommunityCommentQueryDTO queryDTO) {
        return Result.success(communityService.pagePortalComments(postId, queryDTO));
    }
}
