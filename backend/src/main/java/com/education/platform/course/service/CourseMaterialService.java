package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.common.model.PageResponse;
import com.education.platform.course.dto.CourseMaterialQueryDTO;
import com.education.platform.course.dto.CourseMaterialSaveDTO;
import com.education.platform.course.entity.CourseMaterial;
import com.education.platform.course.vo.CourseMaterialVO;
import java.util.List;

public interface CourseMaterialService extends IService<CourseMaterial> {

    PageResponse<CourseMaterialVO> pageAdminMaterials(CourseMaterialQueryDTO queryDTO);

    PageResponse<CourseMaterialVO> pageTeacherMaterials(CourseMaterialQueryDTO queryDTO);

    CourseMaterialVO getMaterialDetail(Long id);

    CourseMaterialVO getTeacherMaterialDetail(Long id);

    void createMaterial(CourseMaterialSaveDTO request);

    void createTeacherMaterial(CourseMaterialSaveDTO request);

    void updateMaterial(Long id, CourseMaterialSaveDTO request);

    void updateTeacherMaterial(Long id, CourseMaterialSaveDTO request);

    void deleteMaterial(Long id);

    void deleteTeacherMaterial(Long id);

    List<CourseMaterialVO> listPortalMaterials(Long courseId);
}
