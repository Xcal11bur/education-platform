package com.education.platform.infrastructure.storage;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.model.ObjectMetadata;
import com.education.platform.common.exception.BusinessException;
import com.education.platform.common.result.ResultCode;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDate;
import java.util.Objects;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
public class OssUploadService {

    private final OssProperties ossProperties;

    public OssUploadService(OssProperties ossProperties) {
        this.ossProperties = ossProperties;
    }

    public UploadResult uploadMaterial(MultipartFile file) {
        validateOssConfig();
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ResultCode.BAD_REQUEST.getCode(), "upload file must not be empty");
        }

        String originalFilename = Objects.requireNonNullElse(file.getOriginalFilename(), "unknown");
        String extension = "";
        int dotIndex = originalFilename.lastIndexOf('.');
        if (dotIndex >= 0) {
            extension = originalFilename.substring(dotIndex);
        }

        String objectKey = buildObjectKey(extension);
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

    private void validateOssConfig() {
        if (!StringUtils.hasText(ossProperties.getEndpoint())
                || !StringUtils.hasText(ossProperties.getBucketName())
                || !StringUtils.hasText(ossProperties.getAccessKeyId())
                || !StringUtils.hasText(ossProperties.getAccessKeySecret())) {
            throw new BusinessException(ResultCode.INTERNAL_ERROR.getCode(), "OSS config is incomplete");
        }
    }

    private String buildObjectKey(String extension) {
        String basePath = StringUtils.hasText(ossProperties.getBasePath())
                ? ossProperties.getBasePath().replaceAll("^/|/$", "")
                : "education-platform/materials";
        LocalDate today = LocalDate.now();
        return basePath + "/"
                + today.getYear() + "/"
                + String.format("%02d", today.getMonthValue()) + "/"
                + UUID.randomUUID().toString().replace("-", "")
                + extension;
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
