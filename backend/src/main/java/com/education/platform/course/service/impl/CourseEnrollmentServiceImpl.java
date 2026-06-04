package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.course.entity.CourseEnrollment;
import com.education.platform.course.mapper.CourseEnrollmentMapper;
import com.education.platform.course.service.CourseEnrollmentService;
import org.springframework.stereotype.Service;

@Service
public class CourseEnrollmentServiceImpl extends ServiceImpl<CourseEnrollmentMapper, CourseEnrollment>
        implements CourseEnrollmentService {
}
