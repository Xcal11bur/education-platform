package com.education.platform.exam.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("exam_question")
public class ExamQuestion extends BaseEntity {

    private Long taskId;
    private Integer questionType;
    private String stem;
    private String optionsJson;
    private String answerJson;
    private String analysis;
    private Integer score;
    private Integer sort;
}
