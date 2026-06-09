package com.education.platform.exam.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.education.platform.exam.entity.CourseExam;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;

public interface CourseExamMapper extends BaseMapper<CourseExam> {

    @Delete("DELETE FROM course_exam WHERE id = #{id}")
    int hardDeleteById(@Param("id") Long id);
}
