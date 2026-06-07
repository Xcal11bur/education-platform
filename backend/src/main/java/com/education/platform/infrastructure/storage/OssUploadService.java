package com.education.platform.infrastructure.storage;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.model.ObjectMetadata;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDate;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
public class OssUploadService {

    private static final List<String> IMAGE_CONTENT_TYPES = List.of(
            "image/jpeg",
            "image/png",
            "image/gif",
            "image/webp",
            "image/bmp",
            "image/svg+xml"
    );
    private static final List<String> VIDEO_EXTENSIONS = List.of(
            ".mp4",
            ".mov",
            ".m4v",
            ".webm",
            ".avi",
            ".mkv"
    );
    private static final List<String> PPT_EXTENSIONS = List.of(
            ".ppt",
            ".pptx"
    );
    private static final long SECTION_VIDEO_MAX_SIZE = 500L * 1024 * 1024;

    private final OssProperties ossProperties;

    public OssUploadService(OssProperties ossProperties) {
        this.ossProperties = ossProperties;
    }

    public UploadResult uploadMaterial(MultipartFile file) {
        validateOssConfig();
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "upload file must not be empty");
        }
        return upload(file, "");
    }

    public UploadResult uploadCourseCover(MultipartFile file) {
        validateOssConfig();
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "upload file must not be empty");
        }
        validateImageFile(file);
        return upload(file, "course-covers");
    }

    public UploadResult uploadSectionVideo(MultipartFile file) {
        validateOssConfig();
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "upload file must not be empty");
        }
        validateSectionVideoFile(file);
        return upload(file, "section-videos");
    }

    public UploadResult uploadSectionContent(MultipartFile file, String contentType) {
        validateOssConfig();
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "upload file must not be empty");
        }
        String normalizedType = StringUtils.hasText(contentType) ? contentType.trim().toUpperCase() : "FILE";
        return switch (normalizedType) {
            case "VIDEO" -> {
                validateSectionVideoFile(file);
                yield upload(file, "section-contents/videos", false);
            }
            case "PDF" -> {
                validatePdfFile(file);
                yield upload(file, "section-contents/pdf", true);
            }
            case "IMAGE" -> {
                validateImageFile(file);
                yield upload(file, "section-contents/images", true);
            }
            case "PPT" -> {
                validatePptFile(file);
                yield upload(file, "section-contents/ppt", false);
            }
            case "FILE" -> upload(file, "section-contents/files", false);
            default -> throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "invalid section content type");
        };
    }

    private void validateOssConfig() {
        if (!StringUtils.hasText(ossProperties.getEndpoint())
                || !StringUtils.hasText(ossProperties.getBucketName())
                || !StringUtils.hasText(ossProperties.getAccessKeyId())
                || !StringUtils.hasText(ossProperties.getAccessKeySecret())) {
            throw new BusinessException(ResultCode.INTERNAL_ERROR.getCode(), "OSS config is incomplete");
        }
    }

    private UploadResult upload(MultipartFile file, String categoryPath) {
        return upload(file, categoryPath, false);
    }

    private UploadResult upload(MultipartFile file, String categoryPath, boolean inlineDisposition) {
        String originalFilename = Objects.requireNonNullElse(file.getOriginalFilename(), "unknown");
        String extension = "";
        int dotIndex = originalFilename.lastIndexOf('.');
        if (dotIndex >= 0) {
            extension = originalFilename.substring(dotIndex);
        }

        String objectKey = buildObjectKey(categoryPath, extension);
        OSS ossClient = new OSSClientBuilder().build(
                normalizeEndpoint(ossProperties.getEndpoint()),
                ossProperties.getAccessKeyId(),
                ossProperties.getAccessKeySecret()
        );
        try (InputStream inputStream = file.getInputStream()) {
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(file.getSize());
            if (StringUtils.hasText(file.getContentType())) {
                metadata.setContentType(file.getContentType());
            }
            if (inlineDisposition) {
                metadata.setContentDisposition("inline");
            }
            ossClient.putObject(ossProperties.getBucketName(), objectKey, inputStream, metadata);
        } catch (IOException ex) {
            throw new BusinessException(ResultCode.INTERNAL_ERROR.getCode(), "failed to read upload file");
        } catch (Exception ex) {
            throw new BusinessException(ResultCode.INTERNAL_ERROR.getCode(), "failed to upload file to OSS");
        } finally {
            ossClient.shutdown();
        }

        return UploadResult.builder()
                .objectKey(objectKey)
                .url(buildPublicUrl(objectKey))
                .originalFilename(originalFilename)
                .size(file.getSize())
                .contentType(file.getContentType())
                .build();
    }

    private String buildObjectKey(String categoryPath, String extension) {
        String basePath = resolveBasePath();
        LocalDate today = LocalDate.now();
        String objectPrefix = StringUtils.hasText(categoryPath)
                ? basePath + "/" + categoryPath
                : basePath;
        return objectPrefix + "/"
                + today.getYear() + "/"
                + String.format("%02d", today.getMonthValue()) + "/"
                + UUID.randomUUID().toString().replace("-", "")
                + extension;
    }

    private String resolveBasePath() {
        return StringUtils.hasText(ossProperties.getBasePath())
                ? ossProperties.getBasePath().replaceAll("^/|/$", "")
                : "education-platform/materials";
    }

    private void validateImageFile(MultipartFile file) {
        String contentType = file.getContentType();
        if (!StringUtils.hasText(contentType) || !IMAGE_CONTENT_TYPES.contains(contentType.toLowerCase())) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "course cover must be an image");
        }
    }

    private void validatePdfFile(MultipartFile file) {
        String contentType = StringUtils.trimWhitespace(file.getContentType());
        String filename = Objects.requireNonNullElse(file.getOriginalFilename(), "").toLowerCase();
        if (!"application/pdf".equalsIgnoreCase(contentType) && !filename.endsWith(".pdf")) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "section content must be a PDF file");
        }
    }

    private void validatePptFile(MultipartFile file) {
        String filename = Objects.requireNonNullElse(file.getOriginalFilename(), "").toLowerCase();
        boolean validExtension = PPT_EXTENSIONS.stream().anyMatch(filename::endsWith);
        if (!validExtension) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "section content must be a PPT file");
        }
    }

    private void validateSectionVideoFile(MultipartFile file) {
        if (file.getSize() > SECTION_VIDEO_MAX_SIZE) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "section video must not exceed 500MB");
        }

        String contentType = StringUtils.trimWhitespace(file.getContentType());
        if (StringUtils.hasText(contentType) && contentType.toLowerCase().startsWith("video/")) {
            return;
        }

        String filename = Objects.requireNonNullElse(file.getOriginalFilename(), "").toLowerCase();
        boolean validExtension = VIDEO_EXTENSIONS.stream().anyMatch(filename::endsWith);
        if (!validExtension) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "section video must be a valid video file");
        }
    }

    private String buildPublicUrl(String objectKey) {
        if (StringUtils.hasText(ossProperties.getPublicBaseUrl())) {
            return ossProperties.getPublicBaseUrl().replaceAll("/$", "") + "/" + objectKey;
        }
        return "https://" + ossProperties.getBucketName() + "." + ossProperties.getEndpoint() + "/" + objectKey;
    }

    private String normalizeEndpoint(String endpoint) {
        if (endpoint.startsWith("http://") || endpoint.startsWith("https://")) {
            return endpoint;
        }
        return "https://" + endpoint;
    }
}
