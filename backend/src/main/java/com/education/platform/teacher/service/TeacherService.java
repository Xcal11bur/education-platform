package com.education.platform.teacher.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.teacher.dto.TeacherPasswordUpdateDTO;
import com.education.platform.teacher.dto.TeacherProfileUpdateDTO;
import com.education.platform.teacher.dto.TeacherQueryDTO;
import com.education.platform.teacher.dto.TeacherSaveDTO;
import com.education.platform.teacher.entity.Teacher;
import com.education.platform.teacher.vo.TeacherProfileVO;
import com.education.platform.teacher.vo.TeacherVO;
import java.util.Optional;

public interface TeacherService extends IService<Teacher> {

    Optional<Teacher> findByLoginName(String loginName);

    PageResponse<TeacherVO> pageTeachers(TeacherQueryDTO queryDTO);

    TeacherVO getTeacherDetail(Long id);

    void createTeacher(TeacherSaveDTO request);

    void updateTeacher(Long id, TeacherSaveDTO request);

    void updateTeacherStatus(Long id, Integer status);

    TeacherProfileVO getCurrentProfile();

    void updateCurrentProfile(TeacherProfileUpdateDTO request);

    void updateCurrentPassword(TeacherPasswordUpdateDTO request);
}
