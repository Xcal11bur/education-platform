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

 Date: 17/06/2026 12:35:02
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
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_admin_user_username`(`username`) USING BTREE,
  UNIQUE INDEX `uk_admin_user_mobile`(`mobile`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '后台管理员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin_user
-- ----------------------------
INSERT INTO `admin_user` VALUES (1, 'admin', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '系统管理员', '13800000001', 'admin@edu.com', 1, '2026-06-04 10:11:11', '2026-06-04 10:11:11', 0, 0);

-- ----------------------------
-- Table structure for community_comment
-- ----------------------------
DROP TABLE IF EXISTS `community_comment`;
CREATE TABLE `community_comment`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `post_id` bigint(0) UNSIGNED NOT NULL COMMENT '帖子ID',
  `member_id` bigint(0) UNSIGNED NOT NULL COMMENT '评论会员ID',
  `parent_id` bigint(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '父评论ID，一级评论为0',
  `reply_to_member_id` bigint(0) UNSIGNED NULL DEFAULT NULL COMMENT '被回复会员ID',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0隐藏 1显示',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_community_comment_post_id_parent_id_created_at`(`post_id`, `parent_id`, `created_at`) USING BTREE,
  INDEX `idx_community_comment_member_id_created_at`(`member_id`, `created_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of community_comment
-- ----------------------------
INSERT INTO `community_comment` VALUES (1, 1, 2, 0, NULL, '这个模块先把基础互动打通很合理，后面再慢慢丰富。', 1, '2026-06-10 10:12:00', '2026-06-10 10:12:00', 0, 0);
INSERT INTO `community_comment` VALUES (2, 1, 3, 0, NULL, '详情页右侧评论单独滚动的交互挺顺手，阅读和回复不会互相打断。', 1, '2026-06-10 10:18:00', '2026-06-10 10:18:00', 0, 0);
INSERT INTO `community_comment` VALUES (3, 1, 1, 1, 2, '第一版先控制复杂度，后续再补更多能力。', 1, '2026-06-10 10:22:00', '2026-06-10 10:22:00', 0, 0);
INSERT INTO `community_comment` VALUES (4, 2, 4, 0, NULL, '如果后面能把课程学习和讨论串起来，使用频率会更高。', 1, '2026-06-10 10:28:00', '2026-06-10 10:28:00', 0, 0);
INSERT INTO `community_comment` VALUES (5, 4, 1, 0, NULL, '111', 1, '2026-06-10 11:53:13', '2026-06-10 11:53:13', 0, 0);
INSERT INTO `community_comment` VALUES (6, 5, 3, 0, NULL, '这个入口很有必要，用户学完内容后立刻讨论，参与率会高很多。', 1, '2026-06-10 12:18:00', '2026-06-10 12:18:00', 0, 0);
INSERT INTO `community_comment` VALUES (7, 5, 1, 6, 3, '我也这么觉得，至少提问链路顺了很多。', 1, '2026-06-10 12:21:00', '2026-06-10 12:21:00', 0, 0);
INSERT INTO `community_comment` VALUES (8, 6, 4, 0, NULL, '长帖如果能沉淀到课程章节下面，后面复用价值会很高。', 1, '2026-06-10 12:31:00', '2026-06-10 12:31:00', 0, 0);
INSERT INTO `community_comment` VALUES (9, 6, 2, 8, 4, '是的，特别适合总结类和踩坑类内容。', 1, '2026-06-10 12:34:00', '2026-06-10 12:34:00', 0, 0);
INSERT INTO `community_comment` VALUES (10, 6, 5, 0, NULL, '希望后面还能支持老师置顶高质量回复。', 1, '2026-06-10 12:38:00', '2026-06-10 12:38:00', 0, 0);
INSERT INTO `community_comment` VALUES (11, 7, 6, 0, NULL, '我更想先看我的帖子，方便回看自己发过什么。', 1, '2026-06-10 12:45:00', '2026-06-10 12:45:00', 0, 0);
INSERT INTO `community_comment` VALUES (12, 7, 1, 11, 6, '同意，消息提醒可以放第二阶段。', 1, '2026-06-10 12:47:00', '2026-06-10 12:47:00', 0, 0);
INSERT INTO `community_comment` VALUES (13, 8, 7, 0, NULL, '打卡类帖子很适合做成周报汇总。', 1, '2026-06-10 13:12:00', '2026-06-10 13:12:00', 0, 0);
INSERT INTO `community_comment` VALUES (14, 9, 8, 0, NULL, '这条长帖刚好可以验证收藏页、详情页和评论区在长内容下的稳定性。', 1, '2026-06-10 13:33:00', '2026-06-10 13:33:00', 0, 0);
INSERT INTO `community_comment` VALUES (15, 9, 1, 14, 8, '对，这类数据比较适合回归测试。', 1, '2026-06-10 13:36:00', '2026-06-10 13:36:00', 0, 0);
INSERT INTO `community_comment` VALUES (16, 1, 1, 0, NULL, '123', 1, '2026-06-10 12:15:42', '2026-06-10 12:15:42', 0, 0);

-- ----------------------------
-- Table structure for community_post
-- ----------------------------
DROP TABLE IF EXISTS `community_post`;
CREATE TABLE `community_post`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `member_id` bigint(0) UNSIGNED NOT NULL COMMENT '发帖会员ID',
  `title` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '帖子标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '帖子正文',
  `status` tinyint(0) NOT NULL DEFAULT 1 COMMENT '状态: 0待审核 1已发布 2已删除',
  `comment_count` int(0) NOT NULL DEFAULT 0 COMMENT '评论数',
  `like_count` int(0) NOT NULL DEFAULT 0 COMMENT '点赞数',
  `favorite_count` int(0) NOT NULL DEFAULT 0 COMMENT '收藏数',
  `view_count` int(0) NOT NULL DEFAULT 0 COMMENT '浏览数',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_community_post_status_created_at`(`status`, `created_at`) USING BTREE,
  INDEX `idx_community_post_status_hot`(`status`, `like_count`, `comment_count`, `created_at`) USING BTREE,
  INDEX `idx_community_post_member_id_created_at`(`member_id`, `created_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区帖子表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of community_post
-- ----------------------------
INSERT INTO `community_post` VALUES (1, 1, '交流社区第一版已上线', '第一阶段先把发帖、评论、点赞、收藏打通。后续还会继续补充内容治理和更完整的互动体验。', 1, 4, 3, 2, 37, '2026-06-10 10:05:00', '2026-06-10 10:41:40', 0, 0);
INSERT INTO `community_post` VALUES (2, 2, '今天学完课程后有什么收获？', '欢迎大家在这里分享最近学到的知识点，也可以说说你希望社区后续增加什么能力。', 1, 1, 0, 0, 20, '2026-06-10 10:20:00', '2026-06-10 10:20:00', 0, 0);
INSERT INTO `community_post` VALUES (3, 3, '课程学习和交流社区可以怎么联动？', '比如学完一个章节后直接跳转到讨论区，或者给课程关联专题帖。这个方向后面可以继续迭代。', 1, 0, 0, 0, 16, '2026-06-10 10:40:00', '2026-06-10 10:40:00', 0, 0);
INSERT INTO `community_post` VALUES (4, 1, 'test', 'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww\n\nwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww\nwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww', 1, 1, 0, 0, 17, '2026-06-10 11:47:03', '2026-06-10 11:47:03', 0, 0);
INSERT INTO `community_post` VALUES (5, 2, '今天把章节学习页和社区入口串起来了', '短帖测试：学完内容后能直接进入讨论区，这样提问和复盘的链路顺很多。', 1, 2, 0, 0, 5, '2026-06-10 12:10:00', '2026-06-10 12:07:37', 0, 0);
INSERT INTO `community_post` VALUES (6, 3, '关于课程讨论区的一点想法', '这是一条长帖测试，用来验证详情页、列表摘要、个人收藏和评论区在正文较长时的展示稳定性。\n\n如果学习平台后续继续迭代，我更希望讨论区不仅能承接“吐槽”或者“闲聊”，还应该变成课程学习过程中的问题沉淀区。比如：每节课下方自动生成讨论串，老师可以置顶高质量回答，学员可以把自己的实操截图、踩坑记录、补充资料贴进来，后面的同学再遇到相同问题时，就不需要反复问一遍。\n\n另外，长帖也能承担复盘和总结作用。有人学完一门课后，会愿意写一篇自己的理解、实践过程和结果对比，这类内容其实比零碎评论更有价值。只要页面在长文本、换行、超长单词、连续字符、图片混排这些场景下都不溢出，体验就会稳定很多。', 1, 3, 3, 1, 15, '2026-06-10 12:26:00', '2026-06-10 12:07:37', 0, 0);
INSERT INTO `community_post` VALUES (7, 4, '短问题：大家更想先补“我的帖子”还是“消息提醒”？', '我个人更偏向先做我的帖子，这样内容回看会更完整。', 1, 2, 1, 0, 5, '2026-06-10 12:40:00', '2026-06-10 12:07:37', 0, 0);
INSERT INTO `community_post` VALUES (8, 5, '这周学习计划打卡', '本周准备把 Spring Boot 实战课和高效沟通方法课各推进两个章节。\n\n如果晚上能把作业也顺手做完，就来社区发一篇阶段复盘。', 1, 1, 1, 0, 16, '2026-06-10 13:05:00', '2026-06-10 12:07:37', 0, 0);
INSERT INTO `community_post` VALUES (9, 6, '长内容稳定性专项测试', '为了验证页面在极端情况下的稳定性，这里放一条偏长正文。正文里会包含多段换行、较长的叙述，以及一些用于观察换行效果的连续短句。\n\n第一段主要看段间距是否自然。第二段主要看右侧评论区 sticky 时，左侧帖子内容继续向下延展是否会把布局拉坏。第三段则用于观察当用户收藏这类帖子后，个人中心里的“我的收藏”列表是否还能保持一致的展示密度。\n\n如果这些都正常，说明第一阶段的社区骨架已经基本够用了，后面可以把重点转去内容质量、筛选能力和通知能力。', 1, 2, 0, 0, 15, '2026-06-10 13:26:00', '2026-06-10 12:07:37', 0, 0);

-- ----------------------------
-- Table structure for community_post_action
-- ----------------------------
DROP TABLE IF EXISTS `community_post_action`;
CREATE TABLE `community_post_action`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `post_id` bigint(0) UNSIGNED NOT NULL COMMENT '帖子ID',
  `member_id` bigint(0) UNSIGNED NOT NULL COMMENT '会员ID',
  `action_type` tinyint(0) NOT NULL COMMENT '行为类型: 1点赞 2收藏',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_community_post_action`(`post_id`, `member_id`, `action_type`) USING BTREE,
  INDEX `idx_community_post_action_member_id_action_type_created_at`(`member_id`, `action_type`, `created_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区帖子互动行为表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of community_post_action
-- ----------------------------
INSERT INTO `community_post_action` VALUES (2, 1, 3, 1, '2026-06-10 10:13:00', '2026-06-10 10:13:00', 0, 0);
INSERT INTO `community_post_action` VALUES (7, 1, 2, 1, '2026-06-10 10:11:00', '2026-06-10 10:11:00', 0, 0);
INSERT INTO `community_post_action` VALUES (8, 1, 2, 2, '2026-06-10 10:14:00', '2026-06-10 10:14:00', 0, 0);
INSERT INTO `community_post_action` VALUES (12, 6, 2, 1, '2026-06-10 12:42:00', '2026-06-10 12:42:00', 0, 0);
INSERT INTO `community_post_action` VALUES (13, 6, 3, 1, '2026-06-10 12:43:00', '2026-06-10 12:43:00', 0, 0);
INSERT INTO `community_post_action` VALUES (14, 7, 1, 1, '2026-06-10 12:49:00', '2026-06-10 12:49:00', 0, 0);
INSERT INTO `community_post_action` VALUES (15, 8, 1, 1, '2026-06-10 13:14:00', '2026-06-10 13:14:00', 0, 0);
INSERT INTO `community_post_action` VALUES (17, 6, 1, 2, '2026-06-10 12:23:10', '2026-06-10 12:23:10', 0, 0);
INSERT INTO `community_post_action` VALUES (18, 6, 1, 1, '2026-06-10 12:23:12', '2026-06-10 12:23:12', 0, 0);
INSERT INTO `community_post_action` VALUES (19, 1, 1, 1, '2026-06-10 12:30:34', '2026-06-10 12:30:34', 0, 0);
INSERT INTO `community_post_action` VALUES (20, 1, 1, 2, '2026-06-10 12:30:35', '2026-06-10 12:30:35', 0, 0);

-- ----------------------------
-- Table structure for community_post_image
-- ----------------------------
DROP TABLE IF EXISTS `community_post_image`;
CREATE TABLE `community_post_image`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `post_id` bigint(0) UNSIGNED NOT NULL COMMENT '帖子ID',
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片地址',
  `sort` int(0) NOT NULL DEFAULT 0 COMMENT '排序值',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_community_post_image_post_id_sort`(`post_id`, `sort`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区帖子图片表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of community_post_image
-- ----------------------------
INSERT INTO `community_post_image` VALUES (1, 1, 'https://images.unsplash.com/photo-1541746972996-4e0b0f43e02a?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', 1, '2026-06-10 10:05:00', '2026-06-10 10:05:00', 0, 0);
INSERT INTO `community_post_image` VALUES (2, 2, 'https://images.unsplash.com/photo-1759884247231-24a9d8f6d454?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', 1, '2026-06-10 10:20:00', '2026-06-10 10:20:00', 0, 0);
INSERT INTO `community_post_image` VALUES (3, 2, 'https://images.unsplash.com/photo-1758518731814-50848c31d1ae?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', 2, '2026-06-10 10:20:00', '2026-06-10 10:20:00', 0, 0);
INSERT INTO `community_post_image` VALUES (4, 5, 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&fm=jpg&q=60&w=1600', 1, '2026-06-10 12:10:00', '2026-06-10 12:10:00', 0, 0);
INSERT INTO `community_post_image` VALUES (5, 6, 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&fm=jpg&q=60&w=1600', 1, '2026-06-10 12:26:00', '2026-06-10 12:26:00', 0, 0);
INSERT INTO `community_post_image` VALUES (6, 8, 'https://images.unsplash.com/photo-1501504905252-473c47e087f8?auto=format&fit=crop&fm=jpg&q=60&w=1600', 1, '2026-06-10 13:05:00', '2026-06-10 13:05:00', 0, 0);

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
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_teacher`(`teacher_id`) USING BTREE,
  INDEX `idx_course_category1`(`category_level1_id`) USING BTREE,
  INDEX `idx_course_category2`(`category_level2_id`) USING BTREE,
  INDEX `idx_course_publish_status`(`publish_status`) USING BTREE,
  INDEX `idx_course_sort`(`sort`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程基本信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course
-- ----------------------------
INSERT INTO `course` VALUES (1, '企业文化导论', '快速了解企业文化与价值理念', 1, 1, 3, 'https://images.unsplash.com/photo-1541746972996-4e0b0f43e02a?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '帮助新学员系统了解企业发展历程、核心文化与工作方式。', 1, 0.00, 1, 52, 160, '2026-06-04 10:11:58', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (2, '价值观场景实践', '用真实业务案例理解企业价值观', 2, 1, 3, 'https://images.unsplash.com/photo-1759884247231-24a9d8f6d454?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '围绕项目协作、客户服务与执行交付梳理价值观在业务中的应用。', 1, 0.00, 1, 48, 158, '2026-06-04 10:11:58', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (3, '高效沟通方法课', '强化跨部门协同和沟通表达', 1, 1, 4, 'https://images.unsplash.com/photo-1758518731814-50848c31d1ae?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '围绕会议沟通、信息同步和问题反馈建立高效协作机制。', 1, 0.00, 1, 44, 156, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (4, '项目协同作战训练', '掌握跨团队配合的关键动作', 2, 1, 4, 'https://images.unsplash.com/photo-1758873269811-4e62e346b4b7?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '覆盖项目启动、角色分工、风险同步与复盘协同等核心场景。', 2, 69.00, 1, 40, 154, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (5, '云原生基础入门', '理解容器、镜像与集群基础概念', 1, 2, 7, 'https://images.unsplash.com/vector-1761074651005-97a2e57eef29?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '帮助学员建立云原生技术体系认知，适合作为平台学习起点。', 1, 99.00, 1, 36, 152, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (6, '容器化部署实训', '从开发到部署的实战演练', 2, 2, 7, 'https://images.unsplash.com/photo-1667264501379-c1537934c7ab?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '聚焦镜像打包、环境发布和服务巡检等典型工作任务。', 2, 129.00, 1, 33, 150, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (7, '平台交付流程实训', '掌握平台项目交付全流程', 1, 2, 8, 'https://images.unsplash.com/vector-1761645078994-e7aa36f349a8?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '通过典型案例覆盖需求理解、方案设计、交付验收到运维支持。', 2, 149.00, 1, 30, 148, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (8, '运维规范与值守实战', '建立平台运维与响应机制', 2, 2, 8, 'https://images.unsplash.com/photo-1680992046626-418f7e910589?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '学习告警处理、变更管理、日常巡检与故障复盘等运维规范。', 2, 119.00, 1, 27, 146, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (9, '数据分析基础', '掌握指标拆解与报表分析', 1, 5, 9, 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '以业务数据分析为主线，帮助学员建立数据思维与分析框架。', 1, 89.00, 1, 24, 144, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (10, '经营数据看板实战', '从指标体系到可视化展示', 2, 5, 9, 'https://images.unsplash.com/photo-1763038311036-6d18805537e5?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '结合真实场景构建数据看板，完成从数据处理到结果呈现的闭环。', 2, 129.00, 1, 21, 142, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (11, '数据治理规范课', '构建主数据与数据质量意识', 1, 5, 10, 'https://images.unsplash.com/photo-1763568258367-1c52beb60be7?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '覆盖数据标准、口径统一、质量校验与权限治理等核心议题。', 2, 99.00, 1, 18, 140, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (12, '数据资产运营训练营', '提升数据应用与资产沉淀能力', 2, 5, 10, 'https://images.unsplash.com/photo-1774600122432-dfddc9987ff8?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '从资产目录、治理流程到运营复盘，系统提升数据资产管理能力。', 2, 139.00, 1, 15, 138, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (13, '新员工入职第一课', '快速融入团队与岗位角色', 1, 6, 11, 'https://images.unsplash.com/photo-1752651881400-ae82bc9ad5fa?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '围绕制度认知、工作流程和团队协作，帮助学员快速进入工作状态。', 1, 0.00, 1, 12, 136, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (14, '岗位能力成长地图', '明确不同阶段的能力提升路径', 2, 6, 11, 'https://images.unsplash.com/photo-1758691736433-4078b93abd72?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '结合岗位模型和成长路径，帮助学员识别短板并制定学习计划。', 1, 59.00, 1, 9, 134, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (15, '基层管理者进阶课', '从执行骨干到团队管理者', 1, 6, 12, 'https://images.unsplash.com/photo-1551836022-aadb801c60ae?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '聚焦目标拆解、团队带教、过程辅导与结果复盘等管理关键动作。', 2, 129.00, 1, 6, 132, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);
INSERT INTO `course` VALUES (16, '绩效辅导与团队激励', '建立持续反馈与激励机制', 2, 6, 12, 'https://images.unsplash.com/photo-1752651881400-ae82bc9ad5fa?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000', '围绕绩效沟通、目标跟进和正向激励提升团队执行与成长效率。', 2, 149.00, 1, 3, 130, '2026-06-05 14:29:53', '2026-06-09 23:14:22', 1, 1);

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
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_banner_course`(`course_id`) USING BTREE,
  INDEX `idx_course_banner_status_sort`(`status`, `sort`, `id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程轮播图配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_banner
-- ----------------------------
INSERT INTO `course_banner` VALUES (2, 5, '云原生基础入门', '理解容器、镜像与集群基础概念', 30, 1, '2026-06-06 18:16:13', '2026-06-06 18:16:13', 1, 1);
INSERT INTO `course_banner` VALUES (4, 15, '基层管理者进阶课', '从执行骨干到团队管理者', 10, 1, '2026-06-06 18:16:14', '2026-06-06 18:18:35', 1, 0);
INSERT INTO `course_banner` VALUES (6, 2, '', '', 41, 1, '2026-06-08 19:29:26', '2026-06-08 19:29:26', 0, 0);
INSERT INTO `course_banner` VALUES (9, 16, '', '', 43, 1, '2026-06-09 19:03:15', '2026-06-09 19:03:15', 0, 0);

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
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_category_parent_name`(`parent_id`, `name`) USING BTREE,
  INDEX `idx_course_category_parent`(`parent_id`) USING BTREE,
  INDEX `idx_course_category_level_status`(`level`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_category
-- ----------------------------
INSERT INTO `course_category` VALUES (1, 0, '企业文化', 1, 1, 1, '2026-06-04 10:11:33', '2026-06-05 14:28:41', 1, 1);
INSERT INTO `course_category` VALUES (2, 0, '锐道云', 1, 2, 1, '2026-06-04 10:11:33', '2026-06-05 14:28:41', 1, 1);
INSERT INTO `course_category` VALUES (3, 1, '企业价值观', 2, 1, 1, '2026-06-04 10:11:33', '2026-06-05 14:28:41', 1, 1);
INSERT INTO `course_category` VALUES (4, 1, '组织协同', 2, 2, 1, '2026-06-04 10:11:33', '2026-06-05 14:28:41', 1, 1);
INSERT INTO `course_category` VALUES (5, 0, '云计算&大数据', 1, 3, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1);
INSERT INTO `course_category` VALUES (6, 0, '人力资源管理', 1, 4, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1);
INSERT INTO `course_category` VALUES (7, 2, '云原生基础', 2, 1, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1);
INSERT INTO `course_category` VALUES (8, 2, '平台实战', 2, 2, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1);
INSERT INTO `course_category` VALUES (9, 5, '数据分析', 2, 1, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1);
INSERT INTO `course_category` VALUES (10, 5, '数据治理', 2, 2, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1);
INSERT INTO `course_category` VALUES (11, 6, '入职培养', 2, 1, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1);
INSERT INTO `course_category` VALUES (12, 6, '管理进阶', 2, 2, 1, '2026-06-05 14:29:52', '2026-06-05 14:29:52', 1, 1);

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
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_chapter_course`(`course_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程章节表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_chapter
-- ----------------------------
INSERT INTO `course_chapter` VALUES (1, 1, '第一章：企业文化基础入门', 1, '2026-06-04 10:12:07', '2026-06-04 10:12:07', 1, 1);
INSERT INTO `course_chapter` VALUES (2, 2, '第一章：价值判断基础', 1, '2026-06-04 10:12:07', '2026-06-06 19:15:23', 1, 1);
INSERT INTO `course_chapter` VALUES (3, 1, '第二章：核心价值观解读', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (4, 1, '第三章：组织行为与文化案例', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (5, 1, '第四章：文化落地行动清单', 4, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (6, 2, '第二章：客户场景中的价值判断', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (7, 2, '第三章：协作冲突与决策取舍', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (8, 2, '第四章：复盘与行为改进', 4, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (9, 3, '第一章：沟通底层逻辑', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (10, 3, '第二章：向上与跨部门沟通', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (11, 3, '第三章：会议表达与反馈技巧', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (12, 4, '第一章：项目协同角色分工', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (13, 4, '第二章：进度同步与风险处理', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (14, 4, '第三章：跨团队交付复盘', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (15, 5, '第一章：云原生概念总览', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (16, 5, '第二章：容器与镜像基础', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (17, 5, '第三章：集群与服务治理入门', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (18, 6, '第一章：应用容器化准备', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (19, 6, '第二章：镜像构建与仓库管理', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (20, 6, '第三章：部署发布与问题排查', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (21, 7, '第一章：平台交付流程概览', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (22, 7, '第二章：需求评审与环境准备', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (23, 7, '第三章：验收交付与总结复盘', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (24, 8, '第一章：运维值守基本规范', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (25, 8, '第二章：告警响应与故障升级', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (26, 8, '第三章：巡检制度与应急演练', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (27, 9, '第一章：指标认知与数据口径', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (28, 9, '第二章：基础分析方法', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (29, 9, '第三章：报表解读与结论输出', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (30, 10, '第一章：看板目标与受众定义', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (31, 10, '第二章：指标体系设计', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (32, 10, '第三章：可视化呈现与迭代优化', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (33, 11, '第一章：数据治理核心原则', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (34, 11, '第二章：主数据与质量管理', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (35, 11, '第三章：治理机制与职责协同', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (36, 12, '第一章：数据资产盘点方法', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (38, 12, '第三章：资产沉淀与价值评估', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (39, 13, '第一章：公司制度与角色认知', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (40, 13, '第二章：团队协作与工作流程', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (41, 13, '第三章：试用期目标与成长建议', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (42, 14, '第一章：岗位能力模型解析', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (43, 14, '第二章：阶段性成长目标设定', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (44, 14, '第三章：学习路径与行动计划', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (45, 15, '第一章：管理者角色转换', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (46, 15, '第二章：目标管理与任务分配', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (47, 15, '第三章：团队带教与过程复盘', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (48, 16, '第一章：绩效沟通基础', 1, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (49, 16, '第二章：一对一辅导技巧', 2, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);
INSERT INTO `course_chapter` VALUES (50, 16, '第三章：激励机制与团队氛围建设', 3, '2026-06-06 17:54:45', '2026-06-06 17:54:45', 1, 1);

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
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_enrollment_member_course`(`member_id`, `course_id`) USING BTREE,
  INDEX `idx_course_enrollment_course`(`course_id`) USING BTREE,
  INDEX `idx_course_enrollment_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 774 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程报名/学习关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_enrollment
-- ----------------------------
INSERT INTO `course_enrollment` VALUES (263, 1, 1, 1, 'BATCH-1-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (264, 2, 2, 1, 'BATCH-2-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (265, 1, 2, 1, 'BATCH-2-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (266, 3, 3, 1, 'BATCH-3-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (267, 2, 3, 1, 'BATCH-3-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (268, 1, 3, 1, 'BATCH-3-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (269, 4, 4, 1, 'BATCH-4-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (270, 3, 4, 1, 'BATCH-4-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (271, 2, 4, 1, 'BATCH-4-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (272, 1, 4, 1, 'BATCH-4-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (273, 5, 5, 1, 'BATCH-5-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (274, 4, 5, 1, 'BATCH-5-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (275, 3, 5, 1, 'BATCH-5-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (276, 2, 5, 1, 'BATCH-5-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (277, 1, 5, 1, 'BATCH-5-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (278, 6, 6, 1, 'BATCH-6-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (279, 5, 6, 1, 'BATCH-6-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (280, 4, 6, 1, 'BATCH-6-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (281, 3, 6, 1, 'BATCH-6-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (282, 2, 6, 1, 'BATCH-6-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (283, 1, 6, 1, 'BATCH-6-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (284, 7, 7, 1, 'BATCH-7-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (285, 6, 7, 1, 'BATCH-7-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (286, 5, 7, 1, 'BATCH-7-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (287, 4, 7, 1, 'BATCH-7-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (288, 3, 7, 1, 'BATCH-7-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (289, 2, 7, 1, 'BATCH-7-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (290, 1, 7, 1, 'BATCH-7-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (291, 8, 8, 1, 'BATCH-8-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (292, 7, 8, 1, 'BATCH-8-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (293, 6, 8, 1, 'BATCH-8-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (294, 5, 8, 1, 'BATCH-8-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (295, 4, 8, 1, 'BATCH-8-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (296, 3, 8, 1, 'BATCH-8-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (297, 2, 8, 1, 'BATCH-8-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (298, 1, 8, 1, 'BATCH-8-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (299, 9, 9, 1, 'BATCH-9-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (300, 8, 9, 1, 'BATCH-9-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (301, 7, 9, 1, 'BATCH-9-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (302, 6, 9, 1, 'BATCH-9-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (303, 5, 9, 1, 'BATCH-9-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (304, 4, 9, 1, 'BATCH-9-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (305, 3, 9, 1, 'BATCH-9-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (306, 2, 9, 1, 'BATCH-9-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (307, 1, 9, 1, 'BATCH-9-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (308, 10, 10, 1, 'BATCH-10-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (309, 9, 10, 1, 'BATCH-10-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (310, 8, 10, 1, 'BATCH-10-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (311, 7, 10, 1, 'BATCH-10-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (312, 6, 10, 1, 'BATCH-10-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (313, 5, 10, 1, 'BATCH-10-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (314, 4, 10, 1, 'BATCH-10-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (315, 3, 10, 1, 'BATCH-10-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (316, 2, 10, 1, 'BATCH-10-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (317, 1, 10, 1, 'BATCH-10-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (318, 11, 11, 1, 'BATCH-11-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (319, 10, 11, 1, 'BATCH-11-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (320, 9, 11, 1, 'BATCH-11-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (321, 8, 11, 1, 'BATCH-11-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (322, 7, 11, 1, 'BATCH-11-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (323, 6, 11, 1, 'BATCH-11-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (324, 5, 11, 1, 'BATCH-11-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (325, 4, 11, 1, 'BATCH-11-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (326, 3, 11, 1, 'BATCH-11-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (327, 2, 11, 1, 'BATCH-11-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (328, 1, 11, 1, 'BATCH-11-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (329, 12, 12, 1, 'BATCH-12-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (330, 11, 12, 1, 'BATCH-12-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (331, 10, 12, 1, 'BATCH-12-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (332, 9, 12, 1, 'BATCH-12-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (333, 8, 12, 1, 'BATCH-12-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (334, 7, 12, 1, 'BATCH-12-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (335, 6, 12, 1, 'BATCH-12-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (336, 5, 12, 1, 'BATCH-12-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (337, 4, 12, 1, 'BATCH-12-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (338, 3, 12, 1, 'BATCH-12-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (339, 2, 12, 1, 'BATCH-12-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (340, 1, 12, 1, 'BATCH-12-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (341, 13, 13, 1, 'BATCH-13-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (342, 12, 13, 1, 'BATCH-13-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (343, 11, 13, 1, 'BATCH-13-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (344, 10, 13, 1, 'BATCH-13-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (345, 9, 13, 1, 'BATCH-13-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (346, 8, 13, 1, 'BATCH-13-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (347, 7, 13, 1, 'BATCH-13-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (348, 6, 13, 1, 'BATCH-13-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (349, 5, 13, 1, 'BATCH-13-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (350, 4, 13, 1, 'BATCH-13-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (351, 3, 13, 1, 'BATCH-13-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (352, 2, 13, 1, 'BATCH-13-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (353, 1, 13, 1, 'BATCH-13-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (354, 14, 14, 1, 'BATCH-14-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (355, 13, 14, 1, 'BATCH-14-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (356, 12, 14, 1, 'BATCH-14-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (357, 11, 14, 1, 'BATCH-14-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (358, 10, 14, 1, 'BATCH-14-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (359, 9, 14, 1, 'BATCH-14-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (360, 8, 14, 1, 'BATCH-14-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (361, 7, 14, 1, 'BATCH-14-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (362, 6, 14, 1, 'BATCH-14-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (363, 5, 14, 1, 'BATCH-14-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (364, 4, 14, 1, 'BATCH-14-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (365, 3, 14, 1, 'BATCH-14-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (366, 2, 14, 1, 'BATCH-14-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (367, 1, 14, 1, 'BATCH-14-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (368, 15, 15, 1, 'BATCH-15-15', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (369, 14, 15, 1, 'BATCH-15-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (370, 13, 15, 1, 'BATCH-15-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (371, 12, 15, 1, 'BATCH-15-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (372, 11, 15, 1, 'BATCH-15-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (373, 10, 15, 1, 'BATCH-15-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (374, 9, 15, 1, 'BATCH-15-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (375, 8, 15, 1, 'BATCH-15-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (376, 7, 15, 1, 'BATCH-15-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (377, 6, 15, 1, 'BATCH-15-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (378, 5, 15, 1, 'BATCH-15-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (379, 4, 15, 1, 'BATCH-15-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (380, 3, 15, 1, 'BATCH-15-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (381, 2, 15, 1, 'BATCH-15-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (382, 1, 15, 1, 'BATCH-15-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (383, 16, 16, 1, 'BATCH-16-16', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (384, 15, 16, 1, 'BATCH-16-15', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (385, 14, 16, 1, 'BATCH-16-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (386, 13, 16, 1, 'BATCH-16-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (387, 12, 16, 1, 'BATCH-16-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (388, 11, 16, 1, 'BATCH-16-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (389, 10, 16, 1, 'BATCH-16-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (390, 9, 16, 1, 'BATCH-16-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (391, 8, 16, 1, 'BATCH-16-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (392, 7, 16, 1, 'BATCH-16-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (393, 6, 16, 1, 'BATCH-16-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (394, 5, 16, 1, 'BATCH-16-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (395, 4, 16, 1, 'BATCH-16-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (396, 3, 16, 1, 'BATCH-16-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (397, 2, 16, 1, 'BATCH-16-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (398, 1, 16, 1, 'BATCH-16-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (399, 1, 17, 1, 'BATCH-17-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (400, 2, 18, 1, 'BATCH-18-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (401, 1, 18, 1, 'BATCH-18-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (402, 3, 19, 1, 'BATCH-19-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (403, 2, 19, 1, 'BATCH-19-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (404, 1, 19, 1, 'BATCH-19-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (405, 4, 20, 1, 'BATCH-20-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (406, 3, 20, 1, 'BATCH-20-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (407, 2, 20, 1, 'BATCH-20-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (408, 1, 20, 1, 'BATCH-20-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (409, 5, 21, 1, 'BATCH-21-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (410, 4, 21, 1, 'BATCH-21-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (411, 3, 21, 1, 'BATCH-21-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (412, 2, 21, 1, 'BATCH-21-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (413, 1, 21, 1, 'BATCH-21-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (414, 6, 22, 1, 'BATCH-22-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (415, 5, 22, 1, 'BATCH-22-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (416, 4, 22, 1, 'BATCH-22-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (417, 3, 22, 1, 'BATCH-22-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (418, 2, 22, 1, 'BATCH-22-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (419, 1, 22, 1, 'BATCH-22-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (420, 7, 23, 1, 'BATCH-23-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (421, 6, 23, 1, 'BATCH-23-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (422, 5, 23, 1, 'BATCH-23-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (423, 4, 23, 1, 'BATCH-23-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (424, 3, 23, 1, 'BATCH-23-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (425, 2, 23, 1, 'BATCH-23-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (426, 1, 23, 1, 'BATCH-23-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (427, 8, 24, 1, 'BATCH-24-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (428, 7, 24, 1, 'BATCH-24-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (429, 6, 24, 1, 'BATCH-24-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (430, 5, 24, 1, 'BATCH-24-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (431, 4, 24, 1, 'BATCH-24-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (432, 3, 24, 1, 'BATCH-24-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (433, 2, 24, 1, 'BATCH-24-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (434, 1, 24, 1, 'BATCH-24-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (435, 9, 25, 1, 'BATCH-25-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (436, 8, 25, 1, 'BATCH-25-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (437, 7, 25, 1, 'BATCH-25-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (438, 6, 25, 1, 'BATCH-25-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (439, 5, 25, 1, 'BATCH-25-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (440, 4, 25, 1, 'BATCH-25-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (441, 3, 25, 1, 'BATCH-25-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (442, 2, 25, 1, 'BATCH-25-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (443, 1, 25, 1, 'BATCH-25-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (444, 10, 26, 1, 'BATCH-26-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (445, 9, 26, 1, 'BATCH-26-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (446, 8, 26, 1, 'BATCH-26-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (447, 7, 26, 1, 'BATCH-26-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (448, 6, 26, 1, 'BATCH-26-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (449, 5, 26, 1, 'BATCH-26-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (450, 4, 26, 1, 'BATCH-26-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (451, 3, 26, 1, 'BATCH-26-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (452, 2, 26, 1, 'BATCH-26-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (453, 1, 26, 1, 'BATCH-26-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (454, 11, 27, 1, 'BATCH-27-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (455, 10, 27, 1, 'BATCH-27-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (456, 9, 27, 1, 'BATCH-27-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (457, 8, 27, 1, 'BATCH-27-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (458, 7, 27, 1, 'BATCH-27-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (459, 6, 27, 1, 'BATCH-27-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (460, 5, 27, 1, 'BATCH-27-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (461, 4, 27, 1, 'BATCH-27-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (462, 3, 27, 1, 'BATCH-27-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (463, 2, 27, 1, 'BATCH-27-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (464, 1, 27, 1, 'BATCH-27-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (465, 12, 28, 1, 'BATCH-28-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (466, 11, 28, 1, 'BATCH-28-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (467, 10, 28, 1, 'BATCH-28-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (468, 9, 28, 1, 'BATCH-28-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (469, 8, 28, 1, 'BATCH-28-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (470, 7, 28, 1, 'BATCH-28-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (471, 6, 28, 1, 'BATCH-28-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (472, 5, 28, 1, 'BATCH-28-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (473, 4, 28, 1, 'BATCH-28-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (474, 3, 28, 1, 'BATCH-28-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (475, 2, 28, 1, 'BATCH-28-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (476, 1, 28, 1, 'BATCH-28-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (477, 13, 29, 1, 'BATCH-29-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (478, 12, 29, 1, 'BATCH-29-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (479, 11, 29, 1, 'BATCH-29-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (480, 10, 29, 1, 'BATCH-29-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (481, 9, 29, 1, 'BATCH-29-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (482, 8, 29, 1, 'BATCH-29-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (483, 7, 29, 1, 'BATCH-29-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (484, 6, 29, 1, 'BATCH-29-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (485, 5, 29, 1, 'BATCH-29-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (486, 4, 29, 1, 'BATCH-29-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (487, 3, 29, 1, 'BATCH-29-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (488, 2, 29, 1, 'BATCH-29-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (489, 1, 29, 1, 'BATCH-29-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (490, 14, 30, 1, 'BATCH-30-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (491, 13, 30, 1, 'BATCH-30-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (492, 12, 30, 1, 'BATCH-30-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (493, 11, 30, 1, 'BATCH-30-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (494, 10, 30, 1, 'BATCH-30-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (495, 9, 30, 1, 'BATCH-30-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (496, 8, 30, 1, 'BATCH-30-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (497, 7, 30, 1, 'BATCH-30-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (498, 6, 30, 1, 'BATCH-30-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (499, 5, 30, 1, 'BATCH-30-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (500, 4, 30, 1, 'BATCH-30-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (501, 3, 30, 1, 'BATCH-30-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (502, 2, 30, 1, 'BATCH-30-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (503, 1, 30, 1, 'BATCH-30-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (504, 15, 31, 1, 'BATCH-31-15', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (505, 14, 31, 1, 'BATCH-31-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (506, 13, 31, 1, 'BATCH-31-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (507, 12, 31, 1, 'BATCH-31-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (508, 11, 31, 1, 'BATCH-31-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (509, 10, 31, 1, 'BATCH-31-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (510, 9, 31, 1, 'BATCH-31-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (511, 8, 31, 1, 'BATCH-31-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (512, 7, 31, 1, 'BATCH-31-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (513, 6, 31, 1, 'BATCH-31-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (514, 5, 31, 1, 'BATCH-31-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (515, 4, 31, 1, 'BATCH-31-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (516, 3, 31, 1, 'BATCH-31-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (517, 2, 31, 1, 'BATCH-31-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (518, 1, 31, 1, 'BATCH-31-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (519, 16, 32, 1, 'BATCH-32-16', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (520, 15, 32, 1, 'BATCH-32-15', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (521, 14, 32, 1, 'BATCH-32-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (522, 13, 32, 1, 'BATCH-32-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (523, 12, 32, 1, 'BATCH-32-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (524, 11, 32, 1, 'BATCH-32-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (525, 10, 32, 1, 'BATCH-32-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (526, 9, 32, 1, 'BATCH-32-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (527, 8, 32, 1, 'BATCH-32-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (528, 7, 32, 1, 'BATCH-32-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (529, 6, 32, 1, 'BATCH-32-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (530, 5, 32, 1, 'BATCH-32-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (531, 4, 32, 1, 'BATCH-32-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (532, 3, 32, 1, 'BATCH-32-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (533, 2, 32, 1, 'BATCH-32-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (534, 1, 32, 1, 'BATCH-32-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (535, 1, 33, 1, 'BATCH-33-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (536, 2, 34, 1, 'BATCH-34-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (537, 1, 34, 1, 'BATCH-34-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (538, 3, 35, 1, 'BATCH-35-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (539, 2, 35, 1, 'BATCH-35-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (540, 1, 35, 1, 'BATCH-35-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (541, 4, 36, 1, 'BATCH-36-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (542, 3, 36, 1, 'BATCH-36-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (543, 2, 36, 1, 'BATCH-36-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (544, 1, 36, 1, 'BATCH-36-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (545, 5, 37, 1, 'BATCH-37-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (546, 4, 37, 1, 'BATCH-37-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (547, 3, 37, 1, 'BATCH-37-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (548, 2, 37, 1, 'BATCH-37-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (549, 1, 37, 1, 'BATCH-37-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (550, 6, 38, 1, 'BATCH-38-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (551, 5, 38, 1, 'BATCH-38-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (552, 4, 38, 1, 'BATCH-38-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (553, 3, 38, 1, 'BATCH-38-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (554, 2, 38, 1, 'BATCH-38-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (555, 1, 38, 1, 'BATCH-38-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (556, 7, 39, 1, 'BATCH-39-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (557, 6, 39, 1, 'BATCH-39-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (558, 5, 39, 1, 'BATCH-39-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (559, 4, 39, 1, 'BATCH-39-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (560, 3, 39, 1, 'BATCH-39-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (561, 2, 39, 1, 'BATCH-39-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (562, 1, 39, 1, 'BATCH-39-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (563, 8, 40, 1, 'BATCH-40-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (564, 7, 40, 1, 'BATCH-40-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (565, 6, 40, 1, 'BATCH-40-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (566, 5, 40, 1, 'BATCH-40-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (567, 4, 40, 1, 'BATCH-40-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (568, 3, 40, 1, 'BATCH-40-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (569, 2, 40, 1, 'BATCH-40-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (570, 1, 40, 1, 'BATCH-40-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (571, 9, 41, 1, 'BATCH-41-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (572, 8, 41, 1, 'BATCH-41-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (573, 7, 41, 1, 'BATCH-41-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (574, 6, 41, 1, 'BATCH-41-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (575, 5, 41, 1, 'BATCH-41-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (576, 4, 41, 1, 'BATCH-41-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (577, 3, 41, 1, 'BATCH-41-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (578, 2, 41, 1, 'BATCH-41-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (579, 1, 41, 1, 'BATCH-41-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (580, 10, 42, 1, 'BATCH-42-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (581, 9, 42, 1, 'BATCH-42-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (582, 8, 42, 1, 'BATCH-42-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (583, 7, 42, 1, 'BATCH-42-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (584, 6, 42, 1, 'BATCH-42-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (585, 5, 42, 1, 'BATCH-42-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (586, 4, 42, 1, 'BATCH-42-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (587, 3, 42, 1, 'BATCH-42-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (588, 2, 42, 1, 'BATCH-42-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (589, 1, 42, 1, 'BATCH-42-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (590, 11, 43, 1, 'BATCH-43-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (591, 10, 43, 1, 'BATCH-43-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (592, 9, 43, 1, 'BATCH-43-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (593, 8, 43, 1, 'BATCH-43-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (594, 7, 43, 1, 'BATCH-43-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (595, 6, 43, 1, 'BATCH-43-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (596, 5, 43, 1, 'BATCH-43-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (597, 4, 43, 1, 'BATCH-43-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (598, 3, 43, 1, 'BATCH-43-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (599, 2, 43, 1, 'BATCH-43-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (600, 1, 43, 1, 'BATCH-43-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (601, 12, 44, 1, 'BATCH-44-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (602, 11, 44, 1, 'BATCH-44-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (603, 10, 44, 1, 'BATCH-44-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (604, 9, 44, 1, 'BATCH-44-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (605, 8, 44, 1, 'BATCH-44-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (606, 7, 44, 1, 'BATCH-44-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (607, 6, 44, 1, 'BATCH-44-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (608, 5, 44, 1, 'BATCH-44-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (609, 4, 44, 1, 'BATCH-44-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (610, 3, 44, 1, 'BATCH-44-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (611, 2, 44, 1, 'BATCH-44-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (612, 1, 44, 1, 'BATCH-44-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (613, 13, 45, 1, 'BATCH-45-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (614, 12, 45, 1, 'BATCH-45-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (615, 11, 45, 1, 'BATCH-45-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (616, 10, 45, 1, 'BATCH-45-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (617, 9, 45, 1, 'BATCH-45-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (618, 8, 45, 1, 'BATCH-45-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (619, 7, 45, 1, 'BATCH-45-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (620, 6, 45, 1, 'BATCH-45-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (621, 5, 45, 1, 'BATCH-45-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (622, 4, 45, 1, 'BATCH-45-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (623, 3, 45, 1, 'BATCH-45-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (624, 2, 45, 1, 'BATCH-45-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (625, 1, 45, 1, 'BATCH-45-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (626, 14, 46, 1, 'BATCH-46-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (627, 13, 46, 1, 'BATCH-46-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (628, 12, 46, 1, 'BATCH-46-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (629, 11, 46, 1, 'BATCH-46-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (630, 10, 46, 1, 'BATCH-46-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (631, 9, 46, 1, 'BATCH-46-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (632, 8, 46, 1, 'BATCH-46-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (633, 7, 46, 1, 'BATCH-46-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (634, 6, 46, 1, 'BATCH-46-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (635, 5, 46, 1, 'BATCH-46-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (636, 4, 46, 1, 'BATCH-46-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (637, 3, 46, 1, 'BATCH-46-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (638, 2, 46, 1, 'BATCH-46-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (639, 1, 46, 1, 'BATCH-46-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (640, 15, 47, 1, 'BATCH-47-15', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (641, 14, 47, 1, 'BATCH-47-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (642, 13, 47, 1, 'BATCH-47-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (643, 12, 47, 1, 'BATCH-47-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (644, 11, 47, 1, 'BATCH-47-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (645, 10, 47, 1, 'BATCH-47-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (646, 9, 47, 1, 'BATCH-47-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (647, 8, 47, 1, 'BATCH-47-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (648, 7, 47, 1, 'BATCH-47-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (649, 6, 47, 1, 'BATCH-47-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (650, 5, 47, 1, 'BATCH-47-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (651, 4, 47, 1, 'BATCH-47-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (652, 3, 47, 1, 'BATCH-47-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (653, 2, 47, 1, 'BATCH-47-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (654, 1, 47, 1, 'BATCH-47-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (655, 16, 48, 1, 'BATCH-48-16', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (656, 15, 48, 1, 'BATCH-48-15', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (657, 14, 48, 1, 'BATCH-48-14', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (658, 13, 48, 1, 'BATCH-48-13', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (659, 12, 48, 1, 'BATCH-48-12', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (660, 11, 48, 1, 'BATCH-48-11', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (661, 10, 48, 1, 'BATCH-48-10', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (662, 9, 48, 1, 'BATCH-48-9', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (663, 8, 48, 1, 'BATCH-48-8', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (664, 7, 48, 1, 'BATCH-48-7', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (665, 6, 48, 1, 'BATCH-48-6', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (666, 5, 48, 1, 'BATCH-48-5', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (667, 4, 48, 1, 'BATCH-48-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (668, 3, 48, 1, 'BATCH-48-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (669, 2, 48, 1, 'BATCH-48-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (670, 1, 48, 1, 'BATCH-48-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (671, 1, 49, 1, 'BATCH-49-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (672, 2, 50, 1, 'BATCH-50-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (673, 1, 50, 1, 'BATCH-50-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (674, 3, 51, 1, 'BATCH-51-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (675, 2, 51, 1, 'BATCH-51-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (676, 1, 51, 1, 'BATCH-51-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (677, 4, 52, 1, 'BATCH-52-4', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (678, 3, 52, 1, 'BATCH-52-3', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (679, 2, 52, 1, 'BATCH-52-2', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);
INSERT INTO `course_enrollment` VALUES (680, 1, 52, 1, 'BATCH-52-1', 0.00, NULL, 1, '2027-06-09 23:14:20', '2026-06-09 23:14:20', '2026-06-09 23:14:20', 0, 0);

-- ----------------------------
-- Table structure for course_exam
-- ----------------------------
DROP TABLE IF EXISTS `course_exam`;
CREATE TABLE `course_exam`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT,
  `course_id` bigint(0) UNSIGNED NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `total_score` int(0) NOT NULL DEFAULT 100,
  `pass_score` int(0) NOT NULL DEFAULT 60,
  `start_time` datetime(0) NULL DEFAULT NULL,
  `end_time` datetime(0) NULL DEFAULT NULL,
  `duration_minutes` int(0) NOT NULL,
  `status` tinyint(0) NOT NULL DEFAULT 0,
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0,
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_exam_course_id`(`course_id`) USING BTREE,
  INDEX `idx_course_exam_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_exam
-- ----------------------------
INSERT INTO `course_exam` VALUES (9, 1, '测试考试-阶段测验1', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (10, 1, '测试考试-阶段测验2', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 60, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (11, 2, '测试考试-阶段测验1', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (12, 2, '测试考试-阶段测验2', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 60, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (13, 2, '测试考试-阶段测验3', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (14, 3, '测试考试-阶段测验1', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (15, 3, '测试考试-阶段测验2', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 60, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (16, 4, '测试考试-阶段测验1', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (17, 4, '测试考试-阶段测验2', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 60, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (18, 4, '测试考试-阶段测验3', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (19, 5, '测试考试-阶段测验1', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (20, 5, '测试考试-阶段测验2', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 60, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (21, 6, '测试考试-阶段测验1', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (22, 6, '测试考试-阶段测验2', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 60, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (23, 6, '测试考试-阶段测验3', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (24, 7, '测试考试-阶段测验1', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (25, 7, '测试考试-阶段测验2', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 60, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (26, 8, '测试考试-阶段测验1', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (27, 8, '测试考试-阶段测验2', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 60, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);
INSERT INTO `course_exam` VALUES (28, 8, '测试考试-阶段测验3', 20, 12, '2026-06-15 00:00:00', '2026-09-30 23:59:59', 45, 1, '2026-06-10 09:42:03', '2026-06-10 09:42:03', 0, 0);

-- ----------------------------
-- Table structure for course_favorite
-- ----------------------------
DROP TABLE IF EXISTS `course_favorite`;
CREATE TABLE `course_favorite`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `course_id` bigint(0) NOT NULL COMMENT '课程ID',
  `member_id` bigint(0) NOT NULL COMMENT '学员ID',
  `created_at` datetime(0) NULL DEFAULT NULL,
  `updated_at` datetime(0) NULL DEFAULT NULL,
  `created_by` bigint(0) NULL DEFAULT NULL,
  `updated_by` bigint(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_favorite_member_course`(`member_id`, `course_id`) USING BTREE,
  INDEX `idx_course_favorite_course`(`course_id`) USING BTREE,
  INDEX `idx_course_favorite_member`(`member_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程收藏' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_favorite
-- ----------------------------
INSERT INTO `course_favorite` VALUES (1, 1, 1, '2026-06-16 14:28:29', '2026-06-16 14:28:29', 0, 0);
INSERT INTO `course_favorite` VALUES (2, 2, 1, '2026-06-16 14:28:39', '2026-06-16 14:28:39', 0, 0);

-- ----------------------------
-- Table structure for course_homework
-- ----------------------------
DROP TABLE IF EXISTS `course_homework`;
CREATE TABLE `course_homework`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `course_id` bigint(0) UNSIGNED NOT NULL COMMENT '课程ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务标题',
  `total_score` int(0) NOT NULL DEFAULT 100 COMMENT '总分',
  `pass_score` int(0) NOT NULL DEFAULT 60 COMMENT '及格分',
  `start_time` datetime(0) NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '截止时间',
  `allow_retake_count` int(0) NOT NULL DEFAULT 1 COMMENT '允许提交次数',
  `status` tinyint(0) NOT NULL DEFAULT 0 COMMENT '状态: 0草稿 1发布 2关闭',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_task_course`(`course_id`) USING BTREE,
  INDEX `idx_course_task_type_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程考试/作业表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_homework
-- ----------------------------
INSERT INTO `course_homework` VALUES (6, 1, '测试作业-课后练习1', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (7, 1, '测试作业-课后练习2', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (8, 1, '测试作业-课后练习3', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (9, 1, '测试作业-课后练习4', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (10, 2, '测试作业-课后练习1', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (11, 2, '测试作业-课后练习2', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (12, 2, '测试作业-课后练习3', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (13, 3, '测试作业-课后练习1', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (14, 3, '测试作业-课后练习2', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (15, 3, '测试作业-课后练习3', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (16, 3, '测试作业-课后练习4', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (17, 4, '测试作业-课后练习1', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (18, 4, '测试作业-课后练习2', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (19, 4, '测试作业-课后练习3', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (20, 5, '测试作业-课后练习1', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (21, 5, '测试作业-课后练习2', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (22, 5, '测试作业-课后练习3', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (23, 5, '测试作业-课后练习4', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (24, 6, '测试作业-课后练习1', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (25, 6, '测试作业-课后练习2', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (26, 6, '测试作业-课后练习3', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (27, 7, '测试作业-课后练习1', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (28, 7, '测试作业-课后练习2', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (29, 7, '测试作业-课后练习3', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (30, 7, '测试作业-课后练习4', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (31, 8, '测试作业-课后练习1', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (32, 8, '测试作业-课后练习2', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);
INSERT INTO `course_homework` VALUES (33, 8, '测试作业-课后练习3', 20, 12, '2026-06-01 00:00:00', '2026-09-30 23:59:59', 2, 1, '2026-06-10 09:41:37', '2026-06-10 09:41:37', 0, 0);

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
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_material_course`(`course_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程资料表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_material
-- ----------------------------
INSERT INTO `course_material` VALUES (5, 1, 'Redis常见面试题汇总.pdf', 1, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/2026/06/d92fe1bd791940479e84c0d2301593af.pdf', 592563, 1, 0, '2026-06-07 18:50:24', '2026-06-07 18:50:24', 0, 0);
INSERT INTO `course_material` VALUES (6, 1, '专项学分.pdf', 1, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/2026/06/9109de5acf1a4f17817722f7cc960acb.pdf', 97769, 1, 0, '2026-06-07 19:13:41', '2026-06-07 19:13:41', 0, 0);

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
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_course_review_course_member`(`course_id`, `member_id`) USING BTREE,
  INDEX `idx_course_review_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 68 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_review
-- ----------------------------
INSERT INTO `course_review` VALUES (5, 1, 1, 3, '讲解节奏合适，重点内容比较突出。', 0, 1, '2026-06-09 13:28:37', '2026-06-09 13:18:37', '2026-06-09 13:18:37', 0, 0);
INSERT INTO `course_review` VALUES (6, 1, 2, 5, '学习完后对相关主题有了更系统的认识。', 0, 1, '2026-06-09 06:28:37', '2026-06-09 06:18:37', '2026-06-09 06:18:37', 0, 0);
INSERT INTO `course_review` VALUES (7, 2, 3, 5, '案例比较贴近实际工作，收获很大。', 1, 1, '2026-06-08 20:28:37', '2026-06-08 20:18:37', '2026-06-08 20:18:37', 0, 0);
INSERT INTO `course_review` VALUES (8, 3, 4, 5, '对基础概念梳理得比较完整，适合入门。', 0, 1, '2026-06-08 10:28:37', '2026-06-08 10:18:37', '2026-06-08 10:18:37', 0, 0);
INSERT INTO `course_review` VALUES (9, 1, 5, 5, '内容比较实用，对当前岗位有帮助。', 0, 1, '2026-06-08 09:28:37', '2026-06-08 09:18:37', '2026-06-08 09:18:37', 0, 0);
INSERT INTO `course_review` VALUES (10, 2, 6, 5, '课程结构清晰，学习起来很顺畅。', 0, 1, '2026-06-07 23:28:37', '2026-06-07 23:18:37', '2026-06-07 23:18:37', 0, 0);
INSERT INTO `course_review` VALUES (11, 1, 7, 3, '课程结构清晰，学习起来很顺畅。', 0, 1, '2026-06-07 19:28:37', '2026-06-07 19:18:37', '2026-06-07 19:18:37', 0, 0);
INSERT INTO `course_review` VALUES (12, 6, 8, 4, '内容比较实用，对当前岗位有帮助。', 0, 1, '2026-06-06 21:28:37', '2026-06-06 21:18:37', '2026-06-06 21:18:37', 0, 0);
INSERT INTO `course_review` VALUES (13, 1, 9, 4, '讲解节奏合适，重点内容比较突出。', 1, 1, '2026-06-07 05:28:37', '2026-06-07 05:18:37', '2026-06-07 05:18:37', 0, 0);
INSERT INTO `course_review` VALUES (14, 2, 10, 4, '练习和知识点结合得不错，便于理解。', 0, 1, '2026-06-06 19:28:37', '2026-06-06 19:18:37', '2026-06-06 19:18:37', 0, 0);
INSERT INTO `course_review` VALUES (15, 9, 11, 4, '练习和知识点结合得不错，便于理解。', 1, 1, '2026-06-05 15:28:37', '2026-06-05 15:18:37', '2026-06-05 15:18:37', 0, 0);
INSERT INTO `course_review` VALUES (16, 11, 12, 5, '对基础概念梳理得比较完整，适合入门。', 0, 1, '2026-06-05 02:28:37', '2026-06-05 02:18:37', '2026-06-05 02:18:37', 0, 0);
INSERT INTO `course_review` VALUES (17, 3, 13, 5, '课程结构清晰，学习起来很顺畅。', 0, 1, '2026-06-05 19:28:37', '2026-06-05 19:18:37', '2026-06-05 19:18:37', 0, 0);
INSERT INTO `course_review` VALUES (18, 8, 14, 3, '内容比较实用，对当前岗位有帮助。', 0, 1, '2026-06-09 21:28:37', '2026-06-09 21:18:37', '2026-06-09 21:18:37', 0, 0);
INSERT INTO `course_review` VALUES (19, 14, 15, 5, '案例比较贴近实际工作，收获很大。', 0, 1, '2026-06-08 20:28:37', '2026-06-08 20:18:37', '2026-06-08 20:18:37', 0, 0);
INSERT INTO `course_review` VALUES (20, 2, 16, 4, '讲解节奏合适，重点内容比较突出。', 0, 1, '2026-06-05 01:28:37', '2026-06-05 01:18:37', '2026-06-05 01:18:37', 0, 0);
INSERT INTO `course_review` VALUES (21, 1, 17, 5, '讲解节奏合适，重点内容比较突出。', 0, 1, '2026-06-09 21:28:37', '2026-06-09 21:18:37', '2026-06-09 21:18:37', 0, 0);
INSERT INTO `course_review` VALUES (22, 1, 18, 4, '学习完后对相关主题有了更系统的认识。', 0, 1, '2026-06-09 14:28:37', '2026-06-09 14:18:37', '2026-06-09 14:18:37', 0, 0);
INSERT INTO `course_review` VALUES (23, 3, 19, 5, '内容比较实用，对当前岗位有帮助。', 0, 1, '2026-06-09 01:28:37', '2026-06-09 01:18:37', '2026-06-09 01:18:37', 0, 0);
INSERT INTO `course_review` VALUES (24, 1, 20, 5, '案例比较贴近实际工作，收获很大。', 0, 1, '2026-06-09 00:28:37', '2026-06-09 00:18:37', '2026-06-09 00:18:37', 0, 0);
INSERT INTO `course_review` VALUES (25, 4, 21, 4, '整体体验较好，希望后续补充更多实战内容。', 1, 1, '2026-06-08 08:28:37', '2026-06-08 08:18:37', '2026-06-08 08:18:37', 0, 0);
INSERT INTO `course_review` VALUES (26, 6, 22, 5, '练习和知识点结合得不错，便于理解。', 0, 1, '2026-06-07 19:28:37', '2026-06-07 19:18:37', '2026-06-07 19:18:37', 0, 0);
INSERT INTO `course_review` VALUES (27, 1, 23, 5, '课程结构清晰，学习起来很顺畅。', 0, 1, '2026-06-08 03:28:37', '2026-06-08 03:18:37', '2026-06-08 03:18:37', 0, 0);
INSERT INTO `course_review` VALUES (28, 4, 24, 4, '练习和知识点结合得不错，便于理解。', 0, 1, '2026-06-07 11:28:37', '2026-06-07 11:18:37', '2026-06-07 11:18:37', 0, 0);
INSERT INTO `course_review` VALUES (29, 1, 25, 3, '讲解节奏合适，重点内容比较突出。', 0, 1, '2026-06-07 13:28:37', '2026-06-07 13:18:37', '2026-06-07 13:18:37', 0, 0);
INSERT INTO `course_review` VALUES (30, 1, 26, 5, '学习完后对相关主题有了更系统的认识。', 0, 1, '2026-06-07 06:28:37', '2026-06-07 06:18:37', '2026-06-07 06:18:37', 0, 0);
INSERT INTO `course_review` VALUES (31, 7, 27, 4, '讲解节奏合适，重点内容比较突出。', 0, 1, '2026-06-06 05:28:37', '2026-06-06 05:18:37', '2026-06-06 05:18:37', 0, 0);
INSERT INTO `course_review` VALUES (32, 3, 28, 5, '对基础概念梳理得比较完整，适合入门。', 0, 1, '2026-06-06 10:28:37', '2026-06-06 10:18:37', '2026-06-06 10:18:37', 0, 0);
INSERT INTO `course_review` VALUES (33, 1, 29, 5, '内容比较实用，对当前岗位有帮助。', 1, 1, '2026-06-06 09:28:37', '2026-06-06 09:18:37', '2026-06-06 09:18:37', 0, 0);
INSERT INTO `course_review` VALUES (34, 5, 30, 5, '学习完后对相关主题有了更系统的认识。', 1, 1, '2026-06-05 14:28:37', '2026-06-05 14:18:37', '2026-06-05 14:18:37', 0, 0);
INSERT INTO `course_review` VALUES (35, 3, 31, 5, '讲解节奏合适，重点内容比较突出。', 0, 1, '2026-06-05 13:28:37', '2026-06-05 13:18:37', '2026-06-05 13:18:37', 0, 0);
INSERT INTO `course_review` VALUES (36, 8, 32, 3, '课程结构清晰，学习起来很顺畅。', 1, 1, '2026-06-09 15:28:37', '2026-06-09 15:18:37', '2026-06-09 15:18:37', 0, 0);
INSERT INTO `course_review` VALUES (37, 1, 33, 4, '讲解节奏合适，重点内容比较突出。', 0, 1, '2026-06-05 05:28:37', '2026-06-05 05:18:37', '2026-06-05 05:18:37', 0, 0);
INSERT INTO `course_review` VALUES (38, 1, 34, 3, '学习完后对相关主题有了更系统的认识。', 1, 1, '2026-06-09 22:28:37', '2026-06-09 22:18:37', '2026-06-09 22:18:37', 0, 0);
INSERT INTO `course_review` VALUES (39, 3, 35, 4, '内容比较实用，对当前岗位有帮助。', 0, 1, '2026-06-09 09:28:37', '2026-06-09 09:18:37', '2026-06-09 09:18:37', 0, 0);
INSERT INTO `course_review` VALUES (40, 1, 36, 4, '案例比较贴近实际工作，收获很大。', 0, 1, '2026-06-09 08:28:37', '2026-06-09 08:18:37', '2026-06-09 08:18:37', 0, 0);
INSERT INTO `course_review` VALUES (41, 5, 37, 4, '讲解节奏合适，重点内容比较突出。', 0, 1, '2026-06-08 13:28:37', '2026-06-08 13:18:37', '2026-06-08 13:18:37', 0, 0);
INSERT INTO `course_review` VALUES (42, 1, 38, 5, '对基础概念梳理得比较完整，适合入门。', 0, 1, '2026-06-08 18:28:37', '2026-06-08 18:18:37', '2026-06-08 18:18:37', 0, 0);
INSERT INTO `course_review` VALUES (43, 6, 39, 3, '案例比较贴近实际工作，收获很大。', 1, 1, '2026-06-07 20:28:37', '2026-06-07 20:18:37', '2026-06-07 20:18:37', 0, 0);
INSERT INTO `course_review` VALUES (44, 3, 40, 5, '学习完后对相关主题有了更系统的认识。', 0, 1, '2026-06-07 22:28:37', '2026-06-07 22:18:37', '2026-06-07 22:18:37', 0, 0);
INSERT INTO `course_review` VALUES (45, 2, 41, 3, '学习完后对相关主题有了更系统的认识。', 0, 1, '2026-06-07 18:28:37', '2026-06-07 18:18:37', '2026-06-07 18:18:37', 0, 0);
INSERT INTO `course_review` VALUES (46, 2, 42, 5, '练习和知识点结合得不错，便于理解。', 0, 1, '2026-06-07 11:28:37', '2026-06-07 11:18:37', '2026-06-07 11:18:37', 0, 0);
INSERT INTO `course_review` VALUES (47, 3, 43, 5, '内容比较实用，对当前岗位有帮助。', 0, 1, '2026-06-07 01:28:37', '2026-06-07 01:18:37', '2026-06-07 01:18:37', 0, 0);
INSERT INTO `course_review` VALUES (48, 6, 44, 4, '讲解节奏合适，重点内容比较突出。', 1, 1, '2026-06-06 09:28:37', '2026-06-06 09:18:37', '2026-06-06 09:18:37', 0, 0);
INSERT INTO `course_review` VALUES (49, 7, 45, 4, '练习和知识点结合得不错，便于理解。', 0, 1, '2026-06-05 23:28:37', '2026-06-05 23:18:37', '2026-06-05 23:18:37', 0, 0);
INSERT INTO `course_review` VALUES (50, 5, 46, 4, '学习完后对相关主题有了更系统的认识。', 0, 1, '2026-06-05 22:28:37', '2026-06-05 22:18:37', '2026-06-05 22:18:37', 0, 0);
INSERT INTO `course_review` VALUES (51, 12, 47, 4, '学习完后对相关主题有了更系统的认识。', 0, 1, '2026-06-09 18:28:37', '2026-06-09 18:18:37', '2026-06-09 18:18:37', 0, 0);
INSERT INTO `course_review` VALUES (52, 12, 48, 3, '练习和知识点结合得不错，便于理解。', 1, 1, '2026-06-09 11:28:37', '2026-06-09 11:18:37', '2026-06-09 11:18:37', 0, 0);
INSERT INTO `course_review` VALUES (53, 1, 49, 3, '讲解节奏合适，重点内容比较突出。', 1, 1, '2026-06-05 13:28:37', '2026-06-05 13:18:37', '2026-06-05 13:18:37', 0, 0);
INSERT INTO `course_review` VALUES (54, 1, 50, 5, '学习完后对相关主题有了更系统的认识。', 0, 1, '2026-06-05 06:28:37', '2026-06-05 06:18:37', '2026-06-05 06:18:37', 0, 0);
INSERT INTO `course_review` VALUES (55, 1, 51, 4, '练习和知识点结合得不错，便于理解。', 0, 1, '2026-06-09 23:28:37', '2026-06-09 23:18:37', '2026-06-09 23:18:37', 0, 0);
INSERT INTO `course_review` VALUES (56, 2, 52, 4, '内容比较实用，对当前岗位有帮助。', 0, 1, '2026-06-09 13:28:37', '2026-06-09 13:18:37', '2026-06-09 13:18:37', 0, 0);

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
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_section_course`(`course_id`) USING BTREE,
  INDEX `idx_course_section_chapter`(`chapter_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 133 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程小节表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_section
-- ----------------------------
INSERT INTO `course_section` VALUES (1, 1, 1, '企业文化基础入门导读', 1, 1, '2026-06-04 10:12:17', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (2, 2, 2, '价值判断基础导读', 1, 1, '2026-06-04 10:12:17', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (3, 1, 3, '核心价值观解读导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (4, 1, 4, '组织行为与文化案例导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (5, 1, 5, '文化落地行动清单导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (6, 2, 6, '客户场景中的价值判断导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (7, 2, 7, '协作冲突与决策取舍导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (8, 2, 8, '复盘与行为改进导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (9, 3, 9, '沟通底层逻辑导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (10, 3, 10, '向上与跨部门沟通导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (11, 3, 11, '会议表达与反馈技巧导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (12, 4, 12, '项目协同角色分工导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (13, 4, 13, '进度同步与风险处理导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (14, 4, 14, '跨团队交付复盘导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (15, 5, 15, '云原生概念总览导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (16, 5, 16, '容器与镜像基础导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (17, 5, 17, '集群与服务治理入门导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (18, 6, 18, '应用容器化准备导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (19, 6, 19, '镜像构建与仓库管理导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (20, 6, 20, '部署发布与问题排查导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (21, 7, 21, '平台交付流程概览导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (22, 7, 22, '需求评审与环境准备导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (23, 7, 23, '验收交付与总结复盘导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (24, 8, 24, '运维值守基本规范导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (25, 8, 25, '告警响应与故障升级导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (26, 8, 26, '巡检制度与应急演练导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (27, 9, 27, '指标认知与数据口径导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (28, 9, 28, '基础分析方法导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (29, 9, 29, '报表解读与结论输出导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (30, 10, 30, '看板目标与受众定义导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (31, 10, 31, '指标体系设计导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (32, 10, 32, '可视化呈现与迭代优化导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (33, 11, 33, '数据治理核心原则导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (34, 11, 34, '主数据与质量管理导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (35, 11, 35, '治理机制与职责协同导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (36, 12, 36, '数据资产盘点方法导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (38, 12, 38, '资产沉淀与价值评估导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (39, 13, 39, '公司制度与角色认知导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (40, 13, 40, '团队协作与工作流程导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (41, 13, 41, '试用期目标与成长建议导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (42, 14, 42, '岗位能力模型解析导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (43, 14, 43, '阶段性成长目标设定导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (44, 14, 44, '学习路径与行动计划导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (45, 15, 45, '管理者角色转换导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (46, 15, 46, '目标管理与任务分配导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (47, 15, 47, '团队带教与过程复盘导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (48, 16, 48, '绩效沟通基础导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (49, 16, 49, '一对一辅导技巧导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (50, 16, 50, '激励机制与团队氛围建设导读', 1, 1, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (66, 1, 1, '企业文化基础入门实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (67, 2, 2, '价值判断基础实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (68, 1, 3, '核心价值观解读实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (69, 1, 4, '组织行为与文化案例实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (70, 1, 5, '文化落地行动清单实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (71, 2, 6, '客户场景中的价值判断实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (72, 2, 7, '协作冲突与决策取舍实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (73, 2, 8, '复盘与行为改进实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (74, 3, 9, '沟通底层逻辑实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (75, 3, 10, '向上与跨部门沟通实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (76, 3, 11, '会议表达与反馈技巧实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (77, 4, 12, '项目协同角色分工实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (78, 4, 13, '进度同步与风险处理实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (79, 4, 14, '跨团队交付复盘实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (80, 5, 15, '云原生概念总览实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (81, 5, 16, '容器与镜像基础实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (82, 5, 17, '集群与服务治理入门实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (83, 6, 18, '应用容器化准备实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (84, 6, 19, '镜像构建与仓库管理实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (85, 6, 20, '部署发布与问题排查实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (86, 7, 21, '平台交付流程概览实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (87, 7, 22, '需求评审与环境准备实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (88, 7, 23, '验收交付与总结复盘实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (89, 8, 24, '运维值守基本规范实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (90, 8, 25, '告警响应与故障升级实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (91, 8, 26, '巡检制度与应急演练实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (92, 9, 27, '指标认知与数据口径实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (93, 9, 28, '基础分析方法实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (94, 9, 29, '报表解读与结论输出实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (95, 10, 30, '看板目标与受众定义实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (96, 10, 31, '指标体系设计实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (97, 10, 32, '可视化呈现与迭代优化实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (98, 11, 33, '数据治理核心原则实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (99, 11, 34, '主数据与质量管理实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (100, 11, 35, '治理机制与职责协同实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (101, 12, 36, '数据资产盘点方法实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (103, 12, 38, '资产沉淀与价值评估实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (104, 13, 39, '公司制度与角色认知实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (105, 13, 40, '团队协作与工作流程实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (106, 13, 41, '试用期目标与成长建议实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (107, 14, 42, '岗位能力模型解析实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (108, 14, 43, '阶段性成长目标设定实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (109, 14, 44, '学习路径与行动计划实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (110, 15, 45, '管理者角色转换实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (111, 15, 46, '目标管理与任务分配实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (112, 15, 47, '团队带教与过程复盘实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (113, 16, 48, '绩效沟通基础实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (114, 16, 49, '一对一辅导技巧实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);
INSERT INTO `course_section` VALUES (115, 16, 50, '激励机制与团队氛围建设实践应用', 0, 2, '2026-06-06 19:16:09', '2026-06-06 19:16:09', 1, 1);

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
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_course_section_content_section`(`section_id`) USING BTREE,
  INDEX `idx_course_section_content_course`(`course_id`) USING BTREE,
  INDEX `idx_course_section_content_chapter`(`chapter_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程小节内容项表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of course_section_content
-- ----------------------------
INSERT INTO `course_section_content` VALUES (1, 1, 1, 66, 'test', 'RICH_TEXT', '<ol><li><p>123123</p></li><li><p>ttt</p></li><li><p>ttt</p></li><li><p>ww</p></li></ol><p></p>', NULL, '', NULL, NULL, NULL, 0, 0, 1, 1, '2026-06-07 17:36:20', '2026-06-07 17:54:53', 0, 0);
INSERT INTO `course_section_content` VALUES (2, 1, 1, 1, '测试视频', 'VIDEO', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/videos/2026/06/cc87a19c5efb411ea0c7daca1f1ef2d4.mp4', 'education-platform/materials/section-contents/videos/2026/06/cc87a19c5efb411ea0c7daca1f1ef2d4.mp4', 'New project.mp4', 'video/mp4', 8285618, 11, 1, 1, '2026-06-07 17:42:10', '2026-06-07 17:42:10', 0, 0);
INSERT INTO `course_section_content` VALUES (3, 1, 1, 1, '富文本测试', 'RICH_TEXT', '<ol><li><p>a</p></li><li><p>b</p></li><li><p>ccc</p></li></ol><p></p>', '{\"type\":\"doc\",\"content\":[{\"type\":\"orderedList\",\"attrs\":{\"start\":1,\"type\":null},\"content\":[{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"a\"}]}]},{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"b\"}]}]},{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"ccc\"}]}]}]},{\"type\":\"paragraph\"}]}', NULL, NULL, NULL, NULL, 0, 0, 2, 1, '2026-06-07 17:42:31', '2026-06-07 17:54:46', 0, 0);
INSERT INTO `course_section_content` VALUES (4, 1, 1, 1, 'testpdf', 'PDF', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/pdf/2026/06/564b4cb9c296479497e7608840447b89.pdf', 'education-platform/materials/section-contents/pdf/2026/06/564b4cb9c296479497e7608840447b89.pdf', 'Redis常见面试题汇总.pdf', 'application/pdf', 592563, 0, 3, 1, '2026-06-07 17:46:12', '2026-06-07 17:54:48', 0, 0);
INSERT INTO `course_section_content` VALUES (5, 1, 1, 1, '富文本测试', 'RICH_TEXT', '<ul><li><p>test</p></li><li><p></p><img src=\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/6b10070e0f1b41ac85dffbd86affa7ef.png\" alt=\"image.png\"></li></ul><ul><li><p>test2</p></li></ul><p></p>', '{\"type\":\"doc\",\"content\":[{\"type\":\"bulletList\",\"content\":[{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"test\"}]}]},{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\"},{\"type\":\"image\",\"attrs\":{\"src\":\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/6b10070e0f1b41ac85dffbd86affa7ef.png\",\"alt\":\"image.png\",\"title\":null,\"width\":null,\"height\":null}}]}]},{\"type\":\"bulletList\",\"content\":[{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"test2\"}]}]}]},{\"type\":\"paragraph\"}]}', NULL, NULL, NULL, NULL, 0, 0, 2, 1, '2026-06-07 17:55:58', '2026-06-07 17:55:58', 0, 0);
INSERT INTO `course_section_content` VALUES (6, 1, 1, 1, 'pdf测试', 'PDF', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/pdf/2026/06/68d95028d8854c27997dfeeb208e5aed.pdf', 'education-platform/materials/section-contents/pdf/2026/06/68d95028d8854c27997dfeeb208e5aed.pdf', 'Redis常见面试题汇总.pdf', 'application/pdf', 592563, 0, 3, 1, '2026-06-07 17:56:13', '2026-06-07 17:56:13', 0, 0);
INSERT INTO `course_section_content` VALUES (7, 2, 2, 2, 'pdf测试', 'PDF', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/pdf/2026/06/cd69545a73c943ed89e140c54583349b.pdf', 'education-platform/materials/section-contents/pdf/2026/06/cd69545a73c943ed89e140c54583349b.pdf', 'Redis常见面试题汇总.pdf', 'application/pdf', 592563, 0, 1, 1, '2026-06-07 18:00:08', '2026-06-07 18:00:08', 0, 0);
INSERT INTO `course_section_content` VALUES (8, 2, 2, 2, 'pdf', 'PDF', NULL, NULL, 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/pdf/2026/06/445ebbe57a0c4ccfbb31cee64a7f5e22.pdf', 'education-platform/materials/section-contents/pdf/2026/06/445ebbe57a0c4ccfbb31cee64a7f5e22.pdf', 'Redis常见面试题汇总.pdf', 'application/pdf', 592563, 0, 2, 1, '2026-06-07 18:03:56', '2026-06-07 18:03:56', 0, 0);
INSERT INTO `course_section_content` VALUES (9, 1, 3, 3, '这是标题', 'RICH_TEXT', '<h2>这是第一段</h2><ol><li><p>这是正文</p><img src=\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/f8ed599e292c4ee0a10821aedc13e160.png\" alt=\"Clip_2026-06-07_19-17-10.png\"></li><li><p>这也是正文</p><img src=\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/c88f15471c7745d3bdcb6691fa7de485.png\" alt=\"Clip_2026-06-07_19-17-23.png\"></li><li><p>这还是正文</p><img src=\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/da7481d639834143940487c1f39f4390.png\" alt=\"Clip_2026-06-07_19-17-40.png\"></li></ol><h2>这是段尾</h2><p></p>', '{\"type\":\"doc\",\"content\":[{\"type\":\"heading\",\"attrs\":{\"level\":2},\"content\":[{\"type\":\"text\",\"text\":\"这是第一段\"}]},{\"type\":\"orderedList\",\"attrs\":{\"start\":1,\"type\":null},\"content\":[{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"这是正文\"}]},{\"type\":\"image\",\"attrs\":{\"src\":\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/f8ed599e292c4ee0a10821aedc13e160.png\",\"alt\":\"Clip_2026-06-07_19-17-10.png\",\"title\":null,\"width\":null,\"height\":null}}]},{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"这也是正文\"}]},{\"type\":\"image\",\"attrs\":{\"src\":\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/c88f15471c7745d3bdcb6691fa7de485.png\",\"alt\":\"Clip_2026-06-07_19-17-23.png\",\"title\":null,\"width\":null,\"height\":null}}]},{\"type\":\"listItem\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"这还是正文\"}]},{\"type\":\"image\",\"attrs\":{\"src\":\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/da7481d639834143940487c1f39f4390.png\",\"alt\":\"Clip_2026-06-07_19-17-40.png\",\"title\":null,\"width\":null,\"height\":null}}]}]},{\"type\":\"heading\",\"attrs\":{\"level\":2},\"content\":[{\"type\":\"text\",\"text\":\"这是段尾\"}]},{\"type\":\"paragraph\"}]}', NULL, NULL, NULL, NULL, 0, 0, 1, 1, '2026-06-07 19:17:47', '2026-06-07 19:17:47', 0, 0);
INSERT INTO `course_section_content` VALUES (10, 1, 3, 68, 'test', 'RICH_TEXT', '<p>111</p><img src=\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/45a61a7622c74b038e91cc0a80a8077c.png\" alt=\"Clip_2026-06-07_19-17-40.png\"><p>222</p>', '{\"type\":\"doc\",\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"111\"}]},{\"type\":\"image\",\"attrs\":{\"src\":\"https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/section-contents/images/2026/06/45a61a7622c74b038e91cc0a80a8077c.png\",\"alt\":\"Clip_2026-06-07_19-17-40.png\",\"title\":null,\"width\":null,\"height\":null}},{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"222\"}]}]}', NULL, NULL, NULL, NULL, 0, 0, 1, 1, '2026-06-07 19:26:29', '2026-06-07 19:26:29', 0, 0);

-- ----------------------------
-- Table structure for exam_question
-- ----------------------------
DROP TABLE IF EXISTS `exam_question`;
CREATE TABLE `exam_question`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id` bigint(0) UNSIGNED NOT NULL,
  `question_type` tinyint(0) NOT NULL,
  `stem` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `options_json` json NULL,
  `answer_json` json NULL,
  `analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `score` int(0) NOT NULL DEFAULT 0,
  `sort` int(0) NOT NULL DEFAULT 0,
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0,
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam_question_task_id`(`task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 90 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_question
-- ----------------------------
INSERT INTO `exam_question` VALUES (27, 28, 1, '【测试】测试考试-阶段测验3：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (28, 27, 1, '【测试】测试考试-阶段测验2：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (29, 26, 1, '【测试】测试考试-阶段测验1：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (30, 25, 1, '【测试】测试考试-阶段测验2：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (31, 24, 1, '【测试】测试考试-阶段测验1：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (32, 23, 1, '【测试】测试考试-阶段测验3：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (33, 22, 1, '【测试】测试考试-阶段测验2：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (34, 21, 1, '【测试】测试考试-阶段测验1：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (35, 20, 1, '【测试】测试考试-阶段测验2：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (36, 19, 1, '【测试】测试考试-阶段测验1：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (37, 18, 1, '【测试】测试考试-阶段测验3：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (38, 17, 1, '【测试】测试考试-阶段测验2：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (39, 16, 1, '【测试】测试考试-阶段测验1：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (40, 15, 1, '【测试】测试考试-阶段测验2：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (41, 14, 1, '【测试】测试考试-阶段测验1：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (42, 13, 1, '【测试】测试考试-阶段测验3：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (43, 12, 1, '【测试】测试考试-阶段测验2：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (44, 11, 1, '【测试】测试考试-阶段测验1：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (45, 10, 1, '【测试】测试考试-阶段测验2：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (46, 9, 1, '【测试】测试考试-阶段测验1：考试开始前最合理的做法是？', '[{\"label\": \"A\", \"content\": \"先阅读题目要求再作答\"}, {\"label\": \"B\", \"content\": \"直接随机选择\"}, {\"label\": \"C\", \"content\": \"跳过所有说明\"}, {\"label\": \"D\", \"content\": \"不看题干直接提交\"}]', '[\"A\"]', '测试题，验证考试单选题流程。', 10, 1, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (47, 28, 3, '【测试】测试考试-阶段测验3：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (48, 27, 3, '【测试】测试考试-阶段测验2：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (49, 26, 3, '【测试】测试考试-阶段测验1：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (50, 25, 3, '【测试】测试考试-阶段测验2：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (51, 24, 3, '【测试】测试考试-阶段测验1：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (52, 23, 3, '【测试】测试考试-阶段测验3：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (53, 22, 3, '【测试】测试考试-阶段测验2：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (54, 21, 3, '【测试】测试考试-阶段测验1：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (55, 20, 3, '【测试】测试考试-阶段测验2：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (56, 19, 3, '【测试】测试考试-阶段测验1：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (57, 18, 3, '【测试】测试考试-阶段测验3：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (58, 17, 3, '【测试】测试考试-阶段测验2：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (59, 16, 3, '【测试】测试考试-阶段测验1：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (60, 15, 3, '【测试】测试考试-阶段测验2：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (61, 14, 3, '【测试】测试考试-阶段测验1：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (62, 13, 3, '【测试】测试考试-阶段测验3：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (63, 12, 3, '【测试】测试考试-阶段测验2：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (64, 11, 3, '【测试】测试考试-阶段测验1：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (65, 10, 3, '【测试】测试考试-阶段测验2：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);
INSERT INTO `exam_question` VALUES (66, 9, 3, '【测试】测试考试-阶段测验1：考试提交后应能看到提交记录。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证考试判断题流程。', 10, 2, '2026-06-10 09:42:14', '2026-06-10 09:42:14', 0, 0);

-- ----------------------------
-- Table structure for exam_submission
-- ----------------------------
DROP TABLE IF EXISTS `exam_submission`;
CREATE TABLE `exam_submission`  (
  `id` bigint(0) UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id` bigint(0) UNSIGNED NOT NULL,
  `member_id` bigint(0) UNSIGNED NOT NULL,
  `attempt_no` int(0) NOT NULL DEFAULT 1,
  `answers_json` json NULL,
  `attachment_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `objective_score` int(0) NOT NULL DEFAULT 0,
  `subjective_score` int(0) NOT NULL DEFAULT 0,
  `score` int(0) NOT NULL DEFAULT 0,
  `review_status` tinyint(0) NOT NULL DEFAULT 0,
  `review_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `submitted_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `reviewed_at` datetime(0) NULL DEFAULT NULL,
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0,
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam_submission_task_id`(`task_id`) USING BTREE,
  INDEX `idx_exam_submission_member_id`(`member_id`) USING BTREE,
  INDEX `idx_exam_submission_review_status`(`review_status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_submission
-- ----------------------------

-- ----------------------------
-- Table structure for homework_question
-- ----------------------------
DROP TABLE IF EXISTS `homework_question`;
CREATE TABLE `homework_question`  (
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
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_question_task`(`task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 82 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of homework_question
-- ----------------------------
INSERT INTO `homework_question` VALUES (19, 6, 3, '【测试】测试作业-课后练习1：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (20, 6, 1, '【测试】测试作业-课后练习1：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (21, 7, 3, '【测试】测试作业-课后练习2：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (22, 7, 1, '【测试】测试作业-课后练习2：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (23, 8, 3, '【测试】测试作业-课后练习3：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (24, 8, 1, '【测试】测试作业-课后练习3：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (25, 9, 3, '【测试】测试作业-课后练习4：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (26, 9, 1, '【测试】测试作业-课后练习4：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (27, 10, 3, '【测试】测试作业-课后练习1：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (28, 10, 1, '【测试】测试作业-课后练习1：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (29, 11, 3, '【测试】测试作业-课后练习2：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (30, 11, 1, '【测试】测试作业-课后练习2：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (31, 12, 3, '【测试】测试作业-课后练习3：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (32, 12, 1, '【测试】测试作业-课后练习3：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (33, 13, 3, '【测试】测试作业-课后练习1：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (34, 13, 1, '【测试】测试作业-课后练习1：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (35, 14, 3, '【测试】测试作业-课后练习2：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (36, 14, 1, '【测试】测试作业-课后练习2：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (37, 15, 3, '【测试】测试作业-课后练习3：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (38, 15, 1, '【测试】测试作业-课后练习3：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (39, 16, 3, '【测试】测试作业-课后练习4：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (40, 16, 1, '【测试】测试作业-课后练习4：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (41, 17, 3, '【测试】测试作业-课后练习1：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (42, 17, 1, '【测试】测试作业-课后练习1：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (43, 18, 3, '【测试】测试作业-课后练习2：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (44, 18, 1, '【测试】测试作业-课后练习2：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (45, 19, 3, '【测试】测试作业-课后练习3：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (46, 19, 1, '【测试】测试作业-课后练习3：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (47, 20, 3, '【测试】测试作业-课后练习1：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (48, 20, 1, '【测试】测试作业-课后练习1：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (49, 21, 3, '【测试】测试作业-课后练习2：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (50, 21, 1, '【测试】测试作业-课后练习2：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (51, 22, 3, '【测试】测试作业-课后练习3：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (52, 22, 1, '【测试】测试作业-课后练习3：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (53, 23, 3, '【测试】测试作业-课后练习4：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (54, 23, 1, '【测试】测试作业-课后练习4：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (55, 24, 3, '【测试】测试作业-课后练习1：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (56, 24, 1, '【测试】测试作业-课后练习1：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (57, 25, 3, '【测试】测试作业-课后练习2：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (58, 25, 1, '【测试】测试作业-课后练习2：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (59, 26, 3, '【测试】测试作业-课后练习3：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (60, 26, 1, '【测试】测试作业-课后练习3：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (61, 27, 3, '【测试】测试作业-课后练习1：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (62, 27, 1, '【测试】测试作业-课后练习1：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (63, 28, 3, '【测试】测试作业-课后练习2：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (64, 28, 1, '【测试】测试作业-课后练习2：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (65, 29, 3, '【测试】测试作业-课后练习3：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (66, 29, 1, '【测试】测试作业-课后练习3：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (67, 30, 3, '【测试】测试作业-课后练习4：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (68, 30, 1, '【测试】测试作业-课后练习4：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (69, 31, 3, '【测试】测试作业-课后练习1：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (70, 31, 1, '【测试】测试作业-课后练习1：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (71, 32, 3, '【测试】测试作业-课后练习2：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (72, 32, 1, '【测试】测试作业-课后练习2：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (73, 33, 3, '【测试】测试作业-课后练习3：完成学习后需要做结果复盘。', '[{\"label\": \"T\", \"content\": \"正确\"}, {\"label\": \"F\", \"content\": \"错误\"}]', '[\"T\"]', '测试题，验证判断题流程。', 10, 2, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);
INSERT INTO `homework_question` VALUES (74, 33, 1, '【测试】测试作业-课后练习3：以下哪项最符合课程学习要求？', '[{\"label\": \"A\", \"content\": \"按要求完成学习并提交结果\"}, {\"label\": \"B\", \"content\": \"只浏览标题即可\"}, {\"label\": \"C\", \"content\": \"无需记录过程\"}, {\"label\": \"D\", \"content\": \"与课程目标无关\"}]', '[\"A\"]', '测试题，验证单选题展示与提交流程。', 10, 1, '2026-06-10 09:41:51', '2026-06-10 09:41:51', 0, 0);

-- ----------------------------
-- Table structure for homework_submission
-- ----------------------------
DROP TABLE IF EXISTS `homework_submission`;
CREATE TABLE `homework_submission`  (
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
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_task_submission_member_attempt`(`task_id`, `member_id`, `attempt_no`) USING BTREE,
  INDEX `idx_task_submission_member`(`member_id`) USING BTREE,
  INDEX `idx_task_submission_review_status`(`review_status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '考试/作业提交记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of homework_submission
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
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_member_mobile`(`mobile`) USING BTREE,
  INDEX `idx_member_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 66 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of member
-- ----------------------------
INSERT INTO `member` VALUES (1, '15346584695', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '我叫张三', '张三', 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/member-avatars/2026/06/413375b80a1a4195ace4e8efe40e8435.jpg', 1, '2000-05-18', 1, '2026-06-04 11:47:16', '2026-06-04 11:47:16', 0, 0);
INSERT INTO `member` VALUES (2, '13800000012', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '学员小李', '李欣然', 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/member-avatars/2026/06/1d4cedb752b74cbca9a0c129f8e398e6.jfif', 2, '2001-09-06', 1, '2026-06-04 11:47:16', '2026-06-04 11:47:16', 0, 0);
INSERT INTO `member` VALUES (3, '13999000001', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员01', '用户01', NULL, 1, '1995-02-07', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (4, '13999000002', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员02', '用户02', NULL, 2, '1995-03-16', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (5, '13999000003', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员03', '用户03', NULL, 0, '1995-04-22', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (6, '13999000004', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员04', '用户04', NULL, 1, '1995-05-29', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (7, '13999000005', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员05', '用户05', NULL, 2, '1995-07-05', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (8, '13999000006', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员06', '用户06', NULL, 0, '1995-08-11', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (9, '13999000007', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员07', '用户07', NULL, 1, '1995-09-17', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (10, '13999000008', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员08', '用户08', NULL, 2, '1995-10-24', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (11, '13999000009', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员09', '用户09', NULL, 0, '1995-11-30', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (12, '13999000010', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员10', '用户10', NULL, 1, '1996-01-06', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (13, '13999000011', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员11', '用户11', NULL, 2, '1996-02-12', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (14, '13999000012', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员12', '用户12', NULL, 0, '1996-03-20', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (15, '13999000013', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员13', '用户13', NULL, 1, '1996-04-26', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (16, '13999000014', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员14', '用户14', NULL, 2, '1996-06-02', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (17, '13999000015', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员15', '用户15', NULL, 0, '1996-07-09', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (18, '13999000016', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员16', '用户16', NULL, 1, '1996-08-15', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (19, '13999000017', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员17', '用户17', NULL, 2, '1996-09-21', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (20, '13999000018', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员18', '用户18', NULL, 0, '1996-10-28', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (21, '13999000019', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员19', '用户19', NULL, 1, '1996-12-04', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (22, '13999000020', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员20', '用户20', NULL, 2, '1997-01-10', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (23, '13999000021', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员21', '用户21', NULL, 0, '1997-02-16', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (24, '13999000022', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员22', '用户22', NULL, 1, '1997-03-25', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (25, '13999000023', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员23', '用户23', NULL, 2, '1997-05-01', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (26, '13999000024', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员24', '用户24', NULL, 0, '1997-06-07', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (27, '13999000025', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员25', '用户25', NULL, 1, '1997-07-14', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (28, '13999000026', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员26', '用户26', NULL, 2, '1997-08-20', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (29, '13999000027', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员27', '用户27', NULL, 0, '1997-09-26', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (30, '13999000028', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员28', '用户28', NULL, 1, '1997-11-02', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (31, '13999000029', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员29', '用户29', NULL, 2, '1997-12-09', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (32, '13999000030', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员30', '用户30', NULL, 0, '1998-01-15', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (33, '13999000031', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员31', '用户31', NULL, 1, '1998-02-21', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (34, '13999000032', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员32', '用户32', NULL, 2, '1998-03-30', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (35, '13999000033', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员33', '用户33', NULL, 0, '1998-05-06', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (36, '13999000034', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员34', '用户34', NULL, 1, '1998-06-12', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (37, '13999000035', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员35', '用户35', NULL, 2, '1998-07-19', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (38, '13999000036', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员36', '用户36', NULL, 0, '1998-08-25', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (39, '13999000037', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员37', '用户37', NULL, 1, '1998-10-01', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (40, '13999000038', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员38', '用户38', NULL, 2, '1998-11-07', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (41, '13999000039', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员39', '用户39', NULL, 0, '1998-12-14', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (42, '13999000040', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员40', '用户40', NULL, 1, '1999-01-20', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (43, '13999000041', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员41', '用户41', NULL, 2, '1999-02-26', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (44, '13999000042', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员42', '用户42', NULL, 0, '1999-04-04', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (45, '13999000043', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员43', '用户43', NULL, 1, '1999-05-11', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (46, '13999000044', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员44', '用户44', NULL, 2, '1999-06-17', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (47, '13999000045', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员45', '用户45', NULL, 0, '1999-07-24', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (48, '13999000046', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员46', '用户46', NULL, 1, '1999-08-30', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (49, '13999000047', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员47', '用户47', NULL, 2, '1999-10-06', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (50, '13999000048', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员48', '用户48', NULL, 0, '1999-11-12', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (51, '13999000049', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员49', '用户49', NULL, 1, '1999-12-19', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);
INSERT INTO `member` VALUES (52, '13999000050', '$2a$10$lyumNsoRF18TN6zu0pXg2u68sYM.taJiVAJR84vizo.83oZaPg5WK', '测试学员50', '用户50', NULL, 2, '2000-01-25', 1, '2026-06-09 19:32:06', '2026-06-09 19:32:06', 0, 0);

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
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updated_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `created_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '创建人',
  `updated_by` bigint(0) UNSIGNED NULL DEFAULT 0 COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_teacher_login_name`(`login_name`) USING BTREE,
  UNIQUE INDEX `uk_teacher_mobile`(`mobile`) USING BTREE,
  UNIQUE INDEX `uk_teacher_email`(`email`) USING BTREE,
  INDEX `idx_teacher_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '教师表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teacher
-- ----------------------------
INSERT INTO `teacher` VALUES (1, 'teacher_li', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '老李', '高级讲师', '主讲 Java 后端开发与 Spring Boot 实战。', 'https://education-platform-333.oss-cn-beijing.aliyuncs.com/education-platform/materials/teacher-avatars/2026/06/d23120c6d0594cb0a9ac08bfc2a88c47.png', '13900000001', 'li.teacher@edu.com', 1, '2026-06-04 10:11:23', '2026-06-04 10:11:23', 1, 1);
INSERT INTO `teacher` VALUES (2, 'teacher_wang', '$2a$10$K/Bk4X/AoR8SH7nMaOn5JONc3/uax1seUz7s.Pah6EJAUmABVl9da', '王老师', '前端讲师', '主讲 Vue 3、工程化与前端项目实战。', 'https://cdn.edu.com/avatar/teacher-2.png', '13900000002', 'wang.teacher@edu.com', 1, '2026-06-04 10:11:23', '2026-06-04 10:11:23', 1, 1);

SET FOREIGN_KEY_CHECKS = 1;
