package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.dto.SectionMaterialSaveDTO;
import com.education.platform.course.service.SectionMaterialService;
import com.education.platform.course.vo.SectionMaterialVO;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class SectionMaterialAdminController {

    private final SectionMaterialService sectionMaterialService;

    @GetMapping("/sections/{sectionId}/materials")
    public Result<List<SectionMaterialVO>> list(@PathVariable Long sectionId) {
        return Result.success(sectionMaterialService.listAdminMaterials(sectionId));
    }

    @GetMapping("/section-materials/{id}")
    public Result<SectionMaterialVO> detail(@PathVariable Long id) {
        return Result.success(sectionMaterialService.getMaterialDetail(id));
    }

    @PostMapping("/sections/{sectionId}/materials")
    public Result<Void> create(@PathVariable Long sectionId, @Valid @RequestBody SectionMaterialSaveDTO request) {
        sectionMaterialService.createMaterial(sectionId, request);
        return Result.success();
    }

    @PutMapping("/section-materials/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody SectionMaterialSaveDTO request) {
        sectionMaterialService.updateMaterial(id, request);
        return Result.success();
    }

    @DeleteMapping("/section-materials/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        sectionMaterialService.deleteMaterial(id);
        return Result.success();
    }
}
