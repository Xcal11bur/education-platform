package com.education.platform.community.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CommunityCommentSaveDTO {

    private Long parentId;
    private Long replyToMemberId;

    @NotBlank(message = "content must not be blank")
    @Size(max = 1000, message = "content length must not exceed 1000")
    private String content;
}
