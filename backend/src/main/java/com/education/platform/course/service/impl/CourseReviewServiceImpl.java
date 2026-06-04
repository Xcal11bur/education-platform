package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.course.entity.CourseReview;
import com.education.platform.course.mapper.CourseReviewMapper;
import com.education.platform.course.service.CourseReviewService;
import org.springframework.stereotype.Service;

@Service
public class CourseReviewServiceImpl extends ServiceImpl<CourseReviewMapper, CourseReview>
        implements CourseReviewService {
}
