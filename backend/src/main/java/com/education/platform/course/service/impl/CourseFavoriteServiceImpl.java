package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseFavorite;
import com.education.platform.course.mapper.CourseFavoriteMapper;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.service.CourseFavoriteService;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CourseFavoriteServiceImpl extends ServiceImpl<CourseFavoriteMapper, CourseFavorite>
        implements CourseFavoriteService {

    private static final String ROLE_MEMBER = "MEMBER";
    private static final int COURSE_STATUS_PUBLISHED = 1;

    private final CourseMapper courseMapper;

    public CourseFavoriteServiceImpl(CourseMapper courseMapper) {
        this.courseMapper = courseMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean favoriteCurrentMemberCourse(Long courseId) {
        Long memberId = getCurrentMemberId();
        getPublishedCourseOrThrow(courseId);
        if (getFavorite(memberId, courseId) != null) {
            return false;
        }
        CourseFavorite favorite = new CourseFavorite();
        favorite.setCourseId(courseId);
        favorite.setMemberId(memberId);
        save(favorite);
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean unfavoriteCurrentMemberCourse(Long courseId) {
        Long memberId = getCurrentMemberId();
        getPublishedCourseOrThrow(courseId);
        return remove(Wrappers.<CourseFavorite>lambdaQuery()
                .eq(CourseFavorite::getCourseId, courseId)
                .eq(CourseFavorite::getMemberId, memberId));
    }

    @Override
    public boolean isCurrentMemberFavorited(Long courseId) {
        Long memberId = getCurrentMemberIdOrNull();
        if (memberId == null || courseId == null) {
            return false;
        }
        return lambdaQuery()
                .eq(CourseFavorite::getMemberId, memberId)
                .eq(CourseFavorite::getCourseId, courseId)
                .exists();
    }

    @Override
    public Map<Long, CourseFavorite> getCurrentMemberFavoriteMap(Collection<Long> courseIds) {
        Long memberId = getCurrentMemberIdOrNull();
        if (memberId == null || courseIds == null || courseIds.isEmpty()) {
            return Map.of();
        }
        return lambdaQuery()
                .eq(CourseFavorite::getMemberId, memberId)
                .in(CourseFavorite::getCourseId, courseIds)
                .list()
                .stream()
                .collect(Collectors.toMap(CourseFavorite::getCourseId, Function.identity()));
    }

    @Override
    public List<CourseFavorite> listCurrentMemberFavorites() {
        Long memberId = getCurrentMemberId();
        return lambdaQuery()
                .eq(CourseFavorite::getMemberId, memberId)
                .orderByDesc(CourseFavorite::getCreatedAt, CourseFavorite::getId)
                .list();
    }

    private CourseFavorite getFavorite(Long memberId, Long courseId) {
        return getOne(
                Wrappers.<CourseFavorite>lambdaQuery()
                        .eq(CourseFavorite::getMemberId, memberId)
                        .eq(CourseFavorite::getCourseId, courseId)
                        .last("LIMIT 1"),
                false
        );
    }

    private Course getPublishedCourseOrThrow(Long courseId) {
        Course course = courseMapper.selectById(courseId);
        if (course == null || !Integer.valueOf(COURSE_STATUS_PUBLISHED).equals(course.getPublishStatus())) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        return course;
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
}
