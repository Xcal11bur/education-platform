package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.core.toolkit.support.SFunction;
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
import com.education.platform.course.entity.CourseBanner;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseChapter;
import com.education.platform.course.entity.CourseCategory;
import com.education.platform.course.entity.CourseEnrollment;
import com.education.platform.course.entity.CourseMaterial;
import com.education.platform.course.entity.CourseReview;
import com.education.platform.course.entity.CourseSection;
import com.education.platform.course.entity.CourseSectionContent;
import com.education.platform.course.mapper.CourseBannerMapper;
import com.education.platform.course.mapper.CourseChapterMapper;
import com.education.platform.course.mapper.CourseEnrollmentMapper;
import com.education.platform.course.mapper.CourseMaterialMapper;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseReviewMapper;
import com.education.platform.course.mapper.CourseSectionContentMapper;
import com.education.platform.course.mapper.CourseSectionMapper;
import com.education.platform.course.service.CourseChapterService;
import com.education.platform.course.service.CourseEnrollmentService;
import com.education.platform.course.service.CourseService;
import com.education.platform.course.service.TeacherCourseAccessService;
import com.education.platform.course.vo.CourseVO;
import com.education.platform.exam.entity.CourseExam;
import com.education.platform.exam.mapper.CourseExamMapper;
import com.education.platform.task.entity.CourseTask;
import com.education.platform.task.mapper.CourseTaskMapper;
import com.education.platform.teacher.entity.Teacher;
import com.education.platform.teacher.mapper.TeacherMapper;
import java.math.BigDecimal;
import java.util.Collection;
import java.util.Comparator;
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
    private final CourseEnrollmentService courseEnrollmentService;
    private final TeacherCourseAccessService teacherCourseAccessService;
    private final CourseBannerMapper courseBannerMapper;
    private final CourseChapterMapper courseChapterMapper;
    private final CourseSectionMapper courseSectionMapper;
    private final CourseSectionContentMapper courseSectionContentMapper;
    private final CourseMaterialMapper courseMaterialMapper;
    private final CourseEnrollmentMapper courseEnrollmentMapper;
    private final CourseReviewMapper courseReviewMapper;
    private final CourseTaskMapper courseTaskMapper;
    private final CourseExamMapper courseExamMapper;

    public CourseServiceImpl(TeacherMapper teacherMapper,
                             com.education.platform.course.mapper.CourseCategoryMapper courseCategoryMapper,
                             CourseChapterService courseChapterService,
                             CourseEnrollmentService courseEnrollmentService,
                             TeacherCourseAccessService teacherCourseAccessService,
                             CourseBannerMapper courseBannerMapper,
                             CourseChapterMapper courseChapterMapper,
                             CourseSectionMapper courseSectionMapper,
                             CourseSectionContentMapper courseSectionContentMapper,
                             CourseMaterialMapper courseMaterialMapper,
                             CourseEnrollmentMapper courseEnrollmentMapper,
                             CourseReviewMapper courseReviewMapper,
                             CourseTaskMapper courseTaskMapper,
                             CourseExamMapper courseExamMapper) {
        this.teacherMapper = teacherMapper;
        this.courseCategoryMapper = courseCategoryMapper;
        this.courseChapterService = courseChapterService;
        this.courseEnrollmentService = courseEnrollmentService;
        this.teacherCourseAccessService = teacherCourseAccessService;
        this.courseBannerMapper = courseBannerMapper;
        this.courseChapterMapper = courseChapterMapper;
        this.courseSectionMapper = courseSectionMapper;
        this.courseSectionContentMapper = courseSectionContentMapper;
        this.courseMaterialMapper = courseMaterialMapper;
        this.courseEnrollmentMapper = courseEnrollmentMapper;
        this.courseReviewMapper = courseReviewMapper;
        this.courseTaskMapper = courseTaskMapper;
        this.courseExamMapper = courseExamMapper;
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
    public PageResponse<CourseVO> pageTeacherCourses(CourseQueryDTO queryDTO) {
        queryDTO.setTeacherId(teacherCourseAccessService.getCurrentTeacherId());
        return pageAdminCourses(queryDTO);
    }

    @Override
    public CourseDetailVO getTeacherCourseDetail(Long id) {
        return buildCourseDetail(teacherCourseAccessService.getCurrentTeacherCourse(id), false);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createCourse(CourseSaveDTO request) {
        validateCourseRequest(request);
        Course course = new Course();
        BeanUtils.copyProperties(request, course);
        fillDefaultCourseFields(course);
        course.setSort(nextSort());
        course.setStudyCount(0);
        save(course);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCourse(Long id, CourseSaveDTO request) {
        Course course = getCourseOrThrow(id);
        validateCourseRequest(request);
        BeanUtils.copyProperties(request, course, "id", "studyCount", "sort");
        fillDefaultCourseFields(course);
        updateById(course);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updatePublishStatus(Long id, Integer publishStatus) {
        applyPublishStatus(getCourseOrThrow(id), publishStatus);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteCourse(Long id) {
        Course course = getCourseOrThrow(id);
        ensureCourseHasNoDependencies(course.getId());
        removeById(course.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createTeacherCourse(CourseSaveDTO request) {
        Long teacherId = teacherCourseAccessService.getCurrentTeacherId();
        request.setTeacherId(teacherId);
        createCourse(request);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTeacherCourse(Long id, CourseSaveDTO request) {
        Long teacherId = teacherCourseAccessService.getCurrentTeacherId();
        Course course = teacherCourseAccessService.getCurrentTeacherCourse(id);
        request.setTeacherId(teacherId);
        validateCourseRequest(request);
        BeanUtils.copyProperties(request, course, "id", "teacherId", "studyCount", "sort");
        course.setTeacherId(teacherId);
        fillDefaultCourseFields(course);
        updateById(course);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateTeacherPublishStatus(Long id, Integer publishStatus) {
        applyPublishStatus(teacherCourseAccessService.getCurrentTeacherCourse(id), publishStatus);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTeacherCourse(Long id) {
        Course course = teacherCourseAccessService.getCurrentTeacherCourse(id);
        ensureCourseHasNoDependencies(course.getId());
        removeById(course.getId());
    }

    private void applyPublishStatus(Course course, Integer publishStatus) {
        if (!List.of(PUBLISH_STATUS_DRAFT, PUBLISH_STATUS_PUBLISHED, PUBLISH_STATUS_UNPUBLISHED).contains(publishStatus)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "publishStatus must be 0, 1 or 2");
        }
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
                .orderByDesc(Course::getStudyCount)
                .orderByAsc(Course::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<CourseVO> list = fillCourseVOs(page.getRecords());
        return PageResponse.<CourseVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(fillEnrollmentFields(list))
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

    @Override
    public List<CourseVO> listCurrentMemberCourses() {
        List<CourseEnrollment> enrollments = courseEnrollmentService.listCurrentMemberActiveEnrollments();
        if (enrollments.isEmpty()) {
            return List.of();
        }
        Map<Long, CourseEnrollment> enrollmentMap = enrollments.stream()
                .collect(Collectors.toMap(CourseEnrollment::getCourseId, Function.identity()));
        List<Long> courseIds = enrollments.stream()
                .map(CourseEnrollment::getCourseId)
                .distinct()
                .toList();
        Map<Long, Integer> orderMap = java.util.stream.IntStream.range(0, courseIds.size())
                .boxed()
                .collect(Collectors.toMap(courseIds::get, Function.identity()));
        List<Course> courses = lambdaQuery()
                .in(Course::getId, courseIds)
                .eq(Course::getPublishStatus, PUBLISH_STATUS_PUBLISHED)
                .list()
                .stream()
                .sorted(Comparator.comparingInt(course -> orderMap.getOrDefault(course.getId(), Integer.MAX_VALUE)))
                .toList();
        return fillEnrollmentFields(fillCourseVOs(courses), enrollmentMap);
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
        if (portalOnly) {
            applyEnrollmentFields(detailVO, courseEnrollmentService.getCurrentMemberEnrollmentMap(List.of(course.getId())).get(course.getId()));
        }
        return detailVO;
    }

    private Course getCourseOrThrow(Long id) {
        Course course = getById(id);
        if (course == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course not found");
        }
        return course;
    }

    private void fillDefaultCourseFields(Course course) {
        if (course.getDifficulty() == null) {
            course.setDifficulty(1);
        }
        if (course.getPrice() == null) {
            course.setPrice(BigDecimal.ZERO);
        }
        if (course.getPublishStatus() == null) {
            course.setPublishStatus(PUBLISH_STATUS_DRAFT);
        }
    }

    private int nextSort() {
        Course last = getOne(
                Wrappers.<Course>lambdaQuery()
                        .orderByDesc(Course::getSort, Course::getId)
                        .last("LIMIT 1"),
                false
        );
        return last == null || last.getSort() == null ? 1 : last.getSort() + 1;
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

    private void ensureCourseHasNoDependencies(Long courseId) {
        if (hasCourseDependency(courseBannerMapper, CourseBanner::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has banners and cannot be deleted");
        }
        if (hasCourseDependency(courseChapterMapper, CourseChapter::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has chapters and cannot be deleted");
        }
        if (hasCourseDependency(courseSectionMapper, CourseSection::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has sections and cannot be deleted");
        }
        if (hasCourseDependency(courseSectionContentMapper, CourseSectionContent::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has section contents and cannot be deleted");
        }
        if (hasCourseDependency(courseMaterialMapper, CourseMaterial::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has materials and cannot be deleted");
        }
        if (hasCourseDependency(courseEnrollmentMapper, CourseEnrollment::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has enrollments and cannot be deleted");
        }
        if (hasCourseDependency(courseReviewMapper, CourseReview::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has reviews and cannot be deleted");
        }
        if (hasCourseDependency(courseTaskMapper, CourseTask::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has homeworks and cannot be deleted");
        }
        if (hasCourseDependency(courseExamMapper, CourseExam::getCourseId, courseId)) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course has exams and cannot be deleted");
        }
    }

    private <T> boolean hasCourseDependency(BaseMapper<T> mapper, SFunction<T, Long> field, Long courseId) {
        return mapper.selectCount(Wrappers.<T>lambdaQuery().eq(field, courseId)) > 0;
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

    private List<CourseVO> fillEnrollmentFields(List<CourseVO> courses) {
        if (courses.isEmpty()) {
            return courses;
        }
        Map<Long, CourseEnrollment> enrollmentMap = courseEnrollmentService.getCurrentMemberEnrollmentMap(
                courses.stream().map(CourseVO::getId).toList()
        );
        return fillEnrollmentFields(courses, enrollmentMap);
    }

    private List<CourseVO> fillEnrollmentFields(List<CourseVO> courses, Map<Long, CourseEnrollment> enrollmentMap) {
        courses.forEach(course -> applyEnrollmentFields(course, enrollmentMap.get(course.getId())));
        return courses;
    }

    private void applyEnrollmentFields(CourseVO course, CourseEnrollment enrollment) {
        course.setEnrolled(enrollment != null);
        if (enrollment != null) {
            course.setStudyProgress(enrollment.getStudyProgress());
            course.setLastStudySectionId(enrollment.getLastStudySectionId());
        }
    }

    private void applyEnrollmentFields(CourseDetailVO course, CourseEnrollment enrollment) {
        course.setEnrolled(enrollment != null);
        if (enrollment != null) {
            course.setStudyProgress(enrollment.getStudyProgress());
            course.setLastStudySectionId(enrollment.getLastStudySectionId());
        }
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
