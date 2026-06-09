package com.education.platform.task.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.task.dto.TaskSubmissionSaveDTO;
import com.education.platform.task.entity.TaskSubmission;
import com.education.platform.task.vo.CourseTaskMemberDetailVO;
import com.education.platform.task.vo.CourseTaskMemberListVO;
import com.education.platform.task.vo.TaskSubmissionVO;
import java.util.List;

public interface TaskSubmissionService extends IService<TaskSubmission> {

    List<CourseTaskMemberListVO> listCurrentMemberCourseTasks(Long courseId);

    CourseTaskMemberDetailVO getCurrentMemberTaskDetail(Long taskId);

    List<TaskSubmissionVO> listCurrentMemberTaskSubmissions(Long taskId);

    void submitCurrentMemberTask(Long taskId, TaskSubmissionSaveDTO request);
}
