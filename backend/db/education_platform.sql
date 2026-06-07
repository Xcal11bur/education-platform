/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80041
 Source Host           : localhost:3306
 Source Schema         : education_platform

 Target Server Type    : MySQL
 Target Server Version : 80041
 File Encoding         : 65001

 Date: 07/06/2026 18:41:36
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin_user
-- ----------------------------
DROP TABLE IF EXISTS `admin_user`;
CREATE TABLE `admin_user`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录密码',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '真实姓名',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `last_login_at` datetime(0) NULL DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_admin_user_username`(`username`) USING BTREE,
  UNIQUE INDEX `uk_admin_user_mobile`(`mobile`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '后台管理员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin_user
-- ----------------------------
INSERT INTO `admin_user` VALUES (1, 'admin', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '系统管理员', '13800000001', 'admin@edu.com', 1, NULL, '2026-06-04 10:11:11', '2026-06-04 10:11:11', 0, 0, 0);

-- ----------------------------
-- Table structure for course
-- ----------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '课程标题',
  `sub_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '课程副标题',
  `teacher_id` bigint(0) UNSIGNED NOT NULL COMMENT '教师ID',
  `category_level1_id` bigint(0) UNSIGNED NOT NULL COMMENT '一级分类ID',
  `category_level2_id` bigint(0) UNSIGNED NOT NULL COMMENT '二级分类ID',
  `cover_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图地址',
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '课程详情',
  `difficulty` tinyint(0) NOT NULL DEFAULT 1 COMMENT '难度: 1初级 2中级 3高级',
  `price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '课程售价',
  `publish_status` tinyint(0) NOT NULL DEFAULT 0 COMMENT '发布状态: 0草稿 1已上架 2已下架',
  `study_count` int(0) NOT NULL DEFAULT 0 COMMENT '学习人数',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_teacher`(`teacher_id`) USING BTREE,
  INDEX `idx_course_category1`(`category_level1_id`) USING BTREE,
  INDEX `idx_course_category2`(`category_level2_id`) USING BTREE,
  INDEX `idx_course_publish_status`(`publish_status`) USING BTREE,
  INDEX `idx_course_sort`(`sort`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程基本信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course
-- ----------------------------
INSERT INTO `course` VALUES (1, '企业文化导论', '快速了解企业文化与价值理念', 1, 1, 3, 'https://images.unsplash.com/photo-1541746972996-4e0b0f43e02a?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '帮助新学员系统了解企业发展历程、核心文化与工作方式。', 1, 0.00, 1, 1820, 160, '2026-06-04 10:11:58', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (2, '价值观场景实践', '用真实业务案例理解企业价值观', 2, 1, 3, 'https://images.unsplash.com/photo-1759884247231-24a9d8f6d454?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '围绕项目协作、客户服务与执行交付梳理价值观在业务中的应用。', 1, 0.00, 1, 1650, 158, '2026-06-04 10:11:58', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (3, '高效沟通方法课', '强化跨部门协同和沟通表达', 1, 1, 4, 'https://images.unsplash.com/photo-1758518731814-50848c31d1ae?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '围绕会议沟通、信息同步和问题反馈建立高效协作机制。', 1, 0.00, 1, 1498, 156, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (4, '项目协同作战训练', '掌握跨团队配合的关键动作', 2, 1, 4, 'https://images.unsplash.com/photo-1758873269811-4e62e346b4b7?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '覆盖项目启动、角色分工、风险同步与复盘协同等核心场景。', 2, 69.00, 1, 1360, 154, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (5, '云原生基础入门', '理解容器、镜像与集群基础概念', 1, 2, 7, 'https://images.unsplash.com/vector-1761074651005-97a2e57eef29?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '帮助学员建立云原生技术体系认知，适合作为平台学习起点。', 1, 99.00, 1, 1288, 152, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (6, '容器化部署实训', '从开发到部署的实战演练', 2, 2, 7, 'https://images.unsplash.com/photo-1667264501379-c1537934c7ab?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '聚焦镜像打包、环境发布和服务巡检等典型工作任务。', 2, 129.00, 1, 1192, 150, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (7, '平台交付流程实训', '掌握平台项目交付全流程', 1, 2, 8, 'https://images.unsplash.com/vector-1761645078994-e7aa36f349a8?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '通过典型案例覆盖需求理解、方案设计、交付验收到运维支持。', 2, 149.00, 1, 1120, 148, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (8, '运维规范与值守实战', '建立平台运维与响应机制', 2, 2, 8, 'https://images.unsplash.com/photo-1680992046626-418f7e910589?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '学习告警处理、变更管理、日常巡检与故障复盘等运维规范。', 2, 119.00, 1, 1036, 146, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (9, '数据分析基础', '掌握指标拆解与报表分析', 1, 5, 9, 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '以业务数据分析为主线，帮助学员建立数据思维与分析框架。', 1, 89.00, 1, 980, 144, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (10, '经营数据看板实战', '从指标体系到可视化展示', 2, 5, 9, 'https://images.unsplash.com/photo-1763038311036-6d18805537e5?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '结合真实场景构建数据看板，完成从数据处理到结果呈现的闭环。', 2, 129.00, 1, 924, 142, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (11, '数据治理规范课', '构建主数据与数据质量意识', 1, 5, 10, 'https://images.unsplash.com/photo-1763568258367-1c52beb60be7?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '覆盖数据标准、口径统一、质量校验与权限治理等核心议题。', 2, 99.00, 1, 886, 140, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (12, '数据资产运营训练营', '提升数据应用与资产沉淀能力', 2, 5, 10, 'https://images.unsplash.com/photo-1774600122432-dfddc9987ff8?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '从资产目录、治理流程到运营复盘，系统提升数据资产管理能力。', 2, 139.00, 1, 832, 138, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (13, '新员工入职第一课', '快速融入团队与岗位角色', 1, 6, 11, 'https://images.unsplash.com/photo-1752651881400-ae82bc9ad5fa?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '围绕制度认知、工作流程和团队协作，帮助学员快速进入工作状态。', 1, 0.00, 1, 1450, 136, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (14, '岗位能力成长地图', '明确不同阶段的能力提升路径', 2, 6, 11, 'https://images.unsplash.com/photo-1758691736433-4078b93abd72?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '结合岗位模型和成长路径，帮助学员识别短板并制定学习计划。', 1, 59.00, 1, 1186, 134, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (15, '基层管理者进阶课', '从执行骨干到团队管理者', 1, 6, 12, 'https://images.unsplash.com/photo-1551836022-aadb801c60ae?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '聚焦目标拆解、团队带教、过程辅导与结果复盘等管理关键动作。', 2, 129.00, 1, 928, 132, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (16, '绩效辅导与团队激励', '建立持续反馈与激励机制', 2, 6, 12, 'https://images.unsplash.com/photo-1752651881400-ae82bc9ad5fa?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '围绕绩效沟通、目标跟进和正向激励提升团队执行与成长效率。', 2, 149.00, 1, 874, 130, '2026-06-05 14:29:53', '2026-06-06 17:52:53', 1, 1, 0);
INSERT INTO `course` VALUES (17, 'test', 'test', 2, 1, 3, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/course-covers/2026/06/66196887b8b04f6882cffe24f77fe203.png', 'test', 1, 1.00, 0, 0, 0, '2026-06-07 18:07:58', '2026-06-07 18:07:58', 0, 0, 0);

-- ----------------------------
-- Table structure for course_banner
-- ----------------------------
DROP TABLE IF EXISTS `course_banner`;
CREATE TABLE `course_banner`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '自定义轮播标题',
  `sub_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '自定义轮播副标题',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_banner_course`(`course_id`) USING BTREE,
  INDEX `idx_course_banner_status_sort`(`status`, `sort`, `id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程轮播图配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_banner
-- ----------------------------
INSERT INTO `course_banner` VALUES (1, 1, '企业文化导论', '快速了解企业文化与价值理念', 40, 1, '2026-06-06 18:16:12', '2026-06-06 18:16:12', 1, 1, 0);
INSERT INTO `course_banner` VALUES (2, 5, '云原生基础入门', '理解容器、镜像与集群基础概念', 30, 1, '2026-06-06 18:16:13', '2026-06-06 18:16:13', 1, 1, 0);
INSERT INTO `course_banner` VALUES (3, 9, '数据分析基础', '掌握指标拆解与报表分析', 20, 1, '2026-06-06 18:16:13', '2026-06-06 18:16:13', 1, 1, 0);
INSERT INTO `course_banner` VALUES (4, 15, '基层管理者进阶课', '从执行骨干到团队管理者', 10, 1, '2026-06-06 18:16:14', '2026-06-06 18:18:35', 1, 0, 1);

-- ----------------------------
-- Table structure for course_category
-- ----------------------------
DROP TABLE IF EXISTS `course_category`;
CREATE TABLE `course_category`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `parent_id` bigint(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '父级ID，一级为0',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `level` tinyint(0) NOT NULL COMMENT '层级: 1一级 2二级',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_category_parent_name`(`parent_id`, `name`) USING BTREE,
  INDEX `idx_course_category_parent`(`parent_id`) USING BTREE,
  INDEX `idx_course_category_level_status`(`level`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_category
-- ----------------------------
INSERT INTO `course_category` VALUES (1, 0, '企业文化', 1, 1, 1, '2026-06-04 10:11:33', '2026-06-05 14:28:41', 1, 1, 0);
INSERT INTO `course_category` VALUES (2, 0, '锐道云', 1, 2, 1, '2026-06-04 10:11:33', '2026-06-05 14:28:41', 1, 1, 0);
INSERT INTO `course_category` VALUES (3, 1, '企业价值观', 2, 1, 1, '2026-06-04 10:11:33', '2026-06-05 14:28:41', 1, 1, 0);
INSERT INTO `course_category` VALUES (4, 1, '组织协同', 2, 2, 1, '2026-06-04 10:11:33', '2026-06-05 14:28:41', 1, 1, 0);
INSERT INTO `course_category` VALUES (5, 0, '云计算&大数据', 1, 3, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1, 0);
INSERT INTO `course_category` VALUES (6, 0, '人力资源管理', 1, 4, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1, 0);
INSERT INTO `course_category` VALUES (7, 2, '云原生基础', 2, 1, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1, 0);
INSERT INTO `course_category` VALUES (8, 2, '平台实战', 2, 2, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1, 0);
INSERT INTO `course_category` VALUES (9, 5, '数据分析', 2, 1, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1, 0);
INSERT INTO `course_category` VALUES (10, 5, '数据治理', 2, 2, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1, 0);
INSERT INTO `course_category` VALUES (11, 6, '入职培养', 2, 1, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1, 0);
INSERT INTO `course_category` VALUES (12, 6, '管理进阶', 2, 2, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1, 0);

-- ----------------------------
-- Table structure for course_chapter
-- ----------------------------
DROP TABLE IF EXISTS `course_chapter`;
CREATE TABLE `course_chapter`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '章节标题',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_chapter_course`(`course_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程章节表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_chapter
-- ----------------------------
INSERT INTO `course_chapter` VALUES (1, 1, '第一章：企业文化基础入门', 1, '2026-06-04 10:12:07', '2026-06-04 10:12:07', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (2, 2, '第一章：价值判断基础', 1, '2026-06-04 10:12:07', '2026-06-06 19:15:23', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (3, 1, '第二章：核心价值观解读', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (4, 1, '第三章：组织行为与文化案例', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (5, 1, '第四章：文化落地行动清单', 4, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (6, 2, '第二章：客户场景中的价值判断', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (7, 2, '第三章：协作冲突与决策取舍', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (8, 2, '第四章：复盘与行为改进', 4, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (9, 3, '第一章：沟通底层逻辑', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (10, 3, '第二章：向上与跨部门沟通', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (11, 3, '第三章：会议表达与反馈技巧', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (12, 4, '第一章：项目协同角色分工', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (13, 4, '第二章：进度同步与风险处理', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (14, 4, '第三章：跨团队交付复盘', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (15, 5, '第一章：云原生概念总览', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (16, 5, '第二章：容器与镜像基础', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (17, 5, '第三章：集群与服务治理入门', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (18, 6, '第一章：应用容器化准备', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (19, 6, '第二章：镜像构建与仓库管理', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (20, 6, '第三章：部署发布与问题排查', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (21, 7, '第一章：平台交付流程概览', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (22, 7, '第二章：需求评审与环境准备', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (23, 7, '第三章：验收交付与总结复盘', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (24, 8, '第一章：运维值守基本规范', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (25, 8, '第二章：告警响应与故障升级', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (26, 8, '第三章：巡检制度与应急演练', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (27, 9, '第一章：指标认知与数据口径', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (28, 9, '第二章：基础分析方法', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (29, 9, '第三章：报表解读与结论输出', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (30, 10, '第一章：看板目标与受众定义', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (31, 10, '第二章：指标体系设计', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (32, 10, '第三章：可视化呈现与迭代优化', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (33, 11, '第一章：数据治理核心原则', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (34, 11, '第二章：主数据与质量管理', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (35, 11, '第三章：治理机制与职责协同', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (36, 12, '第一章：数据资产盘点方法', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (37, 12, '第二章：数据应用场景运营', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (38, 12, '第三章：资产沉淀与价值评估', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (39, 13, '第一章：公司制度与角色认知', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (40, 13, '第二章：团队协作与工作流程', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (41, 13, '第三章：试用期目标与成长建议', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (42, 14, '第一章：岗位能力模型解析', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (43, 14, '第二章：阶段性成长目标设定', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (44, 14, '第三章：学习路径与行动计划', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (45, 15, '第一章：管理者角色转换', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (46, 15, '第二章：目标管理与任务分配', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (47, 15, '第三章：团队带教与过程复盘', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (48, 16, '第一章：绩效沟通基础', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (49, 16, '第二章：一对一辅导技巧', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (50, 16, '第三章：激励机制与团队氛围建设', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1, 0);
INSERT INTO `course_chapter` VALUES (51, 17, '1', 1, '2026-06-07 18:08:10', '2026-06-07 18:08:10', 0, 0, 0);

-- ----------------------------
-- Table structure for course_enrollment
-- ----------------------------
DROP TABLE IF EXISTS `course_enrollment`;
CREATE TABLE `course_enrollment`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `member_id` bigint(0) UNSIGNED NOT NULL COMMENT '会员ID',
  `enroll_type` tinyint(0) NOT NULL DEFAULT 1 COMMENT '加入方式: 1免费 2购买 3后台分配',
  `source_order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '来源订单号',
  `study_progress` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '学习进度，百分比',
  `last_study_section_id` bigint(0) UNSIGNED NULL DEFAULT NULL COMMENT '最后学习小节ID',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0失效 1有效',
  `expire_time` datetime(0) NULL DEFAULT NULL COMMENT '过期时间',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_enrollment_member_course`(`member_id`, `course_id`) USING BTREE,
  INDEX `idx_course_enrollment_course`(`course_id`) USING BTREE,
  INDEX `idx_course_enrollment_status`(`status`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程报名/学习关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_enrollment
-- ----------------------------

-- ----------------------------
-- Table structure for course_material
-- ----------------------------
DROP TABLE IF EXISTS `course_material`;
CREATE TABLE `course_material`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `material_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资料名称',
  `material_type` tinyint(0) NOT NULL DEFAULT 1 COMMENT '资料类型: 1文档 2压缩包 3图片 4其他',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件地址',
  `file_size` bigint(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件大小，字节',
  `download_limit` tinyint(0) NOT NULL DEFAULT 1 COMMENT '下载权限: 0全部学员 1已报名学员',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_material_course`(`course_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程资料表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_material
-- ----------------------------
INSERT INTO `course_material` VALUES (3, 1, 'test', 1, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/2026/06/f666f1be23674137b035d1b71481c3d3.txt', 18, 1, 1, '2026-06-04 10:52:25', '2026-06-04 10:52:25', 0, 0, 0);

-- ----------------------------
-- Table structure for course_review
-- ----------------------------
DROP TABLE IF EXISTS `course_review`;
CREATE TABLE `course_review`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `member_id` bigint(0) UNSIGNED NOT NULL COMMENT '会员ID',
  `score` tinyint(0) NOT NULL COMMENT '评分: 1-5',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价内容',
  `anonymous_flag` tinyint(0) NOT NULL DEFAULT 0 COMMENT '是否匿名: 0否 1是',
  `status` tinyint(0) NOT NULL DEFAULT 0 COMMENT '审核状态: 0待审核 1已通过 2已拒绝',
  `reviewed_at` datetime(0) NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_review_course_member`(`course_id`, `member_id`) USING BTREE,
  INDEX `idx_course_review_status`(`status`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_review
-- ----------------------------

-- ----------------------------
-- Table structure for course_section
-- ----------------------------
DROP TABLE IF EXISTS `course_section`;
CREATE TABLE `course_section`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `chapter_id` bigint(0) UNSIGNED NOT NULL COMMENT '章节ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '小节标题',
  `is_free_trial` tinyint(0) NOT NULL DEFAULT 0 COMMENT '是否支持试看: 0否 1是',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_section_course`(`course_id`) USING BTREE,
  INDEX `idx_course_section_chapter`(`chapter_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 129 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程小节表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_section
-- ----------------------------
INSERT INTO `course_section` VALUES (1, 1, 1, '企业文化基础入门导读', 1, 1, '2026-06-04 10:12:17', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (2, 2, 2, '价值判断基础导读', 1, 1, '2026-06-04 10:12:17', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (3, 1, 3, '核心价值观解读导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (4, 1, 4, '组织行为与文化案例导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (5, 1, 5, '文化落地行动清单导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (6, 2, 6, '客户场景中的价值判断导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (7, 2, 7, '协作冲突与决策取舍导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (8, 2, 8, '复盘与行为改进导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (9, 3, 9, '沟通底层逻辑导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (10, 3, 10, '向上与跨部门沟通导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (11, 3, 11, '会议表达与反馈技巧导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (12, 4, 12, '项目协同角色分工导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (13, 4, 13, '进度同步与风险处理导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (14, 4, 14, '跨团队交付复盘导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (15, 5, 15, '云原生概念总览导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (16, 5, 16, '容器与镜像基础导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (17, 5, 17, '集群与服务治理入门导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (18, 6, 18, '应用容器化准备导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (19, 6, 19, '镜像构建与仓库管理导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (20, 6, 20, '部署发布与问题排查导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (21, 7, 21, '平台交付流程概览导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (22, 7, 22, '需求评审与环境准备导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (23, 7, 23, '验收交付与总结复盘导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (24, 8, 24, '运维值守基本规范导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (25, 8, 25, '告警响应与故障升级导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (26, 8, 26, '巡检制度与应急演练导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (27, 9, 27, '指标认知与数据口径导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (28, 9, 28, '基础分析方法导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (29, 9, 29, '报表解读与结论输出导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (30, 10, 30, '看板目标与受众定义导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (31, 10, 31, '指标体系设计导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (32, 10, 32, '可视化呈现与迭代优化导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (33, 11, 33, '数据治理核心原则导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (34, 11, 34, '主数据与质量管理导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (35, 11, 35, '治理机制与职责协同导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (36, 12, 36, '数据资产盘点方法导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (37, 12, 37, '数据应用场景运营导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (38, 12, 38, '资产沉淀与价值评估导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (39, 13, 39, '公司制度与角色认知导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (40, 13, 40, '团队协作与工作流程导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (41, 13, 41, '试用期目标与成长建议导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (42, 14, 42, '岗位能力模型解析导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (43, 14, 43, '阶段性成长目标设定导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (44, 14, 44, '学习路径与行动计划导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (45, 15, 45, '管理者角色转换导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (46, 15, 46, '目标管理与任务分配导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (47, 15, 47, '团队带教与过程复盘导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (48, 16, 48, '绩效沟通基础导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (49, 16, 49, '一对一辅导技巧导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (50, 16, 50, '激励机制与团队氛围建设导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (66, 1, 1, '企业文化基础入门实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (67, 2, 2, '价值判断基础实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (68, 1, 3, '核心价值观解读实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (69, 1, 4, '组织行为与文化案例实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (70, 1, 5, '文化落地行动清单实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (71, 2, 6, '客户场景中的价值判断实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (72, 2, 7, '协作冲突与决策取舍实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (73, 2, 8, '复盘与行为改进实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (74, 3, 9, '沟通底层逻辑实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (75, 3, 10, '向上与跨部门沟通实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (76, 3, 11, '会议表达与反馈技巧实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (77, 4, 12, '项目协同角色分工实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (78, 4, 13, '进度同步与风险处理实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (79, 4, 14, '跨团队交付复盘实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (80, 5, 15, '云原生概念总览实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (81, 5, 16, '容器与镜像基础实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (82, 5, 17, '集群与服务治理入门实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (83, 6, 18, '应用容器化准备实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (84, 6, 19, '镜像构建与仓库管理实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (85, 6, 20, '部署发布与问题排查实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (86, 7, 21, '平台交付流程概览实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (87, 7, 22, '需求评审与环境准备实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (88, 7, 23, '验收交付与总结复盘实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (89, 8, 24, '运维值守基本规范实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (90, 8, 25, '告警响应与故障升级实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (91, 8, 26, '巡检制度与应急演练实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (92, 9, 27, '指标认知与数据口径实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (93, 9, 28, '基础分析方法实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (94, 9, 29, '报表解读与结论输出实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (95, 10, 30, '看板目标与受众定义实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (96, 10, 31, '指标体系设计实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (97, 10, 32, '可视化呈现与迭代优化实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (98, 11, 33, '数据治理核心原则实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (99, 11, 34, '主数据与质量管理实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (100, 11, 35, '治理机制与职责协同实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (101, 12, 36, '数据资产盘点方法实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (102, 12, 37, '数据应用场景运营实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (103, 12, 38, '资产沉淀与价值评估实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (104, 13, 39, '公司制度与角色认知实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (105, 13, 40, '团队协作与工作流程实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (106, 13, 41, '试用期目标与成长建议实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (107, 14, 42, '岗位能力模型解析实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (108, 14, 43, '阶段性成长目标设定实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (109, 14, 44, '学习路径与行动计划实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (110, 15, 45, '管理者角色转换实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (111, 15, 46, '目标管理与任务分配实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (112, 15, 47, '团队带教与过程复盘实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (113, 16, 48, '绩效沟通基础实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (114, 16, 49, '一对一辅导技巧实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (115, 16, 50, '激励机制与团队氛围建设实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1, 0);
INSERT INTO `course_section` VALUES (129, 17, 51, '1', 0, 1, '2026-06-07 18:08:15', '2026-06-07 18:08:15', 0, 0, 0);

-- ----------------------------
-- Table structure for course_section_content
-- ----------------------------
DROP TABLE IF EXISTS `course_section_content`;
CREATE TABLE `course_section_content`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `chapter_id` bigint(0) UNSIGNED NOT NULL COMMENT '章节ID',
  `section_id` bigint(0) UNSIGNED NOT NULL COMMENT '小节ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '内容项标题',
  `content_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '内容类型: VIDEO/RICH_TEXT/PDF/FILE',
  `content_html` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '富文本HTML内容',
  `content_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '富文本结构化JSON内容',
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件或视频地址',
  `object_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'OSS对象Key',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原始文件名',
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件MIME类型',
  `file_size` bigint(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件大小，字节',
  `duration` int(0) NOT NULL DEFAULT 0 COMMENT '视频时长，单位秒',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_section_content_section`(`section_id`) USING BTREE,
  INDEX `idx_course_section_content_course`(`course_id`) USING BTREE,
  INDEX `idx_course_section_content_chapter`(`chapter_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程小节内容项表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_section_content
-- ----------------------------
INSERT INTO `course_section_content` VALUES (1, 1, 1, 66, 'test', 'RICH_TEXT', '<ol><li><p>123123</p></li><li><p>ttt</p></li><li><p>ttt</p></li><li><p>ww</p></li></ol><p></p>', NULL, '', NULL, NULL, NULL, 0, 0, 1, 1, '2026-06-07 17:36:20', '2026-06-07 17:54:53', 0, 0, 1);
INSERT INTO `course_section_content` VALUES (2, 1, 1, 1, '测试视频', 'VIDEO', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/videos/2026/06/cc87a19c5efb411ea0c7daca1f1ef2d4.mp4', 'education-platform/materials/section-contents/videos/2026/06/cc87a19c5efb411ea0c7daca1f1ef2d4.mp4', 'New project.mp4', 'video/mp4', 8285618, 11, 1, 1, '2026-06-07 17:42:10', '2026-06-07 17:42:10', 0, 0, 0);
INSERT INTO `course_section_content` VALUES (3, 1, 1, 1, '富文本测试', 'RICH_TEXT', '<ol><li><p>a</p></li><li><p>b</p></li><li><p>ccc</p></li></ol><p></p>', '{\"type\":\"doc\",\"content\":[{\"type\":\"orderedList\",\"attrs\":{\"start\":1,\"type\":null},\"content\":[{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"a\"}]}]},{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"b\"}]}]},{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"ccc\"}]}]}]},{\"type\":\"paragraph\"}]}', NULL, NULL, NULL, NULL, 0, 0, 2, 1, '2026-06-07 17:42:31', '2026-06-07 17:54:46', 0, 0, 1);
INSERT INTO `course_section_content` VALUES (4, 1, 1, 1, 'testpdf', 'PDF', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/pdf/2026/06/564b4cb9c296479497e7608840447b89.pdf', 'education-platform/materials/section-contents/pdf/2026/06/564b4cb9c296479497e7608840447b89.pdf', 'Redis常见面试题汇总.pdf', 'application/pdf', 592563, 0, 3, 1, '2026-06-07 17:46:12', '2026-06-07 17:54:48', 0, 0, 1);
INSERT INTO `course_section_content` VALUES (5, 1, 1, 1, '富文本测试', 'RICH_TEXT', '<ul><li><p>test</p></li><li><p></p><img src=\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/6b10070e0f1b41ac85dffbd86affa7ef.png\" alt=\"image.png\"></li></ul><ul><li><p>test2</p></li></ul><p></p>', '{\"type\":\"doc\",\"content\":[{\"type\":\"bulletList\",\"content\":[{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"test\"}]}]},{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\"},{\"type\":\"image\",\"attrs\":{\"src\":\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/6b10070e0f1b41ac85dffbd86affa7ef.png\",\"alt\":\"image.png\",\"title\":null,\"width\":null,\"height\":null}}]}]},{\"type\":\"bulletList\",\"content\":[{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"test2\"}]}]}]},{\"type\":\"paragraph\"}]}', NULL, NULL, NULL, NULL, 0, 0, 2, 1, '2026-06-07 17:55:58', '2026-06-07 17:55:58', 0, 0, 0);
INSERT INTO `course_section_content` VALUES (6, 1, 1, 1, 'pdf测试', 'PDF', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/pdf/2026/06/68d95028d8854c27997dfeeb208e5aed.pdf', 'education-platform/materials/section-contents/pdf/2026/06/68d95028d8854c27997dfeeb208e5aed.pdf', 'Redis常见面试题汇总.pdf', 'application/pdf', 592563, 0, 3, 1, '2026-06-07 17:56:13', '2026-06-07 17:56:13', 0, 0, 0);
INSERT INTO `course_section_content` VALUES (7, 2, 2, 2, 'pdf测试', 'PDF', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/pdf/2026/06/cd69545a73c943ed89e140c54583349b.pdf', 'education-platform/materials/section-contents/pdf/2026/06/cd69545a73c943ed89e140c54583349b.pdf', 'Redis常见面试题汇总.pdf', 'application/pdf', 592563, 0, 1, 1, '2026-06-07 18:00:08', '2026-06-07 18:00:08', 0, 0, 0);
INSERT INTO `course_section_content` VALUES (8, 2, 2, 2, 'pdf', 'PDF', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/pdf/2026/06/445ebbe57a0c4ccfbb31cee64a7f5e22.pdf', 'education-platform/materials/section-contents/pdf/2026/06/445ebbe57a0c4ccfbb31cee64a7f5e22.pdf', 'Redis常见面试题汇总.pdf', 'application/pdf', 592563, 0, 2, 1, '2026-06-07 18:03:56', '2026-06-07 18:03:56', 0, 0, 0);

-- ----------------------------
-- Table structure for course_task
-- ----------------------------
DROP TABLE IF EXISTS `course_task`;
CREATE TABLE `course_task`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务标题',
  `task_type` tinyint(0) NOT NULL COMMENT '任务类型: 1考试 2作业',
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '任务说明',
  `total_score` int(0) NOT NULL DEFAULT 100 COMMENT '总分',
  `pass_score` int(0) NOT NULL DEFAULT 60 COMMENT '及格分',
  `start_time` datetime(0) NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '截止时间',
  `duration_minutes` int(0) NULL DEFAULT NULL COMMENT '时长，单位分钟',
  `allow_retake_count` int(0) NOT NULL DEFAULT 1 COMMENT '允许提交次数',
  `status` tinyint(0) NOT NULL DEFAULT 0 COMMENT '状态: 0草稿 1发布 2关闭',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_task_course`(`course_id`) USING BTREE,
  INDEX `idx_course_task_type_status`(`task_type`, `status`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程考试/作业表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_task
-- ----------------------------

-- ----------------------------
-- Table structure for member
-- ----------------------------
DROP TABLE IF EXISTS `member`;
CREATE TABLE `member`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录密码',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像地址',
  `gender` tinyint(0) NOT NULL DEFAULT 0 COMMENT '性别: 0未知 1男 2女',
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1正常',
  `register_source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'WEB' COMMENT '注册来源',
  `last_login_at` datetime(0) NULL DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_member_mobile`(`mobile`) USING BTREE,
  INDEX `idx_member_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of member
-- ----------------------------
INSERT INTO `member` VALUES (1, '13800000011', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '学员小王', '王一凡', NULL, 1, '2000-05-18', 1, 'WEB', NULL, '2026-06-04 11:47:16', '2026-06-04 11:47:16', 0, 0, 0);
INSERT INTO `member` VALUES (2, '13800000012', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '学员小李', '李欣然', NULL, 2, '2001-09-06', 1, 'WEB', NULL, '2026-06-04 11:47:16', '2026-06-04 11:47:16', 0, 0, 0);

-- ----------------------------
-- Table structure for task_question
-- ----------------------------
DROP TABLE IF EXISTS `task_question`;
CREATE TABLE `task_question`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` bigint(0) UNSIGNED NOT NULL COMMENT '任务ID',
  `question_type` tinyint(0) NOT NULL COMMENT '题型: 1单选 2多选 3判断 4简答',
  `stem` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题干',
  `options_json` json NULL COMMENT '选项JSON',
  `answer_json` json NULL COMMENT '标准答案JSON',
  `analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '题目解析',
  `score` int(0) NOT NULL DEFAULT 0 COMMENT '题目分值',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_question_task`(`task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of task_question
-- ----------------------------

-- ----------------------------
-- Table structure for task_submission
-- ----------------------------
DROP TABLE IF EXISTS `task_submission`;
CREATE TABLE `task_submission`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` bigint(0) UNSIGNED NOT NULL COMMENT '任务ID',
  `member_id` bigint(0) UNSIGNED NOT NULL COMMENT '会员ID',
  `attempt_no` int(0) NOT NULL DEFAULT 1 COMMENT '第几次提交',
  `answers_json` json NULL COMMENT '提交答案JSON',
  `attachment_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '作业附件地址',
  `objective_score` int(0) NOT NULL DEFAULT 0 COMMENT '客观题得分',
  `subjective_score` int(0) NOT NULL DEFAULT 0 COMMENT '主观题得分',
  `score` int(0) NOT NULL DEFAULT 0 COMMENT '总得分',
  `review_status` tinyint(0) NOT NULL DEFAULT 0 COMMENT '批改状态: 0待批改 1已批改',
  `review_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批改评语',
  `submitted_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '提交时间',
  `reviewed_at` datetime(0) NULL DEFAULT NULL COMMENT '批改时间',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_task_submission_member_attempt`(`task_id`, `member_id`, `attempt_no`) USING BTREE,
  INDEX `idx_task_submission_member`(`member_id`) USING BTREE,
  INDEX `idx_task_submission_review_status`(`review_status`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '考试/作业提交记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of task_submission
-- ----------------------------

-- ----------------------------
-- Table structure for teacher
-- ----------------------------
DROP TABLE IF EXISTS `teacher`;
CREATE TABLE `teacher`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `login_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '教师登录账号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '教师登录密码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '教师姓名',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '职称',
  `intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '讲师简介',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像地址',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0停用 1启用',
  `last_login_at` datetime(0) NULL DEFAULT NULL COMMENT '最后登录时间',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  `deleted` tinyint(0) NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0否 1是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_teacher_login_name`(`login_name`) USING BTREE,
  UNIQUE INDEX `uk_teacher_mobile`(`mobile`) USING BTREE,
  UNIQUE INDEX `uk_teacher_email`(`email`) USING BTREE,
  INDEX `idx_teacher_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '教师表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teacher
-- ----------------------------
INSERT INTO `teacher` VALUES (1, 'teacher_li', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '李老师', '高级讲师', '主讲 Java 后端开发与 Spring Boot 实战。', 'https://cdn.edu.com/avatar/teacher-1.png', '13900000001', 'li.teacher@edu.com', 1, NULL, '2026-06-04 10:11:23', '2026-06-04 10:11:23', 1, 1, 0);
INSERT INTO `teacher` VALUES (2, 'teacher_wang', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '王老师', '前端讲师', '主讲 Vue 3、工程化与前端项目实战。', 'https://cdn.edu.com/avatar/teacher-2.png', '13900000002', 'wang.teacher@edu.com', 1, NULL, '2026-06-04 10:11:23', '2026-06-04 10:11:23', 1, 1, 0);

SET FOREIGN_KEY_CHECKS = 1;
