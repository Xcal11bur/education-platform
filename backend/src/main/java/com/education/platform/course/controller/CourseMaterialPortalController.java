package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.course.service.CourseMaterialService;
import com.education.platform.course.vo.CourseMaterialVO;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/portal/courses")
@RequiredArgsConstructor
public class CourseMaterialPortalController {

    private final CourseMaterialService courseMaterialService;

    @GetMapping("/{courseId}/materials")
    public Result<List<CourseMaterialVO>> list(@PathVariable Long courseId) {
        return Result.success(courseMaterialService.listPortalMaterials(courseId));
    }
}
