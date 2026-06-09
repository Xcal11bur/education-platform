package com.education.platform.task.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.education.platform.task.entity.TaskQuestion;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;

public interface TaskQuestionMapper extends BaseMapper<TaskQuestion> {

    @Delete("DELETE FROM task_question WHERE task_id = #{taskId}")
    int hardDeleteByTaskId(@Param("taskId") Long taskId);
}
