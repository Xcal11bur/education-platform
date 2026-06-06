package com.education.platform.course.controller;

import com.education.platform.common.dto.StatusUpdateDTO;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.course.dto.CourseBannerQueryDTO;
import com.education.platform.course.dto.CourseBannerSaveDTO;
import com.education.platform.course.service.CourseBannerService;
import com.education.platform.course.vo.CourseBannerVO;
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
@RequestMapping("/api/v1/admin/course-banners")
@RequiredArgsConstructor
public class CourseBannerAdminController {

    private final CourseBannerService courseBannerService;

    @GetMapping
    public Result<PageResponse<CourseBannerVO>> list(@Valid @ModelAttribute CourseBannerQueryDTO queryDTO) {
        return Result.success(courseBannerService.pageBanners(queryDTO));
    }

    @GetMapping("/{id}")
    public Result<CourseBannerVO> detail(@PathVariable Long id) {
        return Result.success(courseBannerService.getBannerDetail(id));
    }

    @PostMapping
    public Result<Void> create(@Valid @RequestBody CourseBannerSaveDTO request) {
        courseBannerService.createBanner(request);
        return Result.success();
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody CourseBannerSaveDTO request) {
        courseBannerService.updateBanner(id, request);
        return Result.success();
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @Valid @RequestBody StatusUpdateDTO request) {
        courseBannerService.updateBannerStatus(id, request.getStatus());
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseBannerService.deleteBanner(id);
        return Result.success();
    }
}
