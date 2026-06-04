# 教育云平台后端接口文档

## 1. 文档说明

### 1.1 项目目标

面向教育云平台一期后端，基于 `Spring Boot + MySQL` 提供课程与教学相关核心能力，优先覆盖以下模块：

- 会员模块
- 教师模块
- 课程基本信息模块
- 课程分类模块（支持二级分类）
- 课程章节模块
- 课程评价模块
- 课程资料模块
- 考试/作业模块

### 1.2 角色定义

- `ADMIN`：平台管理员，负责教师、课程、分类、作业等后台管理
- `TEACHER`：教师端用户，负责维护自己名下课程、资料、考试/作业
- `MEMBER`：会员/学员，负责选课学习、提交作业、参与考试、评价课程

### 1.3 接口规范

- Base URL：`/api/v1`
- 数据格式：`application/json`
- 字符编码：`UTF-8`
- 时间格式：`yyyy-MM-dd HH:mm:ss`
- 鉴权方式：`JWT Bearer Token`
- 逻辑删除字段：`deleted`
- 创建时间字段：`createdAt`
- 更新时间字段：`updatedAt`

### 1.4 通用响应结构

```json
{
  "code": 0,
  "message": "success",
  "data": {},
  "traceId": "9f7b6f5e1b684999b9899a6f71a2f6aa"
}
```

### 1.5 通用分页结构

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "pageNum": 1,
    "pageSize": 10,
    "total": 125,
    "list": []
  }
}
```

### 1.6 通用状态码

| code | 含义 |
| --- | --- |
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录或 Token 失效 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 数据冲突 |
| 500 | 系统异常 |

---

## 2. 核心数据模型概览

| 模块 | 核心表 |
| --- | --- |
| 会员 | `member` |
| 教师 | `teacher` |
| 课程分类 | `course_category` |
| 课程基本信息 | `course` |
| 课程章节 | `course_chapter`, `course_section` |
| 课程资料 | `course_material` |
| 课程评价 | `course_review` |
| 考试/作业 | `course_task`, `task_question`, `task_submission` |

---

## 3. 认证与账号接口

### 3.1 会员注册

- `POST /api/v1/auth/member/register`

请求参数：

```json
{
  "mobile": "13800000000",
  "password": "123456",
  "nickname": "张三",
  "verifyCode": "666666"
}
```

返回参数：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "memberId": 10001
  }
}
```

### 3.2 会员登录

- `POST /api/v1/auth/member/login`

请求参数：

```json
{
  "mobile": "13800000000",
  "password": "123456"
}
```

返回参数：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "Bearer xxx.yyy.zzz",
    "refreshToken": "refresh_xxx",
    "expiresIn": 7200,
    "member": {
      "id": 10001,
      "nickname": "张三",
      "avatar": "",
      "status": 1
    }
  }
}
```

### 3.3 教师登录

- `POST /api/v1/auth/teacher/login`

### 3.4 管理员登录

- `POST /api/v1/auth/admin/login`

### 3.5 获取当前登录用户信息

- `GET /api/v1/auth/profile`

返回参数：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "userId": 1,
    "role": "ADMIN",
    "name": "系统管理员",
    "avatar": ""
  }
}
```

### 3.6 退出登录

- `POST /api/v1/auth/logout`

---

## 4. 会员模块

### 4.1 会员字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| mobile | varchar(20) | 手机号，唯一 |
| password | varchar(100) | 密码密文 |
| nickname | varchar(50) | 昵称 |
| realName | varchar(50) | 真实姓名 |
| avatar | varchar(255) | 头像 |
| gender | tinyint | 0未知 1男 2女 |
| birthday | date | 生日 |
| status | tinyint | 0禁用 1正常 |
| registerSource | varchar(20) | 注册来源 |

### 4.2 后台分页查询会员

- `GET /api/v1/admin/members`

查询参数：

| 参数 | 必填 | 说明 |
| --- | --- | --- |
| pageNum | 否 | 页码 |
| pageSize | 否 | 每页条数 |
| mobile | 否 | 手机号 |
| nickname | 否 | 昵称 |
| status | 否 | 状态 |

### 4.3 后台查看会员详情

- `GET /api/v1/admin/members/{id}`

### 4.4 后台修改会员状态

- `PUT /api/v1/admin/members/{id}/status`

请求参数：

```json
{
  "status": 0
}
```

### 4.5 会员查看个人信息

- `GET /api/v1/member/profile`

### 4.6 会员修改个人信息

- `PUT /api/v1/member/profile`

请求参数：

```json
{
  "nickname": "新的昵称",
  "realName": "张三",
  "gender": 1,
  "birthday": "2000-01-01",
  "avatar": "https://cdn.xxx.com/avatar.png"
}
```

