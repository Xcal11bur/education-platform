package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseSectionContentSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseChapter;
import com.education.platform.course.entity.CourseSection;
import com.education.platform.course.entity.CourseSectionContent;
import com.education.platform.course.mapper.CourseChapterMapper;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseSectionContentMapper;
import com.education.platform.course.mapper.CourseSectionMapper;
import com.education.platform.course.service.CourseSectionContentService;
import com.education.platform.course.vo.CourseSectionContentVO;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CourseSectionContentServiceImpl extends ServiceImpl<CourseSectionContentMapper, CourseSectionContent>
        implements CourseSectionContentService {

    private static final String TYPE_RICH_TEXT = "RICH_TEXT";
    private static final String TYPE_VIDEO = "VIDEO";
    private static final String TYPE_PDF = "PDF";
    private static final String TYPE_IMAGE = "IMAGE";
    private static final String TYPE_PPT = "PPT";
    private static final String TYPE_FILE = "FILE";
    private static final Set<String> CONTENT_TYPES = Set.of(
            TYPE_RICH_TEXT,
            TYPE_VIDEO,
            TYPE_PDF,
            TYPE_IMAGE,
            TYPE_PPT,
            TYPE_FILE
    );

    private final CourseMapper courseMapper;
    private final CourseChapterMapper courseChapterMapper;
    private final CourseSectionMapper courseSectionMapper;

    public CourseSectionContentServiceImpl(
            CourseMapper courseMapper,
            CourseChapterMapper courseChapterMapper,
            CourseSectionMapper courseSectionMapper) {
        this.courseMapper = courseMapper;
        this.courseChapterMapper = courseChapterMapper;
        this.courseSectionMapper = courseSectionMapper;
    }

    @Override
    public List<CourseSectionContentVO> listAdminContents(Long sectionId) {
        getSectionOrThrow(sectionId, false);
        List<CourseSectionContent> contents = lambdaQuery()
                .eq(CourseSectionContent::getSectionId, sectionId)
                .orderByAsc(CourseSectionContent::getSort, CourseSectionContent::getId)
                .list();
        return fillContentVOs(contents);
    }

    @Override
    public CourseSectionContentVO getContentDetail(Long id) {
        CourseSectionContent content = getContentOrThrow(id);
        return fillContentVOs(List.of(content)).stream()
                .findFirst()
                .orElseThrow(() -> new BusinessException(ResultCode.NOT_FOUND.getCode(), "section content not found"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createContent(Long sectionId, CourseSectionContentSaveDTO request) {
        CourseSection section = getSectionOrThrow(sectionId, false);
        CourseSectionContent content = new CourseSectionContent();
        content.setCourseId(section.getCourseId());
        content.setChapterId(section.getChapterId());
        content.setSectionId(section.getId());
        fillContent(content, request);
        content.setSort(nextContentSort(sectionId));
        save(content);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateContent(Long id, CourseSectionContentSaveDTO request) {
        CourseSectionContent content = getContentOrThrow(id);
        getSectionOrThrow(content.getSectionId(), false);
        fillContent(content, request);
        updateById(content);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteContent(Long id) {
        getContentOrThrow(id);
        removeById(id);
    }

    @Override
    public List<CourseSectionContentVO> listPortalContents(Long sectionId) {
        getSectionOrThrow(sectionId, true);
        List<CourseSectionContent> contents = lambdaQuery()
                .eq(CourseSectionContent::getSectionId, sectionId)
                .eq(CourseSectionContent::getStatus, 1)
                .orderByAsc(CourseSectionContent::getSort, CourseSectionContent::getId)
                .list();
        return fillContentVOs(contents);
    }

    @Override
    public CourseSectionContent getPortalPreviewContent(Long id) {
        CourseSectionContent content = getContentOrThrow(id);
        if (!Objects.equals(content.getStatus(), 1)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "section content not found");
        }
        getSectionOrThrow(content.getSectionId(), true);
        return content;
    }

    private void fillContent(CourseSectionContent content, CourseSectionContentSaveDTO request) {
        validateContent(request);
        String contentType = request.getContentType().trim().toUpperCase();
        content.setTitle(request.getTitle());
        content.setContentType(contentType);
        content.setContentHtml(TYPE_RICH_TEXT.equals(contentType) ? request.getContentHtml() : null);
        content.setContentJson(TYPE_RICH_TEXT.equals(contentType) ? request.getContentJson() : null);
        content.setFileUrl(TYPE_RICH_TEXT.equals(contentType) ? null : request.getFileUrl());
        content.setObjectKey(TYPE_RICH_TEXT.equals(contentType) ? null : request.getObjectKey());
        content.setFileName(TYPE_RICH_TEXT.equals(contentType) ? null : request.getFileName());
        content.setMimeType(TYPE_RICH_TEXT.equals(contentType) ? null : request.getMimeType());
        content.setFileSize(request.getFileSize() == null ? 0L : request.getFileSize());
        content.setDuration(TYPE_VIDEO.equals(contentType) && request.getDuration() != null ? request.getDuration() : 0);
        content.setStatus(request.getStatus() == null ? 1 : request.getStatus());
    }

    private void validateContent(CourseSectionContentSaveDTO request) {
        String contentType = request.getContentType() == null ? "" : request.getContentType().trim().toUpperCase();
        if (!CONTENT_TYPES.contains(contentType)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "invalid section content type");
        }
        if (TYPE_RICH_TEXT.equals(contentType)) {
            if (request.getContentHtml() == null || request.getContentHtml().trim().isEmpty()) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "rich text content must not be blank");
            }
            return;
        }
        if (request.getFileUrl() == null || request.getFileUrl().trim().isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "content file url must not be blank");
        }
        String mimeType = request.getMimeType() == null ? "" : request.getMimeType().trim().toLowerCase();
        String fileName = request.getFileName() == null ? "" : request.getFileName().trim().toLowerCase();
        if (TYPE_PDF.equals(contentType)
                && !"application/pdf".equals(mimeType)
                && !fileName.endsWith(".pdf")) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "pdf content must be a PDF file");
        }
        if (TYPE_IMAGE.equals(contentType)
                && !mimeType.startsWith("image/")
                && !fileName.endsWith(".jpg")
                && !fileName.endsWith(".jpeg")
                && !fileName.endsWith(".png")
                && !fileName.endsWith(".gif")
                && !fileName.endsWith(".webp")
                && !fileName.endsWith(".bmp")
                && !fileName.endsWith(".svg")) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "image content must be an image file");
        }
        if (TYPE_VIDEO.equals(contentType)
                && !mimeType.startsWith("video/")
                && !fileName.endsWith(".mp4")
                && !fileName.endsWith(".mov")
                && !fileName.endsWith(".m4v")
                && !fileName.endsWith(".webm")
                && !fileName.endsWith(".avi")
                && !fileName.endsWith(".mkv")) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "video content must be a video file");
        }
        if (TYPE_PPT.equals(contentType)
                && !fileName.endsWith(".ppt")
                && !fileName.endsWith(".pptx")) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "ppt content must be a PPT file");
        }
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

    private CourseSectionContent getContentOrThrow(Long id) {
        CourseSectionContent content = getById(id);
        if (content == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "section content not found");
        }
        return content;
    }

    private int nextContentSort(Long sectionId) {
        CourseSectionContent last = getOne(
                Wrappers.<CourseSectionContent>lambdaQuery()
                        .eq(CourseSectionContent::getSectionId, sectionId)
                        .orderByDesc(CourseSectionContent::getSort, CourseSectionContent::getId)
                        .last("LIMIT 1"),
                false
        );
        return last == null || last.getSort() == null ? 1 : last.getSort() + 1;
    }

    private List<CourseSectionContentVO> fillContentVOs(List<CourseSectionContent> contents) {
        if (contents.isEmpty()) {
            return List.of();
        }
        Map<Long, Course> courseMap = listCoursesByIds(contents.stream()
                .map(CourseSectionContent::getCourseId)
                .filter(Objects::nonNull)
                .toList());
        Map<Long, CourseChapter> chapterMap = listChaptersByIds(contents.stream()
                .map(CourseSectionContent::getChapterId)
                .filter(Objects::nonNull)
                .toList());
        Map<Long, CourseSection> sectionMap = listSectionsByIds(contents.stream()
                .map(CourseSectionContent::getSectionId)
                .filter(Objects::nonNull)
                .toList());
        return contents.stream().map(content -> {
            CourseSectionContentVO vo = new CourseSectionContentVO();
            BeanUtils.copyProperties(content, vo);
            Course course = courseMap.get(content.getCourseId());
            if (course != null) {
                vo.setCourseTitle(course.getTitle());
            }
            CourseChapter chapter = chapterMap.get(content.getChapterId());
            if (chapter != null) {
                vo.setChapterTitle(chapter.getTitle());
            }
            CourseSection section = sectionMap.get(content.getSectionId());
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
