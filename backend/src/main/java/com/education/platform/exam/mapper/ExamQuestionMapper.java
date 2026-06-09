package com.education.platform.exam.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.education.platform.exam.entity.ExamQuestion;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;

public interface ExamQuestionMapper extends BaseMapper<ExamQuestion> {

    @Delete("DELETE FROM exam_question WHERE task_id = #{taskId}")
    int hardDeleteByTaskId(@Param("taskId") Long taskId);
}
