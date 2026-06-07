package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.course.entity.CourseEnrollment;
import java.util.Collection;
import java.util.List;
import java.util.Map;

public interface CourseEnrollmentService extends IService<CourseEnrollment> {

    boolean enrollCurrentMember(Long courseId);

    boolean unenrollCurrentMember(Long courseId);

    boolean isCurrentMemberEnrolled(Long courseId);

    boolean canCurrentMemberAccessSection(Long courseId, Integer isFreeTrial);

    Map<Long, CourseEnrollment> getCurrentMemberEnrollmentMap(Collection<Long> courseIds);

    List<CourseEnrollment> listCurrentMemberActiveEnrollments();
}