---

## 5. 教师模块

### 5.1 教师字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| name | varchar(50) | 教师姓名 |
| title | varchar(100) | 职称 |
| intro | text | 讲师简介 |
| avatar | varchar(255) | 头像 |
| mobile | varchar(20) | 手机号 |
| email | varchar(100) | 邮箱 |
| status | tinyint | 0停用 1启用 |
| userId | bigint | 关联登录账号ID |

### 5.2 新增教师

- `POST /api/v1/admin/teachers`

请求参数：

```json
{
  "name": "李老师",
  "title": "高级讲师",
  "intro": "10年教研经验",
  "avatar": "",
  "mobile": "13900000000",
  "email": "teacher@test.com",
  "status": 1
}
```

### 5.3 教师列表

- `GET /api/v1/admin/teachers`

### 5.4 教师详情

- `GET /api/v1/admin/teachers/{id}`

### 5.5 修改教师

- `PUT /api/v1/admin/teachers/{id}`

### 5.6 修改教师状态

- `PUT /api/v1/admin/teachers/{id}/status`

### 5.7 前台查看教师详情

- `GET /api/v1/portal/teachers/{id}`

---

## 6. 课程分类模块

### 6.1 分类设计说明

- 采用二级分类结构
- 一级分类示例：`编程开发`、`升学考试`
- 二级分类示例：`Java`、`前端开发`
- 通过 `parentId` 实现层级关系
- 一级分类 `parentId = 0`

### 6.2 分类字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| parentId | bigint | 父级ID，一级为0 |
| name | varchar(50) | 分类名称 |
| level | tinyint | 1一级 2二级 |
| sort | int | 排序值 |
| status | tinyint | 0禁用 1启用 |

### 6.3 新增分类

- `POST /api/v1/admin/course-categories`

请求参数：

```json
{
  "parentId": 0,
  "name": "编程开发",
  "level": 1,
  "sort": 1,
  "status": 1
}
```

### 6.4 分类树查询

- `GET /api/v1/admin/course-categories/tree`

返回参数：

```json
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "编程开发",
      "level": 1,
      "children": [
        {
          "id": 11,
          "name": "Java",
          "level": 2
        }
      ]
    }
  ]
}
```

### 6.5 分类详情

- `GET /api/v1/admin/course-categories/{id}`

### 6.6 修改分类

- `PUT /api/v1/admin/course-categories/{id}`

### 6.7 删除分类

- `DELETE /api/v1/admin/course-categories/{id}`

删除约束：

- 一级分类下存在二级分类时不可删除
- 分类下存在课程时不可删除

### 6.8 前台分类树

- `GET /api/v1/portal/course-categories/tree`

---

## 7. 课程基本信息模块

### 7.1 课程字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| title | varchar(200) | 课程标题 |
| subTitle | varchar(255) | 课程副标题 |
| teacherId | bigint | 教师ID |
| categoryLevel1Id | bigint | 一级分类ID |
| categoryLevel2Id | bigint | 二级分类ID |
| coverUrl | varchar(255) | 封面图 |
| description | text | 课程详情 |
| difficulty | tinyint | 1初级 2中级 3高级 |
| price | decimal(10,2) | 售价 |
| publishStatus | tinyint | 0草稿 1已上架 2已下架 |
| studyCount | int | 学习人数 |
| sort | int | 排序值 |

### 7.2 新增课程

- `POST /api/v1/admin/courses`

请求参数：

```json
{
  "title": "Spring Boot 实战课",
  "subTitle": "从入门到项目落地",
  "teacherId": 2001,
  "categoryLevel1Id": 1,
  "categoryLevel2Id": 11,
  "coverUrl": "https://cdn.xxx.com/course-cover.jpg",
  "description": "课程详细介绍",
  "difficulty": 2,
  "price": 199.00,
  "publishStatus": 0,
  "sort": 100
}
```

### 7.3 后台课程分页列表

- `GET /api/v1/admin/courses`

查询参数：

| 参数 | 说明 |
| --- | --- |
| pageNum | 页码 |
| pageSize | 每页条数 |
| title | 课程标题 |
| teacherId | 教师ID |
| categoryLevel2Id | 二级分类ID |
| publishStatus | 发布状态 |

### 7.4 课程详情

- `GET /api/v1/admin/courses/{id}`

### 7.5 修改课程

- `PUT /api/v1/admin/courses/{id}`

### 7.6 课程上架/下架

- `PUT /api/v1/admin/courses/{id}/publish-status`

请求参数：

```json
{
  "publishStatus": 1
}
```

### 7.7 前台课程列表

