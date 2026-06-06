USE `education_platform`;

INSERT INTO `course_chapter` (
  `id`, `course_id`, `title`, `sort`, `created_by`, `updated_by`, `deleted`
) VALUES
  (1, 1, '第一章：企业文化基础入门', 1, 1, 1, 0),
  (2, 2, '第一章：价值判断基础', 1, 1, 1, 0),
  (3, 1, '第二章：核心价值观解读', 2, 1, 1, 0),
  (4, 1, '第三章：组织行为与文化案例', 3, 1, 1, 0),
  (5, 1, '第四章：文化落地行动清单', 4, 1, 1, 0),
  (6, 2, '第二章：客户场景中的价值判断', 2, 1, 1, 0),
  (7, 2, '第三章：协作冲突与决策取舍', 3, 1, 1, 0),
  (8, 2, '第四章：复盘与行为改进', 4, 1, 1, 0),
  (9, 3, '第一章：沟通底层逻辑', 1, 1, 1, 0),
  (10, 3, '第二章：向上与跨部门沟通', 2, 1, 1, 0),
  (11, 3, '第三章：会议表达与反馈技巧', 3, 1, 1, 0),
  (12, 4, '第一章：项目协同角色分工', 1, 1, 1, 0),
  (13, 4, '第二章：进度同步与风险处理', 2, 1, 1, 0),
  (14, 4, '第三章：跨团队交付复盘', 3, 1, 1, 0),
  (15, 5, '第一章：云原生概念总览', 1, 1, 1, 0),
  (16, 5, '第二章：容器与镜像基础', 2, 1, 1, 0),
  (17, 5, '第三章：集群与服务治理入门', 3, 1, 1, 0),
  (18, 6, '第一章：应用容器化准备', 1, 1, 1, 0),
  (19, 6, '第二章：镜像构建与仓库管理', 2, 1, 1, 0),
  (20, 6, '第三章：部署发布与问题排查', 3, 1, 1, 0),
  (21, 7, '第一章：平台交付流程概览', 1, 1, 1, 0),
  (22, 7, '第二章：需求评审与环境准备', 2, 1, 1, 0),
  (23, 7, '第三章：验收交付与总结复盘', 3, 1, 1, 0),
  (24, 8, '第一章：运维值守基本规范', 1, 1, 1, 0),
  (25, 8, '第二章：告警响应与故障升级', 2, 1, 1, 0),
  (26, 8, '第三章：巡检制度与应急演练', 3, 1, 1, 0),
  (27, 9, '第一章：指标认知与数据口径', 1, 1, 1, 0),
  (28, 9, '第二章：基础分析方法', 2, 1, 1, 0),
  (29, 9, '第三章：报表解读与结论输出', 3, 1, 1, 0),
  (30, 10, '第一章：看板目标与受众定义', 1, 1, 1, 0),
  (31, 10, '第二章：指标体系设计', 2, 1, 1, 0),
  (32, 10, '第三章：可视化呈现与迭代优化', 3, 1, 1, 0),
  (33, 11, '第一章：数据治理核心原则', 1, 1, 1, 0),
  (34, 11, '第二章：主数据与质量管理', 2, 1, 1, 0),
  (35, 11, '第三章：治理机制与职责协同', 3, 1, 1, 0),
  (36, 12, '第一章：数据资产盘点方法', 1, 1, 1, 0),
  (37, 12, '第二章：数据应用场景运营', 2, 1, 1, 0),
  (38, 12, '第三章：资产沉淀与价值评估', 3, 1, 1, 0),
  (39, 13, '第一章：公司制度与角色认知', 1, 1, 1, 0),
  (40, 13, '第二章：团队协作与工作流程', 2, 1, 1, 0),
  (41, 13, '第三章：试用期目标与成长建议', 3, 1, 1, 0),
  (42, 14, '第一章：岗位能力模型解析', 1, 1, 1, 0),
  (43, 14, '第二章：阶段性成长目标设定', 2, 1, 1, 0),
  (44, 14, '第三章：学习路径与行动计划', 3, 1, 1, 0),
  (45, 15, '第一章：管理者角色转换', 1, 1, 1, 0),
  (46, 15, '第二章：目标管理与任务分配', 2, 1, 1, 0),
  (47, 15, '第三章：团队带教与过程复盘', 3, 1, 1, 0),
  (48, 16, '第一章：绩效沟通基础', 1, 1, 1, 0),
  (49, 16, '第二章：一对一辅导技巧', 2, 1, 1, 0),
  (50, 16, '第三章：激励机制与团队氛围建设', 3, 1, 1, 0)
