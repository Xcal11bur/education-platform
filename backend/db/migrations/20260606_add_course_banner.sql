USE `education_platform`;

CREATE TABLE IF NOT EXISTS `course_banner` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint unsigned NOT NULL COMMENT '课程ID',
  `title` varchar(200) DEFAULT NULL COMMENT '自定义轮播标题',
  `sub_title` varchar(255) DEFAULT NULL COMMENT '自定义轮播副标题',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_banner_course` (`course_id`),
  KEY `idx_course_banner_status_sort` (`status`, `sort`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程轮播图配置表';
