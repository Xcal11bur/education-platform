package com.education.platform.task.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.education.platform.common.model.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("task_question")
public class TaskQuestion extends BaseEntity {

    private Long taskId;
    private Integer questionType;
    private String stem;
    private String optionsJson;
    private String answerJson;
    private String analysis;
    private Integer score;
    private Integer sort;
}
