package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseSectionSaveDTO;
import com.education.platform.course.entity.CourseChapter;
import com.education.platform.course.entity.CourseSection;
import com.education.platform.course.entity.CourseSectionContent;
import com.education.platform.course.mapper.CourseChapterMapper;
import com.education.platform.course.mapper.CourseSectionContentMapper;
import com.education.platform.course.mapper.CourseSectionMapper;
import com.education.platform.course.service.CourseSectionService;
import com.education.platform.course.service.TeacherCourseAccessService;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Service;

@Service
public class CourseSectionServiceImpl extends ServiceImpl<CourseSectionMapper, CourseSection>
        implements CourseSectionService {

    private final CourseChapterMapper courseChapterMapper;
    private final CourseSectionContentMapper courseSectionContentMapper;
    private final TeacherCourseAccessService teacherCourseAccessService;

    public CourseSectionServiceImpl(
            CourseChapterMapper courseChapterMapper,
            CourseSectionContentMapper courseSectionContentMapper,
            TeacherCourseAccessService teacherCourseAccessService) {
        this.courseChapterMapper = courseChapterMapper;
        this.courseSectionContentMapper = courseSectionContentMapper;
        this.teacherCourseAccessService = teacherCourseAccessService;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createSection(Long chapterId, CourseSectionSaveDTO request) {
        CourseChapter chapter = getChapterOrThrow(chapterId);
        CourseSection section = new CourseSection();
        section.setCourseId(chapter.getCourseId());
        section.setChapterId(chapterId);
        fillSection(section, request);
        section.setSort(nextSectionSort(chapterId));
        save(section);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateSection(Long id, CourseSectionSaveDTO request) {
        CourseSection section = getSectionOrThrow(id);
        fillSection(section, request);
        updateById(section);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteSection(Long id) {
        getSectionOrThrow(id);
        boolean hasContents = courseSectionContentMapper.selectCount(
                Wrappers.<CourseSectionContent>lambdaQuery().eq(CourseSectionContent::getSectionId, id)
        ) > 0;
        if (hasContents) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "section has content items and cannot be deleted");
        }
        removeById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createTeacherSection(Long chapterId, CourseSectionSaveDTO request) {
        teacherCourseAccessService.getCurrentTeacherChapter(chapterId);
        createSection(chapterId, request);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTeacherSection(Long id, CourseSectionSaveDTO request) {
        teacherCourseAccessService.getCurrentTeacherSection(id);
        updateSection(id, request);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTeacherSection(Long id) {
        teacherCourseAccessService.getCurrentTeacherSection(id);
        deleteSection(id);
    }

    private void fillSection(CourseSection section, CourseSectionSaveDTO request) {
        section.setTitle(request.getTitle());
        section.setIsFreeTrial(request.getIsFreeTrial() == null ? 0 : request.getIsFreeTrial());
    }

    private int nextSectionSort(Long chapterId) {
        CourseSection last = getOne(
                Wrappers.<CourseSection>lambdaQuery()
                        .eq(CourseSection::getChapterId, chapterId)
                        .orderByDesc(CourseSection::getSort, CourseSection::getId)
                        .last("LIMIT 1"),
                false
        );
        return last == null || last.getSort() == null ? 1 : last.getSort() + 1;
    }

    private CourseChapter getChapterOrThrow(Long chapterId) {
        CourseChapter chapter = courseChapterMapper.selectById(chapterId);
        if (chapter == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "chapter not found");
        }
        return chapter;
    }

    private CourseSection getSectionOrThrow(Long id) {
        CourseSection section = getById(id);
        if (section == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "section not found");
        }
        return section;
    }
}
