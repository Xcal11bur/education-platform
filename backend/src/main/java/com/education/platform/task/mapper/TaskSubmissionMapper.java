package com.education.platform.task.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.education.platform.task.entity.TaskSubmission;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;

public interface TaskSubmissionMapper extends BaseMapper<TaskSubmission> {

    @Delete("DELETE FROM task_submission WHERE task_id = #{taskId}")
    int hardDeleteByTaskId(@Param("taskId") Long taskId);
}
