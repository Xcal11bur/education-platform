package com.education.platform.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.exam.entity.ExamQuestion;
import com.education.platform.task.dto.TaskQuestionSaveDTO;
import com.education.platform.task.vo.TaskQuestionVO;
import java.util.List;

public interface ExamQuestionService extends IService<ExamQuestion> {

    List<TaskQuestionVO> listTeacherQuestions(Long examId);

    void createTeacherQuestion(Long examId, TaskQuestionSaveDTO request);

    void updateTeacherQuestion(Long id, TaskQuestionSaveDTO request);

    void deleteTeacherQuestion(Long id);
}
