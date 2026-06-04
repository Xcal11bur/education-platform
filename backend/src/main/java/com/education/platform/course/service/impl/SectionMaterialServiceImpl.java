package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.SectionMaterialSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseChapter;
import com.education.platform.course.entity.CourseSection;
import com.education.platform.course.entity.SectionMaterial;
import com.education.platform.course.mapper.CourseChapterMapper;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseSectionMapper;
import com.education.platform.course.mapper.SectionMaterialMapper;
import com.education.platform.course.service.SectionMaterialService;
import com.education.platform.course.vo.SectionMaterialVO;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SectionMaterialServiceImpl extends ServiceImpl<SectionMaterialMapper, SectionMaterial>
        implements SectionMaterialService {

    private final CourseMapper courseMapper;
    private final CourseChapterMapper courseChapterMapper;
    private final CourseSectionMapper courseSectionMapper;

    public SectionMaterialServiceImpl(
            CourseMapper courseMapper,
            CourseChapterMapper courseChapterMapper,
            CourseSectionMapper courseSectionMapper) {
        this.courseMapper = courseMapper;
        this.courseChapterMapper = courseChapterMapper;
        this.courseSectionMapper = courseSectionMapper;
    }

    @Override
    public List<SectionMaterialVO> listAdminMaterials(Long sectionId) {
        getSectionOrThrow(sectionId, false);
        List<SectionMaterial> materials = lambdaQuery()
                .eq(SectionMaterial::getSectionId, sectionId)
                .orderByAsc(SectionMaterial::getSort, SectionMaterial::getId)
                .list();
        return fillMaterialVOs(materials);
    }

    @Override
    public SectionMaterialVO getMaterialDetail(Long id) {
        SectionMaterial material = getMaterialOrThrow(id);
        return fillMaterialVOs(List.of(material)).stream().findFirst()
                .orElseThrow(() -> new BusinessException(ResultCode.NOT_FOUND.getCode(), "section material not found"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createMaterial(Long sectionId, SectionMaterialSaveDTO request) {
        CourseSection section = getSectionOrThrow(sectionId, false);
        SectionMaterial material = new SectionMaterial();
        material.setCourseId(section.getCourseId());
        material.setChapterId(section.getChapterId());
        material.setSectionId(section.getId());
        fillMaterial(material, request);
        save(material);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateMaterial(Long id, SectionMaterialSaveDTO request) {
        SectionMaterial material = getMaterialOrThrow(id);
        getSectionOrThrow(material.getSectionId(), false);
        fillMaterial(material, request);
        updateById(material);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteMaterial(Long id) {
        getMaterialOrThrow(id);
        removeById(id);
    }

    @Override
    public List<SectionMaterialVO> listPortalMaterials(Long sectionId) {
        getSectionOrThrow(sectionId, true);
        List<SectionMaterial> materials = lambdaQuery()
                .eq(SectionMaterial::getSectionId, sectionId)
                .orderByAsc(SectionMaterial::getSort, SectionMaterial::getId)
                .list();
        return fillMaterialVOs(materials);
    }

    private void fillMaterial(SectionMaterial material, SectionMaterialSaveDTO request) {
        material.setMaterialName(request.getMaterialName());
        material.setMaterialType(request.getMaterialType());
        material.setFileUrl(request.getFileUrl());
        material.setFileSize(request.getFileSize() == null ? 0L : request.getFileSize());
        material.setDownloadLimit(request.getDownloadLimit() == null ? 1 : request.getDownloadLimit());
        material.setSort(request.getSort() == null ? 0 : request.getSort());
    }

    private CourseSection getSectionOrThrow(Long sectionId, boolean portalOnly) {
        CourseSection section = courseSectionMapper.selectById(sectionId);
        if (section == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "section not found");
        }
        if (portalOnly) {
            Course course = getCourseOrThrow(section.getCourseId(), true);
            if (!Objects.equals(course.getId(), section.getCourseId())) {
                throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "section not found");
            }
        }
        return section;
    }

    private Course getCourseOrThrow(Long courseId, boolean portalOnly) {
        Course course = courseMapper.selectById(courseId);
        if (course == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        if (portalOnly && !Objects.equals(course.getPublishStatus(), 1)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        return course;
    }

    private SectionMaterial getMaterialOrThrow(Long id) {
        SectionMaterial material = getById(id);
        if (material == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "section material not found");
        }
        return material;
    }

    private List<SectionMaterialVO> fillMaterialVOs(List<SectionMaterial> materials) {
        if (materials.isEmpty()) {
            return List.of();
        }
        Map<Long, Course> courseMap = listCoursesByIds(materials.stream()
                .map(SectionMaterial::getCourseId)
                .filter(Objects::nonNull)
                .toList());
        Map<Long, CourseChapter> chapterMap = listChaptersByIds(materials.stream()
                .map(SectionMaterial::getChapterId)
                .filter(Objects::nonNull)
                .toList());
        Map<Long, CourseSection> sectionMap = listSectionsByIds(materials.stream()
                .map(SectionMaterial::getSectionId)
                .filter(Objects::nonNull)
                .toList());
        return materials.stream().map(material -> {
            SectionMaterialVO vo = new SectionMaterialVO();
            BeanUtils.copyProperties(material, vo);
            Course course = courseMap.get(material.getCourseId());
            if (course != null) {
                vo.setCourseTitle(course.getTitle());
            }
            CourseChapter chapter = chapterMap.get(material.getChapterId());
            if (chapter != null) {
                vo.setChapterTitle(chapter.getTitle());
            }
            CourseSection section = sectionMap.get(material.getSectionId());
            if (section != null) {
                vo.setSectionTitle(section.getTitle());
            }
            return vo;
        }).toList();
    }

    private Map<Long, Course> listCoursesByIds(Collection<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return courseMapper.selectList(Wrappers.<Course>lambdaQuery().in(Course::getId, ids)).stream()
                .collect(Collectors.toMap(Course::getId, Function.identity()));
    }

    private Map<Long, CourseChapter> listChaptersByIds(Collection<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return courseChapterMapper.selectList(Wrappers.<CourseChapter>lambdaQuery().in(CourseChapter::getId, ids)).stream()
                .collect(Collectors.toMap(CourseChapter::getId, Function.identity()));
    }

    private Map<Long, CourseSection> listSectionsByIds(Collection<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return courseSectionMapper.selectList(Wrappers.<CourseSection>lambdaQuery().in(CourseSection::getId, ids)).stream()
                .collect(Collectors.toMap(CourseSection::getId, Function.identity()));
    }
}
