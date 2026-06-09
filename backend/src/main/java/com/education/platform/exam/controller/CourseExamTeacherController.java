package com.education.platform.exam.controller;

import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.exam.dto.CourseExamQueryDTO;
import com.education.platform.exam.dto.CourseExamSaveDTO;
import com.education.platform.exam.service.CourseExamService;
import com.education.platform.exam.vo.CourseExamVO;
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
@RequestMapping("/api/v1/teacher/course-exams")
@RequiredArgsConstructor
public class CourseExamTeacherController {

    private final CourseExamService courseExamService;

    @GetMapping
    public Result<PageResponse<CourseExamVO>> list(@Valid @ModelAttribute CourseExamQueryDTO queryDTO) {
        return Result.success(courseExamService.pageTeacherExams(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<CourseExamVO> detail(@PathVariable Long id) {
        return Result.success(courseExamService.getTeacherExamDetail(id));
    }

    @PostMapping
    public Result<Void> create(@Valid @RequestBody CourseExamSaveDTO request) {
        courseExamService.createTeacherExam(request);
        return Result.success();
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody CourseExamSaveDTO request) {
        courseExamService.updateTeacherExam(id, request);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseExamService.deleteTeacherExam(id);
        return Result.success();
    }
}
