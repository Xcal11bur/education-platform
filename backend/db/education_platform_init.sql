-- 教育云平台一期初始化脚本
-- 数据库: MySQL 8.x
-- 说明:
-- 1. 当前脚本不依赖 Redis
-- 2. 一期先按单体后端设计，教师账号直接并入 teacher 表
-- 3. 为避免前期迁移复杂度，表之间不加外键，依赖业务层保证数据一致性
-- 4. 测试账号密码当前使用 BCrypt 密文，原始密码均为 123456

CREATE DATABASE IF NOT EXISTS `education_platform`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE `education_platform`;

SET NAMES utf8mb4;

DROP TABLE IF EXISTS `task_submission`;
DROP TABLE IF EXISTS `task_question`;
DROP TABLE IF EXISTS `course_task`;
DROP TABLE IF EXISTS `course_review`;
DROP TABLE IF EXISTS `course_material`;
DROP TABLE IF EXISTS `course_section`;
DROP TABLE IF EXISTS `course_chapter`;
DROP TABLE IF EXISTS `course_enrollment`;
DROP TABLE IF EXISTS `course`;
DROP TABLE IF EXISTS `course_category`;
DROP TABLE IF EXISTS `teacher`;
DROP TABLE IF EXISTS `member`;
DROP TABLE IF EXISTS `admin_user`;

CREATE TABLE `admin_user` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) NOT NULL COMMENT '登录账号',
  `password` varchar(100) NOT NULL COMMENT '登录密码',
  `real_name` varchar(50) NOT NULL COMMENT '真实姓名',
  `mobile` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `last_login_at` datetime DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_admin_user_username` (`username`),
  UNIQUE KEY `uk_admin_user_mobile` (`mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台管理员表';

