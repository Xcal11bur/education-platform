package com.education.platform.community.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;
import lombok.Data;

@Data
public class CommunityPostSaveDTO {

    @NotBlank(message = "title must not be blank")
    @Size(max = 80, message = "title length must not exceed 80")
    private String title;

    @NotBlank(message = "content must not be blank")
    @Size(max = 5000, message = "content length must not exceed 5000")
    private String content;

    @Size(max = 9, message = "imageUrls size must not exceed 9")
    private List<String> imageUrls;
}
