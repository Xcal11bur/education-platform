package com.education.platform.course.controller;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.model.OSSObject;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.model.PageResponse;
import com.education.platform.common.result.Result;
import com.education.platform.common.result.ResultCode;
import com.education.platform.course.dto.CourseReviewQueryDTO;
import com.education.platform.course.service.CourseReviewService;
import com.education.platform.course.vo.CourseReviewPortalVO;
import com.education.platform.course.vo.CourseReviewSummaryVO;
import com.education.platform.infrastructure.storage.OssProperties;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URLConnection;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StreamUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/portal/courses")
@RequiredArgsConstructor
public class CourseReviewPortalController {

    private final CourseReviewService courseReviewService;
    private final OssProperties ossProperties;

    @GetMapping("/{courseId}/reviews")
    public Result<PageResponse<CourseReviewPortalVO>> list(@PathVariable Long courseId,
                                                           @Valid @ModelAttribute CourseReviewQueryDTO queryDTO) {
        queryDTO.setCourseId(courseId);
        return Result.success(courseReviewService.pagePortalReviews(queryDTO));
    }

    @GetMapping("/{courseId}/review-summary")
    public Result<CourseReviewSummaryVO> summary(@PathVariable Long courseId) {
        return Result.success(courseReviewService.getPortalReviewSummary(courseId));
    }

    @GetMapping("/reviews/{reviewId}/avatar")
    public ResponseEntity<byte[]> avatar(@PathVariable Long reviewId) {
        String avatarUrl = courseReviewService.getPortalReviewAvatarUrl(reviewId);
        try {
            AvatarPayload payload = loadAvatarPayload(avatarUrl);
            return ResponseEntity.ok()
                    .cacheControl(CacheControl.noCache())
                    .header(HttpHeaders.CONTENT_TYPE, payload.contentType())
                    .body(payload.body());
        } catch (IllegalArgumentException | IOException ex) {
            throw new BusinessException(ResultCode.INTERNAL_ERROR.getCode(), "failed to load review avatar");
        }
    }

    private AvatarPayload loadAvatarPayload(String avatarUrl) throws IOException {
        String objectKey = resolveOssObjectKey(avatarUrl);
        if (objectKey != null) {
            return loadAvatarFromOss(objectKey);
        }

        URLConnection connection = URI.create(avatarUrl).toURL().openConnection();
        connection.setConnectTimeout(5000);
        connection.setReadTimeout(30000);
        try (InputStream inputStream = connection.getInputStream()) {
            byte[] body = StreamUtils.copyToByteArray(inputStream);
            String contentType = normalizeImageContentType(connection.getContentType());
            return new AvatarPayload(body, contentType);
        }
    }

    private AvatarPayload loadAvatarFromOss(String objectKey) throws IOException {
        OSS ossClient = new OSSClientBuilder().build(
                normalizeEndpoint(ossProperties.getEndpoint()),
                ossProperties.getAccessKeyId(),
                ossProperties.getAccessKeySecret()
        );
        try (OSSObject object = ossClient.getObject(ossProperties.getBucketName(), objectKey);
             InputStream inputStream = object.getObjectContent()) {
            byte[] body = StreamUtils.copyToByteArray(inputStream);
            String contentType = normalizeImageContentType(object.getObjectMetadata().getContentType());
            return new AvatarPayload(body, contentType);
        } finally {
            ossClient.shutdown();
        }
    }

    private String resolveOssObjectKey(String avatarUrl) {
        if (!StringUtils.hasText(avatarUrl)) {
            return null;
        }
        String normalizedUrl = avatarUrl.trim();
        if (!normalizedUrl.startsWith("http://") && !normalizedUrl.startsWith("https://")) {
            return normalizedUrl.replaceFirst("^/+", "");
        }

        if (StringUtils.hasText(ossProperties.getPublicBaseUrl())) {
            String prefix = ossProperties.getPublicBaseUrl().replaceAll("/$", "") + "/";
            if (normalizedUrl.startsWith(prefix)) {
                return normalizedUrl.substring(prefix.length()).replaceFirst("^/+", "");
            }
        }

        String bucketPrefix = "https://" + ossProperties.getBucketName() + "." + ossProperties.getEndpoint().replaceFirst("^https?://", "") + "/";
        if (normalizedUrl.startsWith(bucketPrefix)) {
            return normalizedUrl.substring(bucketPrefix.length()).replaceFirst("^/+", "");
        }
        return null;
    }

    private String normalizeEndpoint(String endpoint) {
        if (endpoint.startsWith("http://") || endpoint.startsWith("https://")) {
            return endpoint;
        }
        return "https://" + endpoint;
    }

    private String normalizeImageContentType(String contentType) {
        if (!StringUtils.hasText(contentType)) {
            return MediaType.IMAGE_JPEG_VALUE;
        }
        try {
            MediaType.parseMediaType(contentType);
            return contentType;
        } catch (IllegalArgumentException ex) {
            return MediaType.IMAGE_JPEG_VALUE;
        }
    }

    private record AvatarPayload(byte[] body, String contentType) {
    }
}