CREATE TABLE `member` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `mobile` varchar(20) NOT NULL COMMENT '手机号',
  `password` varchar(100) NOT NULL COMMENT '登录密码',
  `nickname` varchar(50) NOT NULL COMMENT '昵称',
  `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像地址',
  `gender` tinyint NOT NULL DEFAULT 0 COMMENT '性别: 0未知 1男 2女',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1正常',
  `register_source` varchar(20) NOT NULL DEFAULT 'WEB' COMMENT '注册来源',
  `last_login_at` datetime DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_member_mobile` (`mobile`),
  KEY `idx_member_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员表';

CREATE TABLE `teacher` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `login_name` varchar(50) NOT NULL COMMENT '教师登录账号',
  `password` varchar(100) NOT NULL COMMENT '教师登录密码',
  `name` varchar(50) NOT NULL COMMENT '教师姓名',
  `title` varchar(100) DEFAULT NULL COMMENT '职称',
  `intro` text COMMENT '讲师简介',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像地址',
  `mobile` varchar(20) NOT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0停用 1启用',
  `last_login_at` datetime DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_teacher_login_name` (`login_name`),
  UNIQUE KEY `uk_teacher_mobile` (`mobile`),
  UNIQUE KEY `uk_teacher_email` (`email`),
  KEY `idx_teacher_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师表';

CREATE TABLE `course_category` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint unsigned NOT NULL DEFAULT 0 COMMENT '父级ID，一级为0',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `level` tinyint NOT NULL COMMENT '层级: 1一级 2二级',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_category_parent_name` (`parent_id`, `name`),
  KEY `idx_course_category_parent` (`parent_id`),
  KEY `idx_course_category_level_status` (`level`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程分类表';

CREATE TABLE `course` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `title` varchar(200) NOT NULL COMMENT '课程标题',
  `sub_title` varchar(255) DEFAULT NULL COMMENT '课程副标题',
  `teacher_id` bigint unsigned NOT NULL COMMENT '教师ID',
  `category_level1_id` bigint unsigned NOT NULL COMMENT '一级分类ID',
  `category_level2_id` bigint unsigned NOT NULL COMMENT '二级分类ID',
  `cover_url` varchar(255) DEFAULT NULL COMMENT '封面图地址',
  `description` longtext COMMENT '课程详情',
  `difficulty` tinyint NOT NULL DEFAULT 1 COMMENT '难度: 1初级 2中级 3高级',
  `price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '课程售价',
  `publish_status` tinyint NOT NULL DEFAULT 0 COMMENT '发布状态: 0草稿 1已上架 2已下架',
  `study_count` int NOT NULL DEFAULT 0 COMMENT '学习人数',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_course_teacher` (`teacher_id`),
  KEY `idx_course_category1` (`category_level1_id`),
  KEY `idx_course_category2` (`category_level2_id`),
  KEY `idx_course_publish_status` (`publish_status`),
  KEY `idx_course_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程基本信息表';

CREATE TABLE `course_enrollment` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint unsigned NOT NULL COMMENT '课程ID',
  `member_id` bigint unsigned NOT NULL COMMENT '会员ID',
  `enroll_type` tinyint NOT NULL DEFAULT 1 COMMENT '加入方式: 1免费 2购买 3后台分配',
  `source_order_no` varchar(64) DEFAULT NULL COMMENT '来源订单号',
  `study_progress` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT '学习进度，百分比',
  `last_study_section_id` bigint unsigned DEFAULT NULL COMMENT '最后学习小节ID',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0失效 1有效',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_enrollment_member_course` (`member_id`, `course_id`),
  KEY `idx_course_enrollment_course` (`course_id`),
  KEY `idx_course_enrollment_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程报名/学习关系表';

CREATE TABLE `course_chapter` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint unsigned NOT NULL COMMENT '课程ID',
  `title` varchar(200) NOT NULL COMMENT '章节标题',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_course_chapter_course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程章节表';

CREATE TABLE `course_section` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint unsigned NOT NULL COMMENT '课程ID',
  `chapter_id` bigint unsigned NOT NULL COMMENT '章节ID',
  `title` varchar(200) NOT NULL COMMENT '小节标题',
  `section_type` tinyint NOT NULL DEFAULT 1 COMMENT '小节类型: 1视频 2图文 3直播回放',
  `content` longtext COMMENT '图文内容或扩展描述',
  `video_url` varchar(255) DEFAULT NULL COMMENT '视频地址',
  `duration` int NOT NULL DEFAULT 0 COMMENT '时长，单位秒',
  `is_free_trial` tinyint NOT NULL DEFAULT 0 COMMENT '是否支持试看: 0否 1是',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_course_section_course` (`course_id`),
  KEY `idx_course_section_chapter` (`chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程小节表';

CREATE TABLE `course_material` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint unsigned NOT NULL COMMENT '课程ID',
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
  KEY `idx_course_material_course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程资料表';

CREATE TABLE `course_review` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint unsigned NOT NULL COMMENT '课程ID',
  `member_id` bigint unsigned NOT NULL COMMENT '会员ID',
  `score` tinyint NOT NULL COMMENT '评分: 1-5',
  `content` varchar(500) DEFAULT NULL COMMENT '评价内容',
  `anonymous_flag` tinyint NOT NULL DEFAULT 0 COMMENT '是否匿名: 0否 1是',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '审核状态: 0待审核 1已通过 2已拒绝',
  `reviewed_at` datetime DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_course_review_course_member` (`course_id`, `member_id`),
  KEY `idx_course_review_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程评价表';

CREATE TABLE `course_task` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint unsigned NOT NULL COMMENT '课程ID',
  `title` varchar(200) NOT NULL COMMENT '任务标题',
  `task_type` tinyint NOT NULL COMMENT '任务类型: 1考试 2作业',
  `description` longtext COMMENT '任务说明',
  `total_score` int NOT NULL DEFAULT 100 COMMENT '总分',
  `pass_score` int NOT NULL DEFAULT 60 COMMENT '及格分',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '截止时间',
  `duration_minutes` int DEFAULT NULL COMMENT '时长，单位分钟',
  `allow_retake_count` int NOT NULL DEFAULT 1 COMMENT '允许提交次数',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0草稿 1发布 2关闭',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_course_task_course` (`course_id`),
  KEY `idx_course_task_type_status` (`task_type`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程考试/作业表';

CREATE TABLE `task_question` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` bigint unsigned NOT NULL COMMENT '任务ID',
  `question_type` tinyint NOT NULL COMMENT '题型: 1单选 2多选 3判断 4简答',
  `stem` text NOT NULL COMMENT '题干',
  `options_json` json DEFAULT NULL COMMENT '选项JSON',
  `answer_json` json DEFAULT NULL COMMENT '标准答案JSON',
  `analysis` text COMMENT '题目解析',
  `score` int NOT NULL DEFAULT 0 COMMENT '题目分值',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_task_question_task` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题目表';

CREATE TABLE `task_submission` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` bigint unsigned NOT NULL COMMENT '任务ID',
  `member_id` bigint unsigned NOT NULL COMMENT '会员ID',
  `attempt_no` int NOT NULL DEFAULT 1 COMMENT '第几次提交',
  `answers_json` json DEFAULT NULL COMMENT '提交答案JSON',
  `attachment_url` varchar(255) DEFAULT NULL COMMENT '作业附件地址',
  `objective_score` int NOT NULL DEFAULT 0 COMMENT '客观题得分',
  `subjective_score` int NOT NULL DEFAULT 0 COMMENT '主观题得分',
  `score` int NOT NULL DEFAULT 0 COMMENT '总得分',
  `review_status` tinyint NOT NULL DEFAULT 0 COMMENT '批改状态: 0待批改 1已批改',
  `review_comment` varchar(500) DEFAULT NULL COMMENT '批改评语',
  `submitted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `reviewed_at` datetime DEFAULT NULL COMMENT '批改时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint unsigned DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint unsigned DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_submission_member_attempt` (`task_id`, `member_id`, `attempt_no`),
  KEY `idx_task_submission_member` (`member_id`),
  KEY `idx_task_submission_review_status` (`review_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试/作业提交记录表';

-- ----------------------------
-- 测试数据
-- ----------------------------

INSERT INTO `admin_user` (
  `id`, `username`, `password`, `real_name`, `mobile`, `email`, `status`, `created_by`, `updated_by`
) VALUES
  (1, 'admin', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '系统管理员', '13800000001', 'admin@edu.com', 1, 0, 0);

INSERT INTO `teacher` (
  `id`, `login_name`, `password`, `name`, `title`, `intro`, `avatar`, `mobile`, `email`, `status`, `created_by`, `updated_by`
) VALUES
  (1, 'teacher_li', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '李老师', '高级讲师', '主讲 Java 后端开发与 Spring Boot 实战。', 'https://cdn.edu.com/avatar/teacher-1.png', '13900000001', 'li.teacher@edu.com', 1, 1, 1),
  (2, 'teacher_wang', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '王老师', '前端讲师', '主讲 Vue 3、工程化与前端项目实战。', 'https://cdn.edu.com/avatar/teacher-2.png', '13900000002', 'wang.teacher@edu.com', 1, 1, 1);

INSERT INTO `course_category` (
  `id`, `parent_id`, `name`, `level`, `sort`, `status`, `created_by`, `updated_by`
) VALUES
  (1, 0, '编程开发', 1, 1, 1, 1, 1),
  (2, 0, '设计创作', 1, 2, 1, 1, 1),
  (3, 1, 'Java', 2, 1, 1, 1, 1),
  (4, 2, 'UI 设计', 2, 1, 1, 1, 1);

INSERT INTO `course` (
  `id`, `title`, `sub_title`, `teacher_id`, `category_level1_id`, `category_level2_id`,
  `cover_url`, `description`, `difficulty`, `price`, `publish_status`, `study_count`, `sort`, `created_by`, `updated_by`
) VALUES
  (
    1,
    'Spring Boot 实战课',
    '从入门到项目落地',
    1,
    1,
    3,
    'https://cdn.edu.com/course/springboot-cover.jpg',
    '本课程覆盖 Spring Boot 基础、接口设计、项目分层、数据库集成与综合案例。',
    2,
    199.00,
    1,
    0,
    100,
    1,
    1
  ),
  (
    2,
    'Figma 界面设计基础',
    '掌握组件化设计与页面规范',
    2,
    2,
    4,
    'https://cdn.edu.com/course/figma-cover.jpg',
    '本课程覆盖 Figma 基础操作、组件样式、界面结构与设计交付。',
    1,
    99.00,
    0,
    0,
    90,
    1,
    1
  );

INSERT INTO `course_chapter` (
  `id`, `course_id`, `title`, `sort`, `created_by`, `updated_by`
) VALUES
  (1, 1, '第一章：Spring Boot 基础入门', 1, 1, 1),
  (2, 2, '第一章：Figma 页面结构', 1, 1, 1);

INSERT INTO `course_section` (
  `id`, `course_id`, `chapter_id`, `title`, `section_type`, `content`,
  `video_url`, `duration`, `is_free_trial`, `sort`, `created_by`, `updated_by`
) VALUES
  (
    1,
    1,
    1,
    '1.1 Spring Boot 项目初始化',
    1,
    '介绍 IDEA 创建 Spring Boot 项目的基本步骤。',
    'https://cdn.edu.com/video/course-1-section-1.mp4',
    900,
    1,
    1,
    1,
    1
  ),
  (
    2,
    2,
    2,
    '1.1 Figma 基础画板与布局',
    2,
    '讲解画板、栅格、布局与基础组件搭建。',
    NULL,
    0,
    1,
    1,
    1,
    1
  );

INSERT INTO `course_material` (
  `id`, `course_id`, `material_name`, `material_type`, `file_url`,
  `file_size`, `download_limit`, `sort`, `created_by`, `updated_by`
) VALUES
  (1, 1, '课程源码.zip', 2, 'https://cdn.edu.com/material/course-1-source.zip', 10485760, 1, 1, 1, 1),
  (2, 2, '界面设计稿.fig', 4, 'https://cdn.edu.com/material/course-2-figma.fig', 5242880, 1, 1, 1, 1);