ON DUPLICATE KEY UPDATE
  `course_id` = VALUES(`course_id`),
  `title` = VALUES(`title`),
  `sort` = VALUES(`sort`),
  `updated_by` = VALUES(`updated_by`),
  `deleted` = 0;

INSERT INTO `course_section` (
  `course_id`, `chapter_id`, `title`, `section_type`, `content`, `video_url`,
  `duration`, `is_free_trial`, `sort`, `created_by`, `updated_by`, `deleted`
)
SELECT
  ch.`course_id`,
  ch.`id`,
  '章节导读',
  2,
  CONCAT('本小节围绕“', ch.`title`, '”进行知识导读与重点梳理。'),
  NULL,
  480,
  1,
  1,
  1,
  1,
  0
FROM `course_chapter` ch
WHERE ch.`deleted` = 0
  AND ch.`id` BETWEEN 1 AND 50
  AND NOT EXISTS (
    SELECT 1
    FROM `course_section` s
    WHERE s.`chapter_id` = ch.`id`
      AND s.`sort` = 1
      AND s.`deleted` = 0
  );

INSERT INTO `course_section` (
  `course_id`, `chapter_id`, `title`, `section_type`, `content`, `video_url`,
  `duration`, `is_free_trial`, `sort`, `created_by`, `updated_by`, `deleted`
)
SELECT
  ch.`course_id`,
  ch.`id`,
  '实践应用',
  1,
  CONCAT('本小节通过案例演练帮助学员掌握“', ch.`title`, '”的应用方式。'),
  CONCAT('https://cdn.edu.com/video/course-', ch.`course_id`, '-chapter-', ch.`id`, '-section-2.mp4'),
  900,
  0,
  2,
  1,
  1,
  0
FROM `course_chapter` ch
WHERE ch.`deleted` = 0
  AND ch.`id` BETWEEN 1 AND 50
  AND NOT EXISTS (
    SELECT 1
    FROM `course_section` s
    WHERE s.`chapter_id` = ch.`id`
      AND s.`sort` = 2
      AND s.`deleted` = 0
  );

UPDATE `course_section` s
JOIN `course_chapter` ch ON ch.`id` = s.`chapter_id`
SET
  s.`title` = CONCAT(
    TRIM(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(ch.`title`, '第一章：', ''),
            '第二章：', ''
          ),
          '第三章：', ''
        ),
        '第四章：', ''
      )
    ),
    '导读'
  ),
  s.`section_type` = 2,
  s.`content` = CONCAT(
    '本小节围绕“',
    TRIM(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(ch.`title`, '第一章：', ''),
            '第二章：', ''
          ),
          '第三章：', ''
        ),
        '第四章：', ''
      )
    ),
    '”进行知识导读与重点梳理。'
  ),
  s.`video_url` = NULL,
  s.`duration` = 480,
  s.`is_free_trial` = 1,
  s.`sort` = 1,
  s.`updated_by` = 1,
  s.`deleted` = 0
WHERE s.`chapter_id` BETWEEN 1 AND 50
  AND s.`sort` = 1;

UPDATE `course_section` s
JOIN `course_chapter` ch ON ch.`id` = s.`chapter_id`
SET
  s.`title` = CONCAT(
    TRIM(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(ch.`title`, '第一章：', ''),
            '第二章：', ''
          ),
          '第三章：', ''
        ),
        '第四章：', ''
      )
    ),
    '实践应用'
  ),
  s.`section_type` = 1,
  s.`content` = CONCAT(
    '本小节通过案例演练帮助学员掌握“',
    TRIM(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(ch.`title`, '第一章：', ''),
            '第二章：', ''
          ),
          '第三章：', ''
        ),
        '第四章：', ''
      )
    ),
    '”的应用方式。'
  ),
  s.`video_url` = CONCAT('https://cdn.edu.com/video/course-', s.`course_id`, '-chapter-', s.`chapter_id`, '-section-2.mp4'),
  s.`duration` = 900,
  s.`is_free_trial` = 0,
  s.`sort` = 2,
  s.`updated_by` = 1,
  s.`deleted` = 0
WHERE s.`chapter_id` BETWEEN 1 AND 50
  AND s.`sort` = 2;
