package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.service.SectionMaterialService;
import com.education.platform.course.vo.SectionMaterialVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/portal/sections")
@RequiredArgsConstructor
public class SectionMaterialPortalController {

    private final SectionMaterialService sectionMaterialService;

    @GetMapping("/{sectionId}/materials")
    public Result<List<SectionMaterialVO>> list(@PathVariable Long sectionId) {
        return Result.success(sectionMaterialService.listPortalMaterials(sectionId));
    }
}
