package com.education.platform.course.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.education.platform.course.dto.SectionMaterialSaveDTO;
import com.education.platform.course.entity.SectionMaterial;
import com.education.platform.course.vo.SectionMaterialVO;
import java.util.List;

public interface SectionMaterialService extends IService<SectionMaterial> {

    List<SectionMaterialVO> listAdminMaterials(Long sectionId);

    SectionMaterialVO getMaterialDetail(Long id);

    void createMaterial(Long sectionId, SectionMaterialSaveDTO request);

    void updateMaterial(Long id, SectionMaterialSaveDTO request);

    void deleteMaterial(Long id);

    List<SectionMaterialVO> listPortalMaterials(Long sectionId);
}
