package com.education.platform.exam.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.education.platform.exam.entity.ExamSubmission;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;

public interface ExamSubmissionMapper extends BaseMapper<ExamSubmission> {

    @Delete("DELETE FROM exam_submission WHERE task_id = #{taskId}")
    int hardDeleteByTaskId(@Param("taskId") Long taskId);
}
