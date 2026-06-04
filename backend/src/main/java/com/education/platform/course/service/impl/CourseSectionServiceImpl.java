package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseSectionSaveDTO;
import com.education.platform.course.entity.CourseChapter;
import com.education.platform.course.entity.CourseSection;
import com.education.platform.course.entity.SectionMaterial;
import com.education.platform.course.mapper.CourseChapterMapper;
import com.education.platform.course.mapper.CourseSectionMapper;
import com.education.platform.course.mapper.SectionMaterialMapper;
import com.education.platform.course.service.CourseSectionService;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Service;

@Service
public class CourseSectionServiceImpl extends ServiceImpl<CourseSectionMapper, CourseSection>
        implements CourseSectionService {

    private final CourseChapterMapper courseChapterMapper;
    private final SectionMaterialMapper sectionMaterialMapper;

    public CourseSectionServiceImpl(CourseChapterMapper courseChapterMapper, SectionMaterialMapper sectionMaterialMapper) {
        this.courseChapterMapper = courseChapterMapper;
        this.sectionMaterialMapper = sectionMaterialMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createSection(Long chapterId, CourseSectionSaveDTO request) {
        CourseChapter chapter = getChapterOrThrow(chapterId);
        CourseSection section = new CourseSection();
        section.setCourseId(chapter.getCourseId());
        section.setChapterId(chapterId);
        fillSection(section, request);
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
        boolean hasMaterials = sectionMaterialMapper.selectCount(
                Wrappers.<SectionMaterial>lambdaQuery().eq(SectionMaterial::getSectionId, id)
        ) > 0;
        if (hasMaterials) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "section has materials and cannot be deleted");
        }
        removeById(id);
    }

    private void fillSection(CourseSection section, CourseSectionSaveDTO request) {
        section.setTitle(request.getTitle());
        section.setSectionType(request.getSectionType());
        section.setContent(request.getContent());
        section.setVideoUrl(request.getVideoUrl());
        section.setDuration(request.getDuration() == null ? 0 : request.getDuration());
        section.setIsFreeTrial(request.getIsFreeTrial() == null ? 0 : request.getIsFreeTrial());
        section.setSort(request.getSort() == null ? 0 : request.getSort());
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
