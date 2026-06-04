package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.course.dto.CourseSectionSaveDTO;
import com.education.platform.course.entity.CourseSection;

public interface CourseSectionService extends IService<CourseSection> {

    void createSection(Long chapterId, CourseSectionSaveDTO request);

    void updateSection(Long id, CourseSectionSaveDTO request);

    void deleteSection(Long id);
}
