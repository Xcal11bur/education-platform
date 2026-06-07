package com.education.platform.course.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseMaterialQueryDTO;
import com.education.platform.course.dto.CourseMaterialSaveDTO;
import com.education.platform.course.entity.Course;
import com.education.platform.course.entity.CourseMaterial;
import com.education.platform.course.mapper.CourseMapper;
import com.education.platform.course.mapper.CourseMaterialMapper;
import com.education.platform.course.service.CourseEnrollmentService;
import com.education.platform.course.service.CourseMaterialService;
import com.education.platform.course.vo.CourseMaterialVO;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class CourseMaterialServiceImpl extends ServiceImpl<CourseMaterialMapper, CourseMaterial>
        implements CourseMaterialService {

    private final CourseMapper courseMapper;
    private final CourseMaterialMapper courseMaterialMapper;
    private final CourseEnrollmentService courseEnrollmentService;

    public CourseMaterialServiceImpl(
            CourseMapper courseMapper,
            CourseMaterialMapper courseMaterialMapper,
            CourseEnrollmentService courseEnrollmentService) {
        this.courseMapper = courseMapper;
        this.courseMaterialMapper = courseMaterialMapper;
        this.courseEnrollmentService = courseEnrollmentService;
    }

    @Override
    public PageResponse<CourseMaterialVO> pageAdminMaterials(CourseMaterialQueryDTO queryDTO) {
        IPage<CourseMaterial> page = lambdaQuery()
                .eq(queryDTO.getCourseId() != null, CourseMaterial::getCourseId, queryDTO.getCourseId())
                .like(StringUtils.hasText(queryDTO.getMaterialName()), CourseMaterial::getMaterialName, queryDTO.getMaterialName())
                .eq(queryDTO.getMaterialType() != null, CourseMaterial::getMaterialType, queryDTO.getMaterialType())
                .orderByAsc(CourseMaterial::getSort, CourseMaterial::getId)
                .page(new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize()));
        List<CourseMaterialVO> list = fillMaterialVOs(page.getRecords());
        return PageResponse.<CourseMaterialVO>builder()
                .pageNum(page.getCurrent())
                .pageSize(page.getSize())
                .total(page.getTotal())
                .list(list)
                .build();
    }

    @Override
    public CourseMaterialVO getMaterialDetail(Long id) {
        CourseMaterial material = getMaterialOrThrow(id);
        return fillMaterialVOs(List.of(material)).stream().findFirst()
                .orElseThrow(() -> new BusinessException(ResultCode.NOT_FOUND.getCode(), "course material not found"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createMaterial(CourseMaterialSaveDTO request) {
        getCourseOrThrow(request.getCourseId(), false);
        CourseMaterial material = new CourseMaterial();
        BeanUtils.copyProperties(request, material);
        if (material.getFileSize() == null) {
            material.setFileSize(0L);
        }
        if (material.getDownloadLimit() == null) {
            material.setDownloadLimit(1);
        }
        material.setSort(nextSort(request.getCourseId()));
        save(material);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateMaterial(Long id, CourseMaterialSaveDTO request) {
        CourseMaterial material = getMaterialOrThrow(id);
        getCourseOrThrow(request.getCourseId(), false);
        BeanUtils.copyProperties(request, material, "id", "sort");
        if (material.getFileSize() == null) {
            material.setFileSize(0L);
        }
        if (material.getDownloadLimit() == null) {
            material.setDownloadLimit(1);
        }
        updateById(material);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteMaterial(Long id) {
        getMaterialOrThrow(id);
        int affectedRows = courseMaterialMapper.deleteMaterialPhysically(id);
        if (affectedRows != 1) {
            throw new BusinessException(ResultCode.INTERNAL_ERROR.getCode(), "failed to delete course material");
        }
    }

    @Override
    public List<CourseMaterialVO> listPortalMaterials(Long courseId) {
        getCourseOrThrow(courseId, true);
        boolean enrolled = courseEnrollmentService.isCurrentMemberEnrolled(courseId);
        List<CourseMaterial> materials = lambdaQuery()
                .eq(CourseMaterial::getCourseId, courseId)
                .orderByAsc(CourseMaterial::getSort, CourseMaterial::getId)
                .list()
                .stream()
                .filter(material -> Objects.equals(material.getDownloadLimit(), 0) || enrolled)
                .toList();
        return fillMaterialVOs(materials);
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

    private CourseMaterial getMaterialOrThrow(Long id) {
        CourseMaterial material = getById(id);
        if (material == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "course material not found");
        }
        return material;
    }

    private int nextSort(Long courseId) {
        CourseMaterial last = getOne(
                Wrappers.<CourseMaterial>lambdaQuery()
                        .eq(CourseMaterial::getCourseId, courseId)
                        .orderByDesc(CourseMaterial::getSort, CourseMaterial::getId)
                        .last("LIMIT 1"),
                false
        );
        return last == null || last.getSort() == null ? 1 : last.getSort() + 1;
    }

    private List<CourseMaterialVO> fillMaterialVOs(List<CourseMaterial> materials) {
        if (materials.isEmpty()) {
            return List.of();
        }
        Map<Long, Course> courseMap = listCoursesByIds(materials.stream()
                .map(CourseMaterial::getCourseId)
                .filter(Objects::nonNull)
                .toList());
        return materials.stream().map(material -> {
            CourseMaterialVO vo = new CourseMaterialVO();
            BeanUtils.copyProperties(material, vo);
            Course course = courseMap.get(material.getCourseId());
            if (course != null) {
                vo.setCourseTitle(course.getTitle());
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
}
