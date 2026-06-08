package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseSectionContentSaveDTO;
import com.education.platform.course.service.CourseSectionContentService;
import com.education.platform.course.vo.CourseSectionContentVO;
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
@RequestMapping("/api/v1/teacher")
@RequiredArgsConstructor
public class CourseSectionContentTeacherController {

    private final CourseSectionContentService courseSectionContentService;

    @GetMapping("/sections/{sectionId}/contents")
    public Result<List<CourseSectionContentVO>> list(@PathVariable Long sectionId) {
        return Result.success(courseSectionContentService.listTeacherContents(sectionId));
    }

    @GetMapping("/section-contents/{id}")
    public Result<CourseSectionContentVO> detail(@PathVariable Long id) {
        return Result.success(courseSectionContentService.getTeacherContentDetail(id));
    }

    @PostMapping("/sections/{sectionId}/contents")
    public Result<Void> create(@PathVariable Long sectionId, @Valid @RequestBody CourseSectionContentSaveDTO request) {
        courseSectionContentService.createTeacherContent(sectionId, request);
        return Result.success();
    }

    @PutMapping("/section-contents/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody CourseSectionContentSaveDTO request) {
        courseSectionContentService.updateTeacherContent(id, request);
        return Result.success();
    }

    @DeleteMapping("/section-contents/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseSectionContentService.deleteTeacherContent(id);
        return Result.success();
    }
}
