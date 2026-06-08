package com.education.platform.task.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.task.dto.TaskQuestionSaveDTO;
import com.education.platform.task.entity.TaskQuestion;
import com.education.platform.task.vo.TaskQuestionVO;
import java.util.List;

public interface TaskQuestionService extends IService<TaskQuestion> {

    List<TaskQuestionVO> listTeacherQuestions(Long taskId);

    void createTeacherQuestion(Long taskId, TaskQuestionSaveDTO request);

    void updateTeacherQuestion(Long id, TaskQuestionSaveDTO request);

    void deleteTeacherQuestion(Long id);
}
