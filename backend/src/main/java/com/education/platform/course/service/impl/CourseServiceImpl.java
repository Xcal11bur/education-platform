package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.vo.CourseCategoryVO;
import com.education.platform.course.vo.CourseChapterVO;
import com.education.platform.course.vo.CourseDetailVO;
import com.education.platform.course.vo.CourseTeacherVO;
import com.education.platform.course.dto.CourseQueryDTO;
import com.education.platform.course.dto.CourseSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseCategory;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.service.CourseChapterService;
import com.education.platform.course.service.CourseService;
import com.education.platform.course.vo.CourseVO;
import com.education.platform.teacher.entity.Teacher;
import com.education.platform.teacher.mapper.TeacherMapper;
import java.math.BigDecimal;
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
import org.springframework.util.StringUtils;

@Service
public class CourseServiceImpl extends ServiceImpl<CourseMapper, Course> implements CourseService {

    private static final int PUBLISH_STATUS_DRAFT = 0;
    private static final int PUBLISH_STATUS_PUBLISHED = 1;
    private static final int PUBLISH_STATUS_UNPUBLISHED = 2;

    private final TeacherMapper teacherMapper;
    private final com.education.platform.course.mapper.CourseCategoryMapper courseCategoryMapper;
    private final CourseChapterService courseChapterService;

    public CourseServiceImpl(TeacherMapper teacherMapper,
                             com.education.platform.course.mapper.CourseCategoryMapper courseCategoryMapper,
                             CourseChapterService courseChapterService) {
        this.teacherMapper = teacherMapper;
        this.courseCategoryMapper = courseCategoryMapper;
        this.courseChapterService = courseChapterService;
    }

