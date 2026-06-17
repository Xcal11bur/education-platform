package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.enums.StatusEnum;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseBannerQueryDTO;
import com.education.platform.course.dto.CourseBannerSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseBanner;
import com.education.platform.course.entity.CourseCategory;
import com.education.platform.course.mapper.CourseBannerMapper;
import com.education.platform.course.mapper.CourseCategoryMapper;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.service.CourseBannerService;
import com.education.platform.course.vo.CourseBannerPortalVO;
import com.education.platform.course.vo.CourseBannerVO;
import com.education.platform.teacher.entity.Teacher;
import com.education.platform.teacher.mapper.TeacherMapper;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class CourseBannerServiceImpl extends ServiceImpl<CourseBannerMapper, CourseBanner> implements CourseBannerService {

    private static final int ADMIN_BANNER_LIMIT = 6;
    private static final int PUBLISH_STATUS_PUBLISHED = 1;
    private static final int PORTAL_BANNER_MIN_SIZE = 3;
    private static final int PORTAL_BANNER_MAX_SIZE = 4;
    private static final int PORTAL_BANNER_CANDIDATE_SIZE = 8;

    private final CourseMapper courseMapper;
    private final TeacherMapper teacherMapper;
    private final CourseCategoryMapper courseCategoryMapper;

    public CourseBannerServiceImpl(CourseMapper courseMapper,
                                   TeacherMapper teacherMapper,
                                   CourseCategoryMapper courseCategoryMapper) {
        this.courseMapper = courseMapper;
        this.teacherMapper = teacherMapper;
        this.courseCategoryMapper = courseCategoryMapper;
    }

    @Override
    public PageResponse<CourseBannerVO> pageBanners(CourseBannerQueryDTO queryDTO) {
        IPage<CourseBanner> page = lambdaQuery()
                .eq(queryDTO.getCourseId() != null, CourseBanner::getCourseId, queryDTO.getCourseId())
                .eq(queryDTO.getStatus() != null, CourseBanner::getStatus, queryDTO.getStatus())
                .orderByDesc(CourseBanner::getSort, CourseBanner::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<CourseBannerVO> list = fillBannerVOs(page.getRecords());
        return PageResponse.<CourseBannerVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public CourseBannerVO getBannerDetail(Long id) {
        List<CourseBannerVO> list = fillBannerVOs(List.of(getBannerOrThrow(id)));
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createBanner(CourseBannerSaveDTO request) {
        enforceBannerLimit();
        Course course = validateCourseForBanner(request.getCourseId());
        boolean exists = lambdaQuery().eq(CourseBanner::getCourseId, course.getId()).exists();
        if (exists) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course banner already exists");
        }
        CourseBanner banner = new CourseBanner();
        applyBannerRequest(banner, request);
        save(banner);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateBanner(Long id, CourseBannerSaveDTO request) {
        CourseBanner banner = getBannerOrThrow(id);
        validateCourseForBanner(request.getCourseId());
        boolean exists = lambdaQuery()
                .eq(CourseBanner::getCourseId, request.getCourseId())
                .ne(CourseBanner::getId, id)
                .exists();
        if (exists) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "course banner already exists");
        }
        applyBannerRequest(banner, request);
        updateById(banner);
    }

    private void enforceBannerLimit() {
        long count = count();
        if (count >= ADMIN_BANNER_LIMIT) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "course banners are limited to 6 items");
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateBannerStatus(Long id, Integer status) {
        CourseBanner banner = getBannerOrThrow(id);
        banner.setStatus(status);
        updateById(banner);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteBanner(Long id) {
        removeById(id);
    }

    @Override
    public List<CourseBannerPortalVO> listPortalBanners() {
        List<CourseBanner> configuredBanners = lambdaQuery()
                .eq(CourseBanner::getStatus, StatusEnum.ENABLED.getCode())
                .orderByDesc(CourseBanner::getSort, CourseBanner::getId)
                .list();

        List<CourseBannerPortalVO> configuredList = fillPortalBannerVOs(configuredBanners);
        if (!configuredList.isEmpty()) {
            return configuredList;
        }

        List<Course> hotCourses = courseMapper.selectList(
                Wrappers.<Course>lambdaQuery()
                        .eq(Course::getPublishStatus, PUBLISH_STATUS_PUBLISHED)
                        .isNotNull(Course::getCoverUrl)
                        .orderByDesc(Course::getStudyCount)
                        .orderByAsc(Course::getId)
                        .last("LIMIT " + PORTAL_BANNER_CANDIDATE_SIZE)
        );

        List<CourseBannerPortalVO> fallback = fillPortalBannerVOsFromCourses(hotCourses);
        fallback.removeIf(item -> !StringUtils.hasText(item.getCoverUrl()));
        if (fallback.size() <= PORTAL_BANNER_MIN_SIZE) {
            return fallback;
        }

        Collections.shuffle(fallback);
        int bannerSize = Math.min(
                fallback.size(),
                ThreadLocalRandom.current().nextInt(PORTAL_BANNER_MIN_SIZE, PORTAL_BANNER_MAX_SIZE + 1)
        );
        return new ArrayList<>(fallback.subList(0, bannerSize));
    }

    private void applyBannerRequest(CourseBanner banner, CourseBannerSaveDTO request) {
        banner.setCourseId(request.getCourseId());
        banner.setTitle(request.getTitle());
        banner.setSubTitle(request.getSubTitle());
        if (banner.getId() == null) {
            banner.setSort(nextSort());
        }
        banner.setStatus(request.getStatus() == null ? StatusEnum.ENABLED.getCode() : request.getStatus());
    }

    private int nextSort() {
        CourseBanner last = getOne(
                Wrappers.<CourseBanner>lambdaQuery()
                        .orderByDesc(CourseBanner::getSort, CourseBanner::getId)
                        .last("LIMIT 1"),
                false
        );
        return last == null || last.getSort() == null ? 1 : last.getSort() + 1;
    }

    private Course validateCourseForBanner(Long courseId) {
        Course course = courseMapper.selectById(courseId);
        if (course == null || !Objects.equals(course.getPublishStatus(), PUBLISH_STATUS_PUBLISHED)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "course is invalid or unpublished");
        }
        if (!StringUtils.hasText(course.getCoverUrl())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "course cover is required");
        }
        return course;
    }

    private CourseBanner getBannerOrThrow(Long id) {
        CourseBanner banner = getById(id);
        if (banner == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course banner not found");
        }
        return banner;
    }

    private List<CourseBannerVO> fillBannerVOs(List<CourseBanner> banners) {
        if (banners.isEmpty()) {
            return List.of();
        }

        Map<Long, Course> courseMap = listCoursesByIds(
                banners.stream().map(CourseBanner::getCourseId).collect(Collectors.toSet())
        );
        Map<Long, Teacher> teacherMap = listTeachersByIds(
                courseMap.values().stream().map(Course::getTeacherId).filter(Objects::nonNull).collect(Collectors.toSet())
        );

        return banners.stream()
                .map(banner -> {
                    CourseBannerVO vo = new CourseBannerVO();
                    BeanUtils.copyProperties(banner, vo);
                    Course course = courseMap.get(banner.getCourseId());
                    if (course != null) {
                        vo.setCourseTitle(course.getTitle());
                        vo.setCourseSubTitle(course.getSubTitle());
                        vo.setCoverUrl(course.getCoverUrl());
                        vo.setStudyCount(course.getStudyCount());
                        Teacher teacher = teacherMap.get(course.getTeacherId());
                        if (teacher != null) {
                            vo.setTeacherName(teacher.getName());
                        }
                    }
                    return vo;
                })
                .toList();
    }

    private List<CourseBannerPortalVO> fillPortalBannerVOs(List<CourseBanner> banners) {
        if (banners.isEmpty()) {
            return List.of();
        }

        Map<Long, Course> courseMap = listCoursesByIds(
                banners.stream().map(CourseBanner::getCourseId).collect(Collectors.toSet())
        );
        Map<Long, Teacher> teacherMap = listTeachersByIds(
                courseMap.values().stream().map(Course::getTeacherId).filter(Objects::nonNull).collect(Collectors.toSet())
        );
        Map<Long, CourseCategory> categoryMap = listCategoriesByIds(
                courseMap.values().stream()
                        .flatMap(course -> java.util.stream.Stream.of(course.getCategoryLevel1Id(), course.getCategoryLevel2Id()))
                        .filter(Objects::nonNull)
                        .collect(Collectors.toSet())
        );

        return banners.stream()
                .map(banner -> {
                    Course course = courseMap.get(banner.getCourseId());
                    if (course == null
                            || !Objects.equals(course.getPublishStatus(), PUBLISH_STATUS_PUBLISHED)
                            || !StringUtils.hasText(course.getCoverUrl())) {
                        return null;
                    }
                    CourseBannerPortalVO vo = new CourseBannerPortalVO();
                    vo.setId(banner.getId());
                    vo.setCourseId(course.getId());
                    vo.setTitle(StringUtils.hasText(banner.getTitle()) ? banner.getTitle() : course.getTitle());
                    vo.setSubTitle(StringUtils.hasText(banner.getSubTitle()) ? banner.getSubTitle() : course.getSubTitle());
                    vo.setCoverUrl(course.getCoverUrl());
                    vo.setStudyCount(course.getStudyCount());
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
                .filter(Objects::nonNull)
                .toList();
    }

    private List<CourseBannerPortalVO> fillPortalBannerVOsFromCourses(List<Course> courses) {
        if (courses.isEmpty()) {
            return List.of();
        }
        Map<Long, Teacher> teacherMap = listTeachersByIds(
                courses.stream().map(Course::getTeacherId).filter(Objects::nonNull).collect(Collectors.toSet())
        );
        Map<Long, CourseCategory> categoryMap = listCategoriesByIds(
                courses.stream()
                        .flatMap(course -> java.util.stream.Stream.of(course.getCategoryLevel1Id(), course.getCategoryLevel2Id()))
                        .filter(Objects::nonNull)
                        .collect(Collectors.toSet())
        );
        return courses.stream().map(course -> {
            CourseBannerPortalVO vo = new CourseBannerPortalVO();
            vo.setId(course.getId());
            vo.setCourseId(course.getId());
            vo.setTitle(course.getTitle());
            vo.setSubTitle(course.getSubTitle());
            vo.setCoverUrl(course.getCoverUrl());
            vo.setStudyCount(course.getStudyCount());
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
        }).toList();
    }

    private Map<Long, Course> listCoursesByIds(Collection<Long> ids) {
        if (ids.isEmpty()) {
            return Map.of();
        }
        return courseMapper.selectList(
                        Wrappers.<Course>lambdaQuery().in(Course::getId, ids)
                ).stream()
                .collect(Collectors.toMap(Course::getId, Function.identity()));
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
}
