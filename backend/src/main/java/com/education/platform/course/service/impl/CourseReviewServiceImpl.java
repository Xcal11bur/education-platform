package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseReviewQueryDTO;
import com.education.platform.course.dto.CourseReviewSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseEnrollment;
import com.education.platform.course.entity.CourseReview;
import com.education.platform.course.mapper.CourseEnrollmentMapper;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseReviewMapper;
import com.education.platform.course.service.CourseReviewService;
import com.education.platform.course.vo.CourseReviewAdminVO;
import com.education.platform.course.vo.CourseReviewPortalVO;
import com.education.platform.course.vo.CourseReviewSummaryVO;
import com.education.platform.member.entity.Member;
import com.education.platform.member.mapper.MemberMapper;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class CourseReviewServiceImpl extends ServiceImpl<CourseReviewMapper, CourseReview>
        implements CourseReviewService {

    private static final String ROLE_MEMBER = "MEMBER";
    private static final int COURSE_STATUS_PUBLISHED = 1;
    private static final int ENROLLMENT_STATUS_ACTIVE = 1;
    private static final int REVIEW_STATUS_PENDING = 0;
    private static final int REVIEW_STATUS_APPROVED = 1;
    private static final int REVIEW_STATUS_REJECTED = 2;
    private static final int MEMBER_STATUS_ENABLED = 1;

    private final CourseMapper courseMapper;
    private final CourseEnrollmentMapper courseEnrollmentMapper;
    private final MemberMapper memberMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitCurrentMemberReview(CourseReviewSaveDTO request) {
        Long memberId = getCurrentMemberId();
        Course course = getPublishedCourseOrThrow(request.getCourseId());
        ensureCurrentMemberEnrolled(course.getId(), memberId);

        boolean exists = lambdaQuery()
                .eq(CourseReview::getCourseId, course.getId())
                .eq(CourseReview::getMemberId, memberId)
                .exists();
        if (exists) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course review already exists");
        }

        CourseReview review = new CourseReview();
        review.setCourseId(course.getId());
        review.setMemberId(memberId);
        review.setScore(request.getScore());
        review.setContent(StringUtils.hasText(request.getContent()) ? request.getContent().trim() : null);
        review.setAnonymousFlag(Objects.equals(request.getAnonymousFlag(), 1) ? 1 : 0);
        review.setStatus(REVIEW_STATUS_PENDING);
        save(review);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteCurrentMemberReview(Long courseId) {
        Long memberId = getCurrentMemberId();
        getPublishedCourseOrThrow(courseId);
        CourseReview review = getCurrentMemberReview(courseId, memberId);
        if (review == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course review not found");
        }
        removeById(review.getId());
    }

    @Override
    public PageResponse<CourseReviewAdminVO> pageAdminReviews(CourseReviewQueryDTO queryDTO) {
        IPage<CourseReview> page = lambdaQuery()
                .eq(queryDTO.getCourseId() != null, CourseReview::getCourseId, queryDTO.getCourseId())
                .eq(queryDTO.getStatus() != null, CourseReview::getStatus, queryDTO.getStatus())
                .eq(queryDTO.getScore() != null, CourseReview::getScore, queryDTO.getScore())
                .like(StringUtils.hasText(queryDTO.getKeyword()), CourseReview::getContent, queryDTO.getKeyword())
                .orderByDesc(CourseReview::getCreatedAt, CourseReview::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<CourseReviewAdminVO> list = fillAdminReviewVOs(page.getRecords());
        return PageResponse.<CourseReviewAdminVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateReviewStatus(Long id, Integer status) {
        if (!List.of(REVIEW_STATUS_PENDING, REVIEW_STATUS_APPROVED, REVIEW_STATUS_REJECTED).contains(status)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "status must be 0, 1 or 2");
        }
        CourseReview review = getReviewOrThrow(id);
        review.setStatus(status);
        review.setReviewedAt(LocalDateTime.now());
        updateById(review);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteReview(Long id) {
        CourseReview review = getReviewOrThrow(id);
        removeById(review.getId());
    }

    @Override
    public PageResponse<CourseReviewPortalVO> pagePortalReviews(CourseReviewQueryDTO queryDTO) {
        getPublishedCourseOrThrow(queryDTO.getCourseId());
        IPage<CourseReview> page = lambdaQuery()
                .eq(CourseReview::getCourseId, queryDTO.getCourseId())
                .eq(CourseReview::getStatus, REVIEW_STATUS_APPROVED)
                .orderByDesc(CourseReview::getCreatedAt, CourseReview::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<CourseReviewPortalVO> list = fillPortalReviewVOs(page.getRecords());
        return PageResponse.<CourseReviewPortalVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public CourseReviewSummaryVO getPortalReviewSummary(Long courseId) {
        getPublishedCourseOrThrow(courseId);
        return buildReviewSummary(courseId, getCurrentMemberIdOrNull());
    }

    @Override
    public CourseReviewSummaryVO getCurrentMemberReviewSummary(Long courseId) {
        getPublishedCourseOrThrow(courseId);
        return buildReviewSummary(courseId, getCurrentMemberId());
    }

    @Override
    public String getPortalReviewAvatarUrl(Long reviewId) {
        CourseReview review = getReviewOrThrow(reviewId);
        if (!Objects.equals(review.getStatus(), REVIEW_STATUS_APPROVED)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course review not found");
        }
        if (Objects.equals(review.getAnonymousFlag(), 1)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "review avatar not found");
        }
        Member member = memberMapper.selectById(review.getMemberId());
        if (member == null || !Objects.equals(member.getStatus(), MEMBER_STATUS_ENABLED) || !StringUtils.hasText(member.getAvatar())) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "review avatar not found");
        }
        return member.getAvatar().trim();
    }

    private CourseReviewSummaryVO buildReviewSummary(Long courseId, Long memberId) {
        List<CourseReview> approvedReviews = lambdaQuery()
                .eq(CourseReview::getCourseId, courseId)
                .eq(CourseReview::getStatus, REVIEW_STATUS_APPROVED)
                .list();

        Map<Integer, Long> scoreDistribution = new LinkedHashMap<>();
        for (int score = 5; score >= 1; score--) {
            final int targetScore = score;
            scoreDistribution.put(score, approvedReviews.stream()
                    .filter(review -> Objects.equals(review.getScore(), targetScore))
                    .count());
        }

        CourseReview currentMemberReview = memberId == null ? null : getCurrentMemberReview(courseId, memberId);

        CourseReviewSummaryVO summary = new CourseReviewSummaryVO();
        summary.setReviewCount((long) approvedReviews.size());
        summary.setAvgScore(approvedReviews.isEmpty()
                ? 0D
                : approvedReviews.stream().mapToInt(CourseReview::getScore).average().orElse(0D));
        summary.setScoreDistribution(scoreDistribution);
        summary.setHasReviewed(currentMemberReview != null);
        summary.setMyReviewStatus(currentMemberReview == null ? null : currentMemberReview.getStatus());
        summary.setCanReview(memberId != null
                && currentMemberReview == null
                && isMemberEnrolled(courseId, memberId));
        return summary;
    }

    private List<CourseReviewAdminVO> fillAdminReviewVOs(List<CourseReview> reviews) {
        if (reviews.isEmpty()) {
            return List.of();
        }
        Map<Long, Course> courseMap = listCoursesByIds(reviews.stream().map(CourseReview::getCourseId).collect(Collectors.toSet()));
        Map<Long, Member> memberMap = listMembersByIds(reviews.stream().map(CourseReview::getMemberId).collect(Collectors.toSet()));
        return reviews.stream().map(review -> {
            CourseReviewAdminVO vo = new CourseReviewAdminVO();
            BeanUtils.copyProperties(review, vo);
            Course course = courseMap.get(review.getCourseId());
            if (course != null) {
                vo.setCourseTitle(course.getTitle());
            }
            Member member = memberMap.get(review.getMemberId());
            if (member != null) {
                vo.setMemberNickname(resolveMemberDisplayName(member));
                vo.setMemberMobile(member.getMobile());
            }
            return vo;
        }).toList();
    }

    private List<CourseReviewPortalVO> fillPortalReviewVOs(List<CourseReview> reviews) {
        if (reviews.isEmpty()) {
            return List.of();
        }
        Map<Long, Member> memberMap = listMembersByIds(reviews.stream().map(CourseReview::getMemberId).collect(Collectors.toSet()));
        return reviews.stream().map(review -> {
            CourseReviewPortalVO vo = new CourseReviewPortalVO();
            vo.setId(review.getId());
            vo.setScore(review.getScore());
            vo.setContent(review.getContent());
            vo.setCreatedAt(review.getCreatedAt());
            Member member = memberMap.get(review.getMemberId());
            if (Objects.equals(review.getAnonymousFlag(), 1)) {
                vo.setMemberDisplayName("匿名用户");
                vo.setMemberAvatar(null);
                vo.setAvatar(null);
                vo.setMemberAvatarProxy(null);
            } else {
                vo.setMemberDisplayName(member == null ? "学员" : resolveMemberDisplayName(member));
                String avatar = member == null ? null : member.getAvatar();
                vo.setMemberAvatar(avatar);
                vo.setAvatar(avatar);
                vo.setMemberAvatarProxy(StringUtils.hasText(avatar)
                        ? "/api/v1/portal/courses/reviews/" + review.getId() + "/avatar"
                        : null);
            }
            return vo;
        }).toList();
    }

    private CourseReview getCurrentMemberReview(Long courseId, Long memberId) {
        return getOne(Wrappers.<CourseReview>lambdaQuery()
                .eq(CourseReview::getCourseId, courseId)
                .eq(CourseReview::getMemberId, memberId)
                .last("LIMIT 1"), false);
    }

    private CourseReview getReviewOrThrow(Long id) {
        CourseReview review = getById(id);
        if (review == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course review not found");
        }
        return review;
    }

    private Course getPublishedCourseOrThrow(Long courseId) {
        Course course = courseMapper.selectById(courseId);
        if (course == null || !Objects.equals(course.getPublishStatus(), COURSE_STATUS_PUBLISHED)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        return course;
    }

    private void ensureCurrentMemberEnrolled(Long courseId, Long memberId) {
        if (!isMemberEnrolled(courseId, memberId)) {
            throw new BusinessException(ResultCode.FORBIDDEN.getCode(), "course enrollment required");
        }
    }

    private boolean isMemberEnrolled(Long courseId, Long memberId) {
        return courseEnrollmentMapper.selectCount(
                Wrappers.<CourseEnrollment>lambdaQuery()
                        .eq(CourseEnrollment::getCourseId, courseId)
                        .eq(CourseEnrollment::getMemberId, memberId)
                        .eq(CourseEnrollment::getStatus, ENROLLMENT_STATUS_ACTIVE)
        ) > 0;
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

    private Map<Long, Course> listCoursesByIds(Set<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return courseMapper.selectList(Wrappers.<Course>lambdaQuery().in(Course::getId, ids)).stream()
                .collect(Collectors.toMap(Course::getId, Function.identity()));
    }

    private Map<Long, Member> listMembersByIds(Set<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return memberMapper.selectList(Wrappers.<Member>lambdaQuery()
                        .in(Member::getId, ids)
                        .eq(Member::getStatus, MEMBER_STATUS_ENABLED))
                .stream()
                .collect(Collectors.toMap(Member::getId, Function.identity()));
    }

    private String resolveMemberDisplayName(Member member) {
        if (StringUtils.hasText(member.getNickname())) {
            return member.getNickname();
        }
        if (StringUtils.hasText(member.getRealName())) {
            return member.getRealName();
        }
        return member.getMobile();
    }
}
