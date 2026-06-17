package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.auth.model.LoginUser;
import com.education.platform.auth.util.SecurityUtils;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseEnrollment;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseEnrollmentMapper;
import com.education.platform.course.service.CourseEnrollmentService;
import com.education.platform.member.service.MemberService;
import java.math.BigDecimal;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CourseEnrollmentServiceImpl extends ServiceImpl<CourseEnrollmentMapper, CourseEnrollment>
        implements CourseEnrollmentService {

    private static final String ROLE_MEMBER = "MEMBER";
    private static final int COURSE_STATUS_PUBLISHED = 1;
    private static final int ENROLLMENT_STATUS_ACTIVE = 1;
    private static final int ENROLLMENT_STATUS_INACTIVE = 0;
    private static final int ENROLL_TYPE_SELF = 1;

    private final CourseMapper courseMapper;
    private final MemberService memberService;

    public CourseEnrollmentServiceImpl(CourseMapper courseMapper, MemberService memberService) {
        this.courseMapper = courseMapper;
        this.memberService = memberService;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean purchaseCourseForCurrentMember(Long courseId) {
        Long memberId = getCurrentMemberId();
        Course course = getPublishedCourseOrThrow(courseId);
        CourseEnrollment enrollment = getEnrollment(memberId, courseId);
        if (enrollment != null) {
            if (Objects.equals(enrollment.getStatus(), ENROLLMENT_STATUS_ACTIVE)) {
                return false;
            }
            deductCoursePrice(course);
            enrollment.setStatus(ENROLLMENT_STATUS_ACTIVE);
            enrollment.setEnrollType(ENROLL_TYPE_SELF);
            updateById(enrollment);
        } else {
            deductCoursePrice(course);
            enrollment = new CourseEnrollment();
            enrollment.setCourseId(courseId);
            enrollment.setMemberId(memberId);
            enrollment.setEnrollType(ENROLL_TYPE_SELF);
            enrollment.setStudyProgress(java.math.BigDecimal.ZERO);
            enrollment.setStatus(ENROLLMENT_STATUS_ACTIVE);
            save(enrollment);
        }
        course.setStudyCount((course.getStudyCount() == null ? 0 : course.getStudyCount()) + 1);
        courseMapper.updateById(course);
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean unenrollCurrentMember(Long courseId) {
        Long memberId = getCurrentMemberId();
        CourseEnrollment enrollment = getEnrollment(memberId, courseId);
        if (enrollment == null || !Objects.equals(enrollment.getStatus(), ENROLLMENT_STATUS_ACTIVE)) {
            return false;
        }
        enrollment.setStatus(ENROLLMENT_STATUS_INACTIVE);
        updateById(enrollment);

        Course course = courseMapper.selectById(courseId);
        if (course != null) {
            int studyCount = course.getStudyCount() == null ? 0 : course.getStudyCount();
            course.setStudyCount(Math.max(0, studyCount - 1));
            courseMapper.updateById(course);
        }
        return true;
    }

    @Override
    public boolean isCurrentMemberEnrolled(Long courseId) {
        Long memberId = getCurrentMemberIdOrNull();
        if (memberId == null || courseId == null) {
            return false;
        }
        return lambdaQuery()
                .eq(CourseEnrollment::getMemberId, memberId)
                .eq(CourseEnrollment::getCourseId, courseId)
                .eq(CourseEnrollment::getStatus, ENROLLMENT_STATUS_ACTIVE)
                .exists();
    }

    @Override
    public boolean canCurrentMemberAccessSection(Long courseId, Integer isFreeTrial) {
        return isCurrentMemberEnrolled(courseId) || Objects.equals(isFreeTrial, 1);
    }

    @Override
    public Map<Long, CourseEnrollment> getCurrentMemberEnrollmentMap(Collection<Long> courseIds) {
        Long memberId = getCurrentMemberIdOrNull();
        if (memberId == null || courseIds == null || courseIds.isEmpty()) {
            return Map.of();
        }
        return lambdaQuery()
                .eq(CourseEnrollment::getMemberId, memberId)
                .eq(CourseEnrollment::getStatus, ENROLLMENT_STATUS_ACTIVE)
                .in(CourseEnrollment::getCourseId, courseIds)
                .list()
                .stream()
                .collect(Collectors.toMap(CourseEnrollment::getCourseId, Function.identity()));
    }

    @Override
    public List<CourseEnrollment> listCurrentMemberActiveEnrollments() {
        Long memberId = getCurrentMemberId();
        return lambdaQuery()
                .eq(CourseEnrollment::getMemberId, memberId)
                .eq(CourseEnrollment::getStatus, ENROLLMENT_STATUS_ACTIVE)
                .orderByDesc(CourseEnrollment::getUpdatedAt, CourseEnrollment::getId)
                .list();
    }

    private CourseEnrollment getEnrollment(Long memberId, Long courseId) {
        return getOne(
                Wrappers.<CourseEnrollment>lambdaQuery()
                        .eq(CourseEnrollment::getMemberId, memberId)
                        .eq(CourseEnrollment::getCourseId, courseId)
                        .last("LIMIT 1"),
                false
        );
    }

    private Course getPublishedCourseOrThrow(Long courseId) {
        Course course = courseMapper.selectById(courseId);
        if (course == null || !Objects.equals(course.getPublishStatus(), COURSE_STATUS_PUBLISHED)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        return course;
    }

    private void deductCoursePrice(Course course) {
        BigDecimal price = course.getPrice() == null ? BigDecimal.ZERO : course.getPrice();
        if (price.compareTo(BigDecimal.ZERO) <= 0) {
            return;
        }
        memberService.deductCurrentMemberBalance(price);
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
