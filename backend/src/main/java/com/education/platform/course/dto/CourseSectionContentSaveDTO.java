package com.education.platform.course.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CourseSectionContentSaveDTO {

    @NotBlank(message = "title must not be blank")
    private String title;

    @NotBlank(message = "contentType must not be blank")
    private String contentType;

    private String contentHtml;
    private String contentJson;
    private String fileUrl;
    private String objectKey;
    private String fileName;
    private String mimeType;
    private Long fileSize;
    private Integer duration;
    private Integer sort;
    private Integer status;
}
