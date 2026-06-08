package com.education.platform.task.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.task.dto.CourseTaskQueryDTO;
import com.education.platform.task.dto.CourseTaskSaveDTO;
import com.education.platform.task.entity.CourseTask;
import com.education.platform.task.vo.CourseTaskVO;

public interface CourseTaskService extends IService<CourseTask> {

    PageResponse<CourseTaskVO> pageTeacherTasks(CourseTaskQueryDTO queryDTO);

    CourseTaskVO getTeacherTaskDetail(Long id);

    void createTeacherTask(CourseTaskSaveDTO request);

    void updateTeacherTask(Long id, CourseTaskSaveDTO request);

    void deleteTeacherTask(Long id);
}
