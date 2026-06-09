package com.education.platform.exam.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.exam.dto.CourseExamQueryDTO;
import com.education.platform.exam.dto.CourseExamSaveDTO;
import com.education.platform.exam.entity.CourseExam;
import com.education.platform.exam.vo.CourseExamVO;

public interface CourseExamService extends IService<CourseExam> {

    PageResponse<CourseExamVO> pageTeacherExams(CourseExamQueryDTO queryDTO);

    CourseExamVO getTeacherExamDetail(Long id);

    void createTeacherExam(CourseExamSaveDTO request);

    void updateTeacherExam(Long id, CourseExamSaveDTO request);

    void deleteTeacherExam(Long id);
}
