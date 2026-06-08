package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.course.dto.CourseChapterSaveDTO;
import com.education.platform.course.entity.CourseChapter;
import com.education.platform.course.vo.CourseChapterVO;
import java.util.List;

public interface CourseChapterService extends IService<CourseChapter> {

    void createChapter(Long courseId, CourseChapterSaveDTO request);

    void updateChapter(Long id, CourseChapterSaveDTO request);

    void deleteChapter(Long id);

    List<CourseChapterVO> getChapterTree(Long courseId, boolean portalOnly);

    void createTeacherChapter(Long courseId, CourseChapterSaveDTO request);

    void updateTeacherChapter(Long id, CourseChapterSaveDTO request);

    void deleteTeacherChapter(Long id);

    List<CourseChapterVO> getTeacherChapterTree(Long courseId);
}
