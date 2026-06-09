package com.education.platform.task.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.education.platform.task.entity.CourseTask;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;

public interface CourseTaskMapper extends BaseMapper<CourseTask> {

    @Delete("DELETE FROM course_task WHERE id = #{id}")
    int hardDeleteById(@Param("id") Long id);
}
