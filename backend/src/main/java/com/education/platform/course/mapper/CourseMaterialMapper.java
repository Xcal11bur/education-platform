package com.education.platform.course.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.education.platform.course.entity.CourseMaterial;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;

public interface CourseMaterialMapper extends BaseMapper<CourseMaterial> {

    @Delete("DELETE FROM course_material WHERE id = #{id}")
    int deleteMaterialPhysically(@Param("id") Long id);
}
