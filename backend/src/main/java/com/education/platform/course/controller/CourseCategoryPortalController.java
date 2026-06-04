package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.service.CourseCategoryService;
import com.education.platform.course.vo.CourseCategoryVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/portal/course-categories")
@RequiredArgsConstructor
public class CourseCategoryPortalController {

    private final CourseCategoryService courseCategoryService;

    @GetMapping("/tree")
    public Result<List<CourseCategoryVO>> tree() {
        return Result.success(courseCategoryService.getCategoryTree(true));
    }
}
