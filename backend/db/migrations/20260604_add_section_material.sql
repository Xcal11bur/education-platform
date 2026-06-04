USE `education_platform`;

CREATE TABLE IF NOT EXISTS `section_material` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint unsigned NOT NULL COMMENT '课程ID',
  `chapter_id` bigint unsigned NOT NULL COMMENT '章节ID',
  `section_id` bigint unsigned NOT NULL COMMENT '小节ID',
  `material_name` varchar(200) NOT NULL COMMENT '资料名称',
  `material_type` tinyint NOT NULL DEFAULT 1 COMMENT '资料类型: 1文档 2压缩包 3图片 4其他',
  `file_url` varchar(255) NOT NULL COMMENT '文件地址',
  `file_size` bigint unsigned NOT NULL DEFAULT 0 COMMENT '文件大小，字节',
  `download_limit` tinyint NOT NULL DEFAULT 1 COMMENT '下载权限: 0全部学员 1已报名学员',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_section_material_course` (`course_id`),
  KEY `idx_section_material_chapter` (`chapter_id`),
  KEY `idx_section_material_section` (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小节资料表';