    @Override
    public PageResponse<CourseVO> pageAdminCourses(CourseQueryDTO queryDTO) {
        IPage<Course> page = lambdaQuery()
                .like(StringUtils.hasText(queryDTO.getTitle()), Course::getTitle, queryDTO.getTitle())
                .eq(queryDTO.getTeacherId() != null, Course::getTeacherId, queryDTO.getTeacherId())
                .eq(queryDTO.getCategoryLevel2Id() != null, Course::getCategoryLevel2Id, queryDTO.getCategoryLevel2Id())
                .eq(queryDTO.getPublishStatus() != null, Course::getPublishStatus, queryDTO.getPublishStatus())
                .orderByDesc(Course::getSort, Course::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<CourseVO> list = fillCourseVOs(page.getRecords());
        return PageResponse.<CourseVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public CourseDetailVO getAdminCourseDetail(Long id) {
        Course course = getCourseOrThrow(id);
        return buildCourseDetail(course, false);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createCourse(CourseSaveDTO request) {
        validateCourseRequest(request);
        Course course = new Course();
        BeanUtils.copyProperties(request, course);
        if (course.getDifficulty() == null) {
            course.setDifficulty(1);
        }
        if (course.getPrice() == null) {
            course.setPrice(BigDecimal.ZERO);
        }
        if (course.getPublishStatus() == null) {
            course.setPublishStatus(PUBLISH_STATUS_DRAFT);
        }
        if (course.getSort() == null) {
            course.setSort(0);
        }
        course.setStudyCount(0);
        save(course);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCourse(Long id, CourseSaveDTO request) {
        Course course = getCourseOrThrow(id);
        validateCourseRequest(request);
        BeanUtils.copyProperties(request, course, "id", "studyCount");
        if (course.getDifficulty() == null) {
            course.setDifficulty(1);
        }
        if (course.getPrice() == null) {
            course.setPrice(BigDecimal.ZERO);
        }
        if (course.getSort() == null) {
            course.setSort(0);
        }
        updateById(course);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updatePublishStatus(Long id, Integer publishStatus) {
        if (!List.of(PUBLISH_STATUS_DRAFT, PUBLISH_STATUS_PUBLISHED, PUBLISH_STATUS_UNPUBLISHED).contains(publishStatus)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "publishStatus must be 0, 1 or 2");
        }
        Course course = getCourseOrThrow(id);
        if (publishStatus == PUBLISH_STATUS_PUBLISHED) {
            validateCourseCanBePublished(course);
        }
        course.setPublishStatus(publishStatus);
        updateById(course);
    }

    @Override
    public PageResponse<CourseVO> pagePortalCourses(CourseQueryDTO queryDTO) {
        IPage<Course> page = lambdaQuery()
                .eq(Course::getPublishStatus, PUBLISH_STATUS_PUBLISHED)
                .like(StringUtils.hasText(queryDTO.getTitle()), Course::getTitle, queryDTO.getTitle())
                .eq(queryDTO.getTeacherId() != null, Course::getTeacherId, queryDTO.getTeacherId())
                .eq(queryDTO.getCategoryLevel2Id() != null, Course::getCategoryLevel2Id, queryDTO.getCategoryLevel2Id())
                .orderByDesc(Course::getSort, Course::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<CourseVO> list = fillCourseVOs(page.getRecords());
        return PageResponse.<CourseVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public CourseDetailVO getPortalCourseDetail(Long id) {
        Course course = getCourseOrThrow(id);
        if (!Objects.equals(course.getPublishStatus(), PUBLISH_STATUS_PUBLISHED)) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        return buildCourseDetail(course, true);
    }

    private CourseDetailVO buildCourseDetail(Course course, boolean portalOnly) {
        Map<Long, Teacher> teacherMap = listTeachersByIds(List.of(course.getTeacherId()));
        Map<Long, CourseCategory> categoryMap = listCategoriesByIds(
                List.of(course.getCategoryLevel1Id(), course.getCategoryLevel2Id())
        );

        CourseDetailVO detailVO = new CourseDetailVO();
        BeanUtils.copyProperties(course, detailVO);

        Teacher teacher = teacherMap.get(course.getTeacherId());
        if (teacher != null) {
            CourseTeacherVO teacherVO = new CourseTeacherVO();
            teacherVO.setId(teacher.getId());
            teacherVO.setName(teacher.getName());
            teacherVO.setTitle(teacher.getTitle());
            teacherVO.setIntro(teacher.getIntro());
            teacherVO.setAvatar(teacher.getAvatar());
            detailVO.setTeacher(teacherVO);
        }

        CourseCategory level1 = categoryMap.get(course.getCategoryLevel1Id());
        if (level1 != null) {
            detailVO.setCategoryLevel1(toCategoryVO(level1));
        }

        CourseCategory level2 = categoryMap.get(course.getCategoryLevel2Id());
        if (level2 != null) {
            detailVO.setCategoryLevel2(toCategoryVO(level2));
        }

        List<CourseChapterVO> chapters = courseChapterService.getChapterTree(course.getId(), portalOnly);
        detailVO.setChapters(chapters);
        return detailVO;
    }

    private Course getCourseOrThrow(Long id) {
        Course course = getById(id);
        if (course == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        return course;
    }

    private void validateCourseRequest(CourseSaveDTO request) {
        Teacher teacher = teacherMapper.selectById(request.getTeacherId());
        if (teacher == null || !Objects.equals(teacher.getStatus(), 1)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "teacher is invalid or disabled");
        }

        CourseCategory level1 = courseCategoryMapper.selectById(request.getCategoryLevel1Id());
        if (level1 == null || !Objects.equals(level1.getLevel(), 1) || !Objects.equals(level1.getStatus(), 1)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "level 1 category is invalid");
        }

        CourseCategory level2 = courseCategoryMapper.selectById(request.getCategoryLevel2Id());
        if (level2 == null || !Objects.equals(level2.getLevel(), 2) || !Objects.equals(level2.getStatus(), 1)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "level 2 category is invalid");
        }

        if (!Objects.equals(level2.getParentId(), level1.getId())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "category hierarchy does not match");
        }
    }

    private void validateCourseCanBePublished(Course course) {
        if (!StringUtils.hasText(course.getTitle())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "course title is required before publishing");
        }
        validateCourseRequest(toSaveDTO(course));
    }

    private CourseSaveDTO toSaveDTO(Course course) {
        CourseSaveDTO dto = new CourseSaveDTO();
        BeanUtils.copyProperties(course, dto);
        return dto;
    }

    private List<CourseVO> fillCourseVOs(List<Course> courses) {
        if (courses.isEmpty()) {
            return List.of();
        }

        Set<Long> teacherIds = courses.stream()
                .map(Course::getTeacherId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, Teacher> teacherMap = listTeachersByIds(teacherIds);

        Set<Long> categoryIds = courses.stream()
                .flatMap(item -> java.util.stream.Stream.of(item.getCategoryLevel1Id(), item.getCategoryLevel2Id()))
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, CourseCategory> categoryMap = listCategoriesByIds(categoryIds);

        return courses.stream()
                .map(course -> {
                    CourseVO vo = new CourseVO();
                    BeanUtils.copyProperties(course, vo);
                    Teacher teacher = teacherMap.get(course.getTeacherId());
                    if (teacher != null) {
                        vo.setTeacherName(teacher.getName());
                    }
                    CourseCategory level1 = categoryMap.get(course.getCategoryLevel1Id());
                    if (level1 != null) {
                        vo.setCategoryLevel1Name(level1.getName());
                    }
                    CourseCategory level2 = categoryMap.get(course.getCategoryLevel2Id());
                    if (level2 != null) {
                        vo.setCategoryLevel2Name(level2.getName());
                    }
                    return vo;
                })
                .toList();
    }

    private Map<Long, Teacher> listTeachersByIds(Collection<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return teacherMapper.selectList(
                        Wrappers.<Teacher>lambdaQuery().in(Teacher::getId, ids)
                ).stream()
                .collect(Collectors.toMap(Teacher::getId, Function.identity()));
    }

    private Map<Long, CourseCategory> listCategoriesByIds(Collection<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return courseCategoryMapper.selectList(
                        Wrappers.<CourseCategory>lambdaQuery().in(CourseCategory::getId, ids)
                ).stream()
                .collect(Collectors.toMap(CourseCategory::getId, Function.identity()));
    }

    private CourseCategoryVO toCategoryVO(CourseCategory category) {
        CourseCategoryVO vo = new CourseCategoryVO();
        BeanUtils.copyProperties(category, vo);
        return vo;
    }
}
