package com.education.platform.infrastructure.storage;

import com.education.platform.common.result.Result;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/admin/uploads")
@RequiredArgsConstructor
public class UploadController {

    private final OssUploadService ossUploadService;

    @PostMapping("/materials")
    public Result<UploadResult> uploadMaterial(@RequestParam("file") MultipartFile file) {
        return Result.success(ossUploadService.uploadMaterial(file));
    }

    @PostMapping("/course-covers")
    public Result<UploadResult> uploadCourseCover(@RequestParam("file") MultipartFile file) {
        return Result.success(ossUploadService.uploadCourseCover(file));
    }

    @PostMapping("/section-videos")
    public Result<UploadResult> uploadSectionVideo(@RequestParam("file") MultipartFile file) {
        return Result.success(ossUploadService.uploadSectionVideo(file));
    }
}
