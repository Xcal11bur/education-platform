package com.education.platform.community.controller;

import com.education.platform.common.result.Result;
import com.education.platform.community.dto.CommunityCommentSaveDTO;
import com.education.platform.community.dto.CommunityPostSaveDTO;
import com.education.platform.community.service.CommunityService;
import com.education.platform.community.vo.CommunityPostInteractVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member/community/posts")
@RequiredArgsConstructor
public class CommunityMemberController {

    private final CommunityService communityService;

    @PostMapping
    public Result<Void> createPost(@Valid @RequestBody CommunityPostSaveDTO request) {
        communityService.createCurrentMemberPost(request);
        return Result.success();
    }

    @PostMapping("/{postId}/comments")
    public Result<Void> createComment(@PathVariable Long postId, @Valid @RequestBody CommunityCommentSaveDTO request) {
        communityService.createCurrentMemberComment(postId, request);
        return Result.success();
    }

    @PostMapping("/{postId}/like")
    public Result<CommunityPostInteractVO> like(@PathVariable Long postId) {
        return Result.success(communityService.likeCurrentMemberPost(postId));
    }

    @DeleteMapping("/{postId}/like")
    public Result<CommunityPostInteractVO> unlike(@PathVariable Long postId) {
        return Result.success(communityService.unlikeCurrentMemberPost(postId));
    }

    @PostMapping("/{postId}/favorite")
    public Result<CommunityPostInteractVO> favorite(@PathVariable Long postId) {
        return Result.success(communityService.favoriteCurrentMemberPost(postId));
    }

    @DeleteMapping("/{postId}/favorite")
    public Result<CommunityPostInteractVO> unfavorite(@PathVariable Long postId) {
        return Result.success(communityService.unfavoriteCurrentMemberPost(postId));
    }
}
