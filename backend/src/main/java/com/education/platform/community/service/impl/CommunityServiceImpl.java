package com.education.platform.community.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.community.dto.CommunityCommentQueryDTO;
import com.education.platform.community.dto.CommunityCommentSaveDTO;
import com.education.platform.community.dto.CommunityPostQueryDTO;
import com.education.platform.community.dto.CommunityPostSaveDTO;
import com.education.platform.community.entity.CommunityComment;
import com.education.platform.community.entity.CommunityPost;
import com.education.platform.community.entity.CommunityPostAction;
import com.education.platform.community.entity.CommunityPostImage;
import com.education.platform.community.mapper.CommunityCommentMapper;
import com.education.platform.community.mapper.CommunityPostActionMapper;
import com.education.platform.community.mapper.CommunityPostImageMapper;
import com.education.platform.community.mapper.CommunityPostMapper;
import com.education.platform.community.service.CommunityService;
import com.education.platform.community.vo.CommunityCommentVO;
import com.education.platform.community.vo.CommunityPostDetailVO;
import com.education.platform.community.vo.CommunityPostInteractVO;
import com.education.platform.community.vo.CommunityPostListVO;
import com.education.platform.member.entity.Member;
import com.education.platform.member.mapper.MemberMapper;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class CommunityServiceImpl extends ServiceImpl<CommunityPostMapper, CommunityPost>
        implements CommunityService {

    private static final String ROLE_MEMBER = "MEMBER";
    private static final int MEMBER_STATUS_ENABLED = 1;
    private static final int POST_STATUS_PUBLISHED = 1;
    private static final int COMMENT_STATUS_PUBLISHED = 1;
    private static final int ACTION_TYPE_LIKE = 1;
    private static final int ACTION_TYPE_FAVORITE = 2;

    private final CommunityPostImageMapper communityPostImageMapper;
    private final CommunityCommentMapper communityCommentMapper;
    private final CommunityPostActionMapper communityPostActionMapper;
    private final MemberMapper memberMapper;

    @Override
    public PageResponse<CommunityPostListVO> pagePortalPosts(CommunityPostQueryDTO queryDTO) {
        var query = lambdaQuery()
                .eq(CommunityPost::getStatus, POST_STATUS_PUBLISHED)
                .and(StringUtils.hasText(queryDTO.getKeyword()), wrapper -> wrapper
                        .like(CommunityPost::getTitle, queryDTO.getKeyword())
                        .or()
                        .like(CommunityPost::getContent, queryDTO.getKeyword()));
        if ("hot".equalsIgnoreCase(queryDTO.getSortMode())) {
            query.orderByDesc(CommunityPost::getLikeCount, CommunityPost::getCommentCount, CommunityPost::getCreatedAt, CommunityPost::getId);
        } else {
            query.orderByDesc(CommunityPost::getCreatedAt, CommunityPost::getId);
        }
        IPage<CommunityPost> page = query.page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        if (page.getRecords().isEmpty()) {
            return PageResponse.empty(queryDTO.getPageNum(), queryDTO.getPageSize());
        }

        List<CommunityPostListVO> list = buildPostListVOs(page.getRecords(), getCurrentMemberIdOrNull());
        return PageResponse.<CommunityPostListVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public PageResponse<CommunityPostListVO> pageCurrentMemberFavoritePosts(CommunityPostQueryDTO queryDTO) {
        Long memberId = getCurrentMemberId();
        IPage<CommunityPostAction> actionPage = communityPostActionMapper.selectPage(
                new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()),
                Wrappers.<CommunityPostAction>lambdaQuery()
                        .eq(CommunityPostAction::getMemberId, memberId)
                        .eq(CommunityPostAction::getActionType, ACTION_TYPE_FAVORITE)
                        .orderByDesc(CommunityPostAction::getCreatedAt, CommunityPostAction::getId)
        );
        if (actionPage.getRecords().isEmpty()) {
            return PageResponse.empty(queryDTO.getPageNum(), queryDTO.getPageSize());
        }

        List<Long> postIds = actionPage.getRecords().stream()
                .map(CommunityPostAction::getPostId)
                .distinct()
                .toList();
        Map<Long, CommunityPost> postMap = lambdaQuery()
                .in(CommunityPost::getId, postIds)
                .eq(CommunityPost::getStatus, POST_STATUS_PUBLISHED)
                .list()
                .stream()
                .collect(Collectors.toMap(CommunityPost::getId, Function.identity()));
        List<CommunityPost> posts = postIds.stream()
                .map(postMap::get)
                .filter(Objects::nonNull)
                .toList();

        return PageResponse.<CommunityPostListVO>builder()
                .pageNum(actionPage.getCurrent())
                .pageSize(actionPage.getSize())
                .total(actionPage.getTotal())
                .list(buildPostListVOs(posts, memberId))
                .build();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommunityPostDetailVO getPortalPostDetail(Long postId) {
        CommunityPost post = getPublishedPostOrThrow(postId);
        post.setViewCount(Math.max(0, defaultInt(post.getViewCount())) + 1);
        updateById(post);

        Member member = listMembersByIds(Set.of(post.getMemberId())).get(post.getMemberId());
        List<String> images = listImageMap(Set.of(postId)).getOrDefault(postId, List.of());
        Long currentMemberId = getCurrentMemberIdOrNull();
        boolean liked = currentMemberId != null && hasAction(postId, currentMemberId, ACTION_TYPE_LIKE);
        boolean favorited = currentMemberId != null && hasAction(postId, currentMemberId, ACTION_TYPE_FAVORITE);
        return toDetailVO(post, member, images, liked, favorited);
    }

    @Override
    public PageResponse<CommunityCommentVO> pagePortalComments(Long postId, CommunityCommentQueryDTO queryDTO) {
        getPublishedPostOrThrow(postId);
        IPage<CommunityComment> page = communityCommentMapper.selectPage(
                new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()),
                Wrappers.<CommunityComment>lambdaQuery()
                        .eq(CommunityComment::getPostId, postId)
                        .eq(CommunityComment::getStatus, COMMENT_STATUS_PUBLISHED)
                        .eq(CommunityComment::getParentId, 0L)
                        .orderByDesc(CommunityComment::getCreatedAt, CommunityComment::getId)
        );
        if (page.getRecords().isEmpty()) {
            return PageResponse.empty(queryDTO.getPageNum(), queryDTO.getPageSize());
        }

        List<CommunityComment> rootComments = page.getRecords();
        Set<Long> rootIds = rootComments.stream().map(CommunityComment::getId).collect(Collectors.toSet());
        List<CommunityComment> childComments = communityCommentMapper.selectList(
                Wrappers.<CommunityComment>lambdaQuery()
                        .eq(CommunityComment::getPostId, postId)
                        .eq(CommunityComment::getStatus, COMMENT_STATUS_PUBLISHED)
                        .in(CommunityComment::getParentId, rootIds)
                        .orderByAsc(CommunityComment::getCreatedAt, CommunityComment::getId)
        );

        Set<Long> memberIds = new HashSet<>();
        rootComments.forEach(comment -> {
            memberIds.add(comment.getMemberId());
            if (comment.getReplyToMemberId() != null) {
                memberIds.add(comment.getReplyToMemberId());
            }
        });
        childComments.forEach(comment -> {
            memberIds.add(comment.getMemberId());
            if (comment.getReplyToMemberId() != null) {
                memberIds.add(comment.getReplyToMemberId());
            }
        });
        Map<Long, Member> memberMap = listMembersByIds(memberIds);

        Map<Long, List<CommunityCommentVO>> childMap = new LinkedHashMap<>();
        for (CommunityComment child : childComments) {
            CommunityCommentVO childVo = toCommentVO(child, memberMap);
            childVo.setChildren(List.of());
            childVo.setReplyCount(0);
            childMap.computeIfAbsent(child.getParentId(), key -> new ArrayList<>()).add(childVo);
        }

        List<CommunityCommentVO> list = rootComments.stream().map(comment -> {
            CommunityCommentVO vo = toCommentVO(comment, memberMap);
            List<CommunityCommentVO> children = childMap.getOrDefault(comment.getId(), List.of());
            vo.setChildren(children);
            vo.setReplyCount(children.size());
            return vo;
        }).toList();

        return PageResponse.<CommunityCommentVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createCurrentMemberPost(CommunityPostSaveDTO request) {
        Long memberId = getCurrentMemberId();
        CommunityPost post = new CommunityPost();
        post.setMemberId(memberId);
        post.setTitle(normalizeText(request.getTitle()));
        post.setContent(normalizeText(request.getContent()));
        post.setStatus(POST_STATUS_PUBLISHED);
        post.setCommentCount(0);
        post.setLikeCount(0);
        post.setFavoriteCount(0);
        post.setViewCount(0);
        save(post);

        List<String> imageUrls = normalizeImageUrls(request.getImageUrls());
        for (int index = 0; index < imageUrls.size(); index++) {
            CommunityPostImage image = new CommunityPostImage();
            image.setPostId(post.getId());
            image.setImageUrl(imageUrls.get(index));
            image.setSort(index + 1);
            communityPostImageMapper.insert(image);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createCurrentMemberComment(Long postId, CommunityCommentSaveDTO request) {
        Long memberId = getCurrentMemberId();
        getPublishedPostOrThrow(postId);

        Long parentId = request.getParentId() == null || request.getParentId() <= 0 ? 0L : request.getParentId();
        Long replyToMemberId = request.getReplyToMemberId();
        if (parentId > 0) {
            CommunityComment parent = getCommentOrThrow(parentId);
            if (!Objects.equals(parent.getPostId(), postId) || !Objects.equals(parent.getStatus(), COMMENT_STATUS_PUBLISHED)) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "comment relation is invalid");
            }
            if (parent.getParentId() != null && parent.getParentId() > 0) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "only one-level reply is supported");
            }
            if (replyToMemberId == null || replyToMemberId <= 0) {
                replyToMemberId = parent.getMemberId();
            }
        } else {
            replyToMemberId = null;
        }

        CommunityComment comment = new CommunityComment();
        comment.setPostId(postId);
        comment.setMemberId(memberId);
        comment.setParentId(parentId);
        comment.setReplyToMemberId(replyToMemberId);
        comment.setContent(normalizeText(request.getContent()));
        comment.setStatus(COMMENT_STATUS_PUBLISHED);
        communityCommentMapper.insert(comment);

        refreshCommentCount(postId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommunityPostInteractVO likeCurrentMemberPost(Long postId) {
        Long memberId = getCurrentMemberId();
        getPublishedPostOrThrow(postId);
        if (!hasAction(postId, memberId, ACTION_TYPE_LIKE)) {
            CommunityPostAction action = new CommunityPostAction();
            action.setPostId(postId);
            action.setMemberId(memberId);
            action.setActionType(ACTION_TYPE_LIKE);
            communityPostActionMapper.insert(action);
            refreshActionCount(postId, ACTION_TYPE_LIKE);
        }
        return buildInteractVO(postId, memberId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommunityPostInteractVO unlikeCurrentMemberPost(Long postId) {
        Long memberId = getCurrentMemberId();
        getPublishedPostOrThrow(postId);
        communityPostActionMapper.delete(Wrappers.<CommunityPostAction>lambdaQuery()
                .eq(CommunityPostAction::getPostId, postId)
                .eq(CommunityPostAction::getMemberId, memberId)
                .eq(CommunityPostAction::getActionType, ACTION_TYPE_LIKE));
        refreshActionCount(postId, ACTION_TYPE_LIKE);
        return buildInteractVO(postId, memberId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommunityPostInteractVO favoriteCurrentMemberPost(Long postId) {
        Long memberId = getCurrentMemberId();
        getPublishedPostOrThrow(postId);
        if (!hasAction(postId, memberId, ACTION_TYPE_FAVORITE)) {
            CommunityPostAction action = new CommunityPostAction();
            action.setPostId(postId);
            action.setMemberId(memberId);
            action.setActionType(ACTION_TYPE_FAVORITE);
            communityPostActionMapper.insert(action);
            refreshActionCount(postId, ACTION_TYPE_FAVORITE);
        }
        return buildInteractVO(postId, memberId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommunityPostInteractVO unfavoriteCurrentMemberPost(Long postId) {
        Long memberId = getCurrentMemberId();
        getPublishedPostOrThrow(postId);
        communityPostActionMapper.delete(Wrappers.<CommunityPostAction>lambdaQuery()
                .eq(CommunityPostAction::getPostId, postId)
                .eq(CommunityPostAction::getMemberId, memberId)
                .eq(CommunityPostAction::getActionType, ACTION_TYPE_FAVORITE));
        refreshActionCount(postId, ACTION_TYPE_FAVORITE);
        return buildInteractVO(postId, memberId);
    }

    private CommunityPostListVO toListVO(CommunityPost post,
                                         Member member,
                                         List<String> images,
                                         Set<Long> likedPostIds,
                                         Set<Long> favoritedPostIds) {
        CommunityPostListVO vo = new CommunityPostListVO();
        vo.setId(post.getId());
        vo.setAuthorId(post.getMemberId());
        vo.setAuthorName(resolveMemberDisplayName(member));
        vo.setAuthorAvatar(member == null ? null : member.getAvatar());
        vo.setTitle(post.getTitle());
        vo.setContent(post.getContent());
        vo.setImages(images == null ? List.of() : images);
        vo.setCommentCount(defaultInt(post.getCommentCount()));
        vo.setLikeCount(defaultInt(post.getLikeCount()));
        vo.setFavoriteCount(defaultInt(post.getFavoriteCount()));
        vo.setLiked(likedPostIds.contains(post.getId()));
        vo.setFavorited(favoritedPostIds.contains(post.getId()));
        vo.setCreatedAt(post.getCreatedAt());
        return vo;
    }

    private CommunityPostDetailVO toDetailVO(CommunityPost post,
                                             Member member,
                                             List<String> images,
                                             boolean liked,
                                             boolean favorited) {
        CommunityPostDetailVO vo = new CommunityPostDetailVO();
        vo.setId(post.getId());
        vo.setAuthorId(post.getMemberId());
        vo.setAuthorName(resolveMemberDisplayName(member));
        vo.setAuthorAvatar(member == null ? null : member.getAvatar());
        vo.setTitle(post.getTitle());
        vo.setContent(post.getContent());
        vo.setImages(images == null ? List.of() : images);
        vo.setCommentCount(defaultInt(post.getCommentCount()));
        vo.setLikeCount(defaultInt(post.getLikeCount()));
        vo.setFavoriteCount(defaultInt(post.getFavoriteCount()));
        vo.setViewCount(defaultInt(post.getViewCount()));
        vo.setLiked(liked);
        vo.setFavorited(favorited);
        vo.setCreatedAt(post.getCreatedAt());
        return vo;
    }

    private CommunityCommentVO toCommentVO(CommunityComment comment, Map<Long, Member> memberMap) {
        Member member = memberMap.get(comment.getMemberId());
        Member replyToMember = comment.getReplyToMemberId() == null ? null : memberMap.get(comment.getReplyToMemberId());
        CommunityCommentVO vo = new CommunityCommentVO();
        vo.setId(comment.getId());
        vo.setPostId(comment.getPostId());
        vo.setMemberId(comment.getMemberId());
        vo.setMemberName(resolveMemberDisplayName(member));
        vo.setMemberAvatar(member == null ? null : member.getAvatar());
        vo.setParentId(comment.getParentId());
        vo.setReplyToMemberId(comment.getReplyToMemberId());
        vo.setReplyToMemberName(replyToMember == null ? null : resolveMemberDisplayName(replyToMember));
        vo.setContent(comment.getContent());
        vo.setCreatedAt(comment.getCreatedAt());
        return vo;
    }

    private Map<Long, Member> listMembersByIds(Collection<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return Map.of();
        }
        return memberMapper.selectList(Wrappers.<Member>lambdaQuery()
                        .in(Member::getId, ids)
                        .eq(Member::getStatus, MEMBER_STATUS_ENABLED))
                .stream()
                .collect(Collectors.toMap(Member::getId, Function.identity()));
    }

    private Map<Long, List<String>> listImageMap(Set<Long> postIds) {
        if (postIds == null || postIds.isEmpty()) {
            return Map.of();
        }
        List<CommunityPostImage> images = communityPostImageMapper.selectList(
                Wrappers.<CommunityPostImage>lambdaQuery()
                        .in(CommunityPostImage::getPostId, postIds)
                        .orderByAsc(CommunityPostImage::getSort, CommunityPostImage::getId)
        );
        Map<Long, List<String>> imageMap = new HashMap<>();
        for (CommunityPostImage image : images) {
            imageMap.computeIfAbsent(image.getPostId(), key -> new ArrayList<>()).add(image.getImageUrl());
        }
        return imageMap;
    }

    private Set<Long> listActionPostIds(Long memberId, Integer actionType, Set<Long> postIds) {
        if (memberId == null || postIds == null || postIds.isEmpty()) {
            return Set.of();
        }
        return communityPostActionMapper.selectList(
                        Wrappers.<CommunityPostAction>lambdaQuery()
                                .eq(CommunityPostAction::getMemberId, memberId)
                                .eq(CommunityPostAction::getActionType, actionType)
                                .in(CommunityPostAction::getPostId, postIds))
                .stream()
                .map(CommunityPostAction::getPostId)
                .collect(Collectors.toSet());
    }

    private boolean hasAction(Long postId, Long memberId, Integer actionType) {
        return communityPostActionMapper.selectCount(
                Wrappers.<CommunityPostAction>lambdaQuery()
                        .eq(CommunityPostAction::getPostId, postId)
                        .eq(CommunityPostAction::getMemberId, memberId)
                        .eq(CommunityPostAction::getActionType, actionType)
        ) > 0;
    }

    private void refreshActionCount(Long postId, Integer actionType) {
        CommunityPost post = getPublishedPostOrThrow(postId);
        int nextCount = Math.toIntExact(communityPostActionMapper.selectCount(
                Wrappers.<CommunityPostAction>lambdaQuery()
                        .eq(CommunityPostAction::getPostId, postId)
                        .eq(CommunityPostAction::getActionType, actionType)
        ));
        if (Objects.equals(actionType, ACTION_TYPE_LIKE)) {
            post.setLikeCount(nextCount);
        } else {
            post.setFavoriteCount(nextCount);
        }
        baseMapper.updateById(post);
    }

    private void refreshCommentCount(Long postId) {
        CommunityPost post = getPublishedPostOrThrow(postId);
        int nextCount = Math.toIntExact(communityCommentMapper.selectCount(
                Wrappers.<CommunityComment>lambdaQuery()
                        .eq(CommunityComment::getPostId, postId)
                        .eq(CommunityComment::getStatus, COMMENT_STATUS_PUBLISHED)
        ));
        post.setCommentCount(nextCount);
        baseMapper.updateById(post);
    }

    private CommunityPostInteractVO buildInteractVO(Long postId, Long memberId) {
        CommunityPost post = getPublishedPostOrThrow(postId);
        CommunityPostInteractVO vo = new CommunityPostInteractVO();
        vo.setCommentCount(defaultInt(post.getCommentCount()));
        vo.setLikeCount(defaultInt(post.getLikeCount()));
        vo.setFavoriteCount(defaultInt(post.getFavoriteCount()));
        vo.setLiked(hasAction(postId, memberId, ACTION_TYPE_LIKE));
        vo.setFavorited(hasAction(postId, memberId, ACTION_TYPE_FAVORITE));
        return vo;
    }

    private List<CommunityPostListVO> buildPostListVOs(List<CommunityPost> posts, Long currentMemberId) {
        if (posts == null || posts.isEmpty()) {
            return List.of();
        }
        Set<Long> postIds = posts.stream().map(CommunityPost::getId).collect(Collectors.toSet());
        Map<Long, Member> memberMap = listMembersByIds(posts.stream().map(CommunityPost::getMemberId).collect(Collectors.toSet()));
        Map<Long, List<String>> imageMap = listImageMap(postIds);
        Set<Long> likedPostIds = currentMemberId == null ? Set.of() : listActionPostIds(currentMemberId, ACTION_TYPE_LIKE, postIds);
        Set<Long> favoritedPostIds = currentMemberId == null ? Set.of() : listActionPostIds(currentMemberId, ACTION_TYPE_FAVORITE, postIds);
        return posts.stream()
                .map(post -> toListVO(post, memberMap.get(post.getMemberId()), imageMap.get(post.getId()), likedPostIds, favoritedPostIds))
                .toList();
    }

    private CommunityPost getPublishedPostOrThrow(Long postId) {
        CommunityPost post = getById(postId);
        if (post == null || !Objects.equals(post.getStatus(), POST_STATUS_PUBLISHED)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "community post not found");
        }
        return post;
    }

    private CommunityComment getCommentOrThrow(Long commentId) {
        CommunityComment comment = communityCommentMapper.selectById(commentId);
        if (comment == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "community comment not found");
        }
        return comment;
    }

    private Long getCurrentMemberId() {
        Long memberId = getCurrentMemberIdOrNull();
        if (memberId == null) {
            throw new BusinessException(ResultCode.FORBIDDEN.getCode(), "member login required");
        }
        return memberId;
    }

    private Long getCurrentMemberIdOrNull() {
        return SecurityUtils.getLoginUser()
                .filter(loginUser -> ROLE_MEMBER.equals(loginUser.getRole()))
                .map(LoginUser::getUserId)
                .orElse(null);
    }

    private String resolveMemberDisplayName(Member member) {
        if (member == null) {
            return "学员";
        }
        if (StringUtils.hasText(member.getNickname())) {
            return member.getNickname();
        }
        if (StringUtils.hasText(member.getRealName())) {
            return member.getRealName();
        }
        return member.getMobile();
    }

    private String normalizeText(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        return value.trim();
    }

    private List<String> normalizeImageUrls(List<String> imageUrls) {
        if (imageUrls == null || imageUrls.isEmpty()) {
            return List.of();
        }
        List<String> normalized = imageUrls.stream()
                .filter(StringUtils::hasText)
                .map(String::trim)
                .distinct()
                .toList();
        if (normalized.size() > 9) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "imageUrls size must not exceed 9");
        }
        return normalized;
    }

    private int defaultInt(Integer value) {
        return value == null ? 0 : value;
    }
}
