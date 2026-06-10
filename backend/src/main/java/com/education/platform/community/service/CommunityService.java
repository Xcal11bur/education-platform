package com.education.platform.community.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.community.dto.CommunityCommentQueryDTO;
import com.education.platform.community.dto.CommunityCommentSaveDTO;
import com.education.platform.community.dto.CommunityPostQueryDTO;
import com.education.platform.community.dto.CommunityPostSaveDTO;
import com.education.platform.community.entity.CommunityPost;
import com.education.platform.community.vo.CommunityCommentVO;
import com.education.platform.community.vo.CommunityPostDetailVO;
import com.education.platform.community.vo.CommunityPostInteractVO;
import com.education.platform.community.vo.CommunityPostListVO;

public interface CommunityService extends IService<CommunityPost> {

    PageResponse<CommunityPostListVO> pagePortalPosts(CommunityPostQueryDTO queryDTO);

    PageResponse<CommunityPostListVO> pageCurrentMemberFavoritePosts(CommunityPostQueryDTO queryDTO);

    PageResponse<CommunityPostListVO> pageCurrentMemberPosts(CommunityPostQueryDTO queryDTO);

    CommunityPostDetailVO getPortalPostDetail(Long postId);

    PageResponse<CommunityCommentVO> pagePortalComments(Long postId, CommunityCommentQueryDTO queryDTO);

    void createCurrentMemberPost(CommunityPostSaveDTO request);

    void createCurrentMemberComment(Long postId, CommunityCommentSaveDTO request);

    void deleteCurrentMemberPost(Long postId);

    void deleteCurrentMemberComment(Long commentId);

    CommunityPostInteractVO likeCurrentMemberPost(Long postId);

    CommunityPostInteractVO unlikeCurrentMemberPost(Long postId);

    CommunityPostInteractVO favoriteCurrentMemberPost(Long postId);

    CommunityPostInteractVO unfavoriteCurrentMemberPost(Long postId);
}
