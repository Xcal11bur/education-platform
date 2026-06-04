package com.education.platform.task.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.task.entity.TaskSubmission;
import com.education.platform.task.mapper.TaskSubmissionMapper;
import com.education.platform.task.service.TaskSubmissionService;
import org.springframework.stereotype.Service;

@Service
public class TaskSubmissionServiceImpl extends ServiceImpl<TaskSubmissionMapper, TaskSubmission>
        implements TaskSubmissionService {
}
