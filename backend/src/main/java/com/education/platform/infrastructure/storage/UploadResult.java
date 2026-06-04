package com.education.platform.infrastructure.storage;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UploadResult {

    private String objectKey;
    private String url;
    private String originalFilename;
    private Long size;
    private String contentType;
}
