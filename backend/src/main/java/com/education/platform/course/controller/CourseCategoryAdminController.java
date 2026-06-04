package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseCategorySaveDTO;
import com.education.platform.course.service.CourseCategoryService;
import com.education.platform.course.vo.CourseCategoryVO;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/course-categories")
@RequiredArgsConstructor
public class CourseCategoryAdminController {

    private final CourseCategoryService courseCategoryService;

    @GetMapping("/tree")
    public Result<List<CourseCategoryVO>> tree() {
        return Result.success(courseCategoryService.getCategoryTree(false));
    }

    @GetMapping("/{id}")
    public Result<CourseCategoryVO> detail(@PathVariable Long id) {
        return Result.success(courseCategoryService.getCategoryDetail(id));
    }

    @PostMapping
    public Result<Void> save(@Valid @RequestBody CourseCategorySaveDTO request) {
        courseCategoryService.createCategory(request);
        return Result.success();
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody CourseCategorySaveDTO request) {
        courseCategoryService.updateCategory(id, request);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseCategoryService.deleteCategory(id);
        return Result.success();
    }
}