- `GET /api/v1/portal/courses`

### 7.8 前台课程详情

- `GET /api/v1/portal/courses/{id}`

建议返回聚合信息：

- 课程基础信息
- 教师信息
- 章节目录
- 课程资料列表
- 课程评价统计

---

## 8. 课程章节模块

### 8.1 结构说明

- 课程目录分为 `章节 chapter` 和 `小节 section`
- 一个课程下可有多个章节
- 一个章节下可有多个小节

### 8.2 章节字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| courseId | bigint | 课程ID |
| title | varchar(200) | 章节标题 |
| sort | int | 排序 |

### 8.3 小节字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| courseId | bigint | 课程ID |
| chapterId | bigint | 章节ID |
| title | varchar(200) | 小节标题 |
| sectionType | tinyint | 1视频 2图文 3直播回放 |
| content | text | 图文内容或扩展描述 |
| videoUrl | varchar(255) | 视频地址 |
| duration | int | 时长，单位秒 |
| isFreeTrial | tinyint | 0否 1是 |
| sort | int | 排序 |

### 8.4 新增章节

- `POST /api/v1/admin/courses/{courseId}/chapters`

### 8.5 修改章节

- `PUT /api/v1/admin/chapters/{id}`

### 8.6 删除章节

- `DELETE /api/v1/admin/chapters/{id}`

删除约束：

- 章节下存在小节时不可直接删除

### 8.7 新增小节

- `POST /api/v1/admin/chapters/{chapterId}/sections`

请求参数：

```json
{
  "title": "Spring Boot 项目初始化",
  "sectionType": 1,
  "videoUrl": "https://cdn.xxx.com/video.mp4",
  "duration": 900,
  "isFreeTrial": 1,
  "sort": 1
}
```

### 8.8 修改小节

- `PUT /api/v1/admin/sections/{id}`

### 8.9 删除小节

- `DELETE /api/v1/admin/sections/{id}`

### 8.10 获取课程章节树

- `GET /api/v1/admin/courses/{courseId}/chapters/tree`
- `GET /api/v1/portal/courses/{courseId}/chapters/tree`

---

## 9. 课程评价模块

### 9.1 评价字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| courseId | bigint | 课程ID |
| memberId | bigint | 会员ID |
| score | tinyint | 1-5分 |
| content | varchar(500) | 评价内容 |
| anonymousFlag | tinyint | 0否 1匿名 |
| status | tinyint | 0待审核 1已通过 2已拒绝 |

### 9.2 学员提交评价

- `POST /api/v1/member/course-reviews`

请求参数：

```json
{
  "courseId": 3001,
  "score": 5,
  "content": "课程内容很系统",
  "anonymousFlag": 0
}
```

约束：

- 同一会员对同一课程默认只允许评价一次
- 仅已学习或已购买用户可评价

### 9.3 后台评价分页列表

- `GET /api/v1/admin/course-reviews`

### 9.4 审核评价

- `PUT /api/v1/admin/course-reviews/{id}/status`

请求参数：

```json
{
  "status": 1
}
```

### 9.5 前台课程评价列表

- `GET /api/v1/portal/courses/{courseId}/reviews`

### 9.6 课程评分统计

- `GET /api/v1/portal/courses/{courseId}/review-summary`

