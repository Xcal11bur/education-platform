package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.education.platform.common.enums.StatusEnum;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseCategorySaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseCategory;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseCategoryMapper;
import com.education.platform.course.service.CourseCategoryService;
import com.education.platform.course.vo.CourseCategoryVO;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class CourseCategoryServiceImpl extends ServiceImpl<CourseCategoryMapper, CourseCategory>
        implements CourseCategoryService {

    private final CourseMapper courseMapper;

    public CourseCategoryServiceImpl(CourseMapper courseMapper) {
        this.courseMapper = courseMapper;
    }

    @Override
    public List<CourseCategoryVO> getCategoryTree(Boolean onlyEnabled) {
        List<CourseCategory> categories = lambdaQuery()
                .eq(Boolean.TRUE.equals(onlyEnabled), CourseCategory::getStatus, StatusEnum.ENABLED.getCode())
                .orderByAsc(CourseCategory::getSort, CourseCategory::getId)
                .list();

        Map<Long, List<CourseCategory>> childrenMap = categories.stream()
                .collect(Collectors.groupingBy(CourseCategory::getParentId));

        return categories.stream()
                .filter(item -> item.getParentId() == 0)
                .sorted(Comparator.comparing(CourseCategory::getSort).thenComparing(CourseCategory::getId))
                .map(item -> buildTree(item, childrenMap))
                .toList();
    }

    @Override
    public CourseCategoryVO getCategoryDetail(Long id) {
        CourseCategory category = getCategoryOrThrow(id);
        return toVO(category);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createCategory(CourseCategorySaveDTO request) {
        validateCategoryRequest(request, null);
        CourseCategory category = new CourseCategory();
        BeanUtils.copyProperties(request, category);
        category.setSort(nextSort(request.getParentId()));
        if (category.getStatus() == null) {
            category.setStatus(StatusEnum.ENABLED.getCode());
        }
        save(category);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCategory(Long id, CourseCategorySaveDTO request) {
        CourseCategory category = getCategoryOrThrow(id);
        validateCategoryRequest(request, id);
        category.setParentId(request.getParentId());
        category.setName(request.getName());
        category.setLevel(request.getLevel());
        category.setStatus(request.getStatus() == null ? category.getStatus() : request.getStatus());
        updateById(category);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteCategory(Long id) {
        CourseCategory category = getCategoryOrThrow(id);

        boolean hasChildren = lambdaQuery()
                .eq(CourseCategory::getParentId, id)
                .exists();
        if (hasChildren) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "category has child categories and cannot be deleted");
        }

        boolean referencedByCourse = lambdaQueryCourseExists(category);
        if (referencedByCourse) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "category is referenced by courses and cannot be deleted");
        }

        removeById(id);
    }

    private boolean lambdaQueryCourseExists(CourseCategory category) {
        return switch (category.getLevel()) {
            case 1 -> courseMapper.selectCount(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Course>()
                            .eq(Course::getCategoryLevel1Id, category.getId())
            ) > 0;
            case 2 -> courseMapper.selectCount(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Course>()
                            .eq(Course::getCategoryLevel2Id, category.getId())
            ) > 0;
            default -> false;
        };
    }

    private void validateCategoryRequest(CourseCategorySaveDTO request, Long excludeId) {
        if (request.getLevel() == null || (request.getLevel() != 1 && request.getLevel() != 2)) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "level must be 1 or 2");
        }

        if (request.getLevel() == 1 && request.getParentId() != 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "level 1 category parentId must be 0");
        }

        if (request.getLevel() == 2) {
            if (request.getParentId() == null || request.getParentId() <= 0) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "level 2 category must have a valid parentId");
            }
            CourseCategory parent = getCategoryOrThrow(request.getParentId());
            if (!Integer.valueOf(1).equals(parent.getLevel())) {
                throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "level 2 category parent must be a level 1 category");
            }
        }

        boolean nameExists = lambdaQuery()
                .eq(CourseCategory::getParentId, request.getParentId())
                .eq(CourseCategory::getName, request.getName())
                .ne(excludeId != null, CourseCategory::getId, excludeId)
                .exists();
        if (nameExists) {
            throw new BusinessException(ResultCode.CONFLICT.getCode(), "category name already exists under the same parent");
        }
    }

    private CourseCategory getCategoryOrThrow(Long id) {
        CourseCategory category = getById(id);
        if (category == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course category not found");
        }
        return category;
    }

    private int nextSort(Long parentId) {
        CourseCategory last = getOne(
                Wrappers.<CourseCategory>lambdaQuery()
                        .eq(CourseCategory::getParentId, parentId)
                        .orderByDesc(CourseCategory::getSort, CourseCategory::getId)
                        .last("LIMIT 1"),
                false
        );
        return last == null || last.getSort() == null ? 1 : last.getSort() + 1;
    }

    private CourseCategoryVO buildTree(CourseCategory category, Map<Long, List<CourseCategory>> childrenMap) {
        CourseCategoryVO vo = toVO(category);
        List<CourseCategoryVO> children = childrenMap.getOrDefault(category.getId(), List.of()).stream()
                .sorted(Comparator.comparing(CourseCategory::getSort).thenComparing(CourseCategory::getId))
                .map(item -> buildTree(item, childrenMap))
                .toList();
        vo.setChildren(children);
        return vo;
    }

    private CourseCategoryVO toVO(CourseCategory category) {
        CourseCategoryVO vo = new CourseCategoryVO();
        BeanUtils.copyProperties(category, vo);
        return vo;
    }
}
