package com.education.platform.task.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.task.entity.CourseTask;
import com.education.platform.task.mapper.CourseTaskMapper;
import com.education.platform.task.service.CourseTaskService;
import org.springframework.stereotype.Service;

@Service
public class CourseTaskServiceImpl extends ServiceImpl<CourseTaskMapper, CourseTask> implements CourseTaskService {
}