返回参数：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "avgScore": 4.8,
    "reviewCount": 122,
    "scoreDistribution": {
      "5": 100,
      "4": 15,
      "3": 5,
      "2": 1,
      "1": 1
    }
  }
}
```

---

## 10. 课程资料模块

### 10.1 资料字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| courseId | bigint | 课程ID |
| materialName | varchar(200) | 资料名称 |
| materialType | tinyint | 1文档 2压缩包 3图片 4其他 |
| fileUrl | varchar(255) | 文件地址 |
| fileSize | bigint | 文件大小，字节 |
| downloadLimit | tinyint | 0全部学员可下 1已购买可下 |
| sort | int | 排序 |

### 10.2 上传课程资料

- `POST /api/v1/admin/course-materials`

请求参数：

```json
{
  "courseId": 3001,
  "materialName": "课程源码",
  "materialType": 2,
  "fileUrl": "https://cdn.xxx.com/source.zip",
  "fileSize": 204800,
  "downloadLimit": 1,
  "sort": 1
}
```

### 10.3 资料列表

- `GET /api/v1/admin/course-materials`
- `GET /api/v1/portal/courses/{courseId}/materials`

### 10.4 修改资料

- `PUT /api/v1/admin/course-materials/{id}`

### 10.5 删除资料

- `DELETE /api/v1/admin/course-materials/{id}`

说明：

- 当前实现为物理删除，会直接删除 `course_material` 表中的记录

---

## 11. 考试/作业模块

### 11.1 设计说明

- 考试和作业统一抽象为 `course_task`
- `taskType`：`1-考试`，`2-作业`
- 可按课程维度发布
- 学员提交记录落表 `task_submission`

### 11.2 作业/考试字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| courseId | bigint | 课程ID |
| title | varchar(200) | 标题 |
| taskType | tinyint | 1考试 2作业 |
| description | text | 任务说明 |
| totalScore | int | 总分 |
| passScore | int | 及格分 |
| startTime | datetime | 开始时间 |
| endTime | datetime | 截止时间 |
| durationMinutes | int | 时长，考试可用 |
| status | tinyint | 0草稿 1发布 2关闭 |

### 11.3 题目字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| taskId | bigint | 任务ID |
| questionType | tinyint | 1单选 2多选 3判断 4简答 |
| stem | text | 题干 |
| optionsJson | json | 选项JSON |
| answerJson | json | 标准答案JSON |
| score | int | 分值 |
| sort | int | 排序 |

### 11.4 提交记录字段定义

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint | 主键 |
| taskId | bigint | 任务ID |
| memberId | bigint | 学员ID |
| answersJson | json | 用户答案 |
| score | int | 得分 |
| submitTime | datetime | 提交时间 |
| reviewStatus | tinyint | 0待批改 1已批改 |

### 11.5 新增考试/作业

- `POST /api/v1/admin/course-tasks`

请求参数：

```json
{
  "courseId": 3001,
  "title": "第一章单元测试",
  "taskType": 1,
  "description": "请在规定时间内完成",
  "totalScore": 100,
  "passScore": 60,
  "startTime": "2026-06-10 09:00:00",
  "endTime": "2026-06-20 23:59:59",
  "durationMinutes": 60,
  "status": 0
}
```

### 11.6 任务列表

- `GET /api/v1/admin/course-tasks`
- `GET /api/v1/portal/courses/{courseId}/tasks`

### 11.7 任务详情

- `GET /api/v1/admin/course-tasks/{id}`
- `GET /api/v1/member/course-tasks/{id}`

### 11.8 修改任务

- `PUT /api/v1/admin/course-tasks/{id}`

### 11.9 发布任务

- `PUT /api/v1/admin/course-tasks/{id}/status`

请求参数：

```json
{
  "status": 1
}
```

### 11.10 新增题目

- `POST /api/v1/admin/course-tasks/{taskId}/questions`

### 11.11 题目列表

- `GET /api/v1/admin/course-tasks/{taskId}/questions`

### 11.12 修改题目

- `PUT /api/v1/admin/task-questions/{id}`

### 11.13 删除题目

- `DELETE /api/v1/admin/task-questions/{id}`

### 11.14 学员提交考试/作业

- `POST /api/v1/member/course-tasks/{taskId}/submissions`

请求参数：

```json
{
  "answers": [
    {
      "questionId": 1,
      "answer": ["A"]
    },
    {
      "questionId": 2,
      "answer": ["A", "C"]
    },
    {
      "questionId": 3,
      "answer": "这是一段简答内容"
    }
  ]
}
```

### 11.15 学员查看我的提交记录

- `GET /api/v1/member/course-tasks/{taskId}/my-submissions`

### 11.16 后台查看提交列表

- `GET /api/v1/admin/course-tasks/{taskId}/submissions`

### 11.17 后台批改简答题/作业

- `PUT /api/v1/admin/task-submissions/{submissionId}/review`

请求参数：

```json
{
  "score": 88,
  "comment": "整体完成较好，简答题第2问可补充细节"
}
```

---

## 12. 非功能性约束

### 12.1 数据校验

- 手机号、邮箱、分类名、课程名需做格式与唯一性校验
- 金额字段统一保留两位小数
- 发布状态变更前需校验关联数据完整性

### 12.2 权限控制

- 管理端接口统一要求 `ADMIN`
- 教师端仅允许维护自己创建或被授权的课程数据
- 学员端仅允许访问自己的提交记录和个人信息

### 12.3 审计字段

- 建议所有核心业务表增加 `createdBy`、`updatedBy`
- 关键操作记录操作日志，便于后台追踪

### 12.4 文件存储

- 课程封面、课程资料、作业附件建议统一走对象存储
- 数据库只保存文件 URL、文件名、大小、类型等元数据

---

## 13. 一期实现优先级建议

### P0

- 认证与登录
- 会员管理
- 教师管理
- 课程分类
- 课程基本信息
- 课程章节

### P1

- 课程资料
- 课程评价

### P2

- 考试/作业
- 自动评分
- 教师端权限细化
