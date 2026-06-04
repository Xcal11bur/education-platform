package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseChapterSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseChapter;
import com.education.platform.course.entity.CourseSection;
import com.education.platform.course.entity.SectionMaterial;
import com.education.platform.course.mapper.CourseChapterMapper;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseSectionMapper;
import com.education.platform.course.mapper.SectionMaterialMapper;
import com.education.platform.course.service.CourseChapterService;
import com.education.platform.course.vo.CourseChapterVO;
import com.education.platform.course.vo.CourseSectionVO;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CourseChapterServiceImpl extends ServiceImpl<CourseChapterMapper, CourseChapter>
        implements CourseChapterService {

    private final CourseMapper courseMapper;
    private final CourseSectionMapper courseSectionMapper;
    private final SectionMaterialMapper sectionMaterialMapper;

    public CourseChapterServiceImpl(
            CourseMapper courseMapper,
            CourseSectionMapper courseSectionMapper,
            SectionMaterialMapper sectionMaterialMapper) {
        this.courseMapper = courseMapper;
        this.courseSectionMapper = courseSectionMapper;
        this.sectionMaterialMapper = sectionMaterialMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createChapter(Long courseId, CourseChapterSaveDTO request) {
        getCourseOrThrow(courseId, false);
        CourseChapter chapter = new CourseChapter();
        chapter.setCourseId(courseId);
        chapter.setTitle(request.getTitle());
        chapter.setSort(request.getSort() == null ? 0 : request.getSort());
        save(chapter);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateChapter(Long id, CourseChapterSaveDTO request) {
        CourseChapter chapter = getChapterOrThrow(id);
        chapter.setTitle(request.getTitle());
        chapter.setSort(request.getSort() == null ? 0 : request.getSort());
        updateById(chapter);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteChapter(Long id) {
        CourseChapter chapter = getChapterOrThrow(id);
        boolean hasSections = courseSectionMapper.selectCount(
                Wrappers.<CourseSection>lambdaQuery().eq(CourseSection::getChapterId, id)
        ) > 0;
        if (hasSections) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "chapter has sections and cannot be deleted");
        }
        removeById(chapter.getId());
    }

    @Override
    public List<CourseChapterVO> getChapterTree(Long courseId, boolean portalOnly) {
        getCourseOrThrow(courseId, portalOnly);

        List<CourseChapter> chapters = lambdaQuery()
                .eq(CourseChapter::getCourseId, courseId)
                .orderByAsc(CourseChapter::getSort, CourseChapter::getId)
                .list();
        if (chapters.isEmpty()) {
            return List.of();
        }

        List<CourseSection> sections = courseSectionMapper.selectList(
                Wrappers.<CourseSection>lambdaQuery()
                        .eq(CourseSection::getCourseId, courseId)
                        .orderByAsc(CourseSection::getSort, CourseSection::getId)
        );
        Map<Long, Long> sectionMaterialCountMap = sections.isEmpty()
                ? Map.of()
                : sectionMaterialMapper.selectList(
                                Wrappers.<SectionMaterial>lambdaQuery()
                                        .in(SectionMaterial::getSectionId, sections.stream().map(CourseSection::getId).toList())
                        ).stream()
                        .collect(Collectors.groupingBy(SectionMaterial::getSectionId, Collectors.counting()));
        Map<Long, List<CourseSection>> sectionMap = sections.stream()
                .collect(Collectors.groupingBy(CourseSection::getChapterId));

        return chapters.stream()
                .sorted(Comparator.comparing(CourseChapter::getSort).thenComparing(CourseChapter::getId))
                .map(chapter -> {
                    CourseChapterVO vo = new CourseChapterVO();
                    BeanUtils.copyProperties(chapter, vo);
                    List<CourseSectionVO> sectionVOs = sectionMap.getOrDefault(chapter.getId(), List.of()).stream()
                            .sorted(Comparator.comparing(CourseSection::getSort).thenComparing(CourseSection::getId))
                            .map(section -> toSectionVO(section, sectionMaterialCountMap.getOrDefault(section.getId(), 0L)))
                            .toList();
                    vo.setSections(sectionVOs);
                    return vo;
                })
                .toList();
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

    private CourseChapter getChapterOrThrow(Long id) {
        CourseChapter chapter = getById(id);
        if (chapter == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "chapter not found");
        }
        return chapter;
    }

    private CourseSectionVO toSectionVO(CourseSection section, Long materialCount) {
        CourseSectionVO vo = new CourseSectionVO();
        BeanUtils.copyProperties(section, vo);
        vo.setMaterialCount(materialCount);
        return vo;
    }
}
