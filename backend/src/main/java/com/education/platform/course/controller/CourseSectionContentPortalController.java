package com.education.platform.course.controller;

import com.education.platform.common.result.Result;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.entity.CourseSectionContent;
import com.education.platform.course.service.CourseSectionContentService;
import com.education.platform.course.vo.CourseSectionContentVO;
import com.education.platform.infrastructure.storage.OssProperties;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URLConnection;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/portal/sections")
@RequiredArgsConstructor
public class CourseSectionContentPortalController {

    private final CourseSectionContentService courseSectionContentService;
    private final OssProperties ossProperties;

    @GetMapping("/{sectionId}/contents")
    public Result<List<CourseSectionContentVO>> list(@PathVariable Long sectionId) {
        return Result.success(courseSectionContentService.listPortalContents(sectionId));
    }

    @GetMapping("/contents/{id}/preview")
    public ResponseEntity<byte[]> preview(@PathVariable Long id) {
        CourseSectionContent content = courseSectionContentService.getPortalPreviewContent(id);
        if (!"PDF".equalsIgnoreCase(content.getContentType()) || content.getFileUrl() == null || content.getFileUrl().isBlank()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "content is not previewable");
        }
        try {
            URLConnection connection = URI.create(resolvePreviewUrl(content)).toURL().openConnection();
            connection.setConnectTimeout(5000);
            connection.setReadTimeout(30000);
            try (InputStream inputStream = connection.getInputStream()) {
                byte[] body = StreamUtils.copyToByteArray(inputStream);
                String fileName = content.getFileName() == null || content.getFileName().isBlank()
                        ? content.getTitle() + ".pdf"
                        : content.getFileName();
                return ResponseEntity.ok()
                        .contentType(MediaType.APPLICATION_PDF)
                        .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.inline().filename(fileName).build().toString())
                        .body(body);
            }
        } catch (IllegalArgumentException | IOException ex) {
            throw new BusinessException(ResultCode.INTERNAL_ERROR.getCode(), "failed to load pdf preview");
        }
    }

    private String resolvePreviewUrl(CourseSectionContent content) {
        String fileUrl = content.getFileUrl().trim();
        if (fileUrl.startsWith("http://") || fileUrl.startsWith("https://")) {
            return fileUrl;
        }

        String objectKey = content.getObjectKey() == null || content.getObjectKey().isBlank()
                ? fileUrl.replaceFirst("^/+", "")
                : content.getObjectKey().replaceFirst("^/+", "");
        if (ossProperties.getPublicBaseUrl() != null && !ossProperties.getPublicBaseUrl().isBlank()) {
            return ossProperties.getPublicBaseUrl().replaceAll("/$", "") + "/" + objectKey;
        }
        return "https://" + ossProperties.getBucketName() + "." + ossProperties.getEndpoint() + "/" + objectKey;
    }
}
