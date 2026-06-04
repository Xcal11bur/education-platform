package com.education.platform.task.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.task.entity.TaskQuestion;
import com.education.platform.task.mapper.TaskQuestionMapper;
import com.education.platform.task.service.TaskQuestionService;
import org.springframework.stereotype.Service;

@Service
public class TaskQuestionServiceImpl extends ServiceImpl<TaskQuestionMapper, TaskQuestion>
        implements TaskQuestionService {
}
