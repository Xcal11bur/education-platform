package com.education.platform.course.controller;

import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseMaterialQueryDTO;
import com.education.platform.course.dto.CourseMaterialSaveDTO;
import com.education.platform.course.service.CourseMaterialService;
import com.education.platform.course.vo.CourseMaterialVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/teacher/course-materials")
@RequiredArgsConstructor
public class CourseMaterialTeacherController {

    private final CourseMaterialService courseMaterialService;

    @GetMapping
    public Result<PageResponse<CourseMaterialVO>> list(@Valid @ModelAttribute CourseMaterialQueryDTO queryDTO) {
        return Result.success(courseMaterialService.pageTeacherMaterials(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<CourseMaterialVO> detail(@PathVariable Long id) {
        return Result.success(courseMaterialService.getTeacherMaterialDetail(id));
    }

    @PostMapping
    public Result<Void> create(@Valid @RequestBody CourseMaterialSaveDTO request) {
        courseMaterialService.createTeacherMaterial(request);
        return Result.success();
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody CourseMaterialSaveDTO request) {
        courseMaterialService.updateTeacherMaterial(id, request);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseMaterialService.deleteTeacherMaterial(id);
        return Result.success();
    }
}
