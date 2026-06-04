package com.education.platform.teacher.controller;

import com.education.platform.common.dto.StatusUpdateDTO;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.teacher.dto.TeacherQueryDTO;
import com.education.platform.teacher.dto.TeacherSaveDTO;
import com.education.platform.teacher.service.TeacherService;
import com.education.platform.teacher.vo.TeacherVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.ModelAttribute;

@RestController
@RequestMapping("/api/v1/admin/teachers")
@RequiredArgsConstructor
public class TeacherAdminController {

    private final TeacherService teacherService;

    @GetMapping
    public Result<PageResponse<TeacherVO>> list(@Valid @ModelAttribute TeacherQueryDTO queryDTO) {
        return Result.success(teacherService.pageTeachers(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<TeacherVO> detail(@PathVariable Long id) {
        return Result.success(teacherService.getTeacherDetail(id));
    }

    @PostMapping
    public Result<Void> save(@Valid @RequestBody TeacherSaveDTO request) {
        teacherService.createTeacher(request);
        return Result.success();
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody TeacherSaveDTO request) {
        teacherService.updateTeacher(id, request);
        return Result.success();
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @Valid @RequestBody StatusUpdateDTO request) {
        teacherService.updateTeacherStatus(id, request.getStatus());
        return Result.success();
    }
}
